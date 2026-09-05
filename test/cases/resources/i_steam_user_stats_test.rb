# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class ISteamUserStatsTest < Minitest::Spec
      let(:steam_id) { TestFixtures::TEST_STEAM_ID1 }
      let(:app_id)   { 440 }
      let(:subject)  { SteamApiClient::Resources::ISteamUserStats }

      describe "#initialize" do
        it "exposes steam_id as a field" do
          assert_equal steam_id, subject.new(app_id: app_id, steam_id: steam_id).steam_id
        end

        it "exposes app_id as a field" do
          assert_equal app_id, subject.new(app_id: app_id, steam_id: steam_id).app_id
        end

        it "can be constructed with only an app_id" do
          subject.new(app_id: app_id)
        end

        it "raises if app_id is nil" do
          assert_raises(subject::Error) { subject.new(app_id: nil) }
        end
      end

      describe "#global_achievement_percentages_for_app" do
        it "fetches all achievements for the provided app_id and creates GameGlobalAchievement Objects" do
          VCR.use_cassette("i_steam_user_stats/global_achievements_for_app") do
            achievements = subject.new(app_id: app_id).global_achievement_percentages_for_app

            assert_operator achievements.size, :>, 0
            assert_instance_of Models::GameGlobalAchievement, achievements.first
          end
        end
      end

      describe "#player_achievements_for_game" do
        it "fetches all achievements for the provided app_id and creates UserGameAchievement Objects" do
          VCR.use_cassette("i_steam_user_stats/player_achievements_for_game") do
            player_achievements = subject.new(app_id: app_id, steam_id: steam_id).player_achievements_for_game

            assert_operator player_achievements.size, :>, 0
            assert_instance_of Models::UserGameAchievement, player_achievements.first
          end
        end
      end

      describe "#player_stats_for_game" do
        it "fetches all stats for the provided app_id and creates UserGameStat objects" do
          VCR.use_cassette("i_steam_user_stats/player_stats_for_game") do
            player_stats = subject.new(app_id: app_id, steam_id: steam_id).player_stats_for_game

            assert_operator player_stats.size, :>, 0
            assert_instance_of Models::UserGameStat, player_stats.first
          end
        end
      end
    end
  end
end
