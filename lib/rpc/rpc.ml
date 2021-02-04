let read_yojson ?(channel = stdin) () =
  let clength = match Stdio.In_channel.input_line channel with
    | Some clength -> clength
    | None -> ""
  in
  let cl = "Content-Length: " in
  let cll = String.length cl in
  if String.sub clength 0 cll = cl then
    let offset = match Sys.os_type with "Win32" -> 0 | _ -> 0 in
    let numstr =
      String.sub clength cll (String.length clength - cll + offset)
    in
    let num =
      int_of_string numstr + match Sys.os_type with "Win32" -> 1 | _ -> 2
    in
    (* num is supposedly the length of the json message *)
    let buffer = Bytes.create num in
    let read_bytes = Stdlib.input channel buffer 0 num in
    if read_bytes != num then
      Error (Printf.sprintf "Insuffience data in buffer")
    else
      let raw = Bytes.to_string buffer in
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
