(** This file contains shortcuts to build JSON representations *)
type json = Yojson.Safe.t

let s s = `String s

let o l = `Assoc l

let i n = `Int n

let b tf = `Bool tf

let f n = `Float n

let l jl = `List jl

let ( % ) json field =
  let rec find_field l =
    match l with
    | [] ->
      None
    | (k, v) :: _ when field = k ->
      Some v
    | _ :: r ->
      find_field r
  in
  match json with `Assoc l -> find_field l | _ -> None

let parse = Yojson.Safe.from_string

let json_to_string = Yojson.Safe.to_string

let is_s = function `String _ -> true | _ -> false
