module Consensus_state : sig
  type t =
    { nodes: Node.t list }

  val create : Node.t list -> t

  val min_votes : t -> int

end
