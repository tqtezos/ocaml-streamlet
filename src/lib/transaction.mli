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
