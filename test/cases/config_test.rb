# frozen_string_literal: true

require "test_helper"

module SteamApiclient
  class ConfigTest < Minitest::Spec
    def build_config(overrides = {})
      with_env(
        {
          "STEAM_API_KEY" => "REALKEY1234567890",
          "STEAM_API_KEY_DOMAIN" => "example.com",
          "STEAM_API_ROOT_URL" => nil
        }.merge(overrides)
      ) { SteamApiClient::Config.new }
    end

    describe "#initialize" do
      it "reads api_key and api_key_domain from ENV" do
        config = build_config

        assert_equal "REALKEY1234567890", config.api_key
        assert_equal "example.com", config.api_key_domain
      end

      it "defaults api_root_url when STEAM_API_ROOT_URL isn't set" do
        assert_equal SteamApiClient::Config::DEFAULT_API_ROOT_URL, build_config.api_root_url
      end

      it "honors a custom STEAM_API_ROOT_URL" do
        config = build_config("STEAM_API_ROOT_URL" => "https://staging.example.com")

        assert_equal "https://staging.example.com", config.api_root_url
      end

      it "rejects the placeholder API key shipped in the example .env" do
        assert_raises(SteamApiClient::Config::Error) { build_config("STEAM_API_KEY" => "secret") }
      end

      it "rejects a blank API key" do
        assert_raises(SteamApiClient::Config::Error) { build_config("STEAM_API_KEY" => "   ") }
      end

      it "rejects the placeholder domain shipped in the example .env" do
        assert_raises(SteamApiClient::Config::Error) { build_config("STEAM_API_KEY_DOMAIN" => "your-domain.com") }
      end

      it "rejects a blank domain" do
        assert_raises(SteamApiClient::Config::Error) { build_config("STEAM_API_KEY_DOMAIN" => "") }
      end
    end

    describe "#user_agent_string" do
      it "builds the expected user agent string" do
        config = build_config

        assert_equal "steam-api-client-ruby/#{SteamApiClient::VERSION} (+ example.com)", config.user_agent_string
      end
    end
  end
end
