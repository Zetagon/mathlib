/-
Copyright (c) 2021 Alena Gusakov, Bhavik Mehta, Kyle Miller. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alena Gusakov, Bhavik Mehta, Kyle Miller
-/
import combinatorics.hall.basic
import topology.category.Top.limits

/-!
# Hall's Marriage Theorem

-/

open finset

namespace hall_marriage_theorem

/-- Wrap `finset` so we can give it its own category structure from a `directed_order` -/
def finset_poset (α : Type*) := finset α

/-- Function to help the typechecker when unwrapping a `finset_poset`. -/
def finset_poset.to_finset {α : Type*} (s : finset_poset α) : finset α := s

instance finset_poset.directed_order (α : Type*) : directed_order (finset_poset α) :=
({ directed := begin
    classical,
    intros s t,
    exact ⟨s ∪ t, subset_union_left s t, subset_union_right s t⟩,
  end } : directed_order (finset α))

/-- Function to help the typechecker when converting `⊆` for `finset` to `≤` for `finset_poset`. -/
def finset_poset.from_subset {α : Type*} {s s' : finset_poset α} (h : s.to_finset ⊆ s'.to_finset) :
  s ≤ s' := h

def hall_set {ι α : Type*} (t : ι → finset α) (ι' : finset ι) :=
  {f : ι' → α | function.injective f ∧ ∀ x, f x ∈ t x}

def hall_set_restrict {ι α : Type*} (t : ι → finset α) {ι' ι'' : finset ι} (h : ι' ⊆ ι'')
  (f : hall_set t ι'') : hall_set t ι' :=
begin
  refine ⟨λ i, f.val ⟨i, h i.property⟩, _⟩,
  cases f.property with hinj hc,
  refine ⟨_, λ i, hc ⟨i, h i.property⟩⟩,
  rintro ⟨i, hi⟩ ⟨j, hj⟩ hh,
  have key := hinj hh,
  simpa only [subtype.mk_eq_mk] using key,
end

def hall_restrict_functor {ι α : Type*} (t : ι → finset α) : (finset_poset ι)ᵒᵖ ⥤ Type* :=
{ obj := λ ι', hall_set t ι'.unop,
  map := λ ι' ι'' g, hall_set_restrict t (category_theory.le_of_hom g.unop) }

def hall_set_nonempty {ι α : Type*} [decidable_eq α] (t : ι → finset α)
  (h : (∀ (s : finset ι), s.card ≤ (s.bUnion t).card))
  (ι' : finset ι) : nonempty (hall_set t ι') :=
begin
  classical,
  refine ⟨classical.indefinite_description _ _⟩,
  apply (all_card_le_bUnion_card_iff_exists_injective' (λ (i : ι'), t i)).mp,
  intro s',
  convert h (s'.image coe) using 1,
  simp only [card_image_of_injective s' subtype.coe_injective],
  rw image_bUnion,
  congr,
end

noncomputable instance hall_set.fintype {ι α : Type*} [decidable_eq α]
  (t : ι → finset α) (ι' : finset ι) :
  fintype (hall_set t ι') :=
begin
  classical,
  rw hall_set,
  let g : hall_set t ι' → (ι' → ι'.bUnion t),
  { rintro f i,
    refine ⟨f.val i, _⟩,
    rw mem_bUnion,
    exact ⟨i, i.property, f.property.2 i⟩ },
  apply fintype.of_injective g,
  intros f f' h,
  simp only [g, function.funext_iff, subtype.val_eq_coe] at h,
  ext a,
  exact h a,
end

end hall_marriage_theorem

open hall_marriage_theorem

theorem finset.all_card_le_bUnion_card_iff_exists_injective
  {ι α : Type*} [decidable_eq α] (t : ι → finset α) :
  (∀ (s : finset ι), s.card ≤ (s.bUnion t).card) ↔
    (∃ (f : ι → α), function.injective f ∧ ∀ x, f x ∈ t x) :=
begin
  letI : category_theory.category (set α) := by apply_instance,
  split,
  swap,
  { rintro ⟨f, hf₁, hf₂⟩ s,
    rw ←finset.card_image_of_injective s hf₁,
    apply finset.card_le_of_subset,
    intro _,
    rw [finset.mem_image, finset.mem_bUnion],
    rintros ⟨x, hx, rfl⟩,
    exact ⟨x, hx, hf₂ x⟩, },
  intro h,
  haveI : ∀ (ι' : (finset_poset ι)ᵒᵖ), nonempty ((hall_restrict_functor t).obj ι') :=
    λ ι', hall_set_nonempty t h ι'.unop,
  classical,
  haveI : Π (ι' : (finset_poset ι)ᵒᵖ), fintype ((hall_restrict_functor t).obj ι') := begin
    intro ι',
    rw [hall_restrict_functor],
    apply_instance,
  end,
  obtain ⟨u, hu⟩ := nonempty_sections_of_fintype_inverse_system (hall_restrict_functor t),
  refine ⟨_, _, _⟩,
  { exact λ i, (u (opposite.op ({i} : finset ι))).val
                 ⟨i, by simp only [opposite.unop_op, mem_singleton]⟩, },
  { intros i i',
    have subi : ({i} : finset ι) ⊆ {i,i'} := by simp,
    have subi' : ({i'} : finset ι) ⊆ {i,i'} := by simp,
    rw [←hu (category_theory.hom_of_le (finset_poset.from_subset subi)).op,
        ←hu (category_theory.hom_of_le (finset_poset.from_subset subi')).op],
    let uii' := u (opposite.op ({i,i'} : finset ι)),
    exact λ h, subtype.mk_eq_mk.mp (uii'.property.1 h), },
  { intro i,
    apply (u (opposite.op ({i} : finset ι))).property.2, },
end

/-- Given a relation such that the image of every singleton set is finite, then the image of every
finite set is finite. -/
instance {α β : Type*} [decidable_eq β]
  (r : α → β → Prop) [∀ (a : α), fintype (rel.image r {a})]
  (A : finset α) : fintype (rel.image r A) :=
begin
  letI : preorder (finset α) := by apply_instance,
  have h : rel.image r A = (A.bUnion (λ a, (rel.image r {a}).to_finset) : set β),
  { ext, simp [rel.image], },
  rw [h],
  apply finset_coe.fintype,
end

/--
This is a version of Hall's Marriage Theorem in terms of a relation
between types `α` and `β` such that `α` is finite and the image of
each `x : α` is finite (it suffices for `β` to be finite).  There is
an injective function `α → β` respecting the relation iff every subset of
`k` terms of `α` is related to at least `k` terms of `β`.

If `[fintype β]`, then `[∀ (a : α), fintype (rel.image r {a})]` is automatically implied.
-/
theorem fintype.all_card_le_rel_image_card_iff_exists_injective
  {α β : Type*} [decidable_eq β]
  (r : α → β → Prop) [∀ (a : α), fintype (rel.image r {a})] :
  (∀ (A : finset α), A.card ≤ fintype.card (rel.image r A)) ↔
    (∃ (f : α → β), function.injective f ∧ ∀ x, r x (f x)) :=
begin
  let r' := λ a, (rel.image r {a}).to_finset,
  have h : ∀ (A : finset α), fintype.card (rel.image r A) = (A.bUnion r').card,
  { intro A,
    rw ←set.to_finset_card,
    apply congr_arg,
    ext b,
    simp [rel.image], },
  have h' : ∀ (f : α → β) x, r x (f x) ↔ f x ∈ r' x,
  { simp [rel.image], },
  simp only [h, h'],
  apply finset.all_card_le_bUnion_card_iff_exists_injective,
end

/--
This is a version of Hall's Marriage Theorem in terms of a relation between finite types.
There is an injective function `α → β` respecting the relation iff every subset of
`k` terms of `α` is related to at least `k` terms of `β`.

It is like `fintype.all_card_le_rel_image_card_iff_exists_injective` but uses `finset.filter`
rather than `rel.image`.
-/
theorem fintype.all_card_le_filter_rel_iff_exists_injective
  {α β : Type*} [fintype β]
  (r : α → β → Prop) [∀ a, decidable_pred (r a)] :
  (∀ (A : finset α), A.card ≤ (univ.filter (λ (b : β), ∃ a ∈ A, r a b)).card) ↔
    (∃ (f : α → β), function.injective f ∧ ∀ x, r x (f x)) :=
begin
  haveI := classical.dec_eq β,
  let r' := λ a, univ.filter (λ b, r a b),
  have h : ∀ (A : finset α), (univ.filter (λ (b : β), ∃ a ∈ A, r a b)) = (A.bUnion r'),
  { intro A,
    ext b,
    simp, },
  have h' : ∀ (f : α → β) x, r x (f x) ↔ f x ∈ r' x,
  { simp, },
  simp_rw [h, h'],
  apply finset.all_card_le_bUnion_card_iff_exists_injective,
end