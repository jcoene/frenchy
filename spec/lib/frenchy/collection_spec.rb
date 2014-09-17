require "spec_helper"

class MyModel
  include Frenchy::Model
end

class MyModelDecorator
  def self.decorate_collection(collection, options={})
    return "DECORATED"
  end
end

describe Frenchy::Collection do
  describe "#decorate" do
    describe "when there are no items" do
      it "returns an empty array" do
        coll = Frenchy::Collection.new
        expect(coll.decorate).to eql([])
      end
    end

    describe "when there are model items" do
      it "decorates using the named convention" do
        m1 = MyModel.new
        m2 = MyModel.new
        coll = Frenchy::Collection.new([m1, m2])
        expect(coll.decorate).to eql("DECORATED")
      end

      it "supports a hash of options" do
        m1 = MyModel.new
        m2 = MyModel.new
        coll = Frenchy::Collection.new([m1, m2])
        expect(coll.decorate({"a" => 1})).to eq("DECORATED") # test arity
      end
    end
  end
end