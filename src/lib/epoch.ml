type t = Int32.t

let (=) =
  Compare.Int32.equal
let (>) =
  Compare.Int32.(>)
let (>=) =
  Compare.Int32.(>=)
let (<) =
  Compare.Int32.(<)
let (<=) =
  Compare.Int32.(<=)

let (+) =
  Int32.add
let (-) =
  Int32.sub

let compare =
  Int32.compare
let equal =
  Int32.equal

let to_int = Int32.to_int
let of_int = Int32.of_int

let encode t =
  Data_encoding.Binary.to_bytes_exn Data_encoding.int32 t

let decode t =
  Data_encoding.Binary.of_bytes_exn Data_encoding.int32 t

let hash_key =
  Bytes.of_string "epoch"

let hash t =
  Blake2B.to_bytes (Blake2B.hash_bytes ~key:hash_key [encode t])
