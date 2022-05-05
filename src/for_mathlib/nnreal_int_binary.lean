import for_mathlib.nnreal_nat_binary

open_locale nnreal

-- lemma is false if w = 1 and n = any and r = 0
-- lemma is false if w = 0 and n ≠ 0 and r = 2⁻¹
lemma nnreal.zpow_le_iff_log {w r : ℝ≥0} (hw : 0 < w) (hr : 0 < r) {n : ℤ} :
  w^n ≤ r ↔ (w : ℝ).log * n ≤ (r : ℝ).log :=
begin
  rw [mul_comm, ←real.log_zpow],
  rw (show w ^ n ≤ r ↔ (w : ℝ) ^ n ≤ (r : ℝ), by norm_cast),
  rw real.log_le_log; norm_cast,
  { exact nnreal.zpow_pos hw.ne.symm _ },
  { exact hr },
end

-- → is false if w = 1 and n = any and r = 0
-- ← is false if w = 0 and n ≠ 0 and r = 2⁻¹
lemma nnreal.lt_zpow_iff_log {w r : ℝ≥0} (hw : 0 < w) (hr : 0 < r) {n : ℤ} :
  r < w ^ n ↔ (r : ℝ).log < (w : ℝ).log * n :=
begin
  rw [mul_comm, ←real.log_zpow],
  rw real.log_lt_log_iff,
  { norm_cast },
  { assumption_mod_cast },
  { apply zpow_pos_of_pos,
    assumption_mod_cast },
end

-- the useful lower and upper bounds on 2⁻¹ ^ ⌈z.log / (2⁻¹ : ℝ).log⌉
lemma pow_d_le_z {z : ℝ≥0} (hz : 0 < z) : (2⁻¹ : ℝ≥0) ^ ⌈(z : ℝ).log / (2⁻¹ : ℝ).log⌉ ≤ z :=
begin
    { rw nnreal.zpow_le_iff_log (by norm_num : (0 : ℝ≥0) < 2⁻¹) hz,
    rw ← div_le_iff_of_neg',
    { convert int.le_ceil _ },
    { apply real.log_neg; norm_num } },
end

lemma int.ceil_sub_one_lt {α : Type*} [linear_ordered_ring α] [floor_ring α]
(a : α) : (⌈a⌉ : α) - 1 < a :=
sub_lt_iff_lt_add.mpr (int.ceil_lt_add_one a)

lemma z_lt_pow_d_succ {z : ℝ≥0} (hz : 0 < z) : z < (2⁻¹ : ℝ≥0) ^ (⌈(z : ℝ).log / (2⁻¹ : ℝ).log⌉ - 1) :=
begin
  { rw nnreal.lt_zpow_iff_log (by norm_num : (0 : ℝ≥0) < 2⁻¹) (hz),
    rw ← lt_div_iff_of_neg',
    { push_cast,
      convert int.ceil_sub_one_lt _ },
    { apply real.log_neg; norm_num } },
end

namespace nnreal

namespace int

/-- The stream of 0s and 1s (always 0 for n<<0, not always 1 for n>>0)
such that r = ∑ (binary r n) * 2⁻¹ ^ n -/
noncomputable def binary (r : ℝ≥0) : ℤ → ℕ := if r = 0 then 0 else
λ n, let d : ℤ := ⌈(r : ℝ).log / (2⁻¹ : ℝ).log⌉ in
if n < d then 0 else nnreal.nat.digit (r * 2 ^ d) (n - d).nat_abs

example (n m : ℤ) : n ≤ m ↔ n < m + 1 := int.lt_add_one_iff.symm

theorem binary_le_one (r : ℝ≥0) (n : ℤ) : binary r n ≤ 1 :=
begin
  let d : ℤ := ⌈(r : ℝ).log / (2⁻¹ : ℝ).log⌉,
  rw [binary], split_ifs with hr hn, exact zero_le_one, exact zero_le_one,
  push_neg at hn,
  rcases lt_or_eq_of_le hn with (h1 | h2),
  { rw [int.lt_iff_add_one_le, le_iff_exists_nonneg_add] at h1,
    rcases h1 with ⟨c, hc1, rfl⟩,
    convert nnreal.nat.digit.succ_le_one (r * 2 ^ d) c.nat_abs,
    suffices : (c + 1).nat_abs = c.nat_abs + 1,
    { convert this, ring },
    exact int.nat_abs_add_nonneg hc1 zero_le_one },
  { clear hn,
    rw ← h2,
    rw [nat.digit, sub_self, int.nat_abs_zero, nat.binary.zero_fst_def, ← nat.lt_add_one_iff],
    rw nat.floor_lt', swap, norm_num,
    have := z_lt_pow_d_succ ((zero_lt_iff.mpr hr)),
    have h : (2⁻¹ : ℝ≥0) ≠ 0, norm_num,
    rw [zpow_sub_one₀ h, inv_inv] at this,
    replace this := inv_mul_lt_of_lt_mul₀ this,
    rw [mul_comm] at this, simpa },
end


@[simp] theorem binary_zero (z : ℤ) : binary 0 z = 0 :=
begin
  rw [binary, if_pos];
  refl,
end


-- d = ⌈real.log r / real.log (2⁻¹ : ℝ≥0)⌉ is
-- the unique solution to 2^{-d} ≤ r < 2^{1-d} if r>0
-- and hence the point beyond with all digits are 0
theorem binary_bounded (r : ℝ≥0) (n : ℤ) (hsmall : n < ⌈real.log r / real.log (2⁻¹ : ℝ≥0)⌉) :
  binary r n = 0 :=
begin
  rw [binary],
  split_ifs;
  refl,
end


-- proof idea for the next two: use ennreal

theorem binary_sum (r : ℝ≥0) : ∑' (n : ℤ), (binary r n : ℝ≥0) * 2⁻¹ ^ n = r := sorry

theorem binary_summable (r : ℝ≥0) : summable (λ (n : ℤ), (binary r n : ℝ≥0) * 2⁻¹ ^ n) := sorry

end int

end nnreal
