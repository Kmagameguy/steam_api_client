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
    end
  end
end
