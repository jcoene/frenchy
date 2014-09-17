require "spec_helper"

describe Frenchy do
  describe ".register_service" do
    it "registers the service in the module" do
      Frenchy.register_service("github", {"host" => "https://api.github.com"})
      client = Frenchy.find_service("github")
      expect(client).to be_an_instance_of(Frenchy::Client)
      expect(client.host).to eql("https://api.github.com")
    end
  end

  describe ".find_service" do
    it "raises an error for missing services" do
      expect{Frenchy.find_service("nonexistent")}.to raise_error(Frenchy::Error)
    end
  end
end