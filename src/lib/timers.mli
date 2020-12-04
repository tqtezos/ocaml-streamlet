type callback = int -> unit Lwt.t

val init_timer : callback list -> unit Lwt.t
