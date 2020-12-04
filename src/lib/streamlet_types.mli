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

type transaction =
{ source: string
; destination: string
; amount: int
; fee: float
; counter: int
; gas_limit: int
; storage_limit: int }

type block_data =
{ parent_hash : string
; epoch_number: int
; txs: transaction list
}

type block =
{ data: block_data
; hash: string
}

type proposed_block =
{ leader_id: string
; block_to_propose: block
}
