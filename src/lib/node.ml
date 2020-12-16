let validate_proposed_block proposed_block =
  Validator.validate_block proposed_block

let propose_block state proposed =
  Distributed_db.add_proposed_block state proposed

let get_longest_notarized_chain = Distributed_db.get_longest_notarized_chain
let get_longest_final_chain = Distributed_db.get_longest_final_chain

let subscribe_voter state response =
  return (Distributed_db.subscribe_voter state response)

let add_block_vote state vote = Streamlet_mempool.add_block_vote state vote
let add_new_txs txs = Streamlet_mempool.add_new_txs txs
let get_pending_operations = Streamlet_mempool.get_pending_operations
