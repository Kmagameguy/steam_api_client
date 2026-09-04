# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class ISteamNewsTest < Minitest::Spec
      let(:app_id) { 440 }
      let(:subject) { SteamApiClient::Resources::ISteamNews }

      describe "#initialize" do
        it "exposes an app_id field" do
          assert_equal 440, subject.new(app_id: app_id).app_id
        end

        it "raises an error if app_id is nil" do
          assert_raises(subject::NoAppIdError) { subject.new(app_id: nil) }
        end
      end

      describe "#news_for_app" do
        it "fetches news for the given appid and creates GameNews Objects" do
          VCR.use_cassette("i_steam_news/news_for_app") do
            news = subject.new(app_id: app_id).news_for_app

            assert_equal 20, news.size
            assert_instance_of Models::GameNews, news.first

            assert_operator news.first.post_date, :>, news.last.post_date
          end
        end

        it "ensures news is sorted by posting date in descending order" do
          VCR.use_cassette("i_steam_news/news_for_app") do
            news = subject.new(app_id: app_id).news_for_app

            assert_operator news.size, :>, 1
            assert_operator news.first.post_date, :>, news.last.post_date
          end
        end

        it "respects 'count' and 'content_max_length' arguments" do
          VCR.use_cassette("i_steam_news/news_for_app_count-two_content_max_length-100") do
            news = subject.new(app_id: app_id).news_for_app(count: 2, content_max_length: 100)

            assert_equal 2, news.size
            assert_equal 100, news.first.content.gsub("...", "").length
            assert_equal 100, news.first.content.gsub("...", "").length
          end
        end

        it "returns an empty array if results can't be found" do
          response = mock("response")
          response.expects(:success?).returns(true)
          response.expects(:body).returns({})
          Connection.any_instance.stubs(:get).returns(response)

          news = subject.new(app_id: app_id).news_for_app

          assert_empty news
        end

        it "raises a resource-specific error when encountering an error" do
          VCR.use_cassette("i_steam_news/news_for_app_invalid_id") do
            error = assert_raises(subject::Error) do
              SteamApiClient::Resources::ISteamNews.new(app_id: -1_000).news_for_app
            end

            assert_equal "403: {}", error.message
          end
        end
      end
    end
  end
end
