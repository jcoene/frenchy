require "frenchy"
require "frenchy/client"
require "active_support/notifications"

module Frenchy
  class Request
    # Create a new request with given parameters
    def initialize(service, path, params={}, options={})
      params.stringify_keys!

      path = path.dup
      path.scan(/(:[a-z0-9_+]+)/).flatten.uniq.each do |pat|
        k = pat.sub(":", "")
        begin
          v = params.fetch(pat.sub(":", "")).to_s
        rescue
          raise Frenchy::InvalidRequest, "The required parameter '#{k}' was not specified."
        end

        params.delete(k)
        path.sub!(pat, v)
      end

      @service = service
      @path = path
      @params = params
      @options = options
    end

    # Issue the request and return the value
    def value
      ActiveSupport::Notifications.instrument("request.frenchy", {service: @service, path: @path, params: @params}.merge(@options)) do
        client = Frenchy.find_service(@service)
        client.get(@path, @params)
      end
    end
  end
end
