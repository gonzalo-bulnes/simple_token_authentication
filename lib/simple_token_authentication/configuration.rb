module SimpleTokenAuthentication
  module Configuration

    mattr_accessor :header_names
    mattr_accessor :sign_in_token
    mattr_accessor :skip_trackable

    # Default configuration
    @@header_names = {}
    @@sign_in_token = false
    @@skip_trackable = true

    # Allow the default configuration to be overwritten from initializers
    def configure
      yield self if block_given?
    end
  end
end
