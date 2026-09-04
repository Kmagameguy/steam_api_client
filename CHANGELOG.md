# CHANGELOG

## Unreleased Changes

## v0.0.5
### Breaking Changes
- `Models::GameNews#tag` is now `Models::GameNews#tags`.
- `Resources::*` class error messages are now a proper string instead of a fake hash.
- `Resources::ISteamUser` and `SteamUser` now raise a `PrivateResourceError` if a user's friend list is private.
- `Resources::ISteamUser#player_profile` now returns `nil` instead of a blank `UserProfile` instance when a player's profile isn't found or configured.
- `Resources::IStoreService` instance methods that require a `steam_id` now all raise `NoSteamIdError` if the provided `steam_id` is `nil`.

### Enhancements
- Add test coverage for `resources/`, along with `connection` and `config`

### Bug Fixes
- `Models::GameNews#tags` are now correctly parsed as an array of values.
- `Resources::IPlayerService` now correctly sets steam_id on instances of `UserOwnedGame`.
- `Resources::IStoreService#app_list` now correctly parses options and only applies overrides when necessary.

## v0.0.4
### Breaking Changes
- `Models::GameAchievementPercentage` has been renamed to `Models::GameGlobalAchievement`.
- `Models::GameGlobalAchievement#value` is now `Models::GameGlobalAchievement#percent_unlocked`.
- `Models::UserOwnedGame#playtime_last_two_weeks_humaized` typo is now fixed: `Models::UserOwnedGame#playtime_last_two_weeks_humanized`

### Enhancements
- `Resources::ISteamUserStats#player_stats_for_game` now merges the user's `steam_id` into the API's JSON response.
- `Models::UserGameStat#steam_id` is now available as a public instance method.
- Add test coverage for `models/`.

### Bug Fixes
- `Models::Game#to_h` and `Models::Game#attributes` now correctly include `mature_content_warnings` instead of crashing.
- `Resources::ISteamUser#player_bans` now correctly returns instances of `Models::UserBan` instead of the plain JSON response.
- `Resources::ISteamUserStats#player_stats_for_game` no longer crashes if the `"stats"` key isn't present in the API's JSON response.
- Several fixes for crashes caused by passing a string value instead of an integer into `Concerns::TimeCastable#cast_to_time`.

## v0.0.3
### Enhancements
- New `IntegerRefinements` on `UserOwnedGame`. Now you can ask to see your playtimes in more human-readable formats:
```ruby
game = my_user.games.max_by(&:linux_playtime)
puts "#{game.name}: #{game.linux_playtime_humanized}"
"Assassin's Creed Valhalla: 4 days, 6 hours, 3 minutes"
=> nil

game = my_user.games.min_by(&:mac_playtime)
puts "#{game.name}: #{game.mac_playtime_humanized}"
"Counter-Strike: never"
=> nil
```

## v0.0.2
This is being released as 0.0.2 but contains a **Breaking Change**. In future this would be handled w/proper semver semantics but I'd still consider this gem in pre-release and I don't want to burn through major versions too early and inadvertently suggest stability where it isn't warranted. So, sticking with patch-increments for now.

### Enhancements
- `game.content_descriptor_ids` has been replaced with `game.mature_content_warnings`; these are string-based enum values now instead of the opaque integers returned by Steam's API.

### Bug Fixes
- Fix broken `ENV` validations in `Config`
- Auto-load the `VERSION` constant
- Fix metadata enumeration

## v0.0.1
Initial API integration. Supports the following API services:
- IPlayerService
- ISteamNews
- ISteamUserStats
- ISteamUser
- ISteamWebApiUtil
- IStoreService
- IWishlistService

```ruby
# You can interface with the API directly, like this:
SteamApiClient::Resources::ISteamnews.new(app_id: 240).news_for_app

# ...or you can use meta-objects like SteamUser to traverse the API like a graph/tree:
my_user = SteamApiClient::SteamUser.from_username("my_username")
my_user.games.first.news
```

See `README.md` for complete setup instructions.
