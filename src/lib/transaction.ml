type transaction =
{ source: string
; destination: string
; amount: int
; fee: float
; counter: int
; gas_limit: int
; storage_limit: int }

type t = transaction

let to_string tx = (Printf.sprintf
  "source:%s, destination:%s, amount:%d, fee%f, counter%d, gas_limit%d, storage_limit%d"
  tx.source tx.destination tx.amount tx.fee tx.counter tx.gas_limit tx.storage_limit)

(* just for now...*)
(* let hash_txs (txs:(transaction list)): bytes list =
 *   let (strs:string list) = List.map (fun (tx:transaction) -> to_string tx) txs in
 *   let str = Base.String.concat ~sep:"\n" strs in
 *   Bytes.of_string str *)
let hash_txs (txs:(transaction list)): bytes list =
  let (strs:string list) = List.map (fun (tx:transaction) -> to_string tx) txs in
  List.map (fun s -> Bytes.of_string s) strs

let compare_list xs ys =
  Bytes.compare (Block.hash_bytes_list (hash_txs xs)) (Block.hash_bytes_list (hash_txs ys))

let equal_list xs ys =
  Bytes.equal (Block.hash_bytes_list (hash_txs xs)) (Block.hash_bytes_list (hash_txs ys))
