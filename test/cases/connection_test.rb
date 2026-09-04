# frozen_string_literal: true

require "test_helper"

module SteamApiClient
  class ConnectionTest < Minitest::Spec
    let(:subject) { SteamApiClient::Connection.instance }

    describe "#initialize" do
      it "exposes config as a field" do
        assert_kind_of SteamApiClient::Config, subject.config
      end

      it "acts as a singleton" do
        assert_raises(NoMethodError) { SteamApiClient::Connection.new }
      end
    end

    describe "#get" do
      it "adds the API key to the request parameters" do
        params = { include_games: false, max_results: 5 }

        http_connection = mock
        http_connection.expects(:get)
                       .with("/IStoreService/GetAppList/v1/", params.merge(key: ENV["STEAM_API_KEY"]))
                       .returns(:response)

        subject.stubs(:connection).returns(http_connection)

        result = subject.get("/IStoreService/GetAppList/v1/", params)

        assert_equal :response, result
      end
    end

    describe "#post" do
      it "addst he API key to the request parameters" do
        http_connection = mock
        request = mock

        request.expects(:[]=).with(:key, ENV["STEAM_API_KEY"])
        request.expects(:body=).with({ foo: "bar" })
        http_connection.expects(:post).yields(request).returns(:response)

        subject.stubs(:connection).returns(http_connection)
        result = subject.post("/test", foo: "bar")

        assert_equal :response, result
      end
    end
  end
end
