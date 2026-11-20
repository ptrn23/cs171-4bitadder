From Stdlib Require Import Bool Arith Lia.
From RedstoneAdder Require Import Primitives Adders.

(* 4-bit bus representation === *)
(* b0 is the least significant bit (2^0), b3 is the most significant bit (2^3) *)
Record bits4 : Type := mkBits4 {
  b0 : bool;
  b1 : bool;
  b2 : bool;
  b3 : bool
}.

(* convert a 4-bit redstone bus into its mat hematical integer value *)
Definition bits4_to_nat (x : bits4) : nat :=
  b2n (b0 x) + 2 * b2n (b1 x) + 4 * b2n (b2 x) + 8 * b2n (b3 x).