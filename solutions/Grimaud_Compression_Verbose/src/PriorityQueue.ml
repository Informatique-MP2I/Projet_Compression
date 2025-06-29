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
  { heap = Array.make initial_capacity None; size = 0; cmp }

(** [size pq] returns the current size of the priority queue [pq].
    @param pq The priority queue.
    @return The current size of the priority queue. *)
let size pq =
  pq.size

(** [is_empty pq] checks if the priority queue [pq] is empty.
    @param pq The priority queue to check.
    @return [true] if the priority queue is empty, [false] otherwise. *)
let is_empty pq =
  pq.size = 0

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
  let rec aux i =
    if i > 0 then
      let parent = (i - 1) / 2 in
      match pq.heap.(i), pq.heap.(parent) with
      | Some i_val, Some p_val ->
        if pq.cmp i_val p_val then (
          swap pq i parent;
          aux parent
        )
      | _ -> failwith "Unexpected priority heap error during insertion..."
  in
  if pq.size = Array.length pq.heap then
    pq.heap <- Array.append pq.heap (Array.make (Array.length pq.heap) None);
  pq.heap.(pq.size) <- Some x;
  aux pq.size;
  pq.size <- pq.size + 1

(** [extract_min pq] extracts the minimum element from the priority queue [pq].
    @param pq The priority queue.
    @return The minimum element.
    If the heap is not empty, the root element (minimum) is removed, and the last element in the heap is moved to the root.
    The function maintains the heap property by "bubbling down" the new root element as needed.
    @raise Failure if the priority queue is empty or if there is an unexpected error during extraction. *)
let extract_min pq =
  let rec aux i =
    let left = 2 * i + 1 in
    let right = 2 * i + 2 in
    let smallest = ref i in
    if left < pq.size then (
      match pq.heap.(left), pq.heap.(!smallest) with
      | Some left_val, Some smallest_val -> 
        if pq.cmp left_val smallest_val then
          smallest := left 
      | _ -> failwith "Unexpected priority heap error during extraction..."
    ) ;
    if right < pq.size then (
      match pq.heap.(right), pq.heap.(!smallest) with
      | Some right_val, Some smallest_val -> 
        if pq.cmp right_val smallest_val then
          smallest := right
      | _ -> failwith "Unexpected priority heap error during extraction..." 
    ) ; 
    if !smallest <> i then (
      swap pq i !smallest;
      aux !smallest
    )
  in
  if pq.size = 0 then failwith "PriorityQueue is empty";
  let min = pq.heap.(0) in
  pq.size <- pq.size - 1;
  pq.heap.(0) <- pq.heap.(pq.size);
  pq.heap.(pq.size) <- None;
  aux 0;
  match min with
  | None -> failwith "Unexpected priority heap error during extraction..."
  | Some min -> min
