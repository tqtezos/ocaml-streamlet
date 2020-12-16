open Block
open Vote

type vote_response = Block.t -> (Block_vote.t, exn) Asynchronous_result.t

val get_test_block : int -> block

module Db_state : sig
  type t =
    { mutable proposed_blocks: hashed_block list
    ; mutable voter_subs: vote_response list }

  val create : t
  val get_blocks : t -> hashed_block list
  val add_block : t -> hashed_block -> unit
  val add_vote_sub : t -> vote_response -> unit
end

val add_proposed_block :
  Db_state.t -> hashed_block -> (unit, 'err) Asynchronous_result.t

val get_longest_notarized_chain : (block, 'err) Asynchronous_result.t
val get_longest_final_chain : (block, 'err) Asynchronous_result.t
val subscribe_voter : Db_state.t -> vote_response -> unit
