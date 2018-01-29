local helpers = require "spec.helpers"
local cjson = require "cjson"

describe(
  "notification plugin #integration",
  function()
    local proxy_client
    local admin_client
    setup(
      function()
        api =
          assert(
          helpers.dao.apis:insert {
            name = "test-api",
            methods = "GET",
            uris = "/test",
            upstream_url = "http://127.0.0.1:9001"
          }
        )
        -- start Kong with your testing Kong configuration (defined in "spec.helpers")
        assert(helpers.start_kong({custom_plugins = "notification"}))
        admin_client = helpers.admin_client()
      end
    )
    teardown(
      function()
        if admin_client then
          admin_client:close()
        end
        helpers.stop_kong()
      end
    )
    before_each(
      function()
        proxy_client = helpers.proxy_client()
      end
    )
    after_each(
      function()
        if proxy_client then
          proxy_client:close()
        end
      end
    )
    describe(
      "add notification plugin",
      function()
        it(
          "success add notification plugin to api",
          function()
            -- add notification plugin to api
            local res =
              assert(
              admin_client:send {
                method = "POST",
                path = "/apis/" .. api.id .. "/plugins/",
                body = {
                  name = "notification",
                  config = {
                    url = "http://127.0.0.1:9001/",
                    method = "GET"
                  }
                },
                headers = {
                  ["Content-Type"] = "application/json"
                }
              }
            )
            assert.res_status(201, res)

            -- hit api
            local res =
              assert(
              proxy_client:send {
                method = "GET",
                path = "/test"
              }
            )
            assert.res_status(200, res)
            -- get notifications from the database
            local res =
              admin_client:send {
              method = "GET",
              path = "/notification",
              headers = {
                ["Content-Type"] = "application/json"
              }
            }

            local body = cjson.decode(assert.res_status(200, res))
            assert.equal(1, body.total)
          end
        )

        it(
          "fail to add notification plugin without url",
          function()
            local res =
              assert(
              admin_client:send {
                method = "POST",
                path = "/apis/" .. api.id .. "/plugins/",
                body = {
                  name = "notification",
                  config = {
                    method = "GET"
                  }
                },
                headers = {
                  ["Content-Type"] = "application/json"
                }
              }
            )
            local body = assert.res_status(400, res)
            local json = cjson.decode(body)
            assert.same({["config.url"] = "url is required"}, json)
          end
        )

        it(
          "fail to add notification plugin without method",
          function()
            local res =
              assert(
              admin_client:send {
                method = "POST",
                path = "/apis/" .. api.id .. "/plugins/",
                body = {
                  name = "notification",
                  config = {
                    url = "http://127.0.0.1:9001/"
                  }
                },
                headers = {
                  ["Content-Type"] = "application/json"
                }
              }
            )
            local body = assert.res_status(400, res)
            local json = cjson.decode(body)
            assert.same({["config.method"] = "method is required"}, json)
          end
        )
      end
    )
  end
)
