require 'simple_token_authentication/entity'

module SimpleTokenAuthentication
  class EntitiesManager
    def find_or_create_entity(model, model_alias=nil)
      @entities ||= {}
      @entities[model.name] ||= Entity.new(model, model_alias)
    end
  end
end
