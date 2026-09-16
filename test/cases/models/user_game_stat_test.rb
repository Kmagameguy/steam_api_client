# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserGameStatTest < SteamApiClientTest
      let(:raw_attributes) do
        {
          "steam_id"  => "76561197960435530",
          "app_id"    => "440",
          "_key_name" => "SOME_GAME_STAT",
          "value"     => { "success" => "1" }
        }
      end

      let(:user_game_stat) { SteamApiClient::Models::UserGameStat.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam_id to an integer" do
          assert_equal 76_561_197_960_435_530, user_game_stat.steam_id
        end

        it "casts the app_id to an integer" do
          assert_equal 440, user_game_stat.app_id
        end

        it "exposes _key_name as a name field" do
          assert_equal "SOME_GAME_STAT", user_game_stat.name
        end

        it "exposts the value as a field" do
          assert_equal({ "success" => "1" }, user_game_stat.value)
        end
      end

      describe "#steam_user" do
        it "gives access to a SteamUser via the provided steam_id" do
          assert_kind_of SteamUser, user_game_stat.steam_user
          assert_equal user_game_stat.steam_id, user_game_stat.steam_user.steam_id
        end
      end

      describe "#game" do
        it "can fetch the game data associated with the achievement" do
          Resources::IStoreService.any_instance
                                  .expects(:app_list)
                                  .with(
                                    app_id_offset: raw_attributes["app_id"].to_i - 1,
                                    include_games: true,
                                    include_dlc: true,
                                    include_software: true,
                                    include_videos: true,
                                    include_hardware: true,
                                    max_results: 1
                                  ).returns([Models::Game.new])

          user_game_stat.game
        end
      end
    end
  end
end
