include Stdlib.Stream

(* Returns a stream containing the elements from stream *)
let take_while f s =
  Stdlib.Stream.from (fun _ ->
      Option.bind (Stdlib.Stream.peek s) (fun x ->
          if f x then (
            Stdlib.Stream.junk s;
            Some x)
          else
            None))

(* Returns a stream containing the first n elements from stream s. If the stream
   has less than n elements, a stream containing all elements will be returned.*)
let take n s =
  Stdlib.Stream.from (fun k ->
      if k >= n then
        None
      else
        try Some (Stdlib.Stream.next s) with Stdlib.Stream.Failure -> None)

(* Coverts a char stream to a string. *)
let to_string s =
  let buf = Buffer.create 16 in
  Stdlib.Stream.iter (fun x -> Buffer.add_char buf x) s;
  Buffer.contents buf
