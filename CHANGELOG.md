# CHANGELOG

## Unreleased Changes

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
