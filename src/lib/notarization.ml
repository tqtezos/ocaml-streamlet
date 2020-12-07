open Prelude

type t = {
  signatory : Signature.Public_key.t;
  signature : Signature.t;
}

(* Printing *)

let pp ppf t =
  Format.fprintf ppf "Notarization {signatory=%a; signature=%a}"
    Signature.Public_key.pp t.signatory Signature.pp t.signature

(* Serialization *)

let encode_signatory {signatory; _} =
  Data_encoding.Binary.to_bytes_exn Signature.Public_key.encoding signatory

let encode_signature {signature; _} =
  Data_encoding.Binary.to_bytes_exn Signature.encoding signature

(* Hashing *)

let hash_bytes bytes_list =
  let bytes = Blake2B.hash_bytes ~key:(Bytes.of_string "notarization") bytes_list in
  Blake2B.to_bytes bytes

let hash t =
  let signatory_bytes = encode_signatory t in
  let signature_bytes = encode_signature t in
  hash_bytes [ signatory_bytes; signature_bytes ]

let hash_list t =
  List.fold_left (fun prefix t ->
      let h = hash t in
      Blake2B.to_bytes (Blake2B.hash_bytes [ prefix; h ])
    ) (Bytes.create 0) t


(* Comparison *)

let compare a b =
  Signature.Public_key.compare a.signatory b.signatory
  >>-? fun () ->
  Signature.compare a.signature b.signature

let equal a b =
  Compare.Int.equal (compare a b) 0
