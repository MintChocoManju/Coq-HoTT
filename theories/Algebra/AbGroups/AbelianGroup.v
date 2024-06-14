Require Import Basics Types.
Require Import Spaces.Nat.Core Spaces.Int.
Require Export Classes.interfaces.canonical_names (Zero, zero, Plus).
Require Export Classes.interfaces.abstract_algebra (IsAbGroup(..), abgroup_group, abgroup_commutative).
Require Export Algebra.Groups.Group.
Require Export Algebra.Groups.Subgroup.
Require Import Algebra.Groups.QuotientGroup.
Require Import WildCat.

Local Set Polymorphic Inductive Cumulativity.

Local Open Scope mc_scope.
Local Open Scope mc_add_scope.

(** * Abelian groups *)

(** Definition of an abelian group *)

Record AbGroup := {
  abgroup_group : Group;
  abgroup_commutative : Commutative (@group_sgop abgroup_group);
}.

Coercion abgroup_group : AbGroup >-> Group.
Global Existing Instance abgroup_commutative.

Global Instance isabgroup_abgroup {A : AbGroup} : IsAbGroup A.
Proof.
  split; exact _.
Defined.

Definition issig_abgroup : _ <~> AbGroup := ltac:(issig).

Global Instance zero_abgroup (A : AbGroup) : Zero A := group_unit.
Global Instance plus_abgroup (A : AbGroup) : Plus A := group_sgop.
Global Instance negate_abgroup (A : AbGroup) : Negate A := group_inverse.

Definition ab_comm {A : AbGroup} (x y : A) : x + y = y + x
  := commutativity x y.

(** ** Paths between abelian groups *)

Definition equiv_path_abgroup `{Univalence} {A B : AbGroup@{u}}
  : GroupIsomorphism A B <~> (A = B).
Proof.
  refine (equiv_ap_inv issig_abgroup _ _ oE _).
  refine (equiv_path_sigma_hprop _ _ oE _).
  exact equiv_path_group.
Defined.

Definition equiv_path_abgroup_group `{Univalence} {A B : AbGroup}
  : (A = B :> AbGroup) <~> (A = B :> Group)
  := equiv_path_group oE equiv_path_abgroup^-1.

(** ** Subgroups of abelian groups *)

(** Subgroups of abelian groups are abelian *)
Global Instance isabgroup_subgroup (G : AbGroup) (H : Subgroup G)
  : IsAbGroup H.
Proof.
  nrapply Build_IsAbGroup.
  1: exact _.
  intros x y.
  apply path_sigma_hprop.
  cbn. apply commutativity.
Defined.

(** Given any subgroup of an abelian group, we can coerce it to an abelian group. Note that Coq complains this coercion doesn't satisfy the uniform-inheritance condition, but in practice it works and doesn't cause any issue, so we ignore it. *)
Definition abgroup_subgroup (G : AbGroup) : Subgroup G -> AbGroup
  := fun H => Build_AbGroup H _.
#[warnings="-uniform-inheritance"]
Coercion abgroup_subgroup : Subgroup >-> AbGroup.

Global Instance isnormal_ab_subgroup (G : AbGroup) (H : Subgroup G)
  : IsNormalSubgroup H.
Proof.
  intros x y; unfold in_cosetL, in_cosetR.
  refine (_ oE equiv_subgroup_inverse _ _).
  rewrite negate_sg_op.
  rewrite negate_involutive.
  by rewrite (commutativity (-y) x).
Defined.

(** ** Quotients of abelian groups *)

