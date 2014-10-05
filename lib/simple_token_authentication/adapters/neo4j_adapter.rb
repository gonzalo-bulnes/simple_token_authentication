require 'neo4j'

module SimpleTokenAuthentication
  module Adapters
    class Neo4jAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.models_base_class
        ::Neo4j::ActiveNode
      end
    end
  end
end
