# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class IStoreServiceTest < Minitest::Spec
      let(:steam_id) { TestFixtures::TEST_STEAM_ID1 }
      let(:subject)  { SteamApiClient::Resources::IStoreService }

      describe "#app_list" do
        it "fetches app info with a default query" do
          VCR.use_cassette("i_store_service/app_list_with_defaults") do
            response               = subject.new.app_list
            app_list               = response["apps"]
            more_results_flag      = response["have_more_results"]
            last_app_id_for_offset = response["last_appid"]

            assert_equal subject::DEFAULT_APP_LIST_RESULT_COUNT, app_list.size
            assert more_results_flag
            refute_nil last_app_id_for_offset
          end
        end

        it "fetches app info with filters" do
          VCR.use_cassette("i_store_service/app_list_with_filters") do
            options = {
              max_results: 5,
              include_games: false,
              include_software: true,
              include_dlc: false,
              include_videos: false,
              include_hardware: true,
              app_id_offset: 220_700
            }
            response = subject.new.app_list(options)
            app_list = response["apps"]

            assert_equal 5, app_list.size
            assert(app_list.all? { |app| app["appid"] > options[:app_id_offset] })
          end
        end

        it "limits the query to a maximum number of results" do
          expected_error_message = "Cannot request more than #{subject::MAX_APP_LIST_RESULT_COUNT} app entries."

          assert_raises(subject::TooManyResultsRequestedError, expected_error_message) do
            subject.new.app_list(max_results: subject::MAX_APP_LIST_RESULT_COUNT + 1)
          end
        end
      end

      describe "#games_followed_by" do
        it "fetches games followed by a given steam_id and creates UserFollowedGame Objects" do
          VCR.use_cassette("i_store_service/games_followed_by") do
            user_followed_games = subject.new.games_followed_by(steam_id: steam_id)

            assert_kind_of Array, user_followed_games
            assert_kind_of Models::UserFollowedGame, user_followed_games.first
          end
        end

        it "raises NoSteamIdError if the provided steam_id is nil" do
          assert_raises(subject::NoSteamIdError) { subject.new.games_followed_by(steam_id: nil) }
        end
      end

      describe "#games_followed_by_count" do
        it "fetches a count of games followed by the given steam_id" do
          VCR.use_cassette("i_store_service/games_followed_by_count") do
            user_followed_game_count = subject.new.games_followed_by_count(steam_id: steam_id)

            assert_kind_of Integer, user_followed_game_count["followed_game_count"]
          end
        end

        it "raises NoSteamIdError if the provided steam_id is nil" do
          assert_raises(subject::NoSteamIdError) { subject.new.games_followed_by_count(steam_id: nil) }
        end
      end
    end
  end
end
