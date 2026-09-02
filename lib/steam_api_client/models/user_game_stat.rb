# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGameStat
      attr_reader :steam_id, :name, :value

      def initialize(raw_attributes = {})
        @steam_id = raw_attributes["steam_id"].to_i
        @name     = raw_attributes["_key_name"]
        @value    = raw_attributes["value"]
      end
    end
  end
end
