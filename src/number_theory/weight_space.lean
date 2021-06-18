import number_theory.L_functions

def zmod.topological_space (d : ℕ) : topological_space (zmod d) := ⊥

local attribute [instance] zmod.topological_space

--instance is_this_needed : topological_space (units (zmod d) × units ℤ_[p]) := infer_instance

#check continuous_map

set_option old_structure_cmd true
/-- A-valued points of weight space -/ --shouldn't this be a category theory statement?
@[ancestor continuous_map monoid_hom]
structure weight_space (p : ℕ) [fact p.prime] (d : ℕ) (A : Type*) [topological_space A] [mul_one_class A]
  extends monoid_hom ((units (zmod d)) × (units ℤ_[p])) A, C((units (zmod d)) × (units ℤ_[p]), A)
--generalize domain to a compact space?

attribute [nolint doc_blame] weight_space.to_continuous_map
attribute [nolint doc_blame] weight_space.to_monoid_hom

namespace weight_space

variables (A : Type*) [topological_space A] [mul_one_class A] (p : ℕ) [fact p.prime] (d : ℕ) (hd : gcd d p = 1)

instance : has_coe_to_fun (weight_space p d A) :=
{ F := _,
  coe := λ w, w.to_fun }

example (w : weight_space p d A) (t : units (zmod d) × units (ℤ_[p])) : A := w t

/-lemma weight_space_continuous_to_fun {A : Type*} [topological_space A] [mul_one_class A]
  (f : weight_space p d A) : continuous f.to_fun :=
  (weight_space.to_continuous_map f).continuous_to_fun-/

example {α β : Type*} [topological_space α] [topological_space β] [group β] [topological_group β]
(f g h : α → β) [continuous f] [continuous g] [continuous h] : f*g*h = f*(g*h) :=
begin
  refine mul_assoc f g h,
end

lemma ext_iff (A : Type*) [topological_space A] [mul_one_class A]
  (a b : (units (zmod d)) × (units ℤ_[p]) →* A) [ha : continuous a] [hb : continuous b] :
  (⟨a.to_fun, monoid_hom.map_one' a, monoid_hom.map_mul' a, ha⟩ : weight_space p d A) =
  (⟨b.to_fun, monoid_hom.map_one' b, monoid_hom.map_mul' b, hb⟩ : weight_space p d A) ↔
  a.to_fun = b.to_fun :=
begin
  split,
  { rintros h, simp only [monoid_hom.to_fun_eq_coe] at h, simp [h], },
  { rintros h, simp only [monoid_hom.to_fun_eq_coe], simp at h, simp [h], },
end

variables {A} {p} {d}

@[ext] lemma ext (w₁ w₂ : weight_space p d A)
  (h : ∀ u : (units (zmod d)) × (units ℤ_[p]), w₁ u = w₂ u) : w₁ = w₂ :=
begin
  cases w₁,
  cases w₂,
  simp only [prod.forall],
  ext u,
  apply h,
end

noncomputable instance (A : Type*) [topological_space A] [comm_group A] [topological_group A] :
  has_one (weight_space p d A) :=
{ one := ⟨monoid_hom.has_one.one, rfl, is_mul_hom.map_mul 1, continuous_const ⟩ }

instance (A : Type*) [topological_space A] [comm_group A] [topological_group A] :
  has_mul (weight_space p d A) :=
{ mul := λ f g, ⟨f.to_fun * g.to_fun,
    begin simp only [pi.mul_apply], repeat {rw weight_space.map_one',}, rw one_mul, end,
    λ x y, begin simp only [pi.mul_apply], repeat {rw weight_space.map_mul',},
    refine mul_mul_mul_comm (f.to_fun x) (f.to_fun y) (g.to_fun x) (g.to_fun y), end,
    -- can we pls have a tactic to solve commutativity and associativity
    continuous.mul (weight_space.continuous_to_fun f) (weight_space.continuous_to_fun g)⟩, }

noncomputable instance (A : Type*) [topological_space A] [comm_group A] [topological_group A] :
  monoid (weight_space p d A) := --is group really needed
{
  mul := (*),
  mul_assoc := λ f g h, begin
    ext,
    apply mul_assoc,
  end,
  --what is simp only doing
  one := has_one.one,
  one_mul := λ a,
  begin
    --have f : (1 * a).to_fun = a.to_fun, sorry,
    --have := (ext p d A _ _).2 f, sorry,
    sorry,
  end,
  --have := one_mul a.to_fun, have h : (1 : weight_space p d A).to_fun = 1, simp only,
  --apply weight_space.mk.inj, refine one_mul a.to_fun, sorry, end,
  mul_one := begin sorry, end,
--  inv := λ f, ⟨λ x, (f.to_fun x)⁻¹, begin sorry end, _, _⟩,
--  mul_left_inv := sorry,
}

--instance : has_mod ℤ_[p] := sorry

lemma padic_units_modp_units (b : units ℤ_[p]) :
  is_unit ((padic_int.appr (b : ℤ_[p]) 1) : (zmod p)) := sorry

example {α β : Type*} (f : α → β) (h : function.surjective f) (b : β) : ∃ a, f a = b :=
begin
  have := h b,
  exact h b,
end

lemma blahs' (a : units ℤ_[p]) : ∃ (b : roots_of_unity (nat.to_pnat' p) ℤ_[p]),
  (a - b : ℤ_[p]) ∈ (ideal.span {p} : ideal ℤ_[p]) :=
