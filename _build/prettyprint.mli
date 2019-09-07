(** Pretty prints messages to the terminal. *)

(** [ encode sq] translates the square [sq] into a string. 
    - Requires: [sq] must be valid and cannot exceed 3 digits 
      in representation.*)
val encode: State.square -> string

(** [chararr s] transforms a square array [s] into a string array
    using [encode].
    - Requires: all squares in [s] must be valid and cannot exceed 3 digits 
      in representation.*)
val chararr: State.t -> string array

(** [print_state dim s] prints out the state [s] with dimension [dim]
    prettily using for loops. Its time complexity is O(n^2). 
    - Requires: [dim] must be equal to the dimension of [s]. *)
val print_state: int -> State.t -> unit

(** [general_print_state dim a] generalizes printing by using for loops and 
    allows printing multiple dimensions as well as row and column numbers. It 
    prints a state represented by string array [a] with dimension [d]. *)
val general_print_state : int -> string array -> unit

(** [print_general dim s] prints out general information that should 
    be printed to the terminal before each round starts. If the game wins, 
    then it will print out winning message.
    - Requires: [dim] must be equal to the dimension of [s]. *)
val print_general: int -> State.t -> unit