type node =
  { node_id : string;
    port: int;
    node_pk_hash: Signature.Public_key_hash.t;
    node_secret_key: Signature.secret_key
  }

type t = node
