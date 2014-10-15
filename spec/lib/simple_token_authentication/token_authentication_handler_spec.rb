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
      subject.stub(:entities_manager).and_return(entities_manager)
      subject.stub(:set_token_authentication_hooks)
      subject.stub(:define_token_authentication_helpers_for)

      expect(subject).to receive(:set_token_authentication_hooks).with('entity', {option: 'value'})
      subject.handle_token_authentication_for(User, {option: 'value'})
    end
  end

  describe 'and which supports the :before_filter hook' do

    before(:each) do
      subject.stub(:before_filter)
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
    end
  end
end
