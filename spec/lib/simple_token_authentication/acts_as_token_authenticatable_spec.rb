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

  it 'responds to :acts_as_token_authenticatable', public: true do
    subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authenticatable
    end
  end

  describe 'which supports the :before_save hook' do

    context 'when it acts as token authenticatable' do
      it 'ensures its instances have an authentication token before being saved', public: true do
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

    context 'when some authentication tokens are already in use' do

      before(:each) do
        [klass, child_klass].each do |k|
          k.class_eval do

            def initialize(args={})
              @authentication_token = args[:authentication_token]
              # testing data
              @tokens_in_use = ['ExampleTok3n', '4notherTokeN']
              @tokens_to_be_generated = ['ExampleTok3n', '4notherTokeN', 'Dist1nCt-Tok3N']
            end

            def authentication_token=(value)
              @authentication_token = value
            end

            def authentication_token
              @authentication_token
            end

            # the 'ExampleTok3n' is already in use
            def token_suitable?(token)
              not @tokens_in_use.include? token
            end

            # some tokens already in use are generated
            def generate_token
              @tokens_to_be_generated.shift
            end
          end
        end
      end

      it 'ensures its authentication token is unique', public: true do
        subjects.each do |subject|
          subject.ensure_authentication_token

          expect(subject.authentication_token).not_to eq 'ExampleTok3n'
          expect(subject.authentication_token).not_to eq '4notherTokeN'
          expect(subject.authentication_token).to eq 'Dist1nCt-Tok3N'
        end
      end
    end
  end
end
