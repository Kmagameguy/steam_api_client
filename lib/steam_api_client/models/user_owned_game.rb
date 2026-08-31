# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserOwnedGame < Game
      include Concerns::TimeCastable

      attr_reader :steam_id,
                  :playtime_last_two_weeks,
                  :total_playtime,
                  :windows_playtime,
                  :mac_playtime,
                  :linux_playtime,
                  :steam_deck_playtime,
                  :last_played_at,
                  :offline_playtime

      def to_h
        {}.merge(steam_id: steam_id).merge(super).merge({
          playtime_last_two_weeks: playtime_last_two_weeks,
          total_playtime: total_playtime,
          windows_playtime: windows_playtime,
          mac_playtime: mac_playtime,
          linux_playtime: linux_playtime,
          last_played_at: last_played_at,
          offline_playtime: offline_playtime,
          achievements: achievements
        })
      end

      def achievements
        @achievements ||= steam_user_stats_service.player_achievements_for_game
      end

      def stats
        @stats ||= steam_user_stats_service.player_stats_for_game
      end

      protected

      def post_initialize_hook
        @steam_id            = @raw_attributes["steam_id"].to_i
        @playtime_last_two_weeks = @raw_attributes["playtime_2weeks"]      || 0
        @total_playtime      = @raw_attributes["playtime_forever"]         || 0
        @windows_playtime    = @raw_attributes["playtime_windows_forever"] || 0
        @mac_playtime        = @raw_attributes["playtime_mac_forever"]     || 0
        @linux_playtime      = @raw_attributes["playtime_linux_forever"]   || 0
        @steam_deck_playtime = @raw_attributes["playtime_deck_forever"]    || 0
        @last_played_at      = cast_to_time(@raw_attributes["rtime_last_played"])
        @offline_playtime    = @raw_attributes["playtime_disconnected"]    || 0
      end

      private

      def steam_user_stats_service
        @steam_user_stats_service ||= Resources::ISteamUserStats.new(app_id: id, steam_id: steam_id)
      end
    end
  end
end
