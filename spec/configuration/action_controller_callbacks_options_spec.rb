require 'spec_helper'

describe 'ActionController', action_controller_callbacks_options: true do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    double_user_model
    define_test_subjects_for_extension_of(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
  end

  describe ':only option' do

    context 'when provided to `acts_as_token_authentication_hanlder_for`' do

      it 'is applied to the corresponding callback', private: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, { only: ['some_action', :some_other_action] })
          subject.acts_as_token_authentication_handler_for User, only: ['some_action', :some_other_action]
        end
      end
    end
  end

  describe ':except option' do

    context 'when provided to `acts_as_token_authentication_hanlder_for`' do

      it 'is applied to the corresponding callback', private: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, { except: ['some_action', :some_other_action] })
          subject.acts_as_token_authentication_handler_for User, except: ['some_action', :some_other_action]
        end
      end
    end
  end
end
