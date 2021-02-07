include Stream (* This module will contain all the standard Stream module too *)

let take_while f s =
  Stream.from (fun _ ->
      Option.bind
        (Some (Stream.peek s))
        (fun x ->
          if f x then (
            Stream.junk s;
            x)
          else
            None))

let take n s =
  Stream.from (fun k ->
      if k >= n then
        None
      else
        Some (Stream.next s))

let to_string s =
  let buf = Buffer.create 16 in
  Stream.iter (fun x -> Buffer.add_char buf x) s;
  Buffer.contents buf
