require 'grape'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class GrapeAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::Grape::API
      end
    end
  end
end
