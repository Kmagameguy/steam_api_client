# frozen_string_literal: true

module SteamApiClient
  module Models
    module Concerns
      module TimeCastable
        def cast_to_time(epoch)
          return Time.at(epoch) unless epoch.to_i.zero? || epoch.nil?

          nil
        end
      end
    end
  end
end
