RSpec.shared_examples 'a token generator' do

  let(:token_generator) { described_class.new() }

  it 'responds to :generate_token', public: true do
    expect(token_generator).to respond_to :generate_token
  end
end
