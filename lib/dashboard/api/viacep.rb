# frozen_string_literal: true

require 'httparty'

module Dashboard
  module API
    # Cliente para a API do ViaCEP
    # Permite buscar informações de endereço por CEP brasileiro
    class ViaCEP
      include HTTParty
      base_uri 'https://viacep.com.br/ws'

      # Busca informações de um CEP
      # @param cep [String] CEP a ser consultado (apenas números ou com hífen)
      # @return [Hash, nil] dados do endereço ou nil em caso de erro
      def lookup(cep)
        # Remove caracteres não numéricos
        clean_cep = cep.to_s.gsub(/\D/, '')

        return { error: 'CEP deve ter 8 dígitos' } unless clean_cep.length == 8

        response = self.class.get("/#{clean_cep}/json")
        return { error: 'Erro na consulta do CEP' } unless response.success?

        parsed = response.parsed_response
        return { error: 'CEP não encontrado' } if parsed['erro']

        parse_cep_response(parsed)
      rescue StandardError => e
        { error: e.message }
      end

      private

      def parse_cep_response(response)
        {
          cep: response['cep'],
          logradouro: response['logradouro'],
          complemento: response['complemento'],
          bairro: response['bairro'],
          cidade: response['localidade'],
          estado: response['uf'],
          ibge: response['ibge'],
          ddd: response['ddd']
        }
      end
    end
  end
end
