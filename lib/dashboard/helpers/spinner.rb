# frozen_string_literal: true

require 'tty-spinner'

module Dashboard
  module Helpers
    # Módulo para gerenciar spinners de loading animados
    module Spinner
      # Estilos de spinner disponíveis
      STYLES = {
        dots: '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏',
        line: '-\\|/',
        pulse: '█▓▒░',
        arrows: '←↖↑↗→↘↓↙',
        bounce: '⠁⠂⠄⠂',
        grow: '▁▃▄▅▆▇█▇▆▅▄▃'
      }.freeze

      module_function

      # Cria e executa um spinner durante uma operação
      # @param message [String] mensagem a ser exibida
      # @param style [Symbol] estilo do spinner (:dots, :line, :pulse, etc)
      # @yield bloco a ser executado
      # @return [Object] resultado do bloco
      def with_spinner(message, style: :dots, success_message: nil, error_message: nil)
        format_string = "[:spinner] #{message}"
        spinner = TTY::Spinner.new(format_string, format: style)

        spinner.auto_spin
        result = yield
        
        if result.is_a?(Hash) && result[:error]
          spinner.error(error_message || '(erro)')
        else
          spinner.success(success_message || '(concluído)')
        end

        result
      rescue StandardError => e
        spinner.error("(erro: #{e.message})")
        { error: e.message }
      end

      # Cria múltiplos spinners para operações paralelas
      # @param tasks [Hash] hash com nome => mensagem das tarefas
      # @yield [name] bloco que recebe o nome da tarefa
      def multi_spinner(tasks)
        spinners = TTY::Spinner::Multi.new('[:spinner] Carregando dados...')

        results = {}
        threads = tasks.map do |name, message|
          sp = spinners.register("[:spinner] #{message}")
          Thread.new do
            sp.auto_spin
            results[name] = yield(name)
            sp.success
          rescue StandardError => e
            results[name] = { error: e.message }
            sp.error
          end
        end

        threads.each(&:join)
        results
      end
    end
  end
end
