require 'spec_helper'

describe SimpleTokenAuthentication::Entity do

  before(:each) do
    user = double()
    allow(user).to receive(:name).and_return('SuperUser')
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

  it 'responds to :get_token_from_params_or_headers', protected: true do
    expect(@subject).to respond_to :get_token_from_params_or_headers
  end

  it 'responds to :get_identifier_from_params_or_headers', protected: true do
    expect(@subject).to respond_to :get_identifier_from_params_or_headers
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

    it 'can be predefined', token_authenticatable_aliases_option: true do
      @subject = SimpleTokenAuthentication::Entity.new(SuperUser, 'incognito_super_user')

      expect(@subject.name_underscore).to eq 'incognito_super_user'
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

  describe '#identifier_header_name', protected: true, identifiers_option: true do

    it 'is a String' do
      expect(@subject.identifier_header_name).to be_instance_of String
    end

    it 'defines a non-standard header field' do
      expect(@subject.identifier_header_name[0..1]).to eq 'X-'
    end

    it 'returns the default header for the default identifier' do
      expect(@subject.identifier_header_name).to eq 'X-SuperUser-Email'
    end

    context 'when a custom identifier is defined' do

      before(:each) do
        allow(SimpleTokenAuthentication).to receive(:identifiers).
          and_return({ super_user: :phone_number })
      end

      it 'returns the default header name for that custom identifier' do
        expect(@subject.identifier_header_name).to eq 'X-SuperUser-PhoneNumber'
      end

      context 'when a custom header name is defined for that custom identifer' do

        it 'returns the custom header name for that custom identifier' do
          allow(SimpleTokenAuthentication).to receive(:header_names).
            and_return({ super_user: { phone_number: 'X-Custom' } })
          expect(@subject.identifier_header_name).to eq 'X-Custom'
        end
      end
    end
  end

  describe '#token_param_name', protected: true do
    it 'is a Symbol' do
      expect(@subject.token_param_name).to be_instance_of Symbol
    end
  end

  describe '#identifier_param_name', protected: true, identifiers_option: true do

    it 'is a Symbol' do
      expect(@subject.identifier_param_name).to be_instance_of Symbol
    end

    it 'returns the default param name for the default identifier' do
      expect(@subject.identifier_param_name).to eq :super_user_email
    end

    context 'when a custom identifier is defined' do

      it 'returns the custom param name for that identifier' do
        allow(SimpleTokenAuthentication).to receive(:identifiers).
          and_return({ super_user: 'phone_number' })
        expect(@subject.identifier_param_name).to eq :super_user_phone_number
      end
    end
  end

  describe '#identifier', protected: true, identifiers_option: true do

    it 'is a Symbol' do
      expect(@subject.identifier).to be_instance_of Symbol
    end

    it 'returns :email' do
      expect(@subject.identifier).to eq :email
    end

    context 'when a custom identifier is defined' do

      it 'returns the custom identifier' do
        allow(SimpleTokenAuthentication).to receive(:identifiers).
          and_return({ super_user: 'phone_number' })
        expect(@subject.identifier).to eq :phone_number
      end
    end
  end

  describe '#get_token_from_params_or_headers', protected: true do

    context 'when a token is present in params' do

      before(:each) do
        @controller = double()
        allow(@controller).to receive(:params).and_return({ super_user_token: 'The_ToKeN' })
      end

      it 'returns that token (String)' do
        expect(@subject.get_token_from_params_or_headers(@controller)).to be_instance_of String
        expect(@subject.get_token_from_params_or_headers(@controller)).to eq 'The_ToKeN'
      end

      context 'and another token is present in the headers' do

        before(:each) do
          allow(@controller).to receive_message_chain(:request, :headers)
                     .and_return({ 'X-SuperUser-Token' => 'HeAd3rs_ToKeN' })
        end

        it 'returns the params token' do
          expect(@subject.get_token_from_params_or_headers(@controller)).to eq 'The_ToKeN'
        end
      end
    end

    context 'when no token is present in params' do

      context 'and a token is present in the headers' do

        before(:each) do
          @controller = double()
          allow(@controller).to receive(:params).and_return({ super_user_token: '' })
          allow(@controller).to receive_message_chain(:request, :headers)
                     .and_return({ 'X-SuperUser-Token' => 'HeAd3rs_ToKeN' })
        end

        it 'returns the headers token' do
          expect(@subject.get_token_from_params_or_headers(@controller)).to eq 'HeAd3rs_ToKeN'
        end
      end
    end
  end

  describe '#get_identifier_from_params_or_headers', protected: true do

    context 'when an identifier is present in params' do

      before(:each) do
        @controller = double()
        allow(@controller).to receive(:params).and_return({ super_user_email: 'alice@example.com' })
      end

      it 'returns that identifier (String)' do
        expect(@subject.get_identifier_from_params_or_headers(@controller)).to be_instance_of String
        expect(@subject.get_identifier_from_params_or_headers(@controller)).to eq 'alice@example.com'
      end

      context 'and another identifier is present in the headers' do

        before(:each) do
          allow(@controller).to receive_message_chain(:request, :headers)
                     .and_return({ 'X-SuperUser-Email' => 'bob@example.com' })
        end

        it 'returns the params identifier' do
          expect(@subject.get_identifier_from_params_or_headers(@controller)).to eq 'alice@example.com'
        end
      end
    end

    context 'when no identifier is present in params' do

      context 'and an identifier is present in the headers' do

        before(:each) do
          @controller = double()
          allow(@controller).to receive(:params).and_return({ super_user_email: '' })
          allow(@controller).to receive_message_chain(:request, :headers)
                     .and_return({ 'X-SuperUser-Email' => 'bob@example.com' })
        end

        it 'returns the headers identifier' do
          expect(@subject.get_identifier_from_params_or_headers(@controller)).to eq 'bob@example.com'
        end
      end
    end
  end
end
