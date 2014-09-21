require 'spec_helper'

describe 'A token authenticatable class (or one of its children)' do

  let(:klass) do
    class SomeClass; end
    SomeClass.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
  end

  let(:child_klass) do
    class SomeChildClass < klass; end
    SomeChildClass
  end

  let(:subjects) do
    # all specs must apply to classes which include the module and their children
    [klass, child_klass]
  end

  it 'responds to :acts_as_token_authenticatable' do
    subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authenticatable
    end
  end

  describe 'which supports the :before_save hook' do

    context 'when it acts as token authenticatable' do
      it 'ensures its instances have an authentication token before being saved' do
        subjects.each do |subject|
          expect(subject).to receive(:before_save).with(:ensure_authentication_token)
          subject.acts_as_token_authenticatable
        end
      end
    end
  end

  describe 'instance' do

    let(:subjects) { [klass.new, child_klass.new] }

    it 'responds to :ensure_authentication_token', protected: true do
      subjects.each do |subject|
        expect(subject).to respond_to :ensure_authentication_token
      end
    end
  end
end
