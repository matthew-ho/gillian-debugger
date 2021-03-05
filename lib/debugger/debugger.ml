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

type debugger_state =
  { file_source : string
  ; scopes : scope list
  ; execution_store : Sqlite3.db
  ; file_length : int
  ; mutable curr_line : int
  ; mutable curr_col : int
  ; mutable breakpoints : IntSet.t
  }

let scopes_tbl = Hashtbl.create 0

let global_scope = ({ name = "Global"; id = 1 } : scope)

let local_scope = ({ name = "Local"; id = 2 } : scope)

let contains s1 s2 =
  try
    let len = String.length s2 in
    for i = 0 to String.length s1 - len do
      if Stdlib.String.sub s1 i len = s2 then raise Exit
    done;
    false
  with
  | Exit ->
    true

let rec build_list l in_channel =
  match input_line in_channel with
  | line ->
    build_list (line :: l) in_channel
  | exception End_of_file ->
    close_in in_channel;
    List.rev l

let open_file file_path db =
  let f = open_in file_path in
  let file = Array.of_list (build_list [] f) in
  let () = Array.iteri (fun index line -> Db.store_line index line db) file in
  Array.length file

let has_reached_end dbg = dbg.curr_line >= dbg.file_length

let has_reached_start dbg = dbg.curr_line <= 0

let next_line dbg =
  if not (has_reached_end dbg) then
    dbg.curr_line <- dbg.curr_line + 1
  else
    ()

let prev_line dbg =
  if not (has_reached_start dbg) then
    dbg.curr_line <- dbg.curr_line - 1
  else
    ()

let get_curr_line_content dbg =
  Db.get_line dbg.curr_line dbg.execution_store

let has_hit_exception dbg =
  contains (get_curr_line_content dbg) "exception"

(* Line numbers in client start from 1. Our line numbers start from 0. *)
let get_curr_line_num dbg = dbg.curr_line + 1

(* Column numbers in client start from 1. Our column numbers start from 0. *)
let get_curr_col_num dbg = dbg.curr_col + 1

let has_hit_breakpoint dbg = IntSet.mem (get_curr_line_num dbg) dbg.breakpoints

let get_words dbg =
  Str.split (Str.regexp " ") (get_curr_line_content dbg)

let execute_line reverse dbg =
  match reverse with
  | true ->
    prev_line dbg
  | false ->
    let curr_line_content = get_curr_line_content dbg in
    let () = Log.info ("Executing line:  " ^ curr_line_content) in
    next_line dbg

let launch file_name =
  Hashtbl.replace scopes_tbl global_scope.id global_scope.name;
  Hashtbl.replace scopes_tbl local_scope.id local_scope.name;
  Db.reset ();
  let db = Db.create () in
  let file_length = open_file file_name db in
  ({ file_source = file_name
   ; scopes = [ global_scope; local_scope ]
   ; execution_store = db
   ; file_length = file_length
   ; curr_line = 0
   ; curr_col = 0
   ; breakpoints = IntSet.empty
   }
    : debugger_state)

let step ?(reverse = false) dbg =
  let () = execute_line reverse dbg in
  if has_reached_start dbg then
    let () = Log.info "Program has reached start" in
    Reached_start
  else if has_reached_end dbg then
    let () = Log.info "Program has finished running" in
    Reached_end
  else if has_hit_breakpoint dbg then
    let () = Log.info "Breakpoint has been hit" in
    Breakpoint
  else if has_hit_exception dbg then
    let () = Log.info "Uncaught exception has been hit" in
    Uncaught_exc
  else
    Step

let step_back dbg = step ~reverse:true dbg

let rec run ?(reverse = false) dbg =
  let stop_reason = step ~reverse dbg in
  match stop_reason with
  | Step ->
    run ~reverse dbg
  | Reached_start ->
    Reached_start
  | Reached_end ->
    Reached_end
  | Breakpoint ->
    Breakpoint
  | Uncaught_exc ->
    Uncaught_exc

let reverse_run dbg = run ~reverse:true dbg

let get_frames dbg =
  [ ({ index = 0
     ; name = "This is a test"
     ; source_path = dbg.file_source
     ; line_num = get_curr_line_num dbg
     ; col_num = get_curr_col_num dbg
     }
      : frame)
  ]

let set_breakpoints source_path bps dbg =
  if source_path <> dbg.file_source then
    Log.info ("Unable to set breakpoints for source file" ^ source_path)
  else
    dbg.breakpoints <- bps

let get_scopes dbg = dbg.scopes

let get_variables var_ref dbg =
  match Hashtbl.find_opt scopes_tbl var_ref with
  | None ->
    []
  | Some id ->
    if id = "Global" then
      [ ({ name = id ^ "_i"; value = "21354"; type_ = Some "integer" }
          : variable)
      ; ({ name = id ^ "_f"; value = "4.52"; type_ = Some "float" } : variable)
      ; ({ name = id ^ "_s"; value = "hello world"; type_ = Some "string" }
          : variable)
      ]
    else
      get_words dbg
      |> List.map (fun (word : string) : variable ->
             { name = word
             ; value = string_of_int (String.length word)
             ; type_ = Some "integer"
             })
