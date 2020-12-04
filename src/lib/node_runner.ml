open Streamlet_node

  let make_node_ids n : (string list) =
    let rec make_list acc n : (string list) =
      match n with
        | 0 -> acc
        | x -> make_list (("Node_" ^ (Int.to_string x)) :: acc) (n-1) in
    make_list ["Node_0"] n

  let init_state num_nodes : Simulation_state.t =
    let node_ids = make_node_ids num_nodes in
    Simulation_state.create ~node_ids

  let simulate_node_callback state node_id epoch  =
    receive_epoch_event state node_id epoch

  let curried_callback state node_id : (Timers.callback) =
    simulate_node_callback state node_id

  let run num_nodes =
    let state = init_state num_nodes in
    let ids = state.consensus_state.node_ids in
    let callbacks = (List.map (fun s -> curried_callback state s) ids) in
    Timers.init_timer callbacks
