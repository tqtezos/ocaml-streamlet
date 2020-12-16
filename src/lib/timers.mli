type callback = Epoch.t -> unit Lwt.t

val init_timer : callback list -> unit Lwt.t
