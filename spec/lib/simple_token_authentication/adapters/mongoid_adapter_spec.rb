require 'spec_helper'
require 'simple_token_authentication/adapters/mongoid_adapter'

describe 'SimpleTokenAuthentication::Adapters::MongoidAdapter' do

  before(:each) do
    stub_const('Mongoid', Module.new)
    stub_const('Mongoid::Document', double())

    @subject = SimpleTokenAuthentication::Adapters::MongoidAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is Mongoid::Document', private: true do
      expect(@subject.base_class).to eq Mongoid::Document
    end
  end
end
