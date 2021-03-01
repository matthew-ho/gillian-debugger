let file = ref [||]

let file_source = ref ""

let current_line = ref 0

let current_col = ref 0

let breakpoints = ref IntSet.empty

let rec build_list l in_channel =
  match input_line in_channel with
  | line ->
    build_list (line :: l) in_channel
  | exception End_of_file ->
    close_in in_channel;
    List.rev l

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

let open_file file_path =
  let f = open_in file_path in
  file_source := file_path;
  file := Array.of_list (build_list [] f)

let has_reached_end () = !current_line >= Array.length !file

let has_reached_start () = !current_line <= 0

let next_line () =
  if not (has_reached_end ()) then
    current_line := !current_line + 1
  else
    ()

let prev_line () =
  if not (has_reached_start ()) then
    current_line := !current_line - 1
  else
    ()

let get_curr_line () = Array.get !file !current_line

let has_hit_exception () = contains (Array.get !file !current_line) "exception"

let get_index () = 0

let get_name () = "This is a test"

let get_source () = !file_source

(* Line numbers in client start from 1. Our line numbers start from 0. *)
let get_curr_line_num () = !current_line + 1

(* Column numbers in client start from 1. Our column numbers start from 0. *)
let get_curr_col_num () = !current_col + 1

let set_breakpoints source bps =
  if source <> !file_source then
    Log.info ("Unable to set breakpoints for source file" ^ !file_source)
  else
    breakpoints := bps

let has_hit_breakpoint () = IntSet.mem (get_curr_line_num ()) !breakpoints

let get_words () = Str.split (Str.regexp " ") (get_curr_line ())
