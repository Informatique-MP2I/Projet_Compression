(** {1 PriorityQueue}
    This module provides une simple implementation of a priority queue using a binary heap. *)

(** {2 Types} *)

(** The type representing a priority queue. *)
type 'a priorityqueue = {
  mutable heap : 'a option array;  (** The array representing the heap. *)
  mutable size : int;       (** The current size of the priority queue. *)
  cmp : 'a -> 'a -> bool;   (** The comparison function for priority. *)
}

(** {2 Constants} *)

(** The initial capacity of the priority queue. *)
let initial_capacity = 10

(** {2 Functions} *)

(** [create cmp] creates a new priority queue with a given comparison function [cmp].
    @param cmp The comparison function to determine priority.
    @return A new priority queue.
*)
let create cmp =
  (* TODO *)
  { heap = [||]; size = 0; cmp }

(** [size pq] returns the current size of the priority queue [pq].
    @param pq The priority queue.
    @return The current size of the priority queue. *)
let size pq =
  (* TODO *)
  0

(** [is_empty pq] checks if the priority queue [pq] is empty.
    @param pq The priority queue to check.
    @return [true] if the priority queue is empty, [false] otherwise. *)
let is_empty pq =
  (* TODO *)
  false

(** [swap pq i j] swaps the elements at indices [i] and [j] in the priority queue [pq].
    @param pq The priority queue.
    @param i The first index.
    @param j The second index. *)
let swap pq i j =
  let temp = pq.heap.(i) in
  pq.heap.(i) <- pq.heap.(j);
  pq.heap.(j) <- temp

(** [insert pq x] inserts the element [x] into the priority queue [pq].
    @param pq The priority queue.
    @param x The element to insert.
    If the heap is full, the array is resized to accommodate more elements.
    The function maintains the heap property by "bubbling up" the new element as needed.
    @raise Failure if there is an unexpected error during insertion. *)
let insert pq x =
  (* TODO *)
  ()

(** [extract_min pq] extracts the minimum element from the priority queue [pq].
    @param pq The priority queue.
    @return The minimum element.
    If the heap is not empty, the root element (minimum) is removed, and the last element in the heap is moved to the root.
    The function maintains the heap property by "bubbling down" the new root element as needed.
    @raise Failure if the priority queue is empty or if there is an unexpected error during extraction. *)
let extract_min pq =
  (* TODO *)
  match pq.heap.(0) with
  | Some s -> s
  | None -> failwith "Error."
  
