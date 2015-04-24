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

describe 'Any instance of a class which includes SimpleTokenAuthentication::TokenAuthenticatable' do

  let(:described_class) do
    define_dummy_class_which_includes SimpleTokenAuthentication::TokenAuthenticatable
  end

  after(:each) do
    # ensure_examples_independence
    SimpleTokenAuthentication.send(:remove_const, :SomeClass)
  end

  it_behaves_like 'a token authenticatable'

  let(:subject) { described_class.new() }

  describe '#ensure_authentication_token' do

    context 'when some authentication tokens are already in use' do

      before(:each) do
        TOKENS_IN_USE = ['ExampleTok3n', '4notherTokeN']

        subject.instance_eval do

          @token_generator = DummyTokenGenerator.new(
            tokens_to_be_generated: TOKENS_IN_USE + ['Dist1nCt-Tok3N'])

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
        end
      end

      it 'ensures its authentication token is unique', public: true do
        subject.ensure_authentication_token

        expect(subject.authentication_token).not_to eq 'ExampleTok3n'
        expect(subject.authentication_token).not_to eq '4notherTokeN'
        expect(subject.authentication_token).to eq 'Dist1nCt-Tok3N'
      end
    end
  end
end
