open OUnit2
open Command
open Interpreter
open State

let command_parse_test name (expected_cmd:Command.t) (cmd:string) = 
  name >:: (fun _ -> assert_equal expected_cmd (Command.parse cmd))

let command_parse_raises name e command =
  let f = fun() -> Command.parse command in
  name >:: (fun _ -> (assert_raises (e) f))

let command_tests = [
  command_parse_test "myfirsttestohyeah" (Command.Move (1, (1,1))) "move 1 1,1";
  command_parse_test "mysecondtestohyeah" (Command.Move (1, (1,2))) "move 1 1,2";
  command_parse_test "mythirdtest" (Command.Move (0, (1,3))) "move 0 1,3";
  command_parse_test "myfourthtest" (Command.Move (34, (79,182))) "move 34 79,182";
  command_parse_test "my5thtest" (Command.Quit) "quit";
  command_parse_raises "bandtest1" Command.Malformed "move -1 1,1";
  command_parse_raises "bandtest2" Command.Malformed "safgsgsdgsd";
  command_parse_raises "bandtest3" Command.Malformed "move 1 2,";
  command_parse_raises "bandtest4" Command.Malformed "move 1,3";
  command_parse_raises "bandtest5" Command.Malformed "move 2 3,a";
  command_parse_raises "bandtest6" Command.Malformed "move 2 a,b";
  command_parse_raises "bandtest7" Command.Malformed "mov 2 3,4";
  command_parse_raises "bandtest8" Command.Malformed "move 2 3,a";
  command_parse_raises "bandtest9" Command.Malformed "move 2 3,4,5";
  command_parse_raises "bandtest10" Command.Malformed "quitted";
  command_parse_raises "bandtest11" Command.Malformed "move";


]

let valid_move_test name cmd st ex_op = 
  name >:: (fun _ -> 
      assert_equal ex_op (Interpreter.valid_move cmd st)
    )

let first_state = State.empty 1 2
let second_state = Interpreter.interpret_move (Command.Move (1,(0,0))) (State.empty 1 2)
let third_state = State.empty 2 2
                  |> Interpreter.interpret_move (Command.Move (1,(0,0)))
                  |> Interpreter.interpret_move (Command.Move (2,(0,1)))
                  |> Interpreter.interpret_move (Command.Move (3,(0,2)))
let test_toggle = Interpreter.toggle_turn second_state
let count_type = assert_equal (State.count_type third_state State.Empty) 13

let is_valid_move = [ 
  valid_move_test "test1" (Command.Move (1, (0,0))) first_state true;
  valid_move_test "test2" (Command.Move (1, (1,1))) first_state false;
  valid_move_test "test3" (Command.Move (1, (3,2))) first_state false;
  valid_move_test "test4" (Command.Move (1, (0,1))) first_state false;
  valid_move_test "test5" (Command.Move (1, (3,1))) first_state false;
  valid_move_test "test6" (Command.Move (2, (0,0))) first_state false;
  valid_move_test "test7" (Command.Move (0, (0,0))) first_state false;
  valid_move_test "test8" (Command.Move (1, (0,0))) second_state false;
  valid_move_test "test9" (Command.Move (3, (0,3))) third_state false;
  valid_move_test "test9" (Command.Move (1, (1,1))) third_state false;
  valid_move_test "test10" (Command.Move (2, (1,0))) third_state false;
  valid_move_test "test11" (Command.Move (1, (0,2))) third_state false;
  valid_move_test "test12" (Command.Move (4, (2,2))) third_state true;
  valid_move_test "test13" (Command.Quit) third_state false;
]

let get_all_state name st ex_len = 
  name >:: (fun _ -> 
      assert_equal ex_len (Array.length (State.get_all_elements st))
    )

let get_all_state_test = [
  get_all_state "stest1" (State.empty 1 1) 1;
  get_all_state "stest2" second_state 1;
  get_all_state "stest3" third_state 16;
]

let check_dimension st dim =
  "check dimension "^string_of_int dim >::
  (fun _ -> assert_equal dim (State.board_dim st))

let check_dimensions =
  [
    check_dimension (State.empty 1 1) 1;
    check_dimension (State.empty 5 1) 5;
    check_dimension (State.empty 7 1) 7;
  ]

let grey_possible_check s x y bool name=
  name >::
  (fun _ -> assert_equal bool (if (Interpreter.is_grey_possible s (x,y))= 
                                  None then false else true))

let create_grey_possible_check s x y v name=
  name >::
  (fun _ -> assert_equal v (List.hd (Interpreter.is_create_grey_possible s (x,y))))

let odd_even_check s b bool name = 
  name >::
  (fun _ -> assert_equal bool (if (Interpreter.odd_or_even_grey s b)= 
                                  None then false else true))

let count_check ls v i name= 
  name >::
  (fun _ -> assert_equal i (Interpreter.count ls v))


let new_state (t: State.t) : State.t=
  match t with
  |(TWOPLAYER _,b) -> (ONEPLAYER TURN_1, b)
  |_ -> t

let empty_state : State.t= State.empty 2 1
let fifth_state = third_state
let state3 = new_state fifth_state
let fourth_state = fifth_state
                   |> Interpreter.interpret_move (Command.Move (3,(1,1)))
let state4 = new_state fourth_state


let l = [0;1;2;2;3;2]

let ai_tests = [

  grey_possible_check state4 0 3 true "greyp1";
  grey_possible_check state4 1 1 false "greyp2"; 

  create_grey_possible_check state4 1 3 4 "cgreyp";

  count_check l 2 3 "count";

  odd_even_check state4 true true "oddeven1";
  odd_even_check state4 false true "oddeven2";
  odd_even_check empty_state true false "oddeven3";

]

let suite = "state" >:::
            List.flatten [
              check_dimensions;
              command_tests;
              is_valid_move;
              get_all_state_test;
              ai_tests;
            ]

let _ = run_test_tt_main suite