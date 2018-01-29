local BasePlugin = require "kong.plugins.base_plugin"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local socket_url = require "socket.url"
local cjson = require "cjson"

local singletons = require "kong.singletons"
local string_format = string.format
local cjson_encode = cjson.encode

local NotificationHandler = BasePlugin:extend()
NotificationHandler.PRIORITY = 0

function NotificationHandler:new()
  NotificationHandler.super.new(self, "notification")
end

function NotificationHandler:parse_url(raw_url)
  local parsed_url = socket_url.parse(raw_url)
  if not parsed_url.port then
    if parsed_url.scheme == "http" then
      parsed_url.port = 80
    elseif parsed_url.scheme == "https" then
      parsed_url.port = 443
    end
  end
  if not parsed_url.path then
    parsed_url.path = "/"
  end
  return parsed_url
end

function NotificationHandler:get_message(config, parsed_url)
  local url
  if parsed_url.query then
    url = parsed_url.path .. "?" .. parsed_url.query
  else
    url = parsed_url.path
  end

  local body =
    cjson_encode(
    {
      consumer = ngx.ctx.authenticated_consumer,
      api = ngx.ctx.api
    }
  )

  local headers =
    string_format(
    "%s %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n",
    config.method:upper(),
    url,
    parsed_url.host,
    #body
  )

  return string_format("%s\r\n%s", headers, body)
end

function send(premature, config, ctx)
  -- do some routine job in Lua just like a cron job
  if premature then
    return
  end

  local parsed_url = NotificationHandler:parse_url(config.url)
  local host = parsed_url.host
  local port = tonumber(parsed_url.port)

  local sock = ngx.socket.tcp()
  sock:settimeout(config.timeout)
  ok, err = sock:connect(host, port)
  if not ok then
    ngx.log(ngx.ERR, "[notification-log] failed to connect to " .. host .. ":" .. tostring(port) .. ": ", err)
    return
  end

  if parsed_url.scheme == "https" then
    local _, err = sock:sslhandshake(true, host, false)
    if err then
      ngx.log(
        ngx.ERR,
        "[notification-log] failed to do SSL handshake with " .. host .. ":" .. tostring(port) .. ": ",
        err
      )
    end
  end

  local message = NotificationHandler:get_message(config, parsed_url)
  ok, err = sock:send(message)
  if not ok then
    ngx.log(ngx.ERR, "[notification-log] failed to send data to " .. host .. ":" .. tostring(port) .. ": ", err)
  end

  ok, err = sock:setkeepalive(config.keepalive)
  if not ok then
    ngx.log(ngx.ERR, "[notification-log] failed to keepalive to " .. host .. ":" .. tostring(port) .. ": ", err)
    return
  end

  local dao_factory = singletons.dao
  local notifications_dao = dao_factory.notifications
  local consumer_id = nil
  if ctx.authenticated_consumer ~= nil then
    consumer_id = ctx.authenticated_consumer.id
  end
  local notification,
    err =
    notifications_dao:insert(
    {
      api_id = ctx.api.id,
      consumer_id = consumer_id,
      params = message
    }
  )
  if err then
    ngx.log(ngx.ERR, "failed to save notification: ", err)
    return
  end
end

function NotificationHandler:access(config)
  NotificationHandler.super.access(self)

  local ok, err = ngx.timer.at(0, send, config, ngx.ctx)
  if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
  end
end

return NotificationHandler
