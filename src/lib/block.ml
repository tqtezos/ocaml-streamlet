open Prelude
open Transaction

type block =
{ parent_hash : bytes
; epoch: Epoch.t
; txs: transaction list
; notarizations : Notarization.t list
}

type t = block

type hashed_block =
{ data: block
; hash: bytes
}

(* Printing *)

let pp ppf t =
  Format.fprintf ppf "Block {parent_hash=%a; epoch=%d; notarizations=%d, transactions=%d}"
    Blake2B.pp (Blake2B.of_bytes_exn t.parent_hash)
    (Epoch.to_int t.epoch)
    (List.length t.notarizations)
    (List.length t.txs)

let pp_opt ppf = function
  | Some block ->
    pp ppf block
  | None ->
    Format.fprintf ppf "Timeout_block { nil }"

(* Hashing *)

let hash_bytes_list bytes_list =
  let bytes = Blake2B.hash_bytes ~key:(Bytes.of_string "block") bytes_list in
  Blake2B.to_bytes bytes

(* Hash a virtual block (no chain hash) *)
let hash_virtual {epoch; txs; _} =
  hash_bytes_list [ Epoch.hash epoch; hash_bytes_list (hash_txs txs) ]

(* Hash a regular block *)
let hash_full {data; hash; _} =
  hash_bytes_list
    [ data.parent_hash; Epoch.hash data.epoch; Notarization.hash_list data.notarizations
    ; hash_bytes_list (hash_txs data.txs); hash ]

let sign_block secret_key block =
  Signature.sign ~watermark:Generic_operation secret_key (hash_virtual block)

let sign_hashed_block secret_key hashed_block =
  Signature.sign ~watermark:Generic_operation secret_key (hash_full hashed_block)

let check_signature public_key block signature =
  Signature.check ~watermark:Generic_operation public_key signature (hash_full block)

(* Comparison *)

let compare a b =
  let rec compare_notarizations a b = match (a, b) with
    | ([], []) -> 0
    | (_x, []) -> 1
    | ([], _y) -> -1
    | (x :: xs, y :: ys) ->
      Notarization.compare x y
      >>-? fun () ->
      compare_notarizations xs ys
  in
  Epoch.compare a.epoch b.epoch
  >>-? fun () ->
  Transaction.compare_list a.txs b.txs
  >>-? fun () ->
  compare_notarizations a.notarizations b.notarizations
  >>-? fun () ->
  Bytes.compare a.parent_hash b.parent_hash


let equal_notarizations a b =
  let rec loop a b = match (a, b) with
    | ([], []) -> true
    | (_x, []) -> false
    | ([], _y) -> false
    | (x :: xs, y :: ys) ->
      if Notarization.equal x y then
        loop xs ys
      else
        false
  in
  let n_a = List.sort Notarization.compare a.notarizations in
  let n_b = List.sort Notarization.compare b.notarizations in
  loop n_a n_b

let equal_chain a b =
  Bytes.equal a.parent_hash b.parent_hash

let equal_chain_opt a b =
  make_equal_opt a b equal_chain

let equal a b =
  equal_chain a b && equal_notarizations a b && Transaction.equal_list a.txs b.txs

let equal_opt a b =
  make_equal_opt a b equal

(* Genesis *)

let genesis () : hashed_block =
  let fake_genesis =
    { parent_hash = Bytes.create 0
    ; epoch = 0l
    ; notarizations = [ ]
    ; txs = [] } in
  let parent_hash' = hash_virtual fake_genesis in
  { data = fake_genesis
  ; hash = parent_hash' }

(* let create signatory secret_key epoch parent_hash =
 *   let block = { parent_hash; epoch; notarizations = []; txs = [] } in
 *   let signature = sign_block secret_key block in
 *   { block with notarizations = [Notarization.{signatory; signature}] } *)

(* Notarization *)

let is_notarized state t =
  List.length t.notarizations >= Baker.Consensus_state.min_votes state

let find_signatory_opt public_key {notarizations; _} =
  List.find_opt (fun Notarization.{signatory; _} ->
      Signature.Public_key.equal signatory public_key
    ) notarizations

let has_signatory public_key block =
  match find_signatory_opt public_key block with
  | Some _notarization ->
    true
  | None ->
    false
