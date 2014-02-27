require "active_support/concern"
require "active_support/log_subscriber"

module Frenchy
  module Instrumentation
    class LogSubscriber < ActiveSupport::LogSubscriber
      def start_processing(event)
        Thread.current[:frenchy_runtime] = 0.0
      end

      def request(event)
        Thread.current[:frenchy_runtime] ||= 0.0
        Thread.current[:frenchy_runtime] += event.duration
        if logger.debug?
          name = "%s (%.2fms)" % [event.payload[:service].capitalize, event.duration]
          output = "  #{color(name, YELLOW, true)} GET #{event.payload[:path]}"
          if event.payload[:params].any?
            output += "?"
            output += event.payload[:params].map {|k,v| "#{k}=#{v}" }.join("&")
          end
          debug output
        end
      end

      def self.runtime
        Thread.current[:frenchy_runtime] || 0.0
      end
    end

    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

      def append_info_to_payload(payload)
        super
        payload[:frenchy_runtime] = Frenchy::Instrumentation::LogSubscriber.runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages = super
          if runtime = payload[:frenchy_runtime]
            messages << "Frenchy: %.1fms" % runtime.to_f
          end
          messages
        end
      end
    end
  end
end

Frenchy::Instrumentation::LogSubscriber.attach_to(:action_controller)
Frenchy::Instrumentation::LogSubscriber.attach_to(:frenchy)

ActiveSupport.on_load(:action_controller) do
  include Frenchy::Instrumentation::ControllerRuntime
end
