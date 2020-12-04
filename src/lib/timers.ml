open Lwt

type callback = int -> unit Lwt.t

let epoch_seconds = 2.0

let run_timer ~seconds gs =
  let rec go epoch =
    Lwt_unix.sleep seconds
    >>= fun () ->
    let foldf ((): unit) (g:callback) : unit Lwt.t =
      (g epoch) in
    Lwt_list.fold_left_s foldf () gs
    >>= fun () ->
    go (epoch + 1)
  in
  go 1

let init_timer callbacks = run_timer ~seconds:epoch_seconds callbacks
