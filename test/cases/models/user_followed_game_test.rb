# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserFollowedGameTest < SteamApiClientTest
      let(:raw_attributes) do
        {
          "steam_id" => "76561197960435530",
          "appid" => "440"
        }
      end

      let(:user_followed_game) { SteamApiClient::Models::UserFollowedGame.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam_id to an integer" do
          assert_equal 76_561_197_960_435_530, user_followed_game.steam_id
        end

        it "casts the appid to an integer id" do
          assert_equal 440, user_followed_game.id
        end
      end

      describe "#steam_user" do
        it "gives access to a SteamUser via the provided steam_id" do
          assert_kind_of SteamUser, user_followed_game.steam_user
          assert_equal user_followed_game.steam_id, user_followed_game.steam_user.steam_id
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

          user_followed_game.game
        end
      end
    end
  end
end
