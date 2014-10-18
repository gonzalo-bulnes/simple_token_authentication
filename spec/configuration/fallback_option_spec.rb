require 'spec_helper'

describe 'Simple Token Authentication' do

  describe ':fallback option', fallback_option: true do

    describe 'determines what to do if token authentication fails' do

      before(:each) do
        user = double()
        stub_const('User', user)
        user.stub(:name).and_return('User')

        # given a controller class which acts as token authentication handler
        @controller_class = Class.new
        @controller_class.stub(:before_filter)
        @controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

        @controller = @controller_class.new
        @controller.stub(:params)
        @controller.stub(:find_record_from_identifier)
      end

      context 'when :none' do

        it 'does nothing after token authentication fails', protected: true do
          @controller = @controller_class.new
          @controller.stub(:params)
          @controller.stub(:find_record_from_identifier)

          # sets :authenticate_user_from_token (non-bang) in the before_filter
          expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token, {})

          # when falling back to Devise is enabled
          @controller_class.acts_as_token_authentication_handler_for User, fallback: :none

          # when the hook is triggered
          # Devise strategies do not take control of authentication
          expect(@controller).not_to receive(:authenticate_user!)
          @controller.authenticate_user_from_token # non-bang
        end
      end

      context 'when :devise' do

        it 'delegates authentication to Devise strategies', protected: true do
          # sets :authenticate_user_from_token! (bang) in the before_filter
          expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token!, {})

          # when falling back to Devise is enabled
          @controller_class.acts_as_token_authentication_handler_for User, fallback: :devise

          # when the hook is triggered
          # Devise strategies take control of authentication
          expect(@controller).to receive(:authenticate_user!)
          @controller.authenticate_user_from_token! # bang
        end
      end
    end
  end
end
