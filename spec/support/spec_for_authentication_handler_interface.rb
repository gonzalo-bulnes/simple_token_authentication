RSpec.shared_examples 'an authentication handler' do

  let(:authentication_handler) { described_class.new() }

  it 'responds to :authenticate_entity!', private: true do
    expect(authentication_handler).to respond_to :authenticate_entity!
  end
end
