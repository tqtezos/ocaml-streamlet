open Block

val get_test_block :
     int
  -> block

module P2p_state : sig
  type t =
    { mutable proposed_blocks : block list }

  val create : t

  val add_proposed_block :
       t
    -> block
    -> unit

  val get_proposed_blocks :
       t
   ->  block list
end
