(** Contains handler that take raw rpc messages and output something usable *)

val read_yojson : ?stream:char Stream.t -> unit -> (Json.json, string) result
(** Reads a message and gives a yojson. Default stream is stream of stdin; *)

val write_yojson : ?channel:out_channel -> Json.json -> unit
(** Sends a yojson to the client. Default channel is stdout. *)
