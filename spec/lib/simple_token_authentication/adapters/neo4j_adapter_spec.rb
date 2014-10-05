require 'spec_helper'
require 'simple_token_authentication/adapters/neo4j_adapter'

describe 'SimpleTokenAuthentication::Adapters::Neo4jAdapter' do

  before(:each) do
    stub_const('Neo4j', Module.new)
    stub_const('Neo4j::ActiveNode', double())

    @subject = SimpleTokenAuthentication::Adapters::Neo4jAdapter
  end

  it_behaves_like 'an ORM/ODM/OxM adapter'

  describe '.models_base_class' do

    it 'is Neo4j::ActiveNode', private: true do
      expect(@subject.models_base_class).to eq Neo4j::ActiveNode
    end
  end
end
