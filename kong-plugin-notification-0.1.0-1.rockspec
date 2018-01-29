package = "kong-plugin-notification"

version = "0.1.0-1"

supported_platforms = {"linux", "macosx"}

source = {
  url = "git://github.com/backstopmedia/kong-book-example",
  branch = "notification"
}

description = {
  summary = "A simple notification plugin",
  homepage = "http://getkong.org",
  license = "MIT"
}

dependencies = {
}

local pluginName = "notification"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".migrations.cassandra"] = "kong/plugins/"..pluginName.."/migrations/cassandra.lua",
    ["kong.plugins."..pluginName..".migrations.postgres"] = "kong/plugins/"..pluginName.."/migrations/postgres.lua",
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".api"] = "kong/plugins/"..pluginName.."/api.lua",
    ["kong.plugins."..pluginName..".daos"] = "kong/plugins/"..pluginName.."/daos.lua",
  }
}