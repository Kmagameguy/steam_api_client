# frozen_string_literal: true

# TODO: Probably should make this a singleton...
module SteamApiClient
  class Connection
    STEAM_API_ROOT_URL = "https://api.steampowered.com"

    attr_reader :config

    def initialize(config: Config.new)
      @config = config
    end

    def get(path, params = {})
      connection.get(path, params.merge(key: config.api_key))
    end

    def post(path, params = {})
      connection.post(path) do |request|
        request[:key] = config.api_key
        request.body  = params
      end
    end

    private

    def connection
      @connection ||= Faraday.new(url: STEAM_API_ROOT_URL) do |faraday|
        faraday.headers["User-Agent"] = config.user_agent_string
        faraday.request  :json
        faraday.response :json
      end
    end
  end
end
