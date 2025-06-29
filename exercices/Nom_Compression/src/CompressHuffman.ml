(** compresshuffman programm.

    A program to compress files using the Huffman algorithm.
    The program processes files byte by byte in binary mode and serializes the
    Huffman tree compactly at the beginning of the compressed file.

    {2 Usage}

    To compress a file using the Huffman algorithm, run the following command:

    {[
      ./bin/compresshuffman [OPTIONS] <source> <destination>
    ]}

    {2 Options}

    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To compress a file `test.txt` and save the result as `test.txt.huffman`:

    {[
      ./bin/compresshuffman misc/test.txt misc/test.txt.huffman
    ]}
*)

open PriorityQueue
open BitChannel

(** {2 Types} *)

(** The type representing a Huffman tree. *)
type huffman_tree =
  | Leaf of int * int  (** Leaf node with (byte, occurrence) *)
  | Node of int * huffman_tree * huffman_tree  (** Internal node with (occurrence, left subtree, right subtree) *)

(** {2 Functions} *)

(** [count_bytes filename] counts the occurrences of each byte in the file [filename].
    @param filename The name of the file to count bytes from.
    @return An array of 256 integers representing the occurrence of each byte (0-255).
    @raise Sys_error if the file cannot be opened. *)
let count_bytes filename =
  (* TODO *)
  [||]

(** [build_huffman_tree occurrences] builds a Huffman tree from byte occurrences.
    @param occurrences An array of byte occurrences.
    @return The Huffman tree.
    @raise Failure if the priority queue is empty. *)
let build_huffman_tree occurrences =
  (* TODO *)
  Leaf (0,0)

(** [build_huffman_codes tree] generates Huffman codes from the Huffman tree.
    @param tree The Huffman tree.
    @return An array of Huffman codes, where each code is an array of bits (0 or 1). *)
let build_huffman_codes tree =
  (* TODO *)
  [||]

(** [output_tree boc htree] serializes the Huffman tree [htree] to the
    bit output channel [boc].
    @param boc The bit output channel.
    @param htree The Huffman tree to serialize. *)
let rec output_tree boc htree =
  match htree with
  | Leaf (byte, _) ->
      output_bit boc 1;
      output_8bits boc byte
  | Node (_, left, right) ->
      output_bit boc 0;
      output_tree boc left ;
      output_tree boc right

(** [encode_file infile outfile htree codes] compresses the file
    [infile] using Huffman coding and writes the result to [outfile].
    @param infile The input file to compress.
    @param outfile The output file to write the compressed data.
    @param htree The Huffman tree used for encoding.
    @param codes The Huffman codes derived from the tree.
    @raise Sys_error if the input or output files cannot be opened. *)
let encode_file infile outfile htree codes =
  (* TODO *)
  ()

(** [usage ()] prints the usage message for the program and exits. *)
let usage () =
  Printf.printf "Usage: %s [OPTIONS] <source> <destination>\n" Sys.argv.(0);
  Printf.printf "Options:\n";
  Printf.printf "  -h, --help     Display this help message and exit.\n";
  Printf.printf "\nExamples:\n";
  Printf.printf "  %s \"misc/Les misérables.txt\" \"misc/Les misérables.txt.huffman\"\n" Sys.argv.(0);
  exit 0

(** The main program function parses command-line arguments and performs Huffman compression. *)
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
  let occurrences = count_bytes !source_file in
  let tree = build_huffman_tree occurrences in
  let codes = build_huffman_codes tree in
  encode_file !source_file !destination_file tree codes 

(** {2 Technical details} *)

(** The implementation of the Huffman compression algorithm processes files byte by byte in binary mode. The Huffman tree is serialized compactly at the beginning of the compressed file.

    The main steps of the algorithm are as follows:
    
    - `Initialization`: The occurrences of each byte in the file are counted.
    - `Building the Huffman Tree`: A priority queue is used to construct the Huffman tree from the byte occurrences. 
    - `Generating Huffman Codes`: The Huffman codes are generated from the Huffman tree. 
    - `Serialization`: The Huffman tree is serialized to the output file.
    - `Compression`: The input file is read byte by byte, and the corresponding Huffman code is written to the output file.
    - `Finalization`: After reading all input bytes, the output file is properly closed.

    This approach ensures efficient compression by using variable-length codes based on the occurrence of each byte in the input file.
*)

