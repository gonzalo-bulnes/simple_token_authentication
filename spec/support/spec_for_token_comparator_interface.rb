RSpec.shared_examples 'a token comparator' do

  let(:token_comparator) { described_class.new() }

  it 'responds to :compare', public: true do
    expect(token_comparator).to respond_to :compare
  end
end
