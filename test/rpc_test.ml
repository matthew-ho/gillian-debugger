open Alcotest

(** Test suite for the Utils module. *)

let example_header = "Content-Length: 119\r\n\r\n"

let example_json =
  "{\r\n\
  \    \"seq\": 153,\r\n\
  \    \"type\": \"request\",\r\n\
  \    \"command\": \"next\",\r\n\
  \    \"arguments\": {\r\n\
  \        \"threadId\": 3\r\n\
  \    }\r\n\
   }"

let test_read_yojson_with_valid_request input_text () =
  let input = Stream.of_string input_text in
  let json_or_error = Rpc.read_yojson ~stream:input () in
  match json_or_error with
  | Ok _ ->
    (check pass) "No error was thrown" () ()
  | Error _ ->
    fail "Incorrect error was thrown"

let test_read_yojson_with_invalid_request input_text () =
  let input = Stream.of_string input_text in
  let json_or_error = Rpc.read_yojson ~stream:input () in
  match json_or_error with
  | Ok _ ->
    fail "No error was thrown"
  | Error _ ->
    (check pass) "Error was thrown" () ()

let suite =
  [ ( "can parse valid request"
    , `Quick
    , test_read_yojson_with_valid_request (example_header ^ example_json) )
  ; ( "returns error with invalid header"
    , `Quick
    , test_read_yojson_with_invalid_request "Invalid header" )
  ; ( "returns error with invalid json content"
    , `Quick
    , test_read_yojson_with_invalid_request
        "Content-Length: 17\r\n\r\n{\r\n    \"seq\": 153,\r\n" )
  ; ( "returns error with incorrect number of bytes specified"
    , `Quick
    , test_read_yojson_with_invalid_request
        ("Content-Length: 112\r\n\r\n" ^ example_json) )
  ]
