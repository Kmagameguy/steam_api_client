# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamUserStats
      class NoSteamIdError < StandardError; end
      class NoAppIdError   < StandardError; end

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

      def initialize(steam_id:, app_id:, connection: ::SteamApiClient::Connection.new)
        @steam_id   = steam_id
        @app_id     = app_id
        @connection = connection

        # TODO: Only check these in the relevant methods instead of on init
        raise NoSteamIdError if @steam_id.nil?
        raise NoAppIdError if @app_id.nil?
      end

      def global_achievement_percentages_for_app
        connection.get(build_url(GET_GLOBAL_ACHIEVEMENT_PERCENTAGES_FOR_APP), { gameid: app_id })
      end

      def player_achievements
        connection.get(build_url(GET_PLAYER_ACHIEVEMENTS), { steamid: steam_id, appid: app_id })
      end

      def player_stats_for_game
        connection.get(build_url(GET_USER_STATS_FOR_GAME), { steamid: steam_id, appid: app_id })
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION_MAP[resource]}"
      end
    end
  end
end
