# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamNews
      class Error < StandardError; end
      class NoAppIdError < Error; end

      SERVICE_NAME     = "ISteamNews"
      API_VERSION      = "v0002"
      GET_NEWS_FOR_APP = "GetNewsForApp"

      attr_accessor :app_id

      def initialize(app_id:, connection: ::SteamApiClient::Connection.new)
        @app_id     = app_id
        @connection = connection

        raise NoAppIdError if @app_id.nil?
      end

      def news_for_app(count: nil, content_max_length: nil)
        params = {
          appid: app_id,
          count: count,
          maxlength: content_max_length
        }.select { |_, v| v }

        response = connection.get(build_url(GET_NEWS_FOR_APP), params)
        process_response(response)
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}/"
      end

      def process_response(response)
        return response.body.dig("appnews") if response.success?

        raise Error, status: response.status, error_message: response.body
      end
    end
  end
end
