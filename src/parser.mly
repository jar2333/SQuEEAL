/* Ocamlyacc parser for SIFT */
%{ 
  open Ast 
%}


%token <string> ID

/* Parenthesis and Brackets */
%token LPAREN RPAREN LBRACE RBRACE LSQBRACE RSQBRACE
/* Delimiters */
%token COMMA SEMI COLON DOT
%token EOF

/* Kripke model definition tokens */
%token KRIPKE EDGE
%token <string> LEDGE

%left SEMI EDGE

%start program
%type <Ast.program> program

%%

/* add function declarations*/
program:
  stmt_list EOF { $1 }

stmt_list:
  /* nothing */ { [] }
  | stmt stmt_list  { $1::$2 }

stmt:
  kripke SEMI {$1}

kripke:
  | KRIPKE ID LBRACE graph_stmt_list RBRACE { KripkeDeclare($2, $4) }

graph_stmt_list:
  /* nothing */ { [] }
  | graph_stmt graph_stmt_list  { $1::$2 }

graph_stmt:
  ID SEMI { Node($1) }
  | ID LEDGE ID SEMI { Edge($1, $2, $3) }

