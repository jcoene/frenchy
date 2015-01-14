require "spec_helper"

class FakeModel
  include Frenchy::Model
  include Frenchy::Veneer

  veneer model: "real_model"

  key :id

  field :id, type: "integer"
end

class FakeModelTwo
  include Frenchy::Model
  include Frenchy::Veneer
  veneer model: "real_model_two"
  field :id, type: "integer"
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

  describe ".table_name" do
    it "provides the expected table name" do
      expect(FakeModel.table_name).to eql("real_models")
    end
  end

  describe "#record_key" do
    it "provides the expected key when new" do
      expect(FakeModel.new.record_key).to eql("real_models/")
    end

    it "provides the expected key when existing" do
      expect(FakeModel.new({id: 12345}).record_key).to eql("real_models/12345")
    end

    it "raises an error when no to_param is available" do
      expect do
        FakeModelTwo.new({id: 12345}).record_key
      end.to raise_error(Frenchy::Error)
    end
  end
end