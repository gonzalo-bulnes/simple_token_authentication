require 'spec_helper'

describe SimpleTokenAuthentication do

  it 'responds to :ensure_models_can_act_as_token_authenticatables', private: true do
    expect(subject).to respond_to :ensure_models_can_act_as_token_authenticatables
  end

  it 'responds to :ensure_controllers_can_act_as_token_authentication_handlers', private: true do
    expect(subject).to respond_to :ensure_controllers_can_act_as_token_authentication_handlers
  end

  context 'when ActiveRecord is available' do

    before(:each) do
      stub_const('ActiveRecord', Module.new)
      stub_const('ActiveRecord::Base', Class.new)

      # define a dummy ActiveRecord adapter
      dummy_active_record_adapter = double()
      allow(dummy_active_record_adapter).to receive(:base_class).and_return(ActiveRecord::Base)
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

  context 'when Mongoid is available' do

    before(:each) do
      stub_const('Mongoid', Module.new)
      stub_const('Mongoid::Document', Class.new)

      # define a dummy Mongoid adapter
      dummy_mongoid_adapter = double()
      allow(dummy_mongoid_adapter).to receive(:base_class).and_return(Mongoid::Document)
      stub_const('SimpleTokenAuthentication::Adapters::DummyMongoidAdapter',
                                                       dummy_mongoid_adapter)
    end

    describe '#ensure_models_can_act_as_token_authenticatables' do

      before(:each) do
        class SimpleTokenAuthentication::DummyModel < Mongoid::Document; end
        @dummy_model = SimpleTokenAuthentication::DummyModel

        expect(@dummy_model.new).to be_instance_of SimpleTokenAuthentication::DummyModel
        expect(@dummy_model.new).to be_kind_of Mongoid::Document
      end

      after(:each) do
        SimpleTokenAuthentication.send(:remove_const, :DummyModel)
      end

      it 'allows any kind of Mongoid::Document to act as token authenticatable', private: true do
        expect(@dummy_model).not_to respond_to :acts_as_token_authenticatable

        subject.ensure_models_can_act_as_token_authenticatables [
                SimpleTokenAuthentication::Adapters::DummyMongoidAdapter]

        expect(@dummy_model).to respond_to :acts_as_token_authenticatable
      end
    end
  end

  context 'when no ORM, ODM or OxM is available' do

    before(:each) do
      stub_const('ActiveRecord', Module.new)
      stub_const('Mongoid', Module.new)
    end

    describe '#load_available_adapters' do

      it 'raises NoAdapterAvailableError', private: true do
        allow(subject).to receive(:require).and_return(true)
        hide_const('ActiveRecord')
        hide_const('Mongoid')

        expect do
          subject.load_available_adapters SimpleTokenAuthentication.model_adapters
        end.to raise_error SimpleTokenAuthentication::NoAdapterAvailableError
      end
    end
  end

  context 'when ActionController::Base is available' do

    before(:each) do
      stub_const('ActionController::Base', Class.new)

      # define a dummy ActionController::Base (a.k.a 'Rails') adapter
      dummy_rails_adapter = double()
      allow(dummy_rails_adapter).to receive(:base_class).and_return(ActionController::Base)
      stub_const('SimpleTokenAuthentication::Adapters::DummyRailsAdapter', dummy_rails_adapter)
    end

    describe '#ensure_controllers_can_act_as_token_authentication_handlers' do

      before(:each) do
        class SimpleTokenAuthentication::DummyController < ActionController::Base; end
        @dummy_controller = SimpleTokenAuthentication::DummyController

        expect(@dummy_controller.new).to be_instance_of SimpleTokenAuthentication::DummyController
        expect(@dummy_controller.new).to be_kind_of ActionController::Base
      end

      after(:each) do
        SimpleTokenAuthentication.send(:remove_const, :DummyController)
      end

      it 'allows any kind of ActionController::Base to acts as token authentication handler', private: true do
        expect(@dummy_controller).not_to respond_to :acts_as_token_authentication_handler_for

        subject.ensure_controllers_can_act_as_token_authentication_handlers [
                          SimpleTokenAuthentication::Adapters::DummyRailsAdapter]

        expect(@dummy_controller).to respond_to :acts_as_token_authentication_handler_for
      end
    end
  end

  context 'when ActionController::API is available' do

    before(:each) do
      stub_const('ActionController::API', Class.new)

      # define a dummy ActionController::API (a.k.a 'Rails API') adapter
      dummy_rails_adapter = double()
      allow(dummy_rails_adapter).to receive(:base_class).and_return(ActionController::API)
      stub_const('SimpleTokenAuthentication::Adapters::DummyRailsAPIAdapter', dummy_rails_adapter)
    end

    describe '#ensure_controllers_can_act_as_token_authentication_handlers' do

      before(:each) do
        class SimpleTokenAuthentication::DummyController < ActionController::API; end
        @dummy_controller = SimpleTokenAuthentication::DummyController

        expect(@dummy_controller.new).to be_instance_of SimpleTokenAuthentication::DummyController
        expect(@dummy_controller.new).to be_kind_of ActionController::API
      end

      after(:each) do
        SimpleTokenAuthentication.send(:remove_const, :DummyController)
      end

      it 'allows any kind of ActionController::API to acts as token authentication handler', private: true do
        expect(@dummy_controller).not_to respond_to :acts_as_token_authentication_handler_for

        subject.ensure_controllers_can_act_as_token_authentication_handlers [
                          SimpleTokenAuthentication::Adapters::DummyRailsAPIAdapter]

        expect(@dummy_controller).to respond_to :acts_as_token_authentication_handler_for
      end
    end
  end
end
