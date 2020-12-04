module Consensus_state = struct
  type t =
    { node_ids: string list }

  let create ~node_ids =
    { node_ids }

  let min_votes state = ((List.length state.node_ids) * 2) / 3

end
