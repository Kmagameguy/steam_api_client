# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserOwnedGame < Game
      using Refinements::IntegerRefinements
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

      def playtime_last_two_weeks_humanized
        return "never" unless playtime_last_two_weeks.positive?

        playtime_last_two_weeks.minutes_as_human_readable_time
      end

      def total_playtime_humanized
        return "never" unless total_playtime.positive?

        total_playtime.minutes_as_human_readable_time
      end

      def windows_playtime_humanized
        return "never" unless windows_playtime.positive?

        windows_playtime.minutes_as_human_readable_time
      end

      def mac_playtime_humanized
        return "never" unless mac_playtime.positive?

        mac_playtime.minutes_as_human_readable_time
      end

      def linux_playtime_humanized
        return "never" unless linux_playtime.positive?

        linux_playtime.minutes_as_human_readable_time
      end

      def steam_deck_playtime_humanized
        return "never" unless steam_deck_playtime.positive?

        steam_deck_playtime.minutes_as_human_readable_time
      end

      def offline_playtime_humanized
        return "never" unless offline_playtime.positive?

        offline_playtime.minutes_as_human_readable_time
      end

      def to_h
        {}.merge(steam_id: steam_id).merge(super).merge(
          {
            playtime_last_two_weeks: playtime_last_two_weeks,
            total_playtime: total_playtime,
            windows_playtime: windows_playtime,
            mac_playtime: mac_playtime,
            linux_playtime: linux_playtime,
            last_played_at: last_played_at,
            offline_playtime: offline_playtime,
            achievements: achievements
          }
        )
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
        @playtime_last_two_weeks = @raw_attributes["playtime_2weeks"].to_i
        @total_playtime      = @raw_attributes["playtime_forever"].to_i
        @windows_playtime    = @raw_attributes["playtime_windows_forever"].to_i
        @mac_playtime        = @raw_attributes["playtime_mac_forever"].to_i
        @linux_playtime      = @raw_attributes["playtime_linux_forever"].to_i
        @steam_deck_playtime = @raw_attributes["playtime_deck_forever"].to_i
        @last_played_at      = cast_to_time(@raw_attributes["rtime_last_played"].to_i)
        @offline_playtime    = @raw_attributes["playtime_disconnected"].to_i
      end

      private

      def steam_user_stats_service
        @steam_user_stats_service ||= Resources::ISteamUserStats.new(app_id: id, steam_id: steam_id)
      end
    end
  end
end
