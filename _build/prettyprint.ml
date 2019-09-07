open State

let encode = function
  | Empty -> " "
  | Gray -> "X"
  | Value y -> string_of_int y

let chararr s = State.get_all_elements s |> Array.map (fun x -> encode x)

let rec print_state dim s = 
  general_print_state dim (chararr s)

and general_print_state dim a = 
  assert (dim * dim * dim * dim = Array.length a);
  let output = ref "" in 
  let len = dim * dim in 
  output := !output ^ "\n ";
  for j = 0 to len - 1 do output:= !output ^ "    "^string_of_int j^"  " done;
  output := !output ^ "\n  ";
  for j = 0 to len - 1 do output:= !output ^ "_______" done;
  output := !output ^ "_\n  ";
  for i = 0 to len - 1 do 
    for j = 0 to len - 1 do output:= !output ^ "|      " done;
    output := !output ^ "|\n";
    output := !output ^string_of_int i ^" ";
    for j = 0 to len - 1 do output:= !output ^ "|  "^a.(i * len + j)^"   " done;
    output := !output ^ "|\n" ^"  ";
    for j = 0 to len - 1 do output:= !output ^ "|______" done;
    output := !output ^ "|\n"^"  ";
  done;
  ignore(Sys.command "clear");
  print_endline !output

let print_general dim s =   
  match State.get_state s with
  | ONEPLAYER TURN_1 -> 
    print_string("Your turn. Enter a move in form 'move value row,col'.\n");
    print_state dim s
  | TWOPLAYER TURN_1 -> 
    print_string("Player 1's turn. Enter a move in form 'move value row,col'.\n");
    print_state dim s
  | ONEPLAYER TURN_2 -> 
    print_string("AI's turn.\n");
    print_state dim s
  | TWOPLAYER TURN_2 -> 
    print_string("Player 2's turn. Enter a move in form 'move value row,col'.\n");
    print_state dim s
  | ONEPLAYER WIN_1 -> 
    print_state dim s;
    print_string("Congratulations you beat the algorithm!\n");
    Pervasives.exit 0
  | TWOPLAYER WIN_1 -> 
    print_state dim s;
    print_string("Congratulations Player 1! You win! HAHA Player 2, you SUCK!\n");
    Pervasives.exit 0
  | ONEPLAYER WIN_2 -> 
    print_state dim s;
    print_string("The algorithm beat you! MWUAHAHHAHAHAHA\n");
    Pervasives.exit 0
  | TWOPLAYER WIN_2 -> 
    print_state dim s;
    print_string("Congratulations Player 2! You win! HAHA Player 1, you SUCK!\n");
    Pervasives.exit 0
  | CLIENT TURN_1 ->
    print_string("Other player's turn.\n");
    print_state dim s
  | CLIENT TURN_2 ->
    print_string("Your turn. Enter a move in form 'move value row,col'.\n");
    print_state dim s
  | HOST TURN_1 ->
    print_string("Your turn. Enter a move in form 'move value row,col'.\n");
    print_state dim s
  | HOST TURN_2 ->
    print_string("Other player's turn.\n");
    print_state dim s
  | HOST WIN_1 -> 
    print_state dim s;
    print_string("Congratulations Player 1!\n");
    Pervasives.exit 0
  | HOST WIN_2 -> 
    print_state dim s;
    print_string("You lost Player 1!\n");
    Pervasives.exit 0
  | CLIENT WIN_1 -> 
    print_state dim s;
    print_string("You lost Player 2!\n");
    Pervasives.exit 0
  | CLIENT WIN_2 -> 
    print_state dim s;
    print_string("You won Player 2!\n");
    Pervasives.exit 0