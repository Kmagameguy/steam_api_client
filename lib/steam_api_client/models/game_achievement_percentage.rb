# frozen_string_literal: true

module SteamApiClient
  module Models
    class GameAchievementPercentage
      def initialize(raw_attributes = {})
        @name = raw_attributes["name"]
        @value = raw_attributes["percent"].to_f
      end
    end
  end
end
