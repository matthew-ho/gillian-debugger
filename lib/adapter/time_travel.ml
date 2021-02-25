open Debug_protocol_ex

let run rpc =
  Lwt.pause ();%lwt
  Debug_rpc.set_command_handler
    rpc
    (module Continue_command)
    (fun _ ->
      let () = Log.info "Continue request received" in
      let stop_reason = Debugger.run () in
      let _ =
        match stop_reason with
        | Debugger.Step ->
          let () =
            Log.info
              "Debugger stopped because of step after running. This should not \
               happen"
          in
          Lwt.return_unit
        | Debugger.Exited ->
          Lwt.return_unit
          (* Do not send Terminated event to allow for stepping backwards *)
        | Debugger.Uncaught_exc ->
          Debug_rpc.send_event
            rpc
            (module Stopped_event)
            Stopped_event.Payload.(
              make
                ~reason:Stopped_event.Payload.Reason.Exception
                ~thread_id:(Some 0)
                ())
      in
      Lwt.return (Continue_command.Result.make ()));
  Debug_rpc.set_command_handler
    rpc
    (module Next_command)
    (fun _ ->
      let () = Log.info "Next request received" in
      let stop_reason = Debugger.step () in
      match stop_reason with
      | Debugger.Step ->
        Debug_rpc.send_event
          rpc
          (module Stopped_event)
          Stopped_event.Payload.(
            make
              ~reason:Stopped_event.Payload.Reason.Step
              ~thread_id:(Some 0)
              ())
      | Debugger.Exited ->
        Lwt.return_unit
        (* Do not send Terminated event to allow for stepping backwards *)
      | Debugger.Uncaught_exc ->
        Debug_rpc.send_event
          rpc
          (module Stopped_event)
          Stopped_event.Payload.(
            make
              ~reason:Stopped_event.Payload.Reason.Exception
              ~thread_id:(Some 0)
              ()));
  Lwt.return ()
