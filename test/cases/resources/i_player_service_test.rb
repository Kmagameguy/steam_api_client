# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  module Resources
    class IPlayerServiceTest < SteamApiClientTest
      let(:steam_id) { TestFixtures::TEST_STEAM_ID1 }
      let(:subject)  { SteamApiClient::Resources::IPlayerService }

      describe "#initialize" do
        it "exposes a steam_id field" do
          assert_equal steam_id, subject.new(steam_id: steam_id).steam_id
        end

        it "raises an error if steam_id is nil" do
          assert_raises(subject::Error) { subject.new(steam_id: nil) }
        end
      end

      describe "#owned_games" do
        it "fetches games owned by the provided steam_id and creates UserOwnedGame Objects" do
          VCR.use_cassette("i_player_service/owned_games") do
            owned_games = subject.new(steam_id: steam_id).owned_games
            sample_game = owned_games.first

            assert_operator owned_games.size, :>, 1
            assert_instance_of Models::UserOwnedGame, sample_game
            assert_nil sample_game.name
          end
        end

        it "can also fetch extra app info and free games" do
          VCR.use_cassette("i_player_service/owned_games_with_appinfo_and_free_games") do
            owned_games = subject.new(steam_id: steam_id)
                                 .owned_games(include_appinfo: true, include_played_free_games: true)

            sample_game = owned_games.first

            assert_operator owned_games.size, :>, 1
            assert_instance_of Models::UserOwnedGame, sample_game
            refute_empty sample_game.name
          end
        end
      end

      describe "#recently_played_games" do
        it "fetches games that were recently played by the provided steam_id as UserOwnedGame Objects" do
          VCR.use_cassette("i_player_service/recently_played_games") do
            recently_played = subject.new(steam_id: steam_id).recently_played_games
            sample_game = recently_played.first

            assert_operator recently_played.size, :>, 1
            assert_instance_of Models::UserOwnedGame, sample_game
            assert_equal steam_id.to_i, sample_game.steam_id
          end
        end

        it "can be configured to show a limited number of recently played games" do
          VCR.use_cassette("i_player_service/recently_played_games_limited") do
            recently_played = subject.new(steam_id: steam_id).recently_played_games(limit: 1)

            assert_equal 1, recently_played.size
            assert_instance_of Models::UserOwnedGame, recently_played.first
            assert_equal steam_id.to_i, recently_played.first.steam_id
          end
        end
      end
      describe "response caching" do
        def fake_response(app_ids)
          response = mock("response")
          response.stubs(:success?).returns(true)
          response.stubs(:body).returns({ "response" => { "games" => app_ids.map { |id| { "appid" => id.to_s } } } })
          response
        end

        def cached_service(connection)
          SteamApiClient.cache = MemoryCache.new
          subject.new(steam_id: steam_id, connection: connection)
        end

        it "does not hit the API for repeated owned_games calls within the TTL" do
          connection = mock("connection")
          connection.expects(:get).once.returns(fake_response([440]))

          service = cached_service(connection)

          games = service.owned_games
          again = service.owned_games

          assert_equal [440], games.map(&:id)
          assert_equal games.map(&:id), again.map(&:id)
        end

        it "does not hit the API for repeated recently_played_games calls within the TTL" do
          connection = mock("connection")
          connection.expects(:get).once.returns(fake_response([440]))

          service = cached_service(connection)

          recently_played = service.recently_played_games
          again = service.recently_played_games

          assert_equal [440], recently_played.map(&:id)
          assert_equal recently_played.map(&:id), again.map(&:id)
        end

        it "uses a separate cache entry per parameter set" do
          connection = mock("connection")
          connection.expects(:get).twice.returns(fake_response([440]), fake_response([440, 220]))

          service = cached_service(connection)

          service.owned_games
          games_with_appinfo = service.owned_games(include_appinfo: true)

          assert_equal [440, 220], games_with_appinfo.map(&:id)
        end

        it "uses a separate cache entry per steam_id" do
          connection = mock("connection")
          connection.expects(:get).twice.returns(fake_response([440]), fake_response([220]))

          first = cached_service(connection)
          second = subject.new(steam_id: TestFixtures::TEST_STEAM_ID2, connection: connection)

          assert_equal [440], first.owned_games.map(&:id)
          assert_equal [220], second.owned_games.map(&:id)
        end

        it "re-fetches once the TTL has passed" do
          connection = mock("connection")
          connection.expects(:get).twice.returns(fake_response([440]), fake_response([220]))

          service = cached_service(connection)
          service.owned_games

          expired_at = Time.now + 301
          Time.stubs(:now).returns(expired_at)

          assert_equal [220], service.owned_games.map(&:id)
        end
      end
    end
  end
end
