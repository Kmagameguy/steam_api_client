# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamWebApiUtil
      class Error < StandardError; end

      SERVICE_NAME = "ISteamWebAPIUtil"
      API_VERSION  = "v0001"
      GET_SUPPORTED_API_LIST = "GetSupportedAPIList"

      def self.supported_api_list(connection: ::SteamApiClient::Connection.instance)
        new(connection: connection).supported_api_list
      end

      def initialize(connection: ::SteamApiClient::Connection.instance)
        @connection = connection
      end

      def supported_api_list
        response = connection.get(build_url(GET_SUPPORTED_API_LIST))
        process_response(response)
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}"
      end

      def process_response(response)
        return response.body&.dig("apilist") if response.success?

        raise Error, "#{response.status}: #{response.body}"
      end
    end
  end
end
