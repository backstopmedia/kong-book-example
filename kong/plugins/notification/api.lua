-- api.lua
local crud = require "kong.api.crud_helpers"

return {
  ["/notification"] = {
    GET = function(self, dao_factory, helpers)
      crud.paginated_set(self, dao_factory.notifications)
    end
  },
  ["/notification/api/:api_name_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
      self.params.api_id = self.api.id
    end,
    GET = function(self, dao_factory, helpers)
      crud.paginated_set(self, dao_factory.notifications)
    end
  },
  ["/notification/consumer/:username_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
      self.params.consumer_id = self.consumer.id
    end,
    GET = function(self, dao_factory, helpers)
      crud.paginated_set(self, dao_factory.notifications)
    end
  }
}
