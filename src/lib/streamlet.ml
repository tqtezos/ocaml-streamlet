open Lwt
open Distributed_db
open Streamlet_utils
open Block
open Streamlet_mempool
open Vote

let write_block_to_chain _state _block = assert false

let get_longest_notarized_chain (_node_id : string) =
  let block = get_test_block 2 in
  return (Ok block)

let is_block_final _state _block = assert false
let receive_new_txs _state = assert false
let new_txs_to_mempool _txs = assert false
let validate_tx _tx = assert false

let count_ids_matching_hash (block_votes : Block_vote.t list) hash : int =
  let matching =
    List.filter (fun v -> Bytes.equal v.Block_vote.block_hash hash) block_votes
  in
  let unique = SBV.of_list matching in
  SBV.cardinal unique

let vote_counts_by_hash (votes : SBV.t) =
  let vote_list = SBV.elements votes in
  let hash_list = List.map (fun v -> v.Block_vote.block_hash) vote_list in
  let hash_set = Streamlet_mempool.SS.of_list hash_list in
  let unique_hashes = Streamlet_mempool.SS.elements hash_set in
  Lwt_io.printf
    "vote_counts_by_hash - |vote_list| = %d, |hash_list| = %d, |unique_hashes| \
     = %d\n"
    (List.length vote_list) (List.length hash_list)
    (List.length unique_hashes)
  >>= fun _vs ->
  return
    (List.map (fun h -> (h, count_ids_matching_hash vote_list h)) unique_hashes)

let check_for_votes (state : Simulation_state.t) ~epoch =
  find_block_votes state.mempool_state epoch
  >>= fun epoch_votes ->
  match epoch_votes with
  | Error _ -> fail_with "Failed to notarize block"
  | Ok evs ->
      vote_counts_by_hash evs >>= fun vcs_by_hash -> return (Ok vcs_by_hash)

let notarize_block _state ~(node : Node_info.t) ~block_hash ~epoch :
    (unit, 'err) Asynchronous_result.t =
  Lwt_io.printf "%s is notarizing %s for epoch %d\n" node.node_id
    (Bytes.to_string block_hash)
    (Epoch.to_int epoch)
  >>= fun _vs -> return (Ok ())

(* todo: update state *)

let show_vote_counts (vote_counts : (bytes * int) list) (node_id : string) epoch
    : string =
  let vote_counts' =
    List.map (fun (b, n) -> (Bytes.to_string b, n)) vote_counts in
  let foldf acc (hash, count) =
    let s = Printf.sprintf "hash: %s ..... %d\n" hash count in
    s ^ acc in
  if List.length vote_counts' == 0 then
    Printf.sprintf "(%s: no votes for epoch %d)\n" node_id epoch
  else
    List.fold_left foldf
      (Printf.sprintf "%s: vote counts for epoch %d:\n" node_id epoch)
      vote_counts'

let run_voter (state : Simulation_state.t) (epoch : Epoch.t)
    (my_node : Node_info.t) =
  (* TODO: This needs to progress from the point of this node's longest chain, the epoch number
     could be ahead *)
  check_for_votes state ~epoch
  >>= fun res ->
  match res with
  | Error e ->
      Lwt_io.printf "Error checking for votes: %s" (Base.Exn.to_string e)
      >>= fun () -> return (Error e)
  | Ok vote_counts ->
      Lwt_io.printf "%s"
        (show_vote_counts vote_counts my_node.node_id (Epoch.to_int epoch))
      >>= fun () ->
      let can_notarize =
        List.filter
          (fun (_hash, count) ->
            count >= Baker.Consensus_state.min_votes state.consensus_state)
          vote_counts in
      let can_notarize_hashes = List.map (fun (h, _c) -> h) can_notarize in
      Lwt_io.printf "%s: %d blocks can now be notarized for epoch %d...\n"
        my_node.node_id
        (List.length can_notarize_hashes)
        (Epoch.to_int epoch)
      >>= fun () ->
      let rec loop = function
        | [] -> return (Ok ())
        | h :: hs -> (
            notarize_block state ~node:my_node ~block_hash:h ~epoch
            >>= fun res ->
            match res with
            | Error _ -> fail_with "Failed to notarize block"
            | Ok () -> loop hs ) in
      loop can_notarize_hashes
      >>= fun _ ->
      (* TODO:
         *   * check for finalized blocks
         *   * write finalized blocks to chains
         *   * clean up state (proposed blocks, notarized blocks, etc.) *)
      return (Ok ())

let broadcast_vote (state : Simulation_state.t) ~(vote : Vote.Block_vote.t) =
  Lwt_io.printf
    "Adding block vote - epoch: %d, node_id: %s, block_hash: %s, signature: %s\n"
    (Epoch.to_int vote.epoch) vote.node_id
    (Bytes.to_string vote.block_hash)
    (Signature.to_string vote.signature)
  >>= fun () -> add_block_vote state.mempool_state vote

module Leader = struct
  let pending_from_mempool (state : Simulation_state.t) =
    Node.get_pending_operations state.mempool_state

  let broadcast_new_block (state : Simulation_state.t) (node_info : Node_info.t)
      epoch txs =
    Lwt_io.printf "%s: broadcasting a new block for epoch %d\n"
      node_info.node_id (Epoch.to_int epoch)
    >>= fun () ->
    get_longest_notarized_chain node_info.node_id
    >>= fun res ->
    match res with
    | Error _ -> fail_with "Failed to retrieve the longest chain"
    | Ok longest_block -> (
        let parent_chain_hash = longest_block.parent_hash in
        let data =
          {parent_hash= parent_chain_hash; epoch; notarizations= []; txs} in
        let hash = hash_virtual data in
        let new_block = {data; hash} in
        let signature = sign_hashed_block node_info.node_secret_key new_block in
        Node.propose_block state.db_state new_block
        >>= fun res ->
        match res with
        | Error _ -> fail_with "Failed to notarize block"
        | Ok () ->
            let (vote : Vote.Block_vote.t) =
              { epoch= new_block.data.epoch
              ; node_id= node_info.node_id
              ; block_hash= new_block.hash
              ; signature } in
            return (broadcast_vote state ~vote) >>= fun _res' -> return (Ok ())
        )

  let run_leader (state : Simulation_state.t) (epoch : Epoch.t) my_info =
    Lwt_io.printf "%s: - I am the leader for epoch %d\n"
      my_info.Node_info.node_id (Epoch.to_int epoch)
    >>= fun () ->
    Node.get_pending_operations state.mempool_state
    >>= fun result ->
    match result with
    | Ok ops -> (
        broadcast_new_block state my_info epoch
          (Transaction.filter_from_operations ops)
        >>= fun res ->
        match res with
        | Ok () -> run_voter state epoch my_info
        | Error e -> return (Error e) )
    | Error e -> return (Error e)
end

let receive_epoch_event (state : Simulation_state.t) (my_node : Node_info.t)
    (epoch : Epoch.t) =
  Lwt_io.(flush stdout)
  >>= fun () ->
  let leader_node = get_leader_for_epoch state.consensus_state.nodes epoch in
  let leader = leader_node.Node_info.node_id in
  ( if String.equal leader my_node.node_id then
    Leader.run_leader state epoch my_node
  else run_voter state epoch my_node )
  >>= fun res ->
  match res with
  | Ok () -> return ()
  | Error e ->
      Lwt_io.printf "Error processing epoch event for %s epoch:%d - %s\n"
        my_node.Node_info.node_id (Epoch.to_int epoch) (Base.Exn.to_string e)
