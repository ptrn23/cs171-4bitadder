From Stdlib Require Import Bool.

(* a redstone torch inverts its input signal (NOT) *)
Definition redstone_torch (a : bool) : bool :=
  negb a.

(* joining two redstone dust lines outputs ON if either is ON (OR) *)
Definition redstone_dust_join (a b : bool) : bool :=
  orb a b.

(* classic minecraft AND gate: NOT( (NOT a) OR (NOT b) ) *)
Definition redstone_and (a b : bool) : bool :=
  redstone_torch (redstone_dust_join (redstone_torch a) (redstone_torch b)).

(* redstone XOR gate: (a AND NOT b) OR (NOT a AND b) *)
Definition redstone_xor (a b : bool) : bool :=
  redstone_dust_join
    (redstone_and a (redstone_torch b))
    (redstone_and (redstone_torch a) b).

(* two torches in series cancel out *)
Lemma double_torch_cancel : forall a : bool,
  redstone_torch (redstone_torch a) = a.
Proof.
  intros a.
  destruct a; reflexivity.
Qed.

(* prove the physical AND gate matches standard boolean AND *)
Theorem redstone_and_equiv : forall a b : bool,
  redstone_and a b = andb a b.
Proof.
  intros a b.
  destruct a, b.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
Qed.

(* prove the physical XOR gate matches standard boolean XOR *)
Theorem redstone_xor_equiv : forall a b : bool,
  redstone_xor a b = xorb a b.
Proof.
  intros a b.
  destruct a, b.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
Qed.