module SimpleTokenAuthentication
  module Configuration

    mattr_reader   :fallback
    mattr_accessor :header_names
    mattr_accessor :identifiers
    mattr_accessor :sign_in_token
    mattr_accessor :controller_adapters
    mattr_accessor :model_adapters
    mattr_accessor :adapters_dependencies
    mattr_accessor :skip_devise_trackable
    mattr_accessor :persist_token_as
    mattr_accessor :cache_provider_name
    mattr_accessor :cache_connection
    mattr_accessor :cache_provider
    mattr_accessor :cache_expiration_time

    # Default configuration
    @@fallback = :devise
    @@header_names = {}
    @@identifiers = {}
    @@sign_in_token = false
    @@controller_adapters = ['rails', 'rails_api', 'rails_metal']
    @@model_adapters = ['active_record', 'mongoid']
    @@adapters_dependencies = { 'active_record' => 'ActiveRecord::Base',
                                'mongoid'       => 'Mongoid::Document',
                                'rails'         => 'ActionController::Base',
                                'rails_api'     => 'ActionController::API',
                                'rails_metal'   => 'ActionController::Metal' }
    @@skip_devise_trackable = true
    @@persist_token_as = :plain
    @@cache_provider_name = nil
    @@cache_connection = nil
    @@cache_provider = nil
    @@cache_expiration_time = 15.minutes

    # Allow the default configuration to be overwritten from initializers
    def configure
      yield self if block_given?
      run_post_config_setup
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

    def persist_token_as_plain?
      SimpleTokenAuthentication.persist_token_as == :plain
    end

    def persist_token_as_digest?
      SimpleTokenAuthentication.persist_token_as == :digest
    end

    def pepper
      Devise.pepper
    end

    def stretches
      Devise.stretches
    end
  end
end
