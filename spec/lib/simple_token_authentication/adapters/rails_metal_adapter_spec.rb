require 'spec_helper'
require 'simple_token_authentication/adapters/rails_metal_adapter'

describe 'SimpleTokenAuthentication::Adapters::RailsMetalAdapter' do

  before(:each) do
    stub_const('ActionController', Module.new)
    stub_const('ActionController::Metal', double())

    @subject = SimpleTokenAuthentication::Adapters::RailsMetalAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is ActionController::Metal', private: true do
      expect(@subject.base_class).to eq ActionController::Metal
    end
  end
end
