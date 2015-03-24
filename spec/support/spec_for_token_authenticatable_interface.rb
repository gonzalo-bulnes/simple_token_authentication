RSpec.shared_examples 'a token authenticatable' do

  let(:token_authenticatable) { described_class.new() }

  it 'responds to :ensure_authentication_token', private: true do
    expect(token_authenticatable).to respond_to :ensure_authentication_token
  end
end
