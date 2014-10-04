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

  def self.ensure_models_can_act_as_token_authenticatables
    ActiveRecord::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
  end

  ensure_models_can_act_as_token_authenticatables
end
