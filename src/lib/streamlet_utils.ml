let get_leader_for_epoch nodes epoch =
  let n = List.length nodes in
  let idx = Epoch.to_int epoch mod n in
  List.nth nodes idx

let fold_i n ~init ~f =
  let rec loop n acc =
    match n with n when n <= 0 -> acc | n -> f n (loop (n - 1) acc) in
  loop n init

let generate_keys n =
  let f (_n : int) arg =
    let _, pk, sk = Signature.generate_key () in
    (pk, sk) :: arg in
  fold_i n ~init:[] ~f

let hash_bytes_list bytes_list =
  let bytes = Blake2B.hash_bytes ~key:(Bytes.of_string "block") bytes_list in
  Blake2B.to_bytes bytes
