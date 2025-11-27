# frozen_string_literal: true

require 'tty-prompt'
require 'colorize'

module Dashboard
  # Menu interativo com navegação por setas
  class Menu
    MENU_OPTIONS = {
      github: '👤 GitHub - Buscar perfil de usuário',
      weather: '🌤️  Clima - Consultar previsão do tempo',
      cep: '📍 CEP - Buscar endereço por CEP',
      crypto: '💰 Crypto - Cotações de criptomoedas',
      about: 'ℹ️  Sobre - Informações do dashboard',
      exit: '🚪 Sair'
    }.freeze

    def initialize
      @prompt = TTY::Prompt.new(
        symbols: { marker: '❯' },
        active_color: :cyan,
        help_color: :light_black
      )
    end

    # Exibe o menu principal e retorna a opção selecionada
    # @return [Symbol] opção selecionada
    def show
      display_banner
      
      @prompt.select(
        'Escolha uma opção:'.colorize(:yellow),
        MENU_OPTIONS,
        cycle: true,
        per_page: 7,
        help: '(Use ↑/↓ para navegar e Enter para selecionar)'
      )
    end

    # Solicita input de texto ao usuário
    # @param message [String] mensagem do prompt
    # @param default [String] valor padrão
    # @return [String] valor inserido
    def ask(message, default: nil)
      @prompt.ask(message.colorize(:yellow), default: default) do |q|
        q.required true
        q.modify :strip
      end
    end

    # Solicita seleção de uma lista
    # @param message [String] mensagem do prompt
    # @param options [Array, Hash] opções disponíveis
    # @return [Object] opção selecionada
    def select(message, options)
      @prompt.select(message.colorize(:yellow), options, cycle: true)
    end

    # Confirma uma ação
    # @param message [String] mensagem de confirmação
    # @return [Boolean] resposta do usuário
    def confirm(message)
      @prompt.yes?(message.colorize(:yellow))
    end

    private

    def display_banner
      puts ''
      puts '╔════════════════════════════════════════════════════════════════════════════╗'.colorize(:cyan)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '║     ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗║'.colorize(:cyan)
      puts '║     ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██║'.colorize(:cyan)
      puts '║     ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║'.colorize(:cyan)
      puts '║     ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║'.colorize(:cyan)
      puts '║     ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝║'.colorize(:cyan)
      puts '║     ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ║'.colorize(:cyan)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '║                    🚀 Dashboard Interativo em Ruby 🚀                      ║'.colorize(:light_blue)
      puts '║                                                                            ║'.colorize(:cyan)
      puts '╚════════════════════════════════════════════════════════════════════════════╝'.colorize(:cyan)
      puts ''
    end
  end
end
