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

      attr_accessor :steam_id

      def initialize(steam_id:, connection: ::SteamApiClient::Connection.new)
        @steam_id   = steam_id
        @connection = connection

        raise NoSteamIdError if @steam_id.nil?
      end

      # TODO: Figure out how Valve wants the appids_filter passed in. Might need to use POST for that since the
      # docs state it can't be a URL param (?)
      def owned_games(include_appinfo: false, include_played_free_games: false)
        params = {
          include_appinfo: include_appinfo,
          include_played_free_games: include_played_free_games
        }.select { |_, v| v }

        params[:steamid] = steam_id

        response = connection.get(build_url(GET_OWNED_GAMES), params)
        processed_response = process_response(response)&.dig("games") || []

        processed_response.map do |game|
          Models::UserOwnedGame.new(game.merge("steam_id" => steam_id))
        end
      end

      def recently_played_games(limit: nil)
        params = {
          steamid: steam_id,
          count: limit
        }.select { |_, v| v}

        response = connection.get(build_url(GET_RECENTLY_PLAYED_GAMES), params)
        processed_response = process_response(response)&.dig("games") || []

        processed_response.map do |item|
          Models::UserOwnedGame.new(item)
        end
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}/"
      end

      def process_response(response)
        return response.body.dig("response") if response.success?

        raise Error, status: response.status, error_message: response.body
      end
    end
  end
end
