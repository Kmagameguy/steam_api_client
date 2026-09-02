# frozen_string_literal: true

module SteamApiClient
  module Models
    class Game
      CONTENT_DESCRIPTORS_ENUM = {
        1 => "some_nudity_or_sexual_content",
        2 => "frequent_violence_or_gore",
        3 => "adult_only_content",
        4 => "frequent_nudity_or_sexual_content",
        5 => "general_mature_content"
      }.freeze

      attr_reader :id, :name, :img_icon_url, :mature_content_warnings

      def initialize(raw_attributes = {})
        @raw_attributes          = raw_attributes
        @id                      = @raw_attributes["appid"].to_i
        @name                    = @raw_attributes["name"]
        @img_icon_url            = @raw_attributes["img_icon_url"]
        @mature_content_warnings = map_mature_content_warnings(@raw_attributes["content_descriptorids"])

        post_initialize_hook
      end

      def news
        @news ||= steam_news_service.news_for_app
      end

      def global_achievement_percentages
        @global_achievement_percentages ||= steam_user_stats.global_achievement_percentages_for_app
      end

      def mature_content?
        mature_content_warnings.any?
      end

      def attributes
        to_h
      end

      def to_h
        {}.tap do |h|
          h[:id]           = id
          h[:name]         = name
          h[:img_icon_url] = img_icon_url
          h[:mature_content_warnings] = mature_content_warnings
        end
      end

      protected

      def post_initialize_hook; end

      def map_mature_content_warnings(content_descriptor_ids)
        Array(content_descriptor_ids).filter_map do |content_descriptor_id|
          CONTENT_DESCRIPTORS_ENUM[content_descriptor_id]
        end
      end

      def steam_news_service
        @steam_news_service ||= Resources::ISteamNews.new(app_id: id)
      end

      def steam_user_stats
        @steam_user_stats ||= Resources::ISteamUserStats.new(app_id: id)
      end
    end
  end
end
