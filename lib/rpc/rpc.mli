(** Contains handler that take raw rpc messages and output something usable *)

val read_yojson :
  ?channel:Lwt_io.input_channel -> unit -> (Json.json, string) result Lwt.t
(** Reads a message and gives a yojson *)

val write_yojson : ?channel:Lwt_io.output_channel -> Json.json -> unit Lwt.t
(** Sends a yojson to the client *)
