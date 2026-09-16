# frozen_string_literal: true

module SteamApiClient
  class NullCache
    def fetch(_key, **_options)
      yield
    end

    def read(_key)
      nil
    end

    def write(_key, _value, **_options)
      false
    end

    def delete(_key)
      false
    end

    def clear
      nil
    end
  end

  class MemoryCache
    Entry = Struct.new(:value, :expires_at)

    def initialize
      @store = {}
      @mutex = Mutex.new
    end

    def fetch(key, expires_in: nil)
      entry = live_entry(key)
      return entry.value if entry

      result = yield

      @mutex.synchronize { @store[key] = Entry.new(result, expiry(expires_in)) }
      result
    end

    def read(key)
      live_entry(key)&.value
    end

    def write(key, value, expires_in: nil)
      @mutex.synchronize { @store[key] = Entry.new(value, expiry(expires_in)) }
      true
    end

    def delete(key)
      @mutex.synchronize { !@store.delete(key).nil? }
    end

    def clear
      @mutex.synchronize { @store.clear }
      nil
    end

    private

    def live_entry(key)
      @mutex.synchronize do
        entry = @store[key]
        return entry if entry && !expired?(entry)

        @store.delete(key) if entry
        nil
      end
    end

    def expired?(entry)
      !entry.expires_at.nil? && entry.expires_at <= Time.now
    end

    def expiry(expires_in)
      expires_in && (Time.now + expires_in)
    end
  end
end
