# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserProfileTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steamid" => "76561197960435530",
          "communityvisibilitystate" => 3,
          "profilestate" => 1,
          "personaname" => "Robin",
          "commentpermission" => 1,
          "profileurl" => "https://steamcommunity.com/id/robinwalker/",
          "avatarfull" => "https://avatars.example.com/robin_full.jpg",
          "lastlogoff" => "1700000000",
          "personastate" => 1,
          "primaryclanid" => "103582791429521412",
          "timecreated" => "1000000000",
          "personastateflags" => 0,
          "loccountrycode" => "US"
        }
      end

      let(:user_profile) { SteamApiClient::Models::UserProfile.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam id to an integer" do
          assert_equal 76_561_197_960_435_530, user_profile.steam_id
        end

        it "maps communityvisibilitystate to a readable label" do
          assert_equal "public", user_profile.community_visibility
        end

        it "exposes the display name" do
          assert_equal "Robin", user_profile.display_name
        end

        it "exposes the profile's permalink" do
          assert_equal "https://steamcommunity.com/id/robinwalker/", user_profile.url
        end

        it "exposes the full-size avatar permalink" do
          assert_equal "https://avatars.example.com/robin_full.jpg", user_profile.avatar
        end

        it "casts lastlogoff into a real Time object" do
          assert_kind_of Time, user_profile.last_seen
        end

        it "maps personastate to a readable chat status" do
          assert_equal "online", user_profile.chat_status
        end

        it "casts the primary clan id to an integer" do
          assert_equal 103_582_791_429_521_412, user_profile.primary_clan_id
        end

        it "casts timecreated into a real Time object" do
          assert_kind_of Time, user_profile.created_at
        end

        describe "#metadata" do
          it "returns an empty list when no persona state flags are set" do
            assert_empty user_profile.metadata
          end

          it "lists every flag whose bit is set on personastateflags" do
            # has_rich_presence (1) + remote_play_together (8)
            flags_value = 1 | 8
            raw_attributes["personastateflags"] = flags_value

            assert_equal %w[has_rich_presence remote_play_together], user_profile.metadata
          end
        end

        describe "#country" do
          it "exposes the country code" do
            assert_equal "US", user_profile.country
          end

          it "falls back to 'Unknown' when Valve omits the country code" do
            raw_attributes.delete("loccountrycode")

            assert_equal "Unknown", user_profile.country
          end
        end
      end

      describe "#profile_configured?" do
        it "is true once the account has set up a profile" do
          assert_predicate user_profile, :profile_configured?
        end

        it "is false for a fresh account" do
          raw_attributes["profilestate"] = 0

          refute_predicate user_profile, :profile_configured?
        end
      end

      describe "#comments_allowed?" do
        it "is true when comments are permitted" do
          assert_predicate user_profile, :comments_allowed?
        end

        it "is false when comments are restricted" do
          raw_attributes["commentpermission"] = 0

          refute_predicate user_profile, :comments_allowed?
        end
      end
    end
  end
end
