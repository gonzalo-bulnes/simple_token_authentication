require 'spec_helper'
require 'simple_token_authentication/caches/dalli_provider'

describe 'SimpleTokenAuthentication::Caches::DalliProvider' do

  before(:each) do

    stub_const('Dalli', double())

    @subject = SimpleTokenAuthentication::Caches::DalliProvider
  end

  it_behaves_like 'a cache'

  describe '.base_class' do

    it 'is ::Dalli', private: true do
      expect(@subject.base_class).to eq ::Dalli
    end
  end
end
