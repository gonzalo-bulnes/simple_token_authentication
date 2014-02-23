module SimpleTokenAuthentication
  module Configuration

    mattr_accessor :sign_in_token

    # Default configuration
    @@sign_in_token = false

    def configure
      yield self if block_given?
    end
  end
end
