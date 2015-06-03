require 'spec_helper'

describe 'Any class which includes SimpleTokenAuthentication::TokenAuthenticationHandler' do

  let(:described_class) do
    define_dummy_class_which_includes SimpleTokenAuthentication::TokenAuthenticationHandler
  end

  after(:each) do
    # ensure_examples_independence
    SimpleTokenAuthentication.send(:remove_const, :SomeClass)
  end

  it_behaves_like 'a token authentication handler'

  let(:subject) { described_class }

  describe '.handle_token_authentication_for' do

    before(:each) do
      double_user_model
    end

    it 'ensures token authentication is handled for a given (token authenticatable) model', public: true do
      entities_manager = double()
      allow(entities_manager).to receive(:find_or_create_entity).and_return('entity')

      # skip steps which are not relevant in this example
      allow(SimpleTokenAuthentication).to receive(:fallback).and_return('default')
      allow(subject).to receive(:entities_manager).and_return(entities_manager)
      allow(subject).to receive(:set_token_authentication_hooks)
      allow(subject).to receive(:define_token_authentication_helpers_for)

      expect(subject).to receive(:set_token_authentication_hooks).with('entity', {option: 'value', fallback: 'default'})
      subject.handle_token_authentication_for(User, {option: 'value'})
    end

    context 'when called multiple times' do

      it 'ensures token authentication is handled for the given (token authenticatable) models', public: true do
        double_super_admin_model
        entities_manager = double()
        allow(entities_manager).to receive(:find_or_create_entity).with(User, nil).and_return('User entity')
        allow(entities_manager).to receive(:find_or_create_entity).with(SuperAdmin, nil).and_return('SuperAdmin entity')

        # skip steps which are not relevant in this example
        allow(SimpleTokenAuthentication).to receive(:fallback).and_return('default')
        allow(subject).to receive(:entities_manager).and_return(entities_manager)
        allow(subject).to receive(:set_token_authentication_hooks)
        allow(subject).to receive(:define_token_authentication_helpers_for)

        expect(subject).to receive(:set_token_authentication_hooks).with('User entity', {option: 'value', fallback: 'default'})
        expect(subject).to receive(:set_token_authentication_hooks).with('SuperAdmin entity', {option: 'some specific value', fallback: 'default'})
        subject.handle_token_authentication_for(User, {option: 'value'})
        subject.handle_token_authentication_for(SuperAdmin, {option: 'some specific value'})
      end
    end

    context 'when an alias is provided for the model', token_authenticatable_aliases_option: true do

      it 'creates an Entity with that alias', private: true do
        entities_manager = double()
        allow(entities_manager).to receive(:find_or_create_entity)

        # skip steps which are not relevant in this example
        allow(subject).to receive(:entities_manager).and_return(entities_manager)
        allow(subject).to receive(:set_token_authentication_hooks)
        allow(subject).to receive(:define_token_authentication_helpers_for)

        expect(entities_manager).to receive(:find_or_create_entity).with(User, 'some_alias')
        subject.handle_token_authentication_for(User, {option: 'value', as: 'some_alias'})
        expect(entities_manager).to receive(:find_or_create_entity).with(User, 'another_alias')
        subject.handle_token_authentication_for(User, {option: 'value', 'as' => 'another_alias'})
      end
    end
  end

  describe '.entities_manager' do

    before(:each) do
      # The private tag is here to keep the following examples out of
      # the public documentation.
      subject.send :public_class_method, :entities_manager

      allow(SimpleTokenAuthentication::EntitiesManager).to receive(:new)
        .and_return('a EntitiesManager instance')
    end

    context 'when called for the first time' do

      it 'creates a new EntitiesManager instance', private: true do
        expect(SimpleTokenAuthentication::EntitiesManager).to receive(:new)
        expect(subject.entities_manager).to eq 'a EntitiesManager instance'
      end
    end

    context 'when a EntitiesManager instance was already created' do

      before(:each) do
        subject.entities_manager
        # let's make any new EntitiesManager distinct from the first
        allow(SimpleTokenAuthentication::EntitiesManager).to receive(:new)
        .and_return('another EntitiesManager instance')
      end

      it 'returns that instance', private: true do
        expect(subject.entities_manager).to eq 'a EntitiesManager instance'
      end

      it 'does not create a new EntitiesManager instance', private: true do
        expect(SimpleTokenAuthentication::EntitiesManager).not_to receive(:new)
        expect(subject.entities_manager).not_to eq 'another EntitiesManager instance'
      end
    end
  end

  describe '.fallback_handler' do

    before(:each) do
      # The private tag is here to keep the following examples out of
      # the public documentation.
      subject.send :public_class_method, :fallback_handler

      allow(SimpleTokenAuthentication::DeviseFallbackHandler).to receive(:new)
        .and_return('a DeviseFallbackHandler instance')
    end

    context 'when called for the first time' do

      it 'creates a new DeviseFallbackHandler instance', private: true do
        expect(SimpleTokenAuthentication::DeviseFallbackHandler).to receive(:new)
        expect(subject.fallback_handler).to eq 'a DeviseFallbackHandler instance'
      end
    end

    context 'when a DeviseFallbackHandler instance was already created' do

      before(:each) do
        subject.fallback_handler
        # let's make any new DeviseFallbackHandler distinct from the first
        allow(SimpleTokenAuthentication::DeviseFallbackHandler).to receive(:new)
        .and_return('another DeviseFallbackHandler instance')
      end

      it 'returns that instance', private: true do
        expect(subject.fallback_handler).to eq 'a DeviseFallbackHandler instance'
      end

      it 'does not create a new DeviseFallbackHandler instance', private: true do
        expect(SimpleTokenAuthentication::DeviseFallbackHandler).not_to receive(:new)
        expect(subject.fallback_handler).not_to eq 'another DeviseFallbackHandler instance'
      end
    end
  end

  describe '#find_record_from_identifier', private: true do

    before(:each) do
      @entity = double()
      # default identifer is :email
      allow(@entity).to receive(:identifier).and_return(:email)
    end

    context 'when the Devise config. does not defines the identifier as a case-insentitive key' do

      before(:each) do
        allow(Devise).to receive_message_chain(:case_insensitive_keys, :include?)
        .with(:email).and_return(false)
      end

      context 'when a downcased identifier was provided' do

        before(:each) do
          allow(@entity).to receive(:get_identifier_from_params_or_headers)
          .and_return('alice@example.com')
        end

        it 'returns the proper record if any' do
          # let's say there is a record
          record = double()
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'alice@example.com')
          .and_return([record])

          expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
        end
      end

      context 'when a upcased identifier was provided' do

        before(:each) do
          allow(@entity).to receive(:get_identifier_from_params_or_headers)
          .and_return('AliCe@ExampLe.Com')
        end

        it 'does not return any record' do
          # let's say there is a record...
          record = double()
          # ...whose identifier is downcased...
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'alice@example.com')
          .and_return([record])
          # ...not upcased
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'AliCe@ExampLe.Com')
          .and_return([])

          expect(subject.new.send(:find_record_from_identifier, @entity)).to be_nil
        end
      end
    end

    context 'when the Devise config. defines the identifier as a case-insentitive key' do

      before(:each) do
        allow(Devise).to receive_message_chain(:case_insensitive_keys, :include?)
        .with(:email).and_return(true)
      end

      context 'and a downcased identifier was provided' do

        before(:each) do
          allow(@entity).to receive(:get_identifier_from_params_or_headers)
          .and_return('alice@example.com')
        end

        it 'returns the proper record if any' do
          # let's say there is a record
          record = double()
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'alice@example.com')
          .and_return([record])

          expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
        end
      end

      context 'and a upcased identifier was provided' do

        before(:each) do
          allow(@entity).to receive(:get_identifier_from_params_or_headers)
          .and_return('AliCe@ExampLe.Com')
        end

        it 'returns the proper record if any' do
          # let's say there is a record...
          record = double()
          # ...whose identifier is downcased...
          allow(@entity).to receive_message_chain(:model, :where)
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'alice@example.com')
          .and_return([record])
          # ...not upcased
          allow(@entity).to receive_message_chain(:model, :where).with(email: 'AliCe@ExampLe.Com')
          .and_return([])

          expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
        end
      end
    end

    context 'when a custom identifier was defined', identifiers_option: true do

      before(:each) do
        allow(@entity).to receive(:identifier).and_return(:phone_number)
      end

      context 'when the Devise config. does not defines the identifier as a case-insentitive key' do

        before(:each) do
          allow(Devise).to receive_message_chain(:case_insensitive_keys, :include?)
          .with(:phone_number).and_return(false)
        end

        context 'when a downcased identifier was provided' do

          before(:each) do
            allow(@entity).to receive(:get_identifier_from_params_or_headers)
            .and_return('alice@example.com')
          end

          it 'returns the proper record if any' do
            # let's say there is a record
            record = double()
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'alice@example.com')
            .and_return([record])

            expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
          end
        end

        context 'when a upcased identifier was provided' do

          before(:each) do
            allow(@entity).to receive(:get_identifier_from_params_or_headers)
            .and_return('AliCe@ExampLe.Com')
          end

          it 'does not return any record' do
            # let's say there is a record...
            record = double()
            # ...whose identifier is downcased...
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'alice@example.com')
            .and_return([record])
            # ...not upcased
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'AliCe@ExampLe.Com')
            .and_return([])

            expect(subject.new.send(:find_record_from_identifier, @entity)).to be_nil
          end
        end
      end

      context 'when the Devise config. defines the identifier as a case-insentitive key' do

        before(:each) do
          allow(Devise).to receive_message_chain(:case_insensitive_keys, :include?)
          .with(:phone_number).and_return(true)
        end

        context 'and a downcased identifier was provided' do

          before(:each) do
            allow(@entity).to receive(:get_identifier_from_params_or_headers)
            .and_return('alice@example.com')
          end

          it 'returns the proper record if any' do
            # let's say there is a record
            record = double()
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'alice@example.com')
            .and_return([record])

            expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
          end
        end

        context 'and a upcased identifier was provided' do

          before(:each) do
            allow(@entity).to receive(:get_identifier_from_params_or_headers)
            .and_return('AliCe@ExampLe.Com')
          end

          it 'returns the proper record if any' do
            # let's say there is a record...
            record = double()
            # ...whose identifier is downcased...
            allow(@entity).to receive_message_chain(:model, :where)
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'alice@example.com')
            .and_return([record])
            # ...not upcased
            allow(@entity).to receive_message_chain(:model, :where).with(phone_number: 'AliCe@ExampLe.Com')
            .and_return([])

            expect(subject.new.send(:find_record_from_identifier, @entity)).to eq record
          end
        end
      end
    end
  end

  describe 'and which supports the :before_filter hook' do

    before(:each) do
      allow(subject).to receive(:before_filter)
    end

    # User

    context 'and which handles token authentication for User' do

      before(:each) do
        double_user_model
      end

      it 'ensures its instances require user to authenticate from token or any Devise strategy before any action', public: true do
        expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, {})
        subject.handle_token_authentication_for User
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require user to authenticate from token before any action', public: true do
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token, {})
          subject.handle_token_authentication_for User, options
        end
      end

      describe 'instance' do

        before(:each) do
          double_user_model

          subject.class_eval do
            handle_token_authentication_for User
          end
        end

        it 'responds to :authenticate_user_from_token', protected: true do
          expect(subject.new).to respond_to :authenticate_user_from_token
        end

        it 'responds to :authenticate_user_from_token!', protected: true do
          expect(subject.new).to respond_to :authenticate_user_from_token!
        end

        it 'does not respond to :authenticate_super_admin_from_token', protected: true do
          expect(subject.new).not_to respond_to :authenticate_super_admin_from_token
        end

        it 'does not respond to :authenticate_super_admin_from_token!', protected: true do
          expect(subject.new).not_to respond_to :authenticate_super_admin_from_token!
        end
      end
    end

    # SuperAdmin

    context 'and which handles token authentication for SuperAdmin' do

      before(:each) do
        double_super_admin_model
      end

      it 'ensures its instances require super_admin to authenticate from token or any Devise strategy before any action', public: true do
        expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token!, {})
        subject.handle_token_authentication_for SuperAdmin
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require super_admin to authenticate from token before any action', public: true do
          expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token, {})
          subject.handle_token_authentication_for SuperAdmin, options
        end
      end

      describe 'instance' do

        before(:each) do
          double_super_admin_model

          subject.class_eval do
            handle_token_authentication_for SuperAdmin
          end
        end

        it 'responds to :authenticate_super_admin_from_token', protected: true do
          expect(subject.new).to respond_to :authenticate_super_admin_from_token
        end

        it 'responds to :authenticate_super_admin_from_token!', protected: true do
          expect(subject.new).to respond_to :authenticate_super_admin_from_token!
        end

        it 'does not respond to :authenticate_user_from_token', protected: true do
          expect(subject.new).not_to respond_to :authenticate_user_from_token
        end

        it 'does not respond to :authenticate_user_from_token!', protected: true do
          expect(subject.new).not_to respond_to :authenticate_user_from_token!
        end
      end

      context 'with the :admin alias', token_authenticatable_aliases_option: true do

        let(:options) do
          { 'as' => :admin }
        end

        it 'ensures its instances require admin to authenticate from token or any Devise strategy before any action', public: true do
          expect(subject).to receive(:before_filter).with(:authenticate_admin_from_token!, {})
          subject.handle_token_authentication_for SuperAdmin, options
        end

        context 'and disables the fallback to Devise authentication' do

          let(:options) do
            { as: 'admin', fallback_to_devise: false }
          end

          it 'ensures its instances require admin to authenticate from token before any action', public: true do
            expect(subject).to receive(:before_filter).with(:authenticate_admin_from_token, {})
            subject.handle_token_authentication_for SuperAdmin, options
          end
        end

        describe 'instance' do

          before(:each) do
            double_super_admin_model

            subject.class_eval do
              handle_token_authentication_for SuperAdmin, as: :admin
            end
          end

          it 'responds to :authenticate_admin_from_token', protected: true do
            expect(subject.new).to respond_to :authenticate_admin_from_token
          end

          it 'responds to :authenticate_admin_from_token!', protected: true do
            expect(subject.new).to respond_to :authenticate_admin_from_token!
          end

          it 'does not respond to :authenticate_super_admin_from_token', protected: true do
            expect(subject.new).not_to respond_to :authenticate_super_admin_from_token
          end

          it 'does not respond to :authenticate_super_admin_from_token!', protected: true do
            expect(subject.new).not_to respond_to :authenticate_super_admin_from_token!
          end

          it 'does not respond to :authenticate_user_from_token', protected: true do
            expect(subject.new).not_to respond_to :authenticate_user_from_token
          end

          it 'does not respond to :authenticate_user_from_token!', protected: true do
            expect(subject.new).not_to respond_to :authenticate_user_from_token!
          end
        end
      end
    end
  end
end
