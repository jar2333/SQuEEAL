/* Ocamlyacc parser for EQL */
%{ 
  open Ast 

  let cartesian l l' = 
    List.map (fun e -> List.map (fun e' -> (e,e')) l') l 
    
    |> List.concat 
%}

/* ID */
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

%left COMMA

%left SEMI EDGE IMPLIES

%left AND OR
%right NOT //more precedence -> lower

%nonassoc RSQBRACE RANGLEBRACE
%nonassoc LSQBRACE LANGLEBRACE

%nonassoc RPAREN
%nonassoc LPAREN

// %left COLON
// %left COMMA

%start main
%type <Ast.main> main

%%

/* add function declarations*/
main:
  stmt SEMI { $1 }

// stmt_list:
//   /* nothing */ { [] }
//   | stmt stmt_list  { $1::$2 }

stmt:
  kripke {$1}
  | ID DOT ID IMPLIES formula {Query($1, $3, $5)}

formula:
    LPAREN formula RPAREN {$2}
    | ID {Atom($1)}
    | NOT formula {Not($2)}
    | formula AND formula {And($1, $3)}
    | formula OR formula {Or($1, $3)}
    | formula EDGE formula {Conditional($1, $3)}
    | LSQBRACE ID RSQBRACE formula {Know($2, $4)}
    | LANGLEBRACE ID RANGLEBRACE formula {Consistent($2, $4)}
    | LSQBRACE formula ANNOUNCE RSQBRACE formula {Announce($2, $5)}
    | LANGLEBRACE formula ANNOUNCE RANGLEBRACE formula {DualAnnounce($2, $5)}

kripke:
  | KRIPKE ID LBRACE graph_stmt_list RBRACE { KripkeDeclare($2, $4) }

graph_stmt_list:
  /* nothing */ { [] }
  | graph_stmt graph_stmt_list  { $1 @ $2 }

//The AST creation should be pushed to the leaves for a line-by-line interpreter
graph_stmt:
  | WORLDS COLON world_stmt_list {
    let make_node w = Node(w) in
    List.map make_node $3
    }
  | AGENTS COLON agent_stmt_list { 
    let make_edge t = Edge(fst (snd t), fst t, snd (snd t)) in
    List.map make_edge $3
    }
  | AGENTS id_list COLON prefix_agent_stmt_list { 
    let make_edge a t = Edge(fst t, a, snd t) in
    List.fold_left (fun lst a -> (@) lst (List.map (make_edge a) $4 )) [] $2
    }
  | ATOMS COLON atom_stmt_list { 
    let make_atom t = AtomDef(fst t, snd t) in
    List.map make_atom $3
  }
  | ATOMS id_list COLON prefix_atom_stmt_list { 
    let make_atom a w = AtomDef(a, w) in
    List.fold_left (fun lst a -> (@) lst (List.map (make_atom a) $4 )) [] $2
  }

//---WORLD STATEMENTS----
//worlds: 1,2,3; 3; 4, 5;
world_stmt_list:
  /* nothing */ { [] }
  | world_stmt world_stmt_list  { $1 @ $2 }

world_stmt:
  | id_list SEMI { $1 }

//---AGENT STATEMENTS----
//agents: a: 1->2, 2->3; b, c: 1->4
agent_stmt_list:
  /* nothing */ { [] }
  | agent_stmt agent_stmt_list  { $1 @ $2 }

agent_stmt:
  id_list COLON edge_list SEMI { cartesian $1 $3 } //[(a, (w, v)), ...]

//---PREFIX AGENT STATEMENTS----
//agents a, b, c: 1->3, 1->2, 2->1; 1->2, 1->1; 
prefix_agent_stmt_list:
  /* nothing */ { [] }
  | prefix_agent_stmt prefix_agent_stmt_list  { $1 @ $2 }

prefix_agent_stmt:
  | edge_list SEMI { $1 }

//---ATOM STATEMENTS---- 
//atoms: p, q: 1, 2; t: 3, 4;
atom_stmt_list:
  /* nothing */ { [] }
  | atom_stmt atom_stmt_list  { $1 @ $2 }

atom_stmt:
  id_list COLON id_list SEMI { cartesian $1 $3 }

//---PREFIX ATOM STATEMENTS----
//atoms p, q: 1, 3; 2; 
prefix_atom_stmt_list:
  /* nothing */ { [] }
  | prefix_atom_stmt prefix_atom_stmt_list  { $1 @ $2 }

prefix_atom_stmt:
  | id_list SEMI { $1 }

//Comma-separated list of edge creation expressions.
edge_list:
  edge_expr { $1 } //[(u, v), ...]
  | edge_expr COMMA edge_list  { $1 @ $3 }

//This rule adds 10 seconds to compile time?????
edge_expr:
  ID EDGE ID { [($1, $3)] }
  | ID EDGE edge_expr { ($1, (fst (List.hd $3))) :: $3} 

//Comma-separated list of ids.
id_list:
  ID { [$1] }
  | ID COMMA id_list { $1::$3 } 