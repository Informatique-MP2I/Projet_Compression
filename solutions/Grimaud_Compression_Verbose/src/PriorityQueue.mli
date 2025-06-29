(** {1 PriorityQueue} implemented with a binary heap.
    
    {2 Usage example}

    Here is a simple example showing how to use the PriorityQueue module:

    {[
      open PriorityQueue

      (* Comparison function for integers *)
      let compare x y = x < y

      (* Creating a priority queue with initial comparison function *)
      let pq = create compare

      (* Inserting elements into the priority queue *)
      let () =
        insert pq 5;
        insert pq 3;
        insert pq 9

      (* Extracting the minimum element from the priority queue *)
      let min_element = extract_min pq
      (* min_element should be 3 *)

      (* Checking if the priority queue is empty *)
      let is_empty = is_empty pq
      (* is_empty should be false *)

      (* Getting the current size of the priority queue *)
      let current_size = size pq
      (* current_size should be 2 *)
    ]}
*)

(** {2 Types}
*)

    (** The type representing a priority queue. *)
    type 'a priorityqueue

(** {2 Functions} *)

(** [create cmp] creates a new priority queue with a given comparison function [cmp].
    @param cmp The comparison function to determine priority.
    @return A new priority queue.
    @raise Invalid_argument if [initial_capacity] is less than or equal to zero. *)
val create : ('a -> 'a -> bool) -> 'a priorityqueue

(** [size pq] returns the current size of the priority queue [pq].
    @param pq The priority queue.
    @return The current size of the priority queue. *)
val size : 'a priorityqueue -> int
  
(** [is_empty pq] checks if the priority queue [pq] is empty.
    @param pq The priority queue to check.
    @return [true] if the priority queue is empty, [false] otherwise. *)
val is_empty : 'a priorityqueue -> bool

(** [insert pq x] inserts the element [x] into the priority queue [pq].
    @param pq The priority queue.
    @param x The element to insert. *)
val insert : 'a priorityqueue -> 'a -> unit

(** [extract_min pq] extracts the minimum element from the priority queue [pq].
    @param pq The priority queue.
    @return The minimum element.
    @raise Failure if the priority queue is empty. *)
val extract_min : 'a priorityqueue -> 'a

(** {2 Technical Details}

    {3 Implementation}

    The priority queue is implemented using a binary heap, which is an
efficient structure for maintaining the order of elements. The binary heap is
represented as an array, where the parent of the element at index `i` is at
index `(i - 1) / 2`, and the children of the element at index `i` are at
indices `2 * i + 1` and `2 * i + 2`.

    {3 Operations}

    - `Insertion`: When inserting an element, it is added at the end of the
array, and then the heap property is restored by "bubbling up" the element to
its correct position.
    - `Extraction`: When extracting the minimum element, the root element (at
index 0) is removed, and the last element in the array is moved to the root
position. The heap property is then restored by "bubbling down" the element to
its correct position.
    - `Size`: The current size of the priority queue is maintained and updated
during insertions and extractions.
*)

