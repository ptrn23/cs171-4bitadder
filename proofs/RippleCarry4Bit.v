From Stdlib Require Import Bool Arith Lia.
From RedstoneAdder Require Import Primitives Adders.

(* 4-bit bus representation *)
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

(* 4-bit ripple carry adder *)
(* cascades four full adders, first carry-in is grounded to false (0) *)
Definition ripple_carry_adder_4bit (a b : bits4) : bits4 * bool :=
  let '(s0, c1)   := full_adder (b0 a) (b0 b) false in
  let '(s1, c2)   := full_adder (b1 a) (b1 b) c1 in
  let '(s2, c3)   := full_adder (b2 a) (b2 b) c2 in
  let '(s3, cout) := full_adder (b3 a) (b3 b) c3 in
  (mkBits4 s0 s1 s2 s3, cout).

(* arithmetic correctness *)
(* for any 4-bit inputs A and B, Sum + 16*Cout = A + B *)
Theorem adder_4bit_correct : forall a b : bits4,
  let '(sum, cout) := ripple_carry_adder_4bit a b in
  bits4_to_nat sum + 16 * b2n cout = bits4_to_nat a + bits4_to_nat b.
Proof.
  intros a b.
  unfold ripple_carry_adder_4bit, bits4_to_nat.
  pose proof (full_adder_correct (b0 a) (b0 b) false) as H0.
  destruct (full_adder (b0 a) (b0 b) false) as [s0 c1].
  pose proof (full_adder_correct (b1 a) (b1 b) c1) as H1.
  destruct (full_adder (b1 a) (b1 b) c1) as [s1 c2].
  pose proof (full_adder_correct (b2 a) (b2 b) c2) as H2.
  destruct (full_adder (b2 a) (b2 b) c2) as [s2 c3].
  pose proof (full_adder_correct (b3 a) (b3 b) c3) as H3.
  destruct (full_adder (b3 a) (b3 b) c3) as [s3 cout].
  simpl in *.
  lia.
Qed.
