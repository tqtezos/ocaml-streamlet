open Node_info
open Streamlet

let make_test_nodes n : node_info list =
  let make_node n =
    let pkh, _pk, sk = Signature.generate_key () in
    { node_id= "Node_" ^ Int.to_string n
    ; port= 8000 + n
    ; node_pk_hash= pkh
    ; node_secret_key= sk } in
  let rec make_list acc n : node_info list =
    match n with 0 -> acc | x -> make_list (make_node x :: acc) (x - 1) in
  make_list [] n

let init_state num_nodes : Simulation_state.t =
  let nodes = make_test_nodes num_nodes in
  Simulation_state.create nodes

let simulate_node_callback state (node : node_info) epoch =
  receive_epoch_event state node epoch

let curried_callback state node : Timers.callback =
  simulate_node_callback state node

let run num_nodes =
  let state = init_state num_nodes in
  let nodes = state.consensus_state.nodes in
  let callbacks = List.map (fun s -> curried_callback state s) nodes in
  Timers.init_timer callbacks
