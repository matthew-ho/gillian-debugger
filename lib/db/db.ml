open Sqlite3

let db_name = "gillian_debugger.db"

let create_log_table_sql =
  "CREATE TABLE log ( line_number INTEGER PRIMARY KEY, content TEXT NOT NULL );"

let create () =
  let db = db_open db_name in
  let response = exec db create_log_table_sql in
  let () =
    if Rc.is_success response then
      Log.info "DB: sucessfully created log table"
    else
      Log.info ("DB: unable to create log table, error=" ^ Rc.to_string response)
  in
  db

let reset () =
  if Sys.file_exists db_name then
    Sys.remove db_name
  else
    ()

let store_line line_num content db =
  let sql =
    "INSERT INTO log VALUES ("
    ^ string_of_int line_num
    ^ ", '"
    ^ content
    ^ "');"
  in
  let response = exec db sql in
  if Rc.is_success response then
    Log.info ("DB: sucessfully stored line=" ^ content)
  else
    Log.info ("DB: unable to store line, error=" ^ Rc.to_string response)

let exec_no_headers_wrapper db stmt =
  let acc = ref (Array.of_list []) in
  let cb rows = acc := rows in
  let response = exec_no_headers db ~cb stmt in
  if Rc.is_success response then
    Ok !acc
  else
    Error (Rc.to_string response)

let get_line line_num db =
  let stmt =
    "SELECT content FROM log WHERE line_number=" ^ string_of_int line_num ^ ";"
  in
  let response = exec_no_headers_wrapper db stmt in
  match response with
  | Ok rows ->
    (match rows.(0) with
    | Some content ->
      let () = Log.info ("DB: get line succeeded for line_num=" ^ string_of_int line_num) in
      content
    | None ->
      let () = Log.info ("DB: get line failed for line_num=" ^ string_of_int line_num) in
      "")
  | Error err ->
    let () = Log.info ("DB: get line failed for line_num=" ^ string_of_int line_num ^ ", error=" ^ err) in
    ""