require 'spec_helper'

describe SimpleTokenAuthentication::SignInHandler do

  it_behaves_like 'a sign in handler'

  it 'delegates sign in to Devise::Controllers::SignInOut#sign_in through a controller', private: true do
    controller = double()
    allow(controller).to receive(:sign_in).with(:record, option: 'some_value').and_return('Devise response.')

    # delegating consists in sending the message
    expect(controller).to receive(:sign_in)
    response = subject.sign_in(controller, :record, option: 'some_value')

    # and returning the response
    expect(response).to eq 'Devise response.'
  end
end
