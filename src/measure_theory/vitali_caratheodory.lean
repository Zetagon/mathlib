/-
Copyright (c) 2021 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/

import measure_theory.regular
import topology.semicontinuous
import measure_theory.bochner_integration
import data.real.ereal

open_locale ennreal

open measure_theory
open measure_theory.measure

variables {α : Type*} [topological_space α] [measurable_space α] [borel_space α] {μ : measure α}
  [weakly_regular μ]

/-- Given an integrable function `f`, there exists a lower semicontinuous function `g ≥ f` with
integral arbitrarily close to that of `f`. -/
lemma ennreal.exists_le_lower_semicontinuous
  (f : α → ℝ≥0∞) (hf : measurable f) (ε : ℝ≥0∞) (εpos : 0 < ε) :
  ∃ g : α → ℝ≥0∞, (∀ x, f x ≤ g x) ∧ lower_semicontinuous g ∧ (∫⁻ x, g x ∂μ ≤ ∫⁻ x, f x ∂μ + ε) :=
begin
  by_cases int_f : ∫⁻ x, f x ∂μ = ∞,
  { refine ⟨λ x, ∞, λ x, le_top, lower_semicontinuous_const, by simp [int_f]⟩ },
  sorry
end

/-- Given an integrable function `f`, there exists an upper semicontinuous function `g ≤ f` with
integral arbitrarily close to that of `f`. -/
lemma ennreal.exists_upper_semicontinuous_le
  (f : α → ℝ≥0∞) (hf : measurable f) (int_f : ∫⁻ x, f x ∂μ < ∞) (ε : ℝ≥0∞) (εpos : 0 < ε) :
  ∃ g : α → ℝ≥0∞, (∀ x, g x ≤ f x) ∧ lower_semicontinuous g ∧ (∫⁻ x, f x ∂μ ≤ ∫⁻ x, g x ∂μ + ε) :=
begin
  sorry
end

lemma real.exists_le_lower_semicontinuous
  (f : α → ℝ) (hf : integrable f μ) (ε : ℝ) (εpos : 0 < ε) :
  ∃ g : α → ereal, (∀ x, (f x : ereal) ≤ g x) ∧ lower_semicontinuous g ∧
  (∀ᵐ x ∂ μ, g x < ⊤) ∧
  (∫ x, ereal.to_real (g x) ∂μ ≤ ∫ x, f x ∂μ + ε) :=
begin
  sorry
end



end measure_theory