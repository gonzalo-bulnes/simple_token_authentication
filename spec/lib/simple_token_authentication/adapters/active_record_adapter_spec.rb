require 'spec_helper'

describe SimpleTokenAuthentication::Adapters::ActiveRecordAdapter do

  before(:each) do
    @subject = SimpleTokenAuthentication::Adapters::ActiveRecordAdapter
  end

  it 'responds to :models_base_class', private: true do
    expect(@subject).to respond_to :models_base_class
  end

  describe '.models_base_class' do

    it 'is ActiveRecord::Base', private: true do
      expect(@subject.models_base_class).to eq ActiveRecord::Base
    end
  end
end
