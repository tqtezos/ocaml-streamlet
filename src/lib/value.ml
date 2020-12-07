type t = (Operation_hash.t * Operation.t) list

type id = bytes

let pp ppf _t =
  Format.fprintf ppf "#<signed-block>"

let hash t =
  let hashes = List.sort Operation_hash.compare (List.map fst t) in
  Data_encoding.Binary.to_bytes_exn
    Operation_list_list_hash.encoding
    (Operation_list_list_hash.compute [ Operation_list_hash.compute hashes ])

let create () =
  []

(* FIXME: This should actually check the signature *)
let valid _pk _v =
  true

let compare v1 v2 =
  Bytes.compare (hash v1) (hash v2)

let compare_id id1 id2 =
  Bytes.compare id1 id2

let equal a b =
  (compare a b) = 0

let equal_id a b =
  (compare_id a b) = 0
