val get_leader_for_epoch : Node_info.t list -> Epoch.t -> Node_info.t
val fold_i : int -> init:'accum -> f:(int -> 'accum -> 'accum) -> 'accum

val generate_keys :
     int
  -> (Tezos_crypto.Signature.public_key * Tezos_crypto.Signature.secret_key)
     list

val hash_bytes_list : bytes list -> bytes
