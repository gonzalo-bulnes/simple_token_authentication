require 'active_support/deprecation'
require 'active_support/version'

module SimpleTokenAuthentication
  module Helpers

    def silencing_deprecation_warnings(&block)
      # See https://github.com/rails/rails/pull/5986
      raise NotImplementedError.new('Only available in ActiveSupport 4.0.0 and later.') if ActiveSupport.version.to_s < '4'
      original_behavior = ::ActiveSupport::Deprecation.behavior
      ::ActiveSupport::Deprecation.behavior = :silence
      response = yield
      ::ActiveSupport::Deprecation.behavior = original_behavior
      response
    end
  end
end

