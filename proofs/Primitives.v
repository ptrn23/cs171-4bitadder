Require Import Bool.

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