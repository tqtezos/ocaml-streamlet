open Lwt
open Streamlet_utils
open Block
open Transaction
open Vote
open Mempool

let write_block_to_chain _state _block =
  assert false

let get_longest_notarized_chain (_node_id: string) =
   let block = P2p.get_test_block 2
   in return (Ok block)

let is_block_final _state _block =
  assert false

let receive_new_txs _state = assert false

let new_txs_to_mempool _txs = assert false

let validate_tx _tx = assert false

let count_ids_matching_hash (block_votes: Block_vote.t list) hash : int =
    let matching = List.filter (fun v -> String.equal v.Block_vote.block_hash hash) block_votes in
    let unique = SBV.of_list matching in
    SBV.cardinal unique

let vote_counts_by_hash (votes: SBV.t) =
  let vote_list = SBV.elements votes in
  let hash_list = List.map (fun v -> v.Block_vote.block_hash) vote_list in
  let hash_set = Mempool.SS.of_list hash_list in
  let unique_hashes = Mempool.SS.elements hash_set in
  Lwt_io.printf "vote_counts_by_hash - |vote_list| = %d, |hash_list| = %d, |unique_hashes| = %d\n"
    (List.length vote_list) (List.length hash_list) (List.length unique_hashes)
  >>= fun _vs ->
  return (List.map (fun h ->(h, count_ids_matching_hash vote_list h)) unique_hashes)

let check_for_votes (state:Simulation_state.t) ~epoch =
  let epoch_votes = Mempool.Mempool_state.find_block_votes state.mempool_state epoch in
  vote_counts_by_hash epoch_votes
  >>= fun vcs_by_hash ->
  return (Ok vcs_by_hash)

let notarize_block _state ~node_id ~block_hash ~epoch : ( unit , 'err) Asynchronous_result.t =
    Lwt_io.printf "%s is notarizing %s for epoch %d\n" node_id block_hash epoch
    >>= fun _vs ->
    return (Ok ())
    (* todo: update state *)

let show_vote_counts (vote_counts: (string * int) list) (node_id:string) epoch : string =
  let foldf acc (hash, count) =
    let s = Printf.sprintf "hash: %s ..... %d\n" hash count in
    s ^ acc in
  if List.length vote_counts == 0
    then Printf.sprintf "(%s: no votes for epoch %d)\n" node_id epoch
    else List.fold_left foldf (Printf.sprintf "%s: vote counts for epoch %d:\n" node_id  epoch) vote_counts

let run_voter (state:Simulation_state.t) epoch my_id =
  (* TODO: This needs to progress from the point of this node's longest chain, the epoch number
  could be ahead *)
  check_for_votes state ~epoch
  >>= fun res ->
  match res with
  | Error e ->
      Lwt_io.printf "Error checking for votes: %s" (Base.Exn.to_string e)
      >>= fun () ->
      return (Error e)
  | Ok vote_counts -> (
    Lwt_io.printf "%s" (show_vote_counts vote_counts my_id epoch)
    >>= fun () ->
    let can_notarize = List.filter (fun (_hash, count) -> count >= Baker.Consensus_state.min_votes state.consensus_state) vote_counts in
    let can_notarize_hashes = List.map (fun (h, _c) -> h) can_notarize in
    Lwt_io.printf "%s: %d blocks can now be notarized for epoch %d...\n" my_id (List.length can_notarize_hashes) epoch
    >>= fun () ->
    let rec loop = function
      | [] -> return (Ok ())
      | (h :: hs) ->
        notarize_block state ~node_id:my_id ~block_hash:h ~epoch
        >>= fun res ->
        match res with
          | Error _ -> fail_with "Failed to notarize block"
          | Ok () -> loop hs in

    loop can_notarize_hashes
    >>= fun _ ->
    (* TODO:
    *   * check for finalized blocks
    *   * write finalized blocks to chains
    *   * clean up state (proposed blocks, notarized blocks, etc.)  *)
    return (Ok ()) )

let broadcast_vote (state:Simulation_state.t) ~(vote:Block_vote.t) =
  Lwt_io.printf "Adding block vote - epoch: %d, node_id: %s, block_hash: %s, signature: %s\n"
      vote.epoch vote.node_id vote.block_hash vote.signature
  >>= fun () ->
  return ( Ok (Mempool_state.add_block_vote state.mempool_state vote))

module Leader = struct

  let pending_from_mempool (state:Simulation_state.t) node_id =
    Mempool_state.get_pending_txs state.mempool_state node_id

  let broadcast_new_block (_state:Simulation_state.t) leader_id leader_secret epoch txs
      (*: ( unit , 'err) Asynchronous_result.t *) =
    Lwt_io.printf "%s: broadcasting a new block for epoch %d\n" leader_id (Epoch.to_int epoch)
    >>= fun () ->
    get_longest_notarized_chain leader_id
    >>= fun res ->
    match res with
    | Error _ -> fail_with "Failed to retrieve the longest chain"
    | Ok longest_block ->
    let parent_chain_hash = longest_block.chain_hash in
    let data =
      { chain_hash = parent_chain_hash
      ; epoch
      ; notarizations = []
      ; txs } in
    let hash = hash_virtual data in
    let new_block =
      { data
      ; hash } in
    let signature = sign_hashed_block new_block in
    let proposed =
      { leader_id
      ; block_to_propose = new_block }  in
    P2p.P2p_state.add_proposed_block state.p2p_state proposed;
    let (vote: Block_vote.t) =
      { epoch = proposed.block_to_propose.data.epoch_number
      ; node_id = proposed.leader_id
      ; block_hash = proposed.block_to_propose.hash
      ; signature } in
    return ((broadcast_vote state ~vote))
    >>= fun _res' ->
    return (Ok () )

  let run_leader (state:Simulation_state.t) epoch my_id =
    Lwt_io.printf "%s: - I am the leader for epoch %d\n" my_id epoch
    >>= fun () ->
    Mempool.Mempool_state.get_pending_txs state.mempool_state my_id
    >>= fun result ->
    match result with
    | Ok txs ->
      broadcast_new_block state my_id epoch txs
      >>= fun res ->
      (match res with
      | Ok () -> run_voter state epoch my_id
      | Error e -> return (Error e))
    | Error e -> return (Error e)
end

let receive_epoch_event (state:Simulation_state.t) my_id epoch_num =
    Lwt_io.(flush stdout)
    >>= fun () ->
    let leader = get_leader_for_epoch state.consensus_state.node_ids epoch_num in
    (if String.equal leader my_id
      then Leader.run_leader state epoch_num my_id
      else run_voter state epoch_num my_id)
    >>= fun res ->
    match res with
    | Ok () -> return ()
    | Error e -> Lwt_io.printf "Error processing epoch event for %s epoch:%d - %s\n"
                 my_id epoch_num (Base.Exn.to_string e)
