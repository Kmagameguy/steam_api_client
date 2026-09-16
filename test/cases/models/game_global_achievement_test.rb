# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class GameGlobalAchievementTest < SteamApiClientTest
      let(:raw_attributes) do
        {
          "name" => "SOME_ACHIEVEMENT_NAME",
          "appid" => "440",
          "percent" => "62.3"
        }
      end

      let(:game_global_achievement) { SteamApiClient::Models::GameGlobalAchievement.new(raw_attributes) }

      describe "#initialize" do
        it "exposes the achievement name" do
          assert_equal "SOME_ACHIEVEMENT_NAME", game_global_achievement.name
        end

        it "casts the app_id to an integer" do
          assert_equal 440, game_global_achievement.app_id
        end

        it "casts the percent to a float" do
          assert_in_delta 62.3, game_global_achievement.percent_unlocked
        end
      end

      describe "#game" do
        it "can fetch the game data associated with the achievement" do
          Resources::IStoreService.any_instance
                                  .expects(:app_list)
                                  .with(
                                    app_id_offset: 439,
                                    include_games: true,
                                    include_dlc: true,
                                    include_software: true,
                                    include_videos: true,
                                    include_hardware: true,
                                    max_results: 1
                                  ).returns([Models::Game.new])

          game_global_achievement.game
        end
      end
    end
  end
end
