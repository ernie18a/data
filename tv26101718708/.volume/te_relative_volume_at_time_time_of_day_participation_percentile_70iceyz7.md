# TE Relative Volume at Time Time of Day Participation Percentile

- url: https://www.tradingview.com/script/70iCeyZ7-TE-Relative-Volume-at-Time-Time-of-Day-Participation-Percentile/
- type: indicator
- pine_id: PUB;164ceb1b99584217861ce737cf3d257b
- version: 1.0

## Description

TE Relative Volume at Time measures participation relative to what is normal for the same time of day.
https://www.tradingview.com/x/FOiO96Gr/

Raw volume alone has little context. A volume print that is unusually large at midday may be routine near the open. This indicator keeps the exchange-reported volume unchanged, then ranks it against historical observations from the same intraday time slot.
https://www.tradingview.com/x/fTuhd6Iq/
TIME-OF-DAY RELATIVE VOLUME

The trading day is divided into slots one chart timeframe wide:

k = floor(minutes since exchange midnight / timeframe minutes)

For the current slot, the indicator retains the previous M observations and calculates:

p_tod = (count(V_i < V) + 0.5 × count(V_i = V)) / n
https://www.tradingview.com/x/MWyKvAuX/
This estimates where the current bar's volume sits relative to previous bars occurring at the same time of day.

Default M = 20 sessions.

The mid-rank convention gives half-weight to ties so repeated low-volume values are not incorrectly classified as extreme observations.
https://www.tradingview.com/x/QUGrUvvo/
UNCONDITIONAL VOLUME PERCENTILE

The same calculation is also performed over the last N closed bars without time-of-day conditioning:

p_plain = P(V ≤ v)

Default N = 480 bars.

Both readings are displayed so the user can see when a conventional trailing volume percentile is being influenced by the normal intraday volume curve.

RELATIVE VOLUME MULTIPLE

The familiar RVOL multiple is also included:

RVOL = current volume / reference volume for this slot

The default reference is the median of the previous M observations at the same time of day.

Median is used by default because volume distributions can be heavily affected by unusually large observations. Mean is also available for users who prefer the conventional average-based calculation.
https://www.tradingview.com/x/TM4eScFk/
SESSION PACE

The indicator separately measures how active the entire session has been so far.

C_t = sum of closed-bar volume since the start of the trading day

The current cumulative volume is ranked against cumulative volume at the same point in previous sessions.

This keeps two questions separate:

How unusual is this individual bar?

How unusual is the session's total participation so far?

PARTICIPATION STATES

The governing percentile is classified into five states:

COMPRESSED: 0-20
SUBDUED: 20-40
BASELINE: 40-60
ELEVATED: 60-80
EXPANDED: 80-100

These states describe participation relative to history. They are not bullish or bearish.

STATE STABILITY

Two mechanisms reduce unnecessary state changes.

Hysteresis requires the percentile to move beyond a band boundary by a configurable margin before changing state.

Dwell requires a candidate state to persist for a configurable number of confirmed bars before publication.

Defaults:

Hysteresis: 5 percentile points
Dwell: 2 confirmed bars

The session-pace measurement uses hysteresis but not dwell because cumulative volume does not experience the same short-lived reversals as individual bars.

NO VOLUME DATA

Some symbols do not provide meaningful volume.

If the script determines that the symbol is not reporting usable volume, it displays NO VOLUME DATA rather than generating a percentile from missing or substituted values.

Missing volume is not inserted into the historical sample.

READOUT

The panel can display:

Current bar volume
Relative-volume multiple
Time-of-day percentile
Unconditional percentile
Session-pace percentile
Cumulative session volume
Reference volume for the current time slot
Published participation state

The volume columns can also be colored by the current participation state.

WHAT IT DOES NOT DO

It does not predict price direction.

It does not identify buyers or sellers.

It does not confirm breakouts.

It does not provide entries, stops or targets.

EXPANDED means participation was unusually high for that time of day. It does not mean price is trending or that the next bar will also have high volume.

All published state changes and alerts are based on confirmed bars. The script uses zero request.security() calls.

TE Relative Volume at Time is designed to answer a more precise question than conventional RVOL: not simply "is volume high?" but "is volume unusual for this market at this specific point in its trading day?"

## Source Code

