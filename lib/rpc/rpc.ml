let read_yojson ?(stream = Stream.of_channel stdin) () =
  let cl = "Content-Length: " in
  let cll = String.length cl in
  let clength = Stream.to_string (Stream.take cll stream) in
  let num_json_bytes_str =
    Stream.to_string (Stream.take_while (fun x -> x != '\r') stream)
  in
  let expected_end_of_header = "\r\n\r\n" in
  let end_of_header =
    Stream.to_string (Stream.take (String.length expected_end_of_header) stream)
  in
  if clength = cl && end_of_header = expected_end_of_header then
    let num_json_bytes = int_of_string num_json_bytes_str in
    let raw = Stream.to_string (Stream.take num_json_bytes stream) in
    if String.length raw != num_json_bytes then
      Error (Printf.sprintf "Insufficient data in buffer")
    else
      let json_or_error =
        try Ok (Json.parse raw) with
        | Failure message ->
          Error
            (Printf.sprintf
               "Cannot parse: \n\n%s\n\n as json. Message : %s"
               raw
               message)
        | e ->
          Error
            (Printf.sprintf
               "Cannot parse : \n\n%s\n\n as json. Exception : %s"
               raw
               (Printexc.to_string e))
      in
      json_or_error
  else
    Error (Printf.sprintf "Invalid header")

let write_yojson ?(channel = stdout) outyj =
  let content = Json.json_to_string outyj in
  let sep = "\r\n\r\n" in
  let cl = String.length content in
  let cls = string_of_int cl in
  let header = Printf.sprintf "Content-Length: %s" cls in
  Printf.fprintf channel "%s%s%s" header sep content
