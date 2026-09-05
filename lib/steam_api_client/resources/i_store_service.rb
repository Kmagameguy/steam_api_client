# frozen_string_literal: true

module SteamApiClient
  module Resources
    class IStoreService
      class Error < StandardError; end
      class NoSteamIdError < Error; end
      class TooManyResultsRequestedError < Error; end

      SERVICE_NAME = "IStoreService"
      API_VERSION  = "v0001"

      GET_GAMES_FOLLOWED            = "GetGamesFollowed"
      GET_GAMES_FOLLOWED_COUNT      = "GetGamesFollowedCount"
      GET_APP_LIST                  = "GetAppList"

      DEFAULT_APP_LIST_RESULT_COUNT = 10_000
      MAX_APP_LIST_RESULT_COUNT     = 50_000

      def initialize(connection: ::SteamApiClient::Connection.instance)
        @connection = connection
      end

      def app_list(options = {})
        if options[:max_results].to_i > MAX_APP_LIST_RESULT_COUNT
          raise TooManyResultsRequestedError, "Cannot request more than #{MAX_APP_LIST_RESULT_COUNT} app entries."
        end

        if_modified_since = options[:modified_after].is_a?(Time) ? options[:modified_after].to_i : nil
        include_games     = options.fetch(:include_games, true)
        include_dlc       = options.fetch(:include_dlc, false)
        include_software  = options.fetch(:include_software, false)
        include_videos    = options.fetch(:include_videos, false)
        include_hardware  = options.fetch(:include_hardware, false)
        max_results       = options.fetch(:max_results, DEFAULT_APP_LIST_RESULT_COUNT)
        app_id_offset     = options[:app_id_offset]

        params = {
          if_modified_since: if_modified_since,
          include_games:     include_games,
          include_dlc:       include_dlc,
          include_software:  include_software,
          include_videos:    include_videos,
          include_hardware:  include_hardware,
          max_results:       max_results,
          last_appid:        app_id_offset
        }.compact

        response = connection.get(build_url(GET_APP_LIST), params)
        process_response(response)
      end

      def games_followed_by(steam_id:)
        raise NoSteamIdError if steam_id.nil?

        response = connection.get(build_url(GET_GAMES_FOLLOWED), { steamid: steam_id })
        processed_response = process_response(response)&.dig("appids") || []

        processed_response.map do |item|
          Models::UserFollowedGame.new({ "steam_id" => steam_id, "appid" => item })
        end
      end

      def games_followed_by_count(steam_id:)
        raise NoSteamIdError if steam_id.nil?

        response = connection.get(build_url(GET_GAMES_FOLLOWED_COUNT), { steamid: steam_id })
        process_response(response)
      end

      # TODO: Figure out why GetRecommendedTagsForUser always returns Unauthorized

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}"
      end

      def process_response(response)
        return response.body&.dig("response") if response.success?

        raise Error, "#{response.status}: #{response.body}"
      end
    end
  end
end
