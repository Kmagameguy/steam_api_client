# frozen_string_literal: true

module SteamApiClient
  class Config
    attr_accessor :api_key, :api_key_domain

    def initialize
      @api_key = ENV.fetch("STEAM_API_KEY")
      @api_key_domain = ENV.fetch("STEAM_API_KEY_DOMAIN")
    end

    def user_agent_string
      "steam-api-client-ruby/#{SteamApiClient::VERSION} (+ #{api_key_domain})"
    end
  end
end
