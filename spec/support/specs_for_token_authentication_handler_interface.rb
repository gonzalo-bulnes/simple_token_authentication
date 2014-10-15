RSpec.shared_examples 'a token authentication handler' do

  let(:token_authentication_handler) { described_class }

  it 'responds to :handle_token_authentication_for', private: true do
    expect(token_authentication_handler).to respond_to :handle_token_authentication_for
  end
end
