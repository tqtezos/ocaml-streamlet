open Streamlet_types

module SS = Set.Make(String)
open Lwt

module Mempool_state = struct
  type t =
    { block_votes: (int, SBV.t) Hashtbl.t
    ; pending_txs : transaction list }

  let create =
    { block_votes = (Hashtbl.create 256: (int, SBV.t) Hashtbl.t)
    ; pending_txs = ([] : transaction list)}

  let add_block_vote state vote =
    let s = match Hashtbl.find_opt state.block_votes vote.Block_vote.epoch with
    | Some z -> z
    | None -> SBV.empty in
    let new_set = SBV.add vote s in
    Hashtbl.replace state.block_votes vote.Block_vote.epoch new_set


  let add_new_txs _txs = assert false

  let get_pending_txs _state node_id : ( transaction list , 'err) Asynchronous_result.t =
    Lwt_io.printf "Transactions requested from mempool by %s ...\n" node_id
    >>= fun () ->
    return (Ok Helpers.get_test_txs)

  let find_block_votes state epoch =
    match Hashtbl.find_opt state.block_votes epoch with
    | Some s -> s
    | None -> SBV.empty

  let get_block_votes state epoch =
    return ( Ok (SBV.elements (find_block_votes state epoch)))

end
