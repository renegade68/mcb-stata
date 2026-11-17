# Methods and assumptions

Independent normal observations with a common unknown variance are assumed.
Let group means be m_i, sample sizes n_i, residual df = N−K, and pooled
within-group variance s². Pairwise standard errors are
s_ij = sqrt(s²(1/n_i + 1/n_j)). Unequal sizes and singleton groups are allowed
provided df > 0 and residual variation is positive. Confidence levels range
from 80 to 99.9 and group count from 2 to 50. Tukey requires df from 2 to 1,000,000.
No weights, covariates, dependence or unequal-variance correction is provided.

The definitions below use larger means as better. `best(min)` applies the
construction to the negative outcome and transforms results back.

## Constrained MCB (default)

The target is mu_i − max_{j≠i} mu_j, the signed difference from the best OTHER
population mean. The one-sided critical value d_i calibrates the maximum of
correlated t statistics against control i at probability 1−alpha.

- rawU_i = min_{j≠i}(m_i − m_j + d_i s_ij); U_i = max(0, rawU_i).
- G = {i : rawU_i > 0} is the reported candidate set.
- L_i = 0 if G is the singleton {i}; otherwise
  L_i = min_{j≠i}(m_i − m_j − d_j s_ij).

The lower-bound index is j. Intervals contain zero by construction, so ordinary
zero inclusion is not the screening rule. Exclusion control for a fixed true
best group differs from simultaneously retaining every tied best group.
`p_exclude` uses the one-sided maximum tail probability.

## Edwards–Hsu distance construction

The target is delta_i = max_j mu_j − mu_i, including i in the maximum.
For each putative best control j, c_j calibrates the absolute maximum of
correlated t statistics. Set a_ij = m_i − m_j − c_j s_ij and
b_ij = m_i − m_j + c_j s_ij, with diagonal terms zero.
Retain control j in S when all a_ij ≤ 0, including equality. Following
Edwards and Hsu (1983), Theorem 1 (p. 966) and Example 2 (p. 969):

- lower_i = min_{j in S} max(0, −b_ij); the zero diagonal handles S={i}.
- upper_i = max(0, max_{j≠i}(−a_ij)).

Only the lower bound uses S. In core 0.9.2 the upper bound uses all other groups,
with the zero diagonal implementing the outer truncation at zero. Final candidates
have lower_i = 0 and need not equal S, as illustrated by the article's Table 1.

For any fixed true best control, its simultaneous MCC event places that control
in S and bounds every true distance between these endpoints. Thus the original
theorem gives simultaneous distance coverage under the stated model, subject to
numerical integration accuracy. This implementation uses symmetric two-sided
critical values; it does not implement the full range of asymmetric or nonparametric
constructions discussed in the article.

The 1984 JASA corrigendum restores the sqrt(2) multiplier in the balanced normal
calibration and standard error s*sqrt(2/n). The implemented pair standard error
and conditional-normal integral already use that scale. The corrigendum explicitly
leaves Theorem 1 and the numerical examples unaffected. Both published tables
were reproduced; see [validation](validation.md) for precision and scope.

Earlier core 0.9.1 restricted the upper bound to S, based on the separately
commented Edwards–Hsu block in the SAS sample source. Balanced symmetric cases
agree algebraically, and a finite unequal-size search found no discrepancy;
general equivalence is not claimed. Core 0.9.2 directly follows the original
upper-bound domain. Neither version is certified equivalent to the active final
output of SAS `%UMCB`. No vendor executable comparison is claimed.

## Tukey distance benchmark

`method(tukeygap)` projects simultaneous all-pair Tukey–Kramer bounds to the
same nonnegative distance. With q equal to the studentized-range quantile
(divided by sqrt(2)):

- lower_i = max(0, max_{j≠i}(m_j − m_i − q s_ij)).
- upper_i = max(0, max_{j≠i}(m_j − m_i + q s_ij)).

This is a benchmark, not another name for Hsu MCB. Its intervals and the
Edwards–Hsu intervals have no universal nesting order.

## Summary input and practical margins

`mcbhsus` accepts n/mean/sample SD or n/mean/common MSE/matching df. Sample SDs
are pooled as Σ(n_i−1)s_i² / Σ(n_i−1). It reuses the core calculation engine.
`mcbhsumargin` requires distance intervals: upper ≤ epsilon means within,
lower > epsilon means beyond, and the remaining cases are uncertain.
It preserves original candidate flags and bounds. Retained does not mean equivalent.

## Numerical behavior

The core uses conditional-normal integration with a chi-square scale mixture
and root finding; failed integration raises an error rather than switching methods.
Two-group cases reduce to t quantiles. Cache entries store critical values,
not observations or labels. `near_boundary` flags selected precision-sensitive
classifications. Centering/scaling limits overflow but cannot recover precision
already lost in stored data. Some unbalanced settings and small tails are slow.

## References and attribution

- Hsu (1981), *Annals of Statistics* 9:1026–1034: distances from the best.
- Hsu (1984), *Annals of Statistics* 12:1136–1144: balanced constrained MCB.
  This is distinct from the JASA corrigendum below.
- Edwards and Hsu (1983), *JASA* 78:965–971,
  DOI: 10.2307/2288211; corrigendum (1984), *JASA* 79:965, DOI: 10.2307/2288771.
- Hsu (1996), *Multiple Comparisons: Theory and Methods*.
- SAS Sample Library MCB, Randy Tobias, 16 January 1996:
  https://support.sas.com/documentation/onlinedoc/stat/ex_code/132/mcb.html

This is a new Stata/Mata implementation of established constructions, not a new
statistical methodology. No vendor source or article PDFs are distributed.
See [validation and limitations](validation.md).
