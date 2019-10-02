module SimpleTokenAuthentication

  class NoAdapterAvailableError < LoadError

    def to_s
      message = <<-HELP.gsub(/^ {8}/, '')
        No adapter could be loaded, probably because of unavailable dependencies.

        Please make sure that Simple Token Authentication is declared after your adapters' dependencies in your Gemfile.

        Example:

            # Gemfile

            gem 'mongoid', '~> 7.0.5' # for example
            gem 'simple_token_authentication', '~> 1.0'

        See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/158
      HELP
    end
  end

  InvalidOptionValue = Class.new(RuntimeError)
end
