require 'spec_helper'

describe SimpleTokenAuthentication do

  it 'responds to :ensure_models_can_act_as_token_authenticatables', private: true do
    expect(subject).to respond_to :ensure_models_can_act_as_token_authenticatables
  end

  context 'when ActiveRecord is available' do

    before(:each) do
      stub_const('ActiveRecord', Module.new)
      stub_const('ActiveRecord::Base', Class.new)

      # define a dummy ActiveRecord adapter
      dummy_active_record_adapter = double()
      dummy_active_record_adapter.stub(:models_base_class).and_return(ActiveRecord::Base)
      stub_const('SimpleTokenAuthentication::Adapters::DummyActiveRecordAdapter',
                                                       dummy_active_record_adapter)
    end

    describe '#ensure_models_can_act_as_token_authenticatables' do

      before(:each) do
        class SimpleTokenAuthentication::DummyModel < ActiveRecord::Base; end
        @dummy_model = SimpleTokenAuthentication::DummyModel

        expect(@dummy_model.new).to be_instance_of SimpleTokenAuthentication::DummyModel
        expect(@dummy_model.new).to be_kind_of ActiveRecord::Base
      end

      after(:each) do
        SimpleTokenAuthentication.send(:remove_const, :DummyModel)
      end

      it 'allows any kind of ActiveRecord::Base to act as token authenticatable', private: true do
        expect(@dummy_model).not_to respond_to :acts_as_token_authenticatable

        subject.ensure_models_can_act_as_token_authenticatables [
                SimpleTokenAuthentication::Adapters::DummyActiveRecordAdapter]

        expect(@dummy_model).to respond_to :acts_as_token_authenticatable
      end
    end
  end
end
