# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserFollowedGameTest < Minitest::Spec
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

        it "casts the ppid to an integer id" do
          assert_equal 440, user_followed_game.id
        end
      end
    end
  end
end
