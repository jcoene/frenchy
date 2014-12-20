module Frenchy
  module Model
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        self.fields = {}
        self.defaults = {}
      end

    end

    # Create a new instance of this model with the given attributes
    def initialize(attrs={})
      attrs.stringify_keys!

      self.class.defaults.merge((attrs || {}).reject {|k,v| v.nil? }).each do |k,v|
        if self.class.fields[k]
          send("#{k}=", v)
        end
      end
    end

    # Return a hash of field name as string and value pairs
    def attributes
      Hash[self.class.fields.map {|k,_| [k, send(k)]}]
    end

    # Returns a copy of the model
    def to_model
      self
    end

    # Returns that the model is persisted
    def persisted?
      true
    end

    # Return a string representing the value of the model instance
    def inspect
      "<#{self.class.name} #{attributes.map {|k,v| "#{k}: #{v.inspect}"}.join(", ")}>"
    end

    # Decorate the model using a decorator inferred by the class
    def decorate(options={})
      decorator_class = "#{self.class.name}Decorator".constantize
      decorator_class.decorate(self, options)
    end

    protected

    def set(name, value)
      instance_variable_set("@#{name}", value)
    end

    module ClassMethods

      # Class accessors
      def fields; @fields; end
      def defaults; @defaults; end
      def fields=(value); @fields = value; end
      def defaults=(value); @defaults = value; end

      protected

      # Macro to add primary key
      def key(name)
        define_method(:to_param) do
          send(name).to_s
        end
      end

      # Macro to add a field
      def field(name, options={})
        name = name.to_s
        options.stringify_keys!

        type = (options["type"] || "string").to_s
        aliases = (options["aliases"] || [])

        aliases.each do |a|
          define_method("#{a}") do
            send(name)
          end
        end

        case type
        when "string"
          # Convert value to a String.
          define_method("#{name}=") do |v|
            set(name, String(v))
          end

        when "integer"
          # Convert value to an Integer.
          define_method("#{name}=") do |v|
            set(name, Integer(v))
          end

        when "float"
          # Convert value to a Float.
          define_method("#{name}=") do |v|
            set(name, Float(v))
          end

        when "bool"
          # Accept truthy values as true.
          define_method("#{name}=") do |v|
            set(name, ["true", "1", 1, true].include?(v))
          end

          # Alias a predicate method.
          define_method("#{name}?") do
            send(name)
          end

        when "time"
          # Convert value to a Time or DateTime. Numbers are treated as unix timestamps,
          # other values are parsed with DateTime.parse.
          define_method("#{name}=") do |v|
            if v.is_a?(Fixnum)
              set(name, Time.at(v).to_datetime)
            else
              set(name, DateTime.parse(v))
            end
          end

        when "array"
          # Arrays always have a default of []
          options["default"] ||= []

          # Convert value to an Array.
          define_method("#{name}=") do |v|
            set(name, Array(v))
          end

        when "hash"
          # Hashes always have a default of {}
          options["default"] ||= {}

          # Convert value to a Hash
          define_method("#{name}=") do |v|
            set(name, Hash[v])
          end

        else
          # Unknown types have their type constantized and initialized with the value. This
          # allows us to support things like other Frenchy::Model classes, ActiveRecord models, etc.
          klass = (options["class_name"] || type.camelize).constantize

          # Fields with many values have a default of [] (unless previously set above)
          if options["many"]
            options["default"] ||= []
          end

          # Convert value using the constantized class. Fields with many values are mapped to a
          # Frenchy::Collection containing mapped values.
          define_method("#{name}=") do |v|
            if options["many"]
              set(name, Frenchy::Collection.new(Array(v).map {|vv| klass.new(vv)}))
            else
              if v.is_a?(Hash)
                set(name, klass.new(v))
              else
                set(name, v)
              end
            end
          end
        end

        # Store a reference to the field
        self.fields[name] = options

        # Store a default value if present
        if options["default"]
          self.defaults[name] = options["default"]
        end

        # Create an accessor for the field
        attr_reader name
      end
    end
  end
end
