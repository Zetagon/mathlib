/-
Copyright (c) 2020 Yury Kudryashov All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Heather Macbeth
-/
import analysis.normed_space.operator_norm
import analysis.normed_space.extend
import analysis.convex.cone
import analysis.convex.topology
import analysis.specific_limits
import data.complex.is_R_or_C

/-!
# Hahn-Banach theorem

In this file we prove a version of Hahn-Banach theorem for continuous linear
functions on normed spaces over `ℝ` and `ℂ`.

In order to state and prove its corollaries uniformly, we prove the statements for a field `𝕜`
satisfying `is_R_or_C 𝕜`.

In this setting, `exists_dual_vector` states that, for any nonzero `x`, there exists a continuous
linear form `g` of norm `1` with `g x = ∥x∥` (where the norm has to be interpreted as an element
of `𝕜`).

-/

universes u v

/--
The norm of `x` as an element of `𝕜` (a normed algebra over `ℝ`). This is needed in particular to
state equalities of the form `g x = norm' 𝕜 x` when `g` is a linear function.

For the concrete cases of `ℝ` and `ℂ`, this is just `∥x∥` and `↑∥x∥`, respectively.
-/
noncomputable def norm' (𝕜 : Type*) [nondiscrete_normed_field 𝕜] [normed_algebra ℝ 𝕜]
  {E : Type*} [normed_group E] (x : E) : 𝕜 :=
algebra_map ℝ 𝕜 ∥x∥

lemma norm'_def (𝕜 : Type*) [nondiscrete_normed_field 𝕜] [normed_algebra ℝ 𝕜]
  {E : Type*} [normed_group E] (x : E) :
  norm' 𝕜 x = (algebra_map ℝ 𝕜 ∥x∥) := rfl

lemma norm_norm'
  (𝕜 : Type*) [nondiscrete_normed_field 𝕜] [normed_algebra ℝ 𝕜]
  (A : Type*) [normed_group A]
  (x : A) : ∥norm' 𝕜 x∥ = ∥x∥ :=
