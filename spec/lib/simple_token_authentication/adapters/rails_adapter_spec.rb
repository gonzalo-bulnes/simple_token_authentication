require 'spec_helper'
require 'simple_token_authentication/adapters/rails_adapter'

describe 'SimpleTokenAuthentication::Adapters::RailsAdapter' do

  before(:each) do
    stub_const('ActionController', Module.new)
    stub_const('ActionController::Base', double())

    @subject = SimpleTokenAuthentication::Adapters::RailsAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is ActionController::Base', private: true do
      expect(@subject.base_class).to eq ActionController::Base
    end
  end
end
