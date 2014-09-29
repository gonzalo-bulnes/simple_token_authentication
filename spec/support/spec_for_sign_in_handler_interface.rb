RSpec.shared_examples 'a sign in handler' do

  let(:sign_in_hanlder) { described_class.new() }

  it 'responds to :sign_in', private: true do
    expect(sign_in_hanlder).to respond_to :sign_in
  end
end
