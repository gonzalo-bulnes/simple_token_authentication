RSpec.shared_examples 'an ORM/ODM/OxM adapter' do

  it 'responds to :models_base_class', public: true do
    expect(@subject).to respond_to :models_base_class
  end
end
