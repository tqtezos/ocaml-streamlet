open Streamlet_types

let get_leader_for_epoch node_ids epoch =
  let n = List.length node_ids in
  let idx = epoch mod n in
  List.nth node_ids idx

let get_block_hash _block = "Block hash not yet implemented"
(* TBD: do somethign like this (from interactive_mini_network):
  let hash =
    match choice with
    | `Old_default -> default
    | `Force v -> v
    | `From_protocol_kind -> of_protocol_kind protocol_kind
    | `Random ->
        let seed =
          Fmt.str "%d:%f" (Random.int 1_000_000) (Unix.gettimeofday ())
        in
        let open Tezos_crypto in
        let block_hash = Block_hash.hash_string [seed] in
        Block_hash.to_b58check block_hash in
*)

let sign_block _block = "Block signature not yet implemented"

let get_test_txs : transaction list =
  [ { source = "not imnplemented"
    ; destination = "not imnplemented"
    ; amount = 10
    ; fee = 10.
    ; counter = 1
    ; gas_limit = 100000
    ; storage_limit = 10000 }
    ; { source = "not imnplemented"
    ; destination = "not imnplemented"
    ; amount = 20
    ; fee = 20.
    ; counter = 2
    ; gas_limit = 200000
    ; storage_limit = 20000 } ]
