require 'active_record'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class ActiveRecordAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::ActiveRecord::Base
      end
    end
  end
end
