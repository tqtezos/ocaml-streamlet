open Block
open Transaction
open Vote

type vote_response = Block.t -> (Block_vote.t, exn) Asynchronous_result.t

let mk_test_block parent_hash epoch txs : block =
  {parent_hash; epoch; txs; notarizations= []}

let test_block n chain_hash =
  mk_test_block chain_hash (Epoch.of_int n) (get_test_txs n)

let rec get_test_block = function
  | 0 -> (genesis ()).data
  | 1 -> test_block 1 (genesis ()).hash
  | n -> test_block n (hash_virtual (get_test_block (n - 1)))

(* test blocks with consecutive epocs *)

module Db_state = struct
  type t =
    { mutable proposed_blocks: hashed_block list
    ; mutable voter_subs: vote_response list }

  let create = {proposed_blocks= []; voter_subs= []}
  let get_blocks state = state.proposed_blocks

  let add_block state proposed =
    state.proposed_blocks <- proposed :: state.proposed_blocks

  let add_vote_sub state sub =
    let current = state.voter_subs in
    state.voter_subs <- sub :: current
end

let add_proposed_block state proposed =
  return (Db_state.add_block state proposed)

let get_longest_notarized_chain = assert false
let get_longest_final_chain = assert false
let subscribe_voter state response = Db_state.add_vote_sub state response
