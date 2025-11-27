# frozen_string_literal: true

require 'httparty'

module Dashboard
  module API
    # Cliente para a API do GitHub
    # Permite buscar informações de usuários e repositórios
    class GitHub
      include HTTParty
      base_uri 'https://api.github.com'

      def initialize(token = nil)
        @token = token || ENV['GITHUB_TOKEN']
        @headers = {
          'User-Agent' => 'Dashboard-CLI-Ruby',
          'Accept' => 'application/vnd.github.v3+json'
        }
        @headers['Authorization'] = "token #{@token}" if @token && !@token.empty? && @token != 'seu_token_aqui'
      end

      # Busca informações de um usuário do GitHub
      # @param username [String] nome de usuário do GitHub
      # @return [Hash, nil] dados do usuário ou nil em caso de erro
      def user(username)
        response = self.class.get("/users/#{username}", headers: @headers)
        return nil unless response.success?

        parse_user_response(response)
      rescue StandardError => e
        { error: e.message }
      end

      # Busca repositórios de um usuário
      # @param username [String] nome de usuário do GitHub
      # @param limit [Integer] número máximo de repositórios
      # @return [Array, nil] lista de repositórios ou nil em caso de erro
      def repositories(username, limit: 5)
        response = self.class.get(
          "/users/#{username}/repos",
          headers: @headers,
          query: { sort: 'updated', per_page: limit }
        )
        return nil unless response.success?

        parse_repositories_response(response)
      rescue StandardError => e
        { error: e.message }
      end

      private

      def parse_user_response(response)
        {
          login: response['login'],
          name: response['name'],
          bio: response['bio'],
          public_repos: response['public_repos'],
          followers: response['followers'],
          following: response['following'],
          created_at: response['created_at'],
          avatar_url: response['avatar_url'],
          html_url: response['html_url']
        }
      end

      def parse_repositories_response(response)
        response.map do |repo|
          {
            name: repo['name'],
            description: repo['description'],
            language: repo['language'],
            stars: repo['stargazers_count'],
            forks: repo['forks_count'],
            url: repo['html_url']
          }
        end
      end
    end
  end
end
