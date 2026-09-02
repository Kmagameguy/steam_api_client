# frozen_string_literal: true

require "bundler"
require "dotenv"
Bundler.require :development, :test

require "steam_api_client"
require "minitest/autorun"
require "minitest/spec"
require "minitest/stub_const"
require "mocha/minitest"
require "vcr"

Dotenv.load(".env.test.local", ".env.test", ".env.local", ".env")

# If .env* isn't configured with real api keys / domains then we stub them for the tests.
# To make real VCR requests, though, you'll have to use real credentials.
if ENV["STEAM_API_KEY"].to_s.strip.empty? || ENV["STEAM_API_KEY"] == "secret"
  ENV["STEAM_API_KEY"] = "TEST00000000000000000000"
end

if ENV["STEAM_API_KEY_DOMAIN"].to_s.strip.empty? || ENV["STEAM_API_KEY_DOMAIN"] == "your-domain.com"
  ENV["STEAM_API_KEY_DOMAIN"] = "example.com"
end

Bundler.setup(:default, :test)

VCR.configure do |vcr|
  vcr.cassette_library_dir = "test/cassettes"
  vcr.hook_into :webmock
  vcr.allow_http_connections_when_no_cassette = true
  vcr.default_cassette_options = {
    record: :once,
    match_requests_on: %i[method host path query]
  }
  vcr.filter_sensitive_data("<STEAM_API_KEY>") { ENV.fetch("STEAM_API_KEY", nil) }
  vcr.filter_sensitive_data("<STEAM_API_DOMAIN>") { ENV.fetch("STEAM_API_DOMAIN", nil) }
  vcr.filter_sensitive_data("<MY_STEAM_ID>") { ENV.fetch("MY_STEAM_ID", nil) }
end

# Convenience method to set ENV vars without leaking the changes
# between tests. Usage:
#
#   with_env("STEAM_API_KEY" => "something", "STEAM_API_ROOT_URL" => nil) do
#     ...
#   end
#
# Original values (or absence of them) will be reset after exiting the block,
# even if it raises.
module EnvHelpers
  def with_env(vars)
    originals = vars.each_key.to_h { |k| [k, ENV[k]] }
    vars.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
    yield
  ensure
    originals.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end
end

Minitest::Test.include(EnvHelpers)
