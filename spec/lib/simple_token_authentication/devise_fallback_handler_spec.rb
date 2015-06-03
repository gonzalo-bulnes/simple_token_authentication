require 'spec_helper'

describe SimpleTokenAuthentication::DeviseFallbackHandler do

  it_behaves_like 'an authentication handler'

  it_behaves_like 'a fallback handler'

  describe '#authenticate_entity!' do

    it 'delegates authentication to Devise::Controllers::Helpers through a controller', private: true do
      controller = double()
      allow(controller).to receive(:authenticate_user!).and_return('Devise response.')

      entity = double()
      allow(entity).to receive_message_chain(:name_underscore).and_return('user')

      # delegating consists in sending the message
      expect(controller).to receive(:authenticate_user!)
      response = subject.authenticate_entity!(controller, entity)

      # and returning the response
      expect(response).to eq 'Devise response.'
    end
  end

  describe '#fallback!' do

    it 'does #authenticate_entity!', private: true do
      entity = double()
      allow(@entity).to receive_message_chain(:name_underscore).and_return('entity')
      controller = double()

      expect(subject).to receive(:authenticate_entity!).with(controller, entity)

      subject.send(:fallback!, controller, entity)
    end
  end
end
