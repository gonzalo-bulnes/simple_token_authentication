require 'simple_token_authentication/acts_as_token_authenticatable'
require 'simple_token_authentication/acts_as_token_authentication_handler'
require 'simple_token_authentication/configuration'
require 'simple_token_authentication/adapters/active_record' if defined? ActiveRecord
require 'simple_token_authentication/adapters/neo4j' if defined? Neo4j
require 'simple_token_authentication/adapters/mongoid' if defined? Mongoid

module SimpleTokenAuthentication
  extend Configuration
end
