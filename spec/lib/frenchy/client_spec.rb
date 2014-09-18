require "spec_helper"

describe Frenchy::Client do
  describe "#initialize" do
    it "uses expected defaults" do
      client = Frenchy::Client.new("default")
      expect(client.host).to eql("http://127.0.0.1:8080")
      expect(client.timeout).to eql(30)
      expect(client.retries).to eql(0)
    end

    it "accepts an options hash" do
      client = Frenchy::Client.new("default", {"host" => "http://127.0.0.1:1234", "timeout" => 15, "retries" => 3})
      expect(client.host).to eql("http://127.0.0.1:1234")
      expect(client.timeout).to eql(15)
      expect(client.retries).to eql(3)
    end

    it "accepts an options hash (symbols)" do
      client = Frenchy::Client.new("default", host: "http://127.0.0.1:1234", timeout: 15, retries: 3)
      expect(client.host).to eql("http://127.0.0.1:1234")
      expect(client.timeout).to eql(15)
      expect(client.retries).to eql(3)
    end
  end

  ["patch", "post", "put", "delete"].each do |method|
    describe "##{method}" do
      it "returns a successful response containing the request json data" do
        client = Frenchy::Client.new("httpbin", "host" => "http://httpbin.org")
        data = {"data" => "abcd", "number" => 1, "nested" => {"more" => "data"}}
        expect = JSON.generate(data)
        result = client.send(method, "/#{method}", data)
        expect(result).to be_an_instance_of(Hash)
        expect(result["data"]).to eql(expect)
      end
    end
  end

  describe "#perform" do
    it "returns a hash for successful json response" do
      client = Frenchy::Client.new("httpbin", "host" => "http://httpbin.org")
      result = client.get("/ip", {})
      expect(result).to be_an_instance_of(Hash)
      expect(result.keys).to eql(["origin"])
    end

    it "raises an invalid response error for non-json response" do
      client = Frenchy::Client.new("httpbin", "host" => "http://httpbin.org")
      expect{client.get("/html", {})}.to raise_error(Frenchy::InvalidResponse)
    end

    it "raises a not found error for 404 responses" do
      client = Frenchy::Client.new("httpbin", "host" => "http://httpbin.org")
      expect{client.get("/status/404", {})}.to raise_error(Frenchy::NotFound)
    end

    it "raises a service unavailable error for 500+ responses" do
      client = Frenchy::Client.new("httpbin", "host" => "http://httpbin.org")
      expect{client.get("/status/500", {})}.to raise_error(Frenchy::ServiceUnavailable)
    end
  end
end