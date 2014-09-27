require "spec_helper"

class Bin
  include Frenchy::Model
  include Frenchy::Resource

  resource  service: "httpbin",
            endpoints: {
              default:  { method: "get", path: "/get" },
              one:      { method: "get", path: "/get" },
              many:     { method: "get", path: "/get" },
              search:   { method: "get", path: "/get" },
            }

  field :args, type: "hash"
  field :headers, type: "hash"
  field :origin, type: "string"
  field :url, type: "string"
end

class BinOneEndpoint
  include Frenchy::Model
  include Frenchy::Resource

  resource  service: "httpbin", endpoint: { path: "/get" }

  field :args, type: "hash"
end

class BinNoEndpoints
  include Frenchy::Model
  include Frenchy::Resource

  resource service: "httpbin"

  field :id, type: "string"
end

class BinArgs
  include Frenchy::Model
  include Frenchy::Resource

  resource  service: "httpbin",
            endpoints: {
              nested:  { method: "get", path: "/get", nesting: "args" },
            }

  field :my_arg, type: "string"
end

describe Frenchy::Resource do
  before :all do
    Frenchy.register_service("httpbin", {"host" => "http://httpbin.org"})
  end

  describe ".find" do
    it "finds a single object with a single string parameter (id substitution)" do
      resp = Bin.find("a")
      expect(resp.args["id"]).to eql("a")
    end

    it "finds a single object with a parameters hash" do
      resp = Bin.find(id: "a")
      expect(resp.args["id"]).to eql("a")
    end
  end

  describe ".find_one" do
    it "finds a single object with id" do
      resp = Bin.find_one("a")
      expect(resp.args["id"]).to eql("a")
    end
  end

  describe ".find_many" do
    it "finds many objects with ids" do
      resp = Bin.find_many(["a", "b", "c"])
      expect(resp.args["ids"]).to eql("a,b,c")
    end
  end

  describe ".find_with_endpoint" do
    it "finds a single object with endpoint and params" do
      resp = Bin.find_with_endpoint(:default, a: 1, b: 2)
      expect(resp.args).to eql({"a" => "1", "b" => "2"})
    end

    it "finds a single object with a single endpoint and params" do
      resp = BinOneEndpoint.find_with_endpoint(:default, a: 1, b: 2)
      expect(resp.args).to eql({"a" => "1", "b" => "2"})
    end

    it "finds a single object with a nested endpoint and params" do
      resp = BinArgs.find_with_endpoint(:nested, my_arg: "dataz")
      expect(resp).to be_an_instance_of(BinArgs)
      expect(resp.my_arg).to eql("dataz")
    end

    it "raises an exception if there are no endpoints" do
      expect do
        BinNoEndpoints.find_with_endpoint(:nonexist, myarg: "mydata")
      end.to raise_exception(Frenchy::Error)
    end

    it "includes the under_score model name in extras" do
      response = double("Frenchy::Request", value: {})

      expect(Frenchy::Request).
        to receive(:new).
        with("httpbin", "get", "/get", {"id" => 1}, {"model" => "bin_one_endpoint", "endpoint" => "default"}).
        and_return(response)

      BinOneEndpoint.find_with_endpoint(:default, id: 1)
    end
  end
end