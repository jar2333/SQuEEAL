open Ast

(* REFACTOR BY MAKING A MODEL MODULE AND A GRAPH MODULE MAYBE? *)

module VertexMap = Map.Make(String);;
module EdgeSet = Set.Make(struct type t = string * string let compare = compare end);; (* (w, a) *)

module AtomMap = Map.Make(String);;
module WorldSet = Set.Make(String);;

type digraph = (EdgeSet.t) VertexMap.t
type atomic_assignment = (WorldSet.t) AtomMap.t

type model = digraph * atomic_assignment

let models = Hashtbl.create 64;;

let print_model id (digraph, assignments) =
  let print_edges edge_set =
    EdgeSet.iter (fun (u, a) -> print_string ("(" ^ u ^ ", " ^ a ^ "), ")) edge_set 
  in
  let print_vertices vertex_map = print_endline("Kripke Model: ");
    VertexMap.iter (fun v edge_set -> (print_string (v ^ ": ["); print_edges edge_set; print_string "]\n")) vertex_map
  in
  let print_worlds world_set = 
    WorldSet.iter (fun w -> print_string (w ^ ", ")) world_set
  in
  let print_atoms atom_map = print_endline("Atomic Assignment: ");
    AtomMap.iter (fun a world_set -> (print_string (a ^ ": {"); print_worlds world_set; print_string "}\n")) atom_map
  in
  print_endline ("Model id: " ^ id);
  print_vertices digraph;
  print_atoms assignments;
in

let create_model model_stmts = 
  let add_edge u_id label edge_set = 
    match edge_set with 
    | Some(e) -> Some(EdgeSet.add (u_id, label) e)
    | None    -> Some(EdgeSet.add (u_id, label) EdgeSet.empty)
  in
  let add_world world_id world_set =
    match world_set with
    | Some(w) -> Some(WorldSet.add world_id w) 
    | None    -> Some(WorldSet.add world_id (WorldSet.empty))
  in
  let empty_model = (VertexMap.empty, AtomMap.empty) 
  in
  let add (digraph, assignments) stmt : model = 
    match stmt with
    | Node(node_id)               -> (VertexMap.add node_id EdgeSet.empty digraph, assignments)
    | Edge(v_id, label, u_id)     -> (VertexMap.update v_id (add_edge u_id label) digraph, assignments)
    | AtomDef (atom_id, world_id) -> (digraph, AtomMap.update atom_id (add_world world_id) assignments)
  in
  List.fold_left add empty_model model_stmts
in



(* change this to use models directly and not model_ids *)
let rec evaluate_query (m: model) (world_id : string) query : bool = 
  match query with
  (* ATOMS *)
  | Atom(atom_id) ->  let (_, assignments) = m in
                      let worlds = AtomMap.find atom_id assignments in
                      WorldSet.mem world_id worlds

  (* PRIMITIVE CONNECTIVES *)
  | Not(q)      -> not (evaluate_query m world_id q)
  | And(q1, q2) -> (evaluate_query m world_id q1) && (evaluate_query m world_id q2)

  (* DERIVED CONNECTIVES (can be native or sugar) *)
  | Or(q1, q2)          -> (evaluate_query m world_id q1) || (evaluate_query m world_id q2)
  | Conditional(q1, q2) -> (not (evaluate_query m world_id q1)) || (evaluate_query m world_id q2)

  (* MODAL OPERATOR *)
  | Know(agent_id, q)  -> let (digraph, _) = m in
                          let edges = VertexMap.find world_id digraph in 
                          EdgeSet.for_all (fun (v, a) -> if a = agent_id then evaluate_query m v q else true) edges

  (* MODAL OPERATOR DUAL (sugar) *)
  | Consistent(agent_id, q) -> evaluate_query m world_id (Not(Know(agent_id, Not(q))))

  (* public announcement, unimplemented *)
  | Announce (q1, q2)     -> true
  | DualAnnounce (q1, q2) -> true
in

let execute_stmt stmt =
  match stmt with
  | KripkeDeclare(id, model_stmts)   -> let m = create_model model_stmts in 
                                        Hashtbl.add models id m; 
                                        print_model id m;

  | Query(model_id, world_id, query) -> let model_opt = Hashtbl.find_opt models model_id in  (* Add "world inside model" check also!!! *)
                                        match model_opt with
                                        | Some(m) -> print_endline (string_of_bool (evaluate_query m world_id query))
                                        | None    -> print_endline ("Error: Model " ^ model_id ^ " not found!")
in


(* INTERPRETER LOOP *)
try
  let lexbuf = Lexing.from_channel stdin in
  while true do
    let result = Parser.main Scanner.token lexbuf in
      print_endline("\n-------EVALUATED STATEMENT-------\n");
      execute_stmt result;
      print_endline("\n---------------------------------\n");
      flush stdout
  done
with Scanner.Eof ->
  exit 0