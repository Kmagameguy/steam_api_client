# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGameStat
      attr_reader :steam_id, :app_id, :name, :value

      def initialize(raw_attributes = {})
        @steam_id = raw_attributes["steam_id"].to_i
        @app_id   = raw_attributes["app_id"].to_i
        @name     = raw_attributes["_key_name"]
        @value    = raw_attributes["value"]
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

      def store_service
        @store_service ||= Resources::IStoreService.new
      end
    end
  end
end
