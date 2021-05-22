/-
Copyright (c) 2021 Henry Swanson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Henry Swanson
-/
import data.equiv.basic
import data.equiv.option
import group_theory.perm.option

import tactic.equiv_rw

/-!
# Derangements on types

In this file we define a predicate and its corresponding set:

* `is_derangement f`: whether the permutation `f` has no fixed points.

* `derangements α`: the set of derangements on a type `α`.

Then we define

* some related predicates: e.g.,

  - `only_possible_fixed_point f a`: either `f` has no fixed points, or `a` is the only fixed point;

  - `exactly_one_fixed_point f a`: `f` has exactly one fixed point, which is `a`;

* equivalences involving various subtypes of `perm α` and `derangements α`: e.g.,

  - `derangements_equiv_sigma_opfp`: an equivalence between `derangements (option α)` and the
    sigma-type `Σ a : α, {f : perm α // only_possible_fixed_point f a}`.
-/

open equiv

namespace perm

section definitions

/-- A permutation is a derangement if it has no fixed points. -/
def is_derangement {α : Type*} (f : perm α) : Prop := ∀ x : α, f x ≠ x

/-- The set of derangements on `α`. -/
def derangements (α : Type*) : set (perm α) := {f : perm α | is_derangement f}

/-- The permutation `f` has at most one fixed point, `a`. -/
def only_possible_fixed_point {α : Type*} (f : perm α) (a : α) : Prop := ∀ x : α, f x = x → x = a

/-- The permutation `f` has exactly one fixed point, `a`. -/
def exactly_one_fixed_point {α : Type*} (f : perm α) (a : α) : Prop := ∀ x : α, f x = x ↔ x = a

end definitions

-- TODO there's just a single lemma here for now, but i can imagine other lemmas living here
-- If I can get perm.support working here, then this is a good place for those lemmas
section simple_lemmas

/-- If `α` is equivalent to `β`, then `derangements α` is equivalent to `derangements β`. -/
def derangements_congr {α β : Type*} (e : α ≃ β) : (derangements α ≃ derangements β) :=
subtype_equiv (perm_congr e) $ λ f, e.forall_congr $ λ x, by simp

end simple_lemmas

section fixed_points

variables {α : Type*}

lemma eofp_iff_opfp_and_eq (a : α) (f : perm α) :
  exactly_one_fixed_point f a ↔ only_possible_fixed_point f a ∧ f a = a :=
begin
  split,
  { intro h_eofp, exact ⟨λ x, (h_eofp x).mp, (h_eofp a).mpr rfl⟩ },
  { rintros ⟨h_opfp, fa_eq_a⟩ x,
    split,
    { exact h_opfp x },
    { rintro ⟨rfl⟩, exact fa_eq_a }}
end

lemma is_derangement_iff_opfp_and_ne (a : α) (f : perm α) :
  is_derangement f ↔ only_possible_fixed_point f a ∧ f a ≠ a :=
begin
  split,
  { intro h_derangement,
    split,
    { intros x x_fixed, exfalso, exact h_derangement x x_fixed },
    { exact h_derangement a }},
  { rintros ⟨h_opfp, fa_ne_a⟩ x x_fixed,
    specialize h_opfp x x_fixed,
    rw h_opfp at x_fixed,
    exact fa_ne_a x_fixed }
end

/-- The set of permutations with `a` the only fixed point is equivalent to the set of derangements
    on `{a}ᶜ`. -/
def eofp_equiv_derangements_except_for [decidable_eq α] (a : α) :
  {f : perm α | exactly_one_fixed_point f a} ≃ derangements ({a}ᶜ : set α) :=
