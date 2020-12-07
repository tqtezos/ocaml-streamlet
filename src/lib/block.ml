open Prelude

type t = {
  epoch : Epoch.t;
  value : Value.t;
  notarizations : Notarization.t list;
  chain_hash : bytes;
}

(* Printing *)

let pp ppf t =
  Format.fprintf ppf "Block {epoch=%d; value=%a; notarizations=%d, chain_hash=%a}"
    (Epoch.to_int t.epoch)
    Value.pp t.value (List.length t.notarizations)
    Blake2B.pp (Blake2B.of_bytes_exn t.chain_hash)

let pp_opt ppf = function
  | Some block ->
    pp ppf block
  | None ->
    Format.fprintf ppf "Timeout_block { nil }"

(* Hashing *)

let hash_bytes bytes_list =
  let bytes = Blake2B.hash_bytes ~key:(Bytes.of_string "block") bytes_list in
  Blake2B.to_bytes bytes

(* Hash a virtual block (no chain hash) *)
let hash_virtual {epoch; value; _} =
  hash_bytes [ Epoch.hash epoch; Value.hash value ]

(* Hash a regular block *)
let hash_full {epoch; value; chain_hash; _} =
  hash_bytes [ Epoch.hash epoch; Value.hash value; chain_hash ]

(* Sign a regular block *)
let sign secret_key block =
  Signature.sign ~watermark:Generic_operation secret_key (hash_full block)

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
  Value.compare a.value b.value
  >>-? fun () ->
  compare_notarizations a.notarizations b.notarizations
  >>-? fun () ->
  Bytes.compare a.chain_hash b.chain_hash

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
  Bytes.equal a.chain_hash b.chain_hash

let equal_chain_opt a b =
  make_equal_opt a b equal_chain

let equal a b =
  equal_chain a b && equal_notarizations a b && Value.equal a.value b.value

let equal_opt a b =
  make_equal_opt a b equal

(* Genesis *)

let genesis () =
  let fake_genesis =
    { epoch = 0l
    ; value = [ ]
    ; notarizations = [ ]
    ; chain_hash = Bytes.create 0
    }
  in
  let chain_hash = hash_virtual fake_genesis in
  { fake_genesis with chain_hash }

let create signatory secret_key epoch chain_hash =
  let block = { epoch; value = []; notarizations = []; chain_hash } in
  let signature = sign secret_key block in
  { block with notarizations = [Notarization.{signatory; signature}] }

(* Notarization *)

let is_notarized t threshold =
  List.length t.notarizations >= threshold

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
