require "spec_helper"

class SimpleEnum
  include Frenchy::Enum

  define :NONE,    0
  define :PARTIAL, 1
  define :FULL,    2
end

class EnumWithDefault
  include Frenchy::Enum

  define :NONE,             0
  define :PARTIAL_SUPPORT,  1
  define :FULL_SUPPORT,     2, default: true
end

describe Frenchy::Enum do
  describe ".default" do
    it "returns the default if set" do
      e = EnumWithDefault.default
      expect(e).to eql(EnumWithDefault::FULL_SUPPORT)
    end

    it "returns nil if not set" do
      e = SimpleEnum.default
      expect(e).to eql nil
    end
  end

  describe ".find" do
    it "finds by tag" do
      e = SimpleEnum.find(1)
      expect(e).to be_an_instance_of(SimpleEnum)
      expect(e.tag).to eql(1)
      expect(e.name).to eql(:PARTIAL)
    end

    it "returns nil when no match is found" do
      e = SimpleEnum.find(5)
      expect(e).to eql(nil)
    end

    it "returns default when no match is found and a default is declared" do
      e = EnumWithDefault.find(5)
      expect(e).to be_an_instance_of(EnumWithDefault)
      expect(e.tag).to eql(2)
      expect(e.name).to eql(:FULL_SUPPORT)
    end
  end

  describe "constants" do
    it "declares constants" do
      e = SimpleEnum::PARTIAL
      expect(e).to be_an_instance_of(SimpleEnum)
      expect(e.tag).to eql(1)
      expect(e.name).to eql(:PARTIAL)

      e = SimpleEnum::FULL
      expect(e).to be_an_instance_of(SimpleEnum)
      expect(e.tag).to eql(2)
      expect(e.name).to eql(:FULL)
    end
  end

  describe "model" do
    it "describes itself" do
      e = SimpleEnum::FULL
      expect(e.inspect).to eql "\#<SimpleEnum::FULL=2>"
    end

    it "== compares equality" do
      e = SimpleEnum::FULL
      e2 = EnumWithDefault::FULL_SUPPORT
      f = SimpleEnum::PARTIAL

      # Separate reference
      expect(e == SimpleEnum::FULL).to eql(true)

      # Comparison by enum
      expect(e == e).to eql(true)

      # Comparison across enum types
      expect(e == e2).to eql(true)
      expect(e == f).to eql(false)

      # Comparison by tag
      expect(e == 2).to eql(true)
      expect(2 == e).to eql(true)

      # Comparison by string
      expect(e == "full").to eql(true)
      expect("full" == e).to eql(true)
      expect(e == "FULL").to eql(true)
      expect("FULL" == e).to eql(true)
    end

    it "#to_i returns the tag" do
      e = SimpleEnum::FULL
      expect(e.to_i).to eql(2)
    end

    it "#to_s returns a lowercase name" do
      e = SimpleEnum::FULL
      expect(e.to_s).to eql("full")
    end

    it "#to_s returns underscore names" do
      e = EnumWithDefault::FULL_SUPPORT
      expect(e.to_s).to eql("full_support")
    end
  end
end