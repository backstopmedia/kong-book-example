local plugin_config_iterator = require("kong.dao.migrations.helpers").plugin_config_iterator

return {
  {
    name = "2018-01-27-841841_init_notification",
    up = [[
        CREATE TABLE IF NOT EXISTS notifications(
          id uuid,
          api_id uuid REFERENCES apis (id),
          consumer_id uuid REFERENCES consumers (id),
          timeout integer,
          keepalive integer,
          params text,
          created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
          PRIMARY KEY (id)
        );
      ]],
    down = [[
        DROP TABLE notifications;
      ]]
  },
  {
    name = "2018-01-28-841841_notification",
    up = function(_, _, dao)
      for ok, config, update in plugin_config_iterator(dao, "notification") do
        if not ok then
          return config
        end
        config.keepalive = 60000
        local ok, err = update(config)
        if not ok then
          return err
        end
      end
    end,
    down = function(_, _, dao)
    end -- not implemented
  }
}
