# CHANGELOG

## Unreleased Changes

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
