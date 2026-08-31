# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserFollowedGame
      attr_reader :steam_id, :id

      def initialize(raw_attributes = {})
        @steam_id = raw_attributes["steam_id"].to_i
        @id   = raw_attributes["appid"].to_i
      end
    end
  end
end
