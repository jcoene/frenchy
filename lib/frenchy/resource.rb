module Frenchy
  module Resource
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Find record(s) using the default endpoint and flexible input
      def find(params={})
        params = {"id" => params.to_s} if [Fixnum, String].any? {|c| params.is_a? c }
        find_with_endpoint("default", params)
      end

      # Find a single record using the "one" (or "default") endpoint and an id
      def find_one(id, params={})
        find_with_endpoint(["one", "default"], {"id" => id}.merge(params))
      end

      # Find multiple record using the "many" (or "default") endpoint and an array of ids
      def find_many(ids, params={})
        find_with_endpoint(["many", "default"], {"ids" => ids.join(",")}.merge(params))
      end

      # Call with a specific endpoint and params
      def find_with_endpoint(endpoints, params={})
        params.stringify_keys!
        name, endpoint = resolve_endpoints(endpoints)
        method = endpoint["method"] || "get"
        extras = {"model" => self.name, "endpoint" => name}

        response = Frenchy::Request.new(@service, method, endpoint["path"], params, extras).value
        digest_response(response, endpoint)
      end

      # Call with arbitrary method and path
      def find_with_path(method, path, params={})
        params.stringify_keys!
        extras = {"model" => self.name, "endpoint" => "path"}
        response = Frenchy::Request.new(@service, method.to_s, path.to_s, params, extras).value
        digest_response(response, endpoint)
      end

      private

      # Converts a response into model data
      def digest_response(response, endpoint)
        if endpoint["nesting"]
          Array(endpoint["nesting"]).map(&:to_s).each do |key|
            response = response.fetch(key)
          end
        end

        if response.is_a?(Array)
          Frenchy::Collection.new(Array(response).map {|v| new(v) })
        else
          new(response)
        end
      end

      # Choose the first available endpoint
      def resolve_endpoints(endpoints)
        Array(endpoints).map(&:to_s).each do |s|
          if ep = @endpoints[s]
            return s, ep
          end
        end

        raise(Frenchy::Error, "Resource does not contain any endpoints: #{Array(endpoints).join(", ")}")
      end

      # Macro to set the location pattern for this request
      def resource(options={})
        options.stringify_keys!

        @service = options.delete("service").to_s || raise(Frenchy::Error, "Resource must specify a service")

        if endpoints = options.delete("endpoints")
          @endpoints = validate_endpoints(endpoints)
        elsif endpoint = options.delete("endpoint")
          @endpoints = validate_endpoints({"default" => endpoint})
        else
          @endpoints = {}
        end
      end

      def validate_endpoints(endpoints={})
        endpoints.stringify_keys!

        Hash[endpoints.map do |k,v|
          v.stringify_keys!
          raise(Frenchy::Error, "Endpoint #{k} does not specify a path") unless v["path"]
          [k, v]
        end]
      end
    end
  end
end
