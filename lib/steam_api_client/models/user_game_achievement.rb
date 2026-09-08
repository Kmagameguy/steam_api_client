# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGameAchievement
      include Concerns::TimeCastable

      attr_reader :steam_id, :app_id, :name, :unlock_time

      def initialize(raw_attributes = {})
        @steam_id    = raw_attributes["steamid"].to_i
        @app_id      = raw_attributes["appid"].to_i
        @name        = raw_attributes["apiname"]
        @achieved    = raw_attributes["achieved"].to_i.positive?
        @unlock_time = cast_to_time(raw_attributes["unlocktime"].to_i)
      end

      def unlocked?
        achieved
      end

      def steam_user
        @steam_user ||= SteamUser.new(steam_id: steam_id)
      end

      def game
        @game ||= store_service.app_list(
          app_id_offset: app_id - 1,
          include_games: true,
          include_dlc: true,
          include_software: true,
          include_videos: true,
          include_hardware: true,
          max_results: 1
        ).first
      end

      private

      attr_reader :achieved

      def store_service
        @store_service ||= Resources::IStoreService.new
      end
    end
  end
end
