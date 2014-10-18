module SimpleTokenAuthentication
  module Configuration

    mattr_reader   :fallback
    mattr_accessor :header_names
    mattr_accessor :sign_in_token
    mattr_accessor :controller_adapters
    mattr_accessor :model_adapters

    # Default configuration
    @@fallback = :devise
    @@header_names = {}
    @@sign_in_token = false
    @@controller_adapters = ['rails']
    @@model_adapters = ['active_record']

    # Allow the default configuration to be overwritten from initializers
    def configure
      yield self if block_given?
    end

    def parse_options(options)
      unless options[:fallback].presence
        if options[:fallback_to_devise]
          options[:fallback] = :devise
        elsif options[:fallback_to_devise] == false
          if SimpleTokenAuthentication.fallback == :devise
              options[:fallback] = :none
          else
            options[:fallback] = SimpleTokenAuthentication.fallback
          end
        else
          options[:fallback] = SimpleTokenAuthentication.fallback
        end
      end
      options.reject! { |k,v| k == :fallback_to_devise }
      options
    end
  end
end
