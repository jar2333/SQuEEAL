(* Ocamllex scanner for EQL *)

{ open Parser }

let digit = ['0' - '9']
let letter = ['a'-'z''A'-'Z']
let digits = digit+

let id = (letter | digit | '_')+

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)

(* Parenthesis and Brackets *)
| '{' { LBRACE }
| '}' { RBRACE }
| '[' { LSQBRACE }
| ']' { RSQBRACE }
| '(' { LPAREN }
| ')' { RPAREN }

(* Delimiters *)
| ':' { COLON }
| ',' { COMMA }
| ';' { SEMI }
| '.' { DOT }

(* KRIPKE MODEL DEFINITIONS *)
| "kripke" { KRIPKE }
| "->"     { EDGE }
| "-" id "->" as ledge { LEDGE(String.sub ledge 1 ((String.length ledge) - 3)) }
| "agents" { AGENTS }
| "worlds" { WORLDS }

(* Misc *)
| id as id  { ID(id) }
| eof { EOF }