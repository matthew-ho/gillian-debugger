let file = ref [||]

let file_source = ref ""

let current_line = ref 0

let current_col = ref 0

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

let has_ended () = !current_line >= Array.length !file

let next_line () = current_line := !current_line + 1

let get_curr_line () = Array.get !file !current_line

let has_hit_exception () = contains (Array.get !file !current_line) "exception"

let get_index () = 0

let get_name () = "This is a test"

let get_source () = !file_source

(* Line numbers in client start from 1. Our line numbers start from 0. *)
let get_curr_line_num () = !current_line + 1

(* Column numbers in client start from 1. Our column numbers start from 0. *)
let get_curr_col_num () = !current_col + 1
