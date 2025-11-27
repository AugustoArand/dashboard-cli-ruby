# frozen_string_literal: true

require 'httparty'

module Dashboard
  module API
    # Cliente para a API do OpenWeatherMap
    # Permite buscar informações meteorológicas por cidade
    class Weather
      include HTTParty
      base_uri 'https://api.openweathermap.org/data/2.5'

      def initialize(api_key = nil)
        @api_key = api_key || ENV['OPENWEATHERMAP_API_KEY']
      end

      # Verifica se a API key está configurada
      # @return [Boolean] true se a chave está configurada
      def configured?
        @api_key && !@api_key.empty? && @api_key != 'sua_chave_aqui'
      end

      # Busca o clima atual de uma cidade
      # @param city [String] nome da cidade
      # @param country_code [String] código do país (opcional, ex: 'BR')
      # @return [Hash, nil] dados do clima ou nil em caso de erro
      def current(city, country_code: nil)
        return { error: 'API key não configurada. Configure OPENWEATHERMAP_API_KEY no arquivo .env' } unless configured?

        location = country_code ? "#{city},#{country_code}" : city
        response = self.class.get('/weather', query: {
          q: location,
          appid: @api_key,
          units: 'metric',
          lang: 'pt_br'
        })

        return { error: "Cidade não encontrada: #{city}" } unless response.success?

        parse_weather_response(response)
      rescue StandardError => e
        { error: e.message }
      end

      private

      def parse_weather_response(response)
        {
          city: response['name'],
          country: response.dig('sys', 'country'),
          temperature: response.dig('main', 'temp'),
          feels_like: response.dig('main', 'feels_like'),
          humidity: response.dig('main', 'humidity'),
          pressure: response.dig('main', 'pressure'),
          description: response.dig('weather', 0, 'description'),
          icon: weather_icon(response.dig('weather', 0, 'icon')),
          wind_speed: response.dig('wind', 'speed'),
          clouds: response.dig('clouds', 'all')
        }
      end

      def weather_icon(icon_code)
        icons = {
          '01d' => '☀️', '01n' => '🌙',
          '02d' => '⛅', '02n' => '☁️',
          '03d' => '☁️', '03n' => '☁️',
          '04d' => '☁️', '04n' => '☁️',
          '09d' => '🌧️', '09n' => '🌧️',
          '10d' => '🌦️', '10n' => '🌧️',
          '11d' => '⛈️', '11n' => '⛈️',
          '13d' => '❄️', '13n' => '❄️',
          '50d' => '🌫️', '50n' => '🌫️'
        }
        icons[icon_code] || '🌡️'
      end
    end
  end
end
