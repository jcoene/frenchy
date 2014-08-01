require "frenchy/client"
require "frenchy/collection"
require "frenchy/instrumentation"
require "frenchy/model"
require "frenchy/request"
require "frenchy/resource"
require "frenchy/veneer"
require "frenchy/version"

module Frenchy
  class Error < ::StandardError; end
  class NotFound < Error; end
  class ServerError < Error; end
  class InvalidResponse < Error; end
  class InvalidRequest < Error; end
  class ConfigurationError < Error; end

  def self.register_service(name, options={})
    @services ||= {}
    @services[name.to_sym] = Frenchy::Client.new(options)
  end

  def self.find_service(name)
    if @services.nil?
      raise(Frenchy::ConfigurationError, "No services have been configured")
    end

    @services[name.to_sym] || raise(Frenchy::ConfigurationError, "No service '#{name}' registered")
  end
end
