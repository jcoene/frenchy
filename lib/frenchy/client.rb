require "frenchy"
require "http"
require "json"

module Frenchy
  class Client
    # Create a new client instance
    def initialize(options={})
      options.symbolize_keys!

      @host = options.delete(:host) || "http://127.0.0.1:8080"
      @timeout = options.delete(:timeout) || 30
      @retries = options.delete(:retires) || 5
    end

    # Issue a request with the given path and query parameters
    def get(path, params)
      try = 1
      error = nil

      while try < @retries
        begin
          return get_once(path, params)
        rescue Frenchy::ServerError, Frenchy::InvalidResponse => error
          sleep (0.35 * (try*try))
          try += 1
        end
      end

      raise error
    end

    private

    def get_once(path, params)
      url = "#{@host}#{path}"

      response = begin
        HTTP.accept(:json).get(url, params: params).response
      rescue
        raise Frenchy::ServerError
      end

      case response.code
      when 200
        begin
          JSON.parse(response.body)
        rescue
          raise Frenchy::InvalidResponse
        end
      when 404
        raise Frenchy::NotFound
      else
        raise Frenchy::ServerError, response.inspect
      end
    end

    public
  end
end
