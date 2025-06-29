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

    - `-v`, `--verbose` : Display detailed information during compression.
    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To compress a file `test.txt` and save the result as `test.txt.huffman`:

    {[
      ./bin/compresshuffman misc/test.txt misc/test.txt.huffman
    ]}

    To compress a file with verbose output:

    {[
      ./bin/compresshuffman -v misc/test.txt misc/test.txt.huffman
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
  let occurrences = Array.make 256 0 in
  let input_channel = open_in_bin filename in
  try
    while true do
      let byte = input_byte input_channel in
      occurrences.(byte) <- occurrences.(byte) + 1
    done;
    occurrences
  with
  | End_of_file ->
      close_in input_channel;
      occurrences
  | e ->
      close_in_noerr input_channel;
      raise e

(** [build_huffman_tree occurrences] builds a Huffman tree from byte occurrences.
    @param occurrences An array of byte occurrences.
    @return The Huffman tree.
    @raise Failure if the priority queue is empty. *)
let build_huffman_tree occurrences =
  let cmp = fun a b -> 
    match a, b with 
    | Leaf(_, occ1), Leaf(_, occ2) 
    | Leaf(_, occ1), Node(occ2, _, _) 
    | Node(occ1, _, _), Leaf(_, occ2) 
    | Node(occ1, _, _), Node(occ2, _, _) -> occ1 < occ2
  in
  let pq = PriorityQueue.create cmp in
  Array.iteri (fun byte occ ->
    if occ > 0 then
      PriorityQueue.insert pq (Leaf (byte, occ))
  ) occurrences;
  while size pq > 1 do
    let min1 = PriorityQueue.extract_min pq in
    let min2 = PriorityQueue.extract_min pq in
    match (min1, min2) with
    | (Leaf(_,occ1),Leaf(_,occ2)) | (Leaf(_,occ1),Node(occ2,_,_)) | (Node(occ1,_,_),Leaf(_,occ2)) | (Node(occ1,_,_),Node(occ2,_,_)) ->
        let new_node = Node (occ1 + occ2, min1, min2) in
        PriorityQueue.insert pq new_node
  done;
  if not (PriorityQueue.is_empty pq) then
    PriorityQueue.extract_min pq
  else
    failwith "PriorityQueue is empty"

(** [build_huffman_codes tree] generates Huffman codes from the Huffman tree.
    @param tree The Huffman tree.
    @return An array of Huffman codes, where each code is an array of bits (0 or 1). *)
let build_huffman_codes tree =
  let rec gen_codes subtree prefix codes str =
    match subtree with
    | Leaf (byte, _) ->
      codes.(byte) <- Array.of_list (List.rev prefix)
    | Node (_, left, right) ->
      gen_codes left (0 :: prefix) codes (str ^ "0") ;
      gen_codes right (1 :: prefix) codes (str ^ "1")
  in
  let codes = Array.make 256 [||] in
  gen_codes tree [] codes "";
  codes

(** [output_tree boc htree verbose] serializes the Huffman tree [htree] to the
    bit output channel [boc].
    @param boc The bit output channel.
    @param htree The Huffman tree to serialize.
    @param verbose If true, print the serialized tree structure. *)
let rec output_tree boc htree verbose =
  match htree with
  | Leaf (byte, _) ->
      if verbose then Printf.printf "1[0x%02x]" byte ;
      output_bit boc 1;
      output_8bits boc byte
  | Node (_, left, right) ->
      if verbose then Printf.printf "0" ;
      output_bit boc 0;
      output_tree boc left verbose ;
      output_tree boc right verbose

(** [encode_file infile outfile htree codes verbose] compresses the file
    [infile] using Huffman coding and writes the result to [outfile].
    @param infile The input file to compress.
    @param outfile The output file to write the compressed data.
    @param htree The Huffman tree used for encoding.
    @param codes The Huffman codes derived from the tree.
    @param verbose If true, print detailed information during compression.
    @raise Sys_error if the input or output files cannot be opened. *)
let encode_file infile outfile htree codes verbose =
  if verbose then Printf.printf "---=== Encoded file ===---\n" ;
  let input_channel = open_in_bin infile in
  let output_channel = open_out_bit outfile in
  try
    if verbose then Printf.printf " -- encoded tree\n" ;
    output_tree output_channel htree verbose ;
    if verbose then Printf.printf "\n -- encoded content\n" ;
    while true do
      let byte = input_byte input_channel in
      Array.iter (output_bit output_channel) codes.(byte) ;
      if verbose then begin
        Array.iter (Printf.printf "%d") codes.(byte) ;
        Printf.printf " "
      end
    done
  with
  | End_of_file ->
      close_in input_channel;
      close_out_bit output_channel;
      if verbose then Printf.printf "\nFile '%s' successfully compressed to '%s'.\n" infile outfile
  | e ->
      close_in_noerr input_channel;
      close_out_bit output_channel;
      raise e

(** [usage ()] prints the usage message for the program and exits. *)
let usage () =
  Printf.printf "Usage: %s [OPTIONS] <source> <destination>\n" Sys.argv.(0);
  Printf.printf "Options:\n";
  Printf.printf "  -v, --verbose  Display detailed information during compression.\n";
  Printf.printf "  -h, --help     Display this help message and exit.\n";
  Printf.printf "\nExamples:\n";
  Printf.printf "  %s \"misc/Les misérables.txt\" \"misc/Les misérables.txt.huffman\"\n" Sys.argv.(0);
  Printf.printf "  %s -v misc/test.txt misc/test.txt.huffman\n" Sys.argv.(0);
  exit 0

(** [print_occurrences occurrences] prints the occurrences of each byte.
    @param occurrences An array of byte occurrences. *)
let print_occurrences occurrences =
  Printf.printf "---=== Occurrences table ===---\n" ;
  Array.iteri (fun byte occ ->
    if occ > 0 then
      let ascii_repr = if byte >= 32 && byte <= 126 then Printf.sprintf " '%c'" (char_of_int byte) else "  - " in
      Printf.printf "Decimal: %d, Hexadecimal: 0x%02X, ASCII:%s, Occurrences: %d\n"
        byte byte ascii_repr occ
  ) occurrences

(** [print_huffman_tree tree] prints the Huffman tree.
    @param tree The Huffman tree to print. *)
let print_huffman_tree tree =
  Printf.printf "---=== Resulting Huffman tree ===---\n" ;
  let rec aux indent tree =
    match tree with
    | Leaf (byte, occ) ->
        let ascii_repr = if byte >= 32 && byte <= 126 then Printf.sprintf " '%c'" (char_of_int byte) else "" in
        Printf.printf "%sLeaf: byte = %d, occ = %d%s\n" indent byte occ ascii_repr
    | Node (occ, left, right) ->
        Printf.printf "%sNode: occ = %d\n" indent occ;
        aux (indent ^ "  ") left;
        aux (indent ^ "  ") right
  in
  aux "" tree

(** [print_huffman_codes codes] prints the Huffman codes.
    @param codes An array of Huffman codes. *)
let print_huffman_codes codes =
  Printf.printf "---=== Final Huffman codes ===---\n" ;
  Array.iteri (fun byte code ->
    if Array.length code > 0 then
      let ascii_repr = if byte >= 32 && byte <= 126 then Printf.sprintf " '%c'" (char_of_int byte) else "" in
      let binary_code = String.concat "" (List.map string_of_int (Array.to_list code)) in
      Printf.printf "Byte: %d, ASCII:%s, Code: %s\n" byte ascii_repr binary_code
  ) codes

(** The main program function parses command-line arguments and performs Huffman compression. *)
let () =
  let verbose = ref false in
  let source_file = ref "" in
  let destination_file = ref "" in
  let args = [
    ("-v", Arg.Set verbose, "Display detailed information during compression");
    ("--verbose", Arg.Set verbose, "Display detailed information during compression");
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
  if !verbose then print_occurrences occurrences ;
  let tree = build_huffman_tree occurrences in
  if !verbose then print_huffman_tree tree ;
  let codes = build_huffman_codes tree in
  if !verbose then print_huffman_codes codes ;
  encode_file !source_file !destination_file tree codes !verbose

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

