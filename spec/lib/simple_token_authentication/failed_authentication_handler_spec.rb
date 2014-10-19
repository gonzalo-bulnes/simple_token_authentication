require 'spec_helper'

describe SimpleTokenAuthentication::FailedAuthenticationHandler do

  it_behaves_like 'an authentication handler'

  describe '#authenticate_entity!' do

    it 'throws an authentication error', private: true do
      controller = double()
      entity = double()
      entity.stub_chain(:name_underscore).and_return('user')

      expect { subject.authenticate_entity!(controller, entity) }.to \
        throw_symbol(:warden, scope: :user)
    end

    it 'does something else', private: true do
      # Throwing a symbol is not an end in itself, and the thrown :warden
      # must be catched somewhere so a failure app can do that "something else",
      # which, of course, must be previously to be defined and described here.
      fail 'Missing feature definition.'
    end
  end
end
