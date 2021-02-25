type stop_reason =
  | Step
  | Exited
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

let execute_next_line () =
  Log.info ("Executing line:  " ^ Debugger_state.get_curr_line ());
  Debugger_state.next_line ()

let launch file_name = Debugger_state.open_file file_name

let step () =
  if Debugger_state.has_ended () then
    let () = Log.info "Program has finished running" in
    Exited
  else if Debugger_state.has_hit_exception () then
    let () = Log.info "Uncaught exception has been hit" in
    Uncaught_exc
  else
    let () = execute_next_line () in
    Step

let rec run () =
  let stop_reason = step () in
  match stop_reason with
  | Exited ->
    Exited
  | Uncaught_exc ->
    Uncaught_exc
  | Step ->
    let () = execute_next_line () in
    run ()

let get_frames () =
  [ ({ index = Debugger_state.get_index ()
     ; name = Debugger_state.get_name ()
     ; source_path = Debugger_state.get_source ()
     ; line_num = Debugger_state.get_curr_line_num ()
     ; col_num = Debugger_state.get_curr_col_num ()
     }
      : frame)
  ]
