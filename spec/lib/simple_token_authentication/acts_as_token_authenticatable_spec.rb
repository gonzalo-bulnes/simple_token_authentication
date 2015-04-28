require 'spec_helper'


class DummyTokenGenerator
  def initialize(args={})
    @tokens_to_be_generated = args[:tokens_to_be_generated]
  end

  def generate_token
    @tokens_to_be_generated.shift
  end
end

describe DummyTokenGenerator do
  it_behaves_like 'a token generator'
end

describe 'Any class which extends SimpleTokenAuthentication::ActsAsTokenAuthenticatable (or any if its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for_extension_of(SimpleTokenAuthentication::ActsAsTokenAuthenticatable)
  end

  it 'doesn\'t behave like a token authenticatable', public: true do
    stub_const('SimpleTokenAuthentication::TokenAuthenticatable', Module.new)

    @subjects.each do |subject|
      expect(subject).not_to be_include SimpleTokenAuthentication::TokenAuthenticatable
    end
  end

  it 'responds to :acts_as_token_authenticatable', public: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authenticatable
    end
  end

  context 'when it explicitely acts as a token authenticatable' do

    it 'behaves like a token authenticatable (1)', rspec_3_error: true, public: true do
      stub_const('SimpleTokenAuthentication::TokenAuthenticatable', Module.new)

      some_class = @subjects.first
      allow(some_class).to receive(:before_save)

      some_class.acts_as_token_authenticatable
      expect(some_class).to be_include SimpleTokenAuthentication::TokenAuthenticatable
    end

    it 'behaves like a token authenticatable (2)', rspec_3_error: true, public: true do
      stub_const('SimpleTokenAuthentication::TokenAuthenticatable', Module.new)

      some_child_class = @subjects.last
      allow(some_child_class).to receive(:before_save)

      some_child_class.acts_as_token_authenticatable
      expect(some_child_class).to be_include SimpleTokenAuthentication::TokenAuthenticatable
    end
  end

  describe '.acts_as_token_authenticatable' do

    context 'when the class supports the :before_save hook' do

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
end

describe 'A class which includes a module which extends ActsAsTokenAuthenticatable (a.k.a Adapters::MongoidAdapter)' do

  before(:each) do
    base_module = Module.new do
      extend SimpleTokenAuthentication::ActsAsTokenAuthenticatable
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

describe 'A class that inherits from a class which extends ActsAsTokenAuthenticatable (a.k.a Adapters::ActiveRecordAdapter)' do

  before(:each) do
    base_class = Class.new do
      extend SimpleTokenAuthentication::ActsAsTokenAuthenticatable
    end
    stub_const('BaseClass', base_class)

    @subject = Class.new(BaseClass)
  end

  it 'responds to :acts_as_token_authenticatable', protected: true do
    expect(@subject).to respond_to :acts_as_token_authenticatable
  end
end
