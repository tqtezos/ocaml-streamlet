module Kind : sig
  type proposal_kind = Proposal_kind
  type block_signature_kind = Block_signature_kind
end

type _ contents =
  | Proposal : Proposal.t -> Kind.proposal_kind contents
  | Block_signature : Block_signature.t -> Kind.block_signature_kind contents

type t = T : 'kind contents -> t  (** Generic base type *)


val compare : t -> t -> int

val serialize :
     Operation.shell_header
  -> t
  -> Bytes.t