````pine
//@version=6
// TE RELATIVE VOLUME AT TIME — TIME-OF-DAY-CONDITIONED PARTICIPATION PERCENTILE  (catalog TE-003)
// This source code is subject to the terms of the TRADERS EDGE license — all rights reserved. Distributed on
// TradingView as a protected / Public; not for resale, or reverse engineering.
// THE QUESTION: is participation unusual for this exact point in the session?
//
// THE PROBLEM WITH THE CLASSIC: relative volume is shipped everywhere as one ratio — today's
// cumulative volume divided by the AVERAGE cumulative volume at the same point in recent sessions,
// reported as "1.8x". Three things are wrong with it, and each one is a design decision here:
//
//   1. A ratio to a mean has no distribution behind it. Volume is heavy-tailed to the right: one
//      enormous afternoon moves the mean, and nothing tells the reader that it did. "1.8x" cannot
//      say whether 1.8x is the busiest this slot has been in a month or an ordinary Tuesday.
//   2. The BAR-level question is not answered at all. The classic is a session-cumulative measure,
//      so a trader watching a single bar print heavy has no tool that says whether THIS BAR is heavy
//      FOR THIS TIME OF DAY — and 09:30 and 12:15 are simply not comparable quantities.
//   3. A plain trailing volume window is dominated by whichever hours it happens to span. That is
//      the measured part, and it is large.
//
// WHAT THIS ADDS, AND ONLY THIS: the volume series is drawn unchanged. Behind it, the pane is shaded
// by where the current bar's volume sits in the distribution of volume AT THIS SAME TIME OF DAY. The
// panel shows BOTH percentile estimates side by side so you can watch them disagree — which is the
// entire product — plus the session-cumulative ranking and the familiar multiple.
//
// WHY TIME OF DAY AND NOT JUST A TRAILING PERCENTILE — measured, not asserted:
//   Sixteen years of 1m tape (2010-06-07 to 2026-06-19) aggregated to 15 minutes: 4,131 sessions and
//   about 373,000 rated bars per instrument, on two index futures. A plain trailing percentile and a
//   time-of-day-matched one put the bar in a DIFFERENT one of the five bands on 72.56% and 71.76%
//   of bars.
//
//   That number means nothing by itself, so it was controlled. A time-of-day percentile ranks
//   against ~20 samples and a plain one against ~480, and two estimators at different sample sizes
//   disagree from noise alone. The same estimator at the same sample size, with the time-of-day
//   structure destroyed, disagrees on 29.88% and 29.83% — so 42.68 and 41.93 percentage points are
//   attributable to time of day itself, and the two instruments replicate each other to within
//   0.75 of a point.
//
//   It is LARGER than the same measurement on range rather than participation (37.4 and 38.3 points
//   on the companion ATR product). Time of day conditions VOLUME more strongly than it conditions
//   RANGE. That was not the assumption going in, and it is the honest headline.
//
//   The internal check it passes, which would have been the tell had it failed: the disagreement
//   concentrates in the regular session — worst around 09:45-11:30 and 15:30-16:00, near 80% — and
//   is weakest overnight, near 65%. That is the U-shaped intraday volume curve appearing exactly
//   where it must. Flat, or overnight-heavy, would have meant an artifact.
//
//   Reproduce it: daemons/learn/tod-relative-volume-measure.mjs, raw output in reports/te-rvol/,
//   written up in docs/findings/2026-09-23-te-003-relative-volume-at-time-measurement.md. It is
//   DESCRIPTIVE. It says how the tape is shaped. It says nothing about what price will do next, and
//   neither does this indicator.
//
//   THREE LIMITATIONS, STATED HERE RATHER THAN DISCOVERED LATER:
//     • Contract-roll dates are NOT excluded from that measurement. Every baseline is a TRAILING
//       window, never the whole history, so decade-scale volume growth cannot leak into a percentile
//       — and a roll day inflates BOTH estimators, so it is not a plausible source of a 42-point gap.
//     • The two instruments DO NOT AGREE on the single loudest slot of the day: one peaks at the
//       cash close, the other at the open. The headline and the SHAPE replicate; the peak does not.
//     • It was measured on two index futures. This indicator works on any instrument that reports
//       volume, because it reads the symbol's own exchange timezone — but the SIZE of the effect
//       above is a two-instrument number and has not been measured on equities, currencies or
//       crypto. "Correct" and "verified" are different words. You can see which is true on your own
//       symbol, because the panel shows both percentiles side by side.
//
//   On a daily or higher chart every bar falls in the same slot, so the time-of-day comparison is
//   vacuous. The indicator does not fake it: it falls back to the unconditional percentile and the
//   panel says "needs intraday" where the conditional figure would have been.
//
// THE GUARD THE COMPANION VOLATILITY PRODUCT DID NOT NEED: many currency crosses, many indices and
// some CFDs report NO VOLUME AT ALL. A percentile of a column of blanks — or worse, of zeros — is a
// confident number about nothing. So this counts, over its own opening window, how many bars carried
// a real volume figure. If none did, it prints NO VOLUME DATA, reports no band and no percentile,
// and switches the shading off. It does not fall back, it does not guess, and it does not draw a
// flat line at zero.
//
// WHAT IT DELIBERATELY DOES NOT DO — this is the point, not a limitation:
//   • it never tells you direction. Not a bias, not a tint, not an arrow. Heavy volume is not
//     bullish volume, and no band or state word here names a side of the market.
//   • it never predicts. EXPANDED means this bar was busy for this hour. It does not mean the next
//     one will be, and nothing here is a forecast.
//   • it never confirms a breakout, sizes a trade or places a stop. It gives you the number those
//     decisions need and stops there.
//
// HOW IT DECIDES: every published state, every band change and every alert is decided inside
// `barstate.isconfirmed` — on closed bars only. The volume figure itself moves on the forming bar,
// the way any live readout does; the STATE does not move until the bar closes. This script contains
// ZERO request.security calls, so there is no higher-timeframe repaint surface at all.
//
// LOGIC SOURCE OF TRUTH: daemons/sim/te-rvol/te-rvol.mjs, pinned by te-rvol.test.mjs — mid-rank tie
// handling, exact band edges, hysteresis in both directions, dwell, the trading-day reset, the
// no-volume path, and three properties worth naming: CAUSALITY (replace the tape after any bar and
// every earlier output is unchanged), NO RATCHET (the learned history is fed by every closed bar
// regardless of the state published, so a threshold can never climb out of reach of its own input),
// and SPELLING (a test reads THIS FILE and asserts the band words here are the same strings as the
// mirror's — because in September a rename went green across 145 tests with the Pine still saying
// the old words). This file is a transliteration of that mirror; if the two ever disagree, the
// mirror is right.
//
// ── IP PROVENANCE ───────────────────────────────────────────────────────────────────────────────
// PUBLIC MATH — percentile rank is ordinary order statistics: values strictly below, plus half the
//   ties, over the sample size. Cumulative session volume is addition.
// INDEPENDENTLY DERIVED — the time-of-day-matched volume percentile, the session-cumulative-at-slot
//   ranking, the five-band publication with hysteresis and dwell, and the no-volume guard. Derived
//   from the behavioural spec at docs/findings/2026-09-23-te-003-relative-volume-at-time-spec.md,
//   which was committed before any line of this file existed, and measured before it was designed.
//   No third-party script was read, ported or paraphrased for any of it.
// REUSED from our own catalog — the percentile, hysteresis, dwell and time-of-day slot machinery
//   come from the companion volatility product in this same catalog, as do the five band words.
//   Same repository, same authorship, declared here rather than disguised.
// ORIGINAL — the TE design kit block below, generated from daemons/forge/design-kit.mjs.
// LEFT OUT RATHER THAN GUESSED AT — any claim that heavy participation favours a direction, any
//   breakout-confirmation rule, and any volume-derived signal. Those are open research questions and
//   they do not get drawn on a chart until the evidence exists.
//
// Decision support only. No order is placed, no target is promised, no outcome is claimed.

indicator("TE Relative Volume at Time — Time-of-Day-Conditioned Participation Percentile", "TE RVOL-T", overlay = false, precision = 2)
// DRAWING BUDGET: this script allocates NO line, label or box objects. Every visual is a plot, a
// bgcolor or ONE table created once and reused — and tables are not covered by the caps. So there is
// no max_*_count to declare, and nothing here can leak a drawing object, because nothing here
// creates one.

// ── TE DESIGN KIT v1 ── generated by daemons/forge/design-kit.mjs — do not hand-edit
//
// The Trader's Edge visual grammar. Every indicator in the fleet reads the SAME meanings:
//   solid = confirmed · dashed = projected/conditional · dotted = historical/reference
//   gold  = brand and selection ONLY. It never means good, bullish, or high confidence.
//   risk outranks opportunity: a blocker always dominates positive styling.
// Palette evidence: CANDIDATE — doc 29 §9.2 labels its own hex values "design candidates, not immutable production values"

teKitDark = input.string("Dark", "Theme", options = ["Dark", "Light"], group = "APPEARANCE", tooltip = "Which chart background this is drawn for. Changing it re-picks every colour so text and lines stay legible. It cannot detect your theme automatically, so set it to match your chart.") == "Dark"

