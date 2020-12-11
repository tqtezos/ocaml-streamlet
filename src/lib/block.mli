open Transaction

type block =
{ parent_hash : bytes
; epoch: Epoch.t
; txs: transaction list
; notarizations : Notarization.t list
}

type t = block

type hashed_block =
{ data: block
; hash: bytes
}

val is_notarized : Baker.Consensus_state.t -> t -> bool

val genesis : unit -> hashed_block

(* Hash a virtual block (no chain hash) *)
val hash_virtual : block -> bytes

(* Hash a regular block *)
val hash_full : hashed_block -> bytes

val compare : t -> t -> int

val hash_bytes_list : bytes list -> bytes

val equal_chain: t -> t -> bool

val equal_chain_opt : t option -> t option -> bool

val equal : t -> t -> bool

val equal_opt : t option -> t option -> bool

val sign_block : Tezos_crypto.Signature.secret_key -> block -> Tezos_crypto.Signature.t

val sign_hashed_block : Tezos_crypto.Signature.secret_key -> hashed_block -> Tezos_crypto.Signature.t

val check_signature :
     Signature.Public_key.t
  -> hashed_block
  -> Signature.t
  -> bool

val pp :
     Format.formatter
  -> t
  -> unit

val pp_opt :
     Format.formatter
  -> t option
  -> unit


(* Printing *)

(* val pp : *)

(* Hashing *)


(* val check_signature : *)


(* val equal_notarizations : *)

(* Genesis *)

(* val create : *)

(* Notarization *)

(* val find_signatory_opt : *)

(* val has_signatory *)
