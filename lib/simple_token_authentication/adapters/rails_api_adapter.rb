require 'action_controller'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class RailsAPIAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::ActionController::API
      end
    end

    # make the adpater available even if the 'API' acronym is not defined
    RailsApiAdapter = RailsAPIAdapter
  end
end

