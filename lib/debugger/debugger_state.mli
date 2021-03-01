val open_file : string -> unit

val has_reached_end : unit -> bool

val has_reached_start : unit -> bool

val next_line : unit -> unit

val prev_line : unit -> unit

val get_curr_line : unit -> string

val has_hit_exception : unit -> bool

val get_index : unit -> int

val get_name : unit -> string

val get_source : unit -> string

val get_curr_line_num : unit -> int

val get_curr_col_num : unit -> int

val set_breakpoints : string -> IntSet.t -> unit

val has_hit_breakpoint : unit -> bool
