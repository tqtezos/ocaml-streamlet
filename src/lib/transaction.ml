open Streamlet_utils

type transaction =
  { source: string
  ; destination: string
  ; amount: int
  ; fee: float
  ; counter: int
  ; gas_limit: int
  ; storage_limit: int }

type t = transaction

let to_string tx =
  Printf.sprintf
    "source:%s, destination:%s, amount:%d, fee%f, counter%d, gas_limit%d, \
     storage_limit%d"
    tx.source tx.destination tx.amount tx.fee tx.counter tx.gas_limit
    tx.storage_limit

(* just for now...*)
let hash_txs (txs : transaction list) : bytes list =
  let (strs : string list) =
    List.map (fun (tx : transaction) -> to_string tx) txs in
  List.map (fun s -> Bytes.of_string s) strs

let compare_list xs ys =
  Bytes.compare (hash_bytes_list (hash_txs xs)) (hash_bytes_list (hash_txs ys))

let equal_list xs ys =
  Bytes.equal (hash_bytes_list (hash_txs xs)) (hash_bytes_list (hash_txs ys))

let get_test_txs n : transaction list =
  [ { source= "not imnplemented"
    ; destination= "not imnplemented"
    ; amount= 10 * n
    ; fee= 10.
    ; counter= 1
    ; gas_limit= 100000
    ; storage_limit= 10000 }
  ; { source= "not imnplemented"
    ; destination= "not imnplemented"
    ; amount= 20 * n
    ; fee= 20.
    ; counter= 1
    ; gas_limit= 200000
    ; storage_limit= 20000 } ]

(* TODO...*)
let filter_from_operations (_ops : Operation_extension.operation list) :
    transaction list =
  []
