require 'active_record'

module SimpleTokenAuthentication
  module Adapters
    class ActiveRecordAdapter

      def self.models_base_class
        ::ActiveRecord::Base
      end
    end
  end
end
