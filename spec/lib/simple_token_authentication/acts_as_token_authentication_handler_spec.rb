require 'spec_helper'

def ignore_cucumber_hack
  skip_rails_test_environment_code
end

# Skip the code intended to be run in the Rails test environment
def skip_rails_test_environment_code
  rails = double()
  stub_const('Rails', rails)
  allow(rails).to receive_message_chain(:env, :test?).and_return(false)
end

describe 'Any class which extends SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler (or any if its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for_extension_of(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
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

  it 'doesn\'t behave like a token authentication handler', public: true do
    stub_const('SimpleTokenAuthentication::TokenAuthenticationHandler', Module.new)

    @subjects.each do |subject|
      expect(subject).not_to be_include SimpleTokenAuthentication::TokenAuthenticationHandler
    end
  end

  context 'when it explicitely acts as a token authentication handler' do

    it 'behaves like a token authentication handler', public: true do
      double_user_model
      stub_const('SimpleTokenAuthentication::TokenAuthenticationHandler', Module.new)

      @subjects.each do |subject|
        allow(subject).to receive(:handle_token_authentication_for)

        subject.acts_as_token_authentication_handler_for User
        expect(subject).to be_include SimpleTokenAuthentication::TokenAuthenticationHandler
      end
    end
  end

  describe '.acts_as_token_authentication_handler_for' do

    it 'ensures the receiver class does handle token authentication for a given (token authenticatable) model', public: true do
      double_user_model

      @subjects.each do |subject|
        allow(subject).to receive(:before_filter)

        expect(subject).to receive(:include).with(SimpleTokenAuthentication::TokenAuthenticationHandler)
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
        allow(subject).to receive(:acts_as_token_authentication_handler_for)

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
        allow(subject).to receive(:acts_as_token_authentication_handler_for)

        expect(subject).to receive(:acts_as_token_authentication_handler_for).with(User)

        subject.acts_as_token_authentication_handler
      end
    end
  end
end
