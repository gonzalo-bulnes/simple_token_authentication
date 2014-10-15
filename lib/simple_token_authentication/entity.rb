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

    def identifier_field_name

      if SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym] && SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:identifier_field]
        return SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:identifier_field].to_sym
      else
        # Fallback for older configurations, when email was the only possible identifier. 
        return :email
      end
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
        SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][identifier_field_name]
      else
        "X-#{name}-Email"
      end
    end

    def token_param_name
      "#{name_underscore}_token".to_sym
    end

    def identifier
      if (SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym].presence && \
         SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:identifier_field].presence)
        SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:identifier_field]
      else
        :email
      end
    end

    def identifier_param_name
      "#{name_underscore}_#{identifier}".to_sym
    end

    def get_token_from_params_or_headers controller
      # if the token is not present among params, get it from headers
      if token = controller.params[token_param_name].blank? && controller.request.headers[token_header_name]
        controller.params[token_param_name] = token
      end
      controller.params[token_param_name]
    end

    def get_identifier_from_params_or_headers controller
      # if the identifier (email) is not present among params, get it from headers
      if identifier = controller.params[identifier_param_name].blank? && controller.request.headers[identifier_header_name]
        controller.params[identifier_param_name] = identifier
      end
      controller.params[identifier_param_name]
    end
  end
end
