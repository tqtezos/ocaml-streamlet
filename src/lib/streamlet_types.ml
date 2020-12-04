module Block_vote = struct
  type block_vote =
  { epoch: int
  ; node_id: string
  ; block_hash: string
  ; signature: string
  }

  type t = block_vote

  let compare bv1 bv2 =
    let epoch_c = compare bv1.epoch bv2.epoch in
    let id_c = compare bv1.node_id bv2.node_id in
    let hash_c = compare bv1.block_hash bv2.block_hash in
    let sig_c = compare bv1.signature bv2.signature in
    if epoch_c != 0 then epoch_c
    else if id_c != 0 then id_c
    else if hash_c != 0 then hash_c
    else sig_c
end

module SBV = Set.Make(Block_vote)

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
