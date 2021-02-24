open Debug_protocol_ex

let run rpc =
  let promise, resolver = Lwt.task () in
  let prevent_reenter () =
    Debug_rpc.remove_command_handler rpc (module Launch_command);
    Debug_rpc.remove_command_handler rpc (module Attach_command)
  in
  Debug_rpc.set_command_handler rpc
    (module Launch_command)
    (fun (launch_args : Debug_protocol_ex.Launch_command.Arguments.t) ->
      Log.info "Launch request received";
      prevent_reenter ();
      Debugger.launch launch_args.Launch_command.Arguments.program;
      Lwt.wakeup_later resolver launch_args;
      Lwt.return_unit);
  Debug_rpc.set_command_handler rpc
    (module Attach_command)
    (fun _ ->
      Log.info "Attach request received";
      prevent_reenter ();
      Lwt.fail_with "Attach request is unsupported");
  Debug_rpc.set_command_handler rpc
    (module Disconnect_command)
    (fun _ ->
      Log.info "Disconnect request received";
      Debug_rpc.remove_command_handler rpc (module Disconnect_command);
      Lwt.wakeup_later_exn resolver Exit;
      Lwt.return_unit);
  promise
