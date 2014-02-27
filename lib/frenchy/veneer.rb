require "frenchy"
require "active_model/naming"

module Frenchy
  # Veneer provides a friendly face on unfriendly models, allowing your Frenchy
  # models to appear as though they were of another class.
  module Veneer
    def self.included(base)
      if defined?(ActiveModel)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Macro to establish a veneer for a given model
      def veneer(options={})
        options.symbolize_keys!
        @model = options.delete(:model) || raise(Frenchy::ConfigurationError, "Veneer must specify a model")
        extend ActiveModel::Naming

        class_eval do
          def self.model_name
            ActiveModel::Name.new(self, nil, @model.to_s.camelize)
          end
        end
      end
    end
  end
end
