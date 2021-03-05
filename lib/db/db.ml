open Sqlite3

let db_name = "gillian_debugger.db"

let create () =
  let db = db_open db_name in
  let stmt =
    prepare
      db
      "CREATE TABLE log ( line_number INTEGER PRIMARY KEY, content TEXT NOT \
       NULL );"
  in
  let response = step stmt in
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
  let stmt = prepare db "INSERT INTO log VALUES (?, ?);" in
  let response = bind stmt 1 (Data.opt_int (Some line_num)) in

  if Rc.is_success response then
    let response = bind stmt 2 (Data.opt_text (Some content)) in
    if Rc.is_success response then
      let response = step stmt in
      if Rc.is_success response then
        Log.info ("DB: sucessfully stored line=" ^ content)
      else
        Log.info ("DB: unable to store line, error=" ^ Rc.to_string response)
    else
      Log.info ("DB: unable to store line, error=" ^ Rc.to_string response)
  else
    Log.info ("DB: unable to store line, error=" ^ Rc.to_string response)

let get_line line_num db =
  let stmt = prepare db "SELECT content FROM log WHERE line_number=?;" in
  let response = bind stmt 1 (Data.opt_int (Some line_num)) in
  if Rc.is_success response then
    let response = step stmt in
    if response == Rc.ROW then
      let rows = row_blobs stmt in
      let content = rows.(0) in
      let () =
        Log.info
          ("DB: get line succeeded for line_num="
          ^ string_of_int line_num
          ^ "content="
          ^ content)
      in
      content
    else
      let () =
        Log.info
          ("DB: get line failed for line_num="
          ^ string_of_int line_num
          ^ ", error=NO_DATA")
      in
      ""
  else
    let () =
      Log.info
        ("DB: get line failed for line_num="
        ^ string_of_int line_num
        ^ ", error="
        ^ Rc.to_string response)
    in
    ""
