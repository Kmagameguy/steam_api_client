# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Models
    class UserWishlistItemTest < Minitest::Spec
      let(:raw_attributes) do
        {
          "steam_id" => "76561197960435530",
          "appid" => "440",
          "priority" => "1",
          "date_added" => "1788311473"
        }
      end

      let(:user_wishlist_item) { SteamApiClient::Models::UserWishlistItem.new(raw_attributes) }

      describe "#initialize" do
        it "casts steam_id to an integer field" do
          assert_equal 76_561_197_960_435_530, user_wishlist_item.steam_id
        end

        it "casts appid to an integer field" do
          assert_equal 440, user_wishlist_item.app_id
        end

        it "casts priority to an integer field" do
          assert_equal 1, user_wishlist_item.priority
        end

        it "casts date_added to a real Time object" do
          assert_kind_of Time, user_wishlist_item.date_added
        end
      end
    end
  end
end
