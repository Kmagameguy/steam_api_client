# frozen_string_literal: true

module SteamApiClient
  class SteamUser
    # TODO: Consider extracting errors to an errors.rb module
    class Error < StandardError; end
    class NoSteamIdError < Error; end
    class UsernameNotFoundError < Error; end
    class AppNotFoundError < Error; end

    def self.from_username(username)
      steam_id = Resources::ISteamUser.steam_id_for_vanity_url(username)&.dig("steamid")
      raise UsernameNotFoundError if steam_id.nil? || steam_id.to_i <= 0

      new(steam_id: steam_id)
    rescue StandardError => e
      raise UsernameNotFoundError, e.message
    end

    def self.profiles_for(steam_ids: [])
      Resources::ISteamUser.new.players_profiles(steam_ids: steam_ids)
    end

    attr_reader :steam_id

    def initialize(steam_id: ENV["MY_STEAM_ID"], bypass_cache: false)
      @steam_id     = steam_id
      @bypass_cache = !!bypass_cache

      raise NoSteamIdError if @steam_id.nil?
    end

    # TODO: Consider abstracting this a bit with a builder service.
    # That way we could assemble the Models::UserOwnedGame data via multiple
    # API calls all-at-once instead of lazily evaluating things like achievements and stats
    # from inside the Game model itself.
    # That will also make stuff like bypass_cache! work a bit more cleanly...
    def games(include_appinfo: true, include_played_free_games: true)
      @games = nil if bypass_cache

      @games ||= player_service.owned_games(
        include_appinfo: include_appinfo,
        include_played_free_games: include_played_free_games
      )
    end

    # TODO: It'd be nice if we had a way to get more info about a wishlisted
    # game, e.g. its name.
    def wishlist
      @wishlist = nil if bypass_cache

      @wishlist ||= wishlist_service.user_wishlist
    rescue StandardError => _e
      @wishlist = []
    end

    # TODO: It'd be nice if we had a way to get more info about a followed
    # game, e.g. its name
    def followed_games
      @followed_games = nil if bypass_cache

      @followed_games ||= store_service.games_followed_by(steam_id: steam_id)
    rescue StandardError => _e
      @followed_games = []
    end

    # TODO: Not sure if this is really working; tried it on several accounts and
    # just kept getting 401 errors.
    def friends(relationship_type: nil)
      @friends = nil if bypass_cache

      @friends ||= steam_user_service.friend_list(relationship: relationship_type)
    rescue Resources::ISteamUser::PrivateResourceError
      raise
    rescue StandardError => _e
      @friends = []
    end

    def bans
      @bans = nil if bypass_cache

      @bans ||= steam_user_service.player_bans
    rescue StandardError => _e
      @bans = []
    end

    # TODO: It'd be nice if we had a way to get more info about a group,
    # e.g. its name instead of just the group id.
    def groups
      @groups = nil if bypass_cache

      @groups ||= steam_user_service.group_list
    rescue StandardError => _e
      @groups = []
    end

    def profile
      @profile = nil if bypass_cache

      @profile ||= steam_user_service.player_profile
    rescue StandardError => _e
      @profile = {}
    end

    # TODO: Merge the results of this with .games() when possible; this will make
    # the data a bit more synchronized since the recently_played endpoint doesn't
    # return all the same details as .games().
    def recently_played(limit: nil)
      @recently_played = nil if bypass_cache

      @recently_played ||= player_service.recently_played_games(limit: limit)
    rescue StandardError => _e
      @recently_played = []
    end

    # TODO: There's an edge case here where if you've got achievements for a refunded
    # game then this method won't return those results.
    def achievements_for(app_id: nil, app_name: nil)
      raise ArgumentError, "Must provide an app_id or an app_name!" if app_id.nil? && app_name.nil?

      find_game(app_id: app_id, app_name: app_name)&.achievements || []
    end

    # TODO: There's an edge case here, where if you've got achievements for a refunded
    # game then this method won't return those results.
    def stats_for(app_id: nil, app_name: nil)
      raise ArgumentError, "Must provide an app_id or an app_name!" if app_id.nil? && app_name.nil?

      find_game(app_id: app_id, app_name: app_name)&.stats || []
    end

    def bypass_cache?
      !!self.bypass_cache
    end

    def enable_cache!
      # Cosmetic: Invert the assignment so the return value is 'true', matching the
      # semantic meaning of enable_cache! (i.e. caching is true because bypassing cache is false)
      !(self.bypass_cache = false)
    end

    def bypass_cache!
      self.bypass_cache = true
    end

    private

    attr_accessor :bypass_cache

    def find_game(app_id: nil, app_name: nil)
      if app_id
        games.find { |game| game.id == app_id }
      else
        games.find { |game| names_match?(game.name, app_name) }
      end
    end

    def names_match?(str1, str2)
      str1.strip.tr(" ", "").downcase == str2.strip.tr(" ", "").downcase
    end

    def wishlist_service
      @wishlist_service ||= Resources::IWishlistService.new(steam_id: steam_id, connection: connection)
    end

    def steam_user_service
      @steam_user_service ||= Resources::ISteamUser.new(steam_id: steam_id, connection: connection)
    end

    def player_service
      @player_service ||= Resources::IPlayerService.new(steam_id: steam_id, connection: connection)
    end

    def store_service
      @store_service ||= Resources::IStoreService.new(connection: connection)
    end

    def connection
      @connection ||= Connection.instance
    end
  end
end
