(** Compresslzw programm.

     - A program to compress files using the Lempel-Ziv-Welch (LZW) algorithm.
    The program implements the LZW compression algorithm and manages command line
    arguments.

    {2 Usage}

    To compress a file using the LZW algorithm, run the following command:

    {[
      ./bin/compresslzw [OPTIONS] <source> <destination>
    ]}

    {2 Options}

    - `-h`, `--help` : Display this help message and exit.

    {2 Examples}

    To compress a file `test.txt` and save the result as `test.txt.lzw`:

    {[
      ./bin/compresslzw misc/test.txt misc/test.txt.lzw
    ]}
*)

open BitChannel
open Hashtbl
open Printexc

(** {2 Functions} *)     

(** [compress_lzw in_channel boc] compresses the data from the input channel
    [in_channel] using the LZW algorithm and writes the compressed data to the
    bit output channel [boc].
    The compression uses fixed 12-bit codes.
    
    @param ic The input binary channel to read from.
    @param boc The bit output channel to write the compressed data to.
    @raise End_of_file if the end of the input channel is reached unexpectedly.
    @raise Sys_error if there is an error with file operations.
    @raise Invalid_argument if a value is out of the expected range.
*)
let compress_lzw (ic : in_channel) (boc : bit_out_channel) : unit =
  (* TODO *)
  ()

(** {2 Technical details} *)

(** The implementation of the LZW compression algorithm reads data from the
    input file byte by byte. Each code written to the output file is 12 bits
    long, which implies a dictionary with a maximum of 4096 entries.

    The dictionary is initialized with the first 256 entries, each
    corresponding to a single byte value (0-255). The buffer is used to store the
    current sequence being processed.

    The main steps of the algorithm are as follows:
    
    - `Initialization`: The dictionary is created and populated with 256
    initial entries.
    - `Reading and Processing`: The algorithm reads the input file byte by
    byte.
    - `Buffer Management`: For each byte read, the current buffer (sequence) is
    checked in the dictionary.
    -- If the sequence is found in the dictionary, the buffer is extended.
    -- If the sequence is not found, the code for the existing sequence
    (without the new byte) is written to the output, and the new sequence is added
    to the dictionary if there is space.
    - `Writing Output`: Each code is written as a 12-bit value to the output
    file.
    - `Finalization`: After reading all input bytes, any remaining sequence in
    the buffer is processed and its code is written to the output.
*)

(** The main program function parses command-line arguments and performs LZW
    compression. *)
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
    if !source_file = "stdin" then stdin else open_in_bin !source_file
  in
  let out_channel : bit_out_channel =
    if !destination_file = "stdout" then open_out_bit "/dev/stdout" else open_out_bit !destination_file
  in
  compress_lzw in_channel out_channel;
  if !source_file <> "stdin" then close_in in_channel;
  if !destination_file <> "stdout" then close_out_bit out_channel


