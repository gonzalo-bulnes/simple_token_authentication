RSpec.shared_examples 'an ORM/ODM/OxM adapter' do

  it 'responds to :base_class', public: true do
    expect(@subject).to respond_to :base_class
  end
end