by rw [norm'_def, norm_algebra_map_eq, norm_norm]

namespace real
variables {E : Type*} [normed_group E] [normed_space ℝ E]

/-- Hahn-Banach theorem for continuous linear functions over `ℝ`. -/
theorem exists_extension_norm_eq (p : subspace ℝ E) (f : p →L[ℝ] ℝ) :
  ∃ g : E →L[ℝ] ℝ, (∀ x : p, g x = f x) ∧ ∥g∥ = ∥f∥ :=
begin
  rcases exists_extension_of_le_sublinear ⟨p, f⟩ (λ x, ∥f∥ * ∥x∥)
    (λ c hc x, by simp only [norm_smul c x, real.norm_eq_abs, abs_of_pos hc, mul_left_comm])
    (λ x y, _) (λ x, le_trans (le_abs_self _) (f.le_op_norm _))
    with ⟨g, g_eq, g_le⟩,
  set g' := g.mk_continuous (∥f∥)
    (λ x, abs_le.2 ⟨neg_le.1 $ g.map_neg x ▸ norm_neg x ▸ g_le (-x), g_le x⟩),
  { refine ⟨g', g_eq, _⟩,
    { apply le_antisymm (g.mk_continuous_norm_le (norm_nonneg f) _),
      refine f.op_norm_le_bound (norm_nonneg _) (λ x, _),
      dsimp at g_eq,
      rw ← g_eq,
      apply g'.le_op_norm } },
  { simp only [← mul_add],
    exact mul_le_mul_of_nonneg_left (norm_add_le x y) (norm_nonneg f) }
end

end real

section is_R_or_C
open is_R_or_C

variables {𝕜 : Type*} [is_R_or_C 𝕜] {F : Type*} [normed_group F] [normed_space 𝕜 F]

/-- Hahn-Banach theorem for continuous linear functions over `𝕜` satisyfing `is_R_or_C 𝕜`. -/
theorem exists_extension_norm_eq (p : subspace 𝕜 F) (f : p →L[𝕜] 𝕜) :
  ∃ g : F →L[𝕜] 𝕜, (∀ x : p, g x = f x) ∧ ∥g∥ = ∥f∥ :=
begin
  letI : module ℝ F := restrict_scalars.semimodule ℝ 𝕜 F,
  letI : is_scalar_tower ℝ 𝕜 F := restrict_scalars.is_scalar_tower _ _ _,
  letI : normed_space ℝ F := normed_space.restrict_scalars _ 𝕜 _,
  -- Let `fr: p →L[ℝ] ℝ` be the real part of `f`.
  let fr := re_clm.comp (f.restrict_scalars ℝ),
  have fr_apply : ∀ x, fr x = re (f x), by { assume x, refl },
  -- Use the real version to get a norm-preserving extension of `fr`, which
  -- we'll call `g : F →L[ℝ] ℝ`.
  rcases real.exists_extension_norm_eq (p.restrict_scalars ℝ) fr with ⟨g, ⟨hextends, hnormeq⟩⟩,
  -- Now `g` can be extended to the `F →L[𝕜] 𝕜` we need.
  use g.extend_to_𝕜,
  -- It is an extension of `f`.
  have h : ∀ x : p, g.extend_to_𝕜 x = f x,
  { assume x,
    rw [continuous_linear_map.extend_to_𝕜_apply, ←submodule.coe_smul, hextends, hextends],
    have : (fr x : 𝕜) - I * ↑(fr (I • x)) = (re (f x) : 𝕜) - (I : 𝕜) * (re (f ((I : 𝕜) • x))),
      by refl,
    rw this,
    apply ext,
    { simp only [add_zero, algebra.id.smul_eq_mul, I_re, of_real_im, add_monoid_hom.map_add,
        zero_sub, I_im', zero_mul, of_real_re, eq_self_iff_true, sub_zero, mul_neg_eq_neg_mul_symm,
        of_real_neg, mul_re, mul_zero, sub_neg_eq_add, continuous_linear_map.map_smul] },
    { simp only [algebra.id.smul_eq_mul, I_re, of_real_im, add_monoid_hom.map_add, zero_sub, I_im',
        zero_mul, of_real_re, mul_neg_eq_neg_mul_symm, mul_im, zero_add, of_real_neg, mul_re,
        sub_neg_eq_add, continuous_linear_map.map_smul] } },
  refine ⟨h, _⟩,
  -- And we derive the equality of the norms by bounding on both sides.
  refine le_antisymm _ _,
  { calc ∥g.extend_to_𝕜∥
        ≤ ∥g∥ : g.extend_to_𝕜.op_norm_le_bound g.op_norm_nonneg (norm_bound _)
    ... = ∥fr∥ : hnormeq
    ... ≤ ∥re_clm∥ * ∥f∥ : continuous_linear_map.op_norm_comp_le _ _
    ... = ∥f∥ : by rw [re_clm_norm, one_mul] },
  { exact f.op_norm_le_bound g.extend_to_𝕜.op_norm_nonneg (λ x, h x ▸ g.extend_to_𝕜.le_op_norm x) },
end

end is_R_or_C

section dual_vector
variables {𝕜 : Type v} [is_R_or_C 𝕜]
variables {E : Type u} [normed_group E] [normed_space 𝕜 E]

open continuous_linear_equiv submodule
open_locale classical

lemma coord_norm' (x : E) (h : x ≠ 0) : ∥norm' 𝕜 x • coord 𝕜 x h∥ = 1 :=
by rw [norm_smul, norm_norm', coord_norm, mul_inv_cancel (mt norm_eq_zero.mp h)]

/-- Corollary of Hahn-Banach.  Given a nonzero element `x` of a normed space, there exists an
    element of the dual space, of norm `1`, whose value on `x` is `∥x∥`. -/
theorem exists_dual_vector (x : E) (h : x ≠ 0) : ∃ g : E →L[𝕜] 𝕜, ∥g∥ = 1 ∧ g x = norm' 𝕜 x :=
begin
  let p : submodule 𝕜 E := 𝕜 ∙ x,
  let f := norm' 𝕜 x • coord 𝕜 x h,
  obtain ⟨g, hg⟩ := exists_extension_norm_eq p f,
  use g, split,
  { rw [hg.2, coord_norm'] },
  { calc g x = g (⟨x, mem_span_singleton_self x⟩ : 𝕜 ∙ x) : by rw coe_mk
    ... = (norm' 𝕜 x • coord 𝕜 x h) (⟨x, mem_span_singleton_self x⟩ : 𝕜 ∙ x) : by rw ← hg.1
    ... = norm' 𝕜 x : by simp }
end

/-- Variant of Hahn-Banach, eliminating the hypothesis that `x` be nonzero, and choosing
    the dual element arbitrarily when `x = 0`. -/
theorem exists_dual_vector' [nontrivial E] (x : E) :
  ∃ g : E →L[𝕜] 𝕜, ∥g∥ = 1 ∧ g x = norm' 𝕜 x :=
begin
  by_cases hx : x = 0,
  { obtain ⟨y, hy⟩ := exists_ne (0 : E),
    obtain ⟨g, hg⟩ : ∃ g : E →L[𝕜] 𝕜, ∥g∥ = 1 ∧ g y = norm' 𝕜 y := exists_dual_vector y hy,
    refine ⟨g, hg.left, _⟩,
    rw [norm'_def, hx, norm_zero, ring_hom.map_zero, continuous_linear_map.map_zero] },
  { exact exists_dual_vector x hx }
end

end dual_vector

section separating
open set

noncomputable theory
variables {E : Type*} [normed_group E] [normed_space ℝ E]

lemma mem_sep_true {α : Type*} (s : set α) : {a ∈ s | true} = s :=
by { ext; simp }

lemma mem_sep_false {α : Type*} (s : set α) : {a ∈ s | false} = ∅ :=
by { ext; simp }

lemma le_of_lt_add {α : Type*} [linear_ordered_add_comm_group α] {x y : α}
  (hz : ∀ z, 0 < z → x < y + z) : x ≤ y :=
begin
  by_contra h,
  push_neg at h,
  have : 0 < x - y,
  { rwa sub_pos },
  simpa using hz (x - y) ‹_›,
end

lemma real.zero_le_Inf (S : set ℝ) (hS : ∀ x ∈ S, (0:ℝ) ≤ x) : 0 ≤ Inf S :=
begin
  rcases S.eq_empty_or_nonempty with (rfl | hS₂),
  { simp [real.Inf_empty] },
  { apply real.lb_le_Inf S hS₂ hS }
end

lemma Inf_le_of_forall_lt (S : set ℝ) (hS : bdd_below S) (y : ℝ)
  (h : ∀ ε, 0 < ε → ∃ δ, δ < ε ∧ y + δ ∈ S) :
  Inf S ≤ y :=
begin
  apply le_of_lt_add,
  intros ε hε,
  obtain ⟨δ, hδ₁, hδ₂⟩ := h ε hε,
  exact cInf_lt_of_lt hS hδ₂ (add_lt_add_left hδ₁ _),
end

@[simp]
lemma Inf_Ioi (x : ℝ) : Inf (set.Ioi x) = x :=
begin
  apply le_antisymm,
  { refine Inf_le_of_forall_lt (set.Ioi x) ⟨x, λ y, le_of_lt⟩ _ (λ ε hε, _),
    exact ⟨ε/2, half_lt_self hε, lt_add_of_pos_right _ (half_pos hε)⟩ },
  { exact le_cInf set.nonempty_Ioi (λ y, le_of_lt) }
end

lemma eq_interval_of_upward_closed {α : Type*} [conditionally_complete_linear_order α] {s : set α}
  (hs₁ : ∀ ⦃k₁ k₂⦄, k₁ < k₂ → k₁ ∈ s → k₂ ∈ s) (hs₂ : s.nonempty) (hs₃ : s ≠ set.univ) :
  ∃ x, s = set.Ici x ∨ s = set.Ioi x :=
begin
  obtain ⟨x, hx⟩ : sᶜ.nonempty := set.nonempty_compl.2 hs₃,
  have : bdd_below s := ⟨x, λ y hy, le_of_not_lt (λ t, hx (hs₁ t hy))⟩,
  refine ⟨Inf s, _⟩,
  by_cases Inf s ∈ s,
  { left,
    ext y,
    refine ⟨λ hy, cInf_le ‹bdd_below s› hy, λ hy, _⟩,
    rcases eq_or_lt_of_le hy with (rfl | hy),
    { assumption },
    { apply hs₁ hy h } },
  { right,
    ext y,
    refine ⟨λ hy, _, λ hy, _⟩,
    { apply lt_of_le_of_ne (cInf_le ‹bdd_below s› ‹y ∈ s›) (ne_of_mem_of_not_mem hy h).symm },
    obtain ⟨t, ht₁, ht₂⟩ := exists_lt_of_cInf_lt hs₂ hy,
    apply hs₁ ht₂ ht₁ }
end

lemma bdd_below_or_eq_univ_of_upward_closed {α : Type*} [linear_order α]
  {s : set α} (hs₁ : s.nonempty)
  (hs₂ : ∀ ⦃k₁ k₂⦄, k₁ < k₂ → k₁ ∈ s → k₂ ∈ s) :
  bdd_below s ∨ s = set.univ :=
begin
  rw or_iff_not_imp_right,
  intro h,
  obtain ⟨x, hx⟩ := set.nonempty_compl.2 h,
  refine ⟨x, λ y hy, le_of_not_lt (λ t, hx (hs₂ t hy))⟩,
end

lemma of_Inf_le {S : set ℝ} (hS : ∀ ⦃x y⦄, x < y → x ∈ S → y ∈ S) (hS₂ : S.nonempty) {x y : ℝ}
  (hx : Inf S ≤ x) (hy : x < y) :
  y ∈ S :=
let ⟨z, hz₁, hz₂⟩ := exists_lt_of_cInf_lt hS₂ (lt_of_le_of_lt hx hy) in hS hz₂ hz₁

def gauge (K : set E) (x : E) : ℝ :=
Inf {y ∈ set.Ioi 0 | y⁻¹ • x ∈ K}

lemma gauge_set_nonempty_of_absorbing {K : set E} (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K)
  {x : E} :
  {y ∈ set.Ioi (0:ℝ) | y⁻¹ • x ∈ K}.nonempty :=
let ⟨θ, hθ₁, hθ₂⟩ := absorbing x in ⟨θ⁻¹, inv_pos.2 hθ₁, by simpa⟩

lemma gauge_set_bdd_below {K : set E} {x : E} :
  bdd_below {y ∈ set.Ioi (0:ℝ) | y⁻¹ • x ∈ K} :=
⟨0, λ y hy, le_of_lt hy.1⟩

@[simp]
lemma gauge_zero {K : set E} : gauge K 0 = 0 :=
begin
  rw gauge,
  by_cases (0:E) ∈ K,
  { simp [h, mem_sep_true] },
  { simp [h, mem_sep_false, real.Inf_empty] }
end

lemma smul_mem_of_convex {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K) {x : E}
  {θ : ℝ} (hθ₁ : 0 ≤ θ) (hθ₂ : θ ≤ 1)
  (hx : x ∈ K) : θ • x ∈ K :=
begin
  have := hK.segment_subset zero_mem hx,
  rw segment_eq_image at this,
  apply this ⟨_, ⟨‹0 ≤ θ›, ‹_›⟩, by simp⟩,
end

lemma gauge_set_upward_closed {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K) (x : E) :
  ∀ ⦃a b⦄, a < b → a ∈ {y ∈ set.Ioi (0:ℝ) | y⁻¹ • x ∈ K} → b ∈ {y ∈ set.Ioi (0:ℝ) | y⁻¹ • x ∈ K} :=
begin
  rintro a b h ⟨ha₁ : _ < _, ha₂⟩,
  refine ⟨lt_trans ha₁ h, _⟩,
  dsimp,
  suffices : (b⁻¹ * a * a⁻¹) • x ∈ K,
  { simpa [mul_inv_cancel_right' (ne_of_gt ha₁)] using this },
  rw mul_smul,
  apply smul_mem_of_convex hK ‹0 ∈ K› _ _ ha₂,
  refine mul_nonneg (inv_nonneg.2 (by linarith)) (le_of_lt ha₁),
  rw [inv_mul_le_iff (lt_trans ha₁ h), mul_one],
  apply le_of_lt h
end

lemma zero_le_gauge {K : set E} (x : E) : 0 ≤ gauge K x :=
real.zero_le_Inf _ (λ x hx, le_of_lt hx.1)

lemma gauge_le_one_eq {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K) :
  {x | gauge K x ≤ 1} = ⋂ (θ ∈ set.Ioi (1:ℝ)), θ • K :=
begin
  ext,
  simp only [set.mem_Ioi, set.mem_Inter, set.mem_set_of_eq],
  split,
  { intros h θ hθ,
    have := (of_Inf_le _ (gauge_set_nonempty_of_absorbing absorbing) h hθ).2,
    rwa mem_smul_set_iff_inv_smul_mem,
    linarith,
    apply (gauge_set_upward_closed hK zero_mem _) },
  { intro h,
    apply Inf_le_of_forall_lt,
    apply gauge_set_bdd_below,
    intros ε hε,
    refine ⟨ε/2, by linarith, show 0 < 1 + ε/2, by linarith, _⟩,
    change _ ∈ _,
    rw ←mem_smul_set_iff_inv_smul_mem (show 1 + ε/2 ≠ 0, by linarith),
    apply h,
    linarith }
end

lemma gauge_lt_one_eq {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K) :
  {x | gauge K x < 1} = ⋃ (θ ∈ set.Ioo 0 (1:ℝ)), θ • K :=
begin
  ext,
  simp only [exists_prop, set.mem_Union, set.mem_Ioi, set.mem_set_of_eq],
  split,
  { intro h,
    obtain ⟨θ, ⟨_, _⟩, _⟩ := exists_lt_of_cInf_lt (gauge_set_nonempty_of_absorbing absorbing) h,
    refine ⟨θ, ⟨‹_›, ‹θ < 1›⟩, by rwa mem_smul_set_iff_inv_smul_mem (ne_of_gt ‹0 < θ›)⟩ },
  { rintro ⟨θ, ⟨_, _⟩, _⟩,
    apply cInf_lt_of_lt gauge_set_bdd_below ⟨‹0 < θ›, _⟩ ‹θ < 1›,
    change _ ∈ _,
    rwa ←mem_smul_set_iff_inv_smul_mem (ne_of_gt ‹0 < θ›) }
end

lemma gauge_lt_one_subset_self {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K) :
  {x | gauge K x < 1} ⊆ K :=
begin
  rw gauge_lt_one_eq hK zero_mem absorbing,
  apply set.bUnion_subset,
  intros θ hθ,
  rintro _ ⟨y, hy, rfl⟩,
  rw convex_iff_segment_subset at hK,
  simp_rw segment_eq_image at hK,
  apply hK zero_mem hy ⟨θ, Ioo_subset_Icc_self hθ, _⟩,
  simp,
end

lemma gauge_le_one_convex {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K) :
  convex {x | gauge K x ≤ 1} :=
begin
  rw gauge_le_one_eq hK zero_mem absorbing,
  refine convex_Inter (λ i, convex_Inter (λ (hi : _ < _), convex.smul _ hK)),
end

-- lemma mem_inv_smul_set_iff [field α] [mul_action α β] {a : α} (ha : a ≠ 0) (A : set β) (x : β) :
--   x ∈ a⁻¹ • A ↔ a • x ∈ A :=
-- by simp only [← image_smul, mem_image, inv_smul_eq_iff' ha, exists_eq_right]

-- lemma mem_smul_set_iff_inv_smul_mem [field α] [mul_action α β] {a : α} (ha : a ≠ 0) (A : set β)
--   (x : β) : x ∈ a • A ↔ a⁻¹ • x ∈ A :=
-- by rw [← mem_inv_smul_set_iff $ inv_ne_zero ha, inv_inv'

lemma gauge_le_one_of_mem {K : set E} (x : E) (hx : x ∈ K) : gauge K x ≤ 1 :=
real.Inf_le _ ⟨0, λ y hy, le_of_lt hy.1⟩ ⟨by norm_num, by simpa⟩

lemma gauge_le_of_mem {K : set E} (x : E) {θ : ℝ} (hθ : 0 < θ) (hx : θ⁻¹ • x ∈ K) : gauge K x ≤ θ :=
cInf_le gauge_set_bdd_below ⟨hθ, hx⟩

lemma convex_open_zero_mem_is_absorbing {C : set E} (zero_mem : (0:E) ∈ C) (hC : convex C)
  (hC₂ : is_open C) :
  ∀ (x : E), ∃ (θ:ℝ), 0 < θ ∧ θ • x ∈ C :=
begin
  intro x,
  let F : ℝ → E := λ t, t • x,
  have : continuous F,
  { continuity },
  let C' := preimage F C,
  have : is_open C' := this.is_open_preimage _ hC₂,
  have zero_mem : (0:ℝ) ∈ C',
  { change _ • _ ∈ C,
    simpa },
  rw metric.is_open_iff at this,
  obtain ⟨ε, hε₁, hε₂⟩ := this 0 zero_mem,
  refine ⟨_, half_pos hε₁, _⟩,
  change ε / 2 ∈ C',
  apply hε₂,
  simp only [metric.mem_ball, real.dist_0_eq_abs, abs_of_pos (half_pos hε₁), half_lt_self hε₁],
end

lemma gauge_lt_one_eq_self_of_open {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (hC₂ : is_open K) :
  {x | gauge K x < 1} = K :=
begin
  apply set.subset.antisymm,
  { apply gauge_lt_one_subset_self hK ‹_› (convex_open_zero_mem_is_absorbing zero_mem hK hC₂) },
  intros x hx,
  let F : ℝ → E := λ t, t • x,
  have : continuous F,
  { continuity },
  let K' := preimage F K,
  have : is_open K' := this.is_open_preimage _ hC₂,
  have one_mem : (1:ℝ) ∈ K',
  { change _ • _ ∈ K,
    simpa },
  obtain ⟨ε, _, hε₂⟩ := (metric.nhds_basis_closed_ball.1 _).1 (is_open_iff_mem_nhds.1 this 1 ‹_›),
  rw closed_ball_Icc at hε₂,
  have : (1 + ε)⁻¹ < 1,
  { rw inv_lt_one_iff,
    right,
    linarith },
  refine cInf_lt_of_lt gauge_set_bdd_below ⟨_, _⟩ ‹(1 + ε)⁻¹ < 1›,
  { change (0:ℝ) < _,
    rw inv_pos,
    linarith },
  change _ ∈ _,
  rw inv_inv',
  change _ ∈ K',
  apply hε₂,
  simp;
  linarith
end

lemma gauge_lt_one_of_mem_of_open {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (hK₂ : is_open K) (x : E) (hx : x ∈ K) :
  gauge K x < 1 :=
by rwa ←gauge_lt_one_eq_self_of_open hK zero_mem hK₂ at hx

lemma one_le_gauge_of_not_mem {K : set E} (hK : convex K) (zero_mem : (0:E) ∈ K)
  (hK₂ : is_open K) (x : E) (hx : x ∉ K) :
  1 ≤ gauge K x :=
begin
  rw ←gauge_lt_one_eq_self_of_open hK zero_mem hK₂ at hx,
  exact le_of_not_lt hx
end


lemma Inf_smul (K : set ℝ) {θ : ℝ} (hθ : 0 ≤ θ) :
  θ * Inf K = Inf (θ • K) :=
begin
  cases K.eq_empty_or_nonempty,
  { subst h,
    simp [real.Inf_empty] },
  by_cases h₁ : bdd_below K,
  { have : monotone (λ x, (θ:ℝ) * x),
    { exact monotone_mul_left_of_nonneg hθ },
    have z := map_cInf_of_continuous_at_of_monotone (continuous_mul_left θ).continuous_at
                  (monotone_mul_left_of_nonneg hθ) ‹_› ‹_›,
    dsimp at z,
    rw [z, ←set.image_smul],
    refl },
  { rw [real.Inf_of_not_bdd_below h₁, mul_zero],
    rcases eq_or_lt_of_le hθ with (rfl | hθ),
    { rw zero_smul_set h,
      have : (0 : set ℝ) = {0},
      { ext, simp },
      rw this,
      simp only [cInf_singleton] },
    { rw real.Inf_of_not_bdd_below,
      rintro ⟨t, ht⟩,
      apply h₁,
      refine ⟨t / θ, λ z hz, _⟩,
      rw div_le_iff hθ,
      apply ht,
      rw mul_comm,
      exact ⟨_, hz, smul_eq_mul _⟩ } },
end

lemma gauge_neg {K : set E} (balanced : ∀ x ∈ K, -x ∈ K) (x : E) :
  gauge K (-x) = gauge K x :=
begin
  have : ∀ x, -x ∈ K ↔ x ∈ K := λ x, ⟨λ h, by simpa using balanced _ h, balanced x⟩,
  change Inf _ = Inf _,
  simp_rw [smul_neg, this],
end

lemma gauge_mul_nonneg {K : set E}
  {θ : ℝ} (hθ : 0 ≤ θ) (x : E) :
gauge K (θ • x) = θ * gauge K x :=
begin
  rcases eq_or_lt_of_le hθ with (rfl | hθ'),
  { simp },
  change Inf _ = _ * Inf _,
  rw Inf_smul _ ‹0 ≤ θ›,
  congr' 1,
  ext β,
  simp only [set.mem_smul_set, set.mem_sep_eq, smul_eq_mul, set.mem_Ioi],
  split,
  { rintro ⟨hβ₁, hβ₂⟩,
    refine ⟨β * θ⁻¹, ⟨mul_pos ‹0 < β› (inv_pos.2 ‹0 < θ›), _⟩, _⟩,
    rwa [mul_inv', inv_inv', mul_smul],
    rw [mul_left_comm, mul_inv_cancel (ne_of_gt ‹0 < θ›), mul_one] },
  { rintro ⟨β, ⟨_, _⟩, rfl⟩,
    refine ⟨mul_pos ‹0 < θ› ‹0 < β›, _⟩,
    rwa [mul_inv_rev', ←mul_smul, mul_assoc, inv_mul_cancel (ne_of_gt ‹0 < θ›), mul_one] }
end

lemma gauge_homogeneous {K : set E} (balanced : ∀ x ∈ K, -x ∈ K)
  (θ : ℝ) (x : E) :
  gauge K (θ • x) = abs θ * gauge K x :=
begin
  rw ←gauge_mul_nonneg (abs_nonneg θ),
  cases le_total 0 θ,
  { rw abs_of_nonneg h },
  { rw [abs_of_nonpos h, neg_smul, gauge_neg balanced] }
end

lemma gauge_subadditive {K : set E} (hK : convex K)
  (absorbing : ∀ x, ∃ (θ : ℝ), 0 < θ ∧ θ • x ∈ K) (x y : E) :
  gauge K (x + y) ≤ gauge K x + gauge K y :=
begin
  apply le_of_lt_add,
  intros ε hε,
  obtain ⟨a, ⟨ha₁ : _ < _, ha₂⟩, ha₃ : _ < gauge _ _ + _⟩ :=
    exists_lt_of_cInf_lt (gauge_set_nonempty_of_absorbing absorbing)
      (lt_add_of_pos_right (gauge K x) (half_pos hε)),
  obtain ⟨b, ⟨hb₁ : _ < _, hb₂⟩, hb₃ : _ < gauge _ _ + _⟩ :=
    exists_lt_of_cInf_lt (gauge_set_nonempty_of_absorbing absorbing)
      (lt_add_of_pos_right (gauge K y) (half_pos hε)),
  suffices : gauge K (x + y) ≤ a + b,
  { linarith },
  rw convex_iff_div at hK,
  have := hK ha₂ hb₂ (le_of_lt ha₁) (le_of_lt hb₁) (by linarith),
  rw [smul_smul, smul_smul, mul_comm_div', mul_comm_div', ←mul_div_assoc, ←mul_div_assoc,
    mul_inv_cancel (ne_of_gt ha₁), mul_inv_cancel (ne_of_gt hb₁), ←smul_add] at this,
  apply gauge_le_of_mem,
  { linarith },
  simpa,
end

theorem zorn_reverse_subset {α : Type u} (S : set (set α))
  (h : ∀c ⊆ S, zorn.chain (⊆) c → ∃lb ∈ S, ∀ s ∈ c, lb ⊆ s) :
  ∃ m ∈ S, ∀a ∈ S, a ⊆ m → a = m :=
begin
  let rev : S → S → Prop := λ X Y, Y.1 ⊆ X.1,
  have hS : ∀ (c : set S), zorn.chain rev c → ∃ ub, ∀ a ∈ c, rev a ub,
  { intros c hc,
    obtain ⟨t, ht₁, ht₂⟩ := h (coe '' c) (by simp)
      (by { rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩ ne,
            apply (hc _ hx _ hy (λ t, ne (congr_arg coe t))).symm }),
    exact ⟨⟨_, ht₁⟩, λ a ha, ht₂ a ⟨_, ha, rfl⟩⟩ },
  obtain ⟨m, hm₁⟩ := zorn.exists_maximal_of_chains_bounded hS _,
  { refine ⟨m, m.prop, λ a ha ha₂, set.subset.antisymm ha₂ (hm₁ ⟨a, ha⟩ ha₂)⟩ },
  intros x y z xy yz,
  apply set.subset.trans yz xy
end

lemma continuous_linear_map_of_continuous_at_zero {E F : Type*} [normed_group E] [normed_space ℝ E]
  [normed_group F] [normed_space ℝ F] (f : E →ₗ[ℝ] F) (hf : continuous_at f (0:E)):
  continuous f :=
begin
  have : filter.tendsto f (nhds 0) (nhds 0), by simpa using hf.tendsto,
  exact (uniform_continuous_of_tendsto_zero this).continuous,
end

lemma continuous_at_of_exists_open {E : Type*} [normed_group E] [normed_space ℝ E]
  (f : E →ₗ[ℝ] ℝ) (hf : ∀ ε, 0 < ε → ∃ (U : set E), (0:E) ∈ U ∧ is_open U ∧ ∀ x ∈ U, ∥f x∥ < ε):
  continuous_at f (0:E) :=
begin
  intros U hU,
  rw metric.nhds_basis_ball.1 at hU,
  rcases hU with ⟨ε, hε₁, hε₂⟩,
  simp only [linear_map.map_zero] at hε₂,
  simp only [filter.mem_map],
  obtain ⟨V, hV₁, hV₂, hV₃⟩ := hf ε hε₁,
  rw mem_nhds_sets_iff,
  refine ⟨V, λ x hx, hε₂ _, hV₂, hV₁⟩,
  simp only [metric.mem_ball, dist_zero_right],
  apply hV₃ _ hx,
end

example {x : ℝ} (S : set E) : (-x • S) = -(x • S) :=
begin
  ext y,
  simp only [mem_neg],
  rw ←image_smul,
  rw ←image_smul,
  simp only [mem_image, neg_smul, neg_eq_iff_neg_eq],
  simp only [eq_comm],
end

lemma separate_convex_open_set {C : set E} (zero_mem : (0:E) ∈ C) (hC : convex C) (hC₂ : is_open C)
  (x₀ : E) (hx₀ : x₀ ∉ C) :
∃ (f : E →L[ℝ] ℝ), f x₀ = 1 ∧ ∀ x ∈ C, f x < 1 :=
begin
  let f : linear_pmap ℝ E ℝ :=
    linear_pmap.mk_span_singleton x₀ 1 (ne_of_mem_of_not_mem zero_mem hx₀).symm,
  have : f ⟨(1:ℝ) • x₀, by { dsimp, rw submodule.mem_span_singleton, refine ⟨1, rfl⟩ }⟩ = 1,
  { change linear_pmap.mk_span_singleton _ _ _ _ = _,
    rw linear_pmap.mk_span_singleton_apply,
    simp },
  rcases exists_extension_of_le_sublinear f (gauge C) _ _ _ with ⟨φ, hφ₁, hφ₂⟩,
  { refine ⟨⟨φ, _⟩, _, _⟩,
    { apply continuous_linear_map_of_continuous_at_zero,
      apply continuous_at_of_exists_open,
      intros ε hε,
      refine ⟨(ε • C) ∩ (-ε • C), ⟨_, _⟩, _, _⟩,
      { rw mem_smul_set,
        refine ⟨0, zero_mem, by simp⟩ },
      { rw mem_smul_set,
        refine ⟨0, zero_mem, by simp⟩ },
      { apply is_open_inter,
        { refine is_open_map_smul' hε.ne' _ hC₂ },
        { refine is_open_map_smul' (by linarith) _ hC₂ } },
      { rintro x ⟨hx₁, hx₂⟩,
        rw real.norm_eq_abs,
        rw abs_lt,
        split,
        { have : -ε⁻¹ • x ∈ C,
          { rcases hx₂ with ⟨y, _, rfl⟩,
            simpa [smul_smul, hε.ne'] },
          have := gauge_lt_one_of_mem_of_open hC zero_mem hC₂ (-ε⁻¹ • x) ‹_ ∈ C›,
          rw [neg_smul, ←smul_neg, gauge_mul_nonneg (inv_nonneg.2 hε.le), inv_mul_lt_iff hε,
            mul_one] at this,
          rw [neg_lt, ←linear_map.map_neg],
          apply lt_of_le_of_lt (hφ₂ _) ‹_› },
        { have : ε⁻¹ • x ∈ C,
          { rwa ←mem_smul_set_iff_inv_smul_mem hε.ne' },
          have := gauge_lt_one_of_mem_of_open hC zero_mem hC₂ (ε⁻¹ • x) ‹_›,
          rw gauge_mul_nonneg (inv_nonneg.2 hε.le) at this,
          rw [inv_mul_lt_iff hε, mul_one] at this,
          apply lt_of_le_of_lt (hφ₂ _) ‹_› } } },
    { dsimp,
      rw [←‹f ⟨_, _⟩ = 1›, ←hφ₁],
      simp, },
    { intros x hx,
      apply lt_of_le_of_lt (hφ₂ x),
      apply gauge_lt_one_of_mem_of_open hC zero_mem hC₂ _ hx } },
  { intros c hc x,
    apply gauge_mul_nonneg (le_of_lt hc) },
  { intros x y,
    apply gauge_subadditive,
    apply hC,
    apply convex_open_zero_mem_is_absorbing zero_mem hC hC₂ },
  { rintro ⟨x, hx⟩,
    change x ∈ submodule.span ℝ {x₀} at hx,
    obtain ⟨y, rfl⟩ := submodule.mem_span_singleton.1 hx,
    rw linear_pmap.mk_span_singleton_apply,
    simp only [mul_one, algebra.id.smul_eq_mul, submodule.coe_mk],
    cases lt_or_le 0 y,
    { rw [gauge_mul_nonneg (le_of_lt h), le_mul_iff_one_le_right h],
      apply one_le_gauge_of_not_mem hC ‹_› ‹_› _ hx₀ },
    apply le_trans ‹y ≤ 0›,
    apply zero_le_gauge }
end

lemma nonzero_linear_map_is_open_map (f : E →L[ℝ] ℝ) (hf : f ≠ 0) :
  is_open_map f :=
begin
  have : ∃ x₀, f x₀ ≠ 0,
  { by_contra h,
    push_neg at h,
    apply hf,
    ext,
    simp [h] },
  obtain ⟨x₁, hx₁⟩ : ∃ x₁, f x₁ = 1,
  { rcases this with ⟨x₀, hx₀⟩,
    refine ⟨(f x₀)⁻¹ • x₀, _⟩,
    simp [hx₀] },
  intros A hA,
  rw is_open_iff_mem_nhds,
  rintro _ ⟨a, ha, rfl⟩,
  let g : ℝ → E := λ x, a + x • x₁,
  have := (show continuous g, by continuity).is_open_preimage _ ‹is_open A›,
  rw is_open_iff_mem_nhds at this,
  specialize this 0 _,
  { change a + _ • _ ∈ A,
    simpa },
  rw metric.nhds_basis_ball.1 at this,
  rcases this with ⟨ε, hε₁, hε₂⟩,
  rw metric.nhds_basis_ball.1,
  refine ⟨ε, hε₁, _⟩,
  intros x hx,
  simp only [metric.mem_ball, real.dist_eq] at hx,
  have : x - f a ∈ g ⁻¹' A,
  { apply hε₂,
    rwa [metric.mem_ball, real.dist_0_eq_abs] },
  refine ⟨_, this, _⟩,
  simp [hx₁],
end

theorem geometric_hahn_banach_open {A B : set E}
  (hA₂ : convex A) (hA₃ : is_open A)
  (hB₂ : convex B)
  (disj : disjoint A B) :
∃ (f : E →L[ℝ] ℝ) (s : ℝ), (∀ a ∈ A, f a < s) ∧ (∀ b ∈ B, s ≤ f b) :=
begin
  rcases A.eq_empty_or_nonempty with (rfl | ⟨a₀, ha₀⟩),
  { refine ⟨0, 0, by simp, λ b hb, by simp⟩ },
  rcases B.eq_empty_or_nonempty with (rfl | ⟨b₀, hb₀⟩),
  { refine ⟨0, 1, λ a ha, by norm_num, by simp⟩ },
  let x₀ := b₀ - a₀,
  let C := {x₀} + A + -B,
  have : (0:E) ∈ C,
  { refine ⟨_ + a₀, -b₀, add_mem_add rfl ‹_›, neg_mem_neg.2 ‹_›, _⟩,
    simp },
  have : is_open C := hA₃.add_left.add_right,
  have : convex C,
  { apply convex.add,
    apply convex.add,
    apply convex_singleton,
    apply hA₂,
    apply ‹convex B›.neg_preimage },
  have : x₀ ∉ C,
  { intro hx₀,
    simp only [mem_add, mem_singleton_iff, mem_neg, exists_eq_left, exists_exists_and_eq_and,
      exists_and_distrib_left, add_assoc x₀, add_right_eq_self] at hx₀,
    rcases hx₀ with ⟨a, ha, b, hb, _⟩,
    apply disj ⟨ha, _⟩,
    convert hb,
    rwa ←add_eq_zero_iff_eq_neg },
  obtain ⟨f, hf₁, hf₂⟩ := separate_convex_open_set ‹0 ∈ C› ‹_› ‹_› _ ‹x₀ ∉ C›,
  have : f b₀ = f a₀ + 1,
  { rw f.map_sub at hf₁,
    rw ←hf₁,
    simp },
  have forall_lt : ∀ (a ∈ A) (b ∈ B), f a < f b,
  { intros a ha b hb,
    have := hf₂ (x₀ + a + -b) (add_mem_add (add_mem_add rfl ha) (neg_mem_neg.2 hb)),
    simp [‹f b₀ = _›] at this,
    linarith },
  have A_le_Inf : ∀ (a ∈ A), f a ≤ Inf (f '' B),
  { intros a ha,
    apply le_cInf ⟨f b₀, _⟩,
    { rintro _ ⟨b', _, rfl⟩,
      apply (forall_lt _ ‹a ∈ _› _ ‹b' ∈ _›).le },
    { apply mem_image_of_mem _ ‹b₀ ∈ B› } },
  refine ⟨f, Inf (f '' B), _, _⟩,
  { intros a ha,
    apply lt_of_le_of_ne,
    { apply A_le_Inf _ ha },
    intro same,
    let g : ℝ → E := λ x, a + x • x₀,
    have := (show continuous g, by continuity).is_open_preimage _ ‹is_open A›,
    rw is_open_iff_mem_nhds at this,
    specialize this 0 _,
    { change a + _ • _ ∈ A,
      simpa },
    rw metric.nhds_basis_closed_ball.1 at this,
    rcases this with ⟨ε, hε₁, hε₂⟩,
    have : ε ∈ metric.closed_ball (0:ℝ) ε,
    { simp [real.norm_eq_abs, abs_of_pos hε₁], },
    have : f (_ + _) ≤ _ := A_le_Inf _ (hε₂ ‹ε ∈ _›),
    rw [f.map_add] at this,
    simp only [algebra.id.smul_eq_mul, continuous_linear_map.map_smul, hf₁, ←same, mul_one] at this,
    linarith },
  { intros b hb,
    apply cInf_le ⟨f a₀, _⟩ (mem_image_of_mem _ hb),
    rintro _ ⟨b', hb', rfl⟩,
    apply (forall_lt _ ha₀ _ hb').le },
end

theorem geometric_hahn_banach_open_open {A B : set E}
  (hA₂ : convex A) (hA₃ : is_open A)
  (hB₂ : convex B) (hB₃ : is_open B)
  (disj : disjoint A B) :
∃ (f : E →L[ℝ] ℝ) (s : ℝ), (∀ a ∈ A, f a < s) ∧ (∀ b ∈ B, s < f b) :=
begin
  rcases A.eq_empty_or_nonempty with (rfl | ⟨a₀, ha₀⟩),
  { refine ⟨0, -1, by simp, λ b hb, by norm_num⟩ },
  rcases B.eq_empty_or_nonempty with (rfl | ⟨b₀, hb₀⟩),
  { refine ⟨0, 1, λ a ha, by norm_num, by simp⟩ },
  obtain ⟨f, s, hf₁, hf₂⟩ := geometric_hahn_banach_open hA₂ hA₃ hB₂ disj,
  have : f ≠ 0,
  { rintro rfl,
    have := hf₁ _ ha₀,
    simp only [continuous_linear_map.zero_apply] at this,
    have := hf₂ _ hb₀,
    simp only [continuous_linear_map.zero_apply] at this,
    linarith },
  have : is_open_map f := nonzero_linear_map_is_open_map _ ‹f ≠ 0›,
  refine ⟨f, s, hf₁, _⟩,
  suffices : f '' B ⊆ Ioi s,
  { intros b hb,
    apply this ⟨b, ‹_›, rfl⟩ },
  rw ←interior_Ici,
  apply interior_maximal,
  { rintro _ ⟨_, _, rfl⟩,
    refine hf₂ _ ‹_› },
  apply this _ hB₃,
end

open filter
open_locale topological_space

theorem closed_compact_separate {A B : set E}
  (hA₁ : convex A) (hA₄ : is_compact A) (hB₁ : convex B) (hB₃ : is_closed B) (disj : disjoint A B) :
  ∃ U V, is_open U ∧ is_open V ∧ convex U ∧ convex V ∧ A ⊆ U ∧ B ⊆ V ∧ disjoint U V :=
begin
  have : ∃ (n : ℕ), disjoint (A + metric.ball 0 (n+1)⁻¹) (B + metric.ball 0 (n+1)⁻¹),
  { by_contra h,
    push_neg at h,
    simp only [not_disjoint_iff, set.mem_add, metric.mem_ball, dist_zero_right,
      ←exists_and_distrib_left, ←exists_and_distrib_right, and_assoc] at h,
    choose z f f' g g' h₁ h₂ h₃ h₄ h₅ h₆ using h,
    obtain ⟨w, hw, φ, hφ₁, hφ₂ : tendsto (f ∘ _) _ _⟩ := hA₄.tendsto_subseq h₁,
    have : tendsto (g ∘ φ) at_top (𝓝 w),
    { have : tendsto (f - g) at_top (𝓝 0),
      { suffices : ∀ n, ∥(f - g) n∥ ≤ 2 * (n+1)⁻¹,
        { apply squeeze_zero_norm this,
          rw ←mul_zero (2:ℝ),
          apply tendsto.const_mul (2:ℝ),
          simp_rw inv_eq_one_div,
          apply tendsto_one_div_add_at_top_nhds_0_nat },
        intro n,
        simp only [pi.sub_apply],
        have : f n - g n = g' n - f' n,
        { rw [sub_eq_iff_eq_add', ←add_sub_assoc, h₆, ←h₃, add_sub_cancel] },
        rw this,
        apply le_trans (norm_sub_le _ _) _,
        rw two_mul,
        apply add_le_add (h₅ n).le (h₂ n).le },
      have : tendsto (f ∘ φ - g ∘ φ) at_top (𝓝 0),
      { have : f ∘ φ - g ∘ φ = (f - g) ∘ φ,
        { ext,
          simp },
        rw this,
        apply tendsto.comp ‹tendsto (f - g) at_top _› (strict_mono_tendsto_at_top hφ₁) },
      simpa using tendsto.sub hφ₂ ‹tendsto (f ∘ φ - g ∘ φ) at_top _› },
    have := mem_of_is_closed_sequential ‹is_closed B› (λ n, h₄ (φ n)) this,
    apply disj ⟨hw, ‹w ∈ B›⟩ },
  rcases this with ⟨n, hn⟩,
  refine ⟨_, _, _, _, hA₁.add _, hB₁.add _, _, _, hn⟩,
  { exact metric.is_open_ball.add_left },
  { exact metric.is_open_ball.add_left },
  { exact convex_ball 0 _ },
  { exact convex_ball 0 _ },
  { suffices : A + {0} ⊆ A + metric.ball (0:E) (n+1)⁻¹,
    { simpa },
    apply add_subset_add (set.subset.refl _),
    simp only [metric.mem_ball, norm_zero, dist_zero_left, singleton_subset_iff, inv_pos],
    norm_cast,
    simp },
  { suffices : B + {0} ⊆ B + metric.ball (0:E) (n+1)⁻¹,
    { simpa },
    apply add_subset_add (set.subset.refl _),
    simp only [metric.mem_ball, norm_zero, dist_zero_left, singleton_subset_iff, inv_pos],
    norm_cast,
    simp },
end

theorem geometric_hahn_banach_compact_closed {A B : set E}
  (hA₂ : convex A) (hA₄ : is_compact A)
  (hB₂ : convex B) (hA₃ : is_closed B)
  (disj : disjoint A B) :
  ∃ (f : E →L[ℝ] ℝ) (s t : ℝ), (∀ a ∈ A, f a < s) ∧ s < t ∧ (∀ b ∈ B, t < f b) :=
begin
  rcases A.eq_empty_or_nonempty with (rfl | hA),
  { refine ⟨0, -2, -1, by simp, by norm_num, λ b hb, by norm_num⟩ },
  rcases B.eq_empty_or_nonempty with (h | hB),
  { rw h,
    exact ⟨0, 1, 2, λ a ha, by norm_num, by norm_num, by simp⟩ },
  obtain ⟨U, V, hU, hV, hU₁, hV₁, AU, BV, disj'⟩ := closed_compact_separate hA₂ hA₄ hB₂ hA₃ disj,
  obtain ⟨f, s, hf₁, hf₂⟩ := geometric_hahn_banach_open_open hU₁ hU hV₁ hV disj',
  obtain ⟨x, hx₁, hx₂⟩ := hA₄.exists_forall_ge hA f.continuous.continuous_on,
  have : Sup (f '' A) = f x,
  { apply le_antisymm,
    { apply cSup_le (hA.image f) (by simpa) },
    refine le_cSup ⟨f x, _⟩ ⟨_, hx₁, rfl⟩,
    simpa [upper_bounds] },
  have : f x < s,
  { apply hf₁,
    apply AU,
    apply hx₁ },
  refine ⟨f, (f x + s)/2, s, _, by linarith, λ b hb, hf₂ b (BV hb)⟩,
  intros a ha,
  linarith [hx₂ a ha]
end

theorem geometric_hahn_banach_closed_compact {A B : set E}
  (hA₂ : convex A) (hA₄ : is_closed A)
  (hB₂ : convex B) (hA₃ : is_compact B)
  (disj : disjoint A B) :
  ∃ (f : E →L[ℝ] ℝ) (s t : ℝ), (∀ a ∈ A, f a < s) ∧ s < t ∧ (∀ b ∈ B, t < f b) :=
let ⟨f, s, t, hs, st, ht⟩ := geometric_hahn_banach_compact_closed hB₂ hA₃ hA₂ hA₄ disj.symm in
⟨-f, -t, -s, by simpa using ht, by simpa using st, by simpa using hs⟩

theorem geometric_hahn_banach_point_point {x y : E} (hxy : x ≠ y) :
  ∃ (f : E →L[ℝ] ℝ), f x < f y :=
begin
  have : convex {x} := convex_singleton x,
  have : is_compact {x} := compact_singleton,
  have : convex {y} := convex_singleton y,
  have : is_closed {y} := is_closed_singleton,
  have : disjoint ({x} : set E) {y},
  { simp [hxy.symm] },
  obtain ⟨f, s, t, hs, st, ht⟩ :=
    geometric_hahn_banach_compact_closed ‹_› ‹_› ‹convex {y}› ‹_› ‹_›,
  refine ⟨f, _⟩,
  linarith [hs x rfl, ht y rfl],
end

end separating
