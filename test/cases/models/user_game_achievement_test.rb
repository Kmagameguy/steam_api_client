# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserGameAchievementTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "apiname" => "SOME_ACHIEVEMENT_NAME",
          "achieved" => "1",
          "unlocktime" => "1000000000"
        }
      end

      let(:user_game_achievement) { SteamApiClient::Models::UserGameAchievement.new(raw_attributes) }

      describe "#initialize" do
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
    end
  end
end
