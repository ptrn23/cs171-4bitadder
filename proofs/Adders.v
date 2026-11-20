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

(* two half adders + one redstone dust join (OR) for the carries *)
Definition full_adder (a b cin : bool) : bool * bool :=
  let '(s1, c1) := half_adder a b in
  let '(sum, c2) := half_adder s1 cin in
  (sum, redstone_dust_join c1 c2).

Theorem full_adder_correct : forall a b cin : bool,
  let '(sum, cout) := full_adder a b cin in
  b2n sum + 2 * b2n cout = b2n a + b2n b + b2n cin.
Proof.
  intros a b cin.
  destruct a, b, cin.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
Qed.