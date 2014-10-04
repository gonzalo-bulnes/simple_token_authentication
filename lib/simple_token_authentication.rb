require 'simple_token_authentication/adapter'
require 'simple_token_authentication/fallback_authentication_handler'
require 'simple_token_authentication/token_comparator'
require 'simple_token_authentication/token_generator'
require 'simple_token_authentication/sign_in_handler'
require 'simple_token_authentication/entity'
require 'simple_token_authentication/acts_as_token_authenticatable'
require 'simple_token_authentication/acts_as_token_authentication_handler'
require 'simple_token_authentication/configuration'

module SimpleTokenAuthentication
  extend Configuration

  private

  def self.ensure_models_can_act_as_token_authenticatables adapters
    adapters.each do |adapter|
      adapter.models_base_class.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
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
    adapters_short_names.collect do |short_name|
      adapter_name = "simple_token_authentication/adapters/#{short_name}_adapter"
      if require adapter_name
        adapter_name.camelize.constantize
      end
    end
  end

  available_adapters = load_available_adapters SimpleTokenAuthentication.adapters
  ensure_models_can_act_as_token_authenticatables available_adapters
end
