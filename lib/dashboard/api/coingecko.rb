# frozen_string_literal: true

require 'httparty'

module Dashboard
  module API
    # Cliente para a API do CoinGecko
    # Permite buscar informações de criptomoedas
    class CoinGecko
      include HTTParty
      base_uri 'https://api.coingecko.com/api/v3'

      POPULAR_COINS = %w[bitcoin ethereum binancecoin cardano solana ripple polkadot dogecoin].freeze

      # Busca o preço atual de uma criptomoeda
      # @param coin_id [String] ID da moeda no CoinGecko (ex: 'bitcoin')
      # @param currency [String] moeda de referência (ex: 'brl', 'usd')
      # @return [Hash, nil] dados do preço ou nil em caso de erro
      def price(coin_id, currency: 'brl')
        response = self.class.get('/simple/price', query: {
          ids: coin_id,
          vs_currencies: currency,
          include_24hr_change: true,
          include_market_cap: true
        })

        return { error: 'Erro na consulta de preço' } unless response.success?

        data = response[coin_id]
        return { error: "Moeda não encontrada: #{coin_id}" } unless data

        {
          coin: coin_id,
          currency: currency.upcase,
          price: data[currency],
          change_24h: data["#{currency}_24h_change"],
          market_cap: data["#{currency}_market_cap"]
        }
      rescue StandardError => e
        { error: e.message }
      end

      # Busca lista de criptomoedas populares com preços
      # @param currency [String] moeda de referência
      # @return [Array] lista de moedas com preços
      def popular_coins(currency: 'brl')
        response = self.class.get('/simple/price', query: {
          ids: POPULAR_COINS.join(','),
          vs_currencies: currency,
          include_24hr_change: true
        })

        return { error: 'Erro na consulta' } unless response.success?

        POPULAR_COINS.filter_map do |coin|
          next unless response[coin]

          {
            coin: coin,
            price: response[coin][currency],
            change_24h: response[coin]["#{currency}_24h_change"]
          }
        end
      rescue StandardError => e
        { error: e.message }
      end

      # Busca informações detalhadas de uma moeda
      # @param coin_id [String] ID da moeda no CoinGecko
      # @return [Hash] informações detalhadas da moeda
      def coin_info(coin_id)
        response = self.class.get("/coins/#{coin_id}", query: {
          localization: false,
          tickers: false,
          community_data: false,
          developer_data: false
        })

        return { error: "Moeda não encontrada: #{coin_id}" } unless response.success?

        parse_coin_info(response)
      rescue StandardError => e
        { error: e.message }
      end

      private

      def parse_coin_info(response)
        {
          id: response['id'],
          symbol: response['symbol']&.upcase,
          name: response['name'],
          description: response.dig('description', 'pt') || response.dig('description', 'en'),
          image: response.dig('image', 'small'),
          market_cap_rank: response['market_cap_rank'],
          current_price_brl: response.dig('market_data', 'current_price', 'brl'),
          current_price_usd: response.dig('market_data', 'current_price', 'usd'),
          price_change_24h: response.dig('market_data', 'price_change_percentage_24h'),
          high_24h_brl: response.dig('market_data', 'high_24h', 'brl'),
          low_24h_brl: response.dig('market_data', 'low_24h', 'brl')
        }
      end
    end
  end
end
