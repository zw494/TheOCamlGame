type location = int * int

type t = 
  | Move of int * location
  | Quit

exception Empty

exception Malformed

let is_natural s =
  try
    let i = int_of_string s in
    i > -1
  with Failure _ -> false

let parse str =
  let nowhitespace = String.trim str in
  let lst = String.split_on_char ' ' nowhitespace in 
  if List.length lst = 0 then raise Malformed
  else if  ((List.hd lst = "move" || List.hd lst = "Move") 
            && (List.length lst = 3)) then
    let value_s = List.nth lst 1 in
    if not (is_natural value_s) then raise Malformed
    else let value = int_of_string value_s in
      let xy = String.split_on_char ',' (List.nth lst 2) in
      if List.length xy = 2 then
        let x_s =  List.nth xy 0 in
        let y_s =  List.nth xy 1 in
        if (is_natural x_s) && (is_natural y_s) then
          let x = int_of_string x_s in
          let y = int_of_string y_s in
          Move (value, (x,y))
        else raise Malformed
      else raise Malformed
  else if (List.hd lst= "quit" || List.hd lst= "Quit") then Quit
  else raise Malformed