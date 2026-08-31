# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserBan
      attr_reader :steam_id, :vac_ban_count, :days_since_last_ban, :game_ban_count, :economy_ban

      def initialize(raw_attributes = {})
        @steam_id            = raw_attributes["SteamId"].to_i
        @community_banned    = !!raw_attributes["CommunityBanned"]
        @vac_banned          = !!raw_attributes["VACBanned"]
        @vac_ban_count       = raw_attributes["NumberOfVACBans"].to_i
        @days_since_last_ban = raw_attributes["DaysSinceLastBan"].to_i
        @game_ban_count      = raw_attributes["NumberOfGameBans"].to_i
        @economy_ban         = raw_attributes["EconomyBan"] || "none"
      end

      def actively_banned?
        banned_from_community? || vac_banned?
      end

      def banned_from_community?
        community_banned
      end

      def vac_banned?
        vac_banned
      end

      private

      attr_reader :community_banned, :vac_banned
    end
  end
end
