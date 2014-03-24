require "frenchy"
require "frenchy/request"

module Frenchy
  module Resource
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Find record(s) using the default endpoint and flexible input
      def find(params={})
        params = {id: params.to_s} if [Fixnum, String].any? {|c| params.is_a? c }
        find_with_endpoint(:default, params)
      end

      # Find a single record using the "one" (or "default") endpoint and an id
      def find_one(id, params={})
        find_with_endpoint([:one, :default], {id: id}.merge(params))
      end

      # Find multiple record using the "many" (or "default") endpoint and an array of ids
      def find_many(ids, params={})
        find_with_endpoint([:many, :default], {ids: ids.join(",")}.merge(params))
      end

      # Find with a specific endpoint and params
      def find_with_endpoint(endpoints, params={})
        name, endpoint = resolve_endpoints(endpoints)
        method = (endpoint[:method] || :get).to_sym
        options = {model: self.name.underscore, endpoint: name.to_s}
        response = Frenchy::Request.new(@service, method, endpoint[:path], params, options).value

        if response.is_a?(Array)
          Frenchy::Collection.new(Array(response).map {|v| from_hash(v) })
        else
          from_hash(response)
        end
      end

      private

      # Choose the first available endpoint
      def resolve_endpoints(endpoints)
        Array(endpoints).map(&:to_sym).each do |sym|
          if ep = @endpoints[sym]
            return sym, ep
          end
        end

        raise(Frenchy::ConfigurationError, "Resource does not contain any endpoints: #{endpoints.join(", ")}")
      end

      # Macro to set the location pattern for this request
      def resource(options={})
        options.symbolize_keys!

        @service = options.delete(:service) || raise(Frenchy::ConfigurationError, "Resource must specify a service")

        if endpoints = options.delete(:endpoints)
          @endpoints = validate_endpoints(endpoints)
        elsif endpoint = options.delete(:endpoint)
          @endpoints = validate_endpoints({default: endpoint})
        else
          raise(Frenchy::ConfigurationError, "Resource must specify one or more endpoint")
        end

        @many = options.delete(:many) || false
      end

      def validate_endpoints(endpoints={})
        endpoints.symbolize_keys!

        Hash[endpoints.map do |k,v|
          v.symbolize_keys!
          raise(Frenchy::ConfigurationError, "Endpoint #{k} does not specify a path") unless v[:path]
          [k,v]
        end]
      end
    end
  end
end
