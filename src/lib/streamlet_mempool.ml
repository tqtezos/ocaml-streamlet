open Transaction
open Vote
module SS = Set.Make (Bytes)
open Lwt

module Mempool_state = struct
  type t =
    { block_votes: (int, SBV.t) Base.Hashtbl.t
    ; mutable pending_txs: transaction list
    ; mutable retrieved_txs_count: int }

  let create =
    { block_votes=
        (Base.Hashtbl.create (module Base.Int) : (int, SBV.t) Base.Hashtbl.t)
    ; pending_txs= ([] : transaction list)
    ; retrieved_txs_count= 0 }

  let add_vote state vote =
    let s =
      match
        Base.Hashtbl.find state.block_votes (Epoch.to_int vote.Block_vote.epoch)
      with
      | Some z -> z
      | None -> SBV.empty in
    let new_set = SBV.add vote s in
    Base.Hashtbl.set state.block_votes
      ~key:(Epoch.to_int vote.Block_vote.epoch)
      ~data:new_set

  let add_txs state new_txs =
    let current = state.pending_txs in
    state.pending_txs <- new_txs @ current

  let get_pending_txs state =
    let current = state.retrieved_txs_count + 1 in
    state.retrieved_txs_count <- current ;
    get_test_txs current

  let find_votes state epoch =
    match Base.Hashtbl.find state.block_votes epoch with
    | Some s -> s
    | None -> SBV.empty

  let get_votes state epoch =
    return (Ok (SBV.elements (find_votes state epoch)))
end

let add_block_vote state v = return (Ok (Mempool_state.add_vote state v))

let find_block_votes state (epoch : Epoch.t) =
  return (Ok (Mempool_state.find_votes state (Epoch.to_int epoch)))

let add_new_txs state txs = return (Ok (Mempool_state.add_txs state txs))
let get_pending_operations _state = assert false
