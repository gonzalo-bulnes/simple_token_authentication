module SimpleTokenAuthentication
  class Entity
    def initialize model
      @model = model
      @name = model.name
    end

    def model
      @model
    end

    def name
      @name
    end

    def name_underscore
      name.underscore
    end

    # Private: Return the name of the header to watch for the token authentication param
    def token_header_name
      if SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:authentication_token]
      else
        "X-#{name}-Token"
      end
    end

    # Private: Return the name of the header to watch for the email param
    def identifier_header_name
      if SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:email]
      else
        "X-#{name}-Email"
      end
    end
  end
end
