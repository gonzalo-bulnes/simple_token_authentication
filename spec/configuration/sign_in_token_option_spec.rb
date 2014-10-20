require 'spec_helper'

describe 'Simple Token Authentication' do

  describe ':sign_in_token option', sign_in_token_option: true do

    describe 'determines if the session will be stored' do

      before(:each) do
        user = double()
        stub_const('User', user)
        user.stub(:name).and_return('User')
        @record = double()
        user.stub(:find_by).and_return(@record)

        # given a controller class which acts as token authentication handler
        controller_class = Class.new
        controller_class.stub(:before_filter)
        controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
        # and handles authentication for a given model
        controller_class.acts_as_token_authentication_handler_for User

        @controller = controller_class.new
        @controller.stub(:params)
        # and there are credentials for a record of that model in params or headers
        @controller.stub(:get_identifier_from_params_or_headers)
        # and both identifier and authentication token are correct
        @controller.stub(:find_record_from_identifier).and_return(@record)
        @controller.stub(:token_correct?).and_return(true)
        @controller.stub(:env).and_return({})
      end

      context 'when false' do

        it 'does instruct Devise not to store the session', public: true do
          SimpleTokenAuthentication.stub(:sign_in_token).and_return(false)

          expect(@controller).to receive(:sign_in).with(@record, store: false)
          @controller.authenticate_user_from_token
        end
      end

      context 'when true' do

        it 'does instruct Devise to store the session', public: true do
          SimpleTokenAuthentication.stub(:sign_in_token).and_return(true)

          expect(@controller).to receive(:sign_in).with(@record, store: true)
          @controller.authenticate_user_from_token
        end
      end
    end

    it 'can be modified from an initializer file', public: true do
      user = double()
      stub_const('User', user)
      user.stub(:name).and_return('User')
      @record = double()
      user.stub(:find_by).and_return(@record)

      # given a controller class which acts as token authentication handler
      controller_class = Class.new
      controller_class.stub(:before_filter)
      controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

      SimpleTokenAuthentication.stub(:sign_in_token).and_return('initial value')
      # INITIALIZATION
      # this step occurs when 'simple_token_authentication' is required
      #
      # given the controller class handles token authentication for a model
      controller_class.acts_as_token_authentication_handler_for User

      # RUNTIME
      @controller = controller_class.new
      @controller.stub(:params)
      # and there are credentials for a record of that model in params or headers
      @controller.stub(:get_identifier_from_params_or_headers)
      # and both identifier and authentication token are correct
      @controller.stub(:find_record_from_identifier).and_return(@record)
      @controller.stub(:token_correct?).and_return(true)
      @controller.stub(:env).and_return({})

      # even if modified *after* the class was loaded
      SimpleTokenAuthentication.stub(:sign_in_token).and_return('updated value')

      # the option updated value is taken into account
      # when token authentication is performed
      expect(@controller).to receive(:sign_in).with(@record, store: 'updated value')
      @controller.authenticate_user_from_token
    end
  end
end
