let start in_ out =
  let rpc = Debug_rpc.create ~in_ ~out () in
  let cancel = ref (fun () -> ()) in
  Lwt.async (fun () ->
      (try%lwt
         Log.info "Uninitialized";
         let%lwt _, _ = State_uninitialized.run rpc in
         Log.info "Initialized";
         Lwt.return_unit
       with
      | Exit ->
        Lwt.return_unit);%lwt
      !cancel ();
      Lwt.return_unit);
  let loop = Debug_rpc.start rpc in
  (cancel := fun () -> Lwt.cancel loop);
  (try%lwt loop with Lwt.Canceled -> Lwt.return_unit);%lwt
  Lwt.return ()
