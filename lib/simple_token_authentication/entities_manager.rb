require 'simple_token_authentication/entity'

module SimpleTokenAuthentication
  class EntitiesManager
    def find_or_create_entity(model)
      @entities ||= {}
      @entities[model.name] ||= Entity.new(model)
    end
  end
end
