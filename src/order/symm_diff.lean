/-
Copyright (c) 2021 Bryan Gin-ge Chen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz, Bryan Gin-ge Chen
-/

import order.boolean_algebra

/-!
# Symmetric difference

The symmetric difference or disjunctive union of sets `A` and `B` is the set of elements that are
in either `A` or `B` but not both. Translated into propositions, the symmetric difference is `xor`.

The symmetric difference operator is defined for any type with `⊔` and `\`, however all of the
theorems proved about it only hold for `boolean_algebra`s.

The symmetric difference is the addition operator in the Boolean ring structure on Boolean algebras.

## Main declarations

* `symm_diff`: the symmetric difference operator, defined as `(A \ B) ⊔ (B \ A)`

In Boolean algebras, the symmetric difference operator is:

* `symm_diff_comm`: commutative, and
* `symm_diff_assoc`: associative.

## Notations

* `a Δ b`: `symm_diff a b`

## Tags
boolean ring, boolean algebra, symmetric differences
-/

/-- The symmetric difference operator of a structure with `⊔` and `\` is `(A \ B) ⊔ (B \ A)`. -/
def symm_diff {α : Type*} [has_sup α] [has_sdiff α] (A B : α) : α := (A \ B) ⊔ (B \ A)

infix ` Δ `:100 := symm_diff

section boolean_algebra
variables {α : Type*} [boolean_algebra α] (a b c : α)

lemma symm_diff_eq : a Δ b = (a ⊓ bᶜ) ⊔ (b ⊓ aᶜ) := by simp only [(Δ), sdiff_eq]
lemma symm_diff_comm : a Δ b = b Δ a := by simp only [symm_diff_eq, sup_comm]

lemma compl_symm_diff : (a Δ b)ᶜ = (a ⊓ b) ⊔ (aᶜ ⊓ bᶜ) :=
calc (a Δ b)ᶜ = (aᶜ ⊔ b) ⊓ (bᶜ ⊔ a)                     : by simp only [symm_diff_eq, compl_sup,
                                                                        compl_inf, compl_compl]
          ... = ((aᶜ ⊓ bᶜ) ⊔ (b ⊓ bᶜ)) ⊔ ((aᶜ ⊔ b) ⊓ a) : by rw [inf_sup_left, inf_sup_right]
          ... = (aᶜ ⊓ bᶜ) ⊔ ((aᶜ ⊔ b) ⊓ a)              : by rw [inf_compl_eq_bot, sup_bot_eq]
          ... = (aᶜ ⊓ bᶜ) ⊔ ((aᶜ ⊓ a) ⊔ (b ⊓ a))        : by rw [inf_sup_right]
          ... = (aᶜ ⊓ bᶜ) ⊔ (b ⊓ a)                     : by rw [compl_inf_eq_bot, bot_sup_eq]
          ... = (a ⊓ b) ⊔ (aᶜ ⊓ bᶜ)                     : by rw [@inf_comm _ _ b a, sup_comm]

lemma symm_diff_symm_diff :
  a Δ (b Δ c) = (a ⊓ b ⊓ c) ⊔ (a ⊓ bᶜ ⊓ cᶜ) ⊔ (aᶜ ⊓ b ⊓ cᶜ) ⊔ (aᶜ ⊓ bᶜ ⊓ c) :=
calc a Δ (b Δ c) = (a ⊓ ((b ⊓ c) ⊔ (bᶜ ⊓ cᶜ))) ⊔
                     (((b ⊓ cᶜ) ⊔ (c ⊓ bᶜ)) ⊓ aᶜ)  : by rw [symm_diff_eq, compl_symm_diff,
                                                            symm_diff_eq]
             ... = (a ⊓ b ⊓ c) ⊔ (a ⊓ bᶜ ⊓ cᶜ) ⊔
                     (b ⊓ cᶜ ⊓ aᶜ) ⊔ (c ⊓ bᶜ ⊓ aᶜ) : by rw [inf_sup_left, inf_sup_right,
                                                            ←sup_assoc, ←inf_assoc, ←inf_assoc]
             ... = (a ⊓ b ⊓ c) ⊔ (a ⊓ bᶜ ⊓ cᶜ) ⊔
                     (aᶜ ⊓ b ⊓ cᶜ) ⊔ (aᶜ ⊓ bᶜ ⊓ c) : begin
                                                       congr' 1,
                                                       { congr' 1,
                                                         rw [inf_comm, inf_assoc], },
                                                       { apply inf_left_right_swap }
                                                     end

lemma symm_diff_assoc : a Δ b Δ c = a Δ (b Δ c) :=
eq.symm $ calc a Δ (b Δ c) = (a ⊓ b ⊓ c) ⊔ (a ⊓ bᶜ ⊓ cᶜ) ⊔
                               (aᶜ ⊓ b ⊓ cᶜ) ⊔ (aᶜ ⊓ bᶜ ⊓ c) : symm_diff_symm_diff a b c
                       ... = (c ⊓ b ⊓ a) ⊔ (cᶜ ⊓ bᶜ ⊓ a) ⊔
                               (cᶜ ⊓ b ⊓ aᶜ) ⊔ (c ⊓ bᶜ ⊓ aᶜ) :
                                              by rw [inf_left_right_swap, inf_left_right_swap a bᶜ,
                                                     inf_left_right_swap aᶜ, inf_left_right_swap aᶜ]
                       ... = (c ⊓ b ⊓ a) ⊔ (c ⊓ bᶜ ⊓ aᶜ) ⊔
                               (cᶜ ⊓ b ⊓ aᶜ) ⊔ (cᶜ ⊓ bᶜ ⊓ a) :
                                         by rw [sup_assoc, sup_assoc, @sup_comm _ _ (cᶜ ⊓ bᶜ ⊓ a),
                                                @sup_comm _ _ (cᶜ ⊓ b ⊓ aᶜ), ←sup_assoc, ←sup_assoc]
                       ... = c Δ (b Δ a)                     : by rw symm_diff_symm_diff
                       ... = a Δ b Δ c                    : by rw [symm_diff_comm a, symm_diff_comm]

lemma symm_diff_symm_diff_sup : a Δ b Δ (a ⊓ b) = a ⊔ b :=
by rw [symm_diff_assoc, symm_diff_eq, compl_symm_diff, symm_diff_eq, @inf_comm _ _ a b, ←inf_assoc,
  inf_idem, @inf_comm _ _ b a, inf_assoc, inf_compl_eq_bot, inf_bot_eq, sup_bot_eq,
  compl_inf, @sup_comm _ _ aᶜ, inf_sup_self, inf_assoc, @inf_comm _ _ _ aᶜ, @sup_comm _ _ bᶜ,
  inf_sup_self, inf_sup_left, ←inf_assoc, inf_idem, inf_sup_inf_compl_sup_inf_compl]

lemma top_symm_diff : ⊤ Δ a = aᶜ :=
by rw [symm_diff_eq, compl_top, top_inf_eq, inf_bot_eq, sup_bot_eq]

end boolean_algebra

lemma symm_diff_eq_xor (p q : Prop) : p Δ q = xor p q := rfl
