require 'spec_helper'

describe SimpleTokenAuthentication::TokenGenerator do

  it_behaves_like 'a token generator'

  it 'delegates token generation to Devise.friendly_token', private: true do
    devise = double()
    allow(devise).to receive(:friendly_token).and_return('FRi3ndlY_TokeN')
    stub_const('Devise', devise)

    # delegating consists in sending the message
    expect(Devise).to receive(:friendly_token)
    response = subject.generate_token

    # and returning the response
    expect(response).to eq 'FRi3ndlY_TokeN'
  end
end
