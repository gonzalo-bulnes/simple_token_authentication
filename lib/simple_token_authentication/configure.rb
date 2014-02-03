module SimpleTokenAuthentication
  module Configure

    mattr_accessor :persistent
    @@persistent = false

    def configure
      yield self if block_given?
    end
  end
end