(* Ocamllex scanner for EQL *)

{ open Parser }

let digit = ['0' - '9']
let letter = ['a'-'z''A'-'Z']
let digits = digit+

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)

(* Parenthesis and Brackets *)
| '{' { LBRACE }
| '}' { RBRACE }
| '[' { LSQBRACE }
| ']' { RSQBRACE }
| '(' { LPAREN }
| ')' { RPAREN }

(* KRIPKE MODEL DEFINITIONS *)
| "kripke" { KRIPKE }
| "->"     { EDGE }
| "-" (letter | digit | '_')+ "->" as ledge { LEDGE(String.sub ledge 1 ((String.length ledge) - 3)) }

(* Misc *)
| ';' { SEMI }
| letter (letter | digit | '_')* as id  { ID(id) }
| eof { EOF }