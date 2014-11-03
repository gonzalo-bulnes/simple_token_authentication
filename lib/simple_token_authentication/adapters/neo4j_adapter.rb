require 'neo4j'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class Neo4jAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::Neo4j::ActiveNode
      end
    end
  end
end
