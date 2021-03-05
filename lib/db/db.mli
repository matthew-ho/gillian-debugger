val create : unit -> Sqlite3.db

val reset : unit -> unit

val store_line : int -> string -> Sqlite3.db -> unit

val get_line : int -> Sqlite3.db -> string
