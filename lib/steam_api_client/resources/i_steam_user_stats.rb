# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamUserStats
      class Error < StandardError; end
      class NoSteamIdError < Error; end
      class NoAppIdError   < Error; end

      SERVICE_NAME = "ISteamUserStats"
      GET_GLOBAL_ACHIEVEMENT_PERCENTAGES_FOR_APP = "GetGlobalAchievementPercentagesForApp"
      GET_PLAYER_ACHIEVEMENTS = "GetPlayerAchievements"
      GET_USER_STATS_FOR_GAME = "GetUserStatsForGame"

      API_VERSION_1 = "v0001"
      API_VERSION_2 = "v0002"
      API_VERSION_MAP = {
        GET_GLOBAL_ACHIEVEMENT_PERCENTAGES_FOR_APP => API_VERSION_2,
        GET_PLAYER_ACHIEVEMENTS => API_VERSION_1,
        GET_USER_STATS_FOR_GAME => API_VERSION_1
      }.freeze

      attr_accessor :steam_id, :app_id

      def initialize(app_id:, steam_id: nil, connection: ::SteamApiClient::Connection.new)
        @app_id     = app_id
        @steam_id   = steam_id
        @connection = connection

        raise NoAppIdError if @app_id.nil?
      end

      def global_achievement_percentages_for_app
        response = connection.get(build_url(GET_GLOBAL_ACHIEVEMENT_PERCENTAGES_FOR_APP), { gameid: app_id })
        process_response(response, key: :achievementpercentages)
      end

      def player_achievements_for_game
        raise NoSteamIdError if steam_id.nil?

        response = connection.get(build_url(GET_PLAYER_ACHIEVEMENTS), { steamid: steam_id, appid: app_id })
        processed_response = process_response(response, key: :playerstats)&.dig("achievements")

        processed_response.map do |item|
          Models::UserGameAchievement.new(item)
        end
      end

      def player_stats_for_game
        raise NoSteamIdError if steam_id.nil?

        response = connection.get(build_url(GET_USER_STATS_FOR_GAME), { steamid: steam_id, appid: app_id })
        processed_response = process_response(response, key: :playerstats)&.dig("stats") || []

        processed_response.keys.map do |key|
          Models::UserGameStat.new(processed_response[key].merge("_key_name" => key))
        end
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION_MAP[resource]}"
      end

      def process_response(response, key:)
        return response.body&.dig(key.to_s) if response.success?

        raise Error, status: response.status, error_message: response.body
      end
    end
  end
end
