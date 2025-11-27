# frozen_string_literal: true

require 'colorize'

module Dashboard
  module Helpers
    # Módulo para formatação e exibição de dados no terminal
    module Display
      TERMINAL_WIDTH = 80
      SEPARATOR = '─' * TERMINAL_WIDTH

      module_function

      # Limpa a tela do terminal
      def clear_screen
        system('clear') || system('cls')
      end

      # Exibe um cabeçalho formatado
      # @param title [String] título do cabeçalho
      def header(title)
        puts "\n"
        puts '═' * TERMINAL_WIDTH
        puts title.center(TERMINAL_WIDTH).colorize(:cyan).bold
        puts '═' * TERMINAL_WIDTH
        puts "\n"
      end

      # Exibe uma linha separadora
      def separator
        puts SEPARATOR.colorize(:light_black)
      end

      # Exibe uma mensagem de sucesso
      # @param message [String] mensagem
      def success(message)
        puts "✅ #{message}".colorize(:green)
      end

      # Exibe uma mensagem de erro
      # @param message [String] mensagem
      def error(message)
        puts "❌ #{message}".colorize(:red)
      end

      # Exibe uma mensagem de aviso
      # @param message [String] mensagem
      def warning(message)
        puts "⚠️  #{message}".colorize(:yellow)
      end

      # Exibe informação com label e valor
      # @param label [String] rótulo
      # @param value [Object] valor
      def info(label, value)
        formatted_label = "#{label}:".colorize(:light_blue)
        puts "  #{formatted_label} #{value}"
      end

      # Exibe dados de usuário do GitHub
      # @param user [Hash] dados do usuário
      def github_user(user)
        if user[:error]
          error(user[:error])
          return
        end

        header('👤 Perfil GitHub')
        info('Login', user[:login])
        info('Nome', user[:name] || 'Não informado')
        info('Bio', user[:bio] || 'Não informada')
        info('Repositórios Públicos', user[:public_repos])
        info('Seguidores', user[:followers])
        info('Seguindo', user[:following])
        info('Membro desde', format_date(user[:created_at]))
        info('URL', user[:html_url])
        separator
      end

      # Exibe lista de repositórios do GitHub
      # @param repos [Array] lista de repositórios
      def github_repos(repos)
        if repos.is_a?(Hash) && repos[:error]
          error(repos[:error])
          return
        end

        puts "\n📦 Repositórios Recentes:".colorize(:cyan)
        separator

        repos.each_with_index do |repo, index|
          puts "  #{index + 1}. #{repo[:name].colorize(:yellow)}"
          puts "     #{repo[:description] || 'Sem descrição'}".colorize(:light_black)
          puts "     ⭐ #{repo[:stars]} | 🍴 #{repo[:forks]} | 💻 #{repo[:language] || 'N/A'}"
          puts ''
        end
      end

      # Exibe dados do clima
      # @param weather [Hash] dados do clima
      def weather(weather)
        if weather[:error]
          error(weather[:error])
          return
        end

        header("#{weather[:icon]} Clima em #{weather[:city]}, #{weather[:country]}")
        info('Temperatura', "#{weather[:temperature]}°C")
        info('Sensação Térmica', "#{weather[:feels_like]}°C")
        info('Condição', weather[:description]&.capitalize)
        info('Umidade', "#{weather[:humidity]}%")
        info('Pressão', "#{weather[:pressure]} hPa")
        info('Vento', "#{weather[:wind_speed]} m/s")
        info('Nuvens', "#{weather[:clouds]}%")
        separator
      end

      # Exibe dados de CEP
      # @param address [Hash] dados do endereço
      def address(address)
        if address[:error]
          error(address[:error])
          return
        end

        header('📍 Informações do CEP')
        info('CEP', address[:cep])
        info('Logradouro', address[:logradouro] || 'Não informado')
        info('Bairro', address[:bairro] || 'Não informado')
        info('Cidade', address[:cidade])
        info('Estado', address[:estado])
        info('DDD', address[:ddd])
        info('Código IBGE', address[:ibge])
        separator
      end

      # Exibe dados de criptomoeda
      # @param crypto [Hash] dados da criptomoeda
      def crypto(crypto)
        if crypto[:error]
          error(crypto[:error])
          return
        end

        change_color = crypto[:change_24h].to_f >= 0 ? :green : :red
        change_icon = crypto[:change_24h].to_f >= 0 ? '📈' : '📉'

        header("💰 #{crypto[:coin].capitalize}")
        info('Preço', format_currency(crypto[:price], crypto[:currency]))
        info('Variação 24h', "#{change_icon} #{format_percentage(crypto[:change_24h])}".colorize(change_color))
        info('Market Cap', format_currency(crypto[:market_cap], crypto[:currency])) if crypto[:market_cap]
        separator
      end

      # Exibe lista de criptomoedas
      # @param coins [Array] lista de moedas
      def crypto_list(coins)
        if coins.is_a?(Hash) && coins[:error]
          error(coins[:error])
          return
        end

        header('💎 Criptomoedas Populares')

        coins.each do |coin|
          change_color = coin[:change_24h].to_f >= 0 ? :green : :red
          change_icon = coin[:change_24h].to_f >= 0 ? '▲' : '▼'

          name = coin[:coin].capitalize.ljust(12)
          price = format_currency(coin[:price], 'BRL').rjust(15)
          change = "#{change_icon} #{format_percentage(coin[:change_24h])}".colorize(change_color)

          puts "  #{name} #{price}  #{change}"
        end

        separator
      end

      # Exibe informações detalhadas de uma criptomoeda
      # @param info [Hash] informações da moeda
      def crypto_info(info)
        if info[:error]
          error(info[:error])
          return
        end

        change_color = info[:price_change_24h].to_f >= 0 ? :green : :red

        header("💰 #{info[:name]} (#{info[:symbol]})")
        info('Ranking', "##{info[:market_cap_rank]}")
        info('Preço BRL', format_currency(info[:current_price_brl], 'BRL'))
        info('Preço USD', format_currency(info[:current_price_usd], 'USD'))
        info('Variação 24h', format_percentage(info[:price_change_24h]).colorize(change_color))
        info('Máxima 24h', format_currency(info[:high_24h_brl], 'BRL'))
        info('Mínima 24h', format_currency(info[:low_24h_brl], 'BRL'))
        separator

        if info[:description] && !info[:description].empty?
          puts "\n📝 Descrição:".colorize(:cyan)
          puts word_wrap(info[:description][0..500])
          puts '...' if info[:description].length > 500
        end
      end

      # Formata uma data ISO para formato legível
      # @param date_string [String] data em formato ISO
      # @return [String] data formatada
      def format_date(date_string)
        return 'N/A' unless date_string

        date = Date.parse(date_string)
        date.strftime('%d/%m/%Y')
      rescue StandardError
        date_string
      end

      # Formata valor monetário
      # @param value [Numeric] valor
      # @param currency [String] moeda
      # @return [String] valor formatado
      def format_currency(value, currency)
        return 'N/A' unless value

        case currency.to_s.upcase
        when 'BRL'
          "R$ #{format_number(value)}"
        when 'USD'
          "$ #{format_number(value)}"
        else
          "#{format_number(value)} #{currency}"
        end
      end

      # Formata número com separadores
      # @param value [Numeric] valor
      # @return [String] número formatado
      def format_number(value)
        return 'N/A' unless value

        if value >= 1_000_000
          "#{(value / 1_000_000.0).round(2)}M"
        elsif value >= 1_000
          "#{(value / 1_000.0).round(2)}K"
        elsif value < 1
          value.round(6).to_s
        else
          value.round(2).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
        end
      end

      # Formata porcentagem
      # @param value [Numeric] valor
      # @return [String] porcentagem formatada
      def format_percentage(value)
        return 'N/A' unless value

        "#{value.round(2)}%"
      end

      # Quebra texto em linhas
      # @param text [String] texto
      # @param width [Integer] largura máxima
      # @return [String] texto quebrado
      def word_wrap(text, width: TERMINAL_WIDTH - 4)
        return '' unless text

        # Remove HTML tags using a simple approach that avoids ReDoS
        clean_text = remove_html_tags(text)
        # Word wrap the cleaned text
        clean_text.scan(/.{1,#{width}}(?:\s|$)|.{1,#{width}}/).map { |line| "  #{line.strip}" }.join("\n")
      end

      # Safely removes HTML tags from text
      # @param text [String] text to clean
      # @return [String] text without HTML tags
      def remove_html_tags(text)
        result = +''
        in_tag = false
        text.each_char do |char|
          if char == '<'
            in_tag = true
          elsif char == '>'
            in_tag = false
          elsif !in_tag
            result << char
          end
        end
        result
      end

      # Aguarda input do usuário
      def wait_for_input
        puts "\n"
        puts 'Pressione ENTER para continuar...'.colorize(:light_black)
        gets
      end
    end
  end
end
