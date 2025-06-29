(** bitdump programm.

    - A program to display the contents of a file bit by bit.
    The program includes padding bits in parentheses at the end of the dump.

    {2 Usage}

    To display the contents of a file bit by bit, run the following command:

    {[
      ./bin/bitdump <filename>
    ]}

    {2 Examples}

    To dump the bits of a file `example.bits`:

    {[
      ./bin/bitdump example.bits
    ]}
*)

open BitChannel

(** {2 Functions} *)

(** [dump_bits filename] reads the file [filename] and prints its contents bit by bit.
    The padding bits are displayed in parentheses at the end.
    @param filename The name of the file to dump.
    @raise Sys_error if the file cannot be opened. *)
let dump_bits filename =
  let bit_channel = open_in_bit filename in
  (* Count the total number of bits *)
  let rec count_bits count =
    try
      let _ = input_bit bit_channel in
      count_bits (count + 1)
    with End_of_file -> count
  in
  (* Count the bits first *)
  let total_bits = count_bits 0 in
  close_in_bit bit_channel;
  (* Calculate the number of padding bits *)
  let padding_bits = (8 - (total_bits mod 8)) mod 8 in
  (* Reopen the bit_channel to traverse the bits again *)
  let bit_channel = open_in_bit filename in
  Printf.printf "Filename: %s\n" filename;
  Printf.printf "Total bits: %d\n" total_bits;
  Printf.printf "Padding bits: %d\n" padding_bits;
  (* Print each bit *)
  let rec print_bits i =
    try
      let bit = input_bit bit_channel in
      if i <> 0 && i mod 8 = 0 then Printf.printf " ";
      Printf.printf "%d" bit;
      print_bits (i + 1)
    with End_of_file -> ()
  in
  print_bits 0;
  (* Print padding bits in parentheses *)
  if padding_bits > 0 then (
    Printf.printf " ";
    Printf.printf "(";
    Printf.printf "0";
    for _ = 1 to (padding_bits - 1) do
      Printf.printf "1"
    done;
    Printf.printf ")"
  );
  Printf.printf "\n";
  close_in_bit bit_channel

(** The main function that parses command-line arguments and calls [dump_bits].
    It expects exactly one argument, the filename to dump. *)
let () =
  if Array.length Sys.argv <> 2 then
    Printf.printf "Usage: %s <filename>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    dump_bits filename

(** {2 Technical details} *)

(** The implementation of the bitdump program reads the file bit by bit. The
    padding bits at the end of the file are calculated and displayed in
    parentheses. 

    The main steps of the program are as follows:
    
    - `Initialization`: The bit input channel is opened.
    - `Counting Bits`: The total number of bits in the file is counted.
    - `Calculating Padding Bits`: The number of padding bits is calculated based on the total number of bits.
    - `Printing Bits`: The bits are read from the file and printed one by one.
    - `Displaying Padding Bits`: The padding bits are displayed in parentheses at the end of the output.
    - `Finalization`: The bit input channel is properly closed.
*)

