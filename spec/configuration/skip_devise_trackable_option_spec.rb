require 'spec_helper'

describe SimpleTokenAuthentication do

  describe ':skip_devise_trackable option', skip_devise_trackable_option: true do

    describe 'determines if token authentication should increment the tracking statistics', before_filter: true, before_action: true do

      before(:each) do
        user = double()
        stub_const('User', user)
        allow(user).to receive(:name).and_return('User')
        @record = double()
        allow(user).to receive(:find_by).and_return(@record)

        # given a controller class which acts as token authentication handler
        controller_class = Class.new
        allow(controller_class).to receive(:before_filter)
        allow(controller_class).to receive(:before_action)
        controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
        controller_class.acts_as_token_authentication_handler_for User

        @controller = controller_class.new
        allow(@controller).to receive(:params)
        # and there are credentials for a record of that model in params or headers
        allow(@controller).to receive(:get_identifier_from_params_or_headers)
        # and both identifier and authentication token are correct
        allow(@controller).to receive(:find_record_from_identifier).and_return(@record)
        allow(@controller).to receive(:token_correct?).and_return(true)
        allow(@controller).to receive(:env).and_return({})
        allow(@controller).to receive(:sign_in)
      end

      context 'when true', public: true do

        it 'instructs Devise to track token-authentication-related signins' do
          allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return(true)

          expect(@controller).to receive_message_chain(:env, :[]=).with('devise.skip_trackable', true)
          @controller.authenticate_user_from_token
        end
      end

      context 'when false', public: true do

        it 'instructs Devise not to track token-authentication-related signins' do
          allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return(false)

          expect(@controller).to receive_message_chain(:env, :[]=).with('devise.skip_trackable', false)
          @controller.authenticate_user_from_token
        end
      end
    end

    it 'can be modified from an initializer file', public: true, before_filter: true, before_action: true do
      user = double()
      stub_const('User', user)
      allow(user).to receive(:name).and_return('User')
      @record = double()
      allow(user).to receive(:find_by).and_return(@record)

      # given a controller class which acts as token authentication handler
      controller_class = Class.new
      allow(controller_class).to receive(:before_filter)
      allow(controller_class).to receive(:before_action)
      controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

      allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return('initial value')
      # INITIALIZATION
      # this step occurs when 'simple_token_authentication' is required
      #
      # given the controller class handles token authentication for a model
      controller_class.acts_as_token_authentication_handler_for User

      # RUNTIME
      @controller = controller_class.new
      allow(@controller).to receive(:params)
      # and there are credentials for a record of that model in params or headers
      allow(@controller).to receive(:get_identifier_from_params_or_headers)
      # and both identifier and authentication token are correct
      allow(@controller).to receive(:find_record_from_identifier).and_return(@record)
      allow(@controller).to receive(:token_correct?).and_return(true)
      allow(@controller).to receive(:env).and_return({})
      allow(@controller).to receive(:sign_in)

      # even if modified *after* the class was loaded
      allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return('updated value')

      # the option updated value is taken into account
      # when token authentication is performed
      expect(@controller).to receive_message_chain(:env, :[]=).with('devise.skip_trackable', 'updated value')
      @controller.authenticate_user_from_token
    end
  end
end

