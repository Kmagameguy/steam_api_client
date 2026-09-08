# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserGameAchievementTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steamid" => TestFixtures::TEST_STEAM_ID1,
          "appid" => "440",
          "apiname" => "SOME_ACHIEVEMENT_NAME",
          "achieved" => "1",
          "unlocktime" => "1000000000"
        }
      end

      let(:user_game_achievement) { SteamApiClient::Models::UserGameAchievement.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steamid to an integer" do
          assert_equal TestFixtures::TEST_STEAM_ID1.to_i, user_game_achievement.steam_id
        end

        it "casts the appid to an integer" do
          assert_equal 440, user_game_achievement.app_id
        end

        it "exposes the apiname as the achievement name" do
          assert_equal "SOME_ACHIEVEMENT_NAME", user_game_achievement.name
        end

        it "casts unlocktime to a real Time object" do
          assert_kind_of Time, user_game_achievement.unlock_time
        end
      end

      describe "#unlocked?" do
        it "is true when the achieved property is greater than 0" do
          assert_predicate user_game_achievement, :unlocked?
        end

        it "is false when the achieved property is less than 1" do
          raw_attributes["achieved"] = 0

          refute_predicate user_game_achievement, :unlocked?
        end
      end

      describe "#steam_user" do
        it "gives access to a SteamUser via the provided steam_id" do
          assert_kind_of SteamUser, user_game_achievement.steam_user
          assert_equal user_game_achievement.steam_id, user_game_achievement.steam_user.steam_id
        end
      end

      describe "#game" do
        it "can fetch the game data associated with the achievement" do
          Resources::IStoreService.any_instance
                                  .expects(:app_list)
                                  .with(
                                    app_id_offset: raw_attributes["appid"].to_i - 1,
                                    include_games: true,
                                    include_dlc: true,
                                    include_software: true,
                                    include_videos: true,
                                    include_hardware: true,
                                    max_results: 1
                                  ).returns([Models::Game.new])

          user_game_achievement.game
        end
      end
    end
  end
end
