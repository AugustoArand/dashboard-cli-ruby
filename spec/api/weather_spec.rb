# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::API::Weather do
  describe '#configured?' do
    context 'when API key is not set' do
      subject(:weather) { described_class.new(nil) }

      it 'returns false' do
        expect(weather.configured?).to be false
      end
    end

    context 'when API key is placeholder' do
      subject(:weather) { described_class.new('sua_chave_aqui') }

      it 'returns false' do
        expect(weather.configured?).to be false
      end
    end

    context 'when API key is valid' do
      subject(:weather) { described_class.new('valid_api_key') }

      it 'returns true' do
        expect(weather.configured?).to be true
      end
    end
  end

  describe '#current' do
    context 'when not configured' do
      subject(:weather) { described_class.new(nil) }

      it 'returns error message' do
        result = weather.current('São Paulo')
        expect(result[:error]).to include('API key não configurada')
      end
    end

    context 'when configured' do
      subject(:weather) { described_class.new('valid_api_key') }

      before do
        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: hash_including(q: 'São Paulo,BR'))
          .to_return(
            status: 200,
            body: {
              name: 'São Paulo',
              sys: { country: 'BR' },
              main: {
                temp: 25.0,
                feels_like: 26.5,
                humidity: 60,
                pressure: 1015
              },
              weather: [{ description: 'céu limpo', icon: '01d' }],
              wind: { speed: 3.5 },
              clouds: { all: 10 }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns weather data' do
        result = weather.current('São Paulo', country_code: 'BR')

        expect(result[:city]).to eq('São Paulo')
        expect(result[:country]).to eq('BR')
        expect(result[:temperature]).to eq(25.0)
        expect(result[:humidity]).to eq(60)
        expect(result[:description]).to eq('céu limpo')
      end
    end

    context 'when city not found' do
      subject(:weather) { described_class.new('valid_api_key') }

      before do
        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: hash_including(q: 'InvalidCity'))
          .to_return(status: 404)
      end

      it 'returns error message' do
        result = weather.current('InvalidCity')
        expect(result[:error]).to include('Cidade não encontrada')
      end
    end
  end
end
