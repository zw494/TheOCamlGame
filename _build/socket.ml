exception Quit


module type Host = sig
  type t = {socket: Unix.file_descr ref; inchan: in_channel ref; 
            outchan: out_channel ref}

  exception NoStart
  val start_server : int -> t

  val close_server : t -> unit

  val send_move : t -> string -> unit

  val wait_move : t -> string
end

module type Client = sig

  type t = {socket: Unix.file_descr ref; inchan: in_channel ref; 
            outchan: out_channel ref}

  exception NoConnect of string

  val connect_client : string -> int -> t

  val close_client : t -> unit

  val send_move : t -> string -> unit

  val wait_move : t -> string
end

module GameHost : Host = struct
  type t = {socket: Unix.file_descr ref; inchan: in_channel ref; 
            outchan: out_channel ref}

  exception NoStart

  let my_addr =
    let my_name = Unix.gethostname() in
    let my_entry_byname = Unix.gethostbyname my_name in
    my_entry_byname.Unix.h_addr_list.(0)

  let start_server po =
    (** Creates a default TCP socket (using stream option) *)
    let s_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    Unix.setsockopt s_descr Unix.SO_REUSEADDR true;
    try
      let bind_socket () = Unix.bind s_descr (Unix.ADDR_INET (my_addr, po)) in
      let listen_socket () = Unix.listen s_descr 5 in
      bind_socket ();
      listen_socket ();
      let service_socket, sock_addr = Unix.accept s_descr in
      let output = Unix.out_channel_of_descr service_socket in
      let input = Unix.in_channel_of_descr service_socket in
      { socket = ref service_socket; inchan = ref input; outchan = ref output }
    with Unix.Unix_error _ -> 
      Unix.shutdown s_descr Unix.SHUTDOWN_SEND; raise NoStart

  let close_server t =
    Unix.shutdown !(t.socket) Unix.SHUTDOWN_SEND

  let send_move t str = 
    let outchan = !(t.outchan) in
    output_string outchan (str^"\n");
    flush outchan

  let wait_move (t:t) =
    let inchan = !(t.inchan) in
    try
      input_line inchan
    with End_of_file ->
      close_server t;
      raise Quit
end

module GameClient : Client = struct

  type t = {socket: Unix.file_descr ref; inchan: in_channel ref;
            outchan: out_channel ref}

  exception NoConnect of string

  let my_addr =
    let my_name = Unix.gethostname() in
    let my_entry_byname = Unix.gethostbyname my_name in
    my_entry_byname.Unix.h_addr_list.(0)

  (** [local_addr str] Converts [str], if [str] is ["localhost"], to the local 
      IP address assigned by the network of the client machine, else it returns 
      [str]. *)
  let local_addr str =
    if str = "localhost" then Unix.string_of_inet_addr my_addr
    else str

  let connect_client addr po =
    (** Creates a default TCP socket (using stream option) *)
    let s_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    try
      let new_addr = local_addr addr in
      let target_addr = Unix.inet_addr_of_string new_addr in
      let sock_addr = (Unix.ADDR_INET (target_addr, po)) in
      Unix.connect s_descr sock_addr;
      let output = Unix.out_channel_of_descr s_descr in
      let input = Unix.in_channel_of_descr s_descr in
      { socket = ref s_descr; inchan = ref input; outchan = ref output }
    with 
    | Failure s -> raise (NoConnect s)
    | Unix.Unix_error _ -> raise (NoConnect "Connection error")

  let close_client t =
    Unix.shutdown !(t.socket) Unix.SHUTDOWN_SEND

  let send_move t str = 
    let outchan = !(t.outchan) in
    output_string outchan (str^"\n");
    flush outchan

  let wait_move (t:t) =
    let inchan = !(t.inchan) in
    try
      input_line inchan
    with End_of_file ->
      close_client t;
      raise Quit
end