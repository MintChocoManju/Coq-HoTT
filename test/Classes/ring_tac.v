From HoTT Require Import
  Classes.interfaces.abstract_algebra
  Classes.implementations.peano_naturals
  Classes.orders.sum
  Classes.tactics.ring_tac
  Classes.tactics.ring_quote.

Import Quoting.Instances.
Generalizable Variables R.

Lemma test1 `{IsSemiCRing R}
  : forall x y : R, x + (y * x) = x * (y + 1).
Proof.
intros.
ring_with_nat.
Qed.

Require Import
  HoTT.Classes.interfaces.naturals.

Lemma test2 `{IsSemiCRing R}
  : forall x y : R, x + (y * x) = x * (y + 1).
Proof.
intros.
apply (by_quoting (naturals_to_semiring nat R)).
compute. reflexivity.
Qed.

Lemma test3 `{IsSemiCRing R}
  (pa pb pc : R) :
  pa * (pb * pc)
= pa * pb * pc.
Proof.
intros.
apply (by_quoting (naturals_to_semiring nat R)). compute.
reflexivity.
Qed.

Lemma test4 `{IsSemiCRing R}
  (a b : R)
  : a * b = b * a.
Proof.
apply (ring_quote.Quoting.eval_eqquote R).
apply (prove_prequoted (naturals_to_semiring nat R)).
reflexivity.
Qed.

Lemma test5 : forall x y : nat, x + (y * x) = x * (y + 1).
Proof.
intros;ring_with_nat.
Qed.

