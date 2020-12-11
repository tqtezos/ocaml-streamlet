open Block
open Streamlet_utils

let mk_test_block parent_hash epoch txs: block =
  { parent_hash
  ; epoch
  ; txs
  ; notarizations = [] }

let test_block n chain_hash = mk_test_block chain_hash (Epoch.of_int n) (get_test_txs n)

let rec get_test_block = function
  | 0 -> (genesis ()).data
  | 1 -> test_block 1 (genesis ()).hash
  | n -> test_block n (hash_virtual (get_test_block (n - 1)))
(* test blocks with consecutive epocs *)

module P2p_state = struct
  type t =
    { mutable proposed_blocks : block list }

  let create = { proposed_blocks = [] }

  let get_proposed_blocks state = state.proposed_blocks

  let add_proposed_block state proposed =
    state.proposed_blocks <- proposed :: state.proposed_blocks ;

end