// TE_CANVAS: TE-owned surface; the TV canvas belongs to the user
TE_CANVAS = teKitDark ? #0B0F14 : #FFFFFF
// TE_SURFACE: status card / table background
TE_SURFACE = teKitDark ? #111820 : #F4F6F8
// TE_SURFACE_HI: elevated or selected row
TE_SURFACE_HI = teKitDark ? #17212B : #E9EDF1
// TE_TEXT: primary text
TE_TEXT = teKitDark ? #E6EDF3 : #0B0F14
// TE_TEXT_2: secondary text
TE_TEXT_2 = teKitDark ? #A3AFBA : #3F4A54
// TE_TEXT_MUTED: muted text — provenance, units, secondary detail
//   adjusted from doc 29's #6F7B86 — MEASURED TWICE, and the second measurement is the one that matters.
TE_TEXT_MUTED = teKitDark ? #7F8A93 : #5A6570
// TE_BORDER: divider
TE_BORDER = teKitDark ? #2A3540 : #C7D0D8
// TE_BRAND: BRAND AND SELECTION ONLY. Doc 29 §9.2 verbatim: "Gold is not good, bullish, actionable, or high confidence."
TE_BRAND = teKitDark ? #C9A55B : #AD8E4E
// TE_BRAND_MUTED: brand, de-emphasised
TE_BRAND_MUTED = teKitDark ? #8D7441 : #8D7441
// TE_BULL: bullish direction
TE_BULL = teKitDark ? #27C79A : #21A781
// TE_BEAR: bearish direction
TE_BEAR = teKitDark ? #DF6673 : #DF6673
// TE_DEVELOPING: developing / building / monitor
TE_DEVELOPING = teKitDark ? #5B9EF7 : #5695E8
// TE_ATTENTION: needs attention / selected
TE_ATTENTION = teKitDark ? #D7B45C : #AC904A
// TE_CAUTION: caution / degraded
TE_CAUTION = teKitDark ? #E9B949 : #B18D37
// TE_BLOCKED: blocked / no action
TE_BLOCKED = teKitDark ? #F28C45 : #D57B3D
// TE_INVALID: invalidated / critical risk
TE_INVALID = teKitDark ? #F0525F : #F0525F
// TE_INACTIVE: inactive / dormant / expired
TE_INACTIVE = teKitDark ? #66727D : #66727D
// TE_STRUCTURE: neutral structure — a level with no direction of its own
TE_STRUCTURE = teKitDark ? #B6C0C9 : #8A9299
// TE_STRUCTURE_2: secondary structure
TE_STRUCTURE_2 = teKitDark ? #7F8B95 : #7F8B95
// TE_TARGET: target / destination
TE_TARGET = teKitDark ? #77BDFB : #5F97C9
// TE_STOP: explicit stop / invalidation — SAME HEX as TE_INVALID by doc 29 §9.2, which is deliberate: a stop IS an invalidation
TE_STOP = teKitDark ? #F0525F : #F0525F
// TE_ENTRY: planned entry — SAME HEX as TE_ATTENTION by doc 29 §9.2. Brand-adjacent and explicitly NOT bullish/bearish
TE_ENTRY = teKitDark ? #D7B45C : #AC904A

// the line grammar, as one call — so "dashed" can never quietly come to mean "minor"

// weight carries priority; it is what "minor" uses instead of a dash.
// These are CONSTANTS because plot(linewidth=) refuses a function's series return.
TE_W_CONTEXT = 1  // context / secondary
TE_W_STANDARD = 2  // active primary structure
TE_W_EMPHASIS = 3  // decision boundary / invalidation / selected

// the same grammar for a weight chosen at RUNTIME — line.new(width=) takes series, plot() does not

// zone fills, in doc 29's perceived-opacity bands (Pine takes transparency = 100 - opacity)

// THE TE TAG — the house label. One state, one number, one separator, monospace, and a
// tooltip that is not optional. Everything else belongs in the hover layer, not on the chart.
// `style_label_left` puts the tag's pointer ON the price, so it is attached, not floating.

// ...and the plateless variant, for dense areas where a plate would cover the tape.
// Same typeface, same hover contract, no box.

// THE TEACHING LAYER — the hover is a learning tool, and this is its schema as CODE.
// Four arguments, so a product cannot quietly ship three: reads -> computed -> matters -> limit
// his 2026-09-23 11:28, choosing between two framings: "what it reads and why that matters. this"
// Plain language opens, the maths is second, and the limit clause is never optional.
// PASS COMPOSED STRINGS: a tooltip is built at runtime, so "reads" can carry THIS BAR's
// number and the lesson is about the chart in front of them, not about the concept.
teTeach(string reads, string computed, string matters, string limit) =>
    reads + "  ·  " + computed + "  ·  " + matters + "  ·  " + limit

// Density budgets (doc 29 §33, its own label: DESIGN HYPOTHESIS) are documented, not gated:
//   public classic   ≤1 core plot · ≤2 state labels · ≤1 table · ≤3 accent hues
//   dense standard   ≤3 P0/P1 labels · ≤6 emphasised lines · ≤2 zones
// A static check cannot count what is on screen, so these are the author's budget, not a gate.
// Controlled state words — the on-chart dictionary. A synonym teaches a new language:
//   opportunity [doc 29 §18.1]  OBSERVING · DEVELOPING · PENDING · QUALIFIED · ACTIONABLE
//   constraint  [doc 29 §18.1]  BLOCKED · STAND DOWN · EXPIRED · INVALIDATED
//   trade       [doc 29 §18.1]  ENTERED · T1 HIT · T2 HIT · RUNNER · CLOSED · STOPPED
//   volatility  [TE, 2026-09-23 (TE-001)]  COMPRESSED · SUBDUED · BASELINE · ELEVATED · EXPANDED · CONTRACTING · STABLE · EXPANDING
//   session     [TE, 2026-09-23 (TE-002)]  FORMING · SET · BROKEN ABOVE · BROKEN BELOW · RECLAIMED
//   range       [TE, 2026-09-23 (TE-008)]  BALANCED · RETESTED
//   level       [TE, 2026-09-23 (TE-012)]  TESTED · FLIPPED
//   gap         [TE, 2026-09-23 (TE-010)]  FILLED
// Prohibited synonyms (doc 29 §18.1): READY · GO · ACTIVE · CONFIRMED · VALID · TRIGGERED
//
// THE HOVER LAYER — every on-chart value explains itself on hover, in this order:
//   what it reads .................. [plain]  — bind the live number here
//   how it is computed ............. [maths]  — bind the live number here
//   why that information matters ... [plain]  — bind the live number here
//   what it does not tell you ...... [plain]
//   register: sentence case   ·   source: doc 29 §37.2, middle clause specialised to the formula by his 2026-09-23 00:43 naming ruling, and the teaching clause added by his 11:28 ruling
//   NOT "why it works": it presupposes that it works.
//   hoverable: table.cell · label.new   NOT hoverable: box.new · line.new · plot (compiler-verified)
//   mobile: UNKNOWN — untested, and absent from the whole research corpus
//
// What Pine can and cannot do when someone says "interactive" — the absences are the
// load-bearing half, because there is no button primitive to reach for:
//   CAN     hover — tooltip= on table.cell and label.new (never on a box: compile error)
//   CAN     inputs — toggling one re-renders the whole study, which IS interaction and is how LEARN MODE works
//   CAN     input.price and input.time — the one genuine CLICK-A-POINT affordance Pine has, and the fleet has never used it
//   CAN     input.source — the user hands the study another series to read
//   CAN     symbol and timeframe changes — every number recomposes against the new instrument
//   CANNOT  click handlers on a drawing — nothing on the chart can be clicked to run code
//   CANNOT  buttons — there is no button primitive; the settings dialog is the only control surface
//   CANNOT  scroll or pagination inside a table or a tooltip
//   CANNOT  animation or any redraw on demand — a study redraws when a bar closes or an input changes, never on a gesture
// ── END TE DESIGN KIT ──

// ════════════════════════════════ INPUTS ════════════════════════════════

gMain = "PARTICIPATION MEASURE"
showVolCols = input.bool(true, "Plot volume series V_t", group = gMain, tooltip = "Plots the bar's own volume V_t as columns, coloured by the published participation band. The series itself is the exchange's figure, drawn unchanged and not smoothed, transformed or filtered in any way. Disable it to keep only the band shading and the readout table.")
rvolRef = input.string("Median", "Slot reference statistic for the multiple", options = ["Median", "Mean"], group = gMain, tooltip = "Which statistic the familiar relative-volume MULTIPLE divides by: V_t / median(slot k) or V_t / mean(slot k), over the same M retained observations of this slot. Median is the default and the reason is the shape of the data: volume is heavy-tailed to the right, so one extraordinary session inside the sample drags a mean upward and every subsequent bar then reads quiet by comparison, with nothing on screen to say why. A median is unmoved by it. Mean is offered because it is what most scanners compute, so selecting it makes this figure directly comparable with theirs. The percentile rows below do not use this setting at all - a rank is unaffected by either statistic.")

