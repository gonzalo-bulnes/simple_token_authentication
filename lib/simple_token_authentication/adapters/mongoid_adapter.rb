if Module.const_defined?('ActiveModel') &&
  ActiveModel.const_defined?('Serializers') &&
  ActiveModel::Serializers.const_defined?('Xml')
  # As far as I know Mongoid doesn't support Rails 6
  # Please let me know if this isn't true when you read it!

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
end
