val make_test_nodes : int -> Node_info.t list
val init_state : int -> Simulation_state.t
val run : int -> unit Lwt.t

val simulate_node_callback :
  Simulation_state.t -> Node_info.t -> Epoch.t -> unit Lwt.t
