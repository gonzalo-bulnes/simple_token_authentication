require 'digest/sha2'
require 'simple_token_authentication/cache'

module SimpleTokenAuthentication
  module Cache

    # Cache previous authentications by a specific user record using a plain text token.
    # This allows rapid re-authentication for requests that store authentication tokens
    # as computationally expensive digests in the database.

    # Hash the plain text token with a strong, but computationally fast hashing function.
    # This aims to avoid snooping by other users of the cache, especially since many
    # caches do not require authentication by other system users.
    # This new digest does not provide the full protection from attack that the persisted token
    # BCrypt digest has, since it is not so computationally expensive, and therefore could be brute-forced.
    # Since this hash is only intended to be stored short-term in an in-memory cache
    # accessible by reasonably trusted system users, this compromise allows
    # rapid validation of previous authentications, with reasonable protection
    # against revealing tokens.

    # In order to reflect a session time out with cached authentications, the configuration provides
    # a `cache_expiration_time` setting. This is passed to the cache every time a new authentication
    # result is written. Enforcement of this time is expected to be performed by the cache.
    # Cache providers can also enforce this if the specific cache does not reliably enforce
    # this expiration time.

    def base_class
      raise NotImplementedError
    end

    # The current cache connection
    def connection= c
      @connection = c
    end

    def connection
      @connection
    end

    # Time to expire previous cached authentication results
    def expiration_time= e
      @expiration_time = e
    end

    def expiration_time
      @expiration_time
    end


    # Set a new cached authentication for this record, recording the
    # plain token, authentication status, and timestamp
    def set_new_auth record_id, plain_token, authenticated
    end

    # Get a new cached authentication for this record, recording the
    # plain token, authentication status, and timestamp
    def get_previous_auth record_id, plain_token
    end

    # Invalidate a previous cached authentication for this record
    def invalidate_auth record_id
      set_new_auth record_id, nil, false
    end

    # Generate a key to be used to identify the authentication for this user record
    def cache_record_key record_id
      {cache_record_type: 'simple_token_authentication auth record', record_id: record_id}
    end

    # Generate a stored value, containing the hashed token, current authentication status,
    # and a timestamp that can be used for additional TTL checking
    def cache_record_value token, record_id, authenticated
      {token: hash(token, record_id), authenticated: authenticated, updated_at: Time.now}
    end

    # Generate a digest using the user record id, the Devise configuration pepper and the
    # plain text token.
    def hash token, record_id
      Digest::SHA2.hexdigest("#{record_id}--#{SimpleTokenAuthentication.pepper}--#{token}")
    end

    # Simple check of the cache result to validate that the result was found,
    # the previous authentication was valid, and the authentication token has not changed
    def check_cache_result token, record_id, res
      res && res[:authenticated] == true && res[:token] == hash(token, record_id)
    end

  end
end
