# frozen_string_literal: true

module SteamApiClient
  module Models
    class GameNews
      include Concerns::TimeCastable

      NEWS_FEED_SOURCE_ENUM = {
        0 => "external_feed",
        1 => "steam_community"
      }.freeze

      attr_reader :app_id,
                  :id,
                  :heading,
                  :author,
                  :content,
                  :feed,
                  :feed_source,
                  :tags,
                  :url,
                  :post_date

      def initialize(raw_attributes = {})
        @app_id          = raw_attributes["appid"].to_i
        @id              = raw_attributes["gid"].to_i
        @heading         = raw_attributes["title"]
        @author          = raw_attributes["author"]
        @content         = raw_attributes["contents"]
        @feed            = raw_attributes["feedname"]
        @feed_source     = NEWS_FEED_SOURCE_ENUM[raw_attributes["feed_type"].to_i]
        @tags            = Array(raw_attributes["tags"])
        @url             = raw_attributes["url"]
        @is_external_url = !!raw_attributes["is_external_url"]
        @post_date       = cast_to_time(raw_attributes["date"].to_i)
      end

      def post_from_external_site?
        !post_from_steam_community?
      end

      def post_from_steam_community?
        feed_source == "steam_community"
      end

      def links_to_external_site?
        is_external_url
      end

      private

      attr_reader :is_external_url
    end
  end
end
