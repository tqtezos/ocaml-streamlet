val init_state :
     int
  -> Simulation_state.t

val run :
     int
  -> unit Lwt.t

val simulate_node_callback :
     Simulation_state.t
  -> string
  -> int
  -> unit Lwt.t
