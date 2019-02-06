require 'active_support/cache'
require 'simple_token_authentication/cache'

module SimpleTokenAuthentication
  module Caches
    class RailsCacheProvider
      extend SimpleTokenAuthentication::Cache

      def self.base_class
        ::ActiveSupport::Cache::Store
      end

      # Set a new cached authentication for this record, recording the
      # plain token, authentication status, and timestamp
      def self.set_new_auth record_id, plain_token, authenticated
        connection.write(cache_record_key(record_id), cache_record_value(plain_token, record_id, authenticated), expires_in: expiration_time)
      end

      # Get a new cached authentication for this record, recording the
      # plain token, authentication status, and timestamp
      def self.get_previous_auth record_id, plain_token
        res = connection.fetch(cache_record_key(record_id))
        check_cache_result plain_token, record_id, res
      end

    end
  end
end
