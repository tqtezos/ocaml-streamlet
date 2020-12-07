open Streamlet_types

let mk_test_block parent_hash epoch_number txs hash : block =
  { data =
      { parent_hash
      ; epoch_number
      ; txs }
  ; hash }

let block_0 = mk_test_block "invalid hash TBD" 0 Utils.get_test_txs "block_0_hash_tbd"

let block_1 = mk_test_block "block_0_hash_tbd" 1 Utils.get_test_txs "block_1_hash_tbd"

let block_2 = mk_test_block "block_1_hash_tbd" 2 Utils.get_test_txs "block_2_hash_tbd"

let get_test_block  = function
  | 0 -> block_0
  | 1 -> block_1
  | 2 -> block_2
  | _n -> assert false


module P2p_state = struct
  type t =
    { mutable proposed_blocks : proposed_block list }

  let create = { proposed_blocks = [] }

  let get_proposed_blocks state = state.proposed_blocks

  let add_proposed_block state proposed =
    state.proposed_blocks <- proposed :: state.proposed_blocks ;

end
