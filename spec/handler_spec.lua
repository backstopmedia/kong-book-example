local handler = require("kong.plugins.notification.handler")
local string_format = string.format

describe(
  "testing parse_url #unit",
  function()
    it(
      "test success http",
      function()
        local parsed_url = handler:parse_url("http://localhost/test?query=param")
        assert.are.same(
          {
            host = "localhost",
            port = 80,
            path = "/test",
            query = "query=param",
            scheme = "http",
            authority = "localhost"
          },
          parsed_url
        )
      end
    )

    it(
      "test success https",
      function()
        local parsed_url = handler:parse_url("https://localhost/test")
        assert.are.same(
          {
            host = "localhost",
            port = 443,
            path = "/test",
            scheme = "https",
            authority = "localhost"
          },
          parsed_url
        )
      end
    )

    it(
      "test parse invalid url",
      function()
        local parsed_url = handler:parse_url("invalid")
        assert.are.same(
          {
            path = "invalid"
          },
          parsed_url
        )
      end
    )
  end
)

describe(
  "testing get_message #unit",
  function()
    it(
      "test success get_message no query",
      function()
        local config = {method = "GET"}
        local parsed_url = {host = "localhost", path = "/test"}
        ngx.ctx = {authenticated_consumer = {id = 1}, api = {id = 1}}
        local message = handler:get_message(config, parsed_url)
        local body = [[{"consumer":{"id":1},"api":{"id":1}}]]
        local expected_message =
          string_format(
          "%s %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n\r\n%s",
          "GET",
          "/test",
          "localhost",
          #body,
          body
        )
        assert.are.same(expected_message, message)
      end
    )

    it(
      "test fail get_message ctx is nil",
      function()
        ngx.ctx = nil
        assert.has.errors(
          function()
            handler:get_message({}, {})
          end
        )
      end
    )

    it(
      "test fail get_message ctx is nil",
      function()
        local config = nil
        ngx.ctx = {authenticated_consumer = {id = 1}, api = {id = 1}}
        assert.has.errors(
          function()
            handler:get_message(nil, {})
          end
        )
      end
    )
  end
)
