# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserOwnedGameTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steam_id" => "76561197960435530",
          "appid" => "440",
          "name" => "Team Fortress 2",
          "img_icon_url" => "abc123",
          "content_descriptorids" => [2, 5],
          "playtime_2weeks" => "31",
          "playtime_forever" => "101",
          "playtime_windows_forever" => "8",
          "playtime_mac_forever" => "9",
          "playtime_linux_forever" => "70",
          "playtime_deck_forever" => "13",
          "playtime_disconnected" => "1",
          "rtime_last_played" => "1788311473"
        }
      end

      let(:user_owned_game) { SteamApiClient::Models::UserOwnedGame.new(raw_attributes) }

      before do
        Resources::ISteamUserStats.any_instance.stubs(:player_achievements_for_game).returns([])
      end

      describe "#initialize" do
        it "inherits from Game" do
          assert_kind_of Game, user_owned_game
        end
      end

      describe "#post_initialize_hook" do
        it "casts the steam_id to an integer" do
          assert_equal 76_561_197_960_435_530, user_owned_game.steam_id
        end

        it "casts playtime_2weeks to an integer playtime_last_two_weeks field" do
          assert_equal 31, user_owned_game.playtime_last_two_weeks
        end

        it "casts playtime_forever to an integer total_playtime field" do
          assert_equal 101, user_owned_game.total_playtime
        end

        it "casts playtime_windows_forever to an integer windows_playtime field" do
          assert_equal 8, user_owned_game.windows_playtime
        end

        it "casts playtime_mac_forever to an integer mac_playtime field" do
          assert_equal 9, user_owned_game.mac_playtime
        end

        it "casts playtime_linux_forever to an integer linux_playtime field" do
          assert_equal 70, user_owned_game.linux_playtime
        end

        it "casts playtime_deck_forever to an integer steam_deck_playtime field" do
          assert_equal 13, user_owned_game.steam_deck_playtime
        end

        it "casts rtime_last_played to a real last_played_at Time object" do
          assert_kind_of Time, user_owned_game.last_played_at
        end

        it "casts playtime_disconnected to an integer offline_playtime field" do
          assert_equal 1, user_owned_game.offline_playtime
        end
      end

      describe "#playtime_last_two_weeks_humanized" do
        it "converts playtime_last_two_weeks to human-readable text" do
          assert_equal "31 minutes", user_owned_game.playtime_last_two_weeks_humanized
        end
      end

      describe "#total_playtime_humanized" do
        it "converts total_playtime to human-readable text" do
          raw_attributes["playtime_forever"] = "1990312"

          assert_equal "1382 days, 3 hours, 52 minutes", user_owned_game.total_playtime_humanized
        end
      end

      describe "#windows_playtime_humanized" do
        it "converts windows_playtime to human-readable text" do
          assert_equal "8 minutes", user_owned_game.windows_playtime_humanized
        end
      end

      describe "#mac_playtime_humanized" do
        it "converts mac_playtime to human-readable text" do
          assert_equal "9 minutes", user_owned_game.mac_playtime_humanized
        end
      end

      describe "#linux_playtime_humanized" do
        it "converts linux_playtime to human-readable text" do
          assert_equal "1 hour, 10 minutes", user_owned_game.linux_playtime_humanized
        end
      end

      describe "#steam_deck_playtime_humanized" do
        it "converts steam_deck_playtime to human-readable text" do
          assert_equal "13 minutes", user_owned_game.steam_deck_playtime_humanized
        end
      end

      describe "#offline_playtime_humanized" do
        it "converts offline_playtime to human-readable text" do
          assert_equal "1 minute", user_owned_game.offline_playtime_humanized
        end
      end

      describe "#to_h" do
        it "returns a hash of the public attributes" do
          expected = {
            steam_id: 76_561_197_960_435_530,
            id: 440,
            name: "Team Fortress 2",
            img_icon_url: "abc123",
            mature_content_warnings: %w[frequent_violence_or_gore general_mature_content],
            playtime_last_two_weeks: 31,
            total_playtime: 101,
            windows_playtime: 8,
            mac_playtime: 9,
            linux_playtime: 70,
            last_played_at: Time.at(1_788_311_473),
            offline_playtime: 1, achievements: []
          }

          assert_equal expected, user_owned_game.to_h
        end
      end

      describe "#attributes" do
        it "is an alias for the modified #to_h" do
          assert_equal user_owned_game.to_h, user_owned_game.attributes
        end
      end
    end
  end
end
