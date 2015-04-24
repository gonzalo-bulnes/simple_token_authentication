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

      it 'is applied to the corresponding callback (1)', rspec_3_error: true, private: true do
        some_class = @subjects.first

        expect(some_class).to receive(:before_filter).with(:authenticate_user_from_token!, { only: ['some_action', :some_other_action] })
        some_class.acts_as_token_authentication_handler_for User, only: ['some_action', :some_other_action]
      end

      it 'is applied to the corresponding callback (2)', rspec_3_error: true, private: true do
        some_child_class = @subjects.last

        expect(some_child_class).to receive(:before_filter).with(:authenticate_user_from_token!, { only: ['some_action', :some_other_action] })
        some_child_class.acts_as_token_authentication_handler_for User, only: ['some_action', :some_other_action]
      end
    end
  end

  describe ':except option' do

    context 'when provided to `acts_as_token_authentication_hanlder_for`' do

      it 'is applied to the corresponding callback (1)', rspec_3_error: true, private: true do
        some_class = @subjects.first

        expect(some_class).to receive(:before_filter).with(:authenticate_user_from_token!, { except: ['some_action', :some_other_action] })
        some_class.acts_as_token_authentication_handler_for User, except: ['some_action', :some_other_action]
      end

      it 'is applied to the corresponding callback (2)', rspec_3_error: true, private: true do
        some_child_class = @subjects.last

        expect(some_child_class).to receive(:before_filter).with(:authenticate_user_from_token!, { except: ['some_action', :some_other_action] })
        some_child_class.acts_as_token_authentication_handler_for User, except: ['some_action', :some_other_action]
      end
    end
  end

  describe ':if option' do

    context 'when provided to `acts_as_token_authentication_hanlder_for`' do

      it 'is applied to the corresponding callback (1)', rspec_3_error: true, private: true do
        some_class = @subjects.first

        expect(some_class).to receive(:before_filter).with(:authenticate_user_from_token!, { if: lambda { |controller| 'some condition' } })
        some_class.acts_as_token_authentication_handler_for User, if: lambda { |controller| 'some condition' }
      end

      it 'is applied to the corresponding callback (2)', rspec_3_error: true, private: true do
        some_child_class = @subjects.last

        expect(some_child_class).to receive(:before_filter).with(:authenticate_user_from_token!, { if: lambda { |controller| 'some condition' } })
        some_child_class.acts_as_token_authentication_handler_for User, if: lambda { |controller| 'some condition' }
      end
    end
  end

  describe ':unless option' do

    context 'when provided to `acts_as_token_authentication_hanlder_for`' do

      it 'is applied to the corresponding callback (1)', rspec_3_error: true, private: true do
        some_class = @subjects.first

        expect(some_class).to receive(:before_filter).with(:authenticate_user_from_token!, { unless: lambda { |controller| 'some condition' } })
        some_class.acts_as_token_authentication_handler_for User, unless: lambda { |controller| 'some condition' }
      end

      it 'is applied to the corresponding callback (2)', rspec_3_error: true, private: true do
        some_child_class = @subjects.last

        expect(some_child_class).to receive(:before_filter).with(:authenticate_user_from_token!, { unless: lambda { |controller| 'some condition' } })
        some_child_class.acts_as_token_authentication_handler_for User, unless: lambda { |controller| 'some condition' }
      end
    end
  end
end
