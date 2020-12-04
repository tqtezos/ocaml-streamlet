open Streamlet_types

type node_info =
  { node_id : string;
    port: int;
    node_pk: string;
  }

 type node_paths =
   { path_to_chain: string }

 type node_config =
   { tbd: int }

val write_block_to_chain :
     < paths: node_paths
     ; config: node_config
     ; .. >
  -> block
  -> ( 'ok , 'err) Asynchronous_result.t

val is_block_notarized :
     < paths: node_paths
     ; config: node_config
     ; .. >
  -> block
  -> ( 'ok , 'err) Asynchronous_result.t

val get_longest_notarized_chain :
      string
  -> ( block, 'err) Asynchronous_result.t

val is_block_final :
     < paths: node_paths
     ; config: node_config
     ; .. >
  -> block
  -> ( 'ok , 'err) Asynchronous_result.t

val receive_new_txs :
     < paths: node_paths
     ; config: node_config
     ; other_voters: node_info list
     ; .. >
  -> unit
  -> ( transaction list , 'err) Asynchronous_result.t

val new_txs_to_mempool :
    transaction list
  -> ( unit, 'err) Asynchronous_result.t

val validate_tx :
  transaction
  -> ( 'ok , 'err) Asynchronous_result.t

module Leader : sig
  val pending_from_mempool :
     Simulation_state.t
  -> string
  -> ( transaction list, 'err) Asynchronous_result.t

  val broadcast_new_block :
     Simulation_state.t
  -> string
  -> int
  -> transaction list
  -> ( unit , 'err) Asynchronous_result.t

  val run_leader :
     Simulation_state.t
  -> int
  -> string
  -> ( unit , 'err) Asynchronous_result.t

end

val receive_epoch_event :
   Simulation_state.t
-> string
-> int
-> unit Lwt.t

val vote_counts_by_hash :
      SBV.t
  -> ((string * int) list) Lwt.t

val check_for_votes :
   Simulation_state.t
-> epoch: int
-> ((string * int) list, 'err) Asynchronous_result.t

val notarize_block :
     Simulation_state.t
  -> node_id:string
  -> block_hash:string
  -> epoch: int
  -> ( unit , 'err) Asynchronous_result.t

val run_voter :
     Simulation_state.t
  -> int
  -> string
  -> ( unit , 'err) Asynchronous_result.t

val broadcast_vote :
     Simulation_state.t
  -> vote: Block_vote.t
  -> ( unit, 'err) Asynchronous_result.t
