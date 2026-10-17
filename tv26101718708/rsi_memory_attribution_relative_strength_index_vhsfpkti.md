# RSI Memory Attribution - Relative Strength Index

- url: https://www.tradingview.com/script/vHSfPKTI-RSI-Memory-Attribution-Relative-Strength-Index/
- type: indicator
- pine_id: PUB;5df0bd3933e44af9a99de7205b67e992
- version: 2.0

## Description

The same RSI value can come from very different price histories.

RSI Memory Attribution keeps the standard Relative Strength Index intact and adds a way to examine the weighted gains and losses behind its current reading. It separates recent from older contributions, tests dependence on individual changes, and measures how much the order of those changes affects RSI.

The purpose is to make an RSI reading explainable without replacing it with a composite score. This is an oscillator and a research tool, not a trading strategy or a forecast of the next price move.

What this adds to a standard RSI

The script connects three questions about the same RSI calculation:

How much of the reading comes from recent changes versus older changes?
Could removing one recent weighted contribution change its threshold classification?
How different could RSI be if the same recent changes had occurred in another order?

Concentration, contribution age, completed episodes, and a prior-term entry study provide additional context for those questions. These modules do not average several RSI periods, detect price/RSI divergence, or combine unrelated indicators into a buy/sell score. The standard RSI formula and the basic concentration formula are established tools; the additional functionality is their application to the attribution and sensitivity of one RSI state.

Reading the default display

Cyan line: The built-in RSI, on its usual 0-100 scale.

Violet line: The older-contribution base, defined as 50 plus the older contribution. It is not an independently calculated RSI for an older window.

Mint/orange ribbon: The signed contribution from the most recent H source changes. Mint means those changes add RSI points to the older base; orange means they subtract points.

Gold shading: The REMOVE ONE range. It includes the actual RSI and the values obtained by deleting any one eligible recent weighted contribution. This is not a volatility band or a confidence interval. Optional boundary lines are available in Appearance.

Pink ORDER RANGE values: The lowest and highest RSI under the latest-snapshot order test. These appear in the readout, not as a projected path.

The five-row readout defaults to Overview. Use Readout page in the settings to access Order and concentration, Episodes, Entry study, Diagnostics, or Legend. Colors, text size, position, line width, and visual layers are adjustable. Markers and the strip near 98 are off by default.

At the default thresholds, UPPER means RSI is at or above 70, LOWER means at or below 30, and IN RANGE means between them. These describe oscillator levels, not whether an asset is fundamentally expensive or cheap.

1. Recent and older attribution

Let N be the RSI length, a = 1/N, and q = 1-a. Let G and L be Wilder-smoothed gains and losses, with T = G+L.

After H consecutive valid updates:

Older gains = q^H * G from H bars ago.
Older losses = q^H * L from H bars ago.
Recent gains = current G minus older gains.
Recent losses = current L minus older losses.

Both contributions use the same current denominator:

Recent contribution = 50 * (recent gains - recent losses) / T.
Older contribution = 50 * (older gains - older losses) / T.
RSI = 50 + recent contribution + older contribution.

MEMORY displays the contributions as R and O, in RSI points. The violet base equals 50+O. H partitions the existing RSI state; it does not change the RSI length N. The older part includes the residual influence of the initialized smoothing state.

For example, R = -4.53 and O = -10.87 give RSI = 50 - 4.53 - 10.87 = 34.60. Both cohorts contribute below the midpoint. This explains the composition of that reading without predicting what follows. Separately rounded values may differ slightly when added together.

2. REMOVE ONE: dependence on one weighted change

The full test considers ages 0 through H-1. Age 0 is the latest displayed source change. Each candidate removes exactly one term; the script does not remove all H terms together.

Removing a gain contribution can only reduce or leave RSI unchanged. Removing a loss contribution can only increase or leave RSI unchanged. The largest eligible weighted gain and loss therefore determine the two extremes. The actual, unchanged RSI is also included in the range.

Removal means subtracting one contribution from the current smoothed state while preserving all other weights. It does not delete a candle, reconnect adjacent prices, or reconstruct an alternative OHLC chart.

An asterisk beside REMOVE ONE means that at least one candidate changes the UPPER / IN RANGE / LOWER classification. For an illustrative RSI of 34.6 with a range of 28.6-38.5, some removal can move the calculation below the default lower threshold. The range does not say that RSI or price will move there next. No asterisk means unchanged classification under this particular test, not a reliable trade.

The test displays n/a when no nonzero candidate exists or a candidate leaves an unstable residual denominator. An unavailable test is not classified as resilient.

3. ORDER RANGE: same changes, different sequence

The order test holds the older smoothed state fixed and keeps every signed change in the recent H-change collection. It changes only which recent weight is assigned to each change.

Assigning the largest signed changes to the largest recency weights maximizes the gain component while minimizing the loss component. Reversing this arrangement gives the opposite extreme. Two sorted arrangements produce the bounds without enumerating every permutation.

The sum of the changes stays the same, so the start and end source values remain unchanged. Intermediate rearranged paths need not be economically feasible. This is an arithmetic sensitivity test, not a model of likely future paths.

ORDER EFFECT compares actual RSI with a baseline that divides the recent weight equally among the H changes. That baseline is not the average RSI across random permutations, because RSI is a nonlinear ratio.

POS is the actual reading's location from 0 to 100 inside the order range. It is not a percentile or probability. A zero-width range has no defined position.

Order and concentration values describe only the latest displayed snapshot. Moving the cursor to an older bar does not turn these readout values into historical measurements. They are not copied into past bars or used to assign historical entry-study groups.

4. Concentration and contribution age

For each recent term, m is its absolute source change multiplied by its RSI recency weight.

EQ = (sum of m)^2 / sum of m^2.

EQ describes how many equal-sized contributions would have the same concentration. A value near 1 means recent weighted movement is concentrated in very few terms. A value near H means the weighted contributions are more evenly distributed. It is not a count of statistically independent observations or a confidence score.

AGE is the movement-weighted mean age within the recent cohort, with the newest change at age 0. TOP is the largest recent weighted term as a percentage of recent weighted movement, not total RSI memory. Separate gain and loss ages are available; a side without movement has no defined age.

These values help distinguish a reading dominated by a few changes from one supported by a broader recent sequence. They do not rank the quality of a potential trade.

5. Completed extreme episodes

An episode is a consecutive sequence of confirmed readings on the same extreme side. Duration is measured in bars. A is the accumulated excess beyond the relevant threshold, in RSI-point bars.

Upper and lower completed episodes are stored separately. The Episodes page shows duration medians and the current episode's age and area ranks against retained, completed episodes from the same side. Ties receive half weight in the ranks.

An episode already active when valid sampling begins is marked with a plus sign. Its start was not observed, so it is excluded from completed pools. Missing valid observations or sample boundaries interrupt an episode rather than count it as complete. An active episode is not a completed observation.

The default retains 60 completions per side and requires 20 observations for a summary. Both are adjustable. These completed-only comparisons are not estimates of remaining duration, survival probabilities, or reversal odds.

6. Entry study: prior terms, not the triggering change

Here, entry means entering an RSI threshold region, not opening a trade.

This study deliberately uses a different candidate set from REMOVE ONE. At a new confirmed threshold entry, it holds age 0 fixed and considers deleting one prior term aged 1 through H-1. It therefore requires H of at least 2.

PRIOR-RESILIENT: None of the tested prior-term deletions changes the entry classification.
PRIOR-SENSITIVE: At least one tested prior-term deletion changes it.

These labels concern the RSI calculation, not future price resilience. They are assigned at the entry close without using later outcomes.

The triggering change must be excluded from this comparison. Removing age 0 restores the previous RSI ratio. At a new threshold crossing, including that change would therefore make every evaluable entry sensitive. The prior-only test avoids that structural problem, but either group can still have few or no observations on a particular chart.

K closes after an accepted entry, the script records:

E / END: RSI is on the same extreme side at the endpoint.
R / RUN: RSI remained on that side at every intervening close, including the endpoint.

An episode can end and later restart, satisfying END without satisfying RUN. These percentages describe observed RSI persistence, not profitable trades or a strategy win rate.

Upper and lower groups are reported separately. POOLED BASELINE combines the same selected, classified, matured observations for the chosen side. It is not an independent control group or all market entries.

By default, the earliest classifiable entry is accepted and overlapping entries through its +K bar are skipped across both sides. This choice does not use the eventual outcome. Non-overlap can be disabled for research; it does not establish statistical independence.

SAMPLE STATUS reports the chosen side:

P: Accepted entry whose outcome horizon is still pending.
D: Accepted entry whose matured window includes invalid, missing, or out-of-date observations.
X: Entry with no classifiable prior test, an unstable residual, or a numerical threshold-boundary ambiguity.
O: Otherwise classifiable entry skipped by the non-overlap rule.

These exclusions are not counted as observed failures. Counts remain visible when percentages are withheld below the minimum sample. Event-study counts accumulate over eligible loaded history; the 60-completion setting limits episode pools, not these counts.

Group differences can reflect entry overshoot, prior path, instrument, timeframe, and chosen parameters. Selecting settings after viewing favorable results introduces selection bias. The study does not establish causation, statistical significance, out-of-sample performance, or a trading advantage.

7. A practical research workflow

Begin with standard candlesticks and the default Close source, RSI length 14, H = 7, and thresholds 70/30. H is an attribution horizon, not a second oscillator period.

Read RSI and MEMORY first. Check whether recent and older contributions agree or oppose. Then compare REMOVE ONE with ORDER RANGE: the first changes the membership of the weighted calculation; the second retains the same changes and varies their order.

Use Order and concentration for contribution age and concentration, Episodes for completed-run comparisons, and Entry study for prior-term groups. Check sample counts before interpreting percentages. n/a can be a correct result when data or valid candidates are insufficient.

Material contribution, default 2 RSI points, controls cohort-state classification rather than the RSI formula. The optional width marker uses a separate default threshold of 3 RSI points. The entry-study horizon defaults to 5 closes. These defaults are research settings, not optimized trading parameters.

8. Optional marks and alerts

A gold circle marks a confirmed transition into full REMOVE ONE classification sensitivity. A pink square marks the removal width crossing its configured threshold. These are different events. With Both selected, the circle takes priority on the same bar; the separate alert conditions still exist.

The optional strip at 98 shows cohort relationships: mint for both materially positive, orange for both materially negative, gold for material opposition, violet for one material cohort, and gray for small or mixed contributions. It is categorical, not another RSI value.

Seven close-confirmed alert conditions cover upper and lower threshold entries and exits, material cohort opposition, the appearance of full-test classification sensitivity, and a removal-width threshold crossing. Create the desired alert separately using TradingView's alert dialog. Native threshold alerts are independent of research date filters. These alerts are not order instructions or entry-study outcome predictions.

9. Live behavior, history, and diagnostics

By default, the open bar displays the previous closed RSI and research snapshot. Historical readings stay on their original bars. Turning this option off permits intrabar changes. Episode records, entry-study classifications and outcomes, and alert conditions still commit only at bar close.

A live built-in RSI can therefore differ from this script's default held reading on the current open bar. Compare confirmed bars or use matching live settings when checking values.

Research requires a standard chart, valid consecutive updates, and positive weighted movement. It waits N times the settling setting plus H changes: 147 at the defaults. Those changes can already exist in loaded history. Native RSI is not suppressed while research is settling. The settling convention does not prove convergence to an infinite-history value.

The script uses available chart history without a fixed 6,000-bar execution cap. Changing the dataset start, source, settings, or supplied data can change initialization and statistics. Dates filter close-time observations; they do not load missing history or reset RSI. Ages, durations, and K count bars rather than elapsed clock time.

External indicator sources can repaint upstream. Bar-close confirmation does not prevent source revisions or data-feed corrections, so no absolute non-repainting claim is made.

Diagnostics displays the RSI identity error, direct recent-sum error, full/prior removal comparisons, and whether sorted order bounds contain the actual RSI. Numeric errors show nine decimals and use a tolerance of 0.000001 in the row's stated units. The direct scans are latest-snapshot checks, not certification of every historical bar. n/a is not a pass, and a zero-width order range can be valid without a defined POS.

10. Open-source scope

The source is published under Mozilla Public License 2.0 for inspection and further research. All implemented features are included without an author-side access fee or external service requirement.

The script does not request external market series, import libraries, backdate pivot signals, place orders, or project the order range into future bars. Its historical engine uses recurrence calculations and rolling built-ins; H-term scans and sorting are limited to the latest snapshot.

This publication provides descriptive indicator research. It does not claim a new underlying RSI formula, universal originality, predictive accuracy, guaranteed moderation status, or profitable execution. Its additional value is making the composition and sensitivity of an otherwise familiar RSI reading visible and inspectable.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SG Group
//@version=6
indicator("RSI Memory Attribution - Relative Strength Index", overlay = false, precision = 2, max_bars_back = 600, max_lines_count = 8, max_labels_count = 8, explicit_plot_zorder = true)

// v6.1.2 | Plot-budget fix; retains v6.1.1 calculations, visuals and alerts.
// DATA WINDOW: 36 dedicated numeric exports are routed through 8 fixed slots.
// Select the group in "07 | Data Window"; "Data Window guide" explains slots.
// Slot meanings change only on a settings-driven full recalculation, not by bar.
// Generic exports use an explicit CONST color; input colors also consume counts.
// Conservative plot-count bound for this source:
// 7 pane/anchor plot calls * 2 + 8 constant-color exports * 1
// + 2 shape calls * 3 + 11 alertcondition calls + 4 fills * 1 = 43 < 64.
// This is a source-level upper bound, not a TradingView compiler measurement.
// Counting every fill and every shape text-color as dynamic is conservative.
// Tables, labels, hlines and line objects do not consume this plot-count budget.
// Do not reinstate the old 36 exports behind display.none: hidden calls count.
// No source, sampling, classification, event or visible-pane formula is changed.
// Retained v6.1.1 rolling audit: replaces two H-term scans per historical event candidate with
// an independent two-stack rolling window. Storage is fixed, no collection grows
// with chart history, and no elapsed-time/history cap removes research samples.
// The reported "The script creates too many plots" message identifies the plot-limit failure.
// The five-row ledger shows additive NET RSI points beside each cohort's share
// of TOTAL weighted absolute movement. A small net value may hide cancellation.
// The sum of NET points plus 50 reconstructs RSI; movement shares sum to 100%.
// These are NOT volume shares, probabilities, or shares of net RSI displacement.
// Confirmed research events use current/prior finite-window audits on EVERY candidate.
// Audit states are computed on every observation with the same bounded algorithm,
// independent of whether it is currently the latest, replayed, or historical bar.
// Latest-only sorting/presentation audits do not create or suppress event history.
// No author name, company name, logo, or promotion is drawn on the chart.
// Standard RSI: J. Welles Wilder Jr., New Concepts in Technical Trading Systems (1978).
// The optional next-close equation is established RSI inversion, not our invention:
// Giorgos Siligardos, "Reverse Engineering RSI", Stocks & Commodities, June 2003.
// It is retained as an auxiliary equation, not used as an originality or alpha claim.
// The default ledger reconstructs the CURRENT LEVEL, not the change in RSI:
// RSI = 50 + older (ages H+) + prior recent (1..H-1) + newest (age 0).
// Optional seven-step diverging bars scale NET points only, never movement share.
// Zero-one-term outcomes are separate, nonlinear counterfactuals and are NOT additive.
// Latest-only direct audits gate latest presentation, NEVER historical selection or events.
// Identical confirmed input data/settings must select the same research observations.
// In closed mode the open bar is not given a duplicate historical plot point.
// Retains exact memory turnover, prior-support fragility and
// strictly chronological, paired RSI-only versus prior-test research.
// No imports, external requests, orders, pivots, lookahead or paid features.
// Latest badge/bracket use a few bars of visual padding, never future data.
// The close map is a one-step Wilder inversion, NOT a forecast or an order.
// Its anchor is ALWAYS confirmed, even when the main RSI is set to LIVE.
// Custom-source values are never labeled or formatted as tradable prices.
// Focus changes presentation only; research statistics are not filtered by it.
// RSI = 50 + recent contribution + older contribution, with ONE denominator.
// The older base is 50 + older contribution, NOT an independently scaled RSI.
// REMOVE ONE includes age 0. The entry study EXCLUDES age 0 (the trigger).
// Deleting age 0 at a new threshold entry necessarily restores the prior RSI;
// using that test to split new entries would make the resilient group empty.
// PRIOR UNCHANGED/CHANGED test only ages 1..H-1 at the entry close.
// These words describe an arithmetic test, NOT price stability or trade quality.
// Study labels are frozen at entry; outcomes are evaluated K closes later.
// ORDER reassigns the same signed changes to recency weights; not a forecast.
// No fixed execution-history cap: statistics depend on available chart history.
// Term ranking/order sorting and explicit H-term scans are latest-snapshot work.
// Events use independently aggregated sums/peaks at the current and previous closes.
// A queue transfer occasionally visits H-1 items, but each inserted item transfers
// at most once: total queue-transfer work is linear in the processed bar count.
// No claim of a new RSI formula, predictive edge, statistical independence,
// a confidence interval, trading profitability, or publication approval.
// ZERO A TERM means zero its signed increment at its existing age; it does
// not remove a candle, compress time, or replay the original price path.
// All-bar algebra checks and latest-only direct checks are distinguished.
// All-bar identity failures suppress affected research. Direct snapshot failures suppress
// the latest research presentation, not event history or the independent native RSI.
// Event-relevant rolling-check failures suppress that candidate in BOTH historical and
// realtime close calculations. No absolute non-repainting claim: revised source data,
// settings, loaded history, and external-source revisions can change recalculation.

