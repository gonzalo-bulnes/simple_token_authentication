require 'spec_helper'

def ignore_cucumber_hack
  skip_rails_test_environment_code
end

# Skip the code intended to be run in the Rails test environment
def skip_rails_test_environment_code
  rails = double()
  stub_const('Rails', rails)
  rails.stub_chain(:env, :test?).and_return(false)
end

describe 'Any class which includes SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler (or any if its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
  end

  it 'responds to :acts_as_token_authentication_handler_for', public: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authentication_handler_for
    end
  end

  it 'responds to :acts_as_token_authentication_handler', public: true, deprecated: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authentication_handler
    end
  end

  describe 'which support the :before_filter hook' do


    before(:each) do
      @subjects.each do |subject|
        subject.stub(:before_filter)
      end
    end

    # User

    context 'and which acts as token authentication handler for User' do

      before(:each) do
        ignore_cucumber_hack
        double_user_model
      end

      it 'ensures its instances require user to authenticate from token or any Devise strategy before any action', public: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, {})
          subject.acts_as_token_authentication_handler_for User
        end
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require user to authenticate from token before any action', public: true do
          @subjects.each do |subject|
            expect(subject).to receive(:before_filter).with(:authenticate_user_from_token, {})
            subject.acts_as_token_authentication_handler_for User, options
          end
        end
      end

      describe 'instance' do

        before(:each) do
          ignore_cucumber_hack
          double_user_model

          klass = define_dummy_class_which_includes(
                    SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
          klass.class_eval do
            acts_as_token_authentication_handler_for User
          end

          child_klass = define_dummy_class_child_of(klass)
          @subjects   = [klass.new, child_klass.new]
        end

        it 'responds to :authenticate_user_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_user_from_token
          end
        end

        it 'responds to :authenticate_user_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_user_from_token!
          end
        end

        it 'does not respond to :authenticate_super_admin_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_super_admin_from_token
          end
        end

        it 'does not respond to :authenticate_super_admin_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_super_admin_from_token!
          end
        end
      end
    end

    # SuperAdmin

    context 'and which acts as token authentication handler for SuperAdmin' do

      before(:each) do
        ignore_cucumber_hack
        double_super_admin_model
      end

      it 'ensures its instances require super_admin to authenticate from token or any Devise strategy before any action', public: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token!, {})
          subject.acts_as_token_authentication_handler_for SuperAdmin
        end
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require super_admin to authenticate from token before any action', public: true do
          @subjects.each do |subject|
            expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token, {})
            subject.acts_as_token_authentication_handler_for SuperAdmin, options
          end
        end
      end

      describe 'instance' do

        # ! to ensure it gets defined before subjects
        before(:each) do
          ignore_cucumber_hack
          double_super_admin_model

          klass = define_dummy_class_which_includes(
                    SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
          klass.class_eval do
            acts_as_token_authentication_handler_for SuperAdmin
          end

          child_klass = define_dummy_class_child_of(klass)
          @subjects   = [klass.new, child_klass.new]
        end

        it 'responds to :authenticate_super_admin_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_super_admin_from_token
          end
        end

        it 'responds to :authenticate_super_admin_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_super_admin_from_token!
          end
        end

        it 'does not respond to :authenticate_user_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_user_from_token
          end
        end

        it 'does not respond to :authenticate_user_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_user_from_token!
          end
        end
      end
    end
  end
end

describe 'Any class which includes SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler (or any if its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
  end

  describe '.acts_as_token_authentication_handler_for' do

    it 'ensures the receiver class does handle token authentication for a given (token authenticatable) model', public: true do
      double_user_model

      @subjects.each do |subject|
        subject.stub(:before_filter)

        expect(subject).to receive(:include).with(SimpleTokenAuthentication::TokenAuthenticationHandler)
        expect(subject).to receive(:include).with(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods)
        expect(subject).to receive(:handle_token_authentication_for).with(User, { option: 'value' })

        subject.acts_as_token_authentication_handler_for User, { option: 'value' }
      end
    end
  end

  describe '.acts_as_token_authentication_handler', deprecated: true do

    it 'issues a deprecation warning', public: true do
      double_user_model

      @subjects.each do |subject|
        deprecation_handler = double()
        stub_const('ActiveSupport::Deprecation', deprecation_handler)
        subject.stub(:acts_as_token_authentication_handler_for)

        expect(deprecation_handler).to receive(:warn)

        subject.acts_as_token_authentication_handler
      end
    end

    it 'is replaced by .acts_as_token_authentication_handler_for', public: true do
      double_user_model

      @subjects.each do |subject|
        deprecation_handler = double()
        allow(deprecation_handler).to receive(:warn)
        stub_const('ActiveSupport::Deprecation', deprecation_handler)
        subject.stub(:acts_as_token_authentication_handler_for)

        expect(subject).to receive(:acts_as_token_authentication_handler_for).with(User)

        subject.acts_as_token_authentication_handler
      end
    end
  end
end
