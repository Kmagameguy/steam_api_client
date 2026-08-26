# frozen_string_literal: true

require "json"
require "faraday"

module SteamApiClient
  autoload :Config,     "steam_api_client/config"
  autoload :Connection, "steam_api_client/connection"

  module Resources
    autoload :IPlayerService,  "steam_api_client/resources/i_player_service"
    autoload :ISteamNews,      "steam_api_client/resources/i_steam_news"
    autoload :ISteamUserStats, "steam_api_client/resources/i_steam_user_stats"
  end
end
