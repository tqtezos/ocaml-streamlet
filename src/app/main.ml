open Lwt
open Ocaml_streamlet

let main () : unit Lwt.t =
  Lwt_io.printf "Starting...\n%!"
  >>= fun () ->
  Lwt_io.(flush stdout)
  >>= fun () ->
  Node_runner.run 7
  >>= fun () ->
  Lwt_io.printf "Done.\n%!"

let () = Lwt_main.run (main ())
