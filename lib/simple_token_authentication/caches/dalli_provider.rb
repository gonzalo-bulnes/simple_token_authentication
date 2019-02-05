require 'dalli'
require 'simple_token_authentication/cache'

module SimpleTokenAuthentication
  module Caches
    class DalliProvider
      extend SimpleTokenAuthentication::Cache

      def self.base_class
        ::Dalli
      end

      # Set a new cached authentication for this record, recording the
      # plain token, authentication status, and timestamp
      def self.set_new_auth record_id, plain_token, authenticated
        connection.set(cache_record_key(record_id), cache_record_value(plain_token, record_id, authenticated))
      end

      # Get a new cached authentication for this record, recording the
      # plain token, authentication status, and timestamp
      def self.get_previous_auth record_id, plain_token
        res = connection.get(cache_record_key(record_id))
        check_cache_result plain_token, record_id, res
      end

    end
  end
end
