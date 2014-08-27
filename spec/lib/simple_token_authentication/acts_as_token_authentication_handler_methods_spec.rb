require 'spec_helper'
require 'active_record'
require 'action_controller'
require 'devise'
require 'simple_token_authentication/acts_as_token_authentication_handler'

describe SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods do

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods
  end

  describe '#header_token_name' do

    it 'exists' do
      expect(@dummy).to respond_to :header_token_name
    end

    context 'by default' do

      before(:each) do
        # Given the default configuration
        module SimpleTokenAuthentication
          mattr_accessor :header_names
          @@header_names = {}
        end
      end

      it 'follows the `X-EntityName-Token` pattern' do

        # Ensure the example classes are defined
        User = Class.new
        SuperAdmin = Class.new

        KNOWN_EXAMPLES = [{input: User, output: 'X-User-Token'},
                          {input: SuperAdmin, output: 'X-SuperAdmin-Token'}]

        KNOWN_EXAMPLES.each do |example|
          expect(
            @dummy.header_token_name example[:input]
          ).to eq example[:output]
        end
      end
    end
  end
end
