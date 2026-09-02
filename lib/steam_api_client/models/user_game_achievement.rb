# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGameAchievement
      include Concerns::TimeCastable

      attr_reader :name, :unlock_time

      def initialize(raw_attributes = {})
        @name        = raw_attributes["apiname"]
        @achieved    = raw_attributes["achieved"].to_i.positive?
        @unlock_time = cast_to_time(raw_attributes["unlocktime"].to_i)
      end

      def unlocked?
        achieved
      end

      private

      attr_reader :achieved
    end
  end
end
