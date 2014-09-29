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
      @name.underscore
    end
  end
end
