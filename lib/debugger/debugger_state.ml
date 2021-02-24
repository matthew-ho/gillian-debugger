let file = ref [||]

let current_line = ref 0

let rec build_list l in_channel =
  match input_line in_channel with
  | line ->
    build_list (line :: l) in_channel
  | exception End_of_file ->
    close_in in_channel;
    List.rev l

let open_file file_path =
  let f = open_in file_path in
  file := Array.of_list (build_list [] f)

let has_ended () = !current_line >= (Array.length !file)

let next_line () = current_line := !current_line + 1

let get_curr_line () =
  Array.get !file !current_line