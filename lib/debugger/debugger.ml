let launch file_name = Debugger_state.open_file file_name

let rec run () =
  if Debugger_state.has_ended () then
    Log.info "Program has finished running"
  else
    let () = Log.info ("Executing line:  " ^ (Debugger_state.get_curr_line ()))  in
    let () = Debugger_state.next_line () in
    run ()