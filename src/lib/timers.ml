open Lwt

type callback = Epoch.t -> unit Lwt.t

let epoch_seconds = 2.0

let run_timer ~seconds gs =
  let rec go epoch =
    Lwt_unix.sleep seconds
    >>= fun () ->
    let foldf (() : unit) (g : callback) : unit Lwt.t = g epoch in
    Lwt_list.fold_left_s foldf () gs >>= fun () -> go (Epoch.inc epoch) in
  go (Epoch.of_int 1)

let init_timer callbacks = run_timer ~seconds:epoch_seconds callbacks
