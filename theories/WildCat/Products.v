Require Import Basics.
Require Import WildCat.Core.

(** * Categories with products *)

(** There is a lot of theory that can be developed about categories with certain limits. It can be very tempting to try to do this in full generality, but this often leads to the person doing the formalization getting lost down the rabbit hole. Therefore we try to keep things as direct as possible implementing only what we need for now. *)

Class HasBinaryProducts (A : Type) `{Is1Cat A} := {
  (** A binary product is an object of a category given by a pair of objects. *)
  product : A -> A -> A;

  (** It comes equipped with two projection maps out of the product. *)
  cat_pr1 : forall {x y : A}, product x y $-> x;
  cat_pr2 : forall {x y : A}, product x y $-> y;
  
  (** Together with a pairing "corecursor" into the product. *)
  product_corec : forall {x y z : A},
    (z $-> x) -> (z $-> y) -> (z $-> product x y);

  (** All this data satisifies certain equiations, leading to the unqiueness of the product_corec map. *)

  (** Applying the first projection after a map pariing gives the first map. *) 
  product_beta_pr1 {x y z : A} (f : z $-> x) (g : z $-> y)
    : cat_pr1 $o product_corec f g $== f;
  
  (** Applying the second projection after a map pariing gives the second map. *)
  product_beta_pr2 {x y z : A} (f : z $-> x) (g : z $-> y)
    : cat_pr2 $o product_corec f g $== g;

  (** The pairing map is the unique map that makes the following diagram commute. *)
  product_eta {x y z : A} (f : z $-> product x y)
    : product_corec (cat_pr1 $o f) (cat_pr2 $o f) $== f;
  
  (** Finally given any two [product_corec], they are uniquely identified by their components. (This introduces a 2-categorical notion of product, which for n-categorical universal properties will need (n+1) levels of cells. We therefore restrict to 1-categories for now). Without this condition, we would not be able to show the 2-functorial action of the product functor or even 1-functoriality in the second argument. *) 
  product_corec_eta {x y z : A} {f f' : z $-> x} {g g' : z $-> y}
    : f $== f' -> g $== g' -> product_corec f g $== product_corec f' g';
}.

Lemma product_pr_eta {A} `{HasBinaryProducts A}
  {x y z : A} {f f' : z $-> product x y}
  : cat_pr1 $o f $== cat_pr1 $o f' -> cat_pr2 $o f $== cat_pr2 $o f' -> f $== f'.
Proof.
  intros fst snd.
  refine ((product_eta _)^$ $@ _ $@ product_eta _).
  by apply product_corec_eta.
Defined.

(** In general it's not possible to define a recursor for a product. It is possible if a category has an internal hom, but that is a very strong condition.  *)

(** *** Product functor *)


(** Binary products are functorial in each argument. *)
Global Instance is0functor_product_l {A : Type} `{Is1Cat A} `{HasBinaryProducts A} y
  : Is0Functor (fun x => product x y).
Proof.
  snrapply Build_Is0Functor.
  intros a b f.
  apply product_corec.
  - exact (f $o cat_pr1).
  - exact cat_pr2.
Defined.

Global Instance is1functor_product_l {A : Type} `{Is1Cat A} `{HasBinaryProducts A} y
  : Is1Functor (fun x => product x y).
Proof.
  snrapply Build_Is1Functor.
  - intros a b f g p.
    simpl.
    apply product_corec_eta.
    2: apply Id.
    exact (p $@R cat_pr1).
  - intros x.
    simpl.
    apply product_pr_eta.
    + refine (product_beta_pr1 _ _ $@ _).
      exact (cat_idl _ $@ (cat_idr _)^$).
    + refine (product_beta_pr2 _ _ $@ _).
      exact (cat_idr _)^$.
  - intros x z w f g.
    simpl.
    apply product_pr_eta.
    + refine (product_beta_pr1 _ _ $@ _).
      refine (_ $@ cat_assoc _ _ _).
      refine (_ $@ ((product_beta_pr1 _ _)^$ $@R _)).
      refine (cat_assoc _ _ _ $@ (_ $@L _) $@ (cat_assoc _ _ _)^$).
      exact (product_beta_pr1 _ _)^$.
    + refine (product_beta_pr2 _ _ $@ _).
      refine (_ $@ cat_assoc _ _ _).
      refine (_ $@ ((product_beta_pr2 _ _)^$ $@R _)).
      exact (product_beta_pr2 _ _)^$.
Defined.

Global Instance is0functor_product_r {A : Type} `{Is1Cat A} `{HasBinaryProducts A} x
  : Is0Functor (product x).
Proof.
  snrapply Build_Is0Functor.
  intros a b f.
  apply product_corec.
  - exact cat_pr1.
  - exact (f $o cat_pr2).
Defined.

Global Instance is1functor_product_r {A : Type} `{Is1Cat A} `{HasBinaryProducts A} x
  : Is1Functor (product x).
Proof.
  snrapply Build_Is1Functor.
  - intros y z f g p.
    apply product_corec_eta.
    1: apply Id.
    exact (p $@R cat_pr2).
  - intros y. simpl.
    refine (_ $@ product_eta _).
    apply product_corec_eta.
    + symmetry.
      apply cat_idr.
    + exact (cat_idl _ $@ (cat_idr _)^$).
  - intros y z w f g.
    simpl.
    apply product_pr_eta.
    + refine (product_beta_pr1 _ _ $@ _).
      refine (_ $@ cat_assoc _ _ _).
      refine (_ $@ ((product_beta_pr1 _ _)^$ $@R _)).
      exact (product_beta_pr1 _ _)^$.    
    + refine (product_beta_pr2 _ _ $@ _).
      refine (_ $@ cat_assoc _ _ _).
      refine (_ $@ ((product_beta_pr2 _ _)^$ $@R _)).
      refine (_ $@ (cat_assoc _ _ _)^$).
      refine (cat_assoc _ _ _ $@ _).
      exact (_ $@L product_beta_pr2 _ _)^$.
Defined.

(** [product_corec] is also functorial in each morphsism. *)

Global Instance is0functor_product_corec_l {A : Type} `{Is1Cat A} `{HasBinaryProducts A} {x y z : A} (g : z $-> y)
  : Is0Functor (fun f => @product_corec _ _ _ _ _ _ x y z f g).
Proof.
  snrapply Build_Is0Functor.
  intros f f' p.
  by apply product_corec_eta.
Defined.

Global Instance is0functor_product_corec_r {A : Type} `{Is1Cat A} `{HasBinaryProducts A} {x y z : A} (f : z $-> x)
  : Is0Functor (@product_corec _ _ _ _ _ _ x y z f).
Proof.
  snrapply Build_Is0Functor.
  intros g h p.
  by apply product_corec_eta.
Defined.
