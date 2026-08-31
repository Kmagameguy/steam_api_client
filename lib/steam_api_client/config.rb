# frozen_string_literal: true

module SteamApiClient
  class Config
    class Error < StandardError; end
    DEFAULT_API_ROOT_URL = "https://api.steampowered.com"

    attr_accessor :api_key,
                  :api_key_domain,
                  :api_root_url

    def initialize
      @api_key = ENV.fetch("STEAM_API_KEY")
      @api_key_domain = ENV.fetch("STEAM_API_KEY_DOMAIN")
      @api_root_url = ENV.fetch("STEAM_API_ROOT_URL", DEFAULT_API_ROOT_URL)

      raise Error, "Invalid API Key" if @api_key == "secret" || @api_key.strip.empty?
      raise Error, "Invalid API Key Domain" if @api_key == "your-domain.com" || @api_k
    end

    def user_agent_string
      "steam-api-client-ruby/#{SteamApiClient::VERSION} (+ #{api_key_domain})"
    end

    private

    def validate_config
      raise Error, "Invalid API Key, check ENV" if api_key == "secret" || api_key.to_s.strip.empty?

      return unless api_key_domain == "your-domain.com" || api_key_domain.to_s.strip.empty?

      raise Error, "Invalid API Domain, check ENV"
    end
  end
end
