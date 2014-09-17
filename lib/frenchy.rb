require "frenchy/core_ext"

require "frenchy/client"
require "frenchy/collection"
require "frenchy/error"
require "frenchy/instrumentation"
require "frenchy/model"
require "frenchy/request"
require "frenchy/resource"
require "frenchy/veneer"
require "frenchy/version"

module Frenchy
  class_eval do
    @services = {}
  end

  def self.register_service(name, options={})
    @services[name.to_s] = Frenchy::Client.new(options)
  end

  def self.find_service(name)
    @services[name.to_s] || raise(Frenchy::Error, "No service '#{name}' registered")
  end
end
