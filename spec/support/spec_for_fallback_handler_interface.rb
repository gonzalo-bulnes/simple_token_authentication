RSpec.shared_examples 'a fallback handler' do

  let(:fallback_handler) { described_class.instance }

  it 'responds to :fallback!', private: true do
    expect(fallback_handler).to respond_to :fallback!
  end

  it 'is a kind of Singleton', private: true  do
    expect(fallback_handler).to be_kind_of(Singleton)
  end
end
