type stop_reason =
  | Step
  | Reached_start
  | Reached_end
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

val launch : string -> unit

val step : ?reverse:bool -> unit -> stop_reason

val step_back : unit -> stop_reason

val run : ?reverse:bool -> unit -> stop_reason

val reverse_run : unit -> stop_reason

val get_frames : unit -> frame list
