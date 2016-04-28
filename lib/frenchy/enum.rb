module Frenchy
  module Enum
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        @enums = {}
        @default = nil
      end
    end

    attr_accessor :name, :tag

    def initialize(attrs={})
      attrs.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def inspect
      "\#<#{self.class.name}::#{name}=#{tag}>"
    end

    def to_i
      tag
    end

    def to_str
      to_s
    end

    def to_sym
      name
    end

    def to_s
      name.to_s.underscore
    end

    def ==(other)
      (other.is_a?(Symbol) && (name == other)) ||
      (other.respond_to?(:to_i) && (other.to_i == tag)) ||
      (other.respond_to?(:to_s) && (other.to_s == to_s || other.to_s == name.to_s)) ||
      super
    end

    module ClassMethods
      def define(name, tag, options={})
        name = name.to_sym
        tag = tag.to_i
        options.stringify_keys!

        enum = new(name: name, tag: tag)
        const_set(name, enum)
        @enums[tag] = enum

        if options["default"]
          @default = tag
        end
      end

      def default
        @enums[@default]
      end

      def find(tag)
        @enums[tag.to_i] || default
      end
    end
  end
end