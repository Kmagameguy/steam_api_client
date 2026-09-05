# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  class SteamUserTest < Minitest::Spec
    let(:display_name) { "robinwalker" }
    let(:steam_id)     { TestFixtures::TEST_STEAM_ID1 }
    let(:subject)      { SteamApiClient::SteamUser }

    describe ".from_username" do
      it "can derive a steam_id from a given public display name" do
        VCR.use_cassette("steam_user/from_username") do
          steam_user = subject.from_username(display_name)

          assert_kind_of SteamUser, steam_user
          refute_nil steam_user.steam_id
        end
      end

      it "raises an error if the display name isn't found" do
        VCR.use_cassette("steam_user/username_not_found") do
          assert_raises(subject::UsernameNotFoundError) { subject.from_username(" ") }
        end
      end
    end

    describe ".profiles_for" do
      it "fetches user profiles for the given steam ids and creates UserProfile Objects" do
        VCR.use_cassette("steam_user/profiles_for") do
          users_profiles = subject.profiles_for(steam_ids: [steam_id, TestFixtures::TEST_STEAM_ID2])

          assert_kind_of Array, users_profiles
          assert_kind_of Models::UserProfile, users_profiles.first
        end
      end
    end

    describe "#initialize" do
      it "exposes steam_id as a field" do
        assert_equal steam_id, subject.new(steam_id: steam_id).steam_id
      end

      it "defaults to using the steam_id in ENV" do
        assert_equal ENV.fetch("MY_STEAM_ID"), subject.new.steam_id
      end

      it "raises a NoSteamIdError if the given steam_id is nil" do
        assert_raises(subject::NoSteamIdError) { subject.new(steam_id: nil) }
      end
    end

    describe "#games" do
      it "finds games owned by the provided steam_id and fetches appinfo and played free games by default" do
        VCR.use_cassette("steam_user/games") do
          user_owned_games = subject.new(steam_id: TestFixtures::TEST_STEAM_ID2).games

          assert_kind_of Array, user_owned_games

          sample_game = user_owned_games.first

          assert_kind_of Models::UserOwnedGame, sample_game
          refute_nil sample_game.name
        end
      end

      it "memoizes the results" do
        user_owned_game = Models::UserOwnedGame.new(
          {
            "appid" => "10",
            "name"  => "Counter-Strike"
          }
        )
        Resources::IPlayerService.any_instance
                                 .expects(:owned_games)
                                 .with(include_appinfo: true, include_played_free_games: true)
                                 .once
                                 .returns([user_owned_game])
        steam_user = subject.new(steam_id: steam_id)

        steam_user.games
        # Call it again to test memoization; if memoized then the expectation above should pass because
        # the outbound query to the Steam Web API will only fire once
        steam_user.games
      end

      it "does not memoize the result when caching is disabled" do
        user_owned_game = Models::UserOwnedGame.new(
          {
            "appid" => "10",
            "name"  => "Counter-Strike"
          }
        )
        Resources::IPlayerService.any_instance
                                 .expects(:owned_games)
                                 .with(include_appinfo: true, include_played_free_games: true)
                                 .twice
                                 .returns([user_owned_game])
        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)

        steam_user.games
        steam_user.games
      end
    end

    describe "#wishlist" do
      it "fetches the user's wishlist" do
        Resources::IWishlistService.any_instance.expects(:user_wishlist).once

        subject.new(steam_id: steam_id).wishlist
      end

      it "memoizes the results" do
        user_wishlist_item = Models::UserWishlistItem.new
        Resources::IWishlistService.any_instance
                                   .expects(:user_wishlist)
                                   .once
                                   .returns([user_wishlist_item])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.wishlist
        steam_user.wishlist
      end

      it "does not memoize the result when caching is disabled" do
        user_wishlist_item = Models::UserWishlistItem.new
        Resources::IWishlistService.any_instance
                                   .expects(:user_wishlist)
                                   .twice
                                   .returns([user_wishlist_item])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.wishlist
        steam_user.wishlist
      end

      it "returns an empty list when encountering an error" do
        Resources::IWishlistService.any_instance.expects(:user_wishlist).raises(Resources::IWishlistService::Error)

        assert_empty subject.new(steam_id: steam_id).wishlist
      end
    end

    describe "#followed_games" do
      it "fetches the list of games the user follows" do
        Resources::IStoreService.any_instance.expects(:games_followed_by).with(steam_id: steam_id).once

        subject.new(steam_id: steam_id).followed_games
      end

      it "memoizes the results" do
        user_followed_game = Models::UserFollowedGame.new
        Resources::IStoreService.any_instance
                                .expects(:games_followed_by)
                                .with(steam_id: steam_id)
                                .once
                                .returns([user_followed_game])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.followed_games
        steam_user.followed_games
      end

      it "does not memoize the result when caching is disabled" do
        user_followed_game = Models::UserFollowedGame.new
        Resources::IStoreService.any_instance
                                .expects(:games_followed_by)
                                .with(steam_id: steam_id)
                                .twice
                                .returns([user_followed_game])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.followed_games
        steam_user.followed_games
      end

      it "returns an empty list when encountering an error" do
        Resources::IStoreService.any_instance
                                .expects(:games_followed_by)
                                .with(steam_id: steam_id)
                                .raises(Resources::IStoreService::Error)

        assert_empty subject.new(steam_id: steam_id).followed_games
      end
    end

    describe "#friends" do
      it "fetches the user's list of friends" do
        Resources::ISteamUser.any_instance.expects(:friend_list).with(relationship: nil).once

        subject.new(steam_id: steam_id).friends
      end

      it "fetches a filtered list of the user's friends" do
        Resources::ISteamUser.any_instance.expects(:friend_list).with(relationship: "blocked").once

        subject.new(steam_id: steam_id).friends(relationship_type: "blocked")
      end

      it "memoizes the results" do
        user_friend = Models::UserFriend.new
        Resources::ISteamUser.any_instance
                             .expects(:friend_list)
                             .with(relationship: nil)
                             .once
                             .returns([user_friend])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.friends
        steam_user.friends
      end

      it "does not memoize the result when caching is disabled" do
        user_friend = Models::UserFriend.new
        Resources::ISteamUser.any_instance
                             .expects(:friend_list)
                             .with(relationship: nil)
                             .twice
                             .returns([user_friend])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.friends
        steam_user.friends
      end

      it "raises when the friend list is private" do
        Resources::ISteamUser.any_instance
                             .expects(:friend_list)
                             .with(relationship: nil)
                             .raises(Resources::ISteamUser::PrivateResourceError)

        assert_raises(Resources::ISteamUser::PrivateResourceError) { subject.new(steam_id: steam_id).friends }
      end

      it "returns an empty array for any other error type" do
        Resources::ISteamUser.any_instance
                             .expects(:friend_list)
                             .with(relationship: nil)
                             .raises(Resources::ISteamUser::Error)

        assert_empty subject.new(steam_id: steam_id).friends
      end
    end

    describe "#bans" do
      it "fetches ban history for the provided steam_id" do
        Resources::ISteamUser.any_instance.expects(:player_bans).once

        subject.new(steam_id: steam_id).bans
      end

      it "memoizes the results" do
        user_ban = Models::UserBan.new
        Resources::ISteamUser.any_instance.expects(:player_bans).once.returns([user_ban])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.bans
        steam_user.bans
      end

      it "does not memoize the result when caching is disabled" do
        user_ban = Models::UserBan.new
        Resources::ISteamUser.any_instance.expects(:player_bans).twice.returns([user_ban])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.bans
        steam_user.bans
      end

      it "returns an empty array when encountering an error" do
        Resources::ISteamUser.any_instance.expects(:player_bans).raises(Resources::ISteamUser::Error)

        assert_empty subject.new(steam_id: steam_id).bans
      end
    end

    describe "#groups" do
      it "fetches group memberships for the provided steam_id" do
        Resources::ISteamUser.any_instance.expects(:group_list).once

        subject.new(steam_id: steam_id).groups
      end

      it "memoizes the results" do
        user_group = Models::UserGroup.new
        Resources::ISteamUser.any_instance.expects(:group_list).once.returns([user_group])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.groups
        steam_user.groups
      end

      it "does not memoize the result when caching is disabled" do
        user_group = Models::UserGroup.new
        Resources::ISteamUser.any_instance.expects(:group_list).twice.returns([user_group])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.groups
        steam_user.groups
      end

      it "returns an empty array when encountering an error" do
        Resources::ISteamUser.any_instance.expects(:group_list).raises(Resources::ISteamUser::Error)

        assert_empty subject.new(steam_id: steam_id).groups
      end
    end

    describe "#profile" do
      it "fetches the profile for the given steam_id" do
        Resources::ISteamUser.any_instance.expects(:player_profile).once

        subject.new(steam_id: steam_id).profile
      end

      it "memoizes the results" do
        user_profile = Models::UserProfile.new
        Resources::ISteamUser.any_instance.expects(:player_profile).once.returns([user_profile])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.profile
        steam_user.profile
      end

      it "does not memoize the result when caching is disabled" do
        user_profile = Models::UserProfile.new
        Resources::ISteamUser.any_instance.expects(:player_profile).twice.returns([user_profile])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.profile
        steam_user.profile
      end

      it "returns an empty array when encountering an error" do
        Resources::ISteamUser.any_instance.expects(:player_profile).raises(Resources::ISteamUser::Error)

        assert_empty subject.new(steam_id: steam_id).profile
      end
    end

    describe "#recently_played" do
      it "fetches a list of games recently played by the given steam_id" do
        Resources::IPlayerService.any_instance.expects(:recently_played_games).with(limit: nil).once

        subject.new(steam_id: steam_id).recently_played
      end

      it "fetches a limited list of games recently played by the given steam_id" do
        Resources::IPlayerService.any_instance.expects(:recently_played_games).with(limit: 1).once

        subject.new(steam_id: steam_id).recently_played(limit: 1)
      end

      it "memoizes the results" do
        user_owned_game = Models::UserOwnedGame.new
        Resources::IPlayerService.any_instance
                                 .expects(:recently_played_games)
                                 .with(limit: nil)
                                 .once
                                 .returns([user_owned_game])

        steam_user = subject.new(steam_id: steam_id)
        steam_user.recently_played
        steam_user.recently_played
      end

      it "does not memoize the result when caching is disabled" do
        user_owned_game = Models::UserOwnedGame.new
        Resources::IPlayerService.any_instance
                                 .expects(:recently_played_games)
                                 .with(limit: nil)
                                 .twice
                                 .returns([user_owned_game])

        steam_user = subject.new(steam_id: steam_id, bypass_cache: true)
        steam_user.recently_played
        steam_user.recently_played
      end

      it "returns an empty array when encountering an error" do
        Resources::IPlayerService.any_instance
                                 .expects(:recently_played_games)
                                 .with(limit: nil)
                                 .raises(Resources::IPlayerService::Error)

        assert_empty subject.new(steam_id: steam_id).recently_played
      end
    end
  end
end
