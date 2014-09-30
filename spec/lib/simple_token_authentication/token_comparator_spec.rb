require 'spec_helper'

describe SimpleTokenAuthentication::TokenComparator do

  it_behaves_like 'a token comparator'

  it 'delegates token comparison to Devise.secure_compare', private: true do
    devise = double()
    allow(devise).to receive(:secure_compare).and_return('Devise.secure_compare response.')
    stub_const('Devise', devise)

    # delegating consists in sending the message
    expect(Devise).to receive(:secure_compare)
    response = subject.compare('A_raNd0MtoKeN', 'ano4heR-Tok3n')

    # and returning the response
    expect(response).to eq 'Devise.secure_compare response.'
  end
end
