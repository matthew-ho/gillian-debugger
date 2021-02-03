(** Contains handler that take raw rpc messages and output something usable *)

val read_yojson : ?channel:in_channel -> unit -> (Json.json, string) result
(** Reads a message and gives a yojson. Default channel is stdin; *)

val write_yojson : ?channel:out_channel -> Json.json -> unit
(** Sends a yojson to the client. Default channel is stdout. *)
