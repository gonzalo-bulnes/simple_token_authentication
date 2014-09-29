require 'spec_helper'

describe SimpleTokenAuthentication::Entity do

  before(:each) do
    user = double()
    user.stub(:name).and_return('SuperUser')
    stub_const('SuperUser', user)

    @subject = SimpleTokenAuthentication::Entity.new(SuperUser)
  end

  it 'responds to :model', protected: true do
    expect(@subject).to respond_to :model
  end

  it 'responds to :name', protected: true do
    expect(@subject).to respond_to :name
  end

  it 'responds to :name_underscore', protected: true do
    expect(@subject).to respond_to :name_underscore
  end

  it 'responds to :token_header_name', protected: true do
    expect(@subject).to respond_to :token_header_name
  end

  it 'responds to :identifier_header_name', protected: true do
    expect(@subject).to respond_to :identifier_header_name
  end

  it 'responds to :token_param_name', protected: true do
    expect(@subject).to respond_to :token_param_name
  end

  it 'responds to :identifier_param_name', protected: true do
    expect(@subject).to respond_to :identifier_param_name
  end

  describe '#model' do
    it 'is a constant', protected: true do
      expect(@subject.model).to eq SuperUser
    end
  end

  describe '#name' do
    it 'is a camelized String', protected: true do
      expect(@subject.name).to be_instance_of String
      expect(@subject.name).to eq @subject.name.camelize
    end
  end

  describe '#name_underscore', protected: true do
    it 'is an underscored String' do
      expect(@subject.name_underscore).to be_instance_of String
      expect(@subject.name_underscore).to eq @subject.name_underscore.underscore
    end
  end

  describe '#token_header_name', protected: true do
    it 'is a String' do
      expect(@subject.token_header_name).to be_instance_of String
    end

    it 'defines a non-standard header field' do
      expect(@subject.token_header_name[0..1]).to eq 'X-'
    end
  end

  describe '#identifier_header_name', protected: true do
    it 'is a String' do
      expect(@subject.identifier_header_name).to be_instance_of String
    end

    it 'defines a non-standard header field' do
      expect(@subject.identifier_header_name[0..1]).to eq 'X-'
    end
  end

  describe '#token_param_name', protected: true do
    it 'is a Symbol' do
      expect(@subject.token_param_name).to be_instance_of Symbol
    end
  end

  describe '#identifier_param_name', protected: true do
    it 'is a Symbol' do
      expect(@subject.identifier_param_name).to be_instance_of Symbol
    end
  end
end
