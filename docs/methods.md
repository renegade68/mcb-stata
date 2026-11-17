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

See Hsu (1984, *The Annals of Statistics*) and Hsu (1996). The balanced
constrained theorem alone does not establish the unequal-size implementation.

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

Following the all-pairwise framework of Tukey (1949) and Kramer (1956),
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

Each entry gives the source and its role in this implementation. The two 1984
items below are different publications. Download [BibTeX references](references.bib).

- Edwards, Donald G., and Hsu, Jason C. (1983). Multiple Comparisons with the Best Treatment. Journal of the American Statistical Association, 78(384), 965-971. [10.2307/2288211](https://doi.org/10.2307/2288211)
  Theorem 1 (p. 966) and the normal-model Example 2 (p. 969) underpin method(edwardshsu). The filter observations are transcribed from p. 970; Tables 1 and 2 are the published reproduction targets. The publisher also identifies this article by DOI 10.1080/01621459.1983.10477047; these are two identifiers for the same article.

- Edwards, Donald G., and Hsu, Jason C. (1984). Corrigenda: Multiple Comparisons with the Best Treatment. Journal of the American Statistical Association, 79(388), 965. [10.2307/2288771](https://doi.org/10.2307/2288771)
  Corrects the normal-model calibration in the 1983 article, including the sqrt(2) factor. Theorem 1 and the numerical examples are unaffected. Cite this correction together with the original article when using method(edwardshsu). This is distinct from Hsu's 1984 Annals paper.

- Hsu, Jason C. (1981). Simultaneous Confidence Intervals for all Distances from the "Best". The Annals of Statistics, 9(5), 1026-1034. [10.1214/aos/1176345582](https://doi.org/10.1214/aos/1176345582)
  Foundational reference for simultaneous inference on distances from the best and its relationship to selection.

- Hsu, Jason C. (1984). Constrained Simultaneous Confidence Intervals for Multiple Comparisons with the Best. The Annals of Statistics, 12(3), 1136-1144. [10.1214/aos/1176346732](https://doi.org/10.1214/aos/1176346732)
  The balanced constrained-MCB reference for the signed target. Its balanced theorem alone is not a proof of the suite's unequal-size implementation. It is not the Edwards-Hsu JASA corrigendum.

- Hsu, Jason C. (1996). Multiple Comparisons: Theory and Methods. London: Chapman & Hall. ISBN 0-412-98281-1. [Source](https://www.asc.ohio-state.edu/hsu.1/book.html)
  General methodological reference, especially Chapter 4 on MCB and Chapter 5 on all-pairwise comparisons. The link is the author's book description.

- Tukey, John W. (1949). Comparing Individual Means in the Analysis of Variance. Biometrics, 5(2), 99-114. [10.2307/3001913](https://doi.org/10.2307/3001913)
  Source for the all-pairwise comparison family underlying the Tukey distance benchmark. The suite projects pairwise bounds to nonnegative distances.

- Kramer, Clyde Young (1956). Extension of Multiple Range Tests to Group Means with Unequal Numbers of Replications. Biometrics, 12(3), 307-310. [10.2307/3001469](https://doi.org/10.2307/3001469)
  Unequal-replication extension underlying the Tukey-Kramer pairwise benchmark; used with Tukey (1949), not as an MCB theorem.

- SAS Institute Inc. (1996). MCB: Multiple Comparisons with the Best. SAS Sample Library; support: Randy Tobias; updated 16 January 1996. [Source](https://support.sas.com/documentation/onlinedoc/stat/ex_code/132/mcb.html)
  SAS Sample Library, SAS/STAT 13.2 online sample page; sample support contact Randy Tobias, last updated 16 January 1996. Historical mathematical algorithm reference. No SAS macro source is distributed and no SAS, JMP or Minitab executable equivalence is claimed.

### What to cite

Cite the software version in `CITATION.cff` and the method actually used:

| Use | Methodological references |
| --- | --- |
| `method(edwardshsu)` | Edwards and Hsu (1983) **and** their 1984 JASA corrigendum; Hsu (1981) for the foundational framework |
| Default `method(constrained)` | Hsu (1984, Annals of Statistics) and Hsu (1996); retain the unequal-size qualification above |
| `method(tukeygap)` | Tukey (1949), Kramer (1956) and Hsu (1996) |
| `mcbhsus` | The references for the chosen method; summary input uses the same engine |
| `mcbhsumargin` | The references for its source intervals; the command applies a user-chosen threshold to those bounds |
| Published-filter example | Edwards and Hsu (1983), p. 970 for the observations, together with the 1984 correction |

The SAS sample is an algorithm attribution, not a runtime dependency or a
substitute for the methodological papers. This is a new Stata/Mata implementation
of established constructions, not a claim to a new statistical methodology.
No vendor source or article PDFs are distributed. See [validation](validation.md).
