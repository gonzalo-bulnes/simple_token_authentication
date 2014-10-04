require 'spec_helper'

describe SimpleTokenAuthentication::Adapters::ActiveRecordAdapter do

  before(:each) do
    @subject = SimpleTokenAuthentication::Adapters::ActiveRecordAdapter
  end

  it_behaves_like 'an ORM/ODM/OxM adapter'

  describe '.models_base_class' do

    it 'is ActiveRecord::Base', private: true do
      expect(@subject.models_base_class).to eq ActiveRecord::Base
    end
  end
end
