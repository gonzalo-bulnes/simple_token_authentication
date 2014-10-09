require 'spec_helper'
require 'simple_token_authentication/adapters/active_record_adapter'

describe 'SimpleTokenAuthentication::Adapters::ActiveRecordAdapter' do

  before(:each) do
    stub_const('ActiveRecord', Module.new)
    stub_const('ActiveRecord::Base', double())

    @subject = SimpleTokenAuthentication::Adapters::ActiveRecordAdapter
  end

  it_behaves_like 'an ORM/ODM/OxM adapter'

  describe '.base_class' do

    it 'is ActiveRecord::Base', private: true do
      expect(@subject.base_class).to eq ActiveRecord::Base
    end
  end
end
