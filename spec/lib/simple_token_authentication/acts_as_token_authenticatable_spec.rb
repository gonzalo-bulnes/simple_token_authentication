require 'spec_helper'


class DummyTokenGenerator
  include Singleton

  def tokens_to_be_generated=(tokens)
    @tokens_to_be_generated = tokens
  end

  def generate_token
    @tokens_to_be_generated.shift
  end
end

describe DummyTokenGenerator do
  it_behaves_like 'a token generator'
end

describe 'A token authenticatable class (or one of its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for_inclusion_of(SimpleTokenAuthentication::ActsAsTokenAuthenticatable)
  end

  it 'responds to :acts_as_token_authenticatable', public: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authenticatable
    end
  end

  describe 'which supports the :before_save hook' do

    context 'when it acts as token authenticatable' do
      it 'ensures its instances have an authentication token before being saved (1)', rspec_3_error: true, public: true do
        some_class = @subjects.first

        expect(some_class).to receive(:before_save).with(:ensure_authentication_token)
        some_class.acts_as_token_authenticatable
      end

      it 'ensures its instances have an authentication token before being saved (2)', rspec_3_error: true, public: true do
        some_child_class = @subjects.last

        expect(some_child_class).to receive(:before_save).with(:ensure_authentication_token)
        some_child_class.acts_as_token_authenticatable
      end
    end
  end

  describe 'instance' do

    it 'responds to :ensure_authentication_token', protected: true do
      @subjects.map!{ |subject| subject.new }
      @subjects.each do |subject|
        allow(subject.class).to receive(:before_save)
        subject.class.acts_as_token_authenticatable
        expect(subject).to respond_to :ensure_authentication_token
      end
    end

    context 'when some authentication tokens are already in use' do

      before(:each) do
        TOKENS_IN_USE = ['ExampleTok3n', '4notherTokeN']

        @subjects.each do |k|
          k.class_eval do
            def initialize(args={})
              @authentication_token = args[:authentication_token]
            end

            # the 'ExampleTok3n' is already in use
            def token_suitable?(token)
              not TOKENS_IN_USE.include? token
            end

            def token_generator
              token_generator = DummyTokenGenerator.instance
              token_generator.tokens_to_be_generated = TOKENS_IN_USE + ['Dist1nCt-Tok3N']
              token_generator
            end
          end
          k.send(:include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable)
        end
        @subjects.map!{ |subject| subject.new }
      end

      it 'ensures its authentication token is unique if storing tokens as plaintext', public: true do
        SimpleTokenAuthentication.persist_token_as = :plain

        @subjects.each do |subject|
          allow(subject.class).to receive(:before_save)
          subject.class.acts_as_token_authenticatable

          subject.ensure_authentication_token

          expect(subject.authentication_token).not_to eq 'ExampleTok3n'
          expect(subject.authentication_token).not_to eq '4notherTokeN'
          expect(subject.authentication_token).to eq 'Dist1nCt-Tok3N'
        end
      end


      it "prevents the authentication token being stored in plain text if digest has been configured", public: true do
        # set the config to use plaintext persisted tokens
        SimpleTokenAuthentication.persist_token_as = :digest

        @subjects.each do |subject|
          allow(subject.class).to receive(:before_save)
          subject.class.acts_as_token_authenticatable

          subject.ensure_authentication_token
          expect(subject.plain_authentication_token).to eq 'Dist1nCt-Tok3N'
          expect(subject.persisted_authentication_token).not_to be nil
          expect(subject.persisted_authentication_token).not_to eq 'Dist1nCt-Tok3N'
        end
      end

      it "ensures the stored digest is a true digest" do
        SimpleTokenAuthentication.persist_token_as = :digest

        @subjects.each do |subject|
          allow(subject.class).to receive(:before_save)
          subject.class.acts_as_token_authenticatable

          subject.ensure_authentication_token
          hashed_token = subject.persisted_authentication_token
          plain_token = subject.plain_authentication_token
          comp = Devise::Encryptor.compare(SimpleTokenAuthentication, hashed_token, plain_token)
          expect(comp).to be true
        end
      end

      it "ensures a stored digest can be compared" do

        SimpleTokenAuthentication.persist_token_as = :digest
        token_comparator = SimpleTokenAuthentication::TokenComparator.instance
        @subjects.each do |subject|
          allow(subject.class).to receive(:before_save)
          subject.class.acts_as_token_authenticatable
          
          subject.ensure_authentication_token
          hashed_token = subject.persisted_authentication_token
          plain_token = subject.plain_authentication_token
          comp = token_comparator.compare(hashed_token, plain_token)
          expect(comp).to be true
        end
      end

    end
  end
end

describe 'A class which includes a module which includes ActsAsTokenAuthenticatable and ActiveSupport::Concern (a.k.a Adapters::MongoidAdapter)' do

  before(:each) do
    base_module = Module.new do
      extend ActiveSupport::Concern
      include SimpleTokenAuthentication::ActsAsTokenAuthenticatable
    end
    stub_const('BaseModule', base_module)

    @subject = Class.new do
      include BaseModule
    end
  end

  it 'responds to :acts_as_token_authenticatable', protected: true do
    expect(@subject).to respond_to :acts_as_token_authenticatable
  end
end

describe 'A class that inherits from a class which includes ActsAsTokenAuthenticatable (a.k.a Adapters::ActiveRecordAdapter)' do

  before(:each) do
    base_class = Class.new do
      include SimpleTokenAuthentication::ActsAsTokenAuthenticatable
    end
    stub_const('BaseClass', base_class)

    @subject = Class.new(BaseClass)
  end

  it 'responds to :acts_as_token_authenticatable', protected: true do
    expect(@subject).to respond_to :acts_as_token_authenticatable
  end
end
