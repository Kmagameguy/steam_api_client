# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGroup
      attr_reader :steam_id, :id

      def initialize(raw_attributes = {})
        @steam_id = raw_attributes["steam_id"].to_i
        @id       = raw_attributes["group_id"].to_i
      end

      def steam_user
        @steam_user ||= SteamUser.new(steam_id: steam_id)
      end
    end
  end
end
