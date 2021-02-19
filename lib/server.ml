let start () =
  Log.reset ();
  Lwt_main.run (Adapter.start Lwt_io.stdin Lwt_io.stdout)
