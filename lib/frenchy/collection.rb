module Frenchy
  class Collection < ::Array
    # Decorate the collection using the name of the decorator inferred by the first record
    def decorate
      decorator_class = "#{first.class.name}Decorator".constantize
      decorator_class.decorate(self)
    end

    # Backwards compatibility for old version of draper
    def nil?
      none?
    end
  end
end
