require 'spec_helper'

describe 'Simple Token Authentication' do

  describe ':fallback_to_devise option', fallback_to_devise_option: true, fallback_option: true do

    describe 'determines what to do if token authentication fails' do

      before(:each) do
        user = double()
        stub_const('User', user)
        user.stub(:name).and_return('User')

        # given a controller class which acts as token authentication handler
        @controller_class = Class.new
        @controller_class.stub(:before_filter)
        @controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
      end

      context 'when true' do

        it 'delegates authentication to Devise strategies', protected: true do
          @controller = @controller_class.new
          @controller.stub(:params)
          @controller.stub(:find_record_from_identifier)

          # sets :authenticate_user_from_token! (bang) in the before_filter
          expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token!, {})

          # when falling back to Devise is enabled
          @controller_class.acts_as_token_authentication_handler_for User, fallback_to_devise: true

          # when the hook is triggered
          # Devise strategies take control of authentication
          expect(@controller).to receive(:authenticate_user!)
          @controller.authenticate_user_from_token! # bang
        end
      end

      context 'when false' do

        it 'does nothing after token authentication fails', protected: true do
          @controller = @controller_class.new
          @controller.stub(:params)
          @controller.stub(:find_record_from_identifier)

          # sets :authenticate_user_from_token (non-bang) in the before_filter
          expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token, {})

          # when falling back to Devise is enabled
          @controller_class.acts_as_token_authentication_handler_for User, fallback_to_devise: false

          # when the hook is triggered
          # Devise strategies do not take control of authentication
          expect(@controller).not_to receive(:authenticate_user!)
          @controller.authenticate_user_from_token # non-bang
        end
      end

      context 'when omitted' do

        it 'delegates authentication to Devise strategies', protected: true do
          @controller = @controller_class.new
          @controller.stub(:params)
          @controller.stub(:find_record_from_identifier)

          # sets :authenticate_user_from_token! (bang) in the before_filter
          expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token!, {})

          # when falling back to Devise is enabled
          @controller_class.acts_as_token_authentication_handler_for User

          # when the hook is triggered
          # Devise strategies take control of authentication
          expect(@controller).to receive(:authenticate_user!)
          @controller.authenticate_user_from_token! # bang
        end
      end

      describe 'in a per-model (token authenticatable) way' do

        before(:each) do
          admin = double()
          stub_const('Admin', admin)
          admin.stub(:name).and_return('Admin')
        end

        context 'when false for User and true for Admin' do

          before(:each) do
            @controller = @controller_class.new
            @controller.stub(:params)
            @controller.stub(:find_record_from_identifier)

            # sets :authenticate_user_from_token (non-bang) in the before_filter
            expect(@controller_class).to receive(:before_filter).with(:authenticate_user_from_token, {})
            # sets :authenticate_admin_from_token! (bang) in the before_filter
            expect(@controller_class).to receive(:before_filter).with(:authenticate_admin_from_token!, {})

            # when falling back to Devise is enabled for Admin but not User
            @controller_class.acts_as_token_authentication_handler_for User, fallback_to_devise: false
            @controller_class.acts_as_token_authentication_handler_for Admin, fallback_to_devise: true
          end

          context 'after no user suceeds token authentication' do

            it 'does nothing', protected: true do
              # when the user hook is triggered
              # Devise strategies do not take control of authentication
              expect(@controller).not_to receive(:authenticate_user!)
              @controller.authenticate_user_from_token
            end
          end

          context 'after no admin succeeds token authentication' do

            it 'does delegate authentication to Devise', protected: true do
              # when the admin hook is triggered
              # Devise strategies do take control of authentication
              expect(@controller).to receive(:authenticate_admin!)
              @controller.authenticate_admin_from_token!
            end
          end
        end
      end
    end
  end
end
