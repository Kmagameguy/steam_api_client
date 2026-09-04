# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class ISteamUserTest < Minitest::Spec
      let(:steam_id) { TestFixtures::TEST_STEAM_ID1 }
      let(:subject)  { SteamApiClient::Resources::ISteamUser }

      describe ".steam_id_for_vanity_url" do
        it "fetches the steam_id when given a real account name" do
          VCR.use_cassette("i_steam_user/steam_id_for_vanity_url") do
            steam_user = subject.steam_id_for_vanity_url("robinwalker")

            assert_equal steam_id, steam_user["steamid"]
          end
        end

        it "indicates failure when a steam_id cannot be found" do
          VCR.use_cassette("i_steam_user/no_steam_id_for_vanity_url") do
            response = subject.steam_id_for_vanity_url(" ")

            assert_equal "No match", response["message"]
          end
        end

        it "raises an InvalidUrlTypeError when the vanity url type is unregistered" do
          assert_raises(subject::InvalidUrlTypeError, "Unrecognized url_type: not_a_real_type") do
            subject.steam_id_for_vanity_url("robinwalker", url_type: :not_a_real_type)
          end
        end
      end

      describe ".vanity_url_types" do
        it "produces the list of valid vanity_url types" do
          expected_list = %i[default profile group official_game_group]

          assert_equal expected_list, subject.vanity_url_types
        end
      end

      describe "#initialize" do
        it "exposes steam_id as a field" do
          assert_equal steam_id, subject.new(steam_id: steam_id).steam_id
        end
      end

      describe "#friend_list" do
        it "fetches friends for the given steam_id and creates UserFriend Objects" do
          VCR.use_cassette("i_steam_user/friend_list") do
            friends = subject.new(steam_id: steam_id).friend_list

            assert_operator friends.size, :>, 1
            assert_instance_of Models::UserFriend, friends.first
          end
        end

        it "accepts a relationship keyword" do
          VCR.use_cassette("i_steam_user/friend_list_with_relationship_keyword") do
            friends = subject.new(steam_id: steam_id).friend_list(relationship: :friend)

            assert_operator friends.size, :>, 1
            assert_instance_of Models::UserFriend, friends.first
          end
        end

        it "raises a PrivateResourceError when the given steam_id's friend list is private" do
          mock_response = mock("response")
          mock_response.expects(:status).returns(401)
          Connection.any_instance.stubs(:get).returns(mock_response)

          assert_raises(subject::PrivateResourceError, "#{steam_id}'s friend list is private.") do
            subject.new(steam_id: steam_id).friend_list
          end
        end

        it "raises a NoSteamIdError when a steam_id is not provided" do
          assert_raises(subject::NoSteamIdError) { subject.new.friend_list }
        end
      end

      describe "#player_bans" do
        it "fetches ban history for the given steam_id and creates a UserBan Object" do
          VCR.use_cassette("i_steam_user/player_bans") do
            player_bans = subject.new(steam_id: steam_id).player_bans

            assert_kind_of Models::UserBan, player_bans
          end
        end

        it "can fetch ban history for many steam_ids at once" do
          VCR.use_cassette("i_steam_user/player_bans_multiple_steam_ids") do
            player_bans = subject.new(steam_id: steam_id)
                                 .player_bans(additional_steam_ids: [TestFixtures::TEST_STEAM_ID2])

            assert_operator player_bans.size, :>, 1
            assert_kind_of Models::UserBan, player_bans.first
          end
        end

        it "limits the number of steam_ids per query" do
          steam_ids = (1..(subject::STEAM_ID_QUERY_LIMIT + 1)).to_a
          assert_raises(subject::TooManyIdsError) do
            subject.new(steam_id: steam_id).player_bans(additional_steam_ids: steam_ids)
          end
        end
      end

      describe "#player_profile" do
        it "fetches profile information for the given steam_id and creates a UserProfile Object" do
          VCR.use_cassette("i_steam_user/player_profile") do
            player_profile = subject.new(steam_id: steam_id).player_profile

            assert_kind_of Models::UserProfile, player_profile
          end
        end

        it "raises NoSteamIdError if the provided steam_id is nil" do
          assert_raises(subject::NoSteamIdError) { subject.new(steam_id: nil).player_profile }
        end

        it "returns nil if a profile wasn't found" do
          mock_response = mock("response")
          mock_response.expects(:body).returns({})
          mock_response.expects(:success?).returns(true)
          Connection.any_instance.expects(:get).returns(mock_response)

          player_profile = subject.new(steam_id: steam_id).player_profile

          assert_nil player_profile
        end
      end

      describe "#players_profiles" do
        it "fetches profile information for many steam_ids and creates UserProfile Objects" do
          VCR.use_cassette("i_steam_user/players_profiles") do
            players_profiles = subject.new.players_profiles(steam_ids: [steam_id, TestFixtures::TEST_STEAM_ID2])

            assert_operator players_profiles.size, :>, 1
            assert_kind_of Models::UserProfile, players_profiles.first
          end
        end

        it "raises NoSteamIdError if the steam_ids array is empty" do
          assert_raises(subject::NoSteamIdError) { subject.new.players_profiles }
        end

        it "limits the number of steam_ids per query" do
          steam_ids = (1..(subject::STEAM_ID_QUERY_LIMIT + 1)).to_a
          assert_raises(subject::TooManyIdsError) { subject.new.players_profiles(steam_ids: steam_ids) }
        end
      end

      describe "#group_list" do
        it "fetches group memberships for a steam_id and creates UserGroup Objects" do
          VCR.use_cassette("i_steam_user/group_list") do
            group_list = subject.new(steam_id: steam_id).group_list

            assert_kind_of Array, group_list
            assert_kind_of Models::UserGroup, group_list.first
          end
        end

        it "raises NoSteamIdError if the steam_id is nil" do
          assert_raises(subject::NoSteamIdError) { subject.new(steam_id: nil).group_list }
        end
      end
    end
  end
end
