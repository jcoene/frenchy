module Frenchy
  class Error < ::StandardError; end

  class RequestError < Error
    attr_reader :message, :request, :response

    def initialize(message=nil, request=nil, response=nil)
      @request, @response = request, response

      if message
        @message = message.respond_to?(:message) ? message.message : message
      elsif response.respond_to?(:code)
        @message = "The server responded with status #{response.code}"
        @message += "\n\n#{response.body.to_s}" if response.body.to_s != ""
      else
        @message = "An unknown error has occured"
      end

      @message += "\n\n#{request}" if request
    end

    def to_s
      @message
    end
  end

  class BadRequest < RequestError; end
  class NotFound < RequestError; end
  class ServerError < RequestError; end
  class InvalidResponse < ServerError; end
  class ServiceUnavailable < ServerError; end
  class TemporarilyUnavailable < ServerError; end
end
