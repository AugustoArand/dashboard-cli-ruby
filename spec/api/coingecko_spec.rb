# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::API::CoinGecko do
  subject(:coingecko) { described_class.new }

  describe '#price' do
    context 'when coin exists' do
      before do
        stub_request(:get, 'https://api.coingecko.com/api/v3/simple/price')
          .with(query: hash_including(ids: 'bitcoin'))
          .to_return(
            status: 200,
            body: {
              bitcoin: {
                brl: 350000.0,
                brl_24h_change: 2.5,
                brl_market_cap: 6_800_000_000_000
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns price data' do
        result = coingecko.price('bitcoin', currency: 'brl')

        expect(result[:coin]).to eq('bitcoin')
        expect(result[:currency]).to eq('BRL')
        expect(result[:price]).to eq(350000.0)
        expect(result[:change_24h]).to eq(2.5)
      end
    end

    context 'when coin does not exist' do
      before do
        stub_request(:get, 'https://api.coingecko.com/api/v3/simple/price')
          .with(query: hash_including(ids: 'invalidcoin'))
          .to_return(
            status: 200,
            body: {}.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns error' do
        result = coingecko.price('invalidcoin')
        expect(result[:error]).to include('Moeda não encontrada')
      end
    end
  end

  describe '#popular_coins' do
    before do
      stub_request(:get, 'https://api.coingecko.com/api/v3/simple/price')
        .with(query: hash_including(ids: include('bitcoin')))
        .to_return(
          status: 200,
          body: {
            bitcoin: { brl: 350000.0, brl_24h_change: 2.5 },
            ethereum: { brl: 12000.0, brl_24h_change: -1.2 }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns list of popular coins' do
      result = coingecko.popular_coins(currency: 'brl')

      expect(result).to be_an(Array)
      expect(result.map { |c| c[:coin] }).to include('bitcoin', 'ethereum')
    end
  end
end
