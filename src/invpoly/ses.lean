import free_pfpng.main
import invpoly.functor
import condensed.condensify
import laurent_measures.thm69
import normed_free_pfpng.compare

universe u

noncomputable theory

open category_theory

open_locale nnreal

namespace invpoly
open ProFiltPseuNormGrpWithTinv₁

variables (p : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)]

local notation `r` := @r p

@[simps] def eval2 (S : Fintype.{u}) :
  strict_comphaus_filtered_pseudo_normed_group_hom (invpoly r S) (normed_free_pfpng p S) :=
{ to_fun := λ F s, (F s).eval 2,
  map_zero' := by { ext, simp only [polynomial.eval_zero, pi.zero_apply], },
  map_add' := by { intros, ext, simp only [polynomial.eval_add, pi.add_apply], },
  strict' := λ c F hF, begin
    refine (finset.sum_le_sum _).trans hF,
    rintro s -,
    sorry
  end,
  continuous' := λ c, continuous_of_discrete_topology }

def eval2_nat_trans :
  (fintype_functor.{u} r ⋙ to_CompHausFiltPseuNormGrp₁.{u} r) ⟶
  (normed_free_pfpng_functor.{u} p ⋙ ProFiltPseuNormGrp₁.to_CHFPNG₁) :=
{ app := λ S, eval2 p S,
  naturality' := λ S T f, by { ext x t, sorry } }
.

section ses

open CompHausFiltPseuNormGrp₁

theorem short_exact (S : Profinite) :
  short_exact ((condensify_Tinv2 _).app S) ((condensify_map $ eval2_nat_trans p).app S) :=
begin
  refine condensify_nonstrict_exact _ _ (r⁻¹ + 2) (Tinv2_bound_by _) sorry _ sorry _ _ _ _ _ _,
  all_goals { sorry },
end

end ses

end invpoly
