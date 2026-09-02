# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserGameStatTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steam_id"  => "76561197960435530",
          "_key_name" => "SOME_GAME_STAT",
          "value"     => { "success" => "1" }
        }
      end

      let(:user_game_stat) { SteamApiClient::Models::UserGameStat.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam_id to an integer" do
          assert_equal 76_561_197_960_435_530, user_game_stat.steam_id
        end

        it "exposes _key_name as a name field" do
          assert_equal "SOME_GAME_STAT", user_game_stat.name
        end

        it "exposts the value as a field" do
          assert_equal({ "success" => "1" }, user_game_stat.value)
        end
      end
    end
  end
end
