require 'simple_token_authentication/acts_as_token_authenticatable'
require 'simple_token_authentication/acts_as_token_authentication_handler'
require 'simple_token_authentication/configuration'

module SimpleTokenAuthentication
  extend Configuration

  NoAdapterAvailableError = Class.new(LoadError)

  private

  def self.ensure_models_can_act_as_token_authenticatables model_adapters
    model_adapters.each do |model_adapter|
      model_adapter.base_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
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
      adapter_name = "simple_token_authentication/adapters/#{short_name}_adapter"
      if adapter_dependency_fulfilled?(short_name) && require(adapter_name)
        adapter_name.camelize.constantize
      end
    end
    available_adapters.compact!

    # stop here if dependencies are missing or no adequate adapters are present
    raise SimpleTokenAuthentication::NoAdapterAvailableError if available_adapters.empty?

    available_adapters
  end

  def self.adapter_dependency_fulfilled? adapter_short_name
    qualified_const_defined?(SimpleTokenAuthentication.adapters_dependencies[adapter_short_name])
  end

  available_model_adapters = load_available_adapters SimpleTokenAuthentication.model_adapters
  ensure_models_can_act_as_token_authenticatables available_model_adapters

  available_controller_adapters = load_available_adapters SimpleTokenAuthentication.controller_adapters
  ensure_controllers_can_act_as_token_authentication_handlers available_controller_adapters
end
