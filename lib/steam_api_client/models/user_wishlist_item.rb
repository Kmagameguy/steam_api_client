# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserWishlistItem
      include Concerns::TimeCastable

      attr_reader :steam_id, :app_id, :priority, :date_added

      def initialize(raw_attributes = {})
        @steam_id   = raw_attributes["steam_id"].to_i
        @app_id     = raw_attributes["appid"].to_i
        @priority   = raw_attributes["priority"].to_i
        @date_added = cast_to_time(raw_attributes["date_added"].to_i)
      end
    end
  end
end
