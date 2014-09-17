require "spec_helper"

class FakeModel
  include Frenchy::Veneer

  veneer model: "real_model"
end

describe Frenchy::Veneer do
  describe ".model_name" do
    it "returns an instance of ActiveModel::Name" do
      expect(FakeModel.model_name).to be_an_instance_of(ActiveModel::Name)
    end

    it "provides the expected model name" do
      expect(FakeModel.model_name.to_s).to eql("RealModel")
    end
  end
end