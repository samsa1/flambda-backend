(* TEST
 ocamlopt_flags += " -O3 ";
 reason = "CR ocaml 5 domains: re-enable this test";
 skip;
*)

open Domain

let () =
  let l = lazy (print_string "Lazy Forced\n") in
  let d = spawn (fun () -> Lazy.force l) in
  join d
