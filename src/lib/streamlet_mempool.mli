module SS : Set.S with type elt = Bytes.t
open Operation_extension
open Transaction
open Vote

module Mempool_state : sig
  type t =
    { block_votes: (int, SBV.t) Base.Hashtbl.t
    ; mutable pending_txs: transaction list
    ; mutable retrieved_txs_count: int }

  val create : t
  val add_vote : t -> Block_vote.t -> unit
  val find_votes : t -> int -> SBV.t
  val add_txs : t -> transaction list -> unit
  val get_pending_txs : t -> transaction list
  val get_votes : t -> int -> (Block_vote.t list, 'err) Asynchronous_result.t
end

val add_block_vote :
  Mempool_state.t -> Block_vote.t -> (unit, 'err) Asynchronous_result.t

val find_block_votes :
  Mempool_state.t -> Epoch.t -> (SBV.t, 'err) Asynchronous_result.t

val add_new_txs :
  Mempool_state.t -> transaction list -> (unit, 'err) Asynchronous_result.t

val get_pending_operations :
  Mempool_state.t -> (operation list, 'err) Asynchronous_result.t
