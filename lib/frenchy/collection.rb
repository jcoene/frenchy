module Frenchy
  class Collection < ::Array
    # Decorate the collection using the name of the decorator inferred by the first record
    def decorate(options={})
      return self if none?

      if decorator_class.respond_to?(:decorate_collection)
        decorator_class.decorate_collection(self)
      else
        decorator_class.decorate(self)
      end
    end

    # Compatbility for associations in draper
    def decorator_class
      "#{first.class.name}Decorator".constantize
    end

    # Backwards compatibility for old version of draper
    def nil?
      none?
    end
  end
end
