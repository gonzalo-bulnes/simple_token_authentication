require 'spec_helper'

describe SimpleTokenAuthentication::SignInHandler do

  it_behaves_like 'a sign in handler'

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

  describe '#sign_in' do

    it 'integrates with Devise trackable', protected: true do
      controller = double()
      allow(controller).to receive(:sign_in).with(:record)
      allow(controller).to receive(:integrate_with_devise_trackable!)

      expect(subject).to receive(:integrate_with_devise_trackable!).with(controller)
      subject.sign_in(controller, :record)
    end
  end

  describe '#integrate_with_devise_trackable!' do

    it 'ensures Devise trackable statistics are kept clean', private: true do
      controller = double()
      env = double()
      allow(controller).to receive(:env).and_return(env)
      expect(env).to receive(:[]=).with('devise.skip_trackable', true)

      subject.send :integrate_with_devise_trackable!, controller
    end
  end
end
