(* Abstract Syntax Tree and functions for printing it *)

type op = And | Or 

type uop = Not

type typ = Bool

type expr =
  Id of string

type graph_stmt = 
  Node of string
| Edge of string * string * string

type stmt =
    Expr of expr
  | KripkeDeclare of string * graph_stmt list

type program = stmt list

(* Pretty-printing functions *)
let string_of_expr expr =
  match expr with
  | Id(s) -> s

let string_of_graph_stmt graph_stmt =
  (match graph_stmt with
  | Node(node_id) -> node_id
  | Edge(v_id, label, u_id) -> v_id ^ "-" ^ label ^ "->" ^ u_id
  ) ^ ";"

let string_of_stmt stmt =
  (match stmt with
  | Expr(e) -> string_of_expr e
  | KripkeDeclare(id_s, g) -> "kripke " ^ id_s ^ " {\n" ^ (String.concat "\t\n" (List.map string_of_graph_stmt g)) ^ "\n}"
  ) ^ ";"

let string_of_program p =
  String.concat "\n" (List.map string_of_stmt p)
