type square = 
  | Value of int
  | Gray
  | Empty

type status =
  | TURN_1
  | TURN_2
  | WIN_1
  | WIN_2

type state =
  |TWOPLAYER of status
  |ONEPLAYER of status
  |HOST of status
  |CLIENT of status

(** matrix is row by column *)
type 'a matrix = 'a array array

type board = square matrix

type t = state * board

let make_matrix size x = 
  Array.init size (fun _ -> Array.make size Empty)

let board_len (_, t) = 
  Array.length t

let board_dim (_, t) = 
  int_of_float (sqrt (float (Array.length t)))

let empty dim mode =
  match mode with 
  | 1 -> (ONEPLAYER(TURN_1), make_matrix (dim*dim) Empty)
  | 2 -> (TWOPLAYER(TURN_1), make_matrix (dim*dim) Empty)
  | 3 -> (HOST(TURN_1), make_matrix (dim*dim) Empty)
  | 4 -> (CLIENT(TURN_1), make_matrix (dim*dim) Empty)
  | _ -> failwith "Invalid mode"

let get_square (_, board) (x, y) = 
  board.(x).(y)

let get_row_elements ((state, board):t) x = 
  board.(x)

let get_col_elements ((state, board):t) y =
  Array.map (fun arr -> arr.(y)) board

let get_grid_elements (t:t) (x: int) (y: int)  = 
  let dim = board_dim t in 
  let board = snd t in
  let arr = Array.make (dim*dim) Empty in 
  for i = x/dim * dim to x/dim *dim + dim - 1 do
    for j = y/dim * dim to y/dim * dim +  dim - 1 do 
      arr.((i - (x/dim * dim))*dim + j - (y/dim * dim) ) <- board.(i).(j)
    done 
  done;
  arr

let get_all_elements t = 
  let len = board_len t in 
  let arr = Array.make (len*len) Empty in 
  for i = 0 to len - 1 do 
    for j = 0 to len - 1 do 
      arr.(i * len + j) <- (snd t).(i).(j)
    done
  done;
  arr


let no_empty (_, b) =
  let f  = function
    | Empty -> false
    | Gray | Value _ -> true in
  let row_f row =
    Array.for_all f row in
  Array.for_all row_f b

let get_state = fst  

let get_status = function
  |(ONEPLAYER s, _) -> s
  |(TWOPLAYER s, _) -> s
  |(HOST s, _) -> s
  |(CLIENT s, _) -> s

let new_status (state, b) s1 =
  match state with
  |ONEPLAYER s2 -> (ONEPLAYER s1, b)
  |TWOPLAYER s2 -> (TWOPLAYER s1, b)
  |HOST s2 -> (HOST s1, b)
  |CLIENT s2 -> (CLIENT s1, b)

let set_square (s:t) v (x, y) = 
  let arr = (snd s).(x) in
  Array.set arr y v

let count_type (s:t) typ = 
  Array.fold_left (fun acc elt -> acc + if (elt = typ) then 1 else 0)
    0 (get_all_elements s)
