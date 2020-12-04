open Streamlet_node

val register_node :
  node_info
  -> unit

val list_nodes :
  unit
  -> node_info list

val from_id :
  string
  -> node_info

val start_network :
   unit
  -> unit
