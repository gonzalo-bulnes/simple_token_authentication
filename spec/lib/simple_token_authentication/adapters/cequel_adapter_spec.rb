require 'spec_helper'
require 'simple_token_authentication/adapters/cequel_adapter'

describe 'SimpleTokenAuthentication::Adapters::CequelAdapter' do

  before(:each) do
    stub_const('Cequel', Module.new)
    stub_const('Cequel::Record', double())

    @subject = SimpleTokenAuthentication::Adapters::CequelAdapter
  end

  it_behaves_like 'an adapter'

  describe '.base_class' do

    it 'is Cequel::Record', private: true do
      expect(@subject.base_class).to eq Cequel::Record
    end
  end
end
