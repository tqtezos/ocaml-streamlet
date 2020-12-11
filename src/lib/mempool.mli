module SS:Set.S with type elt = String.t

open Transaction
open Vote

module Mempool_state : sig
  type t =
    { block_votes: (int, SBV.t) Base.Hashtbl.t
    ; pending_txs : transaction list
    ; mutable retrieved_txs_count : int }

  val create: t

  val add_block_vote: t -> Block_vote.t -> unit

  val find_block_votes: t -> int -> SBV.t

  val add_new_txs :
      transaction list
    -> unit

  val get_pending_txs :
       t
    -> string
    -> ( transaction list , 'err) Asynchronous_result.t

  val get_block_votes :
       t
    -> int
    -> ( Block_vote.t list , 'err) Asynchronous_result.t

end
