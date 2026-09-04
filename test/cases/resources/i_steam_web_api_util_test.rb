# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class ISteamWebApiUtilTest < Minitest::Spec
      let(:subject) { SteamApiClient::Resources::ISteamWebApiUtil }

      describe ".supported_api_list" do
        it "fetches all the public API resources available for the given access key" do
          VCR.use_cassette("i_steam_web_api_util/supported_api_list") do
            web_api_listings = subject.supported_api_list["interfaces"]

            assert_kind_of Array, web_api_listings
            assert_includes web_api_listings.first.keys, "name"
            assert_includes web_api_listings.first.keys, "methods"
            assert_kind_of Array, web_api_listings.first["methods"]
          end
        end
      end
    end
  end
end
