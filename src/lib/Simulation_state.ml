open Baker
open Distributed_db
open Streamlet_mempool

type t =
  { consensus_state: Consensus_state.t
  ; mempool_state: Mempool_state.t
  ; db_state: Db_state.t }

let create nodes =
  { consensus_state= Consensus_state.create nodes
  ; mempool_state= Mempool_state.create
  ; db_state= Db_state.create }
