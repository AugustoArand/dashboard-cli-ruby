# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::API::ViaCEP do
  subject(:viacep) { described_class.new }

  describe '#lookup' do
    context 'with valid CEP' do
      before do
        stub_request(:get, 'https://viacep.com.br/ws/01310100/json')
          .to_return(
            status: 200,
            body: {
              cep: '01310-100',
              logradouro: 'Avenida Paulista',
              complemento: 'até 610 - lado par',
              bairro: 'Bela Vista',
              localidade: 'São Paulo',
              uf: 'SP',
              ibge: '3550308',
              ddd: '11'
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns address data' do
        result = viacep.lookup('01310100')

        expect(result[:cep]).to eq('01310-100')
        expect(result[:logradouro]).to eq('Avenida Paulista')
        expect(result[:cidade]).to eq('São Paulo')
        expect(result[:estado]).to eq('SP')
        expect(result[:ddd]).to eq('11')
      end

      it 'accepts CEP with hyphen' do
        result = viacep.lookup('01310-100')

        expect(result[:cep]).to eq('01310-100')
      end
    end

    context 'with invalid CEP format' do
      it 'returns error for short CEP' do
        result = viacep.lookup('0131')
        expect(result[:error]).to eq('CEP deve ter 8 dígitos')
      end

      it 'returns error for long CEP' do
        result = viacep.lookup('013101001234')
        expect(result[:error]).to eq('CEP deve ter 8 dígitos')
      end
    end

    context 'with non-existent CEP' do
      before do
        stub_request(:get, 'https://viacep.com.br/ws/99999999/json')
          .to_return(
            status: 200,
            body: { erro: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns error message' do
        result = viacep.lookup('99999999')
        expect(result[:error]).to eq('CEP não encontrado')
      end
    end
  end
end
