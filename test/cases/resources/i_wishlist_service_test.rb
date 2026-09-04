# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class IWishlistServiceTest < Minitest::Spec
      let(:steam_id) { TestFixtures::TEST_STEAM_ID1 }
      let(:subject)  { SteamApiClient::Resources::IWishlistService }

      describe "#initialize" do
        it "exposes steam_id as a field" do
          assert_equal steam_id, subject.new(steam_id: steam_id).steam_id
        end

        it "raises NoSteamIdError if the provided steam_id is nil" do
          assert_raises(subject::NoSteamIdError) { subject.new(steam_id: nil) }
        end
      end

      describe "#user_wishlist" do
        it "fetches wishlist entries for a given steam_id and creates UserWishlistItem Objects" do
          VCR.use_cassette("i_wishlist_service/user_wishlist") do
            user_wishlist = subject.new(steam_id: steam_id).user_wishlist

            assert_kind_of Array, user_wishlist
            assert_kind_of Models::UserWishlistItem, user_wishlist.first
          end
        end
      end
    end
  end
end
