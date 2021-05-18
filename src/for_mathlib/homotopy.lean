import algebra.homology.homotopy

universes v u

open_locale classical
noncomputable theory

open category_theory category_theory.limits homological_complex

variables {ι : Type*}
variables {V : Type u} [category.{v} V] [preadditive V]
variables {c : complex_shape ι} {C₁ C₂ C₃ : homological_complex V c}
variables {f g f₁ g₁ : C₁ ⟶ C₂} {f₂ g₂ : C₂ ⟶ C₃}

-- namespace category_theory

@[simps]
def homotopy.of_eq (h : f = g) : homotopy f g :=
{ hom := 0,
  zero' := λ _ _ _, rfl,
  comm := by { intros, simp only [add_monoid_hom.map_zero, zero_add, h] } }

@[simps]
def homotopy.comp (h₁ : homotopy f₁ g₁) (h₂ : homotopy f₂ g₂) : homotopy (f₁ ≫ f₂) (g₁ ≫ g₂) :=
(h₁.comp_right _).trans (h₂.comp_left _)

-- end category_theory
