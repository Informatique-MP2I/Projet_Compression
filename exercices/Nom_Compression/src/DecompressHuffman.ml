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

    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To decompress a file `test.txt.huffman` and save the result as `test.txt`:

    {[
      ./bin/decompresshuffman misc/test.txt.huffman misc/test.txt
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
  (* TODO *)
  Leaf (0,0)

(** [read_huffman_code bic htree] reads a Huffman-encoded code from the
    bit input channel [bic] and returns the corresponding byte.
    @param bic The bit input channel.
    @param htree The Huffman tree used for decoding.
    @return The decoded byte. *)
let rec read_huffman_code bic htree =
  (* TODO *)
  0
  
(** [decode_file infile outfile] decompresses the file [infile] using the Huffman tree embedded in the file and writes the result to [outfile].
    
    @param infile The name of the input file containing the compressed data.
    @param outfile The name of the output file where the decompressed data will be written.
    @raise Sys_error if the input or output files cannot be opened.
    @raise End_of_file when the end of the input file is reached.
*)
let decode_file infile outfile =
  (* TODO *)
  ()
      
(** [usage ()] prints the usage message for the program and exits. *)
let usage () =
  Printf.printf "Usage: %s [OPTIONS] <source> <destination>\n" Sys.argv.(0);
  Printf.printf "Options:\n";
  Printf.printf "  -h, --help     Display this help message and exit.\n";
  Printf.printf "\nExamples:\n";
  Printf.printf "  %s misc/test.txt.huffman tmp.txt\n" Sys.argv.(0);
  exit 0

(** The main program function parses command-line arguments and performs Huffman decompression. *)
let () =
  let source_file = ref "" in
  let destination_file = ref "" in
  let args = [
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
  decode_file !source_file !destination_file

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

