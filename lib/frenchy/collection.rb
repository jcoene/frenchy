module Frenchy
  class ArrayDecorator
    def self.decorate_collection(object, options={})
      object.to_a
    end
  end

  class Collection < ::Array
    # Decorate the collection using the name of the decorator inferred by the first record
    def decorate(options={})
      return self if none?

      decorator_class.decorate_collection(self, options)
    end

    # Compatbility for associations in draper
    def decorator_class
      return Frenchy::ArrayDecorator if none?

      "#{first.class.name}Decorator".constantize
    end
  end
end
