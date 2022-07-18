open Ast

let program = Parser.program Scanner.token (Lexing.from_channel stdin);;
print_endline("\nPARSED PROGRAM:\n");;
print_endline (Ast.string_of_program program);;
