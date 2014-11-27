require 'devise'

module SimpleTokenAuthentication
  class TokenComparator

    # Compare two String instances
    #
    # Important: this method is cryptographically critical and
    # must be implemented with care when defining new token comparators.
    #
    # Returns true if String instances do match, false otherwise
    def compare(a, b)
      # Notice how we use Devise.secure_compare to compare tokens
      # while mitigating timing attacks.
      # See http://rubydoc.info/github/plataformatec/\
      #            devise/master/Devise#secure_compare-class_method
      Devise.secure_compare(a, b)
    end
  end
end
