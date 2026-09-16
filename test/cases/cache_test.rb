# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  class CacheTest < SteamApiClientTest
    describe NullCache do
      let(:subject) { NullCache.new }

      it "yields on every fetch" do
        calls = 0
        subject.fetch("key") { calls += 1 }
        subject.fetch("key") { calls += 1 }

        assert_equal 2, calls
      end

      it "never stores values" do
        subject.write("key", "value")

        assert_nil subject.read("key")
      end

      it "reports delete as a no-op" do
        refute subject.delete("key")
      end

      it "returns nil when clearing" do
        assert_nil subject.clear
      end
    end

    describe MemoryCache do
      let(:subject) { MemoryCache.new }

      describe "#fetch" do
        it "yields and stores the result on a miss" do
          calls = 0
          first = subject.fetch("key") do
            calls += 1
            "value"
          end
          second = subject.fetch("key") do
            calls += 1
            "other"
          end

          assert_equal "value", first
          assert_equal "value", second
          assert_equal 1, calls
        end

        it "caches nil results without re-fetching" do
          calls = 0
          2.times do
            subject.fetch("key") do
              calls += 1
              nil
            end
          end

          assert_equal 1, calls
        end

        it "serves the stored value on a hit" do
          value = "value"
          subject.fetch("key") { value }

          assert_equal value, subject.read("key")
        end

        it "does not expire entries without a TTL" do
          value = "value"
          subject.fetch("key") { value }
          far_future = Time.now + 1_000_000

          Time.stubs(:now).returns(far_future)

          assert_equal value, subject.read("key")
        end

        it "re-fetches once the TTL has passed" do
          subject.fetch("key", expires_in: 5) { "first" }
          expired_at = Time.now + 10

          Time.stubs(:now).returns(expired_at)

          assert_equal "second", subject.fetch("key", expires_in: 5) { "second" }
        end
      end

      describe "#write / #read" do
        it "stores and returns the value" do
          subject.write("key", "value")

          assert_equal "value", subject.read("key")
        end

        it "respects the expiry" do
          subject.write("key", "value", expires_in: 5)
          expired_at = Time.now + 10

          Time.stubs(:now).returns(expired_at)

          assert_nil subject.read("key")
        end
      end

      describe "#delete" do
        it "removes an existing entry" do
          subject.write("key", "value")

          assert subject.delete("key")
          assert_nil subject.read("key")
        end

        it "returns false for a missing entry" do
          refute subject.delete("nope")
        end
      end

      describe "#clear" do
        it "removes all entries" do
          subject.write("a", 1)
          subject.write("b", 2)
          subject.clear

          assert_nil subject.read("a")
          assert_nil subject.read("b")
        end
      end
    end

    describe "SteamApiClient.cache" do
      it "defaults to a NullCache" do
        assert_instance_of NullCache, SteamApiClient.cache
      end

      it "accepts any cache with a compatible interface" do
        custom = MemoryCache.new
        SteamApiClient.cache = custom

        assert_same custom, SteamApiClient.cache
      ensure
        SteamApiClient.cache = NullCache.new
      end
    end
  end
end
