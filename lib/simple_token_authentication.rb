require 'active_support/version'
require 'simple_token_authentication/acts_as_token_authenticatable'
require 'simple_token_authentication/acts_as_token_authentication_handler'
require 'simple_token_authentication/configuration'
require 'simple_token_authentication/errors'

module SimpleTokenAuthentication
  extend Configuration

  private

  def self.ensure_models_can_act_as_token_authenticatables model_adapters
    model_adapters.each do |model_adapter|
      model_adapter.base_class.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
    end
  end

  def self.ensure_controllers_can_act_as_token_authentication_handlers controller_adapters
    controller_adapters.each do |controller_adapter|
      controller_adapter.base_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
    end
  end

  # Private: Load the available adapters.
  #
  # adapters_short_names - Array of names of the adapters to load if available
  #
  # Example
  #
  #    load_available_adapters ['unavailable_adapter', 'available_adapter']
  #    # => [SimpleTokenAuthentication::Adapters::AvailableAdapter]
  #
  # Returns an Array of available adapters
  def self.load_available_adapters adapters_short_names
    available_adapters = adapters_short_names.collect do |short_name|
      next if short_name == "rails_api"
      adapter_name = "simple_token_authentication/adapters/#{short_name}_adapter"
      if adapter_dependency_fulfilled?(short_name) && require(adapter_name)
        adapter_name.camelize.constantize
      end
    end
    available_adapters.compact!

    # stop here if dependencies are missing or no adequate adapters are present
    raise NoAdapterAvailableError.new if available_adapters.empty?

    available_adapters
  end

  def self.adapter_dependency_fulfilled? adapter_short_name
    dependency = SimpleTokenAuthentication.adapters_dependencies[adapter_short_name]

    if !respond_to?(:qualified_const_defined?) || (ActiveSupport.respond_to?(:version) && ActiveSupport.version.to_s =~ /^5\.0/)
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/229/commits/74eda6c28cd0b45636c466de56f2dbaca5c5b629#r57507423
      const_defined?(dependency)
    else
      qualified_const_defined?(dependency)
    end
  end

  available_model_adapters = load_available_adapters SimpleTokenAuthentication.model_adapters
  ensure_models_can_act_as_token_authenticatables available_model_adapters

  available_controller_adapters = load_available_adapters SimpleTokenAuthentication.controller_adapters
  ensure_controllers_can_act_as_token_authentication_handlers available_controller_adapters
end
