(** {1 BitChannel}
    This module allows reading and writing files bit by bit.  It provides types
and functions to open, read, write, and close bit channels.
*)

(** {2 Types} *)

(** type `bit_in_channel` : Type representing a bit input channel. *)
type bit_in_channel = {
  input_channel : in_channel;  (** The underlying input channel. *)
  mutable current_byte : int;  (** The current byte being processed. *)
  mutable bit_position : int;  (** The current bit position within the byte. *)
}

(** type `bit_out_channel` : Type representing a bit output channel. *)
type bit_out_channel = {
  output_channel : out_channel;  (** The underlying output channel. *)
  mutable current_byte : int;    (** The current byte being processed. *)
  mutable bit_position : int;    (** The current bit position within the byte. *)
}

(** {2 Functions} *)

(** {3 Reading} *)

(** [open_in_bit filename] opens the file [filename] for reading bits. *)
let open_in_bit filename =
  { input_channel = open_in_bin filename;
    current_byte = 0;
    bit_position = -1 }

(** [input_bit bic] reads the next bit from the bit input channel [bic],
    handling padding to determine the end of the file. *)
let input_bit (bic : bit_in_channel) =
  if bic.bit_position = -1 then begin
    bic.current_byte <- input_byte bic.input_channel;
    bic.bit_position <- 7;
    (* Check if this is the last byte by trying to read one more byte *)
    try
      let _ = input_byte bic.input_channel in
      seek_in bic.input_channel (pos_in bic.input_channel - 1); (* Rewind one byte *)
    with
    | End_of_file ->
      (* If this is the last byte, remove the padding *)
      let rec remove_pad () =
        let first_bit = bic.current_byte land 1 in
        bic.bit_position <- bic.bit_position - 1 ;
        bic.current_byte <- bic.current_byte lsr 1 ;
        if first_bit = 1 then remove_pad ()
      in
      remove_pad ();
      if bic.bit_position < 0 then raise End_of_file;
  end;
  let bit = (bic.current_byte lsr bic.bit_position) land 1 in
  bic.bit_position <- bic.bit_position - 1;
  bit

(** [input_8bits bic] reads the next 8 bits from the bit input channel [bic].
    *)
let input_8bits bic =
  let rec aux n acc =
    if n = 0 then acc
    else
      let bit = input_bit bic in
      aux (n - 1) ((acc lsl 1) lor bit)
  in
  aux 8 0

(** [input_nbits bic nbbits] reads the next [nbbits] bits from the bit input
    channel [bic]. *)
let input_nbits bic nbbits =
  let rec aux n acc =
    if n = 0 then acc
    else
      let bit = input_bit bic in
      aux (n - 1) ((acc lsl 1) lor bit)
  in
  aux nbbits 0

(** [close_in_bit bic] closes the bit input channel [bic]. *)
let close_in_bit bic =
  close_in bic.input_channel

(** {3 Writing} *)

(** [open_out_bit filename] opens the file [filename] for writing bits. *)
let open_out_bit filename =
  { output_channel = open_out_bin filename;
    current_byte = 0;
    bit_position = 7 }

(** [output_bit boc value] writes the bit [value] (0 or 1) to the bit output
    channel [boc]. *)
let output_bit boc value =
  if value <> 0 && value <> 1 then
    invalid_arg "output_bit: value must be 0 or 1";
  boc.current_byte <- (boc.current_byte lsl 1) lor value;
  boc.bit_position <- boc.bit_position - 1;
  if boc.bit_position = -1 then begin
    output_byte boc.output_channel boc.current_byte;
    boc.current_byte <- 0;
    boc.bit_position <- 7
  end

(** [output_8bits boc value] writes the byte [value] (0-255) to the bit output
    channel [boc]. *)
let output_8bits boc value =
  if value < 0 || value > 255 then
    invalid_arg "output_8bits: value must be between 0 and 255.";
  for i = 7 downto 0 do
    let bit = (value lsr i) land 1 in
    output_bit boc bit
  done

(** [output_nbits boc nb_bits value] writes the [nb_bits] bits of [value] to
    the bit output channel [boc]. *)
let output_nbits boc nb_bits value =
  if value < 0 || value > ((1 lsl nb_bits) - 1) then (
    Printf.printf "%d nb_bits for value %d\n" nb_bits value ;
    invalid_arg "output_nbits: value is bigger than expected." );
  for i = (nb_bits-1) downto 0 do
    let bit = (value lsr i) land 1 in
    output_bit boc bit
  done

(** [close_out_bit boc] closes the bit output channel [boc], padding the last
    byte if necessary. *)
let close_out_bit boc =
  boc.current_byte <- boc.current_byte lsl (boc.bit_position + 1);
  boc.current_byte <- boc.current_byte lor ((1 lsl boc.bit_position) - 1);
  output_byte boc.output_channel boc.current_byte ;
  close_out boc.output_channel

