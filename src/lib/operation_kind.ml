module Kind = struct
  type proposal_kind = Proposal_kind
  type block_signature_kind = Block_signature_kind
end

type _ contents =
  | Proposal : Proposal.t -> Kind.proposal_kind contents
  | Block_signature : Block_signature.t -> Kind.block_signature_kind contents

and t = T : 'kind contents -> t  (** Generic base type *)

let compare (T op1) (T op2) =
  match (op1, op2) with
  | (Proposal _, Proposal _) ->
    0
  | (Block_signature _, Proposal _) ->
    1
  | (Proposal _, _) ->
    -1
  | (Block_signature _, Block_signature _) ->
      0

(* Case encoding *)

let proposal_encoding_object =
  let open Data_encoding in
  obj3
    (req "validator" Signature.Public_key_hash.encoding)
    (req "value" (list Operation_hash.encoding))
    (req "chain_hash" bytes)

let proposal_case_encoding =
  Encoding.kind_case
    (Tag 0)
    "proposal"
    proposal_encoding_object
    (function
      | T (Proposal {validator; value; chain_hash}) ->
          Some (validator, value, chain_hash)
      | _ ->
          None)
    (fun (validator, value, chain_hash) ->
      T (Proposal {validator; value; chain_hash}))

let block_signature_encoding_object =
  let open Data_encoding in
  obj2
    (req "validator" Signature.Public_key_hash.encoding)
    (req "id" Operation_list_list_hash.encoding)

let block_signature_case_encoding =
  Encoding.kind_case
    (Tag 2)
    "block_signature"
    block_signature_encoding_object
    (function
      | T (Block_signature {validator; id})
        ->
          Some (validator, id)
      | _ ->
          None)
    (fun (validator, id) ->
      T (Block_signature {validator; id}))

(* Encoding *)

let encoding : t Data_encoding.t =
  let open Data_encoding in
  union [proposal_case_encoding; block_signature_case_encoding]

let unsigned_encoding =
  let open Data_encoding in
  merge_objs Operation.shell_header_encoding (obj1 (req "contents" encoding))

let serialize shell (contents : t) =
  let open Data_encoding in
  Binary.to_bytes_exn unsigned_encoding (shell, contents)
