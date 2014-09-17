require "spec_helper"

class MyOtherClass
  include Frenchy::Model
end

class MyClass
  include Frenchy::Model

  field :other, type: "my_other_class"
end

describe Hash do
  describe "#stringify_keys" do
    it "converts symbol keyed has to string keyed" do
      expect({a: 1, b: 2}.stringify_keys!).to eql({"a" => 1, "b" => 2})
    end
  end
end

describe String do
  describe "#constantize" do
    it "properly constantizes a string" do
      expect("MyClass".constantize).to eql(MyClass)
    end
  end

  describe "#camelize" do
    it "converts under_score to CamelCase" do
      expect("my_class".camelize).to eql("MyClass")
      expect("just_a_model".camelize).to eql("JustAModel")
    end
  end

  describe "#underscore" do
    it "converts CamelCase to under_score" do
      expect("MyClass".underscore).to eql("my_class")
      expect("JustAModel".underscore).to eql("just_a_model")
    end
  end
end

