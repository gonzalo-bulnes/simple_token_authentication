RSpec.shared_examples 'a token generator' do

  let(:token_generator) { described_class.instance }

  it 'responds to :generate_token', public: true do
    expect(token_generator).to respond_to :generate_token
  end

  it 'is a kind of Singleton', public: true  do
    expect(token_generator).to be_kind_of(Singleton)
  end
end

