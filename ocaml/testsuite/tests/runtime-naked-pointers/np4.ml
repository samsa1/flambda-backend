(* TEST
 modules = "cstubs.c np.ml";
 runtime4;
 naked_pointers;
 {
   bytecode;
 }{
   native;
 }
*)

open Np

(* Null pointers and bad pointers outside the heap are OK
   in naked pointers mode only *)

let x = do_gc [ make_raw_pointer 0n; make_raw_pointer 42n ]
let y = do_gc (make_raw_pointer 42n)
