/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying
-/

import linear_algebra.quadratic_form
import analysis.special_functions.pow

/-!
# Sylvester's law of inertia

This file provides a proof of Sylvester's law of inertia.
-/

/-- Nonzero elements in a field are invertible. This is a definition since it requires a
parameter. -/
def field.invertible {K : Type*} [field K] {z : K} (hz : z ≠ 0) : invertible z :=
{ inv_of := z⁻¹,
  inv_of_mul_self := inv_mul_cancel hz,
  mul_inv_of_self := mul_inv_cancel hz }

variables {R : Type*} [ring R] {R₁ : Type*} [comm_ring R₁]
variables {M : Type*} [add_comm_group M] [module R M] [module R₁ M]
variables {M₁ : Type*} [add_comm_group M₁] [module R M₁]
variables {ι : Type*} [fintype ι] {v : ι → M}

namespace quadratic_form

open_locale big_operators

open finset bilin_form

/-- A quadratic form composed with a `linear_equiv` is isometric to itself. -/
def isometry_of_comp_linear_equiv (Q : quadratic_form R M) (f : M₁ ≃ₗ[R] M) :
  Q.isometry (Q.comp (f : M₁ →ₗ[R] M)) :=
{ map_app' :=
  begin
    intro,
    simp only [comp_apply, linear_equiv.coe_coe, linear_equiv.to_fun_eq_coe,
               linear_equiv.apply_symm_apply, f.apply_symm_apply],
  end, .. f.symm }

/-- Given a quadratic form `Q` and a basis, `of_is_basis` is the basis representation of `Q`. -/
noncomputable def of_is_basis (Q : quadratic_form R M)
  (hv₁ : is_basis R v) : quadratic_form R (ι → R) := Q.comp hv₁.equiv_fun.symm

@[simp]
lemma isometry_of_is_basis_apply (Q : quadratic_form R M) (hv₁ : is_basis R v)
  (w : ι → R) : Q.of_is_basis hv₁ w = Q (∑ i : ι, w i • v i) :=
by { rw ← hv₁.equiv_fun_symm_apply, refl }

/-- A quadratic form is isometric to its bases representations. -/
noncomputable def isometry_of_is_basis (Q : quadratic_form R M) (hv₁ : is_basis R v) :
  isometry Q (Q.of_is_basis hv₁) :=
isometry_of_comp_linear_equiv Q hv₁.equiv_fun.symm

lemma isometry_of_is_Ortho_apply [invertible (2 : R₁)]
  (Q : quadratic_form R₁ M) (hv₁ : is_basis R₁ v)
  (hv₂ : (associated Q).is_Ortho v) (w : ι → R₁) :
  Q.of_is_basis hv₁ w = ∑ i : ι, associated Q (v i) (v i) * w i * w i :=
begin
  rw [isometry_of_is_basis_apply, ← @associated_eq_self_apply R₁, sum_left],
  refine sum_congr rfl (λ j hj, _),
  rw [sum_right, sum_eq_single j],
  { rw [smul_left, smul_right], ring },
  { intros i _ hij,
    rw [smul_left, smul_right,
        show (associated_hom R₁) Q (v j) (v i) = 0, by exact hv₂ i j hij,
        mul_zero, mul_zero] },
  { contradiction }
end

/-- The weighted sum of squares with respect some weight as a quadratic form. -/
def weighted_sum_squares (w : ι → R₁) : quadratic_form R₁ (ι → R₁) :=
∑ i : ι, w i • proj i i

@[simp]
lemma weighted_sum_squares_apply (w v : ι → R₁) :
  weighted_sum_squares w v = ∑ i : ι, w i * (v i * v i) :=
quadratic_form.sum_apply _ _ _

variables {V : Type*} {K : Type*} [field K] [invertible (2 : K)]
variables [add_comm_group V] [module K V] [finite_dimensional K V]

lemma equivalent_weighted_sum_squares_of_nondegenerate'
  (Q : quadratic_form K V) (hQ : (associated Q).nondegenerate) :
  ∃ w : fin (finite_dimensional.finrank K V) → K,
  (∀ i, w i ≠ 0) ∧ equivalent Q (weighted_sum_squares w) :=
begin
  obtain ⟨v, hv₁, hv₂, hv₃⟩ := exists_orthogonal_basis' hQ associated_is_sym,
  refine ⟨λ i, associated Q (v i) (v i), hv₃, _⟩,
  refine nonempty.intro _,
  convert Q.isometry_of_is_basis hv₂,
  ext w,
  rw [isometry_of_is_Ortho_apply Q hv₂ hv₁, weighted_sum_squares_apply],
  refine finset.sum_congr rfl _,
  intros, rw ← mul_assoc,
end

lemma equivalent_weighted_sum_squares_of_nondegenerate
  (Q : quadratic_form K V) (hQ : (associated Q).nondegenerate) :
  ∃ w : fin (finite_dimensional.finrank K V) → K,
    equivalent Q (weighted_sum_squares w) :=
let ⟨w, _, hw₂⟩ := Q.equivalent_weighted_sum_squares_of_nondegenerate' hQ in ⟨w, hw₂⟩

end quadratic_form