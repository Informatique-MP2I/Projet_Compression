(** {1 BitChannel} reading and writing files bit by bit.

    It provides types and functions to open, read, write, and close bit channels.
    This documentation explains the usage of the various functions in the module.

    {2 Usage examples}

    Here is a simple example showing how to use the BitChannel module to read
and write bits:

    {[
      open BitChannel

      (* Writing bits to a file *)
      let () =
        let out_channel = open_out_bit "example.bits" in
        output_bit out_channel 1;
        output_bit out_channel 0;
        output_8bits out_channel 255; (* Writes bits 11111111 *)
        close_out_bit out_channel

      (* Reading bits from a file *)
      let () =
        let in_channel = open_in_bit "example.bits" in
        let bit1 = input_bit in_channel in
        let bit2 = input_bit in_channel in
        let byte = input_8bits in_channel in
        Printf.printf "Bits read: %d, %d, Byte read: %d\n" bit1 bit2 byte;
        close_in_bit in_channel
    ]}
*)

(** {2 Types} *)

(** The type representing an input bit channel. *)
type bit_in_channel

(** The type representing an output bit channel. *)
type bit_out_channel

(** {2 Functions} *)

(** {3 Reading} *)

(** [open_in_bit filename] opens the file [filename] for reading bits.
    @param filename The name of the file to open.
    @return A bit input channel for reading bits from the file.
    @raise Sys_error if the file cannot be opened. *)
val open_in_bit : string -> bit_in_channel

(** [input_bit bic] reads the next bit from the bit input channel [bic].
    @param bic The bit input channel.
    @return The next bit (0 or 1) read from the channel.
    @raise End_of_file if the end of the file is reached. *)
val input_bit : bit_in_channel -> int

(** [input_8bits bic] reads the next 8 bits from the bit input channel [bic].
    @param bic The bit input channel.
    @return The next byte (0-255) read from the channel.
    @raise End_of_file if the end of the file is reached before 8 bits are read. *)
val input_8bits : bit_in_channel -> int

(** [input_nbits bic nbbits] reads the next [nbbits] bits from the bit input channel [bic].
    @param bic The bit input channel.
    @param nbbits The number of bits to read.
    @return The next [nbbits] bits as an integer.
    @raise End_of_file if the end of the file is reached before [nbbits] bits are read. *)
val input_nbits : bit_in_channel -> int -> int

(** [close_in_bit bic] closes the bit input channel [bic].
    @param bic The bit input channel to close. *)
val close_in_bit : bit_in_channel -> unit

(** {3 Writing} *)

(** [open_out_bit filename] opens the file [filename] for writing bits.
    @param filename The name of the file to open.
    @return A bit output channel for writing bits to the file.
    @raise Sys_error if the file cannot be opened. *)
val open_out_bit : string -> bit_out_channel

(** [output_bit boc value] writes the bit [value] (0 or 1) to the bit output channel [boc].
    @param boc The bit output channel.
    @param value The bit to write (must be 0 or 1).
    @raise Invalid_argument if [value] is not 0 or 1. *)
val output_bit : bit_out_channel -> int -> unit

(** [output_8bits boc value] writes the byte [value] (0-255) to the bit output channel [boc].
    @param boc The bit output channel.
    @param value The byte to write (must be between 0 and 255).
    @raise Invalid_argument if [value] is not between 0 and 255. *)
val output_8bits : bit_out_channel -> int -> unit

(** [output_nbits boc nb_bits value] writes the [nb_bits] bits of [value] to the bit output channel [boc].
    @param boc The bit output channel.
    @param nb_bits The number of bits to write.
    @param value The value to write (must fit within [nb_bits]).
    @raise Invalid_argument if [value] is too large to fit within [nb_bits]. *)
val output_nbits : bit_out_channel -> int -> int -> unit

(** [close_out_bit boc] closes the bit output channel [boc], padding the last byte if necessary.
    @param boc The bit output channel to close. *)
val close_out_bit : bit_out_channel -> unit


(** {2 Technical Details} 

     {3 Bit Reading Order}

  Bits in a file are read from the most significant bit to the least significant
bit. This means that if we read a file containing the byte 0x41 followed by the
byte 0x42, the bits will be read in the following order: 01000001 01000010.
This choice allows for consistent and predictable bit reading, facilitating
data interpretation during decompression or bit-by-bit processing.

    {3 Padding Management During Writing}

  When writing bits to a file, padding is used to indicate to the reader how
many bits are "valid" in the last byte of the file. Unused bits, starting from
the least significant bit, are set to 1, and the most significant unused bit is
set to 0. For example, if we write the bits 0, 0, 1, 1 and then close the file,
the resulting byte will be 0x37 (in binary: 00110111). This byte will be
interpreted during reading as containing four valid bits (0011), with the
remaining bits (1s and the 0 break bit) being padding.

  This padding mechanism is essential to allow the reader to distinguish
between valid bits and padding bits, ensuring correct data reading even when
the total number of bits written is not a multiple of 8. Without this
mechanism, it would be impossible to know how many bits in the last byte are
relevant, potentially leading to reading errors and data interpretation issues.

*)


