(lang dune 2.0)
(name gillian-debugger)
(documentation "https://matthew-ho.github.io/gillian-debugger/")
(source (github matthew-ho/gillian-debugger))
(license MIT)
(authors "Matthew Ho")
(maintainers "Matthew Ho")

(generate_opam_files true)

(package
 (name gillian-debugger)
 (synopsis "A debugger for Gillian built for the Debug Adapter Protocol (DAP)")
 (description "\
A debugger for Gillian built for the Debug Adapter Protocol (DAP)
")
 (depends
  (ocaml (>= 4.08.0))
  (dune (>= 2.0))
  (alcotest :with-test)
  (odoc :with-doc)))
