# frozen_string_literal: true

module SteamApiClient
  module Models
    class UserProfile
      include Concerns::TimeCastable

      COMMUNITY_VISIBILITY_ENUM = {
        1 => "private",
        2 => "friends_only",
        3 => "public"
      }.freeze

      CHAT_STATUS_ENUM = {
        0 => "offline",
        1 => "online",
        2 => "busy",
        3 => "away",
        4 => "snooze",
        5 => "looking_to_trade",
        6 => "looking_to_play",
        7 => "invisible",
        8 => "max" # (?)
      }.freeze

      # These are bitwise flags, several can coexist.
      PERSONA_STATE_FLAGS = {
        "has_rich_presence"       => 1,
        "in_joinable_game"        => 2,
        "golden"                  => 4, # (?)
        "remote_play_together"    => 8,
        "client_type_web"         => 256,
        "client_type_mobile"      => 512,
        "client_type_tenfoot"     => 1024,
        "client_type_vr"          => 2048,
        "launch_type_gamepad"     => 4096,
        "launch_type_compat_tool" => 8192
      }.freeze

      attr_reader :steam_id,
                  :community_visibility,
                  :display_name,
                  :url,
                  :avatar,
                  :last_seen,
                  :chat_status,
                  :primary_clan_id,
                  :created_at,
                  :metadata,
                  :country

      def initialize(raw_attributes = {})
        @steam_id                 = raw_attributes["steamid"].to_i
        @community_visibility     = COMMUNITY_VISIBILITY_ENUM[raw_attributes["communityvisibilitystate"].to_i]
        @profile_configured       = raw_attributes["profilestate"].to_i
        @display_name             = raw_attributes["personaname"]
        @comments_allowed         = raw_attributes["commentpermission"].to_i
        @url                      = raw_attributes["profileurl"]
        @avatar                   = raw_attributes["avatarfull"]
        @last_seen                = cast_to_time(raw_attributes["lastlogoff"])
        @chat_status              = CHAT_STATUS_ENUM[raw_attributes["personastate"].to_i]
        @primary_clan_id          = raw_attributes["primaryclanid"]
        @created_at               = cast_to_time(raw_attributes["timecreated"])
        @metadata                 = metadata_flags(raw_attributes["personastateflags"].to_i)
        @country                  = raw_attributes["loccountrycode"] || "Unknown"
      end

      def profile_configured?
        profile_configured > 0
      end

      def comments_allowed?
        comments_allowed > 0
      end

      private

      def metadata_flags(value)
        PERSONA_STATE_FLAGS.select { |_name, bit| (value & bit) != 0 }.keys
      end

      attr_reader :profile_configured, :comments_allowed
    end
  end
end
