# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::API::GitHub do
  subject(:github) { described_class.new }

  describe '#user' do
    context 'when user exists' do
      before do
        stub_request(:get, 'https://api.github.com/users/octocat')
          .to_return(
            status: 200,
            body: {
              login: 'octocat',
              name: 'The Octocat',
              bio: 'GitHub mascot',
              public_repos: 8,
              followers: 10000,
              following: 9,
              created_at: '2011-01-25T18:44:36Z',
              avatar_url: 'https://avatars.githubusercontent.com/u/583231?v=4',
              html_url: 'https://github.com/octocat'
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns user data' do
        result = github.user('octocat')

        expect(result[:login]).to eq('octocat')
        expect(result[:name]).to eq('The Octocat')
        expect(result[:public_repos]).to eq(8)
        expect(result[:followers]).to eq(10000)
      end
    end

    context 'when user does not exist' do
      before do
        stub_request(:get, 'https://api.github.com/users/nonexistent')
          .to_return(status: 404)
      end

      it 'returns nil' do
        result = github.user('nonexistent')
        expect(result).to be_nil
      end
    end
  end

  describe '#repositories' do
    before do
      stub_request(:get, 'https://api.github.com/users/octocat/repos')
        .with(query: { sort: 'updated', per_page: 5 })
        .to_return(
          status: 200,
          body: [
            {
              name: 'Hello-World',
              description: 'My first repository',
              language: 'Ruby',
              stargazers_count: 2000,
              forks_count: 500,
              html_url: 'https://github.com/octocat/Hello-World'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns list of repositories' do
      result = github.repositories('octocat', limit: 5)

      expect(result).to be_an(Array)
      expect(result.first[:name]).to eq('Hello-World')
      expect(result.first[:language]).to eq('Ruby')
      expect(result.first[:stars]).to eq(2000)
    end
  end
end
