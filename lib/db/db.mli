val create : unit -> (Sqlite3.db, string) result

val reset : unit -> unit

val store_line : int -> string -> Sqlite3.db -> (unit, string) result

val get_line : int -> Sqlite3.db -> (string, string) result
