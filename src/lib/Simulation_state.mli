type t =
  { consensus_state: Baker.Consensus_state.t
  ; mempool_state: Streamlet_mempool.Mempool_state.t
  ; db_state: Distributed_db.Db_state.t }

val create : Node_info.t list -> t