gRegime = "PERCENTILE NORMALIZATION"
useTod = input.bool(true, "Time-of-day conditioning (rank within slot k)", group = gRegime, tooltip = "ON: the bar's volume is ranked only against volume observed in the SAME intraday slot k on previous sessions, where k = floor(minutes since exchange midnight / chart timeframe). Formally p_tod estimates P(V <= v given slot = k) over the last M sessions. OFF: it is ranked unconditionally over the last N bars, p_plain estimating P(V <= v), which is what an ordinary volume percentile computes. These are different estimators and they disagree: on about 373,000 rated 15-minute bars per instrument across two index futures and sixteen years, they assign a different one of the five bands on 72.56% and 71.76% of bars. A same-sample-size control with the slot structure destroyed disagrees on only 29.88% and 29.83%, so roughly 42 percentage points of that is attributable to time of day rather than to estimator noise. That is a larger effect than the same measurement on bar range rather than participation.")
todSessions = input.int(20, "Slot sample depth M (sessions)", minval = 5, maxval = 60, group = gRegime, tooltip = "Sample depth M for the conditional estimate: how many previous observations of slot k are retained. The percentile is quantised to 1/M, so M = 20 resolves to 5 percentile points at a time, and the standard error of a proportion near the median is about sqrt(0.25/20) = 0.112. Larger M is a lower-variance estimate but a longer memory, so it is slower to accept that participation in this market has genuinely changed level. Ranking begins once a slot holds at least 10 observations; until then the unconditional percentile is used and the readout says so rather than substituting one quietly.")
plainBars = input.int(480, "Unconditional window N (bars)", minval = 60, maxval = 2000, group = gRegime, tooltip = "Window N for the unconditional estimate over the last N closed bars, ignoring time of day. N = 480 is about five sessions on a 15-minute chart. This is the figure shown beside the conditional one so the two can be compared directly, and it is also the fallback while a slot is still filling. Note that the two estimators use very different sample sizes, N against M, which is precisely why the raw disagreement between them needs a control before it means anything.")

gPace = "SESSION PACE"
showPace = input.bool(true, "Rank cumulative session volume at slot k", group = gPace, tooltip = "Ranks the volume traded SO FAR TODAY against the volume traded by this same point in previous sessions - the classic relative-volume question, with the average replaced by a distribution. The running total resets on the exchange's own trading day, so a futures session that opens the previous evening is one day. A shortened or holiday session is not special-cased: it simply reads light at the slots it did reach, because a short day is not an exception to this estimator, it is an observation in it.")
paceSessions = input.int(20, "Pace sample depth P (sessions)", minval = 5, maxval = 60, group = gPace, tooltip = "Sample depth P for the session-cumulative estimate. Each session contributes exactly one observation per slot, so P is literally a number of previous sessions and the estimate is quantised to 1/P. The same ten-observation minimum applies before it ranks anything. This axis takes the hysteresis margin below but NOT the dwell: a running total has no brief excursions to suppress, so dwell would buy delay and fix nothing.")

gStability = "STATE PUBLICATION (hysteresis + dwell)"
hystPts = input.float(5.0, "Hysteresis margin delta-p (percentile pts)", minval = 0.0, maxval = 25.0, step = 0.5, group = gStability, tooltip = "Hysteresis margin delta-p. A published state leaves band b only when the percentile clears that band's boundary by delta-p: upward requires p > top(b) + delta-p, downward requires p < bottom(b) - delta-p. Without it, a percentile resting on an edge alternates between two states bar after bar, which is the false-state-flip problem. delta-p = 5 means the reading must move a full 5 percentile points past the edge. Set it to 0 to see the raw band assignment.")
dwellBars = input.int(2, "Dwell D (confirmed bars)", minval = 1, maxval = 20, group = gStability, tooltip = "Dwell D. After hysteresis, a candidate state must persist for D consecutive CLOSED bars before it is published, so an excursion shorter than D never appears. D and delta-p suppress different things and compose: delta-p removes boundary chatter, D removes brief genuine excursions. D = 1 publishes every change immediately. The cost is explicit: up to D bars of delay, traded for stability. One exception by design - the very first state a slot is able to rank is published at once, because there is no previous state to protect and holding a blank panel for D bars serves nobody.")

gPanel = "READOUT"
showPanel = input.bool(true, "Show readout table", group = gPanel, tooltip = "The readout table: the bar's volume, the relative-volume multiple, BOTH percentile estimates side by side so the conditional and unconditional readings can be compared directly rather than taken on trust, the session-pace ranking, and the slot's own reference statistic.")
panelPos = input.string("Top right", "Table anchor", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gPanel, tooltip = "Where the readout table is anchored within the indicator pane. Move it if it overlaps something you need to read.")
compact = input.bool(false, "Compact mode (reduced rows)", group = gPanel, tooltip = "Reduces the table to three rows for small screens: the published participation state, the bar's volume, and the relative-volume multiple. Also steps the font down one size. The rows it hides are comparisons, not warnings, so nothing load-bearing disappears.")
showShading = input.bool(true, "Shade pane by participation state", group = gPanel, tooltip = "Tints the pane background by the published participation state, so the volume series is read against its own conditional distribution rather than as a bare number. Colour encodes how unusual the participation is for this time of day, never direction: no band here is bullish or bearish, and the shading is switched off entirely when the symbol reports no volume.")

// NOTE: there is deliberately no theme input here. The design kit above emits its own `teKitDark`
// under the APPEARANCE group, and every colour in this file reads from it. A product that added a
// second theme switch would give the reader two controls for one decision.
//
// NOTE ALSO: there is deliberately no volume-smoothing input. The measurement behind this product
// ranked the RAW bar volume, and a smoothing knob would be a way to quietly diverge from the only
// evidence the product has. The percentile is itself a rank, which is the robust answer to a noisy
// series, and the dwell above is the answer to a noisy STATE.

// ════════════════════════════════ THE ENGINE ════════════════════════════════
//
// A transliteration of daemons/sim/te-rvol/te-rvol.mjs. Read that file for the reasoning; this one
// is the same algorithm in Pine's vocabulary. A test in that directory reads THIS FILE and asserts
// the band words below are the same strings the mirror uses — a check that two copies of a thing
// agree is worth more than a check that either copy is individually valid.

// ── the band edges and the band words, in ONE place ───────────────────────────────────────────────
// Spelled once as a function rather than as five literals at five call sites, because a band edge
// that appears twice is a band edge that will eventually differ from itself.
//
// 🔑 THE WORDS ARE DELIBERATELY THE VOLATILITY PRODUCT'S, and the spec records the decision. They do
// not mean "volatility" — they mean WHERE A QUANTITY SITS IN ITS OWN DISTRIBUTION, which is exactly
// what they mean here. A reader who learned them on the companion product reads this one with no new
// vocabulary. The honest cost: COMPRESSED is a weaker word for participation than THIN would have
// been, so every band tooltip states its exact quintile and the word is never the only definition on
// offer.
f_bandOf(float p) =>
    na(p) ? -1 : p <= 0.20 ? 0 : p <= 0.40 ? 1 : p <= 0.60 ? 2 : p <= 0.80 ? 3 : 4

f_bandTop(int i) =>
    i == 0 ? 0.20 : i == 1 ? 0.40 : i == 2 ? 0.60 : i == 3 ? 0.80 : 1.01

