require 'mongoid'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class MongoidAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::Mongoid::Document
      end
    end
  end
end
