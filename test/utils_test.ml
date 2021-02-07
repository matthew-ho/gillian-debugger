open Alcotest

(** Test suite for the Utils module. *)

let json = testable Yojson.Safe.pp Yojson.Safe.equal

let test_hello_with_name name () =
  let greeting = Utils.Json.s name in
  (* Just to show we can import Json from our utils. *)
  let expected = `String name in
  check json "same string" greeting expected

let suite =
  [ "can greet Tom", `Quick, test_hello_with_name "Tom"
  ; "can greet John", `Quick, test_hello_with_name "John"
  ]
