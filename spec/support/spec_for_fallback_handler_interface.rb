RSpec.shared_examples 'a fallback handler' do

  let(:fallback_handler) { described_class.new() }

  it 'responds to :fallback!', private: true do
    expect(fallback_handler).to respond_to :fallback!
  end
end
