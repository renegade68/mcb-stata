# Changes

## Suite 0.1.6: complete reference attribution

This documentation revision supplies complete bibliographic entries, identifies
the distinct 1984 publications, maps methods to their sources, and adds BibTeX
and structured CFF references. Calculation files and all help example commands
are unchanged. Package checksums are regenerated for the revised documents.
macOS/MP 16.1 installation, reinstallation, all 57 help commands and 14 analytic
quickchecks passed. Native Windows evidence covers suite 0.1.5; this revised
package has not been rerun on Windows. See [validation](docs/validation.md).

## Suite 0.1.5: Windows installer correction

Core 0.9.2 and summary/margin 0.1.1 calculations are unchanged. On Windows/MP
16.1, all 14 source-directory numerical quickchecks passed for suite 0.1.4.
Its installation check stopped with r(459): net install changed LF line endings
to CRLF, and the post-install checksum rejected otherwise identical content.
Suite 0.1.5 accepts either the exact source bytes or their complete CRLF form
for installed files. The extracted source files still require exact checksums.
The full Windows installation/help workflow must be rerun on this candidate;
the successful numerical checks alone do not establish that workflow passed.

## Suite 0.1.4 — release candidate, 17 November 2026

- Core 0.9.2 follows the upper bound in Edwards and Hsu (1983), Theorem 1:
  maximize over all other groups and truncate at zero. Previously the upper
  bound was restricted to compatible controls S. The lower bound and S are unchanged.
- Corrected normal calibration from the 1984 corrigendum was already present;
  critical-value integration, constrained MCB and Tukey-gap calculations are unchanged.
- Summary 0.1.1 and margin 0.1.1 use core 0.9.2, with new internal version namespaces
  and saved-result provenance. Recompute results saved by older versions before
  applying the new margin command; do not mix component versions.
- Updated help and methods to reflect the original article/corrigendum review.
- Validated the two published tables, the upper-bound domain, transformations,
  raw/summary agreement and the installed workflow on macOS/MP 16.1.
- Prior finite unequal-size checks found no numerical difference between the old
  and new upper bounds; general equivalence is not assumed or claimed.
- This remains a local candidate; no new Windows/Linux validation is claimed.

## Suite 0.1.3 — release candidate, 17 November 2026

- Installation guidance works with a complete downloaded ZIP without assuming
  a private-repository access workflow.
- Added a self-contained external installation checker and evidence instructions.
- Added a method-by-method scope and release-status guide.
- Calculation sources and the three component versions are unchanged from 0.1.2.
- Historical Windows numerical evidence is distinguished from new installation tests.

## Suite 0.1.2 — release candidate, 17 November 2026

- Downloadable repository now uses the complete flat installation layout.
- English and Korean guides lead from private-repository download to installation,
  working examples, result interpretation and verification.
- Summary-input and practical-margin commands are installed with the core.
- Validation guidance incorporates received Windows numerical evidence and clearly
  separates it from macOS installation checks.
- Calculation sources remain core 0.9.1, summary 0.1.0 and margin 0.1.0.

## Suite 0.1.1 — release candidate, 15 November 2026

- One complete installation layout for the repository and suite ZIP.
- Concise bilingual guidance, self-contained examples and a small verification script.
- Development reports and generated research outputs excluded from the user distribution.
- Core 0.9.1, summary 0.1.0 and margin 0.1.0 calculation sources unchanged.

## Component baseline

Core 0.9.1 includes direct small-tail probability calculation, group-key handling,
result saving and graphs. Summary 0.1.0 reuses the core with group summaries.
Margin 0.1.0 classifies existing distance intervals against a practical threshold.
