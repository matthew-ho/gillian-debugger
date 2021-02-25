type stop_reason =
  | Exited
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

let launch file_name = Debugger_state.open_file file_name

let rec run () =
  if Debugger_state.has_ended () then
    let () = Log.info "Program has finished running" in
    Exited
  else if Debugger_state.has_hit_exception () then
    let () = Log.info "Uncaught exception has been hit" in
    Uncaught_exc
  else
    let () = Log.info ("Executing line:  " ^ Debugger_state.get_curr_line ()) in
    let () = Debugger_state.next_line () in
    run ()

let get_frames () =
  [ ({ index = 0
     ; name = Debugger_state.get_name ()
     ; source_path = Debugger_state.get_source ()
     ; line_num = Debugger_state.get_curr_line_num ()
     ; col_num = Debugger_state.get_curr_col_num ()
     }
      : frame)
  ]
