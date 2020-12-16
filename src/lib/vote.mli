module Block_vote : sig
  type block_vote =
    { epoch: Epoch.t
    ; node_id: string
    ; block_hash: bytes
    ; signature: Tezos_crypto.Signature.t }

  type t = block_vote

  val compare : t -> t -> int
end

module SBV : Set.S with type elt = Block_vote.t
