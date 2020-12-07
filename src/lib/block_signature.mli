type t = {
  validator : Signature.Public_key_hash.t;
  id : Operation_list_list_hash.t;
}

val encoding : t Data_encoding.t

val unsigned_encoding : (Operation.shell_header * t) Data_encoding.encoding
