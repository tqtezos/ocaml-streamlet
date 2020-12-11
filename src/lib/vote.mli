module Block_vote: sig
  type block_vote =
  { epoch: int
  ; node_id: string
  ; block_hash: string
  ; signature: string
  }

  type t = block_vote

  val compare :
      t
   -> t
   -> int
end

module SBV: Set.S with type elt = Block_vote.t
