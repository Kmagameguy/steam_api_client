# frozen_string_literal: true

module SteamApiClient
  module Models
    class GameGlobalAchievement
      attr_reader :name, :percent_unlocked

      def initialize(raw_attributes = {})
        @name = raw_attributes["name"]
        @percent_unlocked = raw_attributes["percent"].to_f
      end
    end
  end
end
