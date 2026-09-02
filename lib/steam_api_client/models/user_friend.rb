# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserFriend
      include Concerns::TimeCastable

      attr_reader :steam_user, :relationship, :friend_since

      def initialize(raw_attributes = {})
        @steam_user = SteamUser.new(steam_id: raw_attributes["steamid"].to_i)
        @relationship = raw_attributes["relationship"]
        @friend_since = cast_to_time(raw_attributes["friend_since"].to_i)
      end
    end
  end
end
