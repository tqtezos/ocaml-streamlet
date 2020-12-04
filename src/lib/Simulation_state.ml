type t =
  { consensus_state : Baker.Consensus_state.t
  ; mempool_state : Mempool.Mempool_state.t
  ; p2p_state: P2p.P2p_state.t }


let create ~node_ids =
  { consensus_state = Baker.Consensus_state.create ~node_ids
  ; mempool_state = Mempool.Mempool_state.create
  ; p2p_state = P2p.P2p_state.create }
