# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserBanTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "SteamId"          => "76561197960435530",
          "CommunityBanned"  => false,
          "VACBanned"        => false,
          "NumberOfVACBans"  => "0",
          "DaysSinceLastBan" => "0",
          "NumberOfGameBans" => "0",
          "EconomyBan"       => "none"
        }
      end

      let(:user_ban) { SteamApiClient::Models::UserBan.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam id to an integer" do
          assert_equal 76_561_197_960_435_530, user_ban.steam_id
        end

        it "exposes ban counters" do
          raw_attributes.merge!("NumberOfVACBans" => "2", "NumberOfGameBans" => "1", "DaysSinceLastBan" => "15")

          assert_equal 2, user_ban.vac_ban_count
          assert_equal 1, user_ban.game_ban_count
          assert_equal 15, user_ban.days_since_last_ban
        end

        it "defaults economy_ban to 'none' when Valve omits the field" do
          raw_attributes.reject! { |key, _| key == "EconomyBan" }

          assert_equal "none", user_ban.economy_ban
        end
      end

      describe "#actively_banned?" do
        it "is false when the account has no bans" do
          refute_predicate user_ban, :actively_banned?
        end

        it "is true when the account is community banned" do
          raw_attributes["CommunityBanned"] = true

          assert_predicate user_ban, :actively_banned?
        end

        it "is true when the account is VAC banned" do
          raw_attributes["VACBanned"] = true

          assert_predicate user_ban, :actively_banned?
        end
      end

      describe "#banned_from_community?" do
        it "is true if CommunityBanned is true" do
          raw_attributes["CommunityBanned"] = true

          assert_predicate user_ban, :banned_from_community?
        end

        it "is false if CommunityBanned is false" do
          raw_attributes["CommunityBanned"] = false

          refute_predicate user_ban, :banned_from_community?
        end
      end

      describe "#vac_banned?" do
        it "is true if VACBanned is true" do
          raw_attributes["VACBanned"] = true

          assert_predicate user_ban, :vac_banned?
        end

        it "is false if VACBanned is false" do
          raw_attributes["VACBanned"] = false

          refute_predicate user_ban, :vac_banned?
        end
      end
    end
  end
end
