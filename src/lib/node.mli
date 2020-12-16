open Distributed_db
open Operation_extension
open Streamlet_mempool
open Transaction
open Vote

val validate_proposed_block : Block.t -> string

val propose_block :
  Db_state.t -> Block.hashed_block -> (unit, 'err) Asynchronous_result.t

val get_longest_notarized_chain : (Block.t, 'err) Asynchronous_result.t
val get_longest_final_chain : (Block.t, 'err) Asynchronous_result.t

val subscribe_voter :
  Db_state.t -> vote_response -> (unit, 'err) Asynchronous_result.t

val add_block_vote :
     Streamlet_mempool.Mempool_state.t
  -> Block_vote.t
  -> (unit, 'err) Asynchronous_result.t

val add_new_txs :
  Mempool_state.t -> transaction list -> (unit, 'err) Asynchronous_result.t

val get_pending_operations :
     Streamlet_mempool.Mempool_state.t
  -> (operation list, 'err) Asynchronous_result.t