f_bandName(int i) =>
    i == 0 ? "COMPRESSED" : i == 1 ? "SUBDUED" : i == 2 ? "BASELINE" : i == 3 ? "ELEVATED" : i == 4 ? "EXPANDED" : "—"

f_bandRange(int i) =>
    i == 0 ? "0-20" : i == 1 ? "20-40" : i == 2 ? "40-60" : i == 3 ? "60-80" : i == 4 ? "80-100" : "—"

// ── hysteresis: leaving a band costs a margin, so an edge-sitter keeps the state it had ──────────
f_hystBand(float p, int prev, float h) =>
    int want = f_bandOf(p)
    int res = want
    if want >= 0 and prev >= 0 and want != prev
        if want > prev
            res := p > f_bandTop(prev) + h ? want : prev
        else
            res := p < f_bandTop(prev - 1) - h ? want : prev
    res

// ── percentile rank over a window of an array ────────────────────────────────────────────────────
// Values strictly below, plus half the ties, over n — the mid-rank convention.
//
// MID-RANK MATTERS MORE HERE THAN IT DID FOR RANGE. An overnight slot genuinely holds repeated
// volumes of 0 or 1. Under a strictly-below convention a bar equal to every one of them would rank
// 0.0 — "the quietest reading on record" for an utterly ordinary bar. Mid-rank puts it at 0.5.
//
// 🔴 THE GUARD THAT MATTERS: `for i = 0 to n - 1` with n == 0 becomes `for i = 0 to -1`, and Pine
// does NOT skip that loop — it counts DOWN, runs once at i = 0, and reads an element that is not
// there. That is RE10040, and this repo has shipped it once before in a table-row loop that compiled
// 0/0 and crashed on a chart. So the loop is only ever entered under a positive count, and every
// index is bounded by the caller's own count rather than by the array's allocated size.
f_pctRank(array<float> buf, int base, int n, float v) =>
    float res = na
    if n > 0 and not na(v)
        float below = 0.0
        float equal = 0.0
        int lim = math.min(n, array.size(buf) - base)
        if lim > 0
            for i = 0 to lim - 1
                float h = array.get(buf, base + i)
                if not na(h)
                    if h < v
                        below += 1.0
                    else if h == v
                        equal += 1.0
            res := (below + equal / 2.0) / lim
    res

f_meanOf(array<float> buf, int base, int n) =>
    float res = na
    int lim = math.min(n, array.size(buf) - base)
    if lim > 0
        float sum = 0.0
        for i = 0 to lim - 1
            sum += array.get(buf, base + i)
        res := sum / lim
    res

// Copy-and-sort rather than a selection algorithm, because Pine has array.sort and does not have
// nth_element — and because the even-n convention has to be SPELLED OUT to match the mirror rather
// than inherited from a built-in whose tie behaviour we would be assuming. `tmp` is passed in and
// reused, so nothing is allocated per bar. n is bounded by M (60 at most), so the sort never grows
// with the chart.
f_medianOf(array<float> buf, int base, int n, array<float> tmp) =>
    float res = na
    int lim = math.min(n, array.size(buf) - base)
    if lim > 0
        array.clear(tmp)
        for i = 0 to lim - 1
            array.push(tmp, array.get(buf, base + i))
        array.sort(tmp, order.ascending)
        int mid = math.floor(lim / 2.0)
        res := lim % 2 == 1 ? array.get(tmp, mid) : (array.get(tmp, mid - 1) + array.get(tmp, mid)) / 2.0
    res

// ── the time-of-day axis ──────────────────────────────────────────────────────────────────────────
// The slot is the bar's position in the trading day, in units of the chart's own timeframe, so the
// same code gives 96 slots on a 15-minute chart and 288 on a 5-minute one.
//
// 🔴 IT ANCHORS ON `syminfo.timezone` — THE INSTRUMENT'S OWN EXCHANGE TIMEZONE — NOT ON A HARDCODED
// ONE. An indicator that hardcodes one city is secretly a product for that city's market: it would
// carve another exchange's day at the wrong boundary, put its open in the middle of a slot, and
// shift every bucket by a whole hour twice a year wherever the daylight-saving dates differ. Going
// through the exchange's own zone means the day is divided the way THAT market's participants
// actually experience it, and the timezone database handles every rule instead of us.
tfMin = math.max(1, math.round(timeframe.in_seconds() / 60))
slotCount = math.max(1, math.min(1440, math.round(1440 / tfMin)))

// The time-of-day layer needs a day to have slots in it. On a daily, weekly or monthly chart every
// bar is the same slot, so the comparison is vacuous — and on a very high intraday timeframe the
// per-slot sample fills too slowly to mean anything. In both cases the product does not guess: it
// falls back to the unconditional percentile and the panel SAYS it is doing so.
intradayOk = timeframe.isintraday and tfMin <= 240

dayMin = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
rawSlot = math.floor(dayMin / tfMin)
slot = math.max(0, math.min(slotCount - 1, rawSlot))

// ── state ─────────────────────────────────────────────────────────────────────────────────────────
var array<float> plainBuf = array.new_float(0)
var array<float> todBuf = array.new_float(slotCount * todSessions, na)
var array<int> todCnt = array.new_int(slotCount, 0)
var array<int> todAt = array.new_int(slotCount, 0)
var array<float> paceBuf = array.new_float(slotCount * paceSessions, na)
var array<int> paceCnt = array.new_int(slotCount, 0)
var array<int> paceAt = array.new_int(slotCount, 0)
var array<float> rvTmp = array.new_float(0)

var int bandIdx = -1
var int pubIdx = -1
var int pendIdx = -1
var int pendBars = 0
var int lastPubIdx = -1
var int paceIdx = -1
// the percentile that produced the PUBLISHED band, held across the forming bar so the readout keeps
// showing the number the state was actually decided on rather than blanking between closes
var float pubPct = na

// ── the running session total ─────────────────────────────────────────────────────────────────────
// `time_tradingday` starts a futures session the previous evening and makes a shortened session
// simply a short one, so "holiday handling" is not a special case here — it is an ordinary
// observation. The key is COMPARED, never parsed.
//
// It advances on CLOSED BARS ONLY, like everything else in this engine. The row that shows it is
// labelled as a closed-bar figure, because a displayed number that disagrees with the ranked number
// during the forming bar would be worse than a number that is one bar behind and says so.
var float cumVol = 0.0
var int lastTd = na

// ── the no-volume probe ───────────────────────────────────────────────────────────────────────────
// NO VOLUME IS A STATE, NOT A ZERO. Before the probe window is up the product simply reports nothing
// yet: claiming "no volume data" on bar three of a quiet overnight session would be its own lie.
VOL_PROBE = 20
var int volBars = 0
var int volPos = 0

float pPlain = na
float pTod = na
float pPace = na
float rvRef = na
float rvMult = na
bool usedTod = false
float pState = na
bool changed = false
bool newSession = false

hasVol = not na(volume)

if barstate.isconfirmed
    volBars += 1
    if hasVol and volume > 0
        volPos += 1

    newSession := na(lastTd) or time_tradingday != lastTd
    lastTd := time_tradingday
    cumVol := (newSession ? 0.0 : cumVol) + (hasVol ? volume : 0.0)

noVolume = volBars >= VOL_PROBE and volPos == 0

