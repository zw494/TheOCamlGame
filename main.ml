open Command
open State
open Prettyprint
open Unix
open Socket

(** [game msg s] starts a round of game. It prints out [msg] every time before 
    a game really starts. Users should type in input and the Duidoku game will 
    justify the user's response. If there is no input in 10s, this user's time 
    is out and turns will be toggled. *)
let rec game dim msg s =
  let () = match s with 
    |TWOPLAYER(_), _ -> print_string "great!\n"
    | _ -> () 
  in 
  let () = Prettyprint.print_general dim s in
  let m = if msg = "" then "\n> " else msg in 
  print_string(m);
  let com = read_line () in
  try 
    let command = Command.parse com in 
    match command with
    | Move _ -> if Interpreter.valid_move command s then 
        game dim "" (Interpreter.interpret_move command s)
      else game dim "The command is not valid. Please try again.\n> " s
    | Quit -> Pervasives.exit 0
  with | Command.Empty  -> game dim "The command is empty.\n> " s
       | Command.Malformed -> 
         game dim "The command is malformed. Please try again.\n> " s

(** [client_wait client s] accepts inputs of the client and wait until the 
    other side responds. Then it sends its resulted command into the server. *)
let rec client_wait client s = 
  let () = Prettyprint.print_general (State.board_dim s) s in
  try
    match Command.parse (Socket.GameClient.wait_move client) with
    | Move _ as com -> Interpreter.interpret_move com s
    | Quit -> print_string "Host quit the game."; ignore(Pervasives.exit 0); s
  with Socket.Quit ->
    print_endline "Host quit the game."; ignore(Pervasives.exit 0); s

(** [client_play dim client s ] parses the command and sends it to server when 
    the game is waiting for client for input.*)
let rec client_play dim client s = 
  let () = Prettyprint.print_general dim s in 
  let com = read_line () in
  try 
    let command = Command.parse com in 
    match command with
    | Move _ -> begin if Interpreter.valid_move command s then begin
        let () = Socket.GameClient.send_move client com in 
        (Interpreter.interpret_move command s) end
        else
          let () = 
            print_string "The command is not valid. Please try again.\n> " in 
          client_play dim client s
      end
    | Quit -> Pervasives.exit 0
  with 
  | Command.Empty  ->  print_string "The command is empty.\n> ";
    client_play dim client s
  | Command.Malformed -> 
    print_string "The command is malformed. Please try again.\n> "; 
    client_play dim client s

(** [client_game dim client s] detects whether the client's command should be 
    parsed by [client_play] or [client_wait], i.e. whether the turn is the 
    client's.*)
let rec client_game dim client s = 
  match s with 
  | (CLIENT(TURN_2), _) -> client_game dim client (client_play dim client s)
  | _ -> client_game dim client (client_wait client s)

(** [host_wait client s] accepts inputs of the host and wait until the 
    other side responds. Then it sends its resulted command into itself. *)
let host_wait host s = 
  let () = Prettyprint.print_general (State.board_dim s) s in
  try
    match Command.parse (Socket.GameHost.wait_move host) with
    | Move _ as com -> Interpreter.interpret_move com s
    | Quit -> print_string "Client quit the game."; ignore(Pervasives.exit 0); s
  with Socket.Quit ->
    print_endline "Host quit the game."; ignore(Pervasives.exit 0); s

(** [host_play dim client s ] parses the command and sends it to itself when 
    the game is waiting for the host for input.*)
let rec host_play dim host s =
  let () = Prettyprint.print_general dim s in
  let com = read_line () in
  try 
    let command = Command.parse com in 
    match command with
    | Move _ -> begin if Interpreter.valid_move command s then begin
        let () = Socket.GameHost.send_move host com in 
        (Interpreter.interpret_move command s) end
        else
          let () = 
            print_string "The command is not valid. Please try again.\n> " in 
          host_play dim host s
      end
    | Quit -> Pervasives.exit 0
  with 
  | Command.Empty  ->  
    print_string "The command is empty.\n> "; host_play dim host s
  | Command.Malformed -> 
    print_string "The command is malformed. Please try again.\n> "; 
    host_play dim host s

(** [host_game dim client s] detects whether the host's command should be 
    parsed by [host_play] or [host_wait], i.e. whether the turn is the 
    host's.*)
let rec host_game dim host s =  
  match s with 
  | (HOST(TURN_1), _) -> host_game dim host (host_play dim host s)
  | _ -> host_game dim host (host_wait host s)

(** [play_game size] starts a game with a given size.
    - Requires: [size] > 0, and [size] < 4.*)
let rec play_game size mode =
  if mode = 3 then
    let () = ANSITerminal.(print_string [red] "Enter the port number:\n>") in
    try
      let po = read_int () in
      if po < 6000 then begin
        print_endline "Port must be greater than 6000";
        play_game size mode end
      else
        print_endline "Waiting for client...";
        let host = Socket.GameHost.start_server po in 
        Socket.GameHost.send_move host (string_of_int size);
        host_game size host (State.empty size mode)
    with Failure _ ->
      print_endline "Port must be a number!";
      play_game size mode
  else if mode = 4 then 
    let () =
      ANSITerminal.(print_string [red] "Enter the IP address to join: \n>") in
    let ip = read_line () in 
    ANSITerminal.(print_string [] "Enter the port number:\n>");
    try
      let po = read_int () in
      print_endline "Waiting for server...";
      let client = Socket.GameClient.connect_client ip po in
      let new_size = Socket.GameClient.wait_move client |> int_of_string in
      client_game new_size client (State.empty new_size mode)
    with 
    | Failure _ ->
      print_endline "Port must be a number!";
      play_game size mode
    | Socket.GameClient.NoConnect _ ->
      print_endline "Cannot connect to specified IP address and port!";
      play_game size mode
  else 
    game size "" (State.empty size mode)

(** [main ()] starts the game. *)
let main () =
  ANSITerminal.(print_string [red] "\nWelcome to Duidoku\n 
  Please enter your desired grid size.\n
  If you select mode '4', your grid size will be overwritten by the host's choice.\n
  The number you enter represents the size of the inner grid, 
  thus the entire board will have dimension n*n x n*n.\n
  Please enter a positive number less than or equal to 3:
  \n>");

  let rec read_dims () x =
    try
      let dim = read_int () in
      if dim < 1 || dim > 3 then
        (print_string ("Type a positive integer <= "^
                       (string_of_int x) ^" bucko!\n");
         read_dims () x )
      else dim
    with
    | Failure _ -> print_string "Type an integer bucko!\n";
      read_dims () x  in
  let rec read_mode () x =
    try
      let dim = read_int () in
      if dim <= x && dim >= 1 then dim
      else begin
        print_string "Please type a correct mode number!\n";
        read_mode () x end
    with
    | Failure _ -> print_string "Type an integer bucko!\n";
      read_mode () x  in
  let dim = read_dims () 3 in 
  ANSITerminal.(print_string [red] "
  Please enter the mode you would like to play in.\n
  You can enter '1' to play against an AI, '2' for two
  player mode on one computer, '3' to host a game, and '4' to join a game: \n
  \n>");
  let mode = read_mode () 4 in 
  play_game dim mode 

(* Execute the game engine. *)
let () = main ()
