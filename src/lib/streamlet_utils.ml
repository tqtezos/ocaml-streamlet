open Transaction

let get_leader_for_epoch node_ids epoch =
  let n = List.length node_ids in
  let idx = epoch mod n in
  List.nth node_ids idx

let get_test_txs n : transaction list =
  [ { source = "not imnplemented"
    ; destination = "not imnplemented"
    ; amount = 10 * n
    ; fee = 10.
    ; counter = 1
    ; gas_limit = 100000
    ; storage_limit = 10000 }
  ; { source = "not imnplemented"
    ; destination = "not imnplemented"
    ; amount = 20 * n
    ; fee = 20.
    ; counter = 1
    ; gas_limit = 200000
    ; storage_limit = 20000 } ]
