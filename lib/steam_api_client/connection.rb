# frozen_string_literal: true

require "singleton"

module SteamApiClient
  class Connection
    include Singleton

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
      @connection ||= Faraday.new(url: config.api_root_url) do |faraday|
        faraday.headers["User-Agent"] = config.user_agent_string
        faraday.request  :json
        faraday.response :json
      end
    end
  end
end
