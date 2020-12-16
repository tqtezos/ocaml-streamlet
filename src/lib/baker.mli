open Vote

module Consensus_state : sig
  type t = {nodes: Node_info.t list}

  val create : Node_info.t list -> t
  val min_votes : t -> int
end

val propose_new_block :
  Block.t -> Block_vote.t list -> (unit, 'err) Asynchronous_result.t
