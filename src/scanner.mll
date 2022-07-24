(* Ocamllex scanner for EQL *)

{ 
  open Parser 
  exception Eof
}

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
| '<' { LANGLEBRACE }
| '>' { RANGLEBRACE }

(* Delimiters *)
| ':' { COLON }
| ',' { COMMA }
| '.' { DOT }

(* NEWLINE/SEMICOLON *)
| ";\n" { SEMI }

(* KRIPKE MODEL DEFINITIONS *)
| "kripke" { KRIPKE }
| "->"     { EDGE }
(* | "-" id "->" as ledge { LEDGE(String.sub ledge 1 ((String.length ledge) - 3)) } *)
| "agents" { AGENTS }
| "worlds" { WORLDS }
| "atoms"  { ATOMS } 

(* QUERY *)
| ":="  { IMPLIES }
| "&"   { AND }
| "|"   { OR }
| "~"   { NOT }
| "!"   { ANNOUNCE }

(* Misc *)
| id as id  { ID(id) }
| eof { raise Eof }