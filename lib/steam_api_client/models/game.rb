# frozen_string_literal: true

module SteamApiClient
  module Models
    class Game
      attr_reader :id, :name, :img_icon_url, :content_descriptor_ids

      def initialize(raw_attributes = {})
        @raw_attributes         = raw_attributes
        @id                     = @raw_attributes["appid"].to_i
        @name                   = @raw_attributes["name"]
        @img_icon_url           = @raw_attributes["img_icon_url"]
        @content_descriptor_ids = @raw_attributes["content_descriptorids"] || []

        post_initialize_hook
      end

      def news
        @news ||= steam_news_service.news_for_app
      end

      def global_achievement_percentages
        @global_achievement_percentages ||= steam_user_stats.global_achievement_percentages_for_app
      end

      def attributes
        to_h
      end

      def to_h
        {}.tap do |h|
          h[:id]           = id
          h[:name]         = name
          h[:img_icon_url] = img_icon_url
          h[:content_descriptor_ids] = content_descriptor_ids
        end
      end

      protected

      def post_initialize_hook; end

      def steam_news_service
        @steam_news_service ||= Resources::ISteamNews.new(app_id: id)
      end

      def steam_user_stats
        @steam_user_stats ||= Resources::ISteamUserStats.new(app_id: id)
      end
    end
  end
end
