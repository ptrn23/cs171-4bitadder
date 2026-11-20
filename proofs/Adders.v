From Stdlib Require Import Bool Arith.
From RedstoneAdder Require Import Primitives.

(* convert a boolean redstone signal into 0 or 1 *)
Definition b2n (b : bool) : nat :=
  if b then 1 else 0.

(* half adder *)
(* returns a pair: (sum, carry) *)
Definition half_adder (a b : bool) : bool * bool :=
  (redstone_xor a b, redstone_and a b).

Theorem half_adder_correct : forall a b : bool,
  let '(sum, carry) := half_adder a b in
  b2n sum + 2 * b2n carry = b2n a + b2n b.
Proof.
  intros a b.
  destruct a, b.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
Qed.

