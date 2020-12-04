module Consensus_state : sig
  type t =
    { node_ids: string list }

  val create : node_ids: string list -> t

  val min_votes : t -> int

end
