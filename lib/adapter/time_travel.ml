open Debug_protocol_ex

let send_stopped_events stop_reason rpc =
  match stop_reason with
  | Debugger.Step | Debugger.Reached_start | Debugger.Reached_end ->
    (* Send step stopped event after reaching the end to allow for stepping
       backwards *)
    Debug_rpc.send_event
      rpc
      (module Stopped_event)
      Stopped_event.Payload.(
        make ~reason:Stopped_event.Payload.Reason.Step ~thread_id:(Some 0) ())
  | Debugger.Breakpoint ->
    Debug_rpc.send_event
      rpc
      (module Stopped_event)
      Stopped_event.Payload.(
        make
          ~reason:Stopped_event.Payload.Reason.Breakpoint
          ~thread_id:(Some 0)
          ())
  | Debugger.Uncaught_exc ->
    Debug_rpc.send_event
      rpc
      (module Stopped_event)
      Stopped_event.Payload.(
        make
          ~reason:Stopped_event.Payload.Reason.Exception
          ~thread_id:(Some 0)
          ())

let run rpc =
  Lwt.pause ();%lwt
  Debug_rpc.set_command_handler
    rpc
    (module Continue_command)
    (fun _ ->
      let () = Log.info "Continue request received" in
      let stop_reason = Debugger.run () in
      send_stopped_events stop_reason rpc;%lwt
      Lwt.return (Continue_command.Result.make ()));
  Debug_rpc.set_command_handler
    rpc
    (module Next_command)
    (fun _ ->
      let () = Log.info "Next request received" in
      let stop_reason = Debugger.step () in
      send_stopped_events stop_reason rpc);
  Debug_rpc.set_command_handler
    rpc
    (module Reverse_continue_command)
    (fun _ ->
      let () = Log.info "Reverse continue request received" in
      let stop_reason = Debugger.reverse_run () in
      send_stopped_events stop_reason rpc);
  Debug_rpc.set_command_handler
    rpc
    (module Step_back_command)
    (fun _ ->
      let () = Log.info "Step back request received" in
      let stop_reason = Debugger.step_back () in
      send_stopped_events stop_reason rpc);
  Lwt.return ()