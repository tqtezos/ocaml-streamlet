open Streamlet_types

val get_leader_for_epoch :
     string list
  -> int
  -> string

val get_block_hash :
  block_data
  -> string

val sign_block :
  block
  -> string

val get_test_txs : transaction list
