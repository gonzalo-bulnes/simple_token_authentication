require 'cequel'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class CequelAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::Cequel::Record
      end
    end
  end
end
