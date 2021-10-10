import for_mathlib.presieve
import condensed.proetale_site

/-!
# Condensed sets

Defines the category of condensed sets and condensed structures.
*Strictly speaking* these are pyknotic, but we hope that in the context of Lean's type theory they
serve the same purpose.
-/

open category_theory category_theory.limits opposite

universes w v u

variables (C : Type u) [category.{v} C]

@[derive category]
def condensed := {F : Profinite.{w}ᵒᵖ ⥤ C |
  ∀ ⦃B : Profinite.{w}⦄ (R : presieve B) (T : C),
    R ∈ proetale_pretopology B → R.is_sheaf_for' (F ⋙ coyoneda.obj (op T)) }

example : category (condensed.{w} (Type u)) := infer_instance
example : category (condensed.{u} (Type (u+37))) := infer_instance

def is_proetale_sheaf_of_types (P : Profinite.{w}ᵒᵖ ⥤ Type u) : Prop := ∀
-- a finite family of morphisms with base B
(α : Type w) [fintype α] (B : Profinite.{w}) (X : α → Profinite.{w}) (f : Π a, X a ⟶ B)
-- jointly surjective
(surj : ∀ b : B, ∃ a (x : X a), f a x = b)
-- family of terms
(x : Π a, P.obj (op (X a)))
-- which is compatible
(compat : ∀ (a b : α) (Z : Profinite.{w}) (g₁ : Z ⟶ X a) (g₂ : Z ⟶ X b),
  (g₁ ≫ f a = g₂ ≫ f b) → P.map g₁.op (x a) = P.map g₂.op (x b)),
-- the actual condition
∃! t : P.obj (op B), ∀ a : α, P.map (f a).op t = x a

theorem is_proetale_sheaf_of_types_iff (P : Profinite.{w}ᵒᵖ ⥤ Type u) :
  is_proetale_sheaf_of_types P ↔
  (∀ (B : Profinite.{w}) (R : presieve B), R ∈ proetale_pretopology B → R.is_sheaf_for' P) :=
begin
  split,
  { intros h B S hS,
    obtain ⟨α, _, X, f, surj, rfl⟩ := hS,
    resetI,
    intros x hx,
    specialize h α B X f surj,
    dsimp [presieve.family_of_elements'] at x,
    let y : Π (a : α), P.obj (op (X a)) := λ a, x (f a) _,
    swap,
    { rw presieve.mem_of_arrows_iff, use [a, rfl], simp },
    specialize h y _,
    { intros a b Z g₁ g₂ hh,
      dsimp [presieve.family_of_elements'.compatible] at hx,
      apply hx,
      assumption },
    convert h,
    ext t,
    split,
    { intro hh,
      intros a,
      apply hh },
    { intros hh Y g hg,
      rw presieve.mem_of_arrows_iff at hg,
      obtain ⟨u,rfl,rfl⟩ := hg,
      simp [hh] } },
  { introsI h α _ B X f surj x compat,
    let R : presieve B := presieve.of_arrows X f,
    have hR : R ∈ proetale_pretopology B := ⟨α, infer_instance, X, f, surj, rfl⟩,
    have hhh : ∀ ⦃Y⦄ (g : Y ⟶ B) (hg : R g), ∃ (a : α) (ha : Y = X a), g = eq_to_hom ha ≫ f a,
    { intros Y g hg,
      rcases hg with ⟨a⟩,
      use [a, rfl],
      simp },
    let aa : Π ⦃Y⦄ (g : Y ⟶ B) (hg : R g), α := λ Y g hg, (hhh g hg).some,
    have haa : ∀ ⦃Y⦄ (g : Y ⟶ B) (hg : R g), Y = X (aa g hg) :=
      λ Y g hg, (hhh g hg).some_spec.some,
    have haa' : ∀ ⦃Y⦄ (g : Y ⟶ B) (hg : R g), g = eq_to_hom (haa g hg) ≫ f (aa g hg) :=
      λ Y g hg, (hhh g hg).some_spec.some_spec,
    let y : R.family_of_elements' P := λ Y g hg, P.map (eq_to_hom (haa g hg)).op (x (aa g hg)),
    specialize h B R hR y _,
    { rintros Y₁ Y₂ Z g₁ g₂ f₁ f₂ ⟨a⟩ ⟨b⟩ hh,
      change (P.map _ ≫ P.map _) _ = (P.map _ ≫ P.map _) _,
      simp_rw [← P.map_comp, ← op_comp],
      apply compat,
      simp,
      convert hh,
      all_goals {
        symmetry,
        apply haa' } },
    convert h,
    ext t,
    split,
    { intros hh Y g hg,
      dsimp [y],
      conv_lhs { rw haa' g hg },
      dsimp,
      simp [hh] },
    { intros hh a,
      have : R (f a),
      { dsimp [R],
        rw presieve.mem_of_arrows_iff,
        use [a, rfl],
        simp },
      rw hh (f a) this,
      specialize haa (f a) this,
      dsimp [y],
      specialize compat (aa (f a) this) a (X a) (eq_to_hom _) (𝟙 _) _,
      apply haa,
      simp,
      symmetry,
      apply haa',
      simpa using compat } }
end

def is_proetale_sheaf (P : Profinite.{w}ᵒᵖ ⥤ C) : Prop := ∀
-- a finite family of morphisms with base B
(α : Type w) [fintype α] (B : Profinite.{w}) (X : α → Profinite.{w}) (f : Π a, X a ⟶ B)
-- jointly surjective
(surj : ∀ b : B, ∃ a (x : X a), f a x = b)
-- test object
(T : C)
-- family of moprhisms
(x : Π a, T ⟶ P.obj (op (X a)))
-- which is compatible
(compat : ∀ (a b : α) (Z : Profinite.{w}) (g₁ : Z ⟶ X a) (g₂ : Z ⟶ X b),
  (g₁ ≫ f a = g₂ ≫ f b) → x a ≫ P.map g₁.op = x b ≫ P.map g₂.op),
-- the actual condition
∃! t : T ⟶ P.obj (op B), ∀ a : α, t ≫ P.map (f a).op = x a

theorem is_proetale_sheaf_iff (P : Profinite.{w}ᵒᵖ ⥤ C) :
  is_proetale_sheaf C P ↔
  (∀ (T : C) (B : Profinite.{w}) (R : presieve B),
    R ∈ proetale_pretopology B → R.is_sheaf_for' (P ⋙ coyoneda.obj (op T))) :=
begin
  split,
  { intros h T,
    rw ← is_proetale_sheaf_of_types_iff,
    introsI α _ B X f surj x compat,
    exact h α B X f surj T x compat },
  { introsI h α _ B X f surj T x compat,
    specialize h T,
    rw ← is_proetale_sheaf_of_types_iff at h,
    exact h α B X f surj x compat }
end

/-
/-- The category of condensed sets. -/
@[derive category]
def CondensedSet : Type (u+2) := SheafOfTypes.{u+1} proetale_topology.{u}

/-- The category of condensed `A`. Applying this to `A = Type*` is *equivalent* but not the same
as `CondensedSet`. -/
@[derive category]
def Condensed (A : Type (u+2)) [large_category A] : Type (u+2) := Sheaf.{u+1} proetale_topology A

example : category.{u+1} (Condensed Ab.{u+1}) := infer_instance
example : category.{u+1} (Condensed Ring.{u+1}) := infer_instance

open opposite

noncomputable theory

variables (X : (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1))

lemma maps_comm {S S' : as_small.{u+1} Profinite.{u}} (f : S' ⟶ S) :
  X.map f.op ≫ X.map (pullback.fst : pullback f f ⟶ S').op = X.map f.op ≫ X.map pullback.snd.op :=
by rw [←X.map_comp, ←op_comp, pullback.condition, op_comp, X.map_comp]

def natural_fork {S S' : as_small.{u+1} Profinite.{u}} (f : S' ⟶ S) :
  fork (X.map pullback.fst.op) (X.map pullback.snd.op) :=
fork.of_ι (X.map (quiver.hom.op f)) (maps_comm X f)

-- TODO (BM): put this in mathlib (it's already in a mathlib branch with API)
def category_theory.functor.preserves_terminal
  (X : (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1)) : Prop := sorry

-- TODO (BM): put this in mathlib (it's already in a mathlib branch with API)
def category_theory.functor.preserves_binary_products
  (X : (as_small.{u+1} Profinite.{u})ᵒᵖ ⥤ Type (u+1)) : Prop := sorry

structure condensed_type_condition : Prop :=
(empty : nonempty X.preserves_terminal)
(bin_prod : nonempty X.preserves_binary_products)
(pullbacks : ∀ {S S' : as_small.{u+1} Profinite.{u}} (f : S' ⟶ S) [epi f],
  nonempty (is_limit (natural_fork X f)))

-- (BM): I'm 90% sure this is true as stated, the forward direction is about halfway done.
lemma sheaf_condition_iff :
  presieve.is_sheaf proetale_topology X ↔ condensed_type_condition X :=
sorry

-- TODO: Double check this definition...
def embed_Top : Top.{u} ⥤ CondensedSet.{u} :=
{ obj := λ T, ⟨as_small.down.op ⋙ Profinite.to_Top.op ⋙ yoneda.obj T ⋙ ulift_functor.{u+1}, sorry⟩,
  map := λ T₁ T₂ f, whisker_left _ $ whisker_left _ $ whisker_right (yoneda.map f) _ }

/-
-- TODO: State `sheaf_condition_iff` for presheaves taking values in `A` for `A` with appropriate
-- structure.
-- TODO: Use `sheaf_condition_iff` to define the functor of Example 1.5, it might look like this:
def embed_Top : Top.{u} ⥤ CondensedSet.{u} :=
{ obj := λ T, ⟨Profinite.to_Top.op ⋙ yoneda.obj T,
  begin
    rw sheaf_condition_iff, refine ⟨⟨_⟩, ⟨_⟩, _⟩,
    all_goals { sorry }
  end⟩,
  map := λ T₁ T₂ f, whisker_left Profinite.to_Top.op (yoneda.map f) }
-/

-- TODO: Use the above to prove the first part of Proposition 1.7:
lemma embed_Top_faithful : faithful embed_Top := sorry

-- TODO: Construct the left adjoint to `embed_Top` as in the second part of Proposition 1.7.
-/
