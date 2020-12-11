open Streamlet

  (* let make_node_ids n : (string list) =
   *   let rec make_list acc n : (string list) =
   *     match n with
   *       | 0 -> acc
   *       | x -> make_list (("Node_" ^ (Int.to_string x)) :: acc) (n-1) in
   *   make_list ["Node_0"] n *)

  (* TODO: Copy test key creation from pala_test_model.ml:
      let test_ideal_convergence _switch () =
        let (keys, schedule) = Helpers.generate_fixed_schedule lim in
        let nodes = Helpers.start_pala_instances keys schedule lim 0.01 in
  *)
  let make_test_nodes n : (string list) =
    let make_node n =
      { node_id = "Node_" ^ (Int.to_string x)
      ; port = 8000 + n
      ; node_pk_hash =
      ; node_secret_key = } in
    let rec make_list acc n : (string list) =
      match n with
        | 0 -> acc
        | x -> make_list (make_node n :: acc) (n-1) in
    make_list ["Node_0"] n

  let init_state num_nodes : Simulation_state.t =
    let node_ids = make_test_nodes num_nodes in
    Simulation_state.create nodes

  let simulate_node_callback state node_id epoch  =
    receive_epoch_event state node_id epoch

  let curried_callback state node_id : (Timers.callback) =
    simulate_node_callback state node_id

  let run num_nodes =
    let state = init_state num_nodes in
    let ids = state.consensus_state.node_ids in
    let callbacks = (List.map (fun s -> curried_callback state s) ids) in
    Timers.init_timer callbacks
