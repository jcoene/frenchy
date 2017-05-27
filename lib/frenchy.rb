require "frenchy/core_ext"

require "frenchy/client"
require "frenchy/collection"
require "frenchy/enum"
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
    @content_types = {}
    @content_type_accept = ""
  end

  def self.register_service(name, options={})
    @services[name.to_s] = Frenchy::Client.new(name, options)
  end

  def self.find_service(name)
    @services[name.to_s] || raise(Frenchy::Error, "No service '#{name}' registered")
  end

  def self.register_content_type(name, &block)
    @content_types[name] = block
    @content_type_accept = @content_types.keys.join(", ")
  end

  def self.find_content_type_handler(name)
    @content_types[name] || raise(Frenchy::Error, "No content type '#{name}' registered")
  end

  def self.accept_header
    @content_type_accept
  end
end

Frenchy.register_content_type("application/json") {|x| JSON.parse(x) }
