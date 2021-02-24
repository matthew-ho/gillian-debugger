let run ~launch_args rpc = Lwt.join [ Lifecycle.run ~launch_args rpc ]
