-- schema.lua
return {
  fields = {
    url = {type = "string", required = true},
    method = {type = "string", required = true},
    timeout = {default = 10000, type = "number"},
    keepalive = {default = 60000, type = "number"}
  }
}
