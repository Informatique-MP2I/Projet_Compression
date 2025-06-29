(** decompresslzw programm. 

    A program to decompress files using the Lempel-Ziv-Welch (LZW) algorithm.
    The program handles files compressed using the LZW algorithm and manages command line arguments.

    {2 Usage}

    To decompress a file using the LZW algorithm, run the following command:

    {[
      ./bin/decompresslzw [OPTIONS] <source> <destination>
    ]}

    {2 Options}
    
    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To decompress a file `test.txt.lzw` and save the result as `test.txt`:

    {[
      ./bin/decompresslzw examples/test.txt.lzw examples/test.txt
    ]}
*)

open Sys
open BitChannel

(** {2 Functions} *)

(** [decompress_lzw bic out_channel] decompresses the input from [bic]
    using the LZW algorithm and writes the output to [out_channel].
    
    @param bic The bit input channel to read from.
    @param oc The output channel to write to.
    @raise End_of_file if the end of the input channel is reached unexpectedly.
    @raise Sys_error if there is an error with file operations.
    @raise Invalid_argument if a value is out of the expected range.
*)
let decompress_lzw (bic : bit_in_channel) (oc : out_channel) : unit =
  let initial_dictionary_size = 256 in
  let max_dictionary_size = 4096 in
  let dictionary = Array.make max_dictionary_size [||] in
  for i = 0 to (initial_dictionary_size-1) do
    dictionary.(i) <- [|i|]
  done;
  let next_code = ref initial_dictionary_size in
  let read_code () =
    try
      Some (input_nbits bic 12)
    with End_of_file -> None
  in
  let write_bytes bytes =
    Array.iter (output_byte oc) bytes
  in
  let rec process_code prev_code =
    match read_code() with
    | None -> ()
    | Some curr_code ->
      let bytes =
        if curr_code < !next_code then 
          dictionary.(curr_code)
        else if curr_code = !next_code then
          Array.append dictionary.(prev_code) [|dictionary.(prev_code).(0)|]
        else failwith "Invalid LZW code.\n"
      in
      write_bytes bytes;
      if !next_code < max_dictionary_size then (
        dictionary.(!next_code) <- Array.append dictionary.(prev_code) [|bytes.(0)|];
        incr next_code
      );
      process_code curr_code
  in
  let rec decompress () =
    match read_code () with
    | None -> ()
    | Some first_code ->
      if first_code >= initial_dictionary_size then
        failwith "Invalid LZW code.\n"
      else
        (write_bytes dictionary.(first_code);
         process_code first_code)
  in
  decompress ()
    

(** {2 Technical details} *)
 
(** The implementation of the LZW decompression algorithm reads data from the
    input file bit by bit. Each code read from the input file is 12 bits long,
which implies a dictionary with a maximum of 4096 entries.

    The dictionary is initialized with the first 256 entries, each
corresponding to a single byte value (0-255). The dictionary is then used to
rebuild sequences from the codes read from the input file.

    The main steps of the algorithm are as follows:
    
    - `Initialization`: The dictionary is created and populated with 256
    initial entries.  
    - `Reading and Processing`: The algorithm reads 12-bit codes
    from the input file.  
    - `Dictionary Management`: For each code read: 
    -- If the code is already in the dictionary, the corresponding sequence is 
    output.  
    -- If the code is not in the dictionary, it must be the next code to be 
    added, and a special handling is done to form the new sequence.  
    - `Writing Output`: Each sequence is written to the output file as bytes.  
    - `Finalization`: After reading all input codes, the output file is closed
    properly.
*)

(** The main program function parses command-line arguments and performs LZW decompression. *)
let () =
  let source_file = ref "" in
  let destination_file = ref "" in

  let args = [
    ("-h", Arg.Unit (fun () ->
        Printf.printf "Usage: %s [OPTIONS] <input file name> <output file name>\n" Sys.argv.(0);
        Printf.printf "Options:\n";
        Printf.printf "  -h, --help     Display this help message and exit.\n";
        exit 0), "Display this help message and exit");
    ("--help", Arg.Unit (fun () ->
        Printf.printf "Usage: %s [OPTIONS] <input file name> <output file name>\n" Sys.argv.(0);
        Printf.printf "Options:\n";
        Printf.printf "  -h, --help     Display this help message and exit.\n";
        exit 0), "Display this help message and exit")
  ] in
  let set_files filename =
    if !source_file = "" then
      source_file := filename
    else
      destination_file := filename
  in
  Arg.parse args set_files "Use -h or --help for help.";
  if !source_file = "" || !destination_file = "" then (
    Printf.eprintf "Usage: %s <input file name> <output file name>\n" Sys.argv.(0);
    exit 1
  );
  let in_channel =
    if !source_file = "stdin" then open_in_bit "/dev/stdin" else open_in_bit !source_file
  in
  let out_channel =
    if !destination_file = "stdout" then stdout else open_out_bin !destination_file
  in
  decompress_lzw in_channel out_channel;
  if !source_file <> "stdin" then close_in_bit in_channel;
  if !destination_file <> "stdout" then close_out out_channel

