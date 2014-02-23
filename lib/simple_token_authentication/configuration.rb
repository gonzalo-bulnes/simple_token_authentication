module SimpleTokenAuthentication
  module Configuration

    mattr_accessor :header_names
    mattr_accessor :sign_in_token

    # Default configuration
    @@header_names = {}
    @@sign_in_token = false

    def configure
      yield self if block_given?
    end
  end
end
