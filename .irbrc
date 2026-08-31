require "bundler"
require "dotenv"
Dotenv.load(".env.development.local", ".env")
Bundler.require(:default, :development)

steam_id = ENV["MY_STEAM_ID"].to_s.strip

unless steam_id.empty?
  def my_user
    @my_user ||= SteamApiClient::SteamUser.new(steam_id: ENV["MY_STEAM_ID"])
  end
end
