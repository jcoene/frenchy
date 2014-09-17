require "spec_helper"

class GithubUser
  include Frenchy::Model
  include Frenchy::Resource

  resource  service: "github",
            endpoints: {
              default:  { method: "get", path: "/users/:id" },
              one:      { method: "get", path: "/users/:id" },
              many:     { method: "get", path: "/users" },
              search:   { method: "get", path: "/search/users", many: true, nesting: "items" },
            }

  field :login, type: "string"
  field :id, type: "integer"
  field :html_url, type: "string"
end

describe Frenchy::Resource do
  describe ".find" do
    it "finds a single object with a single string parameter (id substitution)" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      user = GithubUser.find("jcoene")
      expect(user.class).to eql(GithubUser)
      expect(user.id).to eql(283933)
    end

    it "raises a Frenchy::NotFound error for 404 responses" do
      Frenchy.register_service("github", {"host" => "https://github.com"})
      expect{GithubUser.find("jcoene1234abcd")}.to raise_error(Frenchy::NotFound)
    end

    it "finds a single object with parameters hash" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      user = GithubUser.find(id: "jcoene")
      expect(user.class).to eql(GithubUser)
      expect(user.id).to eql(283933)
    end
  end

  describe ".find_one" do
    it "finds a single object with id" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      user = GithubUser.find_one("jcoene")
      expect(user.class).to eql(GithubUser)
      expect(user.id).to eql(283933)
    end
  end

  describe ".find_many" do
    it "finds many objects with ids" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      users = GithubUser.find_many(["ignored"])
      expect(users.class).to eql(Frenchy::Collection)
      expect(users.any?).to eql(true)
    end
  end

  describe ".find_with_endpoint" do
    it "finds a single object with endpoint and params" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      user = GithubUser.find_with_endpoint(:default, id: "jcoene")
      expect(user.class).to eql(GithubUser)
      expect(user.id).to eql(283933)
    end

    it "finds many objects with endpoint and params (and nesting!)" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      users = GithubUser.find_with_endpoint(:search, q: "jcoene")
      expect(users.class).to eql(Frenchy::Collection)
      expect(users.first.class).to eql(GithubUser)
      expect(users.any?).to eql(true)
    end
  end
end