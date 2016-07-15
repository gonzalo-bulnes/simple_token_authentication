RSpec.shared_examples 'a token authentication handler' do

  let(:token_authentication_handler) { described_class }

  it 'responds to :handle_token_authentication_for', private: true do
    expect(token_authentication_handler).to respond_to :handle_token_authentication_for
  end

  describe 'instance' do

    it 'responds to :after_successful_token_authentication', hooks: true, private: true do
      expect(token_authentication_handler.new).to respond_to :after_successful_token_authentication
    end
  end
end
