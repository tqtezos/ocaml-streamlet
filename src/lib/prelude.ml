(* Comparison utilities *)

let make_equal_opt a b f =
  match (a, b) with
  | (None, None) ->
    true
  | (Some _, None) ->
    false
  | (None, Some _) ->
    false
  | (Some x, Some y) ->
    f x y

(* Used in functions which call compare in a sequence for legibility *)
let (>>-?) x y =
  if x = 0 then
    y ()
  else
    x
