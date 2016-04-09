RSpec.shared_examples 'a sign in handler' do

  let(:sign_in_handler) { described_class.instance }

  it 'responds to :sign_in', private: true do
    expect(sign_in_handler).to respond_to :sign_in
  end

  it 'is a kind of Singleton', private: true  do
    expect(sign_in_handler).to be_kind_of(Singleton)
  end
end
