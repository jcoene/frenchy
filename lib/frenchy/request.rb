begin
  require "active_support"
rescue LoadError
end

module Frenchy
  class Request
    attr_accessor :service, :method, :path, :params, :extras

    # Create a new request with given parameters
    def initialize(service, method, path, params={}, extras={})
      path = path.dup
      path.scan(/(:[a-z0-9_+]+)/).flatten.uniq.each do |pat|
        k = pat.sub(":", "")
        begin
          v = params.fetch(pat.sub(":", "")).to_s
        rescue
          raise Frenchy::Error, "The required parameter '#{k}' was not specified."
        end

        params.delete(k)
        path.sub!(pat, v)
      end

      @service = service
      @method = method
      @path = path
      @params = params
      @extras = extras
    end

    # Issue the request and return the value
    def value
      Frenchy.find_service(@service).send(@method, @path, @params)
    end

    # Requests are instrumented if ActiveSupport is available.
    if defined?(ActiveSupport::Notifications)
      alias_method :value_without_instrumentation, :value

      def value
        ActiveSupport::Notifications.instrument("request.frenchy", {service: @service, method: @method, path: @path, params: @params}.merge(@extras)) do
          value_without_instrumentation
        end
      end
    end
  end
end
