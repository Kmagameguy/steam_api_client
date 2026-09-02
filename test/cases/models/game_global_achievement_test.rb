# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class GameGlobalAchievementTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "name" => "SOME_ACHIEVEMENT_NAME",
          "percent" => "62.3"
        }
      end

      let(:game_global_achievement) { SteamApiClient::Models::GameGlobalAchievement.new(raw_attributes) }

      describe "#initialize" do
        it "exposes the achievemnt name" do
          assert_equal "SOME_ACHIEVEMENT_NAME", game_global_achievement.name
        end

        it "casts the percent to a float" do
          assert_in_delta 62.3, game_global_achievement.percent_unlocked
        end
      end
    end
  end
end
