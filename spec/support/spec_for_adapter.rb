RSpec.shared_examples 'an adapter' do

  it 'responds to :base_class', public: true do
    expect(@subject).to respond_to :base_class
  end

  it 'defines :base_class', public: true do
    expect { @subject.base_class }.not_to raise_error
  end
end
