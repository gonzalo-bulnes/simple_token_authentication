require 'spec_helper'
require 'simple_token_authentication/adapters/grape_adapter'

describe 'SimpleTokenAuthentication::Adapters::RailsAPIAdapter' do

  before(:each) do
    stub_const('Grape', Module.new)
    stub_const('Grape::API', double())

    @subject = SimpleTokenAuthentication::Adapters::GrapeAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is Grape::API', private: true do
      expect(@subject.base_class).to eq Grape::API
    end
  end
end
