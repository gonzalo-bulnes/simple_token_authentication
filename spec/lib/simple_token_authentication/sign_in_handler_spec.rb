require 'spec_helper'

describe SimpleTokenAuthentication::SignInHandler do

  let(:sign_in_handler) { SimpleTokenAuthentication::SignInHandler.instance }

  it_behaves_like 'a sign in handler'

  describe '#sign_in' do

    it 'delegates sign in to Devise::Controllers::SignInOut#sign_in through a controller', private: true do
      controller = double()
      env = double()
      request = double()
      allow(request).to receive(:env).and_return({})
      allow(controller).to receive(:request).and_return(request)
      allow(controller).to receive(:sign_in).with(:record, { option: 'some_value' }).and_return('Devise response.')

      # delegating consists in sending the message
      expect(controller).to receive(:sign_in)
      response = sign_in_handler.sign_in(controller, :record, option: 'some_value')

      # and returning the response
      expect(response).to eq 'Devise response.'
    end

    it 'integrates with Devise trackable', protected: true do
      controller = double()
      allow(controller).to receive(:sign_in).with(:record)
      allow(controller).to receive(:integrate_with_devise_trackable!)

      expect(sign_in_handler).to receive(:integrate_with_devise_trackable!).with(controller)
      sign_in_handler.sign_in(controller, :record)
    end
  end

  describe '#integrate_with_devise_trackable!' do

    context 'when the :skip_devise_trackable option is true', skip_devise_trackable_option: true do

      before(:each) do
        allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return(true)
      end

      it 'ensures Devise trackable statistics are kept untouched', private: true do
        controller = double()
        env = double()
        request = double()
        allow(request).to receive(:env).and_return(env)
        allow(controller).to receive(:request).and_return(request)
        expect(env).to receive(:[]=).with('devise.skip_trackable', true)

        sign_in_handler.send :integrate_with_devise_trackable!, controller
      end
    end


    context 'when the :skip_devise_trackable option is false', skip_devise_trackable_option: true do

      before(:each) do
        allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return(false)
      end

      it 'ensures Devise trackable statistics are updated', private: true do
        controller = double()
        env = double()
        request = double()
        allow(request).to receive(:env).and_return(env)
        allow(controller).to receive(:request).and_return(request)
        expect(env).to receive(:[]=).with('devise.skip_trackable', false)

        sign_in_handler.send :integrate_with_devise_trackable!, controller
      end
    end
  end
end

