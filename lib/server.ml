let rec loop () =
  let%lwt raw_json_res = Rpc.read_yojson () in
  loop ()

let start_server () =
  loop ()

let start () = Lwt_main.run (start_server ())