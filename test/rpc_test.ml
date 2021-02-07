(* open Alcotest

(** Test suite for the Utils module. *)

let test_read_yojson_with_valid_request input_text () =
  let input = Stream.of_string input_text in
  let json_or_error = Rpc.read_yojson ~stream:input () in
  match json_or_error with
  | Ok _ ->
    (check pass) "No error was thrown" () ()
  | Error _ ->
    fail "Incorrect error was thrown"

let suite =
  [ ( "can parse valid request"
    , `Quick
    , test_read_yojson_with_valid_request
        "Content-Length: 119\r\n\
         \r\n\
         {\r\n\
        \    \"seq\": 153,\r\n\
        \    \"type\": \"request\",\r\n\
        \    \"command\": \"next\",\r\n\
        \    \"arguments\": {\r\n\
        \        \"threadId\": 3\r\n\
        \    }\r\n\
         }" )
  ] *)
