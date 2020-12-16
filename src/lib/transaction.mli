type transaction =
  { source: string
  ; destination: string
  ; amount: int
  ; fee: float
  ; counter: int
  ; gas_limit: int
  ; storage_limit: int }

type t = transaction

val to_string : t -> string
val hash_txs : t list -> bytes list
val compare_list : t list -> t list -> int
val equal_list : t list -> t list -> bool
val get_test_txs : int -> transaction list

val filter_from_operations :
  Operation_extension.operation list -> transaction list
