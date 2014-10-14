require 'simple_token_authentication/entity'

module SimpleTokenAuthentication
  class EntitiesManager

    def entities
      entities_store.values
    end

    def find_or_create_entity(model)
      entities_store[model.name] ||= Entity.new(model)
    end

    private

    def entities_store
      @entities_store ||= {}
    end
  end
end
