exception Quit

(** A module for starting, stopping, and communicating to a peer computer
    as a host. *)
module type Host = sig

  (** Type encapsulating information about the host. *)
  type t = {socket: Unix.file_descr ref; inchan: in_channel ref; 
            outchan: out_channel ref}

  (** Exception representing the inability to start a host. *)
  exception NoStart

  (** [start_server p] starts a socket and waits for a connection on port [p].
      Requires:
      - Cannot bind on an occupied port 
        Raises: [NoStart] if the server cannot start. *)
  val start_server : int -> t

  (** [close_server t] closes socket associated with [t]. *)
  val close_server : t -> unit

  (** [send_move t str] sends [str] to the client connected to [t]
      and returns [unit]. *)
  val send_move : t -> string -> unit

  (** [wait_move t] waits for a client to send a string [str], 
      and returns [str]. *)
  val wait_move : t -> string
end

(** A module for starting, stopping, and communicating to a peer computer
    as a client (connecting to host). *)
module type Client = sig

  (** Type encapsulating information about the client. *)
  type t = {socket: Unix.file_descr ref; inchan: in_channel ref; 
            outchan: out_channel ref}

  (** Exception representing the inability to connect to a host. *)
  exception NoConnect of string

  (** [connect_client str p] starts a socket and attempts to connect to socket
      bound to IP address [str] on port [p].
      Requires:
      - [str]:[p] is a valid entry point
        Raises: [NoConnect] if the client cannot connect. *)
  val connect_client : string -> int -> t

  (** [close_client t] closes socket associated with [t]. *)
  val close_client : t -> unit

  (** [send_move t str] sends [str] to the host connected to [t]
      and returns [unit]. *)
  val send_move : t -> string -> unit

  (** [wait_move t] waits for a host to send a string [str], 
      and returns [str]. *)
  val wait_move : t -> string
end

(** [GameHost] is the actual hosting module that implements [Host].*)
module GameHost : Host

(** [GameClient] is the actual client module that implements [Client].*)
module GameClient : Client