module Consensus_state = struct
  type t =
    { nodes: Node.t list }

  let create nodes =
    { nodes }

  let min_votes state = ((List.length state.nodes) * 2) / 3

end
