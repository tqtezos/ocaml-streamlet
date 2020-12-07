type t = {
  validator : Signature.Public_key_hash.t;
  value : Operation_hash.t list;
  chain_hash : bytes;
}

let encoding : t Data_encoding.t =
  let open Data_encoding in
  conv
    (fun {validator; value; chain_hash} ->
      (validator, value, chain_hash))
    (fun (validator, value, chain_hash) ->
      {validator; value; chain_hash})
    (obj3
       (req "validator" Signature.Public_key_hash.encoding)
       (req "value" (list Operation_hash.encoding))
       (req "chain_hash" bytes))

let unsigned_encoding =
  let open Data_encoding in
  merge_objs Operation.shell_header_encoding
    (obj1 (req "contents" encoding))
