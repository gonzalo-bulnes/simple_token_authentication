module SimpleTokenAuthentication
  module Configuration
    attr_accessor(
      :sign_in_token,
    )

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.sign_in_token = false
    end
  end
end
