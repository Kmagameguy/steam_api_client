# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class GameNewsTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "appid" => "440",
          "gid" => "498398475982374",
          "title" => "A Big Update",
          "author" => "Valve",
          "contents" => "Patch notes go here.",
          "feedname" => "steam_updates",
          "feed_type" => 1,
          "tag" => "patchnotes",
          "url" => "https://store.steampowered.com/news/app/440",
          "is_external_url" => false,
          "date" => 1_700_000_000
        }
      end

      let(:game_news) { SteamApiClient::Models::GameNews.new(raw_attributes) }

      describe "#initialize" do
        it "casts the appid to an integer" do
          assert_equal 440, game_news.app_id
        end

        it "casts the gid to an integer id" do
          assert_equal 498_398_475_982_374, game_news.id
        end

        it "exposes the title field as a heading" do
          assert_equal "A Big Update", game_news.heading
        end

        it "exposes the author field" do
          assert_equal "Valve", game_news.author
        end

        it "exposes the contents as a content field" do
          assert_equal "Patch notes go here.", game_news.content
        end

        it "exposes the feedname as a feed field" do
          assert_equal "steam_updates", game_news.feed
        end

        describe "feed source" do
          it "maps feed_type 1 to steam_community" do
            assert_equal "steam_community", game_news.feed_source
          end

          it "maps feed_type 0 to external_feed" do
            raw_attributes["feed_type"] = 0

            assert_equal "external_feed", game_news.feed_source
          end
        end

        it "exposes the tag as a field" do
          assert_equal "patchnotes", game_news.tag
        end

        it "exposes the url as a field" do
          assert_equal "https://store.steampowered.com/news/app/440", game_news.url
        end

        it "casts the post date into a real Time" do
          assert_kind_of Time, game_news.post_date
        end
      end

      describe "#post_from_external_site?" do
        it "is false when feed_type is 1" do
          refute_predicate game_news, :post_from_external_site?
          assert_predicate game_news, :post_from_steam_community?
        end

        it "is true when feed_type is 0" do
          raw_attributes["feed_type"] = 0

          assert_predicate game_news, :post_from_external_site?
          refute_predicate game_news, :post_from_steam_community?
        end
      end

      describe "#post_from_steam_community?" do
        it "is true when feed_type is 1" do
          assert_predicate game_news, :post_from_steam_community?
          refute_predicate game_news, :post_from_external_site?
        end

        it "is false when feed_type is 0" do
          raw_attributes["feed_type"] = 0

          refute_predicate game_news, :post_from_steam_community?
          assert_predicate game_news, :post_from_external_site?
        end
      end

      describe "#links_to_external_site?" do
        it "is true when the url links to an external page/site" do
          raw_attributes["is_external_url"] = true

          assert_predicate game_news, :links_to_external_site?
        end

        it "is false when the url links to an internal Steam page" do
          refute_predicate game_news, :links_to_external_site?
        end
      end
    end
  end
end
