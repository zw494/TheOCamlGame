
open State
open Command


let (--) (i : int) (j : int) : int list =
  let rec from i j l =
    if i>j then l
    else from i (j-1) (j::l)
  in from i j []

let valid_grid v (x,y) state =
  not(Array.mem v (State.get_grid_elements state x y ))

let valid_row v (x,y) state = 
  not(Array.mem v (State.get_row_elements state x))

let valid_col v (x, y) state = 
  not(Array.mem v (State.get_col_elements state y))

let is_valid_tile (v, l) state = 
  match State.get_square state l with 
  | Value _ | Gray -> false
  | Empty -> let v = Value(v) in
    (valid_grid v l state) && 
    (valid_row v l state) && (valid_col v l state)

let valid_move cmd state = 
  match cmd with 
  | Command.Quit -> false
  | Command.Move(v, (x, y)) -> 
    let n = State.board_len state in
    (* Checks if (x, y) is on the board and
        v is a possible square value. *)
    if x < n && y < n && v > 0 && v < n + 1 then
      is_valid_tile (v, (x, y)) state
    else false

let valid_possible_moves loc state = 
  let len = State.board_len state in
  let vals = 1--(len) in
  List.fold_left (fun acc v -> 
      if is_valid_tile (v, loc) state then v::acc else acc) [] vals 

let is_grey_square loc state = 
  let len = State.board_len state in
  let vals = 1--(len) in
  let b = List.for_all (fun v -> is_valid_tile (v, loc) state |> not) vals in 
  assert (b = (List.length (valid_possible_moves loc state) = 0)) ; b

let update_gray state = 
  (** check grid, colum and array*)
  let len = State.board_len state in
  let board = snd state in
  for i = 0 to len -1  do
    for j = 0 to len -1 do
      match board.(i).(j) with
      | Empty -> if (is_grey_square (i,j) state) then 
          State.set_square state State.Gray (i,j) else ()
      | _ -> ()
    done
  done

let transition_winning state =
  let status = State.get_status state in
  let no_empty = State.no_empty state in
  match status, no_empty with
  | TURN_1, true -> State.new_status state WIN_2
  | TURN_2, true -> State.new_status state WIN_1
  | _ -> state

(*!!!!!!! BELOW IS AI ALGORITHM!!!!!!!*)

let is_grey_possible (s: State.t) (p: int * int) = 
  let ls = valid_possible_moves p s in 
  if (List.length ls) = 1 then Some (List.hd ls) else None

let is_create_grey_possible (s : State.t) ((x, y): int * int) = 
  let len = State.board_len s in 
  let dim = State.board_dim s in 
  let b = ref [] in 
  for i = 0 to len - 1 do 
    for j = 0 to len - 1 do  
      if (State.get_square s (i, j) = State.Empty 
          && (i = x || j = y || (i / dim = x / dim && j / dim = y / dim)) 
          && (i <> x || j <> y)) then 
        begin
          match is_grey_possible s (i, j) with 
          | None -> ()
          | Some q -> 
            if valid_move (Command.Move (q, (x, y))) s 
            then b := q :: (!b) 
            else ()
        end
      else ()
    done 
  done; 
  !b

let count ls elt = 
  let rec count_rec acc elt = function 
    | [] -> acc
    | h::t -> count_rec (acc + if h = elt then 1 else 0) elt t 
  in 
  count_rec 0 elt ls

let random_pick ls = 
  Random.self_init () ;
  let ran = List.length ls |> Random.int in 
  List.nth ls ran 

let odd_or_even_grey (s: State.t) (odd: bool): Command.t option = 
  let len = State.board_len s in 
  let x = ref [] in 
  for i = 0 to len - 1 do 
    for j = 0 to len - 1 do 
      let ls = is_create_grey_possible s (i, j) in 
      for h = 1 to len do 
        let num = count ls h in 
        let b = num mod 2 = 0 in 
        if num = 0 then () else  
        if (odd && b) || ((not odd) && (not b)) then () else 
          let cmd = Command.Move (h, (i, j)) in 
          if (valid_move cmd s) then x := cmd :: (!x) else ()
      done
    done
  done;
  match !x with 
  | [] -> None 
  | h::t -> Some (random_pick (!x))

let rec random_move s = 
  let len = State.board_len s in 
  let x = Random.self_init () ; Random.int len in 
  let y = Random.self_init () ; Random.int len in 
  let z = valid_possible_moves (x, y) s in 
  match z with 
  | [] -> random_move s
  | h::t -> let w = Random.self_init(); Random.int (List.length z) in 
    let cmd = Command.Move ((List.nth z w), (x, y)) in 
    if valid_move cmd s then cmd else random_move s

let optimal_move s = 
  let strategy s = 
    let num_of_empty = State.count_type s State.Empty in 
    num_of_empty mod 2 = 0  in 
  let cmd = match odd_or_even_grey s (strategy s) with 
    | Some x -> x (* I have a strategy!*)
    | None ->  random_move s in  (*I dont have a strategy*)
  match cmd with 
  | Move (v,loc) -> 
    State.set_square s (Value v) loc;
    update_gray s;
    s
  | _ -> failwith "should not happen"

(* !!!!!!!ABOVE IS THE AI ALGORITHM!!!!!!!!!!!!*)


let toggle_turn t =
  match t with
  | ONEPLAYER TURN_1, b when State.no_empty t -> 
    transition_winning (ONEPLAYER TURN_2, b)
  | ONEPLAYER TURN_2, b when State.no_empty t -> 
    transition_winning (ONEPLAYER TURN_1, b)
  | ONEPLAYER(TURN_1), b | ONEPLAYER TURN_2, b -> optimal_move t
  | (TWOPLAYER TURN_2, b) -> (TWOPLAYER TURN_1, b)
  | (TWOPLAYER TURN_1, b) -> (TWOPLAYER TURN_2, b)
  | CLIENT(TURN_1), b -> (CLIENT(TURN_2), b)
  | CLIENT(TURN_2), b -> (CLIENT(TURN_1), b)
  | HOST(TURN_1), b -> (HOST(TURN_2), b)
  | HOST(TURN_2), b -> (HOST(TURN_1), b)
  | s -> s

let interpret_move command state =
  match command with
  | Quit -> failwith "requires clause not met"
  | Move (v, loc) ->
    State.set_square state (Value v) loc;
    update_gray state;
    state |> toggle_turn |> transition_winning
