let rec loop () =
  let%lwt raw_json_res = Rpc.read_yojson () in
  let () =
      match raw_json_res with
      | Ok json -> print_endline (Json.json_to_string json)
      | Error s -> print_endline s
  in
  loop ()

let start_server () =
  loop ()

let start () = Lwt_main.run (start_server ())