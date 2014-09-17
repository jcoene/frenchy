require "spec_helper"

describe Frenchy::RequestError do
  describe "#message" do
    describe "with an exception" do
      it "uses the message from the exception" do
        ex = EOFError.new("reached eof")
        error = Frenchy::RequestError.new(ex.message)

        message = begin
          raise(error, ex)
        rescue => e
          e.message
        end

        expect(message).to eql("reached eof")
      end

      it "can be raised" do
        ex = EOFError.new("reached eof")
        error = Frenchy::RequestError
        expect do
          raise(error, ex)
        end.to raise_error(Frenchy::RequestError, "reached eof")
      end
    end

    describe "with a response" do
      it "uses the status of the response" do
        response = instance_double("Net::HTTPResponse", code: "500", body: "internal server error")
        error = Frenchy::RequestError.new(nil, nil, response)

        message = begin
          raise(error)
        rescue => e
          e.message
        end

        expect(message).to include("500")
        expect(message).to include("internal server error")
      end

      it "can be raised" do
        response = instance_double("Net::HTTPResponse", code: "500", body: "internal server error")
        error = Frenchy::RequestError.new(nil, response)
        expect do
          raise error, "something"
        end.to raise_error(Frenchy::RequestError)
      end
    end
  end

  describe "#request" do
    it "contains the original request" do
      request = "GET https://api.github.com"
      error = Frenchy::RequestError.new(nil, request, nil)
      expect(error.request).to eql(request)
    end
  end

  describe "#response" do
    it "contains the original response" do
      response = instance_double("Net::HTTPResponse", code: "500", body: "internal server error")
      error = Frenchy::RequestError.new(nil, nil, response)
      expect(error.response).to eql(response)
    end
  end

end