# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class GameTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "appid" => "440",
          "name" => "Team Fortress 2",
          "img_icon_url" => "abc123",
          "content_descriptorids" => [2, 5]
        }
      end

      let(:game) { SteamApiClient::Models::Game.new(raw_attributes) }

      describe "#initialize" do
        it "casts appid to an integer id" do
          assert_equal 440, game.id
        end

        it "exposes the game name" do
          assert_equal "Team Fortress 2", game.name
        end

        it "exposes the icon url" do
          assert_equal "abc123", game.img_icon_url
        end

        it "maps content descriptor ids to mature_content_warnings" do
          assert_equal %w[frequent_violence_or_gore general_mature_content], game.mature_content_warnings
        end

        it "defaults mature_content_warnings to an empty array" do
          attrs = raw_attributes.except("content_descriptorids")

          assert_equal [], SteamApiClient::Models::Game.new(attrs).mature_content_warnings
        end
      end

      describe "#news" do
        it "delegates to ISteamNews for the game's app_id and memoizes the result" do
          steam_news_service = mock("ISteamNews")
          steam_news_service.expects(:news_for_app).once.returns(:the_news)

          SteamApiClient::Resources::ISteamNews.stubs(:new).with(app_id: 440).returns(steam_news_service)

          assert_equal :the_news, game.news
          # Call it again to ensure game.news results are memoized
          assert_equal :the_news, game.news
        end
      end

      describe "#global_achievement_percentages" do
        it "delegates to ISteamUserStats for the game's app_id and memoizes the result" do
          steam_user_stats_service = mock("ISteamUserStats")
          steam_user_stats_service.expects(:global_achievement_percentages_for_app).once.returns("50%")

          SteamApiClient::Resources::ISteamUserStats.stubs(:new).with(app_id: 440).returns(steam_user_stats_service)

          assert_equal "50%", game.global_achievement_percentages
          # Call it again to ensure game.global_achievement_percentages_for_app results are memoized
          assert_equal "50%", game.global_achievement_percentages
        end
      end

      describe "#mature_content?" do
        it "is true if the game contains any mature_content_warnings flags" do
          assert_predicate game, :mature_content?
        end

        it "is false if the game does not contain any mature_content_warnings flags" do
          attrs = raw_attributes.except("content_descriptorids")

          refute_predicate SteamApiClient::Models::Game.new(attrs), :mature_content?
        end
      end

      describe "#to_h" do
        it "returns a hash of the public attributes" do
          expected = {
            id: 440,
            name: "Team Fortress 2",
            img_icon_url: "abc123",
            mature_content_warnings: %w[frequent_violence_or_gore general_mature_content]
          }

          assert_equal expected, game.to_h
        end
      end

      describe "#attributes" do
        it "is an alias for #to_h" do
          assert_equal game.to_h, game.attributes
        end
      end
    end
  end
end
