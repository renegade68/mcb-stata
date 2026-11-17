# Read the first example

From the extracted suite folder, install with `do install_mcbhsu_suite.do`.
Save your data, then run `do first_steps.do`. All example data are generated
inside the script; no data download is needed.

| Group | Mean | Edwards–Hsu distance interval | Decision for epsilon = 5 |
| --- | ---: | --- | --- |
| First | 5.141 | [9.002, 10.572] | Beyond: lower > 5 |
| Second | 9.959 | [4.185, 5.754] | Uncertain |
| Third | 14.928 | [0, 0] | Within: upper ≤ 5 |

These are simultaneous intervals for nonnegative distances from the best
population mean, under the model assumptions. The constrained candidate analysis
in the same example uses a different, signed target.

The example writes graphs and result files into `onboarding_example/`.
Use `saving(my_results)` on a distance analysis to retain the full result metadata.
You can later run `mcbhsumargin using my_results, epsilon(5)`.
The three decisions use upper ≤ epsilon, lower > epsilon, and otherwise uncertain.
They do not modify the original intervals or candidate flags.

`do demo_mcbhsu_suite.do` additionally aggregates the raw observations, runs
`mcbhsus`, checks agreement with the raw-data result, and applies margins to
both current and saved results. Its success marker is `MCBHSU_SUITE_DEMO_PASSED`.
Individual examples are `demo_mcbhsu.do`, `demo_mcbhsus.do` and
`demo_mcbhsumargin.do`. They replace data and may overwrite their example outputs.

For your own data, consult `help mcbhsu`, `help mcbhsus` and
`help mcbhsumargin`. See [methods](methods.md) and [validation](validation.md).
