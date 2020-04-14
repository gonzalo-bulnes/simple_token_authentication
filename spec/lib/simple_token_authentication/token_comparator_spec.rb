require 'spec_helper'

describe SimpleTokenAuthentication::TokenComparator do

  let(:token_comparator) { described_class.instance }

  it_behaves_like 'a token comparator'

  it 'delegates token comparison to Devise::Encryptor.compare', private: true do

    # set the config to use hashed persisted tokens
    SimpleTokenAuthentication.persist_token_as = :digest

    encryptor = double()
    allow(encryptor).to receive(:compare).and_return('Devise::Encryptor.compare response.')
    stub_const('Devise::Encryptor', encryptor)

    # delegating consists in sending the message
    expect(Devise::Encryptor).to receive(:compare)
    response = token_comparator.compare('A_raNd0MtoKeN', 'ano4heR-Tok3n')

    # and returning the response
    expect(response).to eq 'Devise::Encryptor.compare response.'
  end

  it 'delegates token comparison to Devise.secure_compare', private: true do

    # set the config to use plaintext persisted tokens
    SimpleTokenAuthentication.persist_token_as = :plain

    devise = double()
    allow(devise).to receive(:secure_compare).and_return('Devise.secure_compare response.')
    stub_const('Devise', devise)

    # delegating consists in sending the message
    expect(Devise).to receive(:secure_compare)
    response = token_comparator.compare('A_raNd0MtoKeN', 'ano4heR-Tok3n')

    # and returning the response
    expect(response).to eq 'Devise.secure_compare response.'
  end
end
