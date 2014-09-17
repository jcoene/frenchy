require "spec_helper"

class SimpleModel
  include Frenchy::Model

  field :id, type: "integer"
  field :name, type: "string", default: "unknown"
  field :occupation, type: "string"
end

class SpecialItem
  include Frenchy::Model

  field :id, type: "integer"
end

class SuperSpecialItem
  include Frenchy::Model

  field :id, type: "integer"
end

class Box
  include Frenchy::Model

  field :id, type: "integer"
  field :name, type: "string"
  field :gpa, type: "float", aliases: [:grade, :grade_point_average]
  field :happy, type: "bool"
  field :birth, type: "time"
  field :aliases, type: "array"
  field :extras, type: "hash"

  field :item, type: "special_item"
  field :items, type: "special_item", many: true
  field :special, type: "special_item", class_name: "SuperSpecialItem"
end

class SimpleModelDecorator
  def self.decorate(object, options={})
    "DECORATED"
  end
end

describe Frenchy::Model do
  describe "#initialize" do
    it "assigns given attributes" do
      model = SimpleModel.new(id: 1, name: "bob")
      expect(model.id).to eq(1)
      expect(model.name).to eq("bob")
    end

    it "assigns defaults when attributes are missing" do
      model = SimpleModel.new(id: 1)
      expect(model.name).to eq("unknown")
    end
  end

  describe "#attributes" do
    it "includes all attributes, present or not" do
      model = SimpleModel.new(id: 1)
      expect(model.attributes).to eq({"id" => 1, "name" => "unknown", "occupation" => nil})
    end
  end

  describe "#decorate" do
    it "decorates the model using the named convention" do
      model = SimpleModel.new
      expect(model.decorate).to eq("DECORATED")
    end

    it "supports a hash of options" do
      model = SimpleModel.new
      expect(model.decorate({"a" => 1})).to eq("DECORATED") # test arity
    end
  end

  describe ".field" do
    describe "aliases" do
      it "aliases fields" do
        m = Box.new(gpa: 5.0)
        expect(m.gpa).to eql(5.0)
        expect(m.grade).to eql(5.0)
        expect(m.grade_point_average).to eql(5.0)
      end
    end

    describe "string" do
      it "converts values to a String" do
        expect(Box.new(name: 1234).name).to eql("1234")
      end
    end

    describe "integer" do
      it "converts values to an Integer" do
        expect(Box.new(id: "1234").id).to eql(1234)
      end

      it "raises an error with invalid values" do
        expect{Box.new(id: "a")}.to raise_error(ArgumentError)
      end
    end

    describe "float" do
      it "converts values to a Float" do
        expect(Box.new(gpa: "1").gpa).to eql(1.0)
      end

      it "raises an error with invalid values" do
        expect{Box.new(gpa: "a")}.to raise_error(ArgumentError)
      end
    end

    describe "bool" do
      it "converts truthy values to true" do
        ["true", "1", 1, true].each do |v|
          expect(Box.new(happy: v).happy).to eql(true)
        end
      end

      it "converts non-truthy values to false" do
        ["false", "0", 0, false].each do |v|
          expect(Box.new(happy: v).happy).to eql(false)
        end
      end
    end

    describe "time" do
      it "converts unix timestamps to DateTime" do
        v = Box.new(birth: 1234567890).birth
        expect(v.class).to eql(DateTime)
        expect(v.to_time.to_i).to eql(1234567890)
        expect(v.year).to eql(2009)
      end

      it "converts strings DateTime" do
        dt = DateTime.new(2011,2,3,4,5,6)
        v = Box.new(birth: dt.to_s).birth
        expect(v.class).to eql(DateTime)
        expect(v.to_time.to_i).to eql(1296705906)
        expect(v.year).to eql(2011)
      end
    end

    describe "array" do
      it "defaults to []" do
        v = Box.new.aliases
        expect(v.class).to eql(Array)
        expect(v).to eql([])
      end

      it "stores arrays as is" do
        v = Box.new(aliases: ["chuck", "charles"]).aliases
        expect(v).to eql(["chuck", "charles"])
      end

      it "wraps singualr values in an array" do
        v = Box.new(aliases: "chuck").aliases
        expect(v).to eql(["chuck"])
      end
    end

    describe "hash" do
      it "defaults to {}" do
        v = Box.new.extras
        expect(v.class).to eql(Hash)
        expect(v).to eql({})
      end

      it "stores hashes as is" do
        v = Box.new(extras: {"a" => 1, "b" => 2}).extras
        expect(v).to eql({"a" => 1, "b" => 2})
      end

      it "converts nested array values to a hash" do
        v = Box.new(extras: [["type", "person"], ["pet", "dog"]]).extras
        expect(v).to eql({"type" => "person", "pet" => "dog"})
      end
    end

    describe "model relationships" do
      it "establishes single model relationships" do
        v = Box.new(item: {id: 1}).item
        expect(v).to be_an_instance_of(SpecialItem)
        expect(v.id).to eql(1)
      end

      it "supports explicit class name" do
        v = Box.new(special: {id: 1}).special
        expect(v).to be_an_instance_of(SuperSpecialItem)
        expect(v.id).to eql(1)
      end

      it "establishes many model relationships" do
        v = Box.new(items: [{id: 1}, {id: 2}]).items
        expect(v).to be_an_instance_of(Frenchy::Collection)
        expect(v[0]).to be_an_instance_of(SpecialItem)
        expect(v[0].id).to eql(1)
        expect(v[1]).to be_an_instance_of(SpecialItem)
        expect(v[1].id).to eql(2)
      end
    end
  end
end