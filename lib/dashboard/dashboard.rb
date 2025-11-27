# frozen_string_literal: true

require_relative 'api/github'
require_relative 'api/weather'
require_relative 'api/viacep'
require_relative 'api/coingecko'
require_relative 'helpers/display'
require_relative 'helpers/spinner'
require_relative 'menu'

module Dashboard
  # Orquestrador principal do Dashboard
  class Dashboard
    include Helpers::Display
    include Helpers::Spinner

    def initialize
      @menu = Menu.new
      @github = API::GitHub.new
      @weather = API::Weather.new
      @viacep = API::ViaCEP.new
      @coingecko = API::CoinGecko.new
    end

    # Inicia o loop principal do dashboard
    def run
      loop do
        clear_screen
        choice = @menu.show

        case choice
        when :github
          handle_github
        when :weather
          handle_weather
        when :cep
          handle_cep
        when :crypto
          handle_crypto
        when :about
          handle_about
        when :exit
          handle_exit
          break
        end
      end
    end

    private

    def handle_github
      clear_screen
      header('👤 Consulta GitHub')

      username = @menu.ask('Digite o nome de usuário do GitHub:', default: 'octocat')

      user_data = with_spinner('Buscando perfil do usuário...') do
        @github.user(username)
      end

      github_user(user_data)

      if user_data && !user_data[:error]
        repos_data = with_spinner('Buscando repositórios...') do
          @github.repositories(username, limit: 5)
        end
        github_repos(repos_data)
      end

      wait_for_input
    end

    def handle_weather
      clear_screen
      header('🌤️ Consulta de Clima')

      unless @weather.configured?
        warning('API Key do OpenWeatherMap não configurada!')
        puts '  Configure a variável OPENWEATHERMAP_API_KEY no arquivo .env'
        puts '  Obtenha sua chave em: https://openweathermap.org/api'
        wait_for_input
        return
      end

      city = @menu.ask('Digite o nome da cidade:', default: 'São Paulo')

      weather_data = with_spinner("Buscando clima para #{city}...") do
        @weather.current(city, country_code: 'BR')
      end

      weather(weather_data)
      wait_for_input
    end

    def handle_cep
      clear_screen
      header('📍 Consulta de CEP')

      cep = @menu.ask('Digite o CEP (apenas números):', default: '01310100')

      address_data = with_spinner('Buscando informações do CEP...') do
        @viacep.lookup(cep)
      end

      address(address_data)
      wait_for_input
    end

    def handle_crypto
      clear_screen
      header('💰 Cotações de Criptomoedas')

      crypto_options = {
        popular: '📊 Ver moedas populares',
        search: '🔍 Buscar moeda específica',
        back: '⬅️  Voltar'
      }

      choice = @menu.select('O que deseja fazer?', crypto_options)

      case choice
      when :popular
        show_popular_cryptos
      when :search
        search_crypto
      when :back
        return
      end

      wait_for_input
    end

    def show_popular_cryptos
      coins_data = with_spinner('Buscando cotações...') do
        @coingecko.popular_coins(currency: 'brl')
      end

      crypto_list(coins_data)
    end

    def search_crypto
      coin_options = {
        'bitcoin' => 'Bitcoin (BTC)',
        'ethereum' => 'Ethereum (ETH)',
        'binancecoin' => 'Binance Coin (BNB)',
        'cardano' => 'Cardano (ADA)',
        'solana' => 'Solana (SOL)',
        'ripple' => 'Ripple (XRP)',
        'dogecoin' => 'Dogecoin (DOGE)',
        'polkadot' => 'Polkadot (DOT)'
      }

      coin_id = @menu.select('Selecione a criptomoeda:', coin_options)

      coin_data = with_spinner("Buscando informações de #{coin_id}...") do
        @coingecko.coin_info(coin_id)
      end

      crypto_info(coin_data)
    end

    def handle_about
      clear_screen
      header('ℹ️ Sobre o Dashboard')

      puts '  Este é um dashboard interativo em Ruby que integra múltiplas APIs:'
      puts ''
      puts '  📌 APIs Integradas:'.colorize(:cyan)
      puts '     • GitHub API - Informações de perfis e repositórios'
      puts '     • OpenWeatherMap - Previsão do tempo em tempo real'
      puts '     • ViaCEP - Consulta de endereços brasileiros'
      puts '     • CoinGecko - Cotações de criptomoedas'
      puts ''
      puts '  🛠️  Tecnologias:'.colorize(:cyan)
      puts '     • Ruby'
      puts '     • HTTParty (requisições HTTP)'
      puts '     • TTY::Prompt (menu interativo)'
      puts '     • TTY::Spinner (animações de loading)'
      puts '     • Colorize (cores no terminal)'
      puts ''
      puts '  👨‍💻 Desenvolvido para praticar integração de APIs em Ruby'.colorize(:light_black)
      puts ''
      separator

      wait_for_input
    end

    def handle_exit
      clear_screen
      puts ''
      puts '╔════════════════════════════════════════════════════════════════════════════╗'.colorize(:cyan)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '║                     👋 Obrigado por usar o Dashboard!                      ║'.colorize(:yellow)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '║                          Até a próxima! 🚀                                 ║'.colorize(:light_blue)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '╚════════════════════════════════════════════════════════════════════════════╝'.colorize(:cyan)
      puts ''
    end
  end
end