const string GC = "01 | RSI"
const string GM = "02 | Attribution and sensitivity"
const string GE = "03 | Confirmed research"
const string GX = "04 | Immediate context"
const string GV = "05 | Appearance"
const string GP = "06 | Colors"
const string GD = "07 | Data Window"
const float TOL = 0.000001
const float EPS = 0.00000001
// Relative denominator conditioning, separate from the RSI-point error tolerance.
// With less than 0.001% of current weighted mass left, do not publish an unstable
// zeroing result as a precise number. This gate never alters the native RSI.
const float MIN_RESIDUAL = 0.00001
const float EMPTY_LOG = -1e30

string sourceMode = input.string("Close / price", "Source mode", options = ["Close / price", "Custom source"], group = GC, display = display.none, tooltip = "Close / price hard-wires the chart close. For HLC3, another built-in source or an external indicator, select Custom source and set it below. A custom source can repaint upstream; holding a close cannot prevent upstream revisions.")
float customSource = input.source(close, "Custom source / used only in Custom mode", group = GC, display = display.none)
bool priceMode = sourceMode == "Close / price"
float src = priceMode ? close : customSource
int n = input.int(14, "RSI length", minval = 2, maxval = 300, group = GC, display = display.none)
float upper = input.float(70.0, "Upper threshold", minval = 50.1, maxval = 99.9, step = 0.5, group = GC, display = display.none)
float lower = input.float(30.0, "Lower threshold", minval = 0.1, maxval = 49.9, step = 0.5, group = GC, display = display.none)
bool research = input.bool(true, "Enable research / off = native RSI only", group = GC, display = display.none)
bool closed = input.bool(true, "Hold last closed reading on the open bar", group = GC, display = display.none, tooltip = "Only the open bar holds the previous close. Historical plots are not shifted. Off permits intrabar changes. Episodes, entry samples and alerts always require close.")
int settle = input.int(10, "Research settling: RSI lengths", minval = 2, maxval = 15, group = GC, display = display.none, tooltip = "Wait N times this value plus H consecutive valid changes. This reduces initialization influence; it does not prove infinite-history convergence. Native RSI never waits for research.")
int h = input.int(7, "Recent cohort: H changes", minval = 1, maxval = 200, group = GM, display = display.none, tooltip = "Attribution and REMOVE ONE use ages 0..H-1. The entry study uses ages 1..H-1 and therefore requires H >= 2. Age 0 is the displayed observation.")
float material = input.float(2.0, "Material contribution: RSI points", minval = 0.1, maxval = 20.0, step = 0.1, group = GM, display = display.none)
bool probes = input.bool(true, "Single-term removal analysis", group = GM, display = display.none)
bool orderTest = input.bool(true, "Latest order / concentration analysis", group = GM, display = display.none)
float flagWidth = input.float(3.0, "Wide-range marker threshold: RSI points", minval = 0.1, maxval = 50.0, step = 0.1, group = GM, display = display.none)
bool episodes = input.bool(true, "Completed extreme episodes", group = GE, display = display.none)
int capacity = input.int(60, "Episode completions retained per side", minval = 10, maxval = 300, group = GE, display = display.none)
int minSample = input.int(20, "Minimum observations for a summary", minval = 3, maxval = 100, group = GE, display = display.none)
bool eventStudy = input.bool(true, "Entry study: prior terms only", group = GE, display = display.none, tooltip = "At the entry close, hold the triggering age-0 change fixed and delete any one prior term aged 1..H-1. Freeze that classification before observing outcomes. This is NOT the full REMOVE ONE classification.")
int horizon = input.int(5, "Outcome horizon: K closes after entry", minval = 1, maxval = 200, group = GE, display = display.none)
bool walkForward = input.bool(true, "Paired walk-forward check against RSI-only", group = GE, display = display.none, tooltip = "At entry, use only earlier matured samples. Baseline: same side and RSI overshoot band (0-2, 2-5, 5+ points). Extra model: same band plus the frozen prior-term class. Both training cells must meet Minimum observations. Estimates use (successes+0.5)/(n+1). Compare paired squared errors at +K; not P/L, significance, or a future guarantee.")
bool separateWindows = input.bool(true, "Non-overlapping entry windows", group = GE, display = display.none, tooltip = "Across BOTH sides, accept the earliest eligible entry, then skip entries through its +K bar inclusive. Selection does not use its eventual outcome. This does not make observations statistically independent.")
string studySide = input.string("Upper", "Entry-study side", options = ["Upper", "Lower"], group = GE, display = display.none)
bool useDates = input.bool(false, "Restrict research by bar close time", group = GE, display = display.none)
int fromTime = input.time(timestamp("01 Jan 2020 00:00 +0000"), "Sample start", group = GE, display = display.none)
int toTime = input.time(timestamp("31 Dec 2099 23:59 +0000"), "Sample end", group = GE, display = display.none, tooltip = "Dates filter observations, not RSI initialization or history loading. Partial episodes and incomplete/invalid outcome windows are not counted as completed observations.")
string referenceChoice = input.string("Nearest", "Reference level", options = ["Nearest", "50", "Upper", "Lower"], group = GX, display = display.none, tooltip = "Nearest selects the closest of lower, 50 and upper to the displayed RSI; an exact tie favors 50. The reference stress test holds age 0 fixed and zeros one prior term, ages 1..H-1. This is separate from the original upper/lower entry-study class.")
bool closeMap = input.bool(true, "Confirmed-anchor next-close map", group = GX, display = display.none, tooltip = "One-step source level needed to reach lower, 50 or upper on the NEXT observation after the last confirmed anchor. Close / price mode expresses it as a chart close. Custom mode expresses source units only. Approximate equality values are not limit orders or predictions. The mapping is independent of intrabar ticks until a new close is committed.")
bool showProbe = input.bool(false, "Latest prior-only bracket", group = GX, display = display.none, tooltip = "Small vertical bracket beside the last displayed RSI: full range obtained by zeroing ONE prior signed change, age 0 excluded. Gold means the selected reference can be crossed/touched. Not a forecast range. Horizontal padding is decorative only.")
bool showBadge = input.bool(true, "Latest RSI value badge", group = GX, display = display.none)
int badgeSize = input.int(12, "Latest badge font size", minval = 10, maxval = 18, group = GX, display = display.none)
string visualMode = input.string("Focus", "Visual density", options = ["Focus", "Full research"], group = GV, display = display.none, tooltip = "Focus: crisp native RSI, conflict-only memory ribbon and an age-resolved ledger. The optional bracket and categorical strip are off by default. Full research restores continuous memory and all-term removal shading. Neither mode changes calculations, samples, alerts or enabled research pages.")
bool showZones = input.bool(true, "Quiet upper / lower zone backgrounds", group = GV, display = display.none)
bool showMemory = input.bool(true, "Memory ribbon / Focus: opposition only", group = GV, display = display.none)
bool showEnvelope = input.bool(true, "All-term removal history / Full research only", group = GV, display = display.none)
bool envelopeEdges = input.bool(false, "Also draw removal edges", group = GV, display = display.none)
bool showStrip = input.bool(false, "Memory state strip at 4 / see Legend", group = GV, display = display.none)
string markers = input.string("Off", "Confirmed event markers", options = ["Off", "Threshold exits", "Classification circles", "Width squares", "Both"], group = GV, display = display.none, tooltip = "Threshold exits: a small circle at the exited upper/lower level, only after a close. Classification circles: full removal class became sensitive. Width squares: full removal width crossed its setting. In Both, a classification circle takes priority. No directional arrows or trading instructions.")
bool showHalo = input.bool(false, "Optional subtle RSI halo", group = GV, display = display.none)
int lineWidth = input.int(2, "RSI line width", minval = 1, maxval = 5, group = GV, display = display.none)
int ribbonAlpha = input.int(85, "Memory ribbon transparency", minval = 50, maxval = 98, group = GV, display = display.none)
int envelopeAlpha = input.int(89, "Removal shading transparency", minval = 70, maxval = 98, group = GV, display = display.none)
bool showPanel = input.bool(true, "Compact five-row readout", group = GV, display = display.none)
string panelLanguage = input.string("English", "Context language / 通常画面の言語", options = ["English", "日本語"], group = GV, display = display.none, tooltip = "Applies to Memory attribution, Term ledger, Single-term stress, Trader view, Next-close map, Reference stress and the badge. Legacy research pages/settings remain English. / 新しい通常・項別ページとバッジが対象。従来の研究ページと設定名は英語です。")
string page = input.string("Memory attribution", "Readout page", options = ["Memory attribution", "Term ledger", "Single-term stress", "Trader view", "Next-close map", "Reference stress", "Overview", "Memory turnover", "Threshold support", "Order and concentration", "Episodes", "Entry study", "Walk-forward check", "Diagnostics", "Legend", "Data Window guide"], group = GV, display = display.none)
string corner = input.string("Top right", "Readout position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = GV, display = display.none)
int fontSize = input.int(14, "Readout font size", minval = 10, maxval = 18, group = GV, display = display.none)
bool showLedgerBars = input.bool(true, "Net-contribution bars in the ledger", group = GV, display = display.none, tooltip = "The small signed bars encode NET RSI-point contributions, not weighted movement shares. Both sides and all three rows share a snapshot scale. Turn off for a narrower ledger; numerical points and movement shares remain visible.")
color cRSI = input.color(#40E9FF, "RSI", group = GP, display = display.none)
color cUp = input.color(#42F5BD, "Positive contribution", group = GP, display = display.none)
color cDown = input.color(#FF985A, "Negative contribution", group = GP, display = display.none)
color cOld = input.color(#B59AFF, "Older contribution base", group = GP, display = display.none)
color cTest = input.color(#FFDA62, "Removal sensitivity", group = GP, display = display.none)
color cOrder = input.color(#FF81D0, "Order analysis / width squares", group = GP, display = display.none)
color cMuted = input.color(#98A6B9, "References and secondary text", group = GP, display = display.none)
color cBg = input.color(#111A29, "Readout background", group = GP, display = display.none)
color cText = input.color(#F1F7FF, "Readout foreground", group = GP, display = display.none)
string dataWindowGroup = input.string("Attribution", "Data Window group", options = ["Off", "Attribution", "Removal tests", "Turnover", "Episodes and entries", "Reference and map", "Diagnostics"], group = GD, display = display.none, tooltip = "Research 1..8 in the Data Window are reused by the selected group. Switch Readout page to Data Window guide to see the slot labels. This selector does not change RSI, chart visuals, research samples or alert conditions. The old individual export names have been replaced; external-source bindings and CSV columns must use the selected group. Slots use 9 decimals for diagnostic visibility.\nAttribution: 1 Older net [RSI pt]; 2 Prior net [RSI pt]; 3 Latest net [RSI pt]; 4 Older movement [%]; 5 Prior movement [%]; 6 Latest movement [%]; 7 Recent net [RSI pt]; 8 Recent movement [%].\nRemoval tests: 1 All-term low [RSI]; 2 All-term high [RSI]; 3 All-term width [pt]; 4 Prior-only low [RSI]; 5 Prior-only high [RSI]; 6 Reference [RSI]; 7 Reference test [0-3]; 8 Touch / total [%].\nTurnover: 1 New term [RSI pt]; 2 Cohort transfer [pt]; 3 Recent denominator [pt]; 4 Older denominator [pt]; 5 Recent change [pt]; 6 Older change [pt]; 7 Actual RSI change [pt]; 8 Turnover error [pt].\nEpisodes and entries: 1 Episode age [bars]; 2 Episode area [pt-bars]; 3 Frozen entry group [0-3]; 4 RSI-only estimate [0-1]; 5 Extra-class estimate [0-1]; 6 Unused; 7 Unused; 8 Unused.\nReference and map: 1 Older base [RSI axis]; 2 Touch / total [%]; 3 Touch / prior support [%]; 4 Displayed reference [RSI]; 5 Next lower [source units]; 6 Next 50 [source units]; 7 Next upper [source units]; 8 Confirmed anchor [RSI].\nDiagnostics: 1 RSI identity error [pt]; 2 Turnover error [pt]; 3 Movement split error [pp]; 4 Net split error [pt]; 5 Rolling audit error [pt]; 6 Event current error [pt]; 7 Event prior error [pt]; 8 Event audit [1 pass,0 fail].\nReference test: 0=at level, 1=no touch, 2=touch only, 3=strict cross. Entry group: 0=upper prior unchanged, 1=upper prior changed, 2=lower prior unchanged, 3=lower prior changed. Data Window values belong to the crosshair bar, unlike the latest-only guide table. / データウィンドウは8枠の切替表示です。Readout page の Data Window guide で各枠の意味を確認できます。")

// Nonnegative mass: bool() avoids rounding small price-unit values to zero.
f_mass(float x) =>
    not na(x) and bool(x)
f_num(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.0")
f_sign(float x) =>
    na(x) ? "n/a" : math.abs(x) < 0.005 ? "0.00" : (x > 0.0 ? "+" : "") + str.tostring(x, "0.00")
f_clip(float x) =>
    math.max(0.0, math.min(100.0, x))
f_side(float x) =>
    na(x) ? 0 : x >= upper ? 1 : x <= lower ? -1 : 0
f_name(int s) =>
    s == 1 ? "UPPER" : s == -1 ? "LOWER" : "IN RANGE"
f_near(float x) =>
    not na(x) and (math.abs(x - upper) <= TOL or math.abs(x - lower) <= TOL)
f_ratio(float g0, float l0) =>
    f_mass(g0 + l0) ? f_clip(100.0 * (g0 / (g0 + l0))) : na
f_pair(float x, float y) =>
    f_num(x) + " - " + f_num(y)
f_check(float e) =>
    na(e) ? "n/a" : (e <= TOL ? "PASS " : "FAIL ") + str.tostring(e, "0.000000000")
// Plain-language display helpers; signs describe arithmetic, never orders.
f_tr(string en, string ja) =>
    panelLanguage == "日本語" ? ja : en
f_polarity(float value) =>
    na(value) ? "?" : math.abs(value) <= TOL ? "0" : value > 0.0 ? "+" : "−"
f_zone(float value) =>
    na(value) ? f_tr("NO DATA", "データなし") : value >= upper ? f_tr("UPPER ZONE", "上側領域") : value <= lower ? f_tr("LOWER ZONE", "下側領域") : math.abs(value - 50.0) <= TOL ? f_tr("AT 50", "50付近") : value > 50.0 ? f_tr("ABOVE 50", "50より上") : f_tr("BELOW 50", "50より下")
f_direction(float stepValue) =>
    na(stepValue) ? "n/a" : math.abs(stepValue) <= TOL ? f_tr("FLAT", "横ばい") : stepValue > 0.0 ? f_tr("RISING", "上昇中") : f_tr("FALLING", "低下中")
f_reference(float value) =>
    float result = na
    if not na(value)
        result := referenceChoice == "Upper" ? upper : referenceChoice == "Lower" ? lower : 50.0
        if referenceChoice == "Nearest"
            float distance = math.abs(value - 50.0)
            if math.abs(value - upper) < distance
                result := upper
                distance := math.abs(value - upper)
            if math.abs(value - lower) < distance
                result := lower
    result
// -1 unavailable; 0 already at level; 1 no touch; 2 touch; 3 strict cross.
// Numeric tolerance is explicit. It is NOT a calibrated confidence measure.
f_reference_test(float actual, float lo, float hi, float level) =>
    int result = -1
    if not na(actual) and not na(lo) and not na(hi) and not na(level)
        if math.abs(actual - level) <= TOL
            result := 0
        else if actual > level
            result := lo < level - TOL ? 3 : lo <= level + TOL ? 2 : 1
        else
            result := hi > level + TOL ? 3 : hi >= level - TOL ? 2 : 1
    result
f_test_text(int result) =>
    result == 3 ? f_tr("TEST CROSSES", "テストで交差") : result == 2 ? f_tr("TEST TOUCHES", "テストで接触") : result == 1 ? f_tr("NO TEST TOUCH", "テスト接触なし") : result == 0 ? f_tr("AT LEVEL", "基準上") : "n/a"
f_unit_value(float value) =>
    na(value) ? "n/a" : priceMode ? str.tostring(value, format.mintick) : str.tostring(value, "0.##########")
// Invert ONE future Wilder update from a known, confirmed state.
// t=target/100, u=G/(G+L); d=(n-1)*(G+L)*(t-u)/(t>=u ? 1-t : t).
// Audit both the algebraic shift AND the actually representable source level.
// The latter detects catastrophic cancellation when source is huge vs moves.
f_next_level(float sourceValue, float gainValue, float lossValue, float target) =>
    float level = na
    float err = na
    float total = gainValue + lossValue
    if not na(sourceValue) and f_mass(total) and not na(target) and target > 0.0 and target < 100.0
        float t = target / 100.0
        float u = gainValue / total
        float unitShift = (n - 1.0) * (t - u) / (t >= u ? 1.0 - t : t)
        float shift = unitShift * total
        level := sourceValue + shift
        float realizedUnitShift = (level - sourceValue) / total
        float q0 = 1.0 - 1.0 / n
        float exactRSI = f_ratio(q0 * u + math.max(unitShift, 0.0) / n, q0 * (lossValue / total) + math.max(-unitShift, 0.0) / n)
        float representedRSI = f_ratio(q0 * u + math.max(realizedUnitShift, 0.0) / n, q0 * (lossValue / total) + math.max(-realizedUnitShift, 0.0) / n)
        err := na(exactRSI) or na(representedRSI) ? 100.0 : math.max(math.abs(exactRSI - target), math.abs(representedRSI - target))
    [level, err]

f_envelope(float g0, float l0, float pg, float pl) =>
    float t = g0 + l0
    float lowValue = na
    float highValue = na
    bool ok = false
    // A zero-weight candidate is a valid no-op, not an undefined deletion.
    if f_mass(t) and not na(pg) and not na(pl)
        float gn = g0 / t
        float ln = l0 / t
        float xg = pg / t
        float xl = pl / t
        if xg >= -EPS and xl >= -EPS and xg <= gn + EPS and xl <= ln + EPS
            xg := math.max(0.0, math.min(gn, xg))
            xl := math.max(0.0, math.min(ln, xl))
            if 1.0 - xg > MIN_RESIDUAL and 1.0 - xl > MIN_RESIDUAL
                lowValue := f_clip(math.min(100.0 * gn, 100.0 * (gn - xg) / (1.0 - xg)))
                highValue := f_clip(math.max(100.0 * gn, 100.0 * gn / (1.0 - xl)))
                ok := true
    [lowValue, highValue, ok]
f_add(array<float> pool, float x) =>
    array.push(pool, x)
    if array.size(pool) > capacity
        array.shift(pool)
    array.size(pool)
f_inc(array<int> pool, int ix) =>
    array.set(pool, ix, array.get(pool, ix) + 1)
    array.get(pool, ix)
f_med(array<float> pool) =>
    array.size(pool) >= minSample ? array.median(pool) : na
f_rank(array<float> pool, float x) =>
    float result = na
    int count = array.size(pool)
    if count >= minSample and not na(x)
        float totalRank = 0.0
        for k = 0 to count - 1
            float v = array.get(pool, k)
            totalRank += v < x ? 1.0 : v == x ? 0.5 : 0.0
        result := 100.0 * totalRank / count
    result
f_loss(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.0000")
f_band(float value, int direction) =>
    float distance = direction == 1 ? value - upper : lower - value
    distance < 2.0 ? 0 : distance < 5.0 ? 1 : 2
f_stats(int count, int ends, int runs) =>
    string rates = count >= minSample ? "E " + f_num(100.0 * ends / count) + "% R " + f_num(100.0 * runs / count) + "%" : "E n/a R n/a"
    "n " + str.tostring(count) + " | " + rates
f_row(table id, int row, string caption, string value, color ink, string help) =>
    table.cell(id, 0, row, caption, text_color = cMuted, bgcolor = row == 0 ? color.new(cRSI, 92) : cBg, text_size = fontSize, text_halign = text.align_left, text_formatting = text.format_bold, tooltip = help)
    table.cell(id, 2, row, value, text_color = ink, bgcolor = row == 0 ? color.new(cRSI, 92) : cBg, text_size = row == 0 ? fontSize + 2 : fontSize, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = help)


// Quantitative, signed glyph bars. Both sides use the same seven-step scale.
// Rounded glyph lengths are visual aids; exact point values are printed separately.
f_bar(float value, float barScale, bool negativeSide) =>
    int blocks = not na(value) and not na(barScale) and barScale > TOL ? int(math.round(7.0 * math.min(1.0, math.abs(value) / barScale))) : 0
    bool signMatches = not na(value) and (negativeSide ? value < -TOL : value > TOL)
    string result = ""
    for j = 0 to 6
        bool filled = signMatches and (negativeSide ? j >= 7 - blocks : j < blocks)
        result += filled ? "█" : "·"
    result
f_component_row(table id, int row, string caption, float value, float movementShare, float barScale, string help) =>
    color netInk = na(value) ? cMuted : value > TOL ? cUp : value < -TOL ? cDown : cText
    string netBar = showLedgerBars and not na(value) ? f_bar(value, barScale, true) + "|" + f_bar(value, barScale, false) : ""
    string moveText = na(movementShare) ? "n/a" : movementShare > 0.0 and movementShare < 0.05 ? "<0.1%" : f_num(movementShare) + "%"
    string detail = help + f_tr(" This row: NET=", " この行: 純寄与=") + f_sign(value) + f_tr(" RSI points; share of total weighted movement=", " RSIポイント、重み付き総変動量の構成比=") + moveText + "."
    table.cell(id, 0, row, caption, text_color = cMuted, bgcolor = cBg, text_size = fontSize, text_halign = text.align_left, text_formatting = text.format_bold, tooltip = detail)
    if showLedgerBars
        table.cell(id, 1, row, netBar, text_color = netInk, bgcolor = cBg, text_size = fontSize - 1, text_font_family = font.family_monospace, text_halign = text.align_center, tooltip = detail)
    table.cell(id, 2, row, f_sign(value), text_color = netInk, bgcolor = cBg, text_size = fontSize, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = detail)
    // Neutral ink deliberately separates movement SHARE from directional NET points.
    table.cell(id, 3, row, moveText, text_color = na(movementShare) ? cMuted : cText, bgcolor = cBg, text_size = fontSize, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = detail)
f_ledger_header(table id, string caption, string help) =>
    table.cell(id, 0, 0, caption, text_color = cRSI, bgcolor = color.new(cRSI, 92), text_size = fontSize + 1, text_halign = text.align_left, text_formatting = text.format_bold, tooltip = help)
    table.cell(id, 2, 0, f_tr("NET RSI pt\n50 + sum", "RSI純寄与 pt\n50 + 合計"), text_color = cText, bgcolor = color.new(cRSI, 92), text_size = fontSize - 1, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = help)
    table.cell(id, 3, 0, f_tr("MOVE %\nweighted", "総変動量 %\n重み付き"), text_color = cText, bgcolor = color.new(cRSI, 92), text_size = fontSize - 1, text_halign = text.align_right, text_formatting = text.format_bold, tooltip = help)

// Labels for the eight reusable numeric exports. Plot titles must be constant,
// so this latest-only table guide provides the selected group's human-readable names.
f_dw_caption(int slot) =>
    string result = f_tr("Unused", "未使用")
    if dataWindowGroup == "Attribution"
        result := switch slot
            1 => f_tr("Older net [RSI pt]", "過去側の純寄与 [pt]")
            2 => f_tr("Prior net [RSI pt]", "直近過去の純寄与 [pt]")
            3 => f_tr("Latest net [RSI pt]", "最新項の純寄与 [pt]")
            4 => f_tr("Older movement [%]", "過去側の総量比率 [%]")
            5 => f_tr("Prior movement [%]", "直近過去の総量比率 [%]")
            6 => f_tr("Latest movement [%]", "最新項の総量比率 [%]")
            7 => f_tr("Recent net [RSI pt]", "直近H項の純寄与 [pt]")
            8 => f_tr("Recent movement [%]", "直近H項の総量比率 [%]")
            => f_tr("Unused", "未使用")
    else if dataWindowGroup == "Removal tests"
        result := switch slot
            1 => f_tr("All-term low [RSI]", "全候補の下限 [RSI]")
            2 => f_tr("All-term high [RSI]", "全候補の上限 [RSI]")
            3 => f_tr("All-term width [pt]", "全候補の幅 [pt]")
            4 => f_tr("Prior-only low [RSI]", "過去項のみ下限 [RSI]")
            5 => f_tr("Prior-only high [RSI]", "過去項のみ上限 [RSI]")
            6 => f_tr("Reference [RSI]", "選択基準 [RSI]")
            7 => f_tr("Reference test [0-3]", "基準テスト [0-3]")
            8 => f_tr("Touch / total [%]", "接触必要量/総量 [%]")
            => f_tr("Unused", "未使用")
    else if dataWindowGroup == "Turnover"
        result := switch slot
            1 => f_tr("New term [RSI pt]", "新規項 [RSI pt]")
            2 => f_tr("Cohort transfer [pt]", "過去側への移動 [pt]")
            3 => f_tr("Recent denominator [pt]", "直近側の分母効果 [pt]")
            4 => f_tr("Older denominator [pt]", "過去側の分母効果 [pt]")
            5 => f_tr("Recent change [pt]", "直近寄与の変化 [pt]")
            6 => f_tr("Older change [pt]", "過去寄与の変化 [pt]")
            7 => f_tr("Actual RSI change [pt]", "実際のRSI変化 [pt]")
            8 => f_tr("Turnover error [pt]", "寄与変化の検査誤差 [pt]")
            => f_tr("Unused", "未使用")
    else if dataWindowGroup == "Episodes and entries"
        result := switch slot
            1 => f_tr("Episode age [bars]", "確定エピソード長 [本]")
            2 => f_tr("Episode area [pt-bars]", "閾値超過累積 [pt・本]")
            3 => f_tr("Frozen entry group [0-3]", "進入時の固定分類 [0-3]")
            4 => f_tr("RSI-only estimate [0-1]", "RSIのみ推定値 [0-1]")
            5 => f_tr("Extra-class estimate [0-1]", "追加分類の推定値 [0-1]")
            6 => f_tr("Unused", "未使用")
            7 => f_tr("Unused", "未使用")
            8 => f_tr("Unused", "未使用")
            => f_tr("Unused", "未使用")
    else if dataWindowGroup == "Reference and map"
        result := switch slot
            1 => f_tr("Older base [RSI axis]", "過去寄与の基準線 [RSI軸]")
            2 => f_tr("Touch / total [%]", "接触必要量/総量 [%]")
            3 => f_tr("Touch / prior support [%]", "接触必要量/過去支持量 [%]")
            4 => f_tr("Displayed reference [RSI]", "表示側の選択基準 [RSI]")
            5 => f_tr("Next lower [source units]", "下側の次回値 [入力単位]")
            6 => f_tr("Next 50 [source units]", "50の次回値 [入力単位]")
            7 => f_tr("Next upper [source units]", "上側の次回値 [入力単位]")
            8 => f_tr("Confirmed anchor [RSI]", "確定基準のRSI")
            => f_tr("Unused", "未使用")
    else if dataWindowGroup == "Diagnostics"
        result := switch slot
            1 => f_tr("RSI identity error [pt]", "RSI恒等式の誤差 [pt]")
            2 => f_tr("Turnover error [pt]", "寄与変化の誤差 [pt]")
            3 => f_tr("Movement split error [pp]", "総量分解の誤差 [pp]")
            4 => f_tr("Net split error [pt]", "純寄与分解の誤差 [pt]")
            5 => f_tr("Rolling audit error [pt]", "逐次検査の誤差 [pt]")
            6 => f_tr("Event current error [pt]", "イベント現在検査 [pt]")
            7 => f_tr("Event prior error [pt]", "イベント前回検査 [pt]")
            8 => f_tr("Event audit [1 pass,0 fail]", "イベント検査 [1合格,0不合格]")
            => f_tr("Unused", "未使用")
    result

// Audit bounds use explicit remaining gain/loss states, rather than reusing
// the main envelope formula. Monotonicity means only the largest weighted gain
// and loss are needed to reproduce an exhaustive one-term-zeroing range.
f_audit_bounds(float gainState, float lossState, float gainTerm, float lossTerm) =>
    float lo = na
    float hi = na
    bool defined = false
    float total = gainState + lossState
    if f_mass(total) and not na(gainTerm) and not na(lossTerm)
        float gn = gainState / total
        float ln = lossState / total
        float xg = gainTerm / total
        float xl = lossTerm / total
        if xg >= -EPS and xl >= -EPS and xg <= gn + EPS and xl <= ln + EPS
            xg := math.max(0.0, math.min(gn, xg))
            xl := math.max(0.0, math.min(ln, xl))
            if 1.0 - xg > MIN_RESIDUAL and 1.0 - xl > MIN_RESIDUAL
                float noGain = f_ratio(math.max(gn - xg, 0.0), ln)
                float noLoss = f_ratio(gn, math.max(ln - xl, 0.0))
                float intact = f_ratio(gn, ln)
                defined := not na(noGain) and not na(noLoss) and not na(intact)
                lo := defined ? math.min(intact, noGain) : na
                hi := defined ? math.max(intact, noLoss) : na
    [lo, hi, defined]

// Independent finite-window audit with a fixed-capacity two-stack FIFO.
// Each stack node has seven floats: raw gain, raw loss, aggregated gain/loss,
// aggregated gain/loss maxima, and q^count. Every sum is nonnegative; the queue
// never subtracts an expiring value from a running total. The main engine uses
// RMA-state subtraction and log-ranked maxima, so the audit takes a separate path.
// Append newer to the input stack: S' = x + q*S.
// Prepend older to the output stack: S' = S + q^count*x.
// Output is older than input: combined S = S_in + q^count_in*S_out.
// Records are overwritten inside fixed buffers; there are no per-bar objects.
f_window_push(array<float> stack, int count, float rawG, float rawL, float decay, bool older) =>
    int slot = 7 * count
    int previous = 7 * (count - 1)
    float sg = count > 0 ? array.get(stack, previous + 2) : 0.0
    float sl = count > 0 ? array.get(stack, previous + 3) : 0.0
    float mg = count > 0 ? array.get(stack, previous + 4) : 0.0
    float ml = count > 0 ? array.get(stack, previous + 5) : 0.0
    float tail = count > 0 ? array.get(stack, previous + 6) : 1.0
    array.set(stack, slot, rawG)
    array.set(stack, slot + 1, rawL)
    array.set(stack, slot + 2, older ? sg + tail * rawG : rawG + decay * sg)
    array.set(stack, slot + 3, older ? sl + tail * rawL : rawL + decay * sl)
    array.set(stack, slot + 4, older ? math.max(mg, tail * rawG) : math.max(rawG, decay * mg))
    array.set(stack, slot + 5, older ? math.max(ml, tail * rawL) : math.max(rawL, decay * ml))
    array.set(stack, slot + 6, tail * decay)
    count + 1

f_window_update(array<float> inputStack, array<float> outputStack, array<int> sizes, int cap, float rawG, float rawL, float decay, bool enabled) =>
    int ni = array.get(sizes, 0)
    int no = array.get(sizes, 1)
    float sg = 0.0
    float sl = 0.0
    float mg = 0.0
    float ml = 0.0
    if not enabled or cap == 0 or na(rawG) or na(rawL)
        ni := 0
        no := 0
    else
        // Evict BEFORE insertion so neither fixed buffer needs cap+1 records.
        if ni + no >= cap
            if no == 0
                // At most cap iterations on a transfer bar; every item moves once.
                while ni > 0
                    ni -= 1
                    int slot = 7 * ni
                    no := f_window_push(outputStack, no, array.get(inputStack, slot), array.get(inputStack, slot + 1), decay, true)
            no -= 1
        ni := f_window_push(inputStack, ni, rawG, rawL, decay, false)
        int ix = 7 * (ni - 1)
        int ox = 7 * (no - 1)
        float tail = array.get(inputStack, ix + 6)
        sg := array.get(inputStack, ix + 2) + (no > 0 ? tail * array.get(outputStack, ox + 2) : 0.0)
        sl := array.get(inputStack, ix + 3) + (no > 0 ? tail * array.get(outputStack, ox + 3) : 0.0)
        mg := math.max(array.get(inputStack, ix + 4), no > 0 ? tail * array.get(outputStack, ox + 4) : 0.0)
        ml := math.max(array.get(inputStack, ix + 5), no > 0 ? tail * array.get(outputStack, ox + 5) : 0.0)
    array.set(sizes, 0, ni)
    array.set(sizes, 1, no)
    [sg, sl, mg, ml, enabled and (cap == 0 or ni + no == cap)]

// History-dependent built-ins always execute on every bar.
float delta = ta.change(src)
float gain = math.max(delta, 0.0)
float loss = math.max(-delta, 0.0)
float g = ta.rma(gain, n)
float l = ta.rma(loss, n)
float rsi = ta.rsi(src, n)
float mass = g + l
float a = 1.0 / n
float q = 1.0 - a
float qh = math.pow(q, h)
float oldG = qh * g[h]
float oldL = qh * l[h]
float recG = g - oldG
float recL = l - oldL
var int streak = 0
streak := not na(delta) ? math.min(streak + 1, 1000000) : 0
bool ready = research and chart.is_standard and streak >= n * settle + h and f_mass(mass) and not na(oldG) and not na(oldL) and not na(rsi)
float identityError = ready ? math.abs(rsi - 100.0 * (g / mass)) : na
bool stateOK = ready and identityError <= TOL and recG / mass >= -EPS and recL / mass >= -EPS
float recentPoints = stateOK ? 50.0 * ((recG - recL) / mass) : na
float olderPoints = stateOK ? 50.0 * ((oldG - oldL) / mass) : na
float latestPoints = stateOK ? 50.0 * a * delta / mass : na
float priorPoints = stateOK ? (h > 1 ? recentPoints - latestPoints : 0.0) : na
float splitError = stateOK ? math.abs(rsi - (50.0 + olderPoints + priorPoints + latestPoints)) : na

// Exact changes in common-denominator attribution, not a second oscillator.
// New term N = 50*a*delta/M. Boundary transfer B = 50*a*q^H*delta[H]/M.
// New mass fraction u = a*abs(delta)/M.
// Delta R = N - B - u*R[1]; Delta O = B - u*O[1].
// Hence Delta RSI = N - u*(RSI[1]-50); boundary transfer cancels.
// B is signed transfer BETWEEN the two cohorts, not RSI memory expiry.
bool turnoverReady = stateOK and stateOK[1]
float newMassFraction = turnoverReady ? a * (gain + loss) / mass : na
float newTermPoints = turnoverReady ? 50.0 * a * delta / mass : na
float boundaryPoints = turnoverReady ? 50.0 * a * qh * delta[h] / mass : na
float recentDilution = turnoverReady ? -newMassFraction * recentPoints[1] : na
float olderDilution = turnoverReady ? -newMassFraction * olderPoints[1] : na
float recentStep = turnoverReady ? recentPoints - recentPoints[1] : na
float olderStep = turnoverReady ? olderPoints - olderPoints[1] : na
float turnoverError = turnoverReady ? math.max(math.abs(recentStep - (newTermPoints - boundaryPoints + recentDilution)), math.max(math.abs(olderStep - (boundaryPoints + olderDilution)), math.abs((rsi - rsi[1]) - (newTermPoints + recentDilution + olderDilution)))) : na
float reconstructionError = stateOK ? math.abs(rsi - (50.0 + recentPoints + olderPoints)) : na
bool mathOK = stateOK and reconstructionError <= TOL and splitError <= TOL and (not turnoverReady or turnoverError <= TOL)

// Gross weighted-movement shares, distinct from signed net RSI contributions.
// The shares' denominator is CURRENT total gain+loss, not abs(RSI-50).
// This display-only audit NEVER changes the existing research sample selection.
float olderMovePctRaw = stateOK ? 100.0 * ((oldG + oldL) / mass) : na
float priorMovePctRaw = stateOK ? (h > 1 ? 100.0 * ((recG + recL - a * (gain + loss)) / mass) : 0.0) : na
float latestMovePctRaw = stateOK ? 100.0 * a * ((gain + loss) / mass) : na
float movementSplitError = stateOK ? math.abs(olderMovePctRaw + priorMovePctRaw + latestMovePctRaw - 100.0) : na
bool movementBoundsOK = stateOK and math.min(olderMovePctRaw, math.min(priorMovePctRaw, latestMovePctRaw)) >= -TOL and math.max(olderMovePctRaw, math.max(priorMovePctRaw, latestMovePctRaw)) <= 100.0 + TOL
// |G-L| <= G+L in each cohort. Since points use 50 and shares use 100,
// twice the absolute NET contribution cannot exceed its movement SHARE.
bool movementTriangleOK = stateOK and 2.0 * math.abs(olderPoints) <= olderMovePctRaw + TOL and 2.0 * math.abs(priorPoints) <= priorMovePctRaw + TOL and 2.0 * math.abs(latestPoints) <= latestMovePctRaw + TOL
bool movementOK = mathOK and movementBoundsOK and movementTriangleOK and not na(movementSplitError) and movementSplitError <= TOL
var int movementChecks = 0
var int movementFailures = 0
if barstate.isconfirmed and mathOK
    movementChecks += 1
    if not movementOK
        movementFailures += 1

var int fastChecked = 0
var int fastFailures = 0
var float fastMaxError = 0.0
if barstate.isconfirmed and ready
    fastChecked += 1
    if not mathOK
        fastFailures += 1
    float observedError = math.max(nz(splitError, 100.0), math.max(nz(identityError, 100.0), math.max(nz(reconstructionError, 100.0), nz(turnoverError, 0.0))))
    fastMaxError := math.max(fastMaxError, observedError)
float base = mathOK ? f_clip(50.0 + olderPoints) : na
float recentShare = mathOK ? f_clip(100.0 * ((recG + recL) / mass)) : na
bool rMaterial = mathOK and math.abs(recentPoints) >= material
bool oMaterial = mathOK and math.abs(olderPoints) >= material
bool opposed = rMaterial and oMaterial and recentPoints * olderPoints < 0.0
int relation = opposed ? 2 : rMaterial and oMaterial ? (recentPoints > 0.0 ? 1 : -1) : rMaterial ? 3 : oMaterial ? 4 : 0

// Ranking uses log(change)-bar_index*log(q), but values are recovered from
// the original change and its integer age, avoiding exp(log-log) cancellation.
// The shifted window EXCLUDES age 0. Current + prior maxima give the full test.
float clockLog = -float(bar_index) * math.log(q)
float logG = f_mass(gain) ? math.log(gain) + clockLog : EMPTY_LOG
float logL = f_mass(loss) ? math.log(loss) + clockLog : EMPTY_LOG
int priorLength = math.max(h - 1, 1)
int ageG = 1 + math.abs(nz(ta.highestbars(logG[1], priorLength), 0))
int ageL = 1 + math.abs(nz(ta.highestbars(logL[1], priorLength), 0))
float priorG = h > 1 and f_mass(gain[ageG]) ? a * math.pow(q, ageG) * gain[ageG] : 0.0
float priorL = h > 1 and f_mass(loss[ageL]) ? a * math.pow(q, ageL) * loss[ageL] : 0.0
float peakG = math.max(a * gain, priorG)
float peakL = math.max(a * loss, priorL)
[fullLowRaw, fullHighRaw, fullDefined] = f_envelope(g, l, peakG, peakL)
[priorLowRaw, priorHighRaw, priorDefined] = f_envelope(g, l, priorG, priorL)
bool fullOK = mathOK and probes and fullDefined
bool priorOK = mathOK and probes and h > 1 and priorDefined
float fullLow = fullOK ? fullLowRaw : na
float fullHigh = fullOK ? fullHighRaw : na
float width = fullOK ? fullHigh - fullLow : na
int side = f_side(rsi)
bool sensitive = fullOK and (f_side(fullLow) != side or f_side(fullHigh) != side)
bool priorSensitive = priorOK and (f_side(priorLowRaw) != side or f_side(priorHighRaw) != side)
// Do not let floating-point boundary ambiguity fabricate an entry group.
bool classifiable = priorOK and not f_near(rsi) and not f_near(priorLowRaw) and not f_near(priorHighRaw)

// Supporting mass needed to TOUCH the current extreme threshold.
// Upper: x=(G/M-U)/(1-U); lower: x=(Lthreshold-G/M)/Lthreshold.
// This uses the CURRENT denominator, with age 0 and older state held fixed.
// The percent of prior support can exceed 100: insufficient tested support.
// At 0/100 or a singular residual, a finite touch may be undefined.
float normalizedG = mathOK ? g / mass : na
float thresholdFraction = side == 1 ? upper / 100.0 : lower / 100.0
float touchNeed = mathOK and side != 0 ? (side == 1 ? (normalizedG - thresholdFraction) / (1.0 - thresholdFraction) : (thresholdFraction - normalizedG) / thresholdFraction) : na
bool thresholdOK = mathOK and probes and h >= 2 and side != 0 and not f_near(rsi) and not na(touchNeed) and touchNeed >= 0.0 and 1.0 - touchNeed > MIN_RESIDUAL
float priorSupport = thresholdOK ? math.max(0.0, side == 1 ? recG / mass - a * gain / mass : recL / mass - a * loss / mass) : na
float touchMassPct = thresholdOK ? 100.0 * touchNeed : na
float priorBudgetPct = thresholdOK and priorSupport > EPS ? 100.0 * touchNeed / priorSupport : na

// Latest-snapshot direct audits, concentration and sorted order extrema.
var int snapBar = na
var float orderLow = na
var float orderHigh = na
var float neutralOrder = na
var float orderPosition = na
var float meanAge = na
var float gainMeanAge = na
var float lossMeanAge = na
var float effectiveTerms = na
var float topShare = na
var float directError = na
var float removalError = na
var bool orderAudit = false
var bool orderAttempted = false
var bool snapshotOK = false
var float thresholdAuditError = na
var int minimumPriorTerms = na
var int supportingPriorTerms = 0
var int dominantPriorAge = na
var array<int> termAges = array.new_int(0)
var array<float> termOutcomes = array.new_float(0)
var array<float> termImpacts = array.new_float(0)
var array<float> termContributions = array.new_float(0)
var array<float> termRankKeys = array.new_float(0)
var array<int> termRankOrder = array.new_int(0)
var int referenceCrossCount = 0
var int referenceTouchCount = 0
var int witnessAge = na
var float witnessRSI = na
var float witnessWeight = na
var float witnessTouchPct = na
var float witnessAuditError = na
var float ledgerAuditError = na
bool snapshotTick = barstate.islastconfirmedhistory or (barstate.islast and (barstate.isconfirmed or not closed))
if snapshotTick
    snapBar := bar_index
    orderLow := na
    orderHigh := na
    neutralOrder := na
    orderPosition := na
    meanAge := na
    gainMeanAge := na
    lossMeanAge := na
    effectiveTerms := na
    topShare := na
    directError := na
    removalError := na
    orderAudit := false
    orderAttempted := false
    snapshotOK := false
    thresholdAuditError := na
    minimumPriorTerms := na
    supportingPriorTerms := 0
    dominantPriorAge := na
    array.clear(termAges)
    array.clear(termOutcomes)
    array.clear(termImpacts)
    array.clear(termContributions)
    array.clear(termRankKeys)
    array.clear(termRankOrder)
    referenceCrossCount := 0
    referenceTouchCount := 0
    witnessAge := na
    witnessRSI := na
    witnessWeight := na
    witnessTouchPct := na
    witnessAuditError := na
    ledgerAuditError := na
    if mathOK
        array<float> moves = array.new_float(0)
        array<float> supportWeights = array.new_float(0)
        float selectedLevel = f_reference(rsi)
        bool aboveReference = rsi > selectedLevel + TOL
        bool belowReference = rsi < selectedLevel - TOL
        float rg = 0.0
        float rl = 0.0
        float ag = 0.0
        float al = 0.0
        float squares = 0.0
        float biggest = 0.0
        float rawG = 0.0
        float rawL = 0.0
        float dl = rsi
        float dh = rsi
        float pl = rsi
        float ph = rsi
        bool directFullOK = true
        bool directPriorOK = true
        float w = a
        for k = 0 to h - 1
            float d = delta[k] / mass
            float wg = w * math.max(d, 0.0)
            float wl = w * math.max(-d, 0.0)
            float term = wg + wl
            rg += wg
            rl += wl
            ag += k * wg
            al += k * wl
            squares += term * term
            biggest := math.max(biggest, term)
            rawG += math.max(d, 0.0)
            rawL += math.max(-d, 0.0)
            if probes
                if 1.0 - term > MIN_RESIDUAL
                    float candidate = f_clip(100.0 * math.max(g / mass - wg, 0.0) / (1.0 - term))
                    dl := math.min(dl, candidate)
                    dh := math.max(dh, candidate)
                    if k > 0
                        pl := math.min(pl, candidate)
                        ph := math.max(ph, candidate)
                        float impact = candidate - rsi
                        array.push(termAges, k)
                        array.push(termOutcomes, candidate)
                        array.push(termImpacts, impact)
                        array.push(termContributions, 50.0 * (wg - wl))
                        array.push(termRankKeys, math.abs(impact))
                        int singleTest = f_reference_test(rsi, math.min(rsi, candidate), math.max(rsi, candidate), selectedLevel)
                        referenceCrossCount += singleTest == 3 ? 1 : 0
                        referenceTouchCount += singleTest == 2 ? 1 : 0
                        // Select the largest eligible supporting term TOWARD the reference.
                        // Ties retain the most recent age because the scan is chronological.
                        bool helps = (aboveReference and f_mass(wg)) or (belowReference and f_mass(wl))
                        float eligibleWeight = aboveReference ? wg : wl
                        if helps and (na(witnessAge) or math.sign(eligibleWeight - witnessWeight) == 1)
                            witnessAge := k
                            witnessRSI := candidate
                            witnessWeight := eligibleWeight
                else
                    directFullOK := false
                    if k > 0
                        directPriorOK := false
            if thresholdOK and k > 0
                float support = side == 1 ? wg : wl
                if f_mass(support)
                    array.push(supportWeights, support)
            if orderTest
                array.push(moves, d)
            w *= q
        directError := 100.0 * math.max(math.abs(rg - recG / mass), math.abs(rl - recL / mass))
        if fullOK and directFullOK
            removalError := math.max(math.abs(dl - fullLow), math.abs(dh - fullHigh))
        if priorOK and directPriorOK
            float priorError = math.max(math.abs(pl - priorLowRaw), math.abs(ph - priorHighRaw))
            removalError := na(removalError) ? priorError : math.max(removalError, priorError)
        if (fullOK and not directFullOK) or (priorOK and not directPriorOK)
            removalError := 100.0
        // Availability disagreement is a failed audit, not a quiet n/a.
        if probes and (fullDefined != directFullOK or (h > 1 and priorDefined != directPriorOK))
            removalError := 100.0
        bool snapshotPass = directError <= TOL and (na(removalError) or removalError <= TOL)
        if probes and h > 1 and directPriorOK and priorOK
            termRankOrder := array.sort_indices(termRankKeys, order.descending)
            // Sum ADDITIVE prior contributions; never sum nonlinear zeroing effects.
            float directPriorPoints = array.sum(termContributions)
            ledgerAuditError := math.abs(directPriorPoints - priorPoints)
            snapshotPass := snapshotPass and ledgerAuditError <= TOL and array.size(termAges) == h - 1
            if not na(witnessAge) and witnessWeight > EPS and (aboveReference or belowReference)
                float refFraction = selectedLevel / 100.0
                float needed = aboveReference ? (g / mass - refFraction) / (1.0 - refFraction) : (refFraction - g / mass) / refFraction
                if needed >= 0.0 and 1.0 - needed > MIN_RESIDUAL
                    witnessTouchPct := 100.0 * needed / witnessWeight
                    // >100 means this term alone is insufficient; it is not an executable stress.
                    if needed <= witnessWeight + EPS
                        float touchedRef = aboveReference ? f_ratio(math.max(g / mass - needed, 0.0), l / mass) : f_ratio(g / mass, math.max(l / mass - needed, 0.0))
                        witnessAuditError := na(touchedRef) ? 100.0 : math.abs(touchedRef - selectedLevel)
                        snapshotPass := snapshotPass and witnessAuditError <= TOL
        if thresholdOK
            float touched = side == 1 ? f_ratio(normalizedG - touchNeed, l / mass) : f_ratio(normalizedG, l / mass - touchNeed)
            float target = side == 1 ? upper : lower
            float directSupport = side == 1 ? rg - a * gain / mass : rl - a * loss / mass
            thresholdAuditError := na(touched) ? 100.0 : math.max(math.abs(touched - target), 100.0 * math.abs(directSupport - priorSupport))
            snapshotPass := snapshotPass and thresholdAuditError <= TOL
            supportingPriorTerms := array.size(supportWeights)
            dominantPriorAge := supportingPriorTerms > 0 ? (side == 1 ? ageG : ageL) : na
            if snapshotPass and supportingPriorTerms > 0
                array.sort(supportWeights, order.descending)
                float erased = 0.0
                for k = 0 to supportingPriorTerms - 1
                    erased += array.get(supportWeights, k)
                    if na(minimumPriorTerms) and 1.0 - erased > MIN_RESIDUAL
                        float candidate = side == 1 ? f_ratio(math.max(normalizedG - erased, 0.0), l / mass) : f_ratio(normalizedG, math.max(l / mass - erased, 0.0))
                        // TOUCH/CROSS within TOL, not the stricter entry class.
                        bool reached = not na(candidate) and (side == 1 ? candidate <= upper + TOL : candidate >= lower - TOL)
                        if reached
                            minimumPriorTerms := k + 1
        float rm = rg + rl
        if snapshotPass and orderTest
            orderAttempted := true
            if f_mass(rm) and f_mass(squares)
                effectiveTerms := math.max(1.0, math.min(float(h), rm * rm / squares))
                meanAge := (ag + al) / rm
                gainMeanAge := f_mass(rg) ? ag / rg : na
                lossMeanAge := f_mass(rl) ? al / rl : na
                topShare := f_clip(100.0 * biggest / rm)
            array.sort(moves, order.ascending)
            float minG = oldG / mass
            float minL = oldL / mass
            float maxG = minG
            float maxL = minL
            w := a
            for k = 0 to h - 1
                float small = array.get(moves, k)
                float large = array.get(moves, h - 1 - k)
                minG += w * math.max(small, 0.0)
                minL += w * math.max(-small, 0.0)
                maxG += w * math.max(large, 0.0)
                maxL += w * math.max(-large, 0.0)
                w *= q
            float ol = f_ratio(minG, minL)
            float oh = f_ratio(maxG, maxL)
            orderAudit := not na(ol) and not na(oh) and ol <= oh + TOL and rsi >= ol - TOL and rsi <= oh + TOL
            if orderAudit
                orderLow := math.min(ol, rsi)
                orderHigh := math.max(oh, rsi)
                float equalWeight = (1.0 - qh) / h
                neutralOrder := f_ratio(oldG / mass + equalWeight * rawG, oldL / mass + equalWeight * rawL)
                orderPosition := orderHigh - orderLow > TOL ? f_clip(100.0 * (rsi - orderLow) / (orderHigh - orderLow)) : na
        snapshotOK := snapshotPass and (not orderAttempted or orderAudit)

// Deterministic HISTORY eligibility must not use barstate.islast or snapshotTick.
// Direct scans are latest-only diagnostics; gating the study by those scans would
// re-admit a previously rejected live observation after a full reload.
// The historical gate uses identities evaluated on EVERY eligible observation.
bool activeOK = mathOK
// Independent window validation runs on EVERY observation, not only candidates.
// It stores the H-1 prior changes; the arriving age-0 change is combined below.
// No function-local history indexing, per-candidate rescan, or latest-only gate.
int auditCapacity = math.max(h - 1, 0)
var array<float> auditInput = array.new_float(7 * math.max(h - 1, 1), 0.0)
var array<float> auditOutput = array.new_float(7 * math.max(h - 1, 1), 0.0)
var array<int> auditSizes = array.new_int(2, 0)
[windowG, windowL, windowPeakG, windowPeakL, windowComplete] = f_window_update(auditInput, auditOutput, auditSizes, auditCapacity, gain[1], loss[1], q, research and chart.is_standard)
float auditPriorG = a * q * windowG
float auditPriorL = a * q * windowL
float auditRecentG = a * gain + auditPriorG
float auditRecentL = a * loss + auditPriorL
float auditPriorPeakG = a * q * windowPeakG
float auditPriorPeakL = a * q * windowPeakL
float auditPeakG = math.max(a * gain, auditPriorPeakG)
float auditPeakL = math.max(a * loss, auditPriorPeakL)
bool rollingAuditOK = false
float rollingAuditError = na
if activeOK and windowComplete
    float rebuilt = f_ratio(oldG / mass + auditRecentG / mass, oldL / mass + auditRecentL / mass)
    rollingAuditError := 100.0 * math.max(math.abs(auditRecentG / mass - recG / mass), math.abs(auditRecentL / mass - recL / mass))
    rollingAuditError := math.max(rollingAuditError, na(rebuilt) ? 100.0 : math.abs(rebuilt - rsi))
    bool available = true
    if probes
        [auditFullLow, auditFullHigh, auditFullDefined] = f_audit_bounds(g, l, auditPeakG, auditPeakL)
        [auditPriorLow, auditPriorHigh, auditPriorDefined] = f_audit_bounds(g, l, auditPriorPeakG, auditPriorPeakL)
        available := auditFullDefined == fullDefined and (h <= 1 or auditPriorDefined == priorDefined)
        if auditFullDefined and fullDefined
            rollingAuditError := math.max(rollingAuditError, math.max(math.abs(auditFullLow - fullLowRaw), math.abs(auditFullHigh - fullHighRaw)))
        if h > 1 and auditPriorDefined and priorDefined
            rollingAuditError := math.max(rollingAuditError, math.max(math.abs(auditPriorLow - priorLowRaw), math.abs(auditPriorHigh - priorHighRaw)))
    if not available
        rollingAuditError := 100.0
    rollingAuditOK := available and not na(rollingAuditError) and rollingAuditError <= TOL

// A consistent live/closed snapshot. No historical offsets or backdating.
bool hold = closed and not barstate.isconfirmed
bool drawThisBar = not hold
bool aligned = not na(snapBar) and snapBar == (hold ? bar_index - 1 : bar_index)
float vr = hold ? rsi[1] : rsi
bool vCoreOK = hold ? mathOK[1] : mathOK
// Historical plot series use the all-bar gate only. A direct latest-only failure
// quarantines the current panel/bracket, not a history point that could reappear
// after reload. Keep these two lineages explicitly separate.
bool historyResearchOK = hold ? activeOK[1] : activeOK
bool vok = historyResearchOK and (not aligned or snapshotOK)
bool vready = hold ? ready[1] : ready
float vb = vok ? (hold ? base[1] : base) : na
float vp = vok ? (hold ? recentPoints[1] : recentPoints) : na
float vo = vok ? (hold ? olderPoints[1] : olderPoints) : na
float vs = vok ? (hold ? recentShare[1] : recentShare) : na
float vLatest = vok ? (hold ? latestPoints[1] : latestPoints) : na
float vPriorPoints = vok ? (hold ? priorPoints[1] : priorPoints) : na
float vSplitError = hold ? splitError[1] : splitError
float componentScale = vok ? math.max(math.abs(vo), math.max(math.abs(vPriorPoints), math.abs(vLatest))) : na
bool vMovementOK = vok and (hold ? movementOK[1] : movementOK)
float vOlderMove = vMovementOK ? f_clip(hold ? olderMovePctRaw[1] : olderMovePctRaw) : na
float vPriorMove = vMovementOK ? f_clip(hold ? priorMovePctRaw[1] : priorMovePctRaw) : na
float vLatestMove = vMovementOK ? f_clip(hold ? latestMovePctRaw[1] : latestMovePctRaw) : na
float vMovementError = hold ? movementSplitError[1] : movementSplitError
bool vdOK = vok and (hold ? fullOK[1] : fullOK)
float vdLow = vdOK ? (hold ? fullLow[1] : fullLow) : na
float vdHigh = vdOK ? (hold ? fullHigh[1] : fullHigh) : na
float vdWidth = vdOK ? (hold ? width[1] : width) : na
bool vf = hold ? sensitive[1] : sensitive
int vrel = hold ? relation[1] : relation
float vIdentity = hold ? identityError[1] : identityError
bool snapshotUsable = aligned and snapshotOK and vok
bool vtOK = vok and (hold ? turnoverReady[1] : turnoverReady)
float vtNew = vtOK ? (hold ? newTermPoints[1] : newTermPoints) : na
float vtBoundary = vtOK ? (hold ? boundaryPoints[1] : boundaryPoints) : na
float vtRecentDilution = vtOK ? (hold ? recentDilution[1] : recentDilution) : na
float vtOlderDilution = vtOK ? (hold ? olderDilution[1] : olderDilution) : na
float vtRecentStep = vtOK ? (hold ? recentStep[1] : recentStep) : na
float vtOlderStep = vtOK ? (hold ? olderStep[1] : olderStep) : na
bool vtSupport = vok and (hold ? thresholdOK[1] : thresholdOK)
float vTouchMass = vtSupport ? (hold ? touchMassPct[1] : touchMassPct) : na
float vPriorBudget = vtSupport ? (hold ? priorBudgetPct[1] : priorBudgetPct) : na
float vTurnoverError = hold ? turnoverError[1] : turnoverError

// Immediate reference context is separate from the upper/lower entry label.
float rsiStep = not na(rsi) and not na(rsi[1]) and not na(delta) ? rsi - rsi[1] : na
float vRsiStep = hold ? rsiStep[1] : rsiStep
int displayedIndex = hold ? bar_index - 1 : bar_index
float referenceNow = f_reference(rsi)
float vReference = f_reference(vr)
bool vPriorOK = vok and (hold ? priorOK[1] : priorOK)
float vPriorLow = vPriorOK ? (hold ? priorLowRaw[1] : priorLowRaw) : na
float vPriorHigh = vPriorOK ? (hold ? priorHighRaw[1] : priorHighRaw) : na
int refTestNow = activeOK and priorOK ? f_reference_test(rsi, priorLowRaw, priorHighRaw, referenceNow) : -1
int vRefTest = vPriorOK ? f_reference_test(vr, vPriorLow, vPriorHigh, vReference) : -1
float vRefDistance = not na(vr) and not na(vReference) ? math.abs(vr - vReference) : na
// "Material" means the user's point cutoff, NOT statistical significance.
// Confirmed anchor is independent of the main display's LIVE/CLOSED switch.
bool anchorConfirmedNow = barstate.isconfirmed
bool anchorValid = anchorConfirmedNow ? activeOK : activeOK[1]
float anchorSource = anchorConfirmedNow ? src : src[1]
float anchorG = anchorConfirmedNow ? g : g[1]
float anchorL = anchorConfirmedNow ? l : l[1]
float anchorRSI = anchorConfirmedNow ? rsi : rsi[1]
int anchorTime = anchorConfirmedNow ? time_close : time_close[1]
[nextLowerRaw, nextLowerError] = f_next_level(anchorSource, anchorG, anchorL, lower)
[nextMiddleRaw, nextMiddleError] = f_next_level(anchorSource, anchorG, anchorL, 50.0)
[nextUpperRaw, nextUpperError] = f_next_level(anchorSource, anchorG, anchorL, upper)
float mapError = math.max(nextLowerError, math.max(nextMiddleError, nextUpperError))
bool mapEligible = research and closeMap and chart.is_standard and anchorValid
bool mapOK = mapEligible and not na(mapError) and mapError <= TOL
// Validate each inverse independently: one numerically unrepresentable level
// must not hide another well-defined level. The summary mapOK still checks all three.
float nextLower = mapEligible and not na(nextLowerError) and nextLowerError <= TOL ? nextLowerRaw : na
float nextMiddle = mapEligible and not na(nextMiddleError) and nextMiddleError <= TOL ? nextMiddleRaw : na
float nextUpper = mapEligible and not na(nextUpperError) and nextUpperError <= TOL ? nextUpperRaw : na
// The nearest TARGET, not just its input state, is fixed to the confirmed anchor.
float mapReference = f_reference(anchorRSI)
float nextReference = na(mapReference) ? na : mapReference == upper ? nextUpper : mapReference == lower ? nextLower : nextMiddle
// Close-map audit is separate from native RSI / attribution availability.
// A failed map never invalidates the independent RSI history or its studies.
var int mapChecks = 0
var int mapFailures = 0
var float mapMaxError = 0.0
if barstate.isconfirmed and mapEligible
    mapChecks += 1
    if not mapOK
        mapFailures += 1
    mapMaxError := math.max(mapMaxError, nz(mapError, 100.0))

// Confirmed episodes; left-censored and interrupted episodes are not completions.
bool dateOK = not useDates or fromTime <= toTime
bool inDates = not useDates or (not na(time_close) and time_close >= fromTime and time_close <= toTime)
bool sample = activeOK and dateOK and inDates
bool confirmedSample = barstate.isconfirmed ? sample : sample[1]
var int validSampleRun = 0
validSampleRun := sample ? math.min(validSampleRun + 1, 1000000) : 0
bool enterU = barstate.isconfirmed and sample and sample[1] and side == 1 and side[1] != 1
bool enterL = barstate.isconfirmed and sample and sample[1] and side == -1 and side[1] != -1
var array<float> upAges = array.new_float(0)
var array<float> downAges = array.new_float(0)
var array<float> upAreas = array.new_float(0)
var array<float> downAreas = array.new_float(0)
var int epSide = 0
var int epAge = 0
var float epArea = 0.0
var float epPeak = 0.0
var bool partial = false
// Groups: upper unchanged, upper changed, lower unchanged, lower changed.
// "Changed" means a prior-term zeroing changes the RSI threshold class.
// These groups are the original prior-only test; age 0 stays excluded.
var array<int> counts = array.new_int(4, 0)
var array<int> ends = array.new_int(4, 0)
var array<int> runs = array.new_int(4, 0)
var array<int> pending = array.new_int(2, 0)
var array<int> dropped = array.new_int(2, 0)
var array<int> unclassified = array.new_int(2, 0)
var array<int> overlaps = array.new_int(2, 0)
// Walk-forward training uses ONLY selected, classified, matured entries.
// Six baseline cells: two sides x three fixed RSI overshoot bands.
// Twelve augmented cells add the binary prior-term class.
var array<int> wfBaseN = array.new_int(6, 0)
var array<int> wfBaseE = array.new_int(6, 0)
var array<int> wfClassN = array.new_int(12, 0)
var array<int> wfClassE = array.new_int(12, 0)
var array<int> wfPairs = array.new_int(2, 0)
var array<int> wfUntrained = array.new_int(2, 0)
var array<float> wfBaseLoss = array.new_float(2, 0.0)
var array<float> wfClassLoss = array.new_float(2, 0.0)
var int occupiedThrough = na
var int firstSampleTime = na
var int lastSampleTime = na
int entryGroup = -1
int entryBand = -1
float entryBaseEstimate = na
float entryClassEstimate = na
bool studyOn = research and probes and eventStudy and h >= 2
if barstate.isconfirmed
    if not sample
        epSide := 0
        epAge := 0
        epArea := 0.0
        epPeak := 0.0
        partial := false
    else
        firstSampleTime := na(firstSampleTime) ? time_close : firstSampleTime
        lastSampleTime := time_close
        if side != epSide
            if sample[1] and epSide != 0 and not partial and epAge > 0 and episodes
                f_add(epSide == 1 ? upAges : downAges, float(epAge))
                f_add(epSide == 1 ? upAreas : downAreas, epArea)
            epSide := side
            epAge := 0
            epArea := 0.0
            epPeak := 0.0
            partial := side != 0 and not sample[1]
        if side != 0
            float excess = side == 1 ? math.max(rsi - upper, 0.0) : math.max(lower - rsi, 0.0)
            epAge += 1
            epArea += excess
            epPeak := math.max(epPeak, excess)
    if studyOn and (enterU or enterL)
        int si = enterU ? 0 : 1
        if not classifiable
            f_inc(unclassified, si)
        else if separateWindows and not na(occupiedThrough) and bar_index <= occupiedThrough
            f_inc(overlaps, si)
        else
            entryGroup := si * 2 + (priorSensitive ? 1 : 0)
            entryBand := si * 3 + f_band(rsi, side)
            // Freeze BEFORE processing outcomes maturing on this same close.
            // Thus every training outcome is strictly older than this entry.
            if walkForward
                int modelCell = entryBand * 2 + (priorSensitive ? 1 : 0)
                int nb = array.get(wfBaseN, entryBand)
                int nc = array.get(wfClassN, modelCell)
                if nb >= minSample and nc >= minSample
                    entryBaseEstimate := (array.get(wfBaseE, entryBand) + 0.5) / (nb + 1.0)
                    entryClassEstimate := (array.get(wfClassE, modelCell) + 0.5) / (nc + 1.0)
                else
                    f_inc(wfUntrained, si)
            f_inc(pending, si)
            occupiedThrough := bar_index + horizon
    int matured = entryGroup[horizon]
    if studyOn and not na(matured) and matured >= 0
        int si = matured < 2 ? 0 : 1
        array.set(pending, si, math.max(0, array.get(pending, si) - 1))
        if validSampleRun >= horizon + 1
            int initialSide = si == 0 ? 1 : -1
            bool sameSide = side == initialSide
            f_inc(counts, matured)
            if sameSide
                f_inc(ends, matured)
                if epAge >= horizon + 1
                    f_inc(runs, matured)
            if walkForward
                float pb = entryBaseEstimate[horizon]
                float pc = entryClassEstimate[horizon]
                // Score both models on EXACTLY the same matured observations.
                if not na(pb) and not na(pc)
                    float y = sameSide ? 1.0 : 0.0
                    f_inc(wfPairs, si)
                    array.set(wfBaseLoss, si, array.get(wfBaseLoss, si) + math.pow(pb - y, 2))
                    array.set(wfClassLoss, si, array.get(wfClassLoss, si) + math.pow(pc - y, 2))
                int b = entryBand[horizon]
                if not na(b) and b >= 0 and b < 6
                    int c = b * 2 + matured % 2
                    f_inc(wfBaseN, b)
                    f_inc(wfClassN, c)
                    if sameSide
                        f_inc(wfBaseE, b)
                        f_inc(wfClassE, c)
        else
            f_inc(dropped, si)

// Deterministic confirmed events. Raw candidates never depend on the latest-only
// display audit or a previous emitted-event latch. A failed rolling-window check
// drops that occurrence in both live-close and historical evaluation; it does not
// defer the event and invent a later onset. Native RSI events stay independent.
bool nativePair = not na(rsi) and not na(rsi[1]) and not na(delta)
bool exitUpper = barstate.isconfirmed and nativePair and side != 1 and side[1] == 1
bool exitLower = barstate.isconfirmed and nativePair and side != -1 and side[1] == -1
bool centerUp = ta.crossover(rsi, 50.0)
bool centerDown = ta.crossunder(rsi, 50.0)
bool sameReference = not na(referenceNow) and not na(referenceNow[1]) and referenceNow == referenceNow[1]
bool rawSensitive = activeOK and activeOK[1] and fullOK and fullOK[1] and sensitive and not sensitive[1]
bool rawWide = activeOK and activeOK[1] and fullOK and fullOK[1] and width >= flagWidth and width[1] < flagWidth
bool rawOpposed = activeOK and activeOK[1] and opposed and not opposed[1]
bool turnoverOpposed = activeOK and turnoverReady and math.abs(recentStep) >= material and math.abs(newTermPoints) >= material and recentStep * newTermPoints < 0.0
bool rawTurnoverOpposed = activeOK and activeOK[1] and turnoverReady and turnoverReady[1] and turnoverOpposed and not turnoverOpposed[1]
bool rawPriorCross = activeOK and activeOK[1] and priorOK and priorOK[1] and sameReference and refTestNow == 3 and refTestNow[1] >= 0 and refTestNow[1] != 3
bool eventCandidate = barstate.isconfirmed and (rawSensitive or rawWide or rawOpposed or rawTurnoverOpposed or rawPriorCross)
bool eventAuditOK = false
float eventCurrentError = na
float eventPreviousError = na
var int eventChecks = 0
var int eventFailures = 0
var float eventMaxError = na
if eventCandidate
    bool currentPass = rollingAuditOK
    bool previousPass = rollingAuditOK[1]
    float currentError = rollingAuditError
    float previousError = rollingAuditError[1]
    eventCurrentError := currentError
    eventPreviousError := previousError
    eventAuditOK := currentPass and previousPass
    eventChecks += 1
    if not eventAuditOK
        eventFailures += 1
    float observedEventError = math.max(nz(currentError, 100.0), nz(previousError, 100.0))
    eventMaxError := na(eventMaxError) ? observedEventError : math.max(eventMaxError, observedEventError)
bool newSensitive = eventCandidate and eventAuditOK and rawSensitive
bool newWide = eventCandidate and eventAuditOK and rawWide
bool newOpposed = eventCandidate and eventAuditOK and rawOpposed
bool newTurnoverOpposed = eventCandidate and eventAuditOK and rawTurnoverOpposed
bool priorCrossAppeared = eventCandidate and eventAuditOK and rawPriorCross

// Focus separates the current reading from historical explanatory layers.
// It never changes RSI values, sample selection or the research calculations.
p100 = hline(100.0, "100", color = color.new(cMuted, 92))
p0 = hline(0.0, "0", color = color.new(cMuted, 92))
pUpper = hline(upper, "Upper threshold", color = color.new(cDown, 30), linestyle = hline.style_dashed)
pLower = hline(lower, "Lower threshold", color = color.new(cUp, 30), linestyle = hline.style_dashed)
hline(50.0, "50 | Balance", color = color.new(cMuted, 35), linestyle = hline.style_dotted)
fill(p100, pUpper, color = showZones ? color.new(cDown, 96) : na, title = "Upper zone / not a sell instruction")
fill(p0, pLower, color = showZones ? color.new(cUp, 96) : na, title = "Lower zone / not a buy instruction")
bool fullVisuals = visualMode == "Full research"
bool memoryVisible = drawThisBar and showMemory and historyResearchOK and (fullVisuals or relation == 2)
bool removalVisible = drawThisBar and showEnvelope and fullVisuals and activeOK and fullOK
pDL = plot(removalVisible ? fullLow : na, "All-term removal lower", color = color.new(cTest, envelopeEdges ? 50 : 100), linewidth = 1, style = plot.style_linebr, display = display.pane)
pDH = plot(removalVisible ? fullHigh : na, "All-term removal upper", color = color.new(cTest, envelopeEdges ? 50 : 100), linewidth = 1, style = plot.style_linebr, display = display.pane)
fill(pDL, pDH, color = color.new(cTest, envelopeAlpha), title = "All-term removal range / not a forecast", fillgaps = false)
pB = plot(memoryVisible ? base : na, "Older contribution base / not a separate RSI", color = color.new(cOld, 30), linewidth = 1, style = plot.style_linebr, display = display.pane)
pA = plot(memoryVisible ? rsi : na, "Recent ribbon anchor", display = display.none, editable = false)
fill(pB, pA, color = color.new(recentPoints >= 0.0 ? cUp : cDown, ribbonAlpha), title = "Recent signed contribution / Focus shows material opposition", fillgaps = false)
plot(drawThisBar and showHalo ? vr : na, "RSI halo", color = color.new(cRSI, 90), linewidth = lineWidth + 2, style = plot.style_linebr, display = display.pane, editable = false)
plot(drawThisBar ? vr : na, "RSI", color = cRSI, linewidth = lineWidth, style = plot.style_linebr, display = display.pane + display.data_window)
color stripInk = relation == 2 ? cTest : relation == 1 ? cUp : relation == -1 ? cDown : relation == 3 or relation == 4 ? cOld : color.new(cMuted, 55)
plot(drawThisBar and showStrip and historyResearchOK ? 4.0 : na, "Memory state strip / see Legend", color = stripInk, linewidth = 3, style = plot.style_linebr, display = display.pane)
bool circleNow = (markers == "Classification circles" or markers == "Both") and newSensitive
float markValue = markers == "Threshold exits" ? (exitUpper ? upper : exitLower ? lower : na) : circleNow ? rsi : na
bool squareNow = (markers == "Width squares" or markers == "Both") and newWide and not circleNow
plotshape(markValue, "Confirmed sensitivity / optional threshold exit circle", style = shape.circle, location = location.absolute, color = cTest, size = size.tiny, display = display.pane)
plotshape(squareNow ? rsi : na, "Confirmed width crossing / square", style = shape.square, location = location.absolute, color = cOrder, size = size.tiny, display = display.pane)
// Fixed-budget Data Window exports. This block is presentation-only.
// All underlying series are already computed above on their original schedules.
// This routes the EXACT former export expressions, including their na/close gates.
// Changing a group re-evaluates the whole chart. It never switches groups mid-series.
float dw1 = na
float dw2 = na
float dw3 = na
float dw4 = na
float dw5 = na
float dw6 = na
float dw7 = na
float dw8 = na
if dataWindowGroup == "Attribution"
    dw1 := drawThisBar ? (activeOK ? olderPoints : na) : na
    dw2 := drawThisBar ? (activeOK ? priorPoints : na) : na
    dw3 := drawThisBar ? (activeOK ? latestPoints : na) : na
    dw4 := drawThisBar and movementOK ? f_clip(olderMovePctRaw) : na
    dw5 := drawThisBar and movementOK ? f_clip(priorMovePctRaw) : na
    dw6 := drawThisBar and movementOK ? f_clip(latestMovePctRaw) : na
    dw7 := drawThisBar ? (activeOK ? recentPoints : na) : na
    dw8 := drawThisBar ? (activeOK ? recentShare : na) : na
else if dataWindowGroup == "Removal tests"
    dw1 := drawThisBar ? (activeOK and fullOK ? fullLow : na) : na
    dw2 := drawThisBar ? (activeOK and fullOK ? fullHigh : na) : na
    dw3 := drawThisBar ? (activeOK and fullOK ? width : na) : na
    dw4 := drawThisBar ? (activeOK and priorOK ? priorLowRaw : na) : na
    dw5 := drawThisBar ? (activeOK and priorOK ? priorHighRaw : na) : na
    dw6 := drawThisBar ? referenceNow : na
    dw7 := drawThisBar and refTestNow >= 0 ? refTestNow : na
    dw8 := drawThisBar ? (activeOK and thresholdOK ? touchMassPct : na) : na
else if dataWindowGroup == "Turnover"
    dw1 := drawThisBar ? (activeOK and turnoverReady ? newTermPoints : na) : na
    dw2 := drawThisBar ? (activeOK and turnoverReady ? boundaryPoints : na) : na
    dw3 := drawThisBar ? (activeOK and turnoverReady ? recentDilution : na) : na
    dw4 := drawThisBar ? (activeOK and turnoverReady ? olderDilution : na) : na
    dw5 := drawThisBar ? (activeOK and turnoverReady ? recentStep : na) : na
    dw6 := drawThisBar ? (activeOK and turnoverReady ? olderStep : na) : na
    dw7 := drawThisBar ? rsiStep : na
    dw8 := drawThisBar ? turnoverError : na
else if dataWindowGroup == "Episodes and entries"
    dw1 := episodes and epSide != 0 ? epAge : na
    dw2 := episodes and epSide != 0 ? epArea : na
    dw3 := entryGroup >= 0 ? entryGroup : na
    dw4 := entryBaseEstimate
    dw5 := entryClassEstimate
    dw6 := na
    dw7 := na
    dw8 := na
else if dataWindowGroup == "Reference and map"
    dw1 := drawThisBar ? (activeOK ? base : na) : na
    dw2 := drawThisBar ? (activeOK and thresholdOK ? touchMassPct : na) : na
    dw3 := drawThisBar ? (activeOK and thresholdOK ? priorBudgetPct : na) : na
    dw4 := drawThisBar ? referenceNow : na
    dw5 := nextLower
    dw6 := nextMiddle
    dw7 := nextUpper
    dw8 := anchorRSI
else if dataWindowGroup == "Diagnostics"
    dw1 := drawThisBar ? identityError : na
    dw2 := drawThisBar ? turnoverError : na
    dw3 := drawThisBar ? movementSplitError : na
    dw4 := drawThisBar ? splitError : na
    dw5 := drawThisBar ? rollingAuditError : na
    dw6 := eventCurrentError
    dw7 := eventPreviousError
    dw8 := eventCandidate ? (eventAuditOK ? 1.0 : 0.0) : na

plot(dw1, "Research 1 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw2, "Research 2 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw3, "Research 3 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw4, "Research 4 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw5, "Research 5 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw6, "Research 6 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw7, "Research 7 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)
plot(dw8, "Research 8 | Data Window guide", color = color.silver, precision = 9, display = display.data_window, editable = false)

// Exactly three reusable lines and one label; none is placed on price scale.
// A latest-only bracket does not pretend to be a historical plot or projection.
var line probeStem = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.none, width = 1)
var line probeLowCap = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.none, width = 1)
var line probeHighCap = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.none, width = 1)
var label valueBadge = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, size = badgeSize, text_formatting = text.format_bold)
if barstate.islast
    bool bracketUsable = showProbe and vPriorOK and snapshotUsable
    int px = displayedIndex + 2
    float bracketLow = bracketUsable ? vPriorLow : na
    float bracketHigh = bracketUsable ? vPriorHigh : na
    color bracketColor = vRefTest >= 2 ? cTest : cMuted
    line.set_xy1(probeStem, px, bracketLow)
    line.set_xy2(probeStem, px, bracketHigh)
    line.set_xy1(probeLowCap, px - 1, bracketLow)
    line.set_xy2(probeLowCap, px + 1, bracketLow)
    line.set_xy1(probeHighCap, px - 1, bracketHigh)
    line.set_xy2(probeHighCap, px + 1, bracketHigh)
    line.set_color(probeStem, bracketColor)
    line.set_color(probeLowCap, bracketColor)
    line.set_color(probeHighCap, bracketColor)
    label.set_xy(valueBadge, displayedIndex + (bracketUsable ? 4 : 2), showBadge ? vr : na)
    label.set_text(valueBadge, (hold or barstate.isconfirmed ? "" : "~") + f_num(vr))
    label.set_color(valueBadge, cRSI)
    label.set_textcolor(valueBadge, cBg)
    label.set_tooltip(valueBadge, f_tr("Native RSI. ~ means provisional LIVE. Current prior-only bracket: ", "標準RSI。~は未確定。現在の過去項限定レンジ: ") + f_pair(vPriorLow, vPriorHigh) + f_tr(". Age 0 fixed; zero one prior term. This is not a forecast interval.", "。最新項は固定し、過去項を一つゼロ化。予測区間ではありません。"))

string panelPos = switch corner
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    "Bottom left" => position.bottom_left
    => position.top_right
var table panel = table.new(panelPos, 4, 5, bgcolor = cBg, frame_color = color.new(cMuted, 65), frame_width = 1, border_width = 0)
if barstate.isfirst
    // Populate the grid before merging; every subsequent write uses a merge origin.
    for initRow = 0 to 4
        for initCol = 0 to 3
            table.cell(panel, initCol, initRow, "", bgcolor = cBg, text_size = fontSize)
    if page == "Memory attribution"
        table.merge_cells(panel, 0, 0, 1, 0)
        table.merge_cells(panel, 0, 4, 1, 4)
        table.merge_cells(panel, 2, 4, 3, 4)
        if not showLedgerBars
            for row = 1 to 3
                table.merge_cells(panel, 0, row, 1, row)
    else
        for row = 0 to 4
            table.merge_cells(panel, 0, row, 1, row)
            table.merge_cells(panel, 2, row, 3, row)
if barstate.islast
    if not showPanel
        table.clear(panel, 0, 0, 3, 4)
    else
        string issue = not research ? "RSI ONLY" : not chart.is_standard ? "STANDARD CHART ONLY" : not vready ? "SETTLING / INVALID DATA" : not vCoreOK ? "STATE AUDIT FAILED" : aligned and not snapshotOK ? "DIRECT AUDIT FAILED" : not vok ? "RESEARCH UNAVAILABLE" : not aligned ? "SNAPSHOT UNAVAILABLE" : ""
        string memoryHelp = "RSI = 50 + recent R + older O, with a common denominator. Violet = 50+O, not an older-only RSI. Rounded contributions can differ slightly from rounded RSI. Recent H=" + str.tostring(h) + "; recent mass share=" + f_num(vs) + "%."
        string cutHelp = "REMOVE ONE includes the intact RSI and zeroing any ONE signed increment at its original age 0..H-1. No candle is removed and time is not compressed. * means the threshold class can change; it is not a confidence interval or forecast. The entry study uses ONLY ages 1..H-1. All-zero candidates give a valid zero-width range. If any tested residual has no more than 0.001% of the current weighted mass, that test is unavailable, not classified as unchanged."
        string orderHelp = "Latest snapshot only: reorder the same H signed changes while holding older RSI state fixed. End source value is unchanged. Bounds are not forecasts or probabilities. Intermediate paths need not be economically feasible."
        string sampleHelp = "Chart-history dependent. First valid close UTC: " + (na(firstSampleTime) ? "n/a" : str.format_time(firstSampleTime, "yyyy-MM-dd", "UTC")) + "; last: " + (na(lastSampleTime) ? "n/a" : str.format_time(lastSampleTime, "yyyy-MM-dd", "UTC")) + ". NA/invalid-data interruptions and date boundaries are excluded. Ordinary session gaps are not reset points; unseen missing bars cannot be detected. No independence or causal claim."
        string supportHelp = "Hold age 0 and the older state fixed. TOTAL = weighted supporting mass needed to TOUCH the current extreme threshold, as percent of current G+L. PRIOR = that mass divided by supporting mass in ages 1..H-1. More than 100% means the tested prior cohort is insufficient. Zeroing supporting gains lowers an upper RSI; zeroing supporting losses raises a lower RSI. This is not a future price move, probability, or trade instruction."
        string termsHelp = "Latest snapshot only. Minimum number of whole prior supporting terms that can touch/cross the threshold: zero largest weighted terms first. Undefined residuals are excluded. Equality within 0.000001 RSI points counts as TOUCH, whereas entry classes use threshold membership. n/a can mean no attainable whole-term result or an undefined test. Age 0 and older state are never zeroed."
        string turnoverHelp = "Exact bar-to-bar change in recent attribution: new signed term MINUS signed transfer to the older cohort PLUS denominator effect. Older change = the same transfer + its denominator effect. Transfer cancels in total RSI change. It is cohort migration, not deletion from RSI memory. Units: RSI points."
        string priorText = not probes ? "OFF" : h < 2 ? "H >= 2" : not vtSupport ? "n/a" : na(vPriorBudget) ? "NO RESOLVABLE SUPPORT" : vPriorBudget > 100.0 ? ">100% | INSUFFICIENT" : f_num(vPriorBudget) + "% | " + (snapshotUsable and not na(minimumPriorTerms) ? str.tostring(minimumPriorTerms) + " TERMS" : "TERMS n/a")
        if page != "Memory attribution"
            f_row(panel, 0, hold or barstate.isconfirmed ? "RSI | CLOSED" : "RSI | LIVE", f_num(vr) + " | " + (na(vr) ? "NO DATA" : f_name(f_side(vr))), cRSI, "Native ta.rsi(), independent of research readiness. In closed mode the open bar adds no duplicate historical point. v6.1.2.")
        string referenceHelp = f_tr("Distance from displayed RSI to the selected reference. Prior test holds age 0 and older memory fixed, then zeros ONE signed increment aged 1..H-1. TEST CROSSES/TOUCHES describes a zeroed historical term, NOT a forthcoming crossing or reversal probability. The original entry study still uses only the upper/lower zone class. A residual of at most 0.001% of current weighted mass is considered numerically unresolved. ", "表示RSIから選択基準までの距離。最新項と過去側の記憶を固定し、1〜H-1本前の変動を一つゼロ化したテストです。交差・接触可能は計算上の感応度であり、反転確率ではありません。従来の進入研究は引き続き上下閾値の区分です。ゼロ化後の総量が現在の0.001％以下なら数値不安定として未定義扱いにします。 ") + f_tr("Prior range: ", "過去項レンジ: ") + f_pair(vPriorLow, vPriorHigh)
        string anchorStamp = na(anchorTime) ? "n/a" : str.format_time(anchorTime, "MM-dd HH:mm", syminfo.timezone)
        string mapHelp = f_tr("One Wilder update AFTER the last confirmed anchor. Anchor close time (exchange timezone): ", "最後の確定足から1回だけWilder式を更新する逆算。基準足の終値時刻（取引所時間帯）: ") + anchorStamp + ". " + f_tr("The anchor AND the nearest target stay fixed intrabar, even in LIVE mode. This is an established RSI inversion, not a new formula (G. Siligardos, 2003). On an open bar the next observation is that bar's eventual close; after a confirmed close it is the following bar. Approximate equality level, not a prediction, trigger price guarantee, order, or required future market move. Display rounds to tick size in Close / price mode; equality can lie BETWEEN ticks. Custom mode uses source units, never a market quote. Session gaps, market limits and source constraints are not modeled; a mathematically valid level need not be feasible. Map round-trip error=", "LIVE表示でも基準と最寄り対象は足の途中では変わりません。既存のRSI逆算の考え方（G. Siligardos、2003年）であり、新発明ではありません。未確定足ではその足の終値、確定直後は次の足の終値を対象とします。等式成立水準の近似表示であり、予測・発注・到達保証ではありません。価格モードは最小刻みに丸めるため、厳密な水準は刻みの間に存在する場合があります。カスタムモードは入力系列の値であり、市場価格ではありません。取引制限や入力値の制約は考慮せず、数学的な水準が実現可能とは限りません。往復計算誤差=") + f_check(mapError)
        string mapIssue = not closeMap ? f_tr("MAP OFF", "逆算オフ") : not mapEligible ? f_tr("ANCHOR UNAVAILABLE", "基準未準備") : not mapOK ? f_tr("MAP AUDIT FAILED", "逆算検査不合格") : ""
        string ledgerHelp = f_tr("NET RSI pt: current RSI = 50 + the three signed point values. Each cohort's net points are 50*(weighted gains-weighted losses)/CURRENT total weighted movement. MOVE %: 100*(weighted gains+weighted losses)/the SAME total. Shares sum to 100% before rounding; independently rounded numbers may not sum exactly to 100. A small net contribution can coexist with a large movement share because gains and losses cancel. These are not volume, probability, or shares of abs(RSI-50). LATEST's points are not the observed CHANGE shown in the header. Bars encode NET only; their shared symmetric full-side scale is ", "RSI純寄与 pt: 現在のRSI = 50 + 3行の符号付きポイント。各群の純寄与は50×(重み付き上昇量−下落量)÷現在の重み付き総変動量。総変動量 %は100×(重み付き上昇量＋下落量)÷同じ総量です。比率の合計は丸め前で100％。各表示を独立に丸めるため表示の和は100％と僅かに異なる場合があります。上昇と下落が相殺されると、純寄与が小さくても総量比率は大きくなります。出来高・確率・RSIの50からの乖離に対する比率ではありません。最新項の寄与はヘッダーの実際のCHANGEとは別です。棒は純寄与のみを示し、全行・左右共通の片側全長は ") + f_num(componentScale) + " RSI pt. " + f_tr("Age is measured back from the displayed observation: 0=latest, 1..H-1=prior, H+=older retained state. No whole candle or timestamp is removed. Split error=", "年齢は表示対象から数え、0=最新、1〜H-1=直近過去、H以上=減衰しつつ残る過去側です。ローソク足や時刻を削除する操作ではありません。分解誤差=") + f_check(vSplitError) + f_tr("; movement-share error (percentage points)=", "、総量分解誤差（パーセントポイント）=") + f_check(vMovementError)
        bool ledgerUsable = snapshotUsable and vPriorOK and array.size(termAges) == h - 1
        string witnessHelp = referenceHelp + " " + f_tr("Witness age is the largest weighted eligible prior gain when RSI is above the reference, or prior loss when below it. The displayed RSI is AFTER that one term is zeroed; all other terms and ages stay fixed. TOUCH % is the fraction of that term needed to touch the reference. Above 100% means this term is insufficient. It is not a probability or a proposed price move. A zeroing effect is nonlinear and must not be added to other zeroing effects. ", "代表項は、RSIが基準より上なら過去の上昇項、下なら下落項のうち最大の重み付き項です。表示RSIはその一項だけをゼロ化した後の値。他の項と年齢は固定です。接触％は基準に接触するまでに必要なその一項の減衰割合で、100％超なら不足です。確率や将来の価格変動ではありません。ゼロ化による変化は非線形で、他項のゼロ化効果と足し合わせられません。")
        if page == "Memory attribution"
            string ledgerState = hold or barstate.isconfirmed ? f_tr("CLOSED", "確定") : f_tr("LIVE", "未確定")
            string ledgerCaption = "RSI " + f_num(vr) + " | " + ledgerState + "\n" + f_tr("CHANGE ", "実際の変化 ") + f_sign(vRsiStep) + " pt"
            f_ledger_header(panel, ledgerCaption, ledgerHelp + " " + f_zone(vr) + " | " + f_direction(vRsiStep))
            f_component_row(panel, 1, f_tr("OLDER ", "過去側 ") + str.tostring(h) + f_tr("+ bars", "本前以上"), vo, vOlderMove, componentScale, ledgerHelp)
            f_component_row(panel, 2, (h > 1 ? "1-" + str.tostring(h - 1) + f_tr(" bars ago", "本前") : f_tr("PRIOR EMPTY", "直近過去は空")), vPriorPoints, vPriorMove, componentScale, ledgerHelp + " " + f_tr("When H=1 this cohort is empty: net points and movement share are exactly zero.", "H=1ではこの群は空で、純寄与も総量比率もゼロです。"))
            f_component_row(panel, 3, f_tr("LATEST (0)", "最新項 (0)"), vLatest, vLatestMove, componentScale, ledgerHelp)
            string zeroCaption = ledgerUsable and not na(witnessAge) ? f_tr("ZERO ", "ゼロ化: ") + str.tostring(witnessAge) + f_tr("-BAR-AGO TERM", "本前の変動項") : f_tr("ZERO ONE PRIOR TERM", "過去の変動項をゼロ化")
            string testValue = issue != "" ? (not research ? "RSI ONLY" : not chart.is_standard ? "STANDARD ONLY" : not vready ? "SETTLING" : "CHECK DIAGNOSTICS") : not probes ? "OFF" : h < 2 ? "H >= 2" : not ledgerUsable ? "n/a" : not na(witnessAge) ? f_tr("RSI AFTER ", "処理後RSI ") + f_num(witnessRSI) : f_test_text(vRefTest)
            f_row(panel, 4, zeroCaption, testValue, ledgerUsable and vRefTest >= 2 ? cTest : cText, witnessHelp + f_tr(" The result is the CURRENT RSI after zeroing, NOT the RSI recorded that many bars ago. Selected reference=", " この値は過去項をゼロ化した後の現在RSIであり、その本数前のRSIではありません。選択基準=") + f_num(vReference) + f_tr(". Fraction of term needed to touch=", "、接触に必要な一項の減衰割合=") + f_num(witnessTouchPct) + "%.")
        else if page == "Term ledger"
            string rankHelp = f_tr("Latest snapshot, ranked by absolute change in RSI after independently zeroing each prior term. Latest age 0 is excluded. Printed changes are AFTER minus actual RSI, not additive contributions. The top three are selected for inspection, not as signals. Other ages still participate in all counts and bounds. ", "最新スナップショットで、過去項を各々独立にゼロ化したRSIの変化幅順。最新項0は除外。表示変化は処理後RSI−実RSIで、加算寄与とは異なります。上位3項は閲覧対象で、シグナルではありません。他の項も件数・範囲に含みます。") + referenceHelp
            f_row(panel, 0, f_tr("ZERO ONE PRIOR", "過去1項をゼロ化"), f_tr("ACTUAL ", "実RSI ") + f_num(vr), cRSI, rankHelp)
            for rank = 0 to 2
                bool available = ledgerUsable and rank < array.size(termRankOrder)
                int ix = available ? array.get(termRankOrder, rank) : 0
                string caption = available ? f_tr("ZERO ", "ゼロ化: ") + str.tostring(array.get(termAges, ix)) + f_tr("-BAR-AGO TERM", "本前の変動項") : f_tr("TERM ", "項 ") + str.tostring(rank + 1)
                string value = available ? f_tr("RSI AFTER ", "処理後RSI ") + f_num(array.get(termOutcomes, ix)) + " | " + f_sign(array.get(termImpacts, ix)) + " pt" : "n/a"
                string detail = available ? f_tr("This term's additive contribution before zeroing = ", "ゼロ化前のこの項の加算寄与 = ") + f_sign(array.get(termContributions, ix)) + " RSI pt. " : ""
                f_row(panel, rank + 1, caption, value, cText, rankHelp + detail)
            string ledgerCountText = ledgerUsable and vRefTest != 0 ? str.tostring(referenceCrossCount) + " / " + str.tostring(referenceTouchCount) + f_tr(" of ", " / 母数 ") + str.tostring(array.size(termAges)) : "n/a"
            f_row(panel, 4, f_tr("CROSS / TOUCH", "交差 / 接触"), ledgerCountText, cTest, f_tr("Mutually exclusive strict-cross and touch-only COUNTS, not percentages or probabilities. At the reference there is no defined original side, so counts are not summarized. All eligible ages, including zero changes, are in the denominator. ", "厳密交差と接触のみの排他的な件数で、割合や確率ではありません。実RSIが基準上なら元の側が定まらず集計を表示しません。ゼロ変動も含む対象年齢全てが母数です。") + rankHelp)
        else if page == "Single-term stress"
            f_row(panel, 0, f_tr("REFERENCE ", "基準 ") + f_num(vReference), f_num(vr) + " | " + f_test_text(vRefTest), cRSI, witnessHelp)
            f_row(panel, 1, f_tr("ZEROED TERM", "ゼロ化する変動項"), ledgerUsable and not na(witnessAge) ? str.tostring(witnessAge) + f_tr(" bars ago", "本前") : "n/a", cText, witnessHelp)
            f_row(panel, 2, f_tr("RSI AFTER ZERO", "ゼロ化後RSI"), ledgerUsable ? f_num(witnessRSI) : "n/a", cTest, witnessHelp)
            f_row(panel, 3, f_tr("TERM TO TOUCH", "接触に必要な減衰"), ledgerUsable and not na(witnessTouchPct) ? (witnessTouchPct > 100.0 ? f_tr(">100% | INSUFFICIENT", ">100% | 不足") : f_num(witnessTouchPct) + "%") : "n/a", cText, witnessHelp)
            f_row(panel, 4, f_tr("DIRECT CHECK", "直接検査"), ledgerUsable ? f_check(ledgerAuditError) : "n/a", ledgerUsable ? cUp : cMuted, f_tr("Sum of individual ADDITIVE prior contributions versus the recurrence partition. The touch identity is checked only when the partial removal is attainable; n/a is not a pass. Touch error=", "個別過去項の加算寄与の和と再帰分解を照合。接触式は部分減衰が実現可能な場合のみ検査し、n/aは合格ではありません。接触誤差=") + f_check(witnessAuditError))
        else if page == "Trader view"
            string vMemoryText = not vok ? "n/a" : vrel == 2 ? f_tr("OPPOSED", "対立") + " | R" + f_polarity(vp) + " O" + f_polarity(vo) : vrel == 1 ? f_tr("BOTH POSITIVE", "両方プラス") : vrel == -1 ? f_tr("BOTH NEGATIVE", "両方マイナス") : vrel == 3 ? f_tr("RECENT ONLY", "直近のみ基準超え") + " " + f_polarity(vp) : vrel == 4 ? f_tr("OLDER ONLY", "過去のみ基準超え") + " " + f_polarity(vo) : f_tr("SMALL CONTRIBUTIONS", "寄与は小さい")
            f_row(panel, 0, hold or barstate.isconfirmed ? "RSI | CLOSED" : "RSI | LIVE", f_num(vr) + " | " + f_sign(vRsiStep) + " pt", cRSI, f_tr("Native RSI and its change from the preceding observation. CLOSED holds the last confirmed state; LIVE can change intrabar. Not the contribution of a single term.", "標準RSIと前の観測値からの変化量。CLOSEDは確定値、LIVEは足の途中で変化します。単一項の寄与量ではありません。"))
            f_row(panel, 1, f_tr("STATE", "状態"), f_zone(vr) + " | " + f_direction(vRsiStep), cText, f_tr("RSI level and actual one-observation direction, not a trend prediction. Upper/lower are descriptive regions, not automatic sell/buy instructions.", "RSIの現在位置と直近1観測の方向。将来トレンドの予測ではなく、上下領域も売買指示ではありません。"))
            f_row(panel, 2, f_tr("MEMORY", "記憶の関係"), issue != "" ? issue : vMemoryText, vrel == 2 ? cTest : vrel == 1 ? cUp : vrel == -1 ? cDown : cOld, memoryHelp + " " + f_tr("R=recent, O=older. Plus/minus signs describe contributions relative to 50, NOT their bar-to-bar direction. Material means the configured point cutoff, not statistical significance. Only means only that cohort exceeds the cutoff; the other contribution can be nonzero.", "R=直近、O=過去。正負の記号は50に対する寄与であり、前の足からの変化方向ではありません。大小は設定ポイント基準で、統計的な有意性ではありません。「のみ」は基準超えが片側のみという意味で、他方がゼロとは限りません。"))
            f_row(panel, 3, f_tr("ZERO 1 PRIOR @", "過去1項 @") + f_num(vReference), f_num(vRefDistance) + " pt | " + (not probes ? f_tr("TEST OFF", "テストオフ") : h < 2 ? "H >= 2" : f_test_text(vRefTest)), vRefTest >= 2 ? cTest : cText, referenceHelp)
            f_row(panel, 4, f_tr(priceMode ? "NEXT CLOSE @" : "NEXT SOURCE @", priceMode ? "次の終値 @" : "次の入力値 @") + f_num(mapReference), not na(nextReference) ? "≈ " + f_unit_value(nextReference) : mapIssue, not na(nextReference) ? cRSI : cMuted, mapHelp)
        else if page == "Next-close map"
            f_row(panel, 0, f_tr("CLOSED ANCHOR", "確定基準"), anchorStamp, cRSI, mapHelp)
            f_row(panel, 1, f_tr("UPPER ", "上側 ") + f_num(upper), not na(nextUpper) ? "≈ " + f_unit_value(nextUpper) : mapIssue, cDown, mapHelp)
            f_row(panel, 2, f_tr("BALANCE 50", "均衡 50"), not na(nextMiddle) ? "≈ " + f_unit_value(nextMiddle) : mapIssue, cRSI, mapHelp)
            f_row(panel, 3, f_tr("LOWER ", "下側 ") + f_num(lower), not na(nextLower) ? "≈ " + f_unit_value(nextLower) : mapIssue, cUp, mapHelp)
            f_row(panel, 4, f_tr("UNCHANGED NEXT", "次回変化なし"), mapOK ? f_unit_value(anchorSource) + " → RSI " + f_num(anchorRSI) : "n/a", cMuted, f_tr("A zero next change decays gains and losses by the same factor and leaves RSI unchanged while total mass remains representable. No automatic reversion to 50 is implied.", "次回の変化がゼロなら、上昇と下落の平均が同率で減衰するためRSIは同じです。50への自然回帰を意味しません。") + " " + mapHelp)
        else if page == "Reference stress"
            f_row(panel, 0, f_tr("REFERENCE ", "選択基準 ") + f_num(vReference), f_num(vr) + " | " + f_num(vRefDistance) + " pt", cRSI, referenceHelp)
            f_row(panel, 1, f_tr("ZERO ONE PRIOR", "過去項を一つゼロ化"), vPriorOK ? f_pair(vPriorLow, vPriorHigh) : not probes ? "OFF" : h < 2 ? "H >= 2" : "n/a", cText, referenceHelp)
            f_row(panel, 2, f_tr("REFERENCE TEST", "基準への感応度"), f_test_text(vRefTest), vRefTest >= 2 ? cTest : cText, referenceHelp)
            f_row(panel, 3, f_tr("ZERO ONE / ALL", "最新項も候補に含む"), vdOK ? f_pair(vdLow, vdHigh) : "n/a", cText, cutHelp)
            f_row(panel, 4, f_tr("OLDER / RECENT", "過去 / 直近"), vok ? "O " + f_sign(vo) + " | R " + f_sign(vp) : "n/a", vrel == 2 ? cTest : cText, memoryHelp)
        else if page == "Overview"
            f_row(panel, 1, "MEMORY", issue != "" ? issue : "R " + f_sign(vp) + " | O " + f_sign(vo), vrel == 2 ? cTest : cText, memoryHelp)
            f_row(panel, 2, "REMOVE ONE", not probes ? "OFF" : vdOK ? f_pair(vdLow, vdHigh) + (vf ? " *" : "") : "n/a", vf ? cTest : cText, cutHelp)
            f_row(panel, 3, f_side(vr) == 0 ? "RECENT CHANGE" : "PRIOR TO TOUCH", issue != "" ? "n/a" : f_side(vr) == 0 ? "R " + f_sign(vtRecentStep) + " | NEW " + f_sign(vtNew) : priorText, cText, f_side(vr) == 0 ? turnoverHelp : supportHelp + " " + termsHelp)
            f_row(panel, 4, "ORDER RANGE", not orderTest ? "OFF" : snapshotUsable and orderAudit ? f_pair(orderLow, orderHigh) : "n/a", cOrder, orderHelp)
        else if page == "Memory turnover"
            f_row(panel, 0, "RECENT CHANGE", vtOK ? f_sign(vtRecentStep) + " pt" : issue != "" ? issue : "n/a", cRSI, turnoverHelp)
            f_row(panel, 1, "NEW TERM", f_sign(vtNew), cRSI, turnoverHelp)
            f_row(panel, 2, "COHORT TRANSFER", f_sign(-vtBoundary), cOld, "Shown with its effect on RECENT attribution, so this is minus B. The older cohort receives plus B. " + turnoverHelp)
            f_row(panel, 3, "DENOMINATOR", f_sign(vtRecentDilution), cTest, "New absolute movement changes the shared denominator. This is its effect on the previous recent contribution. " + turnoverHelp)
            f_row(panel, 4, "OLDER CHANGE", f_sign(vtOlderStep), cOld, "Older change plus recent change reconstructs the actual RSI change. Older denominator effect=" + f_sign(vtOlderDilution) + ". " + turnoverHelp)
        else if page == "Threshold support"
            f_row(panel, 1, "TOTAL TO TOUCH", vtSupport ? f_num(vTouchMass) + "%" : "n/a", cTest, supportHelp)
            f_row(panel, 2, "PRIOR TO TOUCH", priorText, cText, supportHelp)
            f_row(panel, 3, "MIN WHOLE TERMS", snapshotUsable and vtSupport ? (na(minimumPriorTerms) ? "n/a" : str.tostring(minimumPriorTerms)) + " / " + str.tostring(supportingPriorTerms) : "n/a", cText, termsHelp)
            f_row(panel, 4, "LARGEST PRIOR AGE", snapshotUsable and vtSupport and not na(dominantPriorAge) ? str.tostring(dominantPriorAge) + "b" : "n/a", cOld, "Age of the largest weighted prior term supporting the CURRENT extreme side; newest permissible age is 1. It is not a turning-point prediction. " + supportHelp)
        else if page == "Order and concentration"
            f_row(panel, 1, "ORDER RANGE", snapshotUsable and orderAudit ? f_pair(orderLow, orderHigh) : "n/a", cOrder, orderHelp)
            f_row(panel, 2, "ORDER EFFECT", snapshotUsable and orderAudit ? f_sign(vr - neutralOrder) + " | POS " + f_num(orderPosition) : "n/a", cText, "Effect = RSI minus equal-recency-weight baseline. It is NOT the mean RSI of permutations. POS is a 0-100 location inside the bounds, NOT a percentile or probability; n/a when the range is zero.")
            f_row(panel, 3, "CONCENTRATION", snapshotUsable and orderTest ? "EQ " + f_num(effectiveTerms) + " | TOP " + f_num(topShare) + "%" : "n/a", cText, "TOP is the largest weighted recent term divided by recent mass, not total mass. EQ is not statistical confidence. Aggregate weighted recent mean age=" + f_num(meanAge) + " bars; latest age=0.")
            f_row(panel, 4, "GAIN / LOSS AGE", snapshotUsable and orderTest ? "G " + f_num(gainMeanAge) + "b | L " + f_num(lossMeanAge) + "b" : "n/a", cText, "Separate weighted mean ages within H. A missing side is n/a; this is not the age of the entire RSI memory.")
        else if page == "Episodes"
            bool usable = research and episodes and chart.is_standard and dateOK and confirmedSample
            string ep = epSide == 0 ? "IN RANGE" : f_name(epSide) + " " + str.tostring(epAge) + "b" + (partial ? "+" : "") + " | A " + f_num(epArea)
            f_row(panel, 1, "CONFIRMED", usable ? ep : "OFF / OUTSIDE SAMPLE", partial ? cTest : cText, "A = accumulated threshold excess in RSI-point bars. + means a left-censored episode excluded from completions. Peak excess=" + f_num(epPeak) + ". " + sampleHelp)
            f_row(panel, 2, "MEDIAN BARS", usable ? "U " + f_num(f_med(upAges)) + " | L " + f_num(f_med(downAges)) : "n/a", cText, "Completed episodes only; current open episode excluded. Not expected remaining duration. Minimum above pool capacity yields n/a.")
            float ageRank = usable and epSide != 0 and not partial ? f_rank(epSide == 1 ? upAges : downAges, float(epAge)) : na
            float areaRank = usable and epSide != 0 and not partial ? f_rank(epSide == 1 ? upAreas : downAreas, epArea) : na
            f_row(panel, 3, "ACTIVE RANK", "AGE " + f_num(ageRank) + " | AREA " + f_num(areaRank), cText, "0-100 midranks versus retained same-side completed episodes. Ties get half weight. Not a survival or reversal probability.")
            f_row(panel, 4, "COMPLETIONS", "U " + str.tostring(array.size(upAges)) + " | L " + str.tostring(array.size(downAges)), minSample > capacity ? cTest : cText, sampleHelp)
        else if page == "Entry study"
            int si = studySide == "Upper" ? 0 : 1
            int ix = si * 2
            int nr = array.get(counts, ix)
            int ns = array.get(counts, ix + 1)
            bool on = studyOn and chart.is_standard and dateOK
            string state = h < 2 ? "H >= 2 REQUIRED" : not on ? "OFF / INVALID SAMPLE" : str.upper(studySide) + " | +" + str.tostring(horizon) + "b"
            string studyHelp = "At the entry close, delete ONE prior term at ages 1..H-1; NEVER age 0. Freeze the label. E = same extreme side at +K; R = uninterrupted same-side closes through +K. Historical RSI persistence, not P/L or a win rate. Entry margin, prior path and settings can confound group differences."
            f_row(panel, 0, "PRIOR-TERM STUDY", state, cRSI, studyHelp)
            f_row(panel, 1, "PRIOR UNCHANGED", on ? f_stats(nr, array.get(ends, ix), array.get(runs, ix)) : "n/a", cText, "No tested PRIOR-term deletion changes the entry class. It does not mean price resilience. No percentages below the minimum. " + studyHelp)
            f_row(panel, 2, "PRIOR CHANGED", on ? f_stats(ns, array.get(ends, ix + 1), array.get(runs, ix + 1)) : "n/a", cText, "Some tested PRIOR-term deletion changes the entry class. It does not predict a reversal. Either group may naturally have few/no observations. " + studyHelp)
            f_row(panel, 3, "POOLED BASELINE", on ? f_stats(nr + ns, array.get(ends, ix) + array.get(ends, ix + 1), array.get(runs, ix) + array.get(runs, ix + 1)) : "n/a", cText, "Same selected, classified, matured observations pooled across both groups of this side. Not all market entries and not a control group. " + sampleHelp)
            string exclusions = "P " + str.tostring(array.get(pending, si)) + " D " + str.tostring(array.get(dropped, si)) + " X " + str.tostring(array.get(unclassified, si)) + " O " + str.tostring(array.get(overlaps, si))
            f_row(panel, 4, "SAMPLE STATUS", on ? exclusions : "n/a", cMuted, "Selected side: P=pending horizon; D=invalid/missing/date-truncated window; X=unclassifiable prior test or numerical threshold boundary; O=overlap skipped. None is counted as an observed failure. Non-overlap is global across both sides. It does not guarantee independence. " + sampleHelp)
        else if page == "Walk-forward check"
            int si = studySide == "Upper" ? 0 : 1
            int np = array.get(wfPairs, si)
            bool on = studyOn and walkForward and chart.is_standard and dateOK
            bool enough = on and np >= minSample
            float lb = enough ? array.get(wfBaseLoss, si) / np : na
            float lc = enough ? array.get(wfClassLoss, si) / np : na
            float improvement = enough ? lb - lc : na
            string wfHelp = "At each selected entry, freeze estimates from strictly earlier matured outcomes. RSI-only uses the same side and fixed entry overshoot band (0-2, 2-5, 5+ points); extra-class also uses the frozen PRIOR label. Training cells each require the configured minimum. Estimates=(successes+0.5)/(n+1). Both models are scored on the SAME later valid +K outcomes. Lower squared loss is better. Positive improvement means extra-class loss was lower in this selected historical sample, not trading alpha or statistical significance. Coarse bands do not remove all confounding. Non-overlap does not establish independence. " + sampleHelp
            f_row(panel, 0, "WALK-FORWARD", on ? str.upper(studySide) + " | +" + str.tostring(horizon) + "b" : "OFF / INVALID SAMPLE", cRSI, wfHelp)
            f_row(panel, 1, "PAIRED OUTCOMES", on ? "n " + str.tostring(np) : "n/a", cText, "Entries without enough prior training=" + str.tostring(array.get(wfUntrained, si)) + ". This counter includes entries whose outcomes may later be invalid or still pending. No loss summary below the minimum paired observations. " + wfHelp)
            f_row(panel, 2, "RSI-ONLY LOSS", f_loss(lb), cText, wfHelp)
            f_row(panel, 3, "EXTRA-CLASS LOSS", f_loss(lc), cText, wfHelp)
            f_row(panel, 4, "LOSS IMPROVEMENT", enough ? f_loss(improvement) : "NO SUMMARY YET", cText, "Baseline loss minus extra-class loss. Negative values are retained; they are not hidden. This does not measure returns, trading success, causality, or future performance. " + wfHelp)
        else if page == "Data Window guide"
            string dwHelp = f_tr("Guide to Research 1..8 in TradingView's Data Window. Values follow the crosshair bar; this table only names the fields. Choose Data Window group in settings. Groups do not change calculations, samples, chart marks or alerts. The 0-3 reference test means at-level/no-touch/touch/cross. Frozen entry groups are 0 upper unchanged, 1 upper changed, 2 lower unchanged, 3 lower changed. Estimates are historical RSI-state frequencies, not profit probabilities. The next-source map remains anchored to the confirmed observation and is not a price forecast. All exports use fixed generic names, so external-script inputs and CSV workflows must select the correct group.", "TradingViewデータウィンドウのResearch 1〜8の対応表です。数値はクロスヘアの足に対応し、この表は項目名だけを示します。設定のData Window groupで切り替えます。計算・標本・マーカー・アラート条件は変えません。基準テスト0〜3は基準上・接触なし・接触・交差。固定進入分類0〜3は上側不変・上側変化・下側不変・下側変化です。推定値は過去のRSI状態頻度で、利益確率ではありません。次回値の逆算は確定基準で、価格予測ではありません。外部スクリプトやCSVでは選択グループと枠番号を合わせてください。")
            f_row(panel, 0, "DATA WINDOW", dataWindowGroup, cRSI, dwHelp)
            for guideRow = 1 to 4
                int leftSlot = 2 * guideRow - 1
                int rightSlot = 2 * guideRow
                f_row(panel, guideRow, str.tostring(leftSlot) + ". " + f_dw_caption(leftSlot), str.tostring(rightSlot) + ". " + f_dw_caption(rightSlot), cText, dwHelp)
        else if page == "Diagnostics"
            float combinedDirect = aligned and not na(directError) ? math.max(directError, math.max(nz(ledgerAuditError, 0.0), math.max(nz(witnessAuditError, 0.0), math.max(nz(removalError, 0.0), nz(thresholdAuditError, 0.0))))) : na
            f_row(panel, 0, "BUILD v6.1.2", issue == "" ? "READY" : issue, issue == "" ? cUp : cTest, "READY concerns the currently displayed research. All-bar fast checks and latest-only direct checks are separate. n/a is not a pass. A failed direct snapshot quarantines only latest presentation. Confirmed research events use independent current/prior rolling-window checks on every candidate, regardless of bar position. Fixed-capacity queues replace per-candidate H-term rescans. v6.1.2 uses eight shared Data Window exports; source-level conservative plot-count bound is 43, not a compiler measurement. Historical sample selection never depends on snapshot checks. Historical selection uses the same all-bar identities on every observation. This does not certify all historical direct tests. Native RSI is never suppressed.")
            f_row(panel, 1, "FAST HISTORY", "N " + str.tostring(fastChecked) + " | FAIL " + str.tostring(fastFailures), fastFailures == 0 and fastChecked > 0 ? cUp : cTest, "Confirmed eligible bars: native RSI identity, common-denominator reconstruction, and turnover identity where a prior valid state exists. Maximum observed error=" + str.tostring(fastMaxError, "0.000000000") + ". This is not a full H-term historical scan. Movement-share checks=" + str.tostring(movementChecks) + "; failures=" + str.tostring(movementFailures) + "; displayed error=" + f_check(vMovementError) + ". Candidate-event closes=" + str.tostring(eventChecks) + "; rejected=" + str.tostring(eventFailures) + "; maximum current/prior rolling-window error=" + f_check(eventMaxError) + ". Candidate checks run under the same rules for all confirmed bars; no last-only event gate.")
            f_row(panel, 2, "RSI / TURNOVER", (not na(vIdentity) and vIdentity <= TOL ? "RSI PASS" : "RSI n/a/FAIL") + " | " + (not na(vTurnoverError) and vTurnoverError <= TOL ? "FLOW PASS" : "FLOW n/a/FAIL"), vok ? cUp : cTest, "Current native RSI identity / turnover reconstruction errors, in RSI points. Tolerance=0.000001. Identity=" + f_check(vIdentity) + "; turnover=" + f_check(vTurnoverError) + ". First eligible state has no prior turnover test. Close-map confirmed checks=" + str.tostring(mapChecks) + "; failures=" + str.tostring(mapFailures) + "; max error=" + f_check(mapMaxError) + "; current=" + f_check(mapError) + ". Map errors quarantine only the map.")
            f_row(panel, 3, "DIRECT SNAPSHOT", f_check(combinedDirect), aligned and not na(combinedDirect) and combinedDirect <= TOL ? cUp : cTest, "Maximum of available latest direct sum, removal and threshold-touch checks. Direct sum=" + f_check(directError) + "; removal=" + (probes ? f_check(removalError) : "OFF") + "; threshold=" + f_check(thresholdAuditError) + ". Availability disagreement fails the removal audit. An unavailable subtest is not certified.")
            f_row(panel, 4, "ORDER AUDIT", not orderTest ? "OFF" : not aligned or not orderAttempted ? "n/a" : orderAudit ? "ACTUAL INSIDE BOUNDS" : "FAIL: OUTSIDE BOUNDS", aligned and orderAttempted and orderAudit ? cUp : cTest, "Latest sorted extrema must contain actual RSI. A zero-width range is valid but has no defined position. " + sampleHelp)
        else
            f_row(panel, 0, "LEGEND", "DESCRIPTIVE / NO SIGNALS", cText, "Colors and optional marks describe indicator arithmetic, not trading recommendations.")
            f_row(panel, 1, "NET pt / MOVE %", "50 + NET / GROSS SHARE", cText, ledgerHelp + " " + memoryHelp)
            f_row(panel, 2, "GOLD BRACKET", "PRIOR ONLY / EXCLUDES 0", cTest, referenceHelp + " Historical shading in Full research instead includes age 0. " + cutHelp)
            f_row(panel, 3, "CIRCLE / SQUARE", "CLASS CHANGE / WIDTH", cOrder, "Optional confirmed events. Research events use current/prior independent rolling checks on every candidate close; latest-only diagnostics do not gate markers. Threshold exits mode: circle on the exited boundary. Classification mode: circle when full deletion sensitivity appears. Square: full-test width crosses its setting. Off by default; no buy/sell arrows.")
            f_row(panel, 4, "OPTIONAL STRIP", "COHORT RELATIONSHIP", cMuted, "Off by default. At 4: mint=both contributions positive; orange=both negative; gold=material opposition; violet=one material cohort; gray=small/mixed. Focus shows the memory ribbon only during material opposition; Full research restores continuous layers. Neither changes statistics. Not confidence or a probability.")

// Native threshold alerts do not depend on the research date/sample filters.
bool validPair = not na(rsi) and not na(rsi[1]) and not na(delta)
alertcondition(barstate.isconfirmed and validPair and side == 1 and side[1] != 1, "RSI entered upper threshold", "Confirmed RSI entered the upper threshold. {{ticker}} {{interval}}. Descriptive observation.")
alertcondition(barstate.isconfirmed and validPair and side == -1 and side[1] != -1, "RSI entered lower threshold", "Confirmed RSI entered the lower threshold. {{ticker}} {{interval}}. Descriptive observation.")
alertcondition(barstate.isconfirmed and validPair and side != 1 and side[1] == 1, "RSI left upper threshold", "Confirmed RSI left the upper threshold. {{ticker}} {{interval}}. Descriptive observation.")
alertcondition(barstate.isconfirmed and validPair and side != -1 and side[1] == -1, "RSI left lower threshold", "Confirmed RSI left the lower threshold. {{ticker}} {{interval}}. Descriptive observation.")
alertcondition(newOpposed, "Recent and older contributions opposed", "Confirmed recent and older RSI contributions are materially opposed. {{ticker}} {{interval}}. Not a forecast.")
alertcondition(newSensitive, "All-term removal classification changed", "Confirmed RSI classification is newly sensitive to deleting one recent term, including age 0. {{ticker}} {{interval}}. Not the prior-only entry-study label.")
alertcondition(newWide, "All-term removal range widened", "Confirmed one-term removal width crossed its configured threshold. {{ticker}} {{interval}}. Sensitivity only, not a trade instruction.")

// A change in cohort attribution can oppose the arriving signed movement.
// This alert describes that arithmetic, not a price divergence prediction.
alertcondition(newTurnoverOpposed, "Recent attribution change opposed the new term", "Confirmed recent RSI attribution changed against the sign of its new term. Cohort transfer and denominator effects explain the difference. {{ticker}} {{interval}}. Not a trading signal.")

// Context alerts reuse the exact confirmed conditions evaluated above.
// The two centerline series execute unconditionally on every bar.
alertcondition(barstate.isconfirmed and nativePair and centerUp, "RSI crossed above 50", "Confirmed RSI crossed above 50. {{ticker}} {{interval}}. Level observation, not a trade instruction.")
alertcondition(barstate.isconfirmed and nativePair and centerDown, "RSI crossed below 50", "Confirmed RSI crossed below 50. {{ticker}} {{interval}}. Level observation, not a trade instruction.")
alertcondition(priorCrossAppeared, "Prior-only reference crossing became possible", "Confirmed: zeroing one prior RSI term can now cross the same selected reference; the age-0 term is fixed. {{ticker}} {{interval}}. Arithmetic sensitivity, not a reversal forecast.")
````
