-- daos.lua
local SCHEMA = {
  primary_key = {"id"},
  table = "notifications",
  fields = {
    id = {type = "id", dao_insert_value = true}, -- a value to be inserted by the DAO itself (think of serial ID and the uniqueness of such required here)
    created_at = {type = "timestamp", immutable = true, dao_insert_value = true}, -- also interted by the DAO itself
    api_id = {type = "id", required = true, foreign = "apis:id"}, -- a foreign key to a Consumer's id
    consumer_id = {type = "id", required = false, foreign = "consumers:id"}, -- a foreign key to a Consumer's id
    params = {type = "string", required = true}
  }
}

return {notifications = SCHEMA} -- this plugin only results in one custom DAO, named `notifications`
