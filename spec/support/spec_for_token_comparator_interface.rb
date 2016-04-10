RSpec.shared_examples 'a token comparator' do

  let(:token_comparator) { described_class.instance }

  it 'responds to :compare', public: true do
    expect(token_comparator).to respond_to :compare
  end

  it 'is a kind of Singleton', private: true  do
    expect(token_comparator).to be_kind_of(Singleton)
  end
end
