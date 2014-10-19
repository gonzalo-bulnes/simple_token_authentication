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
  end
end
