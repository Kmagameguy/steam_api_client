# Steam API Client

A friendly, Ruby-like client for the [Steam Web API](https://developer.valvesoftware.com/wiki/Steam_Web_API).

Query a Steam user's games, playtimes, achievements, stats, wishlist, and more.

## Requirements

- Ruby >= 3.3
- A [Steam User Account](https://store.steampowered.com/join)
- A [Steam Web API key](https://steamcommunity.com/dev/apikey)

## Setup

To install bundler and the project dependencies, run:

```bash
bin/setup
```

Then configure your environment (the repo includes a `.env` file as a starting point):

```env
STEAM_API_KEY=your-api-key
STEAM_API_KEY_DOMAIN=your-domain.com
STEAM_API_ROOT_URL=https://api.steampowered.com  # optional, this is the default
MY_STEAM_ID=76561197960435530                    # optional, see below for more info
```

## Usage

```ruby
require "steam_api_client"

# Find a user by their profile name (Valve calls this the "Vanity URL")
user = SteamApiClient::SteamUser.from_username("robinwalker")

# ...or by Steam ID
user = SteamApiClient::SteamUser.new(steam_id: "76561197960435530")

# Owned games (with app info and playtimes)
user.games.each do |game|
  puts "#{game.name} — #{game.total_playtime / 60}h total"
end

# Achievements & stats for a specific game
# Works with either an app_id or an app_name
# App name is a little less reliable because it uses a naive matching algorithm:
user.achievements_for(app_name: "Half-Life 2")
user.stats_for(app_id: 440)

# Recent activity, wishlist, friends, bans, groups, and profile
user.recently_played(limit: 5)
user.wishlist
user.friends
user.bans
user.groups
user.profile

# Games a user is following in the store
user.followed_games

# Batch-fetch profiles for many Steam IDs
SteamApiClient::SteamUser.profiles_for(steam_ids: ["7656...", "7656..."])

# Also supports some more complex "joins" so you don't
# have to think too much about the API contract itself:
user.friends.first.steam_user.games.last.news
```

Results are returned as small model objects (`UserOwnedGame`, `UserProfile`, `UserWishlistItem`, `UserFriends`, etc) with readable attributes, so you get:

```ruby
game.name            # "Half-Life 2"
game.total_playtime  # 7200 (seconds)
game.last_played_at  # a real Time
game.news            # latest news posts for the game
```

### Caching

Responses are memoized per user for the lifetime of the object. Call `user.bypass_cache!` to force fresh data from the API, or `user.enable_cache!` to switch back to memoized results.

### Rate Limiting

User Beware: Valve has a maximum rate limit of 100,000 calls per day and this gem does not currently enforce this limit.

### User-Agent String

This gem sends a User-Agent header along with every request to the Steam Web API. It will look like this:

```bash
-H "User-Agent: steam-api-client-ruby/v0.0.1 (+ your-domain.com)"
```

Where `v0.0.1` is sourced from `SteamApiClient::Version::VERSION` and `your-domain.com` is sourced from `ENV["STEAM_API_KEY_DOMAIN"]`. Be sure to set that `.env` value, per the Steam Web API's ToS.

## Architecture

```
SteamUser (high-level facade)
  └── Resources  (thin wrappers around each Steam API service)
        ├── IPlayerService, ISteamUser, ISteamUserStats,
        ├── ISteamNews, IStoreService, IWishlistService, ISteamWebApiUtil
        └── Models (typed objects built from API responses)
```

All requests flow through a shared `Connection` (Faraday) that injects your API key automatically.

## Development

```bash
bin/test    # run the test suite (default rake task)
bin/lint    # run RuboCop
bin/console # start an IRB console with the library loaded
```

### IRB Console
To make development a little easier the IRB console will inject a memoized `my_user` method if `MY_STEAM_ID` is passed into the console ENV. This is most easily achieved by adding the ID to your copy of the provided `.env` file (e.g. as `.env.development.local`).  You can invoke it from the IRB session automatically like this:

```ruby
my_user.games
=> [game1, game2, ...]
```

## Status

Work in progress (v0.0.1). A few endpoints are rough around the edges — `friends` can hit Steam 401 errors, and `wishlist`/`followed_games`/`groups` return minimal data for now. See `TODO.md` for planned improvements (rate limiting, etc.).

## License

Released under the [GNU GPL v3](LICENSE.md).
