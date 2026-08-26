# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamNews
      class NoAppIdError < StandardError; end

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
          count: count,
          maxlength: content_max_length
        }.reject { |_, v| !v }

        params[:appid] = app_id

        connection.get(build_url(GET_NEWS_FOR_APP), params)
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}/"
      end
    end
  end
end
