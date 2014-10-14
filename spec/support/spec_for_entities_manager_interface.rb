RSpec.shared_examples 'an entities manager' do

  let(:entities_manager) { described_class.new() }

  it 'responds to :find_or_create_entity', private: true do
    expect(entities_manager).to respond_to :find_or_create_entity
  end

  it 'responds to :entities', private: true do
    expect(entities_manager).to respond_to :entities
  end
end
