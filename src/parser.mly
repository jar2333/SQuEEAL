/* Ocamlyacc parser for EQL */
%{ 
  open Ast 

  let cartesian l l' = 
    List.map (fun e -> List.map (fun e' -> (e,e')) l') l 
    
    |> List.concat 
%}


%token <string> ID

/* Parenthesis and Brackets */
%token LPAREN RPAREN LBRACE RBRACE LSQBRACE RSQBRACE LANGLEBRACE RANGLEBRACE
/* Delimiters */
%token COMMA SEMI COLON DOT
%token EOF

/* Kripke model definition tokens */
%token KRIPKE WORLDS AGENTS ATOMS EDGE
%token <string> LEDGE

/* Querying tokens */
%token IMPLIES

%token NOT AND OR ANNOUNCE

%left SEMI EDGE IMPLIES

%left AND OR
%right NOT //more precedence -> lower

%nonassoc RSQBRACE RANGLEBRACE
%nonassoc LSQBRACE LANGLEBRACE

%nonassoc RPAREN
%nonassoc LPAREN

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
  | ID DOT ID IMPLIES query SEMI  {Query($1, $3, $5)}

query:
    LPAREN query RPAREN {$2}
    | ID {Atom($1)}
    | NOT query {Not($2)}
    | query AND query {And($1, $3)}
    | query OR query {Or($1, $3)}
    | query EDGE query {Conditional($1, $3)}
    | LSQBRACE ID RSQBRACE query {Know($2, $4)}
    | LANGLEBRACE ID RANGLEBRACE query {Consistent($2, $4)}
    | LSQBRACE query ANNOUNCE RSQBRACE query {Announce($2, $5)}
    | LANGLEBRACE query ANNOUNCE RANGLEBRACE query {DualAnnounce($2, $5)}

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
  | ATOMS COLON atom_stmt_list { 
    let make_atom t = AtomDef(fst t, snd t) in
    List.map make_atom $3
  }

node_stmt_list:
  /* nothing */ { [] }
  | node_stmt node_stmt_list  { $1 @ $2 }

node_stmt:
  | id_list SEMI { $1 }

atom_stmt_list:
  /* nothing */ { [] }
  | atom_stmt atom_stmt_list  { $1 @ $2 }

atom_stmt:
  id_list COLON id_list SEMI { cartesian $1 $3 }

edge_stmt_list:
  /* nothing */ { [] }
  | edge_stmt edge_stmt_list  { $1::$2 }

edge_stmt:
  | ID EDGE ID SEMI { ($1, $3) }

id_list:
  ID {[$1]}
  | ID COMMA id_list {$1::$3}