require 'spec_helper'

describe SimpleTokenAuthentication::ExceptionFallbackHandler do

  it_behaves_like 'a fallback handler'

  describe '#fallback!' do

    context 'when authentication failed' do

      before(:each) do
        @entity = double()
        allow(@entity).to receive_message_chain(:name_underscore).and_return('entity')
        @controller = double()

        allow(@controller).to receive(:current_entity).and_return(nil)
      end

      it 'delegates exception throwing to Warden', private: true do
        expect{ subject.fallback!(@controller, @entity) }.to throw_symbol(:warden, scope: :entity)
      end
    end

    context 'when authentication was successful' do

      before(:each) do
        @entity = double()
        allow(@entity).to receive_message_chain(:name_underscore).and_return('entity')
        @controller = double()

        allow(@controller).to receive(:current_entity).and_return('some entity')
      end

      it 'does not throw any exception', private: true do
        expect{ subject.fallback!(@controller, @entity) }.not_to throw_symbol(:warden, scope: :entity)
      end
    end
  end
end
