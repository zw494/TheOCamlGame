(** Construct and parse commands.*)

(** Location representing parsed [(x, y)] pair. *)
type location = int * int

(** Type representing a parsed user command. Player can either [Quit] or
    [Move (v, (x, y))] which indicates the player wants to place value [v]
    on square located at [(x, y)]. *)
type t = 
  | Move of int * location
  | Quit

(** Raised when an empty command is parsed. *)
exception Empty

(** Raised when a malformed command is encountered. *)
exception Malformed

(** [is_natural s] returns if the string [s] is a non-negative integer. *)
val is_natural: string -> bool 

(** [parse str] parses the command string that the user client enters
    into the commandline. If command is "quit", returns [Quit]. If command
    is in format "move val x,y", returns [Move (val, (x, y))]. This method
    does not check if val, or (x, y) conform with game board restrictions.
    Raises: [Malformed] when [str] is not in one of the following formats:
        1. "quit"
        2. "move 5 2,3" *)
val parse : string -> t