(** The representation of a game. Be careful that this state is mutable.*)

(** The type representing a game board square (or tile). Can be
    [Value v] if the number [v] occupies the square, [Gray] if
    no value can be validly placed at the square (also colored
    gray in GUI), [Empty] if nothing there. *)
type square = 
  | Value of int
  | Gray
  | Empty

(** Type representing status of the game. [TURN_1] if it's
    player one's turn. [TURN_2] if it's player two's turn.
    [WIN_1] if player one has won, [WIN_2] if player two
    has won. *)
type status =
  | TURN_1
  | TURN_2
  | WIN_1
  | WIN_2

(** Type representing the mode of the game.  [TWOPLAYER] if it's
    a two player game (i.e. two users). [ONEPLAYER] if its a one
    player game (i.e. only one user). [HOST] if this terminal is 
    hosting the game. [CLIENT] if this terminal is attending 
    someone else's game.*)
type state = 
  | TWOPLAYER of status
  | ONEPLAYER of status
  | HOST of status
  | CLIENT of status

(** Type representing a two-dimensional array of type ['a]. *)
type 'a matrix = 'a array array

(** Type representing the game board. A matrix of [square]s. *)
type board = square matrix

(** Type representing game state. Consists of a [status] and game board. *)
type t = state * board

(** [make_matrix size x] creates a matrix filled with [x] of size [size].
    - Requires: 0 < [size] < 4. *)
val make_matrix: int -> 'a -> square array array

(** [empty dim] returns [(TURN_1, b)] where [b] is a
    two-dimensional array with size [dim*dim] for each row
    and column.
    Requires: 
    - [dim] > 0 *)
val empty : int -> int -> t

(** [board_dim t] returns [len^(1/2)] where [len]
    is the size of each row and column of [snd t]. *)
val board_dim: t -> int

(** [board_len t] gives the width/height of the game board
    of [t]. *)
val board_len: t -> int

(** [set_square t1 s (x, y)] returns unit. 
    Side effects: sets square at location [(x, y)] to
      [s].
    Requires:
    - [(x, y)] is within the bounds of the array [snd t]. *)
val set_square : t -> square -> (int * int) -> unit

(** [get_square t (x, y)] returns the square at location [(x, y)].
    Requires:
    - [(x, y)] is within the bounds of the array [snd t]. *)
val get_square : t -> (int * int) -> square

(** [no_empty t] return true if there are no empty squares in [t].
    In other words, returns true if every square is [GRAY]
    or [Value v]. *)
val no_empty : t -> bool

(** [get_status t] returns the state of [t]. Is either
    [ONEPLAYER] of status or [TWOPLAYER] of status *)
val get_state : t -> state

(** [get_status t] returns the status of [t]. Is either
    [TURN_1], [TURN_2], [WIN_1], or [WIN_2]. *)
val get_status : t -> status

(** [new_status t status] returns [t'] where the status
    of [t'] is [status] but the game board remains unchanged. *)
val new_status : t -> status -> t

(** [get_grid_elements t x t] returns a one dimensional array
    of [square]s that make up the grid located around [(x, y)].
    Requires:
    - [(x, y)] lies within the game board. *)
val get_grid_elements: t -> int -> int -> square array

(** [get_col_elements t x t] returns a one dimensional array
    of [square]s that make up the column of location [(x, y)].
    Requires:
    - [(x, y)] lies within the game board. *)
val get_col_elements: t -> int -> square array

(** [get_col_elements t x t] returns a one dimensional array
    of [square]s that make up the row of location [(x, y)].
    Requires:
    - [(x, y)] lies within the game board. *)
val get_row_elements: t -> int -> square array

(** [get_board_elements t] returns a one dimensional array
    of [square]s in row column order that make up entire board.*)
val get_all_elements: t -> square array

(** [count_type t sq] returns the number of elements of type [sq] in the 
    state representation [t].*)
val count_type: t -> square -> int