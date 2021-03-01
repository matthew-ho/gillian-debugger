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

type scope =
  { name : string
  ; id : int
  }

type variable =
  { name : string
  ; value : string
  ; type_ : string option
  }

let scopes_tbl = Hashtbl.create 0

let global_scope = ({ name = "Global"; id = 1 } : scope)

let local_scope = ({ name = "Local"; id = 2 } : scope)

let execute_line reverse =
  match reverse with
  | true ->
    Debugger_state.prev_line ()
  | false ->
    let () = Log.info ("Executing line:  " ^ Debugger_state.get_curr_line ()) in
    Debugger_state.next_line ()

let launch file_name =
  Hashtbl.replace scopes_tbl global_scope.id global_scope.name;
  Hashtbl.replace scopes_tbl local_scope.id local_scope.name;
  Debugger_state.open_file file_name

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

let get_scopes () = [ global_scope; local_scope ]

let get_variables var_ref =
  match Hashtbl.find_opt scopes_tbl var_ref with
  | None ->
    []
  | Some id ->
    [ ({ name = id ^ "_i"; value = "21354"; type_ = Some "integer" } : variable)
    ; ({ name = id ^ "_f"; value = "4.52"; type_ = Some "float" } : variable)
    ; ({ name = id ^ "_s"; value = "hello world"; type_ = Some "string" }
        : variable)
    ]