begin
  set f : roots_of_unity (nat.to_pnat' p) ℤ_[p] → units (zmod p) :=
    λ b, classical.some (padic_units_modp_units p (b : units ℤ_[p])) with hf,
  have h : function.surjective f, sorry,
  set b := classical.some (h (classical.some (padic_units_modp_units p a))) with hb,
  refine ⟨b, _⟩,
  have h1b : padic_int.appr (a - b : ℤ_[p]) 1 = 0, sorry,
  rw ←sub_zero (a - b : ℤ_[p]),
  show (a - b : ℤ_[p]) - ((0 : ℕ) : ℤ_[p]) ∈ ideal.span {↑p}, rw ←h1b,
  have := padic_int.appr_spec 1 (a - b : ℤ_[p]), rw pow_one at this, exact this,
end

lemma blahs (a : units ℤ_[p]) : ∃ (b : units ℤ_[p]),
  (a - b : ℤ_[p]) ∈ (ideal.span {p} : ideal ℤ_[p]) :=
begin
  obtain ⟨b, hb⟩ := blahs' p a, refine ⟨(b : units ℤ_[p]), hb⟩,
end

/-lemma inj' {B : Type*} [monoid B] (inj : B → A) [hinj : (function.injective inj)] :
  ∃ inj' : (units B) → (units A), ∀ (x : (units B)), inj' x = inj (x : B) -/

variables [complete_space A] (inj : units ℤ_[p] → A) [fact (function.injective inj)]

variables (m : ℕ) (χ : mul_hom (units (zmod (d*(p^m)))) A) (w : weight_space p d A)
--variables (d : ℕ) (hd : gcd d p = 1) (χ : dirichlet_char_space A p d) (w : weight_space A p)
--need χ to be primitive

/-- Extending the primitive dirichlet character χ with conductor (d* p^m) -/
def pri_dir_char_extend : mul_hom ((units (zmod d)) × (units ℤ_[p])) A := sorry
--should this be def or lemma? ; units A instead of A ; use monoid_hom instead of mul_hom
-- so use def not lemma, because def gives Type, lemma gives Prop

--variables (ψ : pri_dir_char_extend A p d)

/-- The Teichmuller character defined on `p`-adic units -/
noncomputable def teichmuller_character (a : units ℤ_[p]) : A := inj (classical.some (blahs p a))

def clopen_basis : set (set ℤ_[p]) := {x : set ℤ_[p] | ∃ (n : ℕ) (a : zmod (p^n)),
  x = set.preimage (padic_int.to_zmod_pow n) a }

lemma proj_lim_preimage_clopen (n : ℕ) (a : zmod (d*(p^n))) :
  is_clopen (set.preimage (padic_int.to_zmod_pow n) a : set ℤ_[p]) := sorry

--example {α β : Type*} {s : set α} {t : set β} : (s.prod t)ᶜ = ((set.univ : α).prod tᶜ) ∪

lemma is_closed_prod {α β : Type*} [topological_space α] [topological_space β] {s : set α}
  {t : set β} (h : is_closed s ∧ is_closed t) : is_closed (s.prod t) :=
begin
  fconstructor,
  rw is_open_iff_forall_mem_open, rintros x hx, cases h with h1 h2,
  rw ←is_open_compl_iff at *, rw is_open_iff_forall_mem_open at *,
  sorry
end

lemma is_clopen_prod {α β : Type*} [topological_space α] [topological_space β] {s : set α}
  {t : set β} (hs : is_clopen s) (ht : is_clopen t) : is_clopen (s.prod t) :=
begin
  split,
  { rw is_open_prod_iff', fconstructor, refine ⟨(hs).1, (ht).1⟩, },
  { apply is_closed_prod, refine ⟨(hs).2, (ht).2⟩, },
end

lemma is_clopen_discrete {α : Type*} [topological_space α] [discrete_topology α] (b : α) :
  is_clopen ({b} : set α) :=
 ⟨is_open_discrete _, is_closed_discrete _⟩

def clopen_basis' : set (clopen_sets ((zmod d) × ℤ_[p])) :=
{x : clopen_sets ((zmod d) × ℤ_[p]) | ∃ (n : ℕ) (a : zmod (d * (p^n))),
  x = ⟨({a} : set (zmod d)).prod (set.preimage (padic_int.to_zmod_pow n) (a : set (zmod (p^n)))),
    is_clopen_prod (is_clopen_discrete (a : zmod d))
      (proj_lim_preimage_clopen p d n a) ⟩ }

/-def clopen_basis' : set (clopen_sets ((zmod d) × ℤ_[p])) :=
{x : clopen_sets ((zmod d) × ℤ_[p]) | ∃ (n : ℕ) (a : zmod (p^n)) (b : zmod d),
  x = ⟨({b} : set (zmod d)).prod (set.preimage (padic_int.to_zmod_pow n) a),
    is_clopen_prod (is_clopen_discrete b) (proj_lim_preimage_clopen p n a) ⟩ }-/

lemma clopen_basis_clopen : topological_space.is_topological_basis (clopen_basis p) ∧
  ∀ x ∈ (clopen_basis p), is_clopen x := sorry

--lemma char_fn_basis_of_loc_const : is_basis A (@char_fn ℤ_[p] _ _ _ _ A _ _ _) := sorry

--instance : semimodule A (units ℤ_[p]) := sorry
-- a + pZ_p a from0 to (p - 2) [for linear independence]
-- set up a bijection between disj union
-- construct distri prove eval at canonical basis gives (a,n)

variables {c : ℤ}

def E_c (hc : gcd c p = 1) := λ (n : ℕ) (a : (zmod (d * (p^n)))), fract ((a : ℤ) / (p^(n + 1)))
    - c * fract ((a : ℤ) / (c * (p^(n + 1)))) + (c - 1)/2

--instance {α : Type*} [topological_space α] : semimodule A (locally_constant α A) := sorry

instance : compact_space (zmod d) := sorry
instance pls_work : compact_space (zmod d × ℤ_[p]) := sorry
instance sigh : totally_disconnected_space (zmod d × ℤ_[p]) := sorry

def bernoulli_measure (hc : gcd c p = 1) := {x : locally_constant (zmod d × ℤ_[p]) A →ₗ[A] A |
  ∀ U : (clopen_basis' p d), x (char_fn (zmod d × ℤ_[p]) U.val) =
    E_c p d hc (classical.some U.prop) (classical.some (classical.some_spec U.prop)) }

lemma bernoulli_measure_nonempty (hc : gcd c p = 1) : nonempty (bernoulli_measure A p d hc) :=
  sorry

/-instance (c : ℤ) (hc : gcd c p = 1) : distribution' (ℤ_[p]) :=
{
  phi := (classical.choice (bernoulli_measure_nonempty p c hc)).val
} -/

/-lemma subspace_induces_locally_constant (U : set X) [hU : semimodule A (locally_constant ↥U A)]
  (f : locally_constant U A) :
  ∃ (g : locally_constant X A), f.to_fun = (set.restrict g.to_fun U) := sorry -/

example {A B C D : Type*} (f : A → B) (g : C → D) : A × C → B × D := by refine prod.map f g

lemma subspace_induces_locally_constant (f : locally_constant (units (zmod d) × units ℤ_[p]) A) :
  ∃ (g : locally_constant (zmod d × ℤ_[p]) A),
    f.to_fun = g.to_fun ∘ (prod.map (coe : units (zmod d) → zmod d) (coe : units ℤ_[p] → ℤ_[p])) :=
sorry
--generalize to units X

instance is_this_even_true : compact_space (units (zmod d) × units ℤ_[p]) := sorry
instance why_is_it_not_recognized : t2_space (units (zmod d) × units ℤ_[p]) := sorry
instance so_many_times : totally_disconnected_space (units (zmod d) × units ℤ_[p]) := sorry

noncomputable lemma bernoulli_measure_of_measure (hc : gcd c p = 1) :
  measures'' (units (zmod d) × units ℤ_[p]) A :=
begin
  constructor, swap,
  constructor,
  constructor, swap 3, rintros f,
  choose g hg using subspace_induces_locally_constant A p d f, --cases does not work as no prop
  exact (classical.choice (bernoulli_measure_nonempty A p d hc)).val g,
  { sorry, },
  { sorry, },
  { sorry, },
end
--function on clopen subsets of Z/dZ* x Z_p* or work in Z_p and restrict
--(i,a + p^nZ_p) (i,d) = 1

instance : nonempty (units ℤ_[p]) := sorry

lemma cont_paLf : continuous (λ (a : (units (zmod d) × units ℤ_[p])),
  ((pri_dir_char_extend A p d) a) * ((teichmuller_character A p inj (a.snd)) : A)^(p - 2)
  * (w.to_fun a : A)) :=
sorry

instance is_an_import_missing : nonempty (units (zmod d) × units ℤ_[p]) := sorry

noncomputable def p_adic_L_function [h : function.injective inj] (hc : gcd c p = 1) := --h wont go in the system if you put it in [], is this independent of c?
  integral (units (zmod d) × units ℤ_[p]) A _ (bernoulli_measure_of_measure A p d hc)
⟨(λ (a : (units (zmod d) × units ℤ_[p])), ((pri_dir_char_extend A p d) a) *
  ((teichmuller_character A p inj a.snd))^(p - 2) * (w.to_fun a : A)), cont_paLf A p d inj w ⟩
