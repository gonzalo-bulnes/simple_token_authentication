require 'action_controller'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class RailsMetalAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::ActionController::Metal
      end
    end
  end
end
