# frozen_string_literal: true

module SteamApiClient
  module Models
    class GameGlobalAchievement
      attr_reader :app_id, :name, :percent_unlocked

      def initialize(raw_attributes = {})
        @app_id           = raw_attributes["appid"].to_i
        @name             = raw_attributes["name"]
        @percent_unlocked = raw_attributes["percent"].to_f
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

      def store_service
        @store_service ||= Resources::IStoreService.new
      end
    end
  end
end
