type t = {
  validator : Signature.Public_key_hash.t;
  value : Operation_hash.t list;
  chain_hash : bytes;
}

val encoding : t Data_encoding.t

val unsigned_encoding : (Operation.shell_header * t) Data_encoding.encoding
