/* Ocamlyacc parser for EQL */
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
%token KRIPKE WORLDS AGENTS EDGE
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
  | graph_stmt graph_stmt_list  { $1 @ $2 }

graph_stmt:
  | WORLDS COLON node_stmt_list {
    let make_node w = Node(w) in
    List.map make_node $3
    }
  | AGENTS id_list COLON edge_stmt_list { 
    let make_edge a t = Edge(fst t, a, snd t) in
    List.fold_left (fun lst a -> (@) lst (List.map (make_edge a) $4 )) [] $2
    }

node_stmt_list:
  /* nothing */ { [] }
  | node_stmt node_stmt_list  { $1 @ $2 }

node_stmt:
  | id_list SEMI { $1 }

edge_stmt_list:
  /* nothing */ { [] }
  | edge_stmt edge_stmt_list  { $1::$2 }

edge_stmt:
  | ID EDGE ID SEMI { ($1, $3) }

id_list:
  ID {[$1]}
  | ID COMMA id_list {$1::$3}