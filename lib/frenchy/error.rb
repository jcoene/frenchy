module Frenchy
  class Error < ::StandardError; end

  class RequestError < Error
    attr_reader :message, :request, :response

    def initialize(message=nil, request=nil, response=nil)
      @request, @response = request, response

      if message
        @message = message.respond_to?(:message) ? message.message : message
      elsif response.respond_to?(:code)
        @message = "The server responded with status #{response.code}:\n\n#{response.body}"
      else
        @message = "An unknown error has occured"
      end

      @message += "\n\n#{request}" if request
    end

    def to_s
      @message
    end
  end

  class NotFound < RequestError; end
  class InvalidResponse < RequestError; end
  class ServerError < RequestError; end
  class ServiceUnavailable < ServerError; end
end