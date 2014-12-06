require 'spec_helper'

describe SimpleTokenAuthentication::SignInHandler do

  it_behaves_like 'a sign in handler'

  describe '#sign_in' do

    it 'delegates sign in to Devise::Controllers::SignInOut#sign_in through a controller', private: true do
      controller = double()
      allow(controller).to receive(:sign_in).with(:record, option: 'some_value').and_return('Devise response.')
      allow(controller).to receive(:env).and_return({})

      # delegating consists in sending the message
      expect(controller).to receive(:sign_in)
      response = subject.sign_in(controller, :record, option: 'some_value')

      # and returning the response
      expect(response).to eq 'Devise response.'
    end

    it 'integrates with Devise trackable', protected: true do
      controller = double()
      allow(controller).to receive(:sign_in).with(:record)
      allow(controller).to receive(:integrate_with_devise_trackable!)

      expect(subject).to receive(:integrate_with_devise_trackable!).with(controller)
      subject.sign_in(controller, :record)
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
        allow(controller).to receive(:env).and_return(env)
        expect(env).to receive(:[]=).with('devise.skip_trackable', true)

        subject.send :integrate_with_devise_trackable!, controller
      end
    end


    context 'when the :skip_devise_trackable option is false', skip_devise_trackable_option: true do

      before(:each) do
        allow(SimpleTokenAuthentication).to receive(:skip_devise_trackable).and_return(false)
      end

      it 'ensures Devise trackable statistics are updated', private: true do
        controller = double()
        env = double()
        allow(controller).to receive(:env).and_return(env)
        expect(env).to receive(:[]=).with('devise.skip_trackable', false)

        subject.send :integrate_with_devise_trackable!, controller
      end
    end
  end
end

