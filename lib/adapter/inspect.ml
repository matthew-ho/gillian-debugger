open Debug_protocol_ex

let run rpc =
  let promise, _ = Lwt.task () in
  Debug_rpc.set_command_handler
    rpc
    (module Threads_command)
    (fun () ->
      let () = Log.info "Threads request received" in
      let main_thread = Thread.make ~id:0 ~name:"main" in
      Lwt.return (Threads_command.Result.make ~threads:[ main_thread ] ()));
  Debug_rpc.set_command_handler
    rpc
    (module Stack_trace_command)
    (fun _ ->
      let () = Log.info "Stack trace request received" in
      let (frames : Debugger.frame list) = Debugger.get_frames () in
      let stack_frames =
        frames
        |> Stdlib.List.map (fun (frame : Debugger.frame) ->
               let source_path =
                 Some (Source.make ~path:(Some frame.Debugger.source_path) ())
               in
               Stack_frame.make
                 ~id:frame.Debugger.index
                 ~name:frame.Debugger.name
                 ~source:source_path
                 ~line:frame.Debugger.line_num
                 ~column:frame.Debugger.col_num
                 ())
      in
      Lwt.return Stack_trace_command.Result.(make ~stack_frames ()));
  Lwt.join [ promise ]
