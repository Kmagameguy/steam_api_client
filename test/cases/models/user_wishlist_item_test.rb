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

      describe "#steam_user" do
        it "gives access to a SteamUser via the provided steam_id" do
          assert_kind_of SteamUser, user_wishlist_item.steam_user
          assert_equal user_wishlist_item.steam_id, user_wishlist_item.steam_user.steam_id
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

          user_wishlist_item.game
        end
      end
    end
  end
end
