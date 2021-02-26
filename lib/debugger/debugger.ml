type stop_reason =
  | Step
  | Reached_start
  | Reached_end
  | Breakpoint
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

let execute_line reverse =
  match reverse with
  | true ->
    Debugger_state.prev_line ()
  | false ->
    let () = Log.info ("Executing line:  " ^ Debugger_state.get_curr_line ()) in
    Debugger_state.next_line ()

let launch file_name = Debugger_state.open_file file_name

let step ?(reverse = false) () =
  let () = execute_line reverse in
  if Debugger_state.has_reached_start () then
    let () = Log.info "Program has reached start" in
    Reached_start
  else if Debugger_state.has_reached_end () then
    let () = Log.info "Program has finished running" in
    Reached_end
  else if Debugger_state.has_hit_breakpoint () then
    let () = Log.info "Breakpoint has been hit" in
    Breakpoint
  else if Debugger_state.has_hit_exception () then
    let () = Log.info "Uncaught exception has been hit" in
    Uncaught_exc
  else
    Step

let step_back () = step ~reverse:true ()

let rec run ?(reverse = false) () =
  let stop_reason = step ~reverse () in
  match stop_reason with
  | Step ->
    run ~reverse ()
  | Reached_start ->
    Reached_start
  | Reached_end ->
    Reached_end
  | Breakpoint ->
    Breakpoint
  | Uncaught_exc ->
    Uncaught_exc

let reverse_run () = run ~reverse:true ()

let get_frames () =
  [ ({ index = Debugger_state.get_index ()
     ; name = Debugger_state.get_name ()
     ; source_path = Debugger_state.get_source ()
     ; line_num = Debugger_state.get_curr_line_num ()
     ; col_num = Debugger_state.get_curr_col_num ()
     }
      : frame)
  ]

let set_breakpoints source_path bps =
  Debugger_state.set_breakpoints source_path bps
