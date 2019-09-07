(** Interprets and validifies commands. In MVC model, this is 
    the controller part, which modifies states as models of the game.*)

(** [i -- j] is the list of integers from [i] to [j], inclusive.
    Tail recursive. *)
val (--) : int -> int -> int list 

(** [valid_grid v (x, y) state] returns true if value [v] is not 
    contained within the grid where [(x, y)] is located. Else
    returns false. 
    Requires:
    - [(x, y)] is on the game board
    - [v] is a permissible value for this game. *)
val valid_grid : State.square -> int * int -> State.t -> bool

(** [valid_row v (x, y) state] returns true if value [v] is not 
    contained within the row where [(x, y)] is located. Else
    returns false. 
    Requires:
    - [(x, y)] is on the game board
    - [v] is a permissible value for this game. *)
val valid_row: State.square -> int * 'a -> State.t -> bool

(** [valid_col v (x, y) state] returns true if value [v] is not 
    contained within the column where [(x, y)] is located. Else
    returns false. 
    Requires:
    - [(x, y)] is on the game board
    - [v] is a permissible value for this game. *)
val valid_col: State.square -> 'a * int -> State.t -> bool

(** [is_valid_tile (v, l) state] returns true if value [v] at square
    location [l] is permitted. Will return false if one of the
    following conditions are met: 
    - [v] occupies column of [l], row of [l], or grid of [l]
    - square at [l] is gray
    - square at [l] already has a value
      Requires:
    - [l] is on the game board
    - [v] is a permissible value for this game. *)
val is_valid_tile: int * (int * int) -> State.t -> bool

(** [valid_move cmd st] returns true if [cmd] is a valid move under
     restrictions defined under [st]. If [cmd] is [Quit], returns false.
     If [cmd] is [val, (x, y)], will check that placing [val] at square
     [(x, y)] is permitted. If it is, will return true. If not, will return
     false. 
     Requires:
    - [val], [x], [y] are non-negative. *)
val valid_move : Command.t -> State.t -> bool

(** [valid_possible_moves loc state] is a list of possible numbers that 
    can be placed at [loc] while in [state]. 
    - Requires: [loc] is a valid position state 
    - Asserts: square should be grey if valid_count = 0. *)
val valid_possible_moves : int * int -> State.t -> int list

(** [is_grey_square loc state] returns true if no value at square
    location [l] is permitted. Will return false otherwise.
    Requires:
    - [l] is on the game board
    - [v] is a permissible value for this game. *)
val is_grey_square: int * int -> State.t -> bool

(** [update_gray state] returns unit.
    Side effects: For each square [sq] (with location [loc])
    in [snd state], changes [sq] to [GRAY] if [is_grey_square loc state]
    is true. If false, the square remains unchanged.
    Requires:
    - [fst state] is [TURN_1] or [TURN_2]. *)
val update_gray: State.t -> unit

(** [transition_winning st] returns updated state [(s', _)] where s' is:
    - WIN_1 if [fst st] is [TURN_2] and no move is valid
    - WIN_2 if [fst st] is [TURN_1] and no move is valid
    - else, [transition_winning st] returns [st].
      Requires:
    - [fst st] is [TURN_1] or [TURN_2] *)
val transition_winning: State.t -> State.t




(** [is_gray_possible s p] is [Some x] if only one number [x] can be filled into 
    position [p] in state [t]. [None] otherwise. 
    - Requires: [p] is a valid posit\ion in [s].*)
val is_grey_possible : State.t -> int * int -> int option

(** [is_create_gray_possible s p] is a list of integers such that each of them 
    will make a square gray if they are placed in position [p] at state [s]. 
    Also, the number of times that one integer occurs is the number of gray 
    squares that could be created once placing that number in [p] at state [s].
    - Requires: [p] is a valid position in [s].
    - Example: if [is_create_gray_possible s p] is [3;2;3], then placing a 
      "3" into position [p] will create 2 gray squares, whereas placing a "2" 
      into position [p] will only create 1 gray square.*)
val is_create_grey_possible : State.t -> int * int -> int list

(** [count ls elt] is the number of times [elt] occurred in [ls]. 
    - Example: [count [3] 3 = 1]. *)
val count : 'a list -> 'a -> int

(** [random_pick ls] picks a random element from [ls]. 
    - Raises: [Failure ls] if [ls] is empty.*)
val random_pick : 'a list -> 'a

(** [place_odd_gray_or_even_gray s odd] is a command option. 
    If [odd] is [true], and it is possible to generate odd numbers of gray 
    squares, then it returns [Some x], where [x] is a command guaranteed to 
    generate odd numbers of gray squares. If [odd] is [false], and it is 
    possible to generate even numbers of gray squares, then it returns 
    [Some x], where [x] is a command guaranteed to generate odd numbers of 
    gray squares. If not possible, then it returns [None].
    - Requires: [s] must be a valid state, and NOT a winning state
*)
val odd_or_even_grey : State.t -> bool -> Command.t option

(** [random_move s] is a valid random move in state [s].
    - Requires: [s] MUST NOT be a state with no possible moves, i.e. a winning 
      state.*)
val random_move : State.t -> Command.t

(** [optimal move s] makes the AI perform the optimal move if there is one
    or a random move if there is not one [random_move s].  It will return 
    the updated state.
    - Requires: [s] must be a valid state, and NOT a winning state *)
val optimal_move : State.t -> State.t


(** [toggle_turn t] returns [t'] where the status of [t'] is: 
    - [TURN_1] if the status of [t] is [TURN_2] 
    - [TURN_2] if the status of [t] is [TURN_1].
      Requires:
    - [t] has status [TURN_1] or [TURN_2]. *)
val toggle_turn: State.t -> State.t

(** [interpret_move cmd st] transitions [st] to [st'] according to [cmd].
    If [cmd] is [val, (x, y)], [val] will be placed at square [(x, y)] to
    form state [st2]. Then, each square in [st2] will be updated to gray,
    or remain unchanged, to form [st3]. The next player's turn will be
    toggled to form [st4]. Finally, the winning condition will checked. 
    If any player has won, the state will be updated to one of the
    winning states, [st']. 
    Requires:
    - [valid_move cmd st] returns true. *)
val interpret_move : Command.t -> State.t -> State.t




