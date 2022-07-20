open Ast

let _ =
  try
    let lexbuf = Lexing.from_channel stdin in
    while true do
      let result = Parser.main Scanner.token lexbuf in
        print_endline("\n-------PARSED PROGRAM------\n");
        (* Interpret the AST instead of printing *)
        print_endline (Ast.string_of_program result);
        print_newline(); 
        flush stdout
    done
  with Scanner.Eof ->
    exit 0