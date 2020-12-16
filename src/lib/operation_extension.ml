open Lwt

type operation_data = {contents: Operation_kind.t; signature: Signature.t option}

let verify_signature public_key bytes = function
  | Some signature ->
      if
        Signature.check ~watermark:Signature.Generic_operation public_key
          signature bytes
      then return ()
      else fail_with "Invalid_signature"
  | None -> fail_with "Signature_undefined"

type operation = {shell: Operation.shell_header; protocol_data: operation_data}

let filter_by_kind (k : Operation_kind.t) os : operation list =
  List.filter
    (fun o ->
      let k2 = o.protocol_data.contents in
      compare k k2 == 0)
    os
