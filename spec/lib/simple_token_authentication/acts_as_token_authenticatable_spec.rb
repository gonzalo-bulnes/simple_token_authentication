require 'spec_helper'

describe 'A token authenticatable class' do

  let(:klass) do
    class SomeClass; end
    SomeClass.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
  end

  let(:subject) { klass }

  it 'responds to :acts_as_token_authenticatable' do
    expect(subject).to respond_to :acts_as_token_authenticatable
  end

  describe 'which supports the :before_save hook' do

    context 'when it acts as token authenticatable' do
      it 'ensures its instances have an authentication token before being saved' do
        expect(subject).to receive(:before_save).with(:ensure_authentication_token)
        subject.acts_as_token_authenticatable
      end
    end
  end

  describe 'instance' do

    let(:subject) { klass.new }

    it 'responds to :ensure_authentication_token', protected: true do
      expect(subject).to respond_to :ensure_authentication_token
    end
  end
end