if barstate.isconfirmed and hasVol and not noVolume
    int base = slot * todSessions
    int paceBase = slot * paceSessions
    int nTod = array.get(todCnt, slot)
    int nPace = array.get(paceCnt, slot)

    // --- rate, against history that has already closed ---
    int nPlain = array.size(plainBuf)
    if nPlain >= math.min(120, plainBars)
        pPlain := f_pctRank(plainBuf, 0, nPlain, volume)

    if useTod and intradayOk and nTod >= 10
        pTod := f_pctRank(todBuf, base, nTod, volume)

    if showPace and intradayOk and nPace >= 10
        pPace := f_pctRank(paceBuf, paceBase, nPace, cumVol)

    // the familiar multiple — the bridge from the classic ratio to the percentile beside it
    if nTod >= 10
        rvRef := rvolRef == "Mean" ? f_meanOf(todBuf, base, nTod) : f_medianOf(todBuf, base, nTod, rvTmp)
        rvMult := not na(rvRef) and rvRef > 0 ? volume / rvRef : na

    usedTod := not na(pTod)
    pState := usedTod ? pTod : pPlain

    // --- publish, with hysteresis then dwell ---
    if not na(pState)
        bandIdx := f_hystBand(pState, bandIdx, hystPts / 100.0)
        if pubIdx < 0
            // the FIRST state a slot can rank is published at once: there is no previous state to
            // protect, and holding a blank panel for D bars serves nobody
            pubIdx := bandIdx
            pendIdx := -1
            pendBars := 0
        else if bandIdx == pubIdx
            pendIdx := -1
            pendBars := 0
        else if bandIdx == pendIdx
            pendBars += 1
            if pendBars >= dwellBars
                pubIdx := bandIdx
                pendIdx := -1
                pendBars := 0
        else
            pendIdx := bandIdx
            pendBars := 1
            if dwellBars <= 1
                pubIdx := bandIdx
                pendIdx := -1
                pendBars := 0
        changed := pubIdx != lastPubIdx and lastPubIdx >= 0
        lastPubIdx := pubIdx
        pubPct := pState

    // --- the pace band: hysteresis, no dwell ---
    // The two mechanisms fix two different faults. Hysteresis fixes a reading resting ON a band
    // edge; dwell fixes a brief genuine excursion. A running total has no brief excursions, so dwell
    // here would be delay bought for nothing.
    if not na(pPace)
        paceIdx := f_hystBand(pPace, paceIdx, hystPts / 100.0)

    // --- append: EVERY closed bar with a real volume, whatever state was published ---
    // This is the anti-ratchet property. A threshold fed only by what it already passed climbs until
    // nothing can reach it; the state here is downstream of the history and never gates it. The live
    // entries are kept DENSE in [base, base + n) so the rating loop above reads observations rather
    // than slots that were never written.
    array.push(plainBuf, volume)
    if array.size(plainBuf) > plainBars
        array.shift(plainBuf)

    if array.size(todBuf) >= base + todSessions
        if nTod < todSessions
            array.set(todBuf, base + nTod, volume)
            array.set(todCnt, slot, nTod + 1)
            array.set(todAt, slot, (nTod + 1) % todSessions)
        else
            int at = array.get(todAt, slot)
            array.set(todBuf, base + at, volume)
            array.set(todAt, slot, (at + 1) % todSessions)

    if array.size(paceBuf) >= paceBase + paceSessions
        if nPace < paceSessions
            array.set(paceBuf, paceBase + nPace, cumVol)
            array.set(paceCnt, slot, nPace + 1)
            array.set(paceAt, slot, (nPace + 1) % paceSessions)
        else
            int at2 = array.get(paceAt, slot)
            array.set(paceBuf, paceBase + at2, cumVol)
            array.set(paceAt, slot, (at2 + 1) % paceSessions)

// ── the readouts ──────────────────────────────────────────────────────────────────────────────────
// What ONE unit of this instrument's volume is CALLED, read from the symbol so the panel never says
// "contracts" on a stock. This is the same portability discipline the rest of the fleet uses: the
// tick size, the currency and the exchange timezone all come from the symbol, and so does this.
unitWord = syminfo.type == "futures" ? "contracts" : syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" ? "shares" : syminfo.type == "crypto" ? "coins" : syminfo.type == "forex" ? "ticks" : "units"

// the state words this product may print, in the one place a reader can find them
STATE_NO_VOLUME = "NO VOLUME DATA"

// ════════════════════════════════ WHAT IS DRAWN ════════════════════════════════

// ── the participation colour ramp ─────────────────────────────────────────────────────────────────
// Every colour comes from the design kit by NAME, and the choice of which token means which band is
// a decision worth stating plainly:
//
//   NO BAND USES TE_BULL OR TE_BEAR. Those encode direction, and this product's whole reason to
//   exist is that participation is not direction. Heavy volume is not bullish volume: the same
//   enormous print is a breakout to one reader and a climax to another, and a green "busy" would
//   quietly pick a side the evidence does not support.
//
//   NO BAND USES BRAND GOLD. Doc 29 §9.2 is verbatim about it: gold is not good, bullish, actionable
//   or high confidence. It is brand and selection only.
//
//   So the ramp is a CONTEXT ramp, not a quality ramp: dormant, then neutral structure, then
//   building, then caution. "Caution" at the top is a statement about how fast the book is moving
//   around you, not a prediction and not a judgment about the market being bad.
f_bandColor(int i) =>
    i == 0 ? TE_INACTIVE : i == 1 ? TE_STRUCTURE_2 : i == 2 ? TE_STRUCTURE : i == 3 ? TE_DEVELOPING : i == 4 ? TE_CAUTION : TE_TEXT_MUTED

bandCol = noVolume ? TE_TEXT_MUTED : f_bandColor(pubIdx)

// the classic series, unchanged and still the main thing on the pane
plot(showVolCols and not noVolume ? volume : na, "Volume", style = plot.style_columns, color = bandCol)

// the context behind it — this is what turns one number into a reading
bgcolor(showShading and not noVolume and pubIdx >= 0 ? color.new(bandCol, 92) : na, title = "Participation shading")

// ── the data window channels ─────────────────────────────────────────────────────────────────────
// display.data_window rather than display.none on purpose: none of these should draw on the pane,
// but all of them should be readable in the Data Window and bindable by another script.
plot(na(pTod) ? na : pTod * 100.0, "p | slot k", display = display.data_window)
plot(na(pPlain) ? na : pPlain * 100.0, "p unconditional", display = display.data_window)
plot(na(pPace) ? na : pPace * 100.0, "pace | slot k", display = display.data_window)
plot(rvMult, "V / slot reference", display = display.data_window)
plot(rvRef, "Slot reference volume", display = display.data_window)
plot(noVolume ? na : pubIdx, "Participation band index (0-4)", display = display.data_window)
plot(noVolume ? na : paceIdx, "Session pace band index (0-4)", display = display.data_window)
plot(noVolume ? na : cumVol, "Session volume (closed bars)", display = display.data_window)

