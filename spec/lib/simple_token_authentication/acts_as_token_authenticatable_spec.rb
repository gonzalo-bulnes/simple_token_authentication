require 'spec_helper'

describe 'A token authenticatable class (or one of its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for(SimpleTokenAuthentication::ActsAsTokenAuthenticatable)
  end

  it 'responds to :acts_as_token_authenticatable', public: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authenticatable
    end
  end

  describe 'which supports the :before_save hook' do

    context 'when it acts as token authenticatable' do
      it 'ensures its instances have an authentication token before being saved', public: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_save).with(:ensure_authentication_token)
          subject.acts_as_token_authenticatable
        end
      end
    end
  end

  describe 'instance' do

    it 'responds to :ensure_authentication_token', protected: true do
      @subjects.map!{ |subject| subject.new }
      @subjects.each do |subject|
        expect(subject).to respond_to :ensure_authentication_token
      end
    end

    context 'when some authentication tokens are already in use' do

      before(:each) do
        TOKENS_IN_USE = ['ExampleTok3n', '4notherTokeN']

        class DummyTokenGenerator
          def initialize(args={})
            @tokens_to_be_generated = args[:tokens_to_be_generated]
          end

          def generate_token
            @tokens_to_be_generated.shift
          end
        end

        @subjects.each do |k|
          k.class_eval do

            def initialize(args={})
              @authentication_token = args[:authentication_token]
              @token_generator = DummyTokenGenerator.new(
                  tokens_to_be_generated: TOKENS_IN_USE + ['Dist1nCt-Tok3N'])
            end

            def authentication_token=(value)
              @authentication_token = value
            end

            def authentication_token
              @authentication_token
            end

            # the 'ExampleTok3n' is already in use
            def token_suitable?(token)
              not TOKENS_IN_USE.include? token
            end

            def token_generator
              @token_generator
            end
          end
        end
        @subjects.map!{ |subject| subject.new }
      end

      it 'ensures its authentication token is unique', public: true do
        @subjects.each do |subject|
          subject.ensure_authentication_token

          expect(subject.authentication_token).not_to eq 'ExampleTok3n'
          expect(subject.authentication_token).not_to eq '4notherTokeN'
          expect(subject.authentication_token).to eq 'Dist1nCt-Tok3N'
        end
      end
    end
  end
end
