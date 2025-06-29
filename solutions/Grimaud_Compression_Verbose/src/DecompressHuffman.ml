(** decompresshuffman programm.

    A program to decompress files using the Huffman algorithm.
    The program handles files compressed using the Huffman coding algorithm and
    manages command line arguments.

    {2 Usage}

    To decompress a file using the Huffman algorithm, run the following command:

    {[
      ./bin/decompresshuffman [OPTIONS] <source> <destination>
    ]}

    {2 Options}

    - `-v`, `--verbose` : Display detailed information during decompression.
    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To decompress a file `test.txt.huffman` and save the result as `test.txt`:

    {[
      ./bin/decompresshuffman misc/test.txt.huffman misc/test.txt
    ]}

    To decompress a file with verbose output:

    {[
      ./bin/decompresshuffman -v misc/test.txt.huffman misc/test.txt
    ]}
*)

open BitChannel

(** {2 Types} *)

(** The type representing a Huffman tree. *)
type huffman_tree =
  | Leaf of int * int  (** Leaf node with (byte, occurrence) *)
  | Node of int * huffman_tree * huffman_tree  (** Internal node with (occurrence, left subtree, right subtree) *)

(** {2 Functions} *)

(** [input_tree bic] deserializes a Huffman tree from the bit input channel [bic].
    @param bic The bit input channel.
    @return The Huffman tree.
    @raise Failure if an invalid bit is encountered during deserialization. *)
let rec input_tree bic =
  let occurrence = 0 in (* occurrence not needed here, default value *)
  match input_bit bic with
  | 1 ->
      let byte = input_8bits bic in
      Leaf (byte, occurrence)
  | 0 ->
      let left = input_tree bic in
      let right = input_tree bic in
      Node (occurrence, left, right)
  | _ -> failwith "Invalid bit in input_tree"

(** [print_huffman_tree tree] prints the structure of the Huffman tree [tree].
    @param tree The Huffman tree to print. *)
let rec print_huffman_tree tree =
  match tree with
  | Leaf (byte, _) ->
      Printf.printf "Leaf (byte: 0x%02x)\n" byte
  | Node (_, left, right) ->
      Printf.printf "Node\n";
      Printf.printf " Left: ";
      print_huffman_tree left;
      Printf.printf " Right: ";
      print_huffman_tree right

(** [read_huffman_code bic htree verbose] reads a Huffman-encoded code from the
    bit input channel [bic] and returns the corresponding byte.
    @param bic The bit input channel.
    @param htree The Huffman tree used for decoding.
    @param verbose If true, print the traversal path of the Huffman tree.
    @return The decoded byte. *)
let rec read_huffman_code bic htree verbose =
  match htree with
  | Leaf (byte, _) -> 
      if verbose then Printf.printf " -> 0x%02x\n" byte ; 
      byte
  | Node (_, left, right) ->
      let bit = input_bit bic in
      if verbose then Printf.printf "%d" bit ;
      if bit = 0 then
        read_huffman_code bic left verbose
      else
        read_huffman_code bic right verbose
  
(** [decode_file infile outfile verbose] decompresses the file [infile] using the Huffman tree embedded in the file and writes the result to [outfile].
    
    @param infile The name of the input file containing the compressed data.
    @param outfile The name of the output file where the decompressed data will be written.
    @param verbose If true, displays detailed information about the decoding process, including the 
                   traversal of the Huffman tree and other debug messages.
    @raise Sys_error if the input or output files cannot be opened.
    @raise End_of_file when the end of the input file is reached.
*)
let decode_file infile outfile verbose =
  if verbose then Printf.printf "---=== Reading Huffman encoded bytes from file ===---\n";
  let input_channel = open_in_bit infile in
    let output_channel = open_out_bin outfile in
  try
    let huffman_tree = input_tree input_channel in
    if verbose then
      begin
        Printf.printf "---=== Reading Huffman Tree from file ===---\n";
        print_huffman_tree huffman_tree;
        Printf.printf "---=== Reading Huffman encoded bytes from file ===---\n"
      end;
    while true do
      let byte = read_huffman_code input_channel huffman_tree verbose in
      output_byte output_channel byte
    done
  with
  | End_of_file ->
    close_in_bit input_channel;
    close_out output_channel
  | e ->
    close_in_bit input_channel;
    close_out output_channel;
    raise e
      
(** [usage ()] prints the usage message for the program and exits. *)
let usage () =
  Printf.printf "Usage: %s [OPTIONS] <source> <destination>\n" Sys.argv.(0);
  Printf.printf "Options:\n";
  Printf.printf "  -v, --verbose  Display detailed information during decompression.\n";
  Printf.printf "  -h, --help     Display this help message and exit.\n";
  Printf.printf "\nExamples:\n";
  Printf.printf "  %s misc/test.txt.huffman tmp.txt\n" Sys.argv.(0);
  Printf.printf "  %s -v misc/test.txt.huffman tmp.txt\n" Sys.argv.(0);
  exit 0

(** The main program function parses command-line arguments and performs Huffman decompression. *)
let () =
  let verbose = ref false in
  let source_file = ref "" in
  let destination_file = ref "" in
  let args = [
    ("-v", Arg.Set verbose, "Display detailed information during decompression");
    ("--verbose", Arg.Set verbose, "Display detailed information during decompression");
    ("-h", Arg.Unit usage, "Display this help message and exit");
    ("--help", Arg.Unit usage, "Display this help message and exit")
  ] in
  let set_files filename =
    if !source_file = "" then
      source_file := filename
    else
      destination_file := filename
  in
  Arg.parse args set_files "Use -h or --help for help.";
  if !source_file = "" || !destination_file = "" then usage ();
  decode_file !source_file !destination_file !verbose;
  if !verbose then
    Printf.printf "Decompression complete: '%s' -> '%s'\n" !source_file !destination_file

(** {2 Technical details} *)

(** The implementation of the Huffman decompression algorithm processes files
    bit by bit in binary mode. The Huffman tree is deserialized from the
    beginning of the compressed file.

    The main steps of the algorithm are as follows:
    
    - `Initialization`: The Huffman tree is read from the bit input channel.
    - `Reading and Decoding`: The algorithm reads Huffman-encoded bits from the
       input file and traverses the Huffman tree to decode the bytes.
    - `Writing Output`: Each decoded byte is written to the output file.
    - `Finalization`: After reading all input bits, the output file is properly
       closed.

    This approach ensures efficient decompression by using the Huffman tree to
map variable-length codes back to the original bytes in the input file.
*)

