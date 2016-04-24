module SimpleTokenAuthentication
  class Entity
    def initialize(model, model_alias=nil)
      @model = model
      @name = model.name
      @name_underscore = model_alias.to_s unless model_alias.nil?
    end

    def model
      @model
    end

    def name
      @name
    end

    def name_underscore
      @name_underscore || name.underscore
    end

    def identifier
      if custom_identifier = SimpleTokenAuthentication.identifiers["#{name_underscore}".to_sym]
        custom_identifier.to_sym
      else
        :email
      end
    end
  end
end
