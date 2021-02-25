let run ~launch_args rpc =
  Lwt.join
    [ Lifecycle.run ~launch_args rpc; Inspect.run rpc; Time_travel.run rpc ]
