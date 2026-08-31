# frozen_string_literal: true

require "json"
require "faraday"

module SteamApiClient
  autoload :Config,     "steam_api_client/config"
  autoload :Connection, "steam_api_client/connection"
  autoload :SteamUser,  "steam_api_client/steam_user"

  module Models
    module Concerns
      autoload :TimeCastable, "steam_api_client/models/concerns/time_castable"
    end

    autoload :Game,                      "steam_api_client/models/game"
    autoload :GameAchievementPercentage, "steam_api_client/models/game_achievement_percentage"
    autoload :GameNews,                  "steam_api_client/models/game_news"
    autoload :UserBan,                   "steam_api_client/models/user_ban"
    autoload :UserFollowedGame,          "steam_api_client/models/user_followed_game"
    autoload :UserFriend,                "steam_api_client/models/user_friend"
    autoload :UserGameAchievement,       "steam_api_client/models/user_game_achievement"
    autoload :UserGameStat,              "steam_api_client/models/user_game_stat"
    autoload :UserGroup,                 "steam_api_client/models/user_group"
    autoload :UserOwnedGame,             "steam_api_client/models/user_owned_game"
    autoload :UserProfile,               "steam_api_client/models/user_profile"
    autoload :UserWishlistItem,          "steam_api_client/models/user_wishlist_item"
  end

  module Resources
    autoload :IPlayerService,   "steam_api_client/resources/i_player_service"
    autoload :ISteamNews,       "steam_api_client/resources/i_steam_news"
    autoload :ISteamUser,       "steam_api_client/resources/i_steam_user"
    autoload :ISteamUserStats,  "steam_api_client/resources/i_steam_user_stats"
    autoload :ISteamWebApiUtil, "steam_api_client/resources/i_steam_web_api_util"
    autoload :IStoreService,    "steam_api_client/resources/i_store_service"
    autoload :IWishlistService, "steam_api_client/resources/i_wishlist_service"
  end
end
