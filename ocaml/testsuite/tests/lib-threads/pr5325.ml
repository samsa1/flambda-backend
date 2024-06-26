(* TEST
 include systhreads;
 hassysthreads;
 {
   bytecode;
 }{
   native;
 }
*)

open Printf

(* Regression test for PR#5325: simultaneous read and write on socket
   in Windows. *)

(* Scenario:
     - thread [server] implements a simple 'echo' server on a socket
     - thread [reader] reads from a socket connected to the echo server
       and copies to standard output
     - main program executes [writer], which writes to the same socket
       (the one connected to the echo server)
*)

let server sock =
  let (s, _) = Unix.accept sock in
  let buf = Bytes.make 1024 '>' in
  let n = Unix.read s buf 2 (Bytes.length buf - 2) in
  ignore (Unix.write s buf 0 (n + 2));
  Unix.close s

let reader s =
  let buf = Bytes.make 1024 ' ' in
  let n = Unix.read s buf 0 (Bytes.length buf) in
  print_bytes (Bytes.sub buf 0 n); flush stdout

let writer s msg =
  ignore (Unix.write_substring s msg 0 (String.length msg));
  Unix.shutdown s Unix.SHUTDOWN_SEND

let _ =
  let addr = Unix.ADDR_INET(Unix.inet_addr_loopback, 0) in
  let serv =
    Unix.socket (Unix.domain_of_sockaddr addr) Unix.SOCK_STREAM 0 in
  Unix.setsockopt serv Unix.SO_REUSEADDR true;
  Unix.bind serv addr;
  let addr = Unix.getsockname serv in
  Unix.listen serv 5;
  let tserv = Thread.create server serv in
  Thread.delay 0.05;
  let client =
    Unix.socket (Unix.domain_of_sockaddr addr) Unix.SOCK_STREAM 0 in
  Unix.connect client addr;
  let rd = Thread.create reader client in
  Thread.delay 0.05;
  writer client "Client data\n";
  Thread.join rd;
  Thread.join tserv
