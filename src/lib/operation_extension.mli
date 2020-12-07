type operation_data = {
  contents : Operation_kind.t;
  signature : Signature.t option;
}

type operation = {
  shell : Operation.shell_header;
  protocol_data : operation_data;
}

val verify_signature :
     Signature.Public_key.t
  -> Bytes.t
  -> Signature.t option
  -> unit Lwt.t
