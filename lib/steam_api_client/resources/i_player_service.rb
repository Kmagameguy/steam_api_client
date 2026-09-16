# frozen_string_literal: true

module SteamApiClient
  module Resources
    class IPlayerService
      class Error < StandardError; end
      class NoSteamIdError < Error; end

      SERVICE_NAME              = "IPlayerService"
      API_VERSION               = "v0001"
      GET_OWNED_GAMES           = "GetOwnedGames"
      GET_RECENTLY_PLAYED_GAMES = "GetRecentlyPlayedGames"

      CACHE_TTLS = {
        GET_OWNED_GAMES           => 300,
        GET_RECENTLY_PLAYED_GAMES => 60
      }.freeze

      attr_accessor :steam_id

      def initialize(steam_id:, connection: ::SteamApiClient::Connection.instance)
        @steam_id   = steam_id
        @connection = connection

        raise NoSteamIdError if @steam_id.nil?
      end

      # TODO: Figure out how Valve wants the appids_filter passed in. Might need to use POST for that since the
      # docs state it can't be a URL param (?)
      def owned_games(include_appinfo: false, include_played_free_games: false)
        params = { include_appinfo: include_appinfo, include_played_free_games: include_played_free_games }
                 .select { |_, v| v }

        params[:steamid] = steam_id
        processed_response = cached_response(GET_OWNED_GAMES, params)&.dig("games") || []

        processed_response.map do |game|
          base_game = Models::Game.new(game)
          Models::UserOwnedGame.new(game: base_game, raw_attributes: game.merge("steam_id" => steam_id))
        end
      end

      def recently_played_games(limit: nil)
        params = {
          steamid: steam_id,
          count: limit
        }.select { |_, v| v }

        processed_response = cached_response(GET_RECENTLY_PLAYED_GAMES, params)&.dig("games") || []

        processed_response.map do |item|
          base_game = Models::Game.new(item)
          Models::UserOwnedGame.new(game: base_game, raw_attributes: item.merge("steam_id" => steam_id))
        end
      end

      private

      attr_reader :connection

      def cached_response(endpoint, params)
        SteamApiClient.cache.fetch(cache_key(endpoint, params), expires_in: CACHE_TTLS[endpoint]) do
          process_response(connection.get(build_url(endpoint), params))
        end
      end

      def cache_key(endpoint, params)
        query = params.sort.map { |k, v| "#{k}=#{v}" }.join("&")
        "i_player_service/#{endpoint}/#{API_VERSION}/#{steam_id}/#{query}"
      end

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}/"
      end

      def process_response(response)
        return response.body&.dig("response") if response.success?

        raise Error, "#{response.status}: #{response.body}"
      end
    end
  end
end
