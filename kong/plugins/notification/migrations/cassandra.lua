return {
  {
    name = "2018-01-27-841841_init_notification",
    up = [[
        CREATE TABLE IF NOT EXISTS notifications(
          id uuid,
          api_id uuid,
          consumer_id uuid,
          params text,
          timeout int,
          keepalive int,
          created_at timestamp,
          PRIMARY KEY (id)
        );
      ]],
    down = [[
        DROP TABLE notifications;
      ]]
  }
}
