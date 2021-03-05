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
  if Rc.is_success response then
    Ok db
  else
    Stdlib.Error
      (Printf.sprintf
         "Unable to create log table, error=%s"
         (Rc.to_string response))

let reset () =
  if Sys.file_exists db_name then
    Sys.remove db_name
  else
    ()

let store_line line_num content db =
  let stmt = prepare db "INSERT INTO log VALUES (?, ?);" in
  let response = bind stmt 1 (Data.opt_int (Some line_num)) in
  if not (Rc.is_success response) then
    Stdlib.Error
      (Printf.sprintf
         "Cannot bind line_num=%d, error=%s"
         line_num
         (Rc.to_string response))
  else
    let response = bind stmt 2 (Data.opt_text (Some content)) in
    if not (Rc.is_success response) then
      Stdlib.Error
        (Printf.sprintf
           "Cannot bind content=%s, error=%s"
           content
           (Rc.to_string response))
    else
      let response = step stmt in
      if not (Rc.is_success response) then
        Stdlib.Error
          (Printf.sprintf
             "SQL statement failed error=%s"
             (Rc.to_string response))
      else
        Ok ()

let get_line line_num db =
  let stmt = prepare db "SELECT content FROM log WHERE line_number=?;" in
  let response = bind stmt 1 (Data.opt_int (Some line_num)) in
  if not (Rc.is_success response) then
    Stdlib.Error
      (Printf.sprintf
         "Cannot bind line_num=%d, error=%s"
         line_num
         (Rc.to_string response))
  else
    let response = step stmt in
    if response == Rc.ROW then
      let rows = row_blobs stmt in
      let content = rows.(0) in
      Ok content
    else
      Stdlib.Error
        (Printf.sprintf
           "No execution log found, error=%s"
           (Rc.to_string response))
