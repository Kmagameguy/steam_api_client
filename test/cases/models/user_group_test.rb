# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserGroupTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steam_id" => "76561197960435530",
          "group_id" => "138000000000"
        }
      end

      let(:user_group) { SteamApiClient::Models::UserGroup.new(raw_attributes) }

      describe "#initialize" do
        it "casts the steam_id to an integer" do
          assert_equal 76_561_197_960_435_530, user_group.steam_id
        end

        it "casts the group_id to an integer id" do
          assert_equal 138_000_000_000, user_group.id
        end
      end
    end
  end
end
