# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserFollowedGame
      attr_reader :steam_id, :id

      def initialize(raw_attributes = {})
        @steam_id = raw_attributes["steam_id"].to_i
        @id       = raw_attributes["appid"].to_i
      end

      def steam_user
        @steam_user ||= SteamUser.new(steam_id: steam_id)
      end

      def game
        @game ||= store_service.app_list(
          app_id_offset: id - 1,
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
