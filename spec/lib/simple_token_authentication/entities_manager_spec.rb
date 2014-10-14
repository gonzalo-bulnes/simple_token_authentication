require 'spec_helper'

describe SimpleTokenAuthentication::EntitiesManager do

  # The 'model' argument is quite vague, as it is for Entity;
  # let's do nothing to solve that undefinition for now.

  it_behaves_like 'an entities manager'

  before(:each) do
    entity = double()
    allow(entity).to receive(:new).and_return('an Entity instance')
    stub_const('SimpleTokenAuthentication::Entity', entity)

    super_user = double()
    allow(super_user).to receive(:name) # any Ruby class has a name
    stub_const('SuperUser', super_user)
  end

  describe '#find_or_create_entity' do

    context 'when a model is provided for the first time' do

      it 'creates an Entity instance for the model', private: true do
        expect(SimpleTokenAuthentication::Entity).to receive(:new).with(SuperUser)
        expect(subject.find_or_create_entity(SuperUser)).to eq 'an Entity instance'
      end

      context 'even if Entity instances for other models exist', private: true do

        before(:each) do
          # define another model
          admin = double()
          allow(admin).to receive(:name).and_return('Admin')
          stub_const('Admin', admin)
          # ensure its Entity instance exists
          subject.find_or_create_entity(Admin)
          allow(SimpleTokenAuthentication::Entity).to receive(:new).and_return('some new Entity instance')
        end

        it 'creates an Entity instance for the model', private: true do
          expect(SimpleTokenAuthentication::Entity).to receive(:new).with(SuperUser)
          expect(subject.find_or_create_entity(SuperUser)).to eq 'some new Entity instance'
        end
      end
    end

    context 'when an Entity instance for that model already exists' do

      before(:each) do
        allow(SuperUser).to receive(:name).and_return('SuperUser')
        subject.find_or_create_entity(SuperUser)

        allow(SimpleTokenAuthentication::Entity).to receive(:new).and_return('some new Entity instance')
      end

      it 'returns that Entity instance', private: true do
        expect(subject.find_or_create_entity(SuperUser)).to eq 'an Entity instance'
      end

      it 'does not create a new Entity instance', private: true do
        expect(SimpleTokenAuthentication::Entity).not_to receive(:new).with(SuperUser)
        subject.find_or_create_entity(SuperUser)
      end
    end
  end

  describe '#entities' do

    it 'returns an Array of the available Entities', private: true do
      # create an entity
      subject.find_or_create_entity(SuperUser)

      entities = subject.entities

      expect(entities).to be_instance_of Array

      entities.each do |item|
        # kind of 'be instance_of SimpleTokenAuthentication::Entity' with a double
        expect(item).to eq 'an Entity instance'
      end

      # one entity has been created
      expect(entities.count).to eq 1
    end
  end
end
