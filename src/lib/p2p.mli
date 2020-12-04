open Streamlet_types

val get_test_block :
     int
  -> block

module P2p_state : sig
  type t =
    { mutable proposed_blocks : proposed_block list }

  val create : t

  val add_proposed_block :
       t
    -> proposed_block
    -> unit

  val get_proposed_blocks :
       t
   ->  proposed_block list
end