begin
  let key_equiv : {f : perm α | f a = a} ≃ perm ({a}ᶜ : set α),
  { transitivity {f : perm α // ∀ x : ({a} : set α), f x = (equiv.refl _) x},
    { apply subtype_equiv_right, simp },
    { exact equiv.set.compl (equiv.refl _) }},

  transitivity {f : {f : perm α // f a = a} // only_possible_fixed_point f.val a},
  { apply equiv.trans _ (subtype_subtype_equiv_subtype_exists _ _).symm,
    apply subtype_equiv_right,
    intro f,
    simp_rw [exists_prop, set.mem_set_of_eq, eofp_iff_opfp_and_eq, and_comm] },
  { refine subtype_equiv key_equiv _,
    rintro ⟨f, _⟩,
    simp [key_equiv, equiv.set.compl, derangements, is_derangement,
          only_possible_fixed_point, not_imp_not] }
end

end fixed_points

section option

variables {α : Type*} [decidable_eq α]

def remove_none.fiber (a : option α) : set (perm α) :=
  {f : perm α | (a, f) ∈ equiv.perm.decompose_option '' derangements (option α)}

lemma remove_none.fiber_mem (a : option α) (f : perm α) :
  f ∈ remove_none.fiber a ↔ ∃ F : perm (option α), is_derangement F ∧ F none = a ∧
  remove_none F = f :=
begin
  simp [remove_none.fiber, derangements],
end

lemma remove_none.fiber_none_eq_empty : remove_none.fiber (@none α) = ∅ :=
begin
  rw set.eq_empty_iff_forall_not_mem,
  intros f hyp,
  rw remove_none.fiber_mem at hyp,
  rcases hyp with ⟨F, F_derangement, F_none, _⟩,
  exact F_derangement none F_none
end

def remove_none.fiber_equiv_opfp (a : α) :
  (remove_none.fiber (some a)) ≃ {f : perm α // only_possible_fixed_point f a} :=
begin
  apply subtype_equiv_right,
  intro f,
  split,
  { rw remove_none.fiber_mem,
    rintro ⟨F, F_derangement, F_none, rfl⟩ x x_fixed,
    apply_fun some at x_fixed,
    cases Fx : F (some x) with y,
    { rw remove_none_none F Fx at x_fixed, rw ←option.some_inj, rwa x_fixed at F_none },
    { exfalso, rw remove_none_some F ⟨y, Fx⟩ at x_fixed, exact F_derangement _ x_fixed }},
  { intro h_opfp,
    use equiv.perm.decompose_option.symm (some a, f),
    split,
    { simp only [equiv.perm.decompose_option_symm_apply],
      intro x,
      apply_fun (swap none (some a)),
      simp only [equiv.swap_apply_self, equiv.perm.coe_mul],
      cases x,
      { simp },
      { simp only [equiv_functor.map_equiv_apply, equiv_functor.map,
                    option.map_eq_map,  option.map_some'],
        by_cases x_vs_a : x = a,
        { rw [x_vs_a, swap_apply_right], exact option.some_ne_none _, },
        { have ne_1 : some x ≠ none := option.some_ne_none _,
          have ne_2 : some x ≠ some a := (option.some_injective α).ne_iff.mpr x_vs_a,
          rw swap_apply_of_ne_of_ne ne_1 ne_2,
          rw (option.some_injective α).ne_iff,
          intro contra,
          exact x_vs_a (h_opfp x contra) }},
    },
    { rw apply_symm_apply }}
end

def derangements_equiv_sigma_opfp :
  derangements (option α) ≃ Σ a : α, {f : perm α // only_possible_fixed_point f a} :=
begin
  have fiber_is_some : ∀ a : option α, (remove_none.fiber a) → a.is_some,
  { intro a,
    cases a,
    { rw remove_none.fiber_none_eq_empty, simp },
    { intro _, simp }},

  calc derangements (option α)
      ≃ equiv.perm.decompose_option '' derangements (option α)   : equiv.image _ _
  ... ≃ Σ (a : option α), ↥(remove_none.fiber a)                 : set_prod_equiv_sigma _
  ... ≃ Σ (a : {a' : option α // a'.is_some}), ↥(remove_none.fiber a.val)
          : (sigma_subtype_equiv_of_subset _ _ fiber_is_some).symm
  ... ≃ Σ (a : α), ↥(remove_none.fiber (some a))
          : sigma_congr_left' (option_is_some_equiv α)
  ... ≃ Σ (a : α), {f : perm α // only_possible_fixed_point f a}
          : sigma_congr_right remove_none.fiber_equiv_opfp,
end

/-- The set of derangements on `option α` is equivalent to the union over all `a : α` of
    "derangements on `α` ⊕ derangements on `{a}ᶜ`". -/
def derangements_recursion_equiv :
  derangements (option α) ≃ Σ a : α, (derangements (({a}ᶜ : set α) : Type _) ⊕ derangements α) :=
begin
  equiv_rw derangements_equiv_sigma_opfp,
  apply sigma_congr_right,
  intro a,
  equiv_rw (equiv.sum_compl (λ f : {f : perm α // _}, f.val a = a)).symm,
  refine sum_congr _ _,
  {
    equiv_rw (eofp_equiv_derangements_except_for a).symm,
    simp_rw (eofp_iff_opfp_and_eq a),
    exact subtype_subtype_equiv_subtype_inter _ (λ f : perm α, f a = a),
    apply_instance,
  },
  {
    unfold derangements,
    simp_rw (is_derangement_iff_opfp_and_ne a),
    exact subtype_subtype_equiv_subtype_inter _ (λ f : perm α, f a ≠ a),
  },

  apply_instance,  -- TODO why does this goal exist? seems to come from equiv_rw
end

end option

end perm