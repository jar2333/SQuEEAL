open OUnit2

let make_test (name : string) (program : string) (expected_output : string) = 
  name >:: fun _ ->
  assert_equal (Ast.string_of_program program) expected_output
    (* (Main.interp_expr Checker.Context.empty Eval.initial_env input
    |> function
    | Ok x | Error (ParseError x) | Error (TypeError x) -> x) *)
    (* ~printer:(fun x -> x) *)

let tests = 
  [
    make_test ("Parsed Program Test") 
    ("kripke g {
      worlds: 1,2,3,4;
      agents a: 1->2;
      agents b,c: 1->3; 3->4;
      atoms: 
      p,q : 1,2;
      l : 4;
      };
      
      g.1 := p;")
      ("kripke g {
        1;
        2;
        3;
        4;
        1-a->2;
        1-b->3;
        3-b->4;
        1-c->3;
        3-c->4;
        p:1;
        p:2;
        q:1;
        q:2;
        l:4;
        };
        g.1 := p;")
  ]

let suite = "suite" >::: tests
let () = run_test_tt_main_suite