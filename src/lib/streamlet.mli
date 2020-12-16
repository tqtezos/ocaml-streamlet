open Block
open Vote
open Transaction

val write_block_to_chain :
  Simulation_state.t -> block -> ('ok, 'err) Asynchronous_result.t

val get_longest_notarized_chain : string -> (block, 'err) Asynchronous_result.t

val is_block_final :
  Simulation_state.t -> block -> ('ok, 'err) Asynchronous_result.t

val receive_new_txs :
  Simulation_state.t -> unit -> (transaction list, 'err) Asynchronous_result.t

val new_txs_to_mempool : transaction list -> (unit, 'err) Asynchronous_result.t
val validate_tx : transaction -> ('ok, 'err) Asynchronous_result.t

module Leader : sig
  val pending_from_mempool :
       Simulation_state.t
    -> (Operation_extension.operation list, 'err) Asynchronous_result.t

  val broadcast_new_block :
       Simulation_state.t
    -> Node_info.t
    -> Epoch.t
    -> transaction list
    -> (unit, 'err) Asynchronous_result.t

  val run_leader :
       Simulation_state.t
    -> Epoch.t
    -> Node_info.t
    -> (unit, 'err) Asynchronous_result.t
end

val receive_epoch_event :
  Simulation_state.t -> Node_info.t -> Epoch.t -> unit Lwt.t

val vote_counts_by_hash : SBV.t -> (bytes * int) list Lwt.t

val check_for_votes :
     Simulation_state.t
  -> epoch:Epoch.t
  -> ((bytes * int) list, 'err) Asynchronous_result.t

val notarize_block :
     Simulation_state.t
  -> node:Node_info.t
  -> block_hash:bytes
  -> epoch:Epoch.t
  -> (unit, 'err) Asynchronous_result.t

val run_voter :
     Simulation_state.t
  -> Epoch.t
  -> Node_info.t
  -> (unit, 'err) Asynchronous_result.t

val broadcast_vote :
  Simulation_state.t -> vote:Block_vote.t -> (unit, 'err) Asynchronous_result.t
