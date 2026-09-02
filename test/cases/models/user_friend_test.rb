# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserFriendTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steamid" => "76561197960435530",
          "relationship" => "friend",
          "friend_since" => "1700000000"
        }
      end

      let(:user_friend) { SteamApiClient::Models::UserFriend.new(raw_attributes) }

      describe "#initialize" do
        it "creates a steam_user object from the steamid" do
          assert_kind_of SteamApiClient::SteamUser, user_friend.steam_user
          assert_equal 76_561_197_960_435_530, user_friend.steam_user.steam_id
        end

        it "exposes the relationship attribute" do
          assert_equal "friend", user_friend.relationship
        end

        it "casts the friend_since value to a real Time object" do
          assert_kind_of Time, user_friend.friend_since
        end
      end
    end
  end
end
