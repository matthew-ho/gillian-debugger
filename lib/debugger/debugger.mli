type stop_reason =
  | Step
  | Exited
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

val launch : string -> unit

val run : unit -> stop_reason

val step : unit -> stop_reason

val get_frames : unit -> frame list
