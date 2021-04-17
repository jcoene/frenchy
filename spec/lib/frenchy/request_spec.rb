require "spec_helper"

describe Frenchy::Request do
  describe "path substitution" do
    it "substitutes path parameters" do
      request = Frenchy::Request.new("service", "get", "/v1/users/:id/:token", {"id" => 1234, "token" => "md5something"}, {})
      expect(request.path).to eql("/v1/users/1234/md5something")
    end

    it "escapes path parameters but not query params" do
      request = Frenchy::Request.new("service", "get", "/v1/users/:slug/:fullname", {"slug" => "big dog 20", "fullname" => "How Big Is He?", "division" => "How Big Is He, Really?"}, {})
      expect(request.path).to eql("/v1/users/big+dog+20/How+Big+Is+He%3F")
      expect(request.params).to eql({"division" => "How Big Is He, Really?"})
    end

    it "retains remaining parameters as query parameters" do
      request = Frenchy::Request.new("service", "get", "/v1/users/:id", {"id" => 1234, "token" => "md5something"}, {})
      expect(request.path).to eql("/v1/users/1234")
      expect(request.params).to eql({"token" => "md5something"})
    end

    it "raises an error for missing path parameters" do
      expect do
        Frenchy::Request.new("service", "get", "/v1/users/:id/:token", {"id" => 1234}, {})
      end.to raise_error(Frenchy::Error)
    end
  end
end