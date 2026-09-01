# frozen_string_literal: true

module SteamApiClient
  module Refinements
    module IntegerRefinements
      refine Integer do
        def minutes_as_human_readable_time
          remaining = self
          units = [[1_440, :days], [60, :hours], [1, :minutes]]

          units.filter_map do |minutes, name|
            value, remaining = remaining.divmod(minutes)
            next if value.zero?

            "#{value} #{value == 1 ? name.to_s.delete_suffix('s') : name}"
          end.join(", ")
        end
      end
    end
  end
end
