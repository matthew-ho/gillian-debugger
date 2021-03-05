type stop_reason =
  | Step
  | Reached_start
  | Reached_end
  | Breakpoint
  | Uncaught_exc

type frame =
  { index : int
  ; name : string
  ; source_path : string
  ; line_num : int
  ; col_num : int
  }

type scope =
  { name : string
  ; id : int
  }

type variable =
  { name : string
  ; value : string
  ; type_ : string option
  }

type debugger_state =
  { file_source : string
  ; scopes : scope list
  ; execution_store : Sqlite3.db
  ; file_length : int
  ; mutable curr_line : int
  ; mutable curr_col : int
  ; mutable breakpoints : IntSet.t
  }

val launch : string -> (debugger_state, string) result

val step : ?reverse:bool -> debugger_state -> stop_reason

val step_back : debugger_state -> stop_reason

val run : ?reverse:bool -> debugger_state -> stop_reason

val reverse_run : debugger_state -> stop_reason

val get_frames : debugger_state -> frame list

val set_breakpoints : string -> IntSet.t -> debugger_state -> unit

val get_scopes : debugger_state -> scope list

val get_variables : int -> debugger_state -> variable list
