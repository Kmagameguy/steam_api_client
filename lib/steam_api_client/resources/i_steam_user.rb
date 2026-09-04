# frozen_string_literal: true

module SteamApiClient
  module Resources
    class ISteamUser
      class Error < StandardError; end
      class NoSteamIdError < Error; end
      class TooManyIdsError < Error; end
      class InvalidUrlTypeError < Error; end
      class PrivateResourceError < Error; end

      SERVICE_NAME         = "ISteamUser"
      GET_FRIEND_LIST      = "GetFriendList"
      GET_PLAYER_BANS      = "GetPlayerBans"
      GET_PLAYER_SUMMARIES = "GetPlayerSummaries"
      GET_USER_GROUP_LIST  = "GetUserGroupList"
      RESOLVE_VANITY_URL   = "ResolveVanityURL"

      API_VERSION_1        = "v0001"
      API_VERSION_2        = "v0002"
      API_VERSION_MAP = {
        GET_FRIEND_LIST      => API_VERSION_1,
        GET_PLAYER_BANS      => API_VERSION_1,
        GET_PLAYER_SUMMARIES => API_VERSION_2,
        GET_USER_GROUP_LIST  => API_VERSION_1,
        RESOLVE_VANITY_URL   => API_VERSION_1
      }.freeze

      STEAM_ID_QUERY_LIMIT = 100

      VANITY_URL_TYPES = {
        default: 1,
        profile: 1,
        group:   2,
        official_game_group: 3
      }.freeze

      attr_accessor :steam_id

      def self.steam_id_for_vanity_url(vanity_url, url_type: :default, connection: ::SteamApiClient::Connection.instance)
        new(connection: connection).steam_id_for_vanity_url(vanity_url, url_type: url_type)
      end

      def self.vanity_url_types
        VANITY_URL_TYPES.keys
      end

      def initialize(steam_id: nil, connection: ::SteamApiClient::Connection.instance)
        @steam_id   = steam_id
        @connection = connection
      end

      # TODO: This will return 401 Unauthorized if a user's friend list is private.
      # We should either cast that to a more friendly error message (e.g. PrivateListError) or handle it
      # gracefully (maybe ! vs non-! methods?)
      def friend_list(relationship: nil)
        raise NoSteamIdError if steam_id.nil?

        params = {
          steamid: steam_id,
          relationship: relationship
        }.select { |_, v| v }

        response = connection.get(build_url(GET_FRIEND_LIST), params)

        raise PrivateResourceError, "#{steam_id}'s friend list is private." if response.status == 401

        processed_response = process_response(response, key: "friendslist")&.dig("friends") || []
        processed_response.map { |item| Models::UserFriend.new(item) }
      end

      def player_bans(additional_steam_ids: [])
        additional_steam_ids = Array(additional_steam_ids).compact.map(&:to_i)
        raise NoSteamIdError if steam_id.nil? && additional_steam_ids.empty?

        steam_ids = ([steam_id.to_i] + additional_steam_ids).uniq.sort
        raise TooManyIdsError if steam_ids.size > STEAM_ID_QUERY_LIMIT

        response = connection.get(build_url(GET_PLAYER_BANS), { steamids: steam_ids.join(",") })
        processed_response = process_response(response, key: :players)

        processed_response.map! do |item|
          Models::UserBan.new(item)
        end

        processed_response.size > 1 ? processed_response : processed_response.first
      end

      def player_profile
        raise NoSteamIdError if steam_id.nil?

        response = connection.get(build_url(GET_PLAYER_SUMMARIES), { steamids: steam_id })
        processed_response = process_response(response, key: :response)&.dig("players")&.first || {}

        Models::UserProfile.new(processed_response)
      end

      def players_profiles(steam_ids: [])
        steam_ids = Array(steam_ids).compact.uniq

        raise NoSteamIdError if steam_ids.empty?
        raise TooManyIdsError if steam_ids.size > STEAM_ID_QUERY_LIMIT

        response = connection.get(build_url(GET_PLAYER_SUMMARIES), { steamids: steam_ids.join(",") })
        processed_response = process_response(response, key: :response)&.dig("players") || []

        processed_response.map do |item|
          Models::UserProfile.new(item)
        end
      end

      def group_list
        raise NoSteamIdError if steam_id.nil?

        params = {
          steamid: steam_id
        }

        response = connection.get(build_url(GET_USER_GROUP_LIST), params)
        processed_response = process_response(response, key: :response)&.dig("groups") || []

        processed_response.map do |item|
          Models::UserGroup.new({ "steam_id" => steam_id, "group_id" => item["gid"] })
        end
      end

      def steam_id_for_vanity_url(vanity_url, url_type: :default)
        mapped_url_type = VANITY_URL_TYPES[url_type.to_sym]
        raise InvalidUrlTypeError, "Unrecognized url_type: #{url_type}" if mapped_url_type.nil?

        params = {
          vanityurl: vanity_url,
          url_type: mapped_url_type
        }

        response = connection.get(build_url(RESOLVE_VANITY_URL), params)
        process_response(response, key: :response)
      end

      private

      attr_reader :connection

      # TODO: Don't like having this directly in this class (or in the other similar classes)
      # See SteamUser for an example of why this is awkward. Maybe this should be its own class (?)
      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION_MAP[resource]}"
      end

      # TODO: Allow "key" to be multi-level dig, e.g. [:response, :players]
      # TODO: Don't like having this directly in this class (or in the other similar classes)
      # See SteamUser for an example of why this is awkward. Maybe this should be its own class (?)
      def process_response(response, key:)
        return response.body&.dig(key.to_s) if response.success?

        raise Error, "#{response.status}: #{response.body}"
      end
    end
  end
end
