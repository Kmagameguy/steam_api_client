# frozen_string_literal: true

module SteamApiClient
  module Resources
    class IWishlistService
      class Error < StandardError; end
      class NoSteamIdError < StandardError; end

      SERVICE_NAME = "IWishlistService"
      API_VERSION  = "v0001"

      GET_WISHLIST                 = "GetWishlist"
      GET_WISHLIST_SORTED_FILTERED = "GetWishlistSortedFiltered"
      GET_WISHLIST_ITEM_COUNT      = "GetWishlistItemCount"

      attr_accessor :steam_id

      def initialize(steam_id:, connection: ::SteamApiClient::Connection.new)
        @steam_id = steam_id
        @connection = connection

        raise NoSteamIdError if @steam_id.nil?
      end

      # TODO: Figure out how the GetWishlistSortedFiltered query params work...
      def user_wishlist
        response = connection.get(build_url(GET_WISHLIST), { steamid: steam_id })
        processed_response = process_response(response)&.dig("items") || []

        processed_response.map do |item|
          Models::UserWishlistItem.new(item.merge("steam_id" => steam_id))
        end
      end

      private

      attr_reader :connection

      def build_url(resource)
        "#{SERVICE_NAME}/#{resource}/#{API_VERSION}"
      end

      def process_response(response)
        return response.body&.dig("response") if response.success?

        raise Error, status: response.status, error_message: response.body
      end
    end
  end
end
