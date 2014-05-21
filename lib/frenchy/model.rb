module Frenchy
  module Model
    def self.included(base)
      base.class_eval do
        cattr_accessor :fields, :defaults

        self.fields = {}
        self.defaults = {}
      end

      base.extend(ClassMethods)
    end

    # Create a new instance of this model with the given attributes
    def initialize(attrs={})
      self.class.defaults.merge(attrs).each do |k,v|
        if self.class.fields[k.to_sym]
          send("#{k}=", v)
        end
      end
    end

    # Return a hash of field name as string and value pairs
    def attributes
      Hash[self.class.fields.map {|k,_| [k.to_s, send(k)]}]
    end

    # Return a string representing the value of the model instance
    def inspect
      "<#{self.class.name} #{attributes.map {|k,v| "#{k}: #{v.inspect}"}.join(", ")}>"
    end

    # Decorate the model using a decorator inferred by the class
    def decorate
      decorator_class = "#{self.class.name}Decorator".constantize
      decorator_class.decorate(self)
    end

    protected

    def set(name, value, options={})
      instance_variable_set("@#{name}", value)
    end

    module ClassMethods
      # Create a new instance of the model from a hash
      def from_hash(hash)
        new(hash)
      end

      # Create a new instance of the model from JSON
      def from_json(json)
        hash = JSON.parse(json)
        from_hash(hash)
      end

      protected

      # Macro to add primary key
      def key(name)
        define_method(:to_param) do
          send(name).to_s
        end
      end

      # Macro to add a field
      def field(name, options={})
        type = (options[:type] || :string).to_sym
        aliases = (options[:aliases] || [])

        aliases.each do |a|
          define_method("#{a}") do
            send(name)
          end
        end

        case type
        when :string
          define_method("#{name}=") do |v|
            set(name, v.to_s, options)
          end
        when :integer
          define_method("#{name}=") do |v|
            set(name, Integer(v), options)
          end
        when :float
          define_method("#{name}=") do |v|
            set(name, Float(v), options)
          end
        when :bool
          define_method("#{name}=") do |v|
            set(name, ["true", 1, true].include?(v), options)
          end
          define_method("#{name}?") do
            send(name)
          end
        when :time
          define_method("#{name}=") do |v|
            if v.is_a?(Fixnum)
              set(name, Time.at(v).to_datetime, options)
            else
              set(name, DateTime.parse(v), options)
            end
          end
        when :array
          options[:default] ||= []
          define_method("#{name}=") do |v|
            set(name, Array(v), options)
          end
        when :hash
          options[:default] ||= {}
          define_method("#{name}=") do |v|
            set(name, Hash[v], options)
          end
        else
          options[:class_name] ||= type.to_s.camelize
          options[:many] = (name.to_s.singularize != name.to_s) unless options.key?(:many)
          klass = options[:class_name].constantize

          define_method("#{name}=") do |v|
            if options[:many]
              options[:default] ||= []
              set(name, Frenchy::Collection.new(Array(v).map {|vv| klass.new(vv)}))
            else
              set(name, klass.new(v))
            end
          end
        end

        self.fields[name.to_sym] = options

        if options[:default]
          self.defaults[name.to_sym] = options[:default]
        end

        attr_reader name.to_sym
      end
    end
  end
end
