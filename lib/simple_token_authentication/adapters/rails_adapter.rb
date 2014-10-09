require 'action_controller'

module SimpleTokenAuthentication
  module Adapters
    class RailsAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::ActionController::Base
      end
    end
  end
end
