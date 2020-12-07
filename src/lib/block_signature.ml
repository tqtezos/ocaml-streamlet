type t = {
  validator : Signature.Public_key_hash.t;
  id : Operation_list_list_hash.t;
}

let encoding : t Data_encoding.t =
  let open Data_encoding in
  conv
    (fun {validator; id} ->
      (validator, id))
    (fun (validator, id) ->
      {validator; id})
    (obj2
       (req "validator" Signature.Public_key_hash.encoding)
       (req "id" Operation_list_list_hash.encoding))

let unsigned_encoding =
  let open Data_encoding in
  merge_objs Operation.shell_header_encoding
    (obj1 (req "contents" encoding))
