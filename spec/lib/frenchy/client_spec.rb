require "spec_helper"

describe Frenchy::Client do
  describe "#initialize" do
    it "uses expected defaults" do
      client = Frenchy::Client.new
      expect(client.host).to eql("http://127.0.0.1:8080")
      expect(client.timeout).to eql(30)
      expect(client.retries).to eql(0)
    end

    it "accepts an options hash" do
      client = Frenchy::Client.new({"host" => "http://127.0.0.1:1234", "timeout" => 15, "retries" => 3})
      expect(client.host).to eql("http://127.0.0.1:1234")
      expect(client.timeout).to eql(15)
      expect(client.retries).to eql(3)
    end

    it "accepts an options hash (symbols)" do
      client = Frenchy::Client.new(host: "http://127.0.0.1:1234", timeout: 15, retries: 3)
      expect(client.host).to eql("http://127.0.0.1:1234")
      expect(client.timeout).to eql(15)
      expect(client.retries).to eql(3)
    end
  end
end