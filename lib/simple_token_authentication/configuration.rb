module SimpleTokenAuthentication
  module Configuration

    mattr_accessor :header_names
    mattr_accessor :sign_in_token
    mattr_accessor :auth_parameter_name


    # Default configuration
    @@header_names = {}
    @@sign_in_token = false
    @@auth_parameter_name = {}

    def configure
      yield self if block_given?
    end
  end
end
