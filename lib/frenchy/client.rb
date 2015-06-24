require "net/http"
require "json"

module Frenchy
  class Client
    attr_accessor :name, :host, :timeout, :retries

    # Create a new client instance
    def initialize(name, options={})
      options.stringify_keys!

      @name           = name.to_s
      @host           = options.fetch("host")           { "http://127.0.0.1:8080" }
      @timeout        = options.fetch("timeout")        { 30 }
      @retries        = options.fetch("retries")        { 0 }
      @backoff_delay  = options.fetch("backoff_delay")  { 1.0 }
      @headers        = options.fetch("headers")        { {} }
    end

    # Issue a get request with the given path and query parameters. Get
    # requests can be retried.
    def get(path, params)
      try = 0
      err = nil

      while try <= @retries
        sleep (@backoff_delay * (try*try)) if try > 0

        begin
          return perform("GET", path, params)
        rescue Frenchy::ServerError => err
          try += 1
        end
      end

      raise err
    end

    # Issue a non-retryable request with the given path and query parameters
    ["PATCH", "POST", "PUT", "DELETE"].each do |method|
      define_method(method.downcase) do |path, params|
        perform(method, path, params)
      end
    end

    private

    def perform(method, path, params)
      uri = URI(@host)
      body = nil
      headers = {
        "User-Agent" => "Frenchy/#{Frenchy::VERSION}",
        "Accept"     => "application/json",
      }.merge(@headers)

      # Set the URI path
      uri.path = path

      # Set request parameters
      if params.any?
        case method
        when "GET"
          # Get method uses params as query string
          uri.query = URI.encode_www_form(params)
        else
          # Other methods post a JSON body
          headers["Content-Type"] = "application/json"
          body = JSON.generate(params)
        end
      end

      # Create a new HTTP connection
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      # Create a new HTTP request
      req = Net::HTTPGenericRequest.new(
        method.to_s.upcase,       # method
        body != nil,              # request has body?
        true,                     # response has body?
        uri.request_uri,          # request uri
        headers,                  # request headers
      )

      # Set the request body if present
      req.body = body if body != nil

      # Create a request info string for inspection
      reqinfo = "#{method} #{uri.to_s}"

      # Perform the request
      begin
        resp = perform_request(http, req)
      rescue => ex
        raise Frenchy::ServerError.new(ex, reqinfo, nil)
      end

      # Return based on response
      case resp.code.to_i
      when 200...399
        # Positive responses are expected to return JSON
        begin
          JSON.parse(resp.body)
        rescue => ex
          raise Frenchy::InvalidResponse.new(ex, reqinfo, resp)
        end
      when 404
        # Explicitly handle not found errors
        raise Frenchy::NotFound.new(nil, reqinfo, resp)
      when 503, 504
        # Explicitly handle temporarily unavailable errors
        raise Frenchy::TemporarilyUnavailable.new(nil, reqinfo, resp)
      else
        # All other responses are treated as a server error
        raise Frenchy::ServiceUnavailable.new(nil, reqinfo, resp)
      end
    end

    def perform_request(http, req)
      http.request(req)
    end
  end
end
