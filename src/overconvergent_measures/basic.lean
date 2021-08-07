import data.real.basic
import algebra.big_operators.basic
import algebra.category.Group.basic
import topology.algebra.infinite_sum
import data.finset.basic
import data.equiv.basic
import analysis.normed_space.basic
import analysis.specific_limits
import data.equiv.basic
import category_theory.Fintype

import Mbar.bounded
import pseudo_normed_group.basic
import pseudo_normed_group.category

import for_mathlib.tsum
import for_mathlib.int_norm
import for_mathlib.int_basic

universe u

noncomputable theory
open_locale big_operators nnreal

section definitions

/-
structure c_measures (r : ℝ≥0) (c : ℝ≥0) (S : Fintype) :=
(to_fun     : S → ℤ → ℤ)
(summable   : ∀ s, summable (λ n, (∥ to_fun s n ∥₊ * r ^ n)))
(bdd        : ∀ s, tsum (λ n, (∥ to_fun s n ∥₊ * r ^ n)) ≤ c)
-/

structure oc_measures (r : ℝ≥0) (S : Fintype) :=
(to_fun     : S → ℤ → ℤ)
(summable'   : ∀ s, summable (λ n, ∥ to_fun s n ∥ * r ^ n))

variables {r : ℝ≥0} {S : Fintype}

instance : has_coe_to_fun (oc_measures r S) :=
⟨λ F, S → ℤ → ℤ, λ F, F.to_fun⟩

@[ext]
lemma oc_measures.ext (F G : oc_measures r S) : (F : S → ℤ → ℤ) = G → F = G :=
by { intros h, cases F, cases G, simpa }

lemma oc_measures.summable (F : oc_measures r S) (s : S) : summable (λ n, ∥ F s n ∥ * r ^ n) :=
  F.2 _

def add : oc_measures r S → oc_measures r S → oc_measures r S := λ F G,
{ to_fun := F + G,
  summable' := begin
    intros s,
    dsimp,
    have : ∀ n, ∥ F s n + G s n ∥ * r ^ n ≤ ∥ F s n ∥ * r ^ n + ∥ G s n ∥ * r ^ n,
    { intros n,
      rw ← add_mul,
      refine mul_le_mul (norm_add_le _ _) (le_refl _) _
        (add_nonneg (norm_nonneg _) (norm_nonneg _)),
      refine fpow_nonneg _ _,
      exact nnreal.coe_nonneg r },
    apply summable_of_nonneg_of_le _ this,
    { apply summable.add,
      exact F.summable s,
      exact G.summable s },
    { intros n,
      refine mul_nonneg (norm_nonneg _) _,
      refine fpow_nonneg _ _,
      exact nnreal.coe_nonneg r }
  end }

instance : has_add (oc_measures r S) := ⟨add⟩

@[simp]
lemma add_apply (F G : oc_measures r S) (s : S) (n : ℤ) : (F + G) s n = F s n + G s n := rfl

def zero : oc_measures r S :=
{ to_fun := 0,
  summable' := λ s, by simp [summable_zero] }

instance : has_zero (oc_measures r S) := ⟨zero⟩

@[simp]
lemma zero_apply (s : S) (n : ℤ) : (0 : oc_measures r S) s n = 0 := rfl

def neg : oc_measures r S → oc_measures r S := λ F,
{ to_fun := - F,
  summable' := λ s, by simp [F.summable] }

instance : has_neg (oc_measures r S) := ⟨neg⟩

@[simp]
lemma neg_apply (F : oc_measures r S) (s : S) (n : ℤ) : (-F) s n = - (F s n) := rfl

def sub : oc_measures r S → oc_measures r S → oc_measures r S := λ F G,
{ to_fun := F - G,
  summable' := sorry }

instance : has_sub (oc_measures r S) := ⟨sub⟩

@[simp]
lemma sub_apply (F G : oc_measures r S) (s : S) (n : ℤ) : (F - G) s n = F s n - G s n := rfl

instance {r S} : add_comm_group (oc_measures r S) :=
{ add_assoc := λ a b c, by { ext, simp [add_assoc] },
  zero_add := λ a, by { ext, simp },
  add_zero := λ a, by { ext, simp },
  nsmul := λ n F,
  { to_fun := nsmul n F,
    summable' := sorry },
  nsmul_zero' := λ F, by { ext, refl },
  nsmul_succ' := λ n F, by { ext, refl },
  sub_eq_add_neg := λ F G, by { ext, refl },
  gsmul := λ n F,
  { to_fun := gsmul n F,
    summable' := sorry },
  gsmul_zero' := λ F, by { ext, simpa, },
  gsmul_succ' := λ n F, by { ext, simpa, },
  gsmul_neg' := λ n F, by { ext, simpa, },
  add_left_neg := λ F, by { ext, simp },
  add_comm := λ a b, by { ext, dsimp, rw add_comm },
  ..(infer_instance : has_add _),
  ..(infer_instance : has_zero _),
  ..(infer_instance : has_neg _),
  ..(infer_instance : has_sub _) }

def filtration (r : ℝ≥0) (S : Fintype) (c : ℝ≥0) : set (oc_measures r S) :=
{ F | ∀ s, ∑' n, ∥ F s n ∥ * r ^ n ≤ c }

lemma exists_c (r : ℝ≥0) (S : Fintype) (F : oc_measures r S) : ∃ (c : ℝ≥0),
  ∀ s : S, ∑' n, ∥ F s n ∥ * r ^ n ≤ c :=
begin
  use ∑ s, ∑' n, ∥ F s n ∥ * r ^ n,
  { apply finset.sum_nonneg,
    rintros s -,
    apply tsum_nonneg,
    intros n,
    refine mul_nonneg (norm_nonneg _) (fpow_nonneg _ _),
    exact nnreal.coe_nonneg r, },
  { sorry },
end

/-
--should this be a coercion?
def c_measures_to_oc (r : ℝ≥0) (c : ℝ≥0) (S : Type*) (hS : fintype S) :
  c_measures r c S hS → oc_measures r S hS := λ f, ⟨f.to_fun, f.summable⟩

lemma oc_measures_are_c (r : ℝ≥0) (S : Type*) (hS : fintype S) (F : oc_measures r S hS) :
  ∃ (c : ℝ≥0) (f : c_measures r c S hS),
  c_measures_to_oc r c S hS f = F := sorry
-/

--needed?
instance png_oc_measures (r : ℝ≥0) (S : Fintype) :
  profinitely_filtered_pseudo_normed_group (oc_measures r S) :=
{ filtration := filtration r S,
  filtration_mono := λ c₁ c₂ h F hF s, le_trans (hF _) h,
  zero_mem_filtration := λ c s, by simp,
  neg_mem_filtration := λ c F h s, by simp [h s],
  add_mem_filtration := λ c₁ c₂ F₁ F₂ h₁ h₂ s, begin
    have : ∀ n, ∥ (F₁ + F₂) s n ∥ * r ^ n ≤ ∥ F₁ s n ∥ * r^n + ∥ F₂ s n ∥ * r^n,
    { intro n,
      rw ← add_mul,
      refine mul_le_mul (norm_add_le _ _) (le_refl _) (fpow_nonneg _ _)
        (add_nonneg (norm_nonneg _) (norm_nonneg _)),
      exact nnreal.coe_nonneg r },
    refine le_trans (tsum_le_tsum this _ _) _,
    { exact (F₁ + F₂).summable _ },
    { exact summable.add (F₁.summable _) (F₂.summable _) },
    { rw [nnreal.coe_add, tsum_add (F₁.summable _) (F₂.summable _)],
      exact add_le_add (h₁ _) (h₂ _) }
  end,
  topology := _,
  t2 := _,
  td := _,
  compact := _,
  continuous_add' := _,
  continuous_neg' := _,
  continuous_cast_le := _ }

variable {α : Type*}

def oc_functor (r : ℝ≥0) : Fintype.{u} ⥤ ProFiltPseuNormGrp.{u} :=
{ obj := λ S, ProFiltPseuNormGrp.of $ oc_measures r S,
  map := λ S T f,
  { to_fun := _,
    map_zero' := _,
    map_add' := _,
    bound' := _,
    continuous' := _ },
  map_id' := _,
  map_comp' := _ }

end definitions
