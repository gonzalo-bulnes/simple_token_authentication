require 'spec_helper'
require 'simple_token_authentication/adapters/rails_api_adapter'

describe 'SimpleTokenAuthentication::Adapters::RailsAPIAdapter' do

  before(:each) do
    stub_const('ActionController', Module.new)
    stub_const('ActionController::API', double())

    @subject = SimpleTokenAuthentication::Adapters::RailsAPIAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is ActionController::API', private: true do
      expect(@subject.base_class).to eq ActionController::API
    end
  end
end

context 'When the "API" acronym is not defined' do
  describe 'SimpleTokenAuthentication::Adapters::RailsApiAdapter' do

    before(:each) do
      stub_const('ActionController', Module.new)
      stub_const('ActionController::API', double())

      @subject = SimpleTokenAuthentication::Adapters::RailsApiAdapter
    end

    it_behaves_like 'an adapter'

    describe '.base_class' do

      it 'is ActionController::API', private: true do
        expect(@subject.base_class).to eq ActionController::API
      end
    end
  end
end

