open Data_encoding

let kind_case tag name args of_fields to_fields =
  case
    tag
    ~title:(String.capitalize_ascii name)
    (merge_objs (obj1 (req "kind" (constant name))) args)
    (fun x -> match of_fields x with Some x -> Some ((), x) | None -> None)
    (fun ((), x) -> to_fields x)

let decode_exn encoding encoded : 'a Lwt.t =
  match Binary.of_bytes encoding encoded with
  | Ok value ->
      Lwt.return value
  | Error _e ->
      assert false


let optional_signature_encoding =
  let open Data_encoding in
  conv
    (function Some s -> s | None -> Signature.zero)
    (fun s -> if Signature.equal s Signature.zero then None else Some s)
    Signature.encoding
