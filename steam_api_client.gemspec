# frozen_string_literal: true

require "pathname"
require_relative "lib/steam_api_client/version"

Gem::Specification.new do |spec|
  spec.name          = "steam_api_client"
  spec.version       = SteamApiClient::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Kmagameguy"]
  spec.description   = "Query the Steam API with Ruby"
  spec.summary       = "A Ruby client for the Steam Web API"
  spec.homepage      = "https://github.com/kmagameguy/steam_web_api"

  spec.files         = Dir.glob(Pathname.new(__dir__).join("lib/**/**")).reject do |file|
    file.match(%r{^(test)/}) || File.directory?(file)
  end

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{(^bin/)}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency("faraday")
end