// ── formatting ────────────────────────────────────────────────────────────────────────────────────
f_panelPos(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

f_num(float v, int dp) =>
    na(v) ? "—" : str.tostring(v, dp == 0 ? "#" : dp == 1 ? "#.#" : "#.##")

// Volume figures span six orders of magnitude between an overnight bar and a cash-close bar on the
// same chart, so a raw integer is unreadable in a two-column table. This abbreviates — and it
// abbreviates DISPLAY only: every percentile above ranks the exact figure, never this rounding.
f_volTxt(float v) =>
    na(v) ? "—" : v >= 1000000000 ? str.tostring(v / 1000000000, "#.##") + "B" : v >= 1000000 ? str.tostring(v / 1000000, "#.##") + "M" : v >= 1000 ? str.tostring(v / 1000, "#.#") + "K" : str.tostring(v, "#")

refWord = rvolRef == "Mean" ? "mean" : "median"

// ── THE HOVER LAYER, AND IT IS A TEACHING LAYER ───────────────────────────────────────────────────
// Every row of this panel explains itself when you hover it. Both cells of a row carry the SAME
// tooltip, so the whole row is a hover target rather than a half-inch of text — you should not have
// to aim.
//
// THE SCHEMA IS HIS, RULED 2026-09-23 and emitted by the design kit as `teTeach`, which takes the
// four clauses as four arguments so a product cannot quietly ship three of them:
//
//     what it reads  ·  how it is computed  ·  why that information matters  ·  what it does not tell you
//
// Plain language opens and the maths is second, but the maths is never dropped, because a formula a
// reader can check is evidence and one they cannot is decoration. Nor is the last clause: a readout
// that explains what it is and hides what it cannot do is the thing that makes people trust a number
// too much.
//
// ⚠️ NOT "why it WORKS". That framing presupposes that it works, which is an efficacy claim. "Why
// that information matters" says which DECISION the number changes, and stops there.
//
// 🕹️ AND THE CLAUSES ARE COMPOSED AT RUNTIME, WHICH IS THE WHOLE POINT. Pine has no click handlers
// and no buttons, so "interactive" cannot mean what it means in a browser. It can mean this: a
// tooltip is a STRING BUILT ON THIS BAR, so it says "this bar traded 41.2K contracts, more than 85%
// of what this slot has done in the last twenty sessions" rather than "relative volume is a measure
// of participation". The lesson is about the chart in front of the reader instead of about the
// concept — and it is free, because every number in it was already computed for the row beside it.

var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    txtSize = compact ? size.small : size.normal

    // ONE teTeach call with the no-volume branch INSIDE each clause, rather than two calls behind a
    // ternary. Both shapes read the same on a chart; only this one can be resolved by the rule that
    // checks the four-clause schema was used, because that rule reads a single-line assignment. A
    // check it cannot see through is a check that silently stops protecting the thing.
    tipState = teTeach(
      noVolume ? "This symbol does not report volume, so there is nothing to rank and this product says so rather than showing a number." : "Right now this bar's participation reads " + f_bandName(pubIdx) + (na(pubPct) ? "" : ", on a percentile of " + f_num(pubPct * 100.0, 0) + " out of 100") + " — that is how busy it is compared with this market's own history at this time of day, not with any other market's.",
      noVolume ? "Over the first " + str.tostring(VOL_PROBE) + " closed bars not one carried a volume figure above zero. Many currency crosses, many index symbols and some contracts-for-difference publish no volume at all." : "The band is the quintile of p: " + f_bandRange(0) + " COMPRESSED, " + f_bandRange(1) + " SUBDUED, " + f_bandRange(2) + " BASELINE, " + f_bandRange(3) + " ELEVATED, " + f_bandRange(4) + " EXPANDED, where p is the conditional percentile when one is available and the unconditional one otherwise. Leaving a band first costs a margin of " + f_num(hystPts, 1) + " percentile points, and the new band must then hold for " + str.tostring(dwellBars) + " closed bars before it is published.",
      noVolume ? "A percentile of a column of blanks would look exactly like a real reading, and you would have no way to tell which you were looking at. Saying so is the only honest output available here." : "Volume means different things at different hours. The same figure is an enormous print at lunchtime and a quiet one at the open, so this is the row that tells you whether what you are watching is actually unusual.",
      noVolume ? "It does not mean the market is quiet. It means the data feed for this symbol carries no participation figure, which is a fact about the symbol and not about the market." : "It does not forecast, and it is not a direction. EXPANDED means a lot of business went through for this hour; it does not say who was buying, and it does not mean the next bar will be busy.")

    tipVol = teTeach(
      "Right now this bar has traded " + f_volTxt(volume) + " " + unitWord + ".",
      "The exchange's own volume figure for the bar, drawn unchanged: not smoothed, not filtered and not transformed. The columns on the pane are this series, coloured by the band above.",
      "It is the raw material every other row is built from, and it is worth seeing beside its ranking so you can tell a genuinely large print from a number that merely ranks highly in a quiet sample.",
      "On its own it carries no context: whether " + f_volTxt(volume) + " is a lot depends entirely on the instrument and on the hour, which is exactly what the rows below add.")

    tipMult = teTeach(
      na(rvMult) ? "This slot is still filling — it needs ten observations of this time of day before there is anything to compare against." : "Right now this bar has traded " + f_num(rvMult, 2) + " times the " + refWord + " volume this slot has seen over the last " + str.tostring(todSessions) + " sessions.",
      "V divided by the " + refWord + " of the last " + str.tostring(todSessions) + " observations of THIS slot" + (na(rvRef) ? "" : ", which is currently " + f_volTxt(rvRef) + " " + unitWord) + ". This is the familiar relative-volume multiple, computed against one time of day rather than against a mixed-hour average.",
      "It is the figure most scanners report, so it is the one you can compare with what you already use — and it is the bridge to the percentile below, which says the same thing with a distribution behind it instead of a single number.",
      "A multiple has no distribution behind it: 2.0 times could be the busiest this slot has ever been or an ordinary Tuesday, and this row cannot tell you which. The percentile rows can. The " + refWord + " is also sensitive to how many sessions are retained.")

    table.clear(panel, 0, 0, 1, 7)
    table.cell(panel, 0, 0, "PARTICIPATION", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipState)
    table.cell(panel, 1, 0, noVolume ? STATE_NO_VOLUME : f_bandName(pubIdx) + (na(pubPct) ? "" : "  p" + f_num(pubPct * 100.0, 0)), text_color = bandCol, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipState)

    table.cell(panel, 0, 1, "Volume V", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipVol)
    table.cell(panel, 1, 1, noVolume ? "—" : f_volTxt(volume), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipVol)

    table.cell(panel, 0, 2, "V / " + refWord + "(slot k)", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipMult)
    table.cell(panel, 1, 2, na(rvMult) ? "—" : f_num(rvMult, 2) + "x", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipMult)

    if not compact
        // BOTH percentiles, side by side, so the reader can see them disagree. That disagreement IS
        // the product, and hiding the comparison would be hiding the evidence for it.
        //
        // And when the time-of-day layer is NOT available — a daily chart, a timeframe too high, or
        // a slot still filling — the row says which of those it is rather than showing a number that
        // looks like the same measurement. A fallback the reader cannot see is a lie by omission.
        todLabel = noVolume ? "—" : not intradayOk ? "needs intraday" : not useTod ? "off" : na(pTod) ? "filling" : f_num(pTod * 100.0, 0)

        tipTod = teTeach(
          not intradayOk ? "This row needs an intraday chart. On a daily or higher timeframe there is no time of day to condition on, so it reports that instead of a number." : not useTod ? "This row is switched off in the settings, so the band above is being decided on the unconditional percentile instead." : na(pTod) ? "This slot of the day is still filling — it needs ten observations before it will rank anything." : "Right now this bar's volume is above " + f_num(pTod * 100.0, 0) + "% of what this same time of day has traded over the last " + str.tostring(todSessions) + " sessions.",
          "The day is carved into slots one chart timeframe wide, anchored on the exchange's own timezone, and the last " + str.tostring(todSessions) + " observations of THIS slot are kept and ranked: it estimates the probability that a bar in this slot trades no more than this one did. The estimate is quantised to one part in " + str.tostring(todSessions) + ", so it resolves to " + f_num(100.0 / todSessions, 0) + " percentile points at a time.",
          "Markets have a shape to the day — an open is not a lunch hour. Ranking this bar against the same clock time is what separates \"this is a big print\" from \"this is 09:30\", and it is the one thing the classic single ratio cannot tell you.",
          "It is a ranking, not a level and not a forecast. A high reading says this hour is busier than this hour usually is; it does not say the market is trending, and it does not say which way.")

        table.cell(panel, 0, 3, "p | slot k  (M=" + str.tostring(todSessions) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTod)
        table.cell(panel, 1, 3, todLabel, text_color = usedTod ? TE_TEXT : TE_TEXT_MUTED, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTod)

        tipPlain = teTeach(
          noVolume ? "There is no volume on this symbol to rank." : na(pPlain) ? "Still filling — this needs " + str.tostring(plainBars) + " closed bars before it will rank anything." : "Right now this bar's volume is above " + f_num(pPlain * 100.0, 0) + "% of the last " + str.tostring(plainBars) + " bars, ignoring time of day entirely — and the row above says " + (na(pTod) ? "nothing yet" : f_num(pTod * 100.0, 0)) + ".",
          "The same ranking over the last " + str.tostring(plainBars) + " closed bars with no conditioning. This is what an ordinary volume percentile computes, and it is shown so the two can be compared directly rather than taken on trust.",
          "Watching these two disagree is the product. When they are far apart, the reading you would have got from a plain percentile was telling you about the time of day rather than about the market.",
          "The two use very different sample sizes, " + str.tostring(plainBars) + " against " + str.tostring(todSessions) + ", so some disagreement is estimator noise. On two index futures a same-sample-size control attributed about 42 of the 72 percentage points of disagreement to time of day itself; the rest was not.")

        table.cell(panel, 0, 4, "p uncond. (N=" + str.tostring(plainBars) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPlain)
        table.cell(panel, 1, 4, noVolume ? "—" : na(pPlain) ? "filling" : f_num(pPlain * 100.0, 0), text_color = usedTod ? TE_TEXT_MUTED : TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPlain)

        paceLabel = noVolume ? "—" : not intradayOk ? "needs intraday" : not showPace ? "off" : na(pPace) ? "filling" : f_bandName(paceIdx) + "  p" + f_num(pPace * 100.0, 0)

        tipPace = teTeach(
          na(pPace) ? (not showPace ? "The session-pace row is switched off in the settings." : not intradayOk ? "This row needs an intraday chart: a session has to have points inside it before there is a pace to measure." : "Still filling — this point in the session needs ten previous sessions to compare against.") : "So far today this market has traded " + f_volTxt(cumVol) + " " + unitWord + " through the last closed bar, which is more than " + f_num(pPace * 100.0, 0) + "% of what it had traded by this same point in the last " + str.tostring(paceSessions) + " sessions.",
          "Volume is added up from the start of the exchange's trading day and ranked against the running total at THIS SAME slot in previous sessions — one observation per session, so the comparison is like for like. A shortened session is not special-cased: it simply reads light at the slots it did reach.",
          "The bar rows tell you about a moment; this one tells you about the day. A session running far below its own normal pace is one where levels tend to be tested by fewer participants, and that is worth knowing before you read anything else on the chart.",
          "It is the day so far, not the day. An early reading is a small fraction of a session and moves easily, and this says nothing about how the rest of the day will trade. It takes the hysteresis margin but no dwell, because a running total has no brief excursions to suppress.")

        table.cell(panel, 0, 5, "Session pace (P=" + str.tostring(paceSessions) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPace)
        table.cell(panel, 1, 5, paceLabel, text_color = na(pPace) ? TE_TEXT_MUTED : f_bandColor(paceIdx), bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPace)

        tipCum = teTeach(
          "So far today this market has traded " + f_volTxt(cumVol) + " " + unitWord + ", counted through the last closed bar.",
          "The sum of every closed bar's volume since the start of the exchange's trading day, which for a market that opens the previous evening begins there rather than at midnight. The forming bar is not included, so this figure is the one the ranking above was actually computed on.",
          "It is the plain number behind the pace ranking, and it is the one to read when you want the size of the day rather than its position in a distribution.",
          "It is a running total, so it only ever grows during a session and cannot be compared with another symbol's or another timeframe's figure directly.")

        table.cell(panel, 0, 6, "Session volume", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipCum)
        table.cell(panel, 1, 6, noVolume ? "—" : f_volTxt(cumVol), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipCum)

        tipRef = teTeach(
          na(rvRef) ? "This slot is still filling — it needs ten observations of this time of day before there is a reference to show." : "Right now a typical bar in this slot trades " + f_volTxt(rvRef) + " " + unitWord + ", taken as the " + refWord + " of the last " + str.tostring(todSessions) + " sessions.",
          "The " + refWord + " of the same retained sample the conditional percentile ranks against. Median is the default because volume is heavy-tailed to the right and a single extraordinary session would drag a mean upward for as long as it stayed in the window.",
          "It is the denominator of the multiple two rows above, shown so that figure is checkable rather than taken on faith — and it is the quickest way to see how busy this slot normally is at all.",
          "It is a summary of " + str.tostring(todSessions) + " observations and nothing more. It is not a target, not an expectation for this bar, and it changes as the sample rolls forward.")

        table.cell(panel, 0, 7, refWord + "(slot k)", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipRef)
        table.cell(panel, 1, 7, na(rvRef) ? "—" : f_volTxt(rvRef), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipRef)

    table.set_position(panel, f_panelPos(panelPos))

// ════════════════════════════════ ALERTS ════════════════════════════════
//
// STATE-CHANGE ONLY, and on CLOSED BARS ONLY. Never an every-bar alert: a participation tool that
// notifies you on every bar is a tool you mute in a week, and a muted alert is worse than no alert
// because you believe you are covered.
//
// Both mechanisms are here on purpose, because they are not interchangeable:
//   alertcondition() is what makes the alert DISCOVERABLE — it appears in TradingView's own alert
//     dialog, so a user can arm it from the UI without reading any documentation.
//   alert() carries the DYNAMIC text, so the message can name which band was entered and what the
//     reading was. alertcondition() cannot interpolate a value.
//
// ⚠️ Whichever you arm: a TradingView alert freezes the INPUTS as they were when you created it. If
// you later change the slot depth or the dwell, the running alert keeps firing on the old settings
// until you recreate it. That is TradingView's behaviour for every script, not this one's.

alertcondition(changed, title = "Participation band changed", message = "Participation band changed on {{ticker}} {{interval}} — the published volume percentile has moved to a new band. See the readout for the new state.")

if changed and barstate.isconfirmed
    alert("TE RVOL-T — " + syminfo.ticker + " " + timeframe.period + " participation is now " + f_bandName(pubIdx) + (na(rvMult) ? "" : " at " + f_num(rvMult, 2) + "x the " + refWord + " for this slot") + (usedTod ? ", ranked against this time of day." : ", ranked against recent bars."), alert.freq_once_per_bar_close)

// ── the rail, last line, where it is never edited away by accident ───────────────────────────────
// Decision support. This is not financial advice, and nothing here is a recommendation to buy or
// sell anything.
````
