require "frenchy"
require "http"
require "json"

module Frenchy
  class Client
    # Create a new client instance
    def initialize(options={})
      options.symbolize_keys!

      @host = options.delete(:host) || "http://127.0.0.1:8080"
      @timeout = options.delete(:timeout) || 60
      @retries = options.delete(:retries) || 0
    end

    # Issue a get request with the given path and query parameters
    def get(path, params)
      try = 0
      error = nil

      while try <= @retries
        begin
          return perform(:get, path, params)
        rescue Frenchy::ServerError, Frenchy::InvalidResponse => error
          sleep (0.35 * (try*try))
          try += 1
        end
      end

      raise error
    end

    # Issue a non-retryable request with the given path and query parameters
    def post(path, params); perform(:post, path, params); end
    def put(path, params); perform(:put, path, params); end
    def delete(path, params); perform(:delete, path, params); end

    private

    def perform(method, path, params)
      url = "#{@host}#{path}"

      request = {
        method: method.to_s.upcase,
        url: url,
        params: params
      }

      response = begin
        HTTP.accept(:json).send(method, url, params: params).response
      rescue => exception
        raise Frenchy::ServerError, {request: request, error: exception}
      end

      case response.code
      when 200
        begin
          JSON.parse(response.body)
        rescue => e
          raise Frenchy::InvalidResponse, {request: request, error: exception, status: response.status, body: response.body}
        end
      when 404
        body = JSON.parse(response.body) rescue response.body
        raise Frenchy::NotFound, {request: request, status: response.status, body: body}
      else
        body = JSON.parse(response.body) rescue response.body
        raise Frenchy::ServerError, {request: request, status: response.status, body: body}
      end
    end

    public
  end
end