Global Instance isabgroup_quotient (G : AbGroup) (H : Subgroup G)
  : IsAbGroup (QuotientGroup' G H (isnormal_ab_subgroup G H)).
Proof.
  nrapply Build_IsAbGroup.
  1: exact _.
  intro x.
  srapply Quotient_ind_hprop.
  intro y; revert x.
  srapply Quotient_ind_hprop.
  intro x.
  apply (ap (class_of _)).
  apply commutativity.
Defined.

Definition QuotientAbGroup (G : AbGroup) (H : Subgroup G) : AbGroup
  := (Build_AbGroup (QuotientGroup' G H (isnormal_ab_subgroup G H)) _).

Definition quotient_abgroup_rec {G : AbGroup}
  (N : Subgroup G) (H : AbGroup)
  (f : GroupHomomorphism G H) (h : forall n : G, N n -> f n = mon_unit)
  : GroupHomomorphism (QuotientAbGroup G N) H
  := grp_quotient_rec G (Build_NormalSubgroup G N _) f h.

Theorem equiv_quotient_abgroup_ump {F : Funext} {G : AbGroup}
  (N : Subgroup G) (H : Group)
  : {f : GroupHomomorphism G H & forall (n : G), N n -> f n = mon_unit}
    <~> (GroupHomomorphism (QuotientAbGroup G N) H).
Proof.
  exact (equiv_grp_quotient_ump (Build_NormalSubgroup G N _) _).
Defined.

(** ** The wild category of abelian groups *)

Global Instance isgraph_abgroup : IsGraph AbGroup
  := isgraph_induced abgroup_group.

Global Instance is01cat_abgroup : Is01Cat AbGroup
  := is01cat_induced abgroup_group.

Global Instance is01cat_grouphomomorphism {A B : AbGroup} : Is01Cat (A $-> B)
  := is01cat_induced (@grp_homo_map A B).

Global Instance is0gpd_grouphomomorphism {A B : AbGroup} : Is0Gpd (A $-> B)
  := is0gpd_induced (@grp_homo_map A B).

Global Instance is2graph_abgroup : Is2Graph AbGroup
  := is2graph_induced abgroup_group.

(** AbGroup forms a 1Cat *)
Global Instance is1cat_abgroup : Is1Cat AbGroup
  := is1cat_induced _.

Global Instance hasmorext_abgroup `{Funext} : HasMorExt AbGroup
  := hasmorext_induced _.

Global Instance hasequivs_abgroup : HasEquivs AbGroup
  := hasequivs_induced _.

(** Zero object of AbGroup *)

Definition abgroup_trivial : AbGroup.
Proof.
  rapply (Build_AbGroup grp_trivial).
  by intros [].
Defined.

(** AbGroup is a pointed category *)
Global Instance ispointedcat_abgroup : IsPointedCat AbGroup.
Proof.
  apply Build_IsPointedCat with abgroup_trivial.
  all: intro A; apply ispointedcat_group.
Defined.

(** Image of group homomorphisms between abelian groups *)
Definition abgroup_image {A B : AbGroup} (f : A $-> B) : AbGroup
  := Build_AbGroup (grp_image f) _.

(** First isomorphism theorem of abelian groups *)
Definition abgroup_first_iso `{Funext} {A B : AbGroup} (f : A $-> B)
  : GroupIsomorphism (QuotientAbGroup A (grp_kernel f)) (abgroup_image f).
Proof.
  etransitivity.
  2: rapply grp_first_iso.
  apply grp_iso_quotient_normal.
Defined.

(** ** Kernels of abelian groups *)

Definition ab_kernel {A B : AbGroup} (f : A $-> B) : AbGroup
  := Build_AbGroup (grp_kernel f) _.

(** ** Transporting in families related to abelian groups *)

Lemma transport_abgrouphomomorphism_from_const `{Univalence} {A B B' : AbGroup}
      (p : B = B') (f : GroupHomomorphism A B)
  : transport (Hom A) p f
    = grp_homo_compose (equiv_path_abgroup^-1 p) f.
Proof.
  induction p.
  by apply equiv_path_grouphomomorphism.
Defined.

Lemma transport_iso_abgrouphomomorphism_from_const `{Univalence} {A B B' : AbGroup}
      (phi : GroupIsomorphism B B') (f : GroupHomomorphism A B)
  : transport (Hom A) (equiv_path_abgroup phi) f
    = grp_homo_compose phi f.
Proof.
  refine (transport_abgrouphomomorphism_from_const _ _ @ _).
  by rewrite eissect.
Defined.

Lemma transport_abgrouphomomorphism_to_const `{Univalence} {A A' B : AbGroup}
      (p : A = A') (f : GroupHomomorphism A B)
  : transport (fun G => Hom G B) p f
    = grp_homo_compose f (grp_iso_inverse (equiv_path_abgroup^-1 p)).
Proof.
  induction p; cbn.
  by apply equiv_path_grouphomomorphism.
Defined.

Lemma transport_iso_abgrouphomomorphism_to_const `{Univalence} {A A' B : AbGroup}
      (phi : GroupIsomorphism A A') (f : GroupHomomorphism A B)
  : transport (fun G => Hom G B) (equiv_path_abgroup phi) f
    = grp_homo_compose f (grp_iso_inverse phi).
Proof.
  refine (transport_abgrouphomomorphism_to_const _ _ @ _).
  by rewrite eissect.
Defined.

(** ** Operations on abelian groups *)

(** The negation automorphism of an abelian group *)
Definition ab_homo_negation {A : AbGroup} : GroupIsomorphism A A.
Proof.
  snrapply Build_GroupIsomorphism.
  - snrapply Build_GroupHomomorphism.
    + exact (fun a => -a).
    + intros x y.
      refine (grp_inv_op x y @ _).
      apply commutativity.
  - srapply isequiv_adjointify.
    1: exact (fun a => -a).
    1-2: exact negate_involutive.
Defined.

(** Multiplication by [n : Int] defines an endomorphism of any abelian group [A]. *)
Definition ab_mul {A : AbGroup} (n : Int) : GroupHomomorphism A A.
Proof.
  snrapply Build_GroupHomomorphism.
  1: exact (fun a => grp_pow a n).
  intros a b.
  induction n; cbn.
  - exact (grp_unit_l _)^.
  - destruct n.
    + reflexivity.
    + simpl in IHn |- *.
      refine (_ @ associativity _ _ _).
      refine (_ @ (ap _ (associativity _ _ _)^)).
      rewrite (commutativity (nat_iter _ _ _) b).
      refine (_ @ (ap _ (associativity _ _ _))).
      refine (_ @ (associativity _ _ _)^).
      apply grp_cancelL.
      exact IHn.
  - destruct n.
    + simpl. 
      rewrite (commutativity (- a)).
      exact (grp_inv_op a b).
    + simpl in IHn |- *.
      refine (_ @ associativity _ _ _).
      refine (_ @ ap _ (associativity _ _ _)^).
      rewrite (commutativity (nat_iter _ _ _) (-b)).
      refine (_ @ ap _ (associativity _ _ _)).
      refine (_ @ (associativity _ _ _)^).
      rewrite (commutativity (-a) (-b)), <- (grp_inv_op a b).
      apply grp_cancelL.
      exact IHn.
Defined.

  (* 1: exact (grp_unit_l _)^.
  refine (_ @ associativity _ _ _).
  refine (_ @ ap _ (associativity _ _ _)^).
  rewrite (commutativity (grp_pow a n) b).
  refine (_ @ ap _ (associativity _ _ _)).
  refine (_ @ (associativity _ _ _)^).
  apply grp_cancelL.
  assumption. *)

Definition ab_mul_homo {A B : AbGroup}
  (f : GroupHomomorphism A B) (n : Int)
  : f o ab_mul n == ab_mul n o f
  := grp_pow_homo f n.

(** The image of an inclusion is a normal subgroup. *)
Definition ab_image_embedding {A B : AbGroup} (f : A $-> B) `{IsEmbedding f} : NormalSubgroup B
  := {| normalsubgroup_subgroup := grp_image_embedding f; normalsubgroup_isnormal := _ |}.

Definition ab_image_in_embedding {A B : AbGroup} (f : A $-> B) `{IsEmbedding f}
  : GroupIsomorphism A (ab_image_embedding f)
  := grp_image_in_embedding f.

(** The cokernel of a homomorphism into an abelian group. *)
Definition ab_cokernel {G : Group@{u}} {A : AbGroup@{u}} (f : GroupHomomorphism G A)
  : AbGroup := QuotientAbGroup _ (grp_image f).

Definition ab_cokernel_embedding {G : Group} {A : AbGroup} (f : G $-> A) `{IsEmbedding f}
  : AbGroup := QuotientAbGroup _ (grp_image_embedding f).

Definition ab_cokernel_embedding_rec {G: Group} {A B : AbGroup} (f : G $-> A) `{IsEmbedding f}
  (h : A $-> B) (p : grp_homo_compose h f $== grp_homo_const)
  : ab_cokernel_embedding f $-> B.
Proof.
  snrapply (grp_quotient_rec _ _ h).
  intros a [g q].
  induction q.
  exact (p g).
Defined.

(** ** Finite Sums *)

(** Indexed finite sum of abelian group elements. *)
Definition ab_sum {A : AbGroup} (n : nat) (f : forall k, (k < n)%nat -> A) : A.
Proof.
  induction n as [|n IHn].
  - exact zero.
  - refine (f n _ + IHn _).
    intros k Hk.
    refine (f k _).
    apply leq_S.
    exact Hk.
Defined.

(** If the function is constant in the range of a finite sum then the sum is equal to the constant times [n]. This is a group power in the underlying group. *)
Definition ab_sum_const {A : AbGroup} (n : nat) (r : A)
  (f : forall k, (k < n)%nat -> A) (p : forall k Hk, f k Hk = r)
  : ab_sum n f = grp_pow r n.
Proof.
  induction n as [|n IHn] in f, p |- *.
  - reflexivity.
  - rewrite int_of_nat_succ_commute, grp_pow_int_add_1.
    simpl. f_ap.
    rewrite IHn.
    + reflexivity.
    + intros. apply p.
Defined.

(** If the function is zero in the range of a finite sum then the sum is zero. *)
Definition ab_sum_zero {A : AbGroup} (n : nat)
  (f : forall k, (k < n)%nat -> A) (p : forall k Hk, f k Hk = 0)
  : ab_sum n f = 0.
Proof.
  lhs nrapply (ab_sum_const _ 0 f p).
  apply grp_pow_unit.
Defined.

(** Finite sums distribute over addition. *)
Definition ab_sum_plus {A : AbGroup} (n : nat) (f g : forall k, (k < n)%nat -> A)
  : ab_sum n (fun k Hk => f k Hk + g k Hk)
    = ab_sum n (fun k Hk => f k Hk) + ab_sum n (fun k Hk => g k Hk).
Proof.
  induction n as [|n IHn].
  1: by rewrite grp_unit_l.
  simpl.
  rewrite <- !grp_assoc; f_ap.
  rewrite IHn, ab_comm, <- grp_assoc; f_ap.
  by rewrite ab_comm.
Defined.

(** Double finite sums commute. *)
Definition ab_sum_sum {A : AbGroup} (m n : nat)
  (f : forall i j, (i < m)%nat -> (j < n)%nat -> A)
  : ab_sum m (fun i Hi => ab_sum n (fun j Hj => f i j Hi Hj))
   = ab_sum n (fun j Hj => ab_sum m (fun i Hi => f i j Hi Hj)).
Proof.
  induction n as [|n IHn] in m, f |- *.
  1: by nrapply ab_sum_zero.
  lhs nrapply ab_sum_plus; cbn; f_ap.
Defined.

(** Finite sums are equal if the functions are equal in the range. *)
Definition path_ab_sum {A : AbGroup} {n : nat} {f g : forall k, (k < n)%nat -> A}
  (p : forall k Hk, f k Hk = g k Hk)
  : ab_sum n f = ab_sum n g.
Proof.
  induction n as [|n IHn].
  1: reflexivity.
  cbn; f_ap.
  by apply IHn.
Defined.
