# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserGameStat

      attr_reader :name, :value

      def initialize(raw_attributes = {})
        @name = raw_attributes["_key_name"]
        @value = raw_attributes["value"]
      end
    end
  end
end
