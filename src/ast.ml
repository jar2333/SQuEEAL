(* Abstract Syntax Tree and functions for printing it *)

type op = And | Or 

type uop = Not

type typ = Bool

type expr =
  Id of string

type query_expr =
  Atom of string
  | And of query_expr * query_expr
  | Not of query_expr
  | Or of query_expr * query_expr
  | Conditional of query_expr * query_expr
  | Know of string * query_expr
  | Consistent of string * query_expr
  | Announce of query_expr * query_expr
  | DualAnnounce of query_expr * query_expr



type graph_stmt = 
  Node of string
| Edge of string * string * string
| AtomDef of string * string

type stmt =
    Expr of expr
  | KripkeDeclare of string * graph_stmt list
  | Query of string * string * query_expr

type main = stmt

(* Pretty-printing functions *)
let string_of_expr expr =
  match expr with
  | Id(s) -> s

let rec string_of_query_expr expr =
  match expr with
  | Atom(id) -> id
  | And(q1, q2) -> (string_of_query_expr q1) ^ " & " ^ (string_of_query_expr q2)
  | Or(q1, q2) -> (string_of_query_expr q1) ^ " | " ^ (string_of_query_expr q2)
  | Conditional(q1, q2) -> (string_of_query_expr q1) ^ " -> " ^ (string_of_query_expr q2)
  | Not(q) -> "~( " ^ (string_of_query_expr q) ^ ")"
  | Know(a, q) -> "[" ^ a ^ "](" ^ (string_of_query_expr q) ^ ")"
  | Consistent(a, q) -> "<" ^ a ^ ">(" ^ (string_of_query_expr q) ^ ")"
  | Announce(qa, q) -> "[" ^ (string_of_query_expr qa) ^ "!](" ^ (string_of_query_expr q) ^ ")"
  | DualAnnounce(qa, q) -> "<" ^ (string_of_query_expr qa) ^ "!>(" ^ (string_of_query_expr q) ^ ")"

let string_of_graph_stmt graph_stmt =
  (match graph_stmt with
  | Node(node_id) -> node_id
  | Edge(v_id, label, u_id) -> v_id ^ "-" ^ label ^ "->" ^ u_id
  | AtomDef(atom_id, node_id) -> atom_id ^ ":" ^ node_id
  ) ^ ";"

let string_of_stmt stmt =
  (match stmt with
  | Expr(e) -> string_of_expr e
  | KripkeDeclare(id, g) -> "kripke " ^ id ^ " {\n" ^ (String.concat "\t\n" (List.map string_of_graph_stmt g)) ^ "\n}"
  | Query(model_id, world_id, q) -> model_id ^ "." ^ world_id ^ " := " ^ (string_of_query_expr q) 
  ) ^ ";"

let string_of_program p =
  String.concat "\n" (List.map string_of_stmt p)
