module Consensus_state = struct
  type t = {nodes: Node_info.t list}

  let create nodes = {nodes}
  let min_votes state = List.length state.nodes * 2 / 3
end

let propose_new_block _parent _parent_votes = assert false
