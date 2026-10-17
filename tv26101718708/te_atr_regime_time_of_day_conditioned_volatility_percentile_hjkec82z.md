# TE ATR Regime Time of Day Conditioned Volatility Percentile

- url: https://www.tradingview.com/script/hjKeC82z-TE-ATR-Regime-Time-of-Day-Conditioned-Volatility-Percentile/
- type: indicator
- pine_id: PUB;511a9298a0fa46b2a910445a09fe4682
- version: 1.0

## Description

[b]TE ATR Regime - Time-of-Day-Conditioned Volatility Percentile[/b]
https://www.tradingview.com/x/yUiTAf5c/
[b]Default parameters[/b]
TE ATR Regime is a volatility-context indicator built around a simple question:

How volatile is this market right now, and is that volatility expanding or contracting?
https://www.tradingview.com/x/D6zNMRUx/
Traditional ATR reports the magnitude of recent range, but the raw value has no context. An ATR of 14 points may be unusually large at one time of day and completely ordinary at another.
https://www.tradingview.com/x/kyHGuiZW/
This indicator keeps Wilder's ATR unchanged and adds two percentile estimators around it:

1. An unconditional percentile over recent bars.
2. A time-of-day-conditioned percentile comparing the current reading only with prior observations from the same intraday time slot.

The two estimates are displayed side by side so the user can see when a conventional trailing volatility percentile is primarily reflecting the normal rhythm of the trading day rather than an unusual volatility condition.
https://www.tradingview.com/x/zAAlfoAO/
[b]1. Average True Range[/b]

The underlying ATR is Wilder's standard Average True Range:

[pine]
TR_t = max(H_t - L_t, abs(H_t - C_(t-1)), abs(L_t - C_(t-1)))

ATR_t = ATR_(t-1) + (TR_t - ATR_(t-1)) / n
[/pine]

The default is n = 14.

The plotted ATR is the standard Pine ta.atr(n) series. It is not replaced by a proprietary variation.

[b]2. Volatility normalization[/b]

The current ATR is first normalized by price:

[pine]
x = ATR_t / C_t
[/pine]

This expresses volatility as a fraction of the instrument's current price instead of relying only on raw points.

The indicator then calculates two empirical percentile ranks:

[pine]
p_uncond = P(X <= x)
           over the last N closed bars

p_slot   = P(X <= x | slot = k)
           over prior observations of the same intraday slot
[/pine]

Defaults:

N = 480 closed bars
M = 20 prior slot observations

The intraday slot is:

[pine]
k = floor(
    minutes since exchange midnight
    / chart timeframe in minutes
)
[/pine]

Time is evaluated using the instrument's own exchange timezone.

Percentile ranks use the mid-rank convention:

[pine]
P_hat =
(
    count(history < x)
    + 0.5 * count(history = x)
)
/ n
[/pine]

A flat history therefore ranks at 0.50 rather than automatically returning 1.00.

The current bar is ranked against previously closed history before it is added to that history.

[b]3. Volatility regime bands[/b]

The active percentile is translated into five descriptive volatility states:

COMPRESSED: p <= 0.20
SUBDUED: 0.20 < p <= 0.40
BASELINE: 0.40 < p <= 0.60
ELEVATED: 0.60 < p <= 0.80
EXPANDED: p > 0.80

These states describe relative range conditions only. They do not indicate bullish or bearish direction.

[b]4. Hysteresis and dwell[/b]

Raw percentile classifications can alternate repeatedly when the reading sits near a band boundary.

TE ATR Regime therefore separates measurement from publication.

A new band must first clear the existing boundary by a hysteresis margin:

[pine]
upward:
p > upper_boundary + delta_p

downward:
p < lower_boundary - delta_p
[/pine]

The default hysteresis margin is 5 percentile points.

After clearing that threshold, the candidate state must remain valid for D consecutive confirmed bars before the new state is published.

Default:

D = 2 closed bars

These mechanisms serve different purposes:

Hysteresis reduces boundary chatter.
Dwell suppresses brief state excursions.
https://www.tradingview.com/x/3IFJSjC0/
The tradeoff is explicit: greater state stability can introduce publication delay.

Setting delta_p = 0 and D = 1 exposes the raw classification behavior.

[b]5. Volatility level and volatility change are separate[/b]

The indicator also measures the relative first difference of ATR:

[pine]
r = (ATR_t - ATR_(t-L)) / ATR_(t-L)
[/pine]

Defaults:

L = 5 bars
epsilon = 5%

Classification:

EXPANDING if r > +epsilon
CONTRACTING if r < -epsilon
STABLE otherwise

This deliberately separates two different questions:

How large is volatility relative to history?

And:

Is volatility currently increasing or decreasing?

A market can therefore be COMPRESSED and EXPANDING at the same time, or EXPANDED and CONTRACTING.

[b]Why condition volatility on time of day?[/b]

The development research measured the difference using 1-minute ES and NQ futures data from June 2010 through June 2026, aggregated to 15-minute bars.

Across 745,589 rated bars, median ATR as a percentage of price varied materially across the trading day.

ES:
quietest-to-loudest median ATR/price ratio = 2.44x

NQ:
quietest-to-loudest median ATR/price ratio = 2.78x

The time-conditioned and unconditional estimators assigned different five-band states on approximately two-thirds of rated bars.

Because the estimators use different sample sizes, that raw disagreement cannot by itself be attributed to time of day. A same-sample-size control was therefore run with the time-of-day structure removed.

Control disagreement was approximately 29% for both instruments, versus approximately 66-67% for the actual time-conditioned comparison.

The remaining difference was approximately 37-38 percentage points in this ES/NQ sample.

This is a descriptive measurement of volatility structure. It is not a trading-performance result and makes no claim about future returns.

[b]Readout[/b]

The full panel can display:

- ATR in price points
- ATR in minimum tick increments
- ATR as a percentage of price
- ATR translated into currency at a user-entered quantity
- Published volatility regime
- EXPANDING / STABLE / CONTRACTING state
- Time-of-day-conditioned percentile
- Unconditional percentile

Instrument metadata such as minimum tick, point value, currency and exchange timezone is read directly from the symbol.

The money row is arithmetic only:

[pine]
ATR * syminfo.pointvalue * q
[/pine]

It is not connected to an account, broker, position or risk model.

[b]Intraday behavior[/b]

Time-of-day conditioning is intended for intraday charts.

When a meaningful time-of-day comparison is unavailable, the indicator falls back to the unconditional percentile and identifies that condition in the panel rather than presenting the fallback as though it were the same measurement.

[b]Closed-bar state logic[/b]

Published regime changes and alerts are evaluated on confirmed bars.

The ATR value itself can naturally change while the current bar is forming, but the published regime state does not change until bar confirmation.

The script does not use request.security() for higher-timeframe calculations.

[b]Alerts[/b]

An alert condition is available when the published ATR regime changes.

Alerts are state-change events rather than every-bar notifications.

[b]What this indicator does not do[/b]

It does not forecast price.

It does not forecast future volatility.

It does not provide bullish or bearish direction.

It does not generate a win rate, profit factor or trading-performance estimate.

It does not place stops or determine position size.

It does not connect to a brokerage account.

EXPANDED means recent volatility is high relative to the selected historical context. It does not mean volatility will remain high or that price will move in either direction.

ATR period n: 14
Slot sample depth M: 20 sessions
Unconditional window N: 480 bars
Hysteresis margin: 5 percentile points
Dwell D: 2 confirmed bars
Difference lag L: 5 bars
First-difference deadband: 5%
Position quantity q: 1

TE ATR Regime is designed as decision-support infrastructure: the classic ATR remains intact while the additional layers provide statistical context for interpreting what that ATR means for the instrument and time of day currently being observed.

## Source Code

````pine
//@version=6
// TE ATR REGIME — TIME-OF-DAY-CONDITIONED VOLATILITY PERCENTILE  (catalog TE-001)
// This source code is subject to the terms of the TRADERS EDGE license — all rights reserved. Distributed on
// TradingView as a protected / Public; not for resale, or reverse engineering.
// THE QUESTION: how volatile is this market, and is volatility expanding or contracting?
//
// THE PROBLEM WITH THE CLASSIC: ATR is almost always drawn as a single line with no context. 14.2
// points tells you nothing on its own — not whether that is a lot for this instrument, and not
// whether it is a lot for THIS TIME OF DAY. So people read a quiet midday ATR as calm when it is
// actually high for midday, and read an overnight ATR as calm when it is extreme for overnight.
//
// WHAT THIS ADDS, AND ONLY THIS: the classic line is untouched. Behind it, the pane is shaded by
// where the current ATR sits in the distribution of ATR AT THIS SAME TIME OF DAY. A panel gives the
// reading in points, in ticks, as a percent of price and as money at your stated size, plus BOTH
// percentile estimates side by side so you can watch them disagree — which is the entire product.
//
// WHY TIME OF DAY AND NOT JUST A TRAILING PERCENTILE — measured, not asserted:
//   Sixteen years of 1m tape (2010-06-07 to 2026-06-19) aggregated to 15m: 8,262 sessions across
//   two instruments, 745,589 rated bars. Median ATR-as-percent-of-price varies 2.44x on ES and
//   2.78x on NQ between the quietest 15m slot of the day (01:45 on both) and the loudest (17:15 on
//   ES, 16:15 on NQ). A plain trailing percentile and a time-of-day-matched one put the market in a
//   DIFFERENT one of the five bands on 66.3% (ES) and 67.4% (NQ) of bars.
//
//   That last number means nothing by itself, so it was controlled. A time-of-day percentile ranks
//   against ~20 samples and a plain one against ~480, and two estimators at different sample sizes
//   disagree from noise alone. The same estimator at the same sample size, with the time-of-day
//   structure destroyed, disagrees on 29.0% (ES) and 29.1% (NQ) — so 37.4 and 38.3 percentage
//   points are attributable to time of day itself, and the two instruments replicate each other to
//   within a point. The disagreement concentrates in the afternoon and around the cash close, where
//   a trailing window is dominated by busy bars and over-reads how quiet the quiet hours are.
//
//   Reproduce it: daemons/learn/tod-volatility-measure.mjs — the measurement, its control, and the
//   raw output in reports/te-vol/. It is DESCRIPTIVE. It says how the tape is shaped. It says
//   nothing about what price will do next, and neither does this indicator.
//
//   ⚠️ SCOPE OF THAT EVIDENCE, STATED PLAINLY: it was measured on ES and NQ index futures. The
//   indicator itself works on any instrument and any timeframe — it reads the symbol's own tick
//   size, point value, currency and exchange timezone, and carves the day in THAT market's own
//   hours, so it is correct on a stock, an FX cross or a crypto pair without configuration. But
//   "correct" and "verified" are different words: the SIZE of the time-of-day effect above is an
//   ES/NQ number and has not been measured on equities, FX or crypto. The mechanism is not
//   futures-specific — a market with busy hours and quiet hours will show it — and you can see
//   whichever is true on your own symbol, because the panel shows both percentiles side by side.
//
//   On a daily or higher chart every bar falls in the same slot, so the time-of-day comparison is
//   vacuous. The indicator does not fake it: it falls back to the plain percentile and the panel
//   says "needs intraday" where the time-of-day figure would have been.
//
// WHAT IT DELIBERATELY DOES NOT DO — this is the point, not a limitation:
//   • it never tells you direction. Not a bias, not a tint, not an arrow. Volatility is not trend,
//     and confusing the two is the failure this product exists to correct. No band or state word in
//     this script names a side of the market, and a test in the repo fails if one ever does.
//   • it never predicts. "EXPANDED" means the last 14 bars were wide for this hour. It does not
//     mean they will stay wide, and nothing here is a forecast.
//   • it never sizes your trade or places your stop. It gives you the number those decisions need.
//
// HOW IT DECIDES: every published state, every band change and every alert is decided inside
// `barstate.isconfirmed` — on closed bars only. The ATR value itself moves on the forming bar, the
// way any price readout does; the STATE does not move until the bar closes. This script contains
// ZERO request.security calls, so there is no higher-timeframe repaint surface at all.
//
// LOGIC SOURCE OF TRUTH: daemons/sim/te-vol/te-vol.mjs, pinned by te-vol.test.mjs — Wilder ATR
// parity, percentile tie handling, exact band edges, hysteresis, dwell, and two properties worth
// naming: CAUSALITY (replace the tape after any bar and every earlier output is unchanged) and NO
// RATCHET (the learned history is fed by every closed bar regardless of the state published, so the
// threshold can never climb out of reach of its own input). This file is a transliteration of that
// mirror; if the two ever disagree, the mirror is right.
//
// ── IP PROVENANCE ───────────────────────────────────────────────────────────────────────────────
// PUBLIC MATH — true range and Wilder's smoothing (Wilder, 1978), the same recursion the built-in
//   ta.atr uses, and here it IS ta.atr. Percentile rank is ordinary order statistics: values below,
//   plus half the ties.
// INDEPENDENTLY DERIVED — the time-of-day-matched percentile, the five bands, and the
//   hysteresis-and-dwell publication rule. Derived from the behavioural spec at
//   docs/findings/2026-09-23-te-001-atr-volatility-regime-spec.md, which was committed before any
//   line of this file existed, and measured before it was designed. No third-party script was read,
//   ported or paraphrased for any of it.
// ORIGINAL — the TE design kit block below, generated from daemons/forge/design-kit.mjs.
// LEFT OUT RATHER THAN GUESSED AT — any volatility forecast, any expansion target, and any claim
//   that a regime favours one kind of setup. Those are open research questions and they do not get
//   drawn on a chart until the evidence exists.
//
// Decision support only. No order is placed, no target is promised, no outcome is claimed.

indicator("TE ATR Regime — Time-of-Day-Conditioned Volatility Percentile", "TE ATR-R", overlay = false, precision = 2)
// DRAWING BUDGET: this script allocates NO line, label or box objects. Every visual is a plot, a
// fill, a bgcolor or ONE table created once and reused — and tables are not covered by the caps. So
// there is no max_*_count to declare, and nothing here can leak a drawing object, because nothing
// here creates one.

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

gMain = "ATR ESTIMATOR"
atrLen = input.int(14, "ATR period n (Wilder RMA)", minval = 1, maxval = 200, group = gMain, tooltip = "Period n of the Wilder-smoothed Average True Range.  TR_t = max(H_t - L_t, abs(H_t - C_prev), abs(L_t - C_prev))  and  ATR_t = ATR_prev + (TR_t - ATR_prev) / n, seeded with the simple mean of the first n true ranges. This is identical to the built-in ta.atr(n), so the line matches any other correctly implemented ATR bar for bar. n = 14 is Wilder's original and the fleet default. Smaller n gives a shorter effective memory and a noisier series; larger n is smoother and slower to register a change of regime.")
showAtrLine = input.bool(true, "Plot ATR(n) series", group = gMain, tooltip = "Plots the ATR(n) series itself. Disable to keep only the regime shading and the readout table.")

gRegime = "PERCENTILE NORMALIZATION"
useTod = input.bool(true, "Time-of-day conditioning (rank within slot k)", group = gRegime, tooltip = "ON: the current ATR is ranked only against ATR values observed in the SAME intraday slot k on previous sessions, where k = floor(minutes since exchange midnight / chart timeframe). Formally p_tod estimates P(X <= x given slot = k) over the last M sessions. OFF: it is ranked unconditionally over the last N bars, p_plain estimating P(X <= x), which is what an ordinary volatility percentile computes. These are different estimators and they disagree: on 745,589 rated 15m bars (ES and NQ, 2010-2026) they assign a different one of the five bands on 66.3% and 67.4% of bars. A same-sample-size control with the slot structure destroyed disagrees on only 29.0% and 29.1%, so roughly 37-38 percentage points of that is attributable to time of day rather than to estimator noise.")
todSessions = input.int(20, "Slot sample depth M (sessions)", minval = 5, maxval = 60, group = gRegime, tooltip = "Sample depth M for the conditional estimate: how many previous observations of slot k are retained. The percentile is quantised to 1/M, so M = 20 resolves to 5 percentile points, and the standard error of a proportion near the median is about sqrt(0.25/20) = 0.112. Larger M is a lower-variance estimate but a longer memory, so it is slower to accept that the market's character has genuinely changed. Ranking begins once a slot holds at least 10 observations; until then the unconditional percentile is used and the readout says so.")
plainBars = input.int(480, "Unconditional window N (bars)", minval = 60, maxval = 2000, group = gRegime, tooltip = "Window N for the unconditional estimate over the last N closed bars, ignoring time of day. N = 480 is about five sessions on a 15-minute chart. This is the figure shown beside the conditional one so the two can be compared directly, and it is the fallback while a slot is still filling. Note that the two estimators use very different sample sizes (N against M), which is precisely why the raw disagreement between them needs a control before it means anything.")

gStability = "STATE PUBLICATION (hysteresis + dwell)"
hystPts = input.float(5.0, "Hysteresis margin delta-p (percentile pts)", minval = 0.0, maxval = 25.0, step = 0.5, group = gStability, tooltip = "Hysteresis margin delta-p. A published state leaves band b only when the percentile clears that band's boundary by delta-p: upward requires p > top(b) + delta-p, downward requires p < bottom(b) - delta-p. Without it, a percentile resting on an edge alternates between two states bar after bar, which is the false-state-flip problem. delta-p = 5 means the reading must move a full 5 percentile points past the edge. Set it to 0 to see the raw band assignment.")
dwellBars = input.int(2, "Dwell D (confirmed bars)", minval = 1, maxval = 20, group = gStability, tooltip = "Dwell D. After hysteresis, a candidate state must persist for D consecutive CLOSED bars before it is published, so an excursion shorter than D never appears. D and delta-p suppress different things and compose: delta-p removes boundary chatter, D removes brief genuine excursions. D = 1 publishes every change immediately. The cost is explicit: up to D bars of delay, traded for stability.")

gTrend = "FIRST DIFFERENCE (dATR/dt)"
slopeBack = input.int(5, "Difference lag L (bars)", minval = 1, maxval = 100, group = gTrend, tooltip = "Lag L for the first difference. The expansion read is the relative change r = (ATR_t - ATR_at_t_minus_L) / ATR_at_t_minus_L, the discrete slope of the level over L bars. This is the second half of the question and it is independent of the first: a market can sit in COMPRESSED and be EXPANDING, or in EXPANDED and be CONTRACTING. Larger L measures a longer sweep and reacts later.")
slopeDead = input.float(5.0, "Deadband epsilon (% of ATR)", minval = 0.0, maxval = 50.0, step = 0.5, group = gTrend, tooltip = "Deadband epsilon on the first difference: the state is EXPANDING when r > epsilon, CONTRACTING when r < -epsilon, and STABLE otherwise, where r is the relative change over lag L. Without a deadband r is almost never exactly zero, so essentially every bar reads as one or the other and the state carries no information. epsilon = 5% means the ATR must move more than a twentieth of its own value across L bars to count.")

gPanel = "READOUT"
showPanel = input.bool(true, "Show readout table", group = gPanel, tooltip = "The readout table: ATR in points, ticks and percent of price, the position-scaled money value, the published regime state, the first-difference state, and BOTH percentile estimates side by side, so the conditional and unconditional readings can be compared directly rather than taken on trust.")
panelPos = input.string("Top right", "Table anchor", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gPanel, tooltip = "Where the readout table is anchored within the indicator pane. Move it if it overlaps something you need to read.")
compact = input.bool(false, "Compact mode (reduced rows)", group = gPanel, tooltip = "Reduces the table to three rows for small screens: ATR in points, the published regime state, and the first-difference state. Also steps the font down one size.")
showShading = input.bool(true, "Shade pane by regime state", group = gPanel, tooltip = "Tints the pane background by the published regime state, so the ATR series is read against its own conditional distribution rather than as a bare number. This is what answers whether the current reading is large for this instrument at this hour. Colour encodes regime only, never direction.")
units = input.int(1, "Position size q (units)", minval = 1, maxval = 100000, group = gPanel, tooltip = "Position size q for the money row, which evaluates ATR_t * syminfo.pointvalue * q and is labelled in syminfo.currency. Because the multiplier comes from the instrument, this reads currency per contract on a future and currency per share on a stock with nothing to configure. It is arithmetic on a number you typed: it is not connected to any account, broker or position, and it is not a sizing recommendation.")

// NOTE: there is deliberately no theme input here. The design kit below emits its own `teKitDark`
// under the APPEARANCE group, and every colour in this file reads from it. A product that added a
// second theme switch would give the reader two controls for one decision.

// ════════════════════════════════ THE ENGINE ════════════════════════════════
//
// A transliteration of daemons/sim/te-vol/te-vol.mjs. Read that file for the reasoning; this one is
// the same algorithm in Pine's vocabulary.

// ── the band edges, in ONE place ──────────────────────────────────────────────────────────────────
// Spelled once as a function rather than as five literals at five call sites, because a band edge
// that appears twice is a band edge that will eventually differ from itself.
f_bandOf(float p) =>
    na(p) ? -1 : p <= 0.20 ? 0 : p <= 0.40 ? 1 : p <= 0.60 ? 2 : p <= 0.80 ? 3 : 4

f_bandTop(int i) =>
    i == 0 ? 0.20 : i == 1 ? 0.40 : i == 2 ? 0.60 : i == 3 ? 0.80 : 1.01

f_bandName(int i) =>
    i == 0 ? "COMPRESSED" : i == 1 ? "SUBDUED" : i == 2 ? "BASELINE" : i == 3 ? "ELEVATED" : i == 4 ? "EXPANDED" : "—"

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
// Values strictly below, plus half the ties, over n — the mid-rank convention, so a flat history
// reads 0.5 rather than 1.0.
//
// 🔴 THE GUARD THAT MATTERS: `for i = 0 to n - 1` with n == 0 becomes `for i = 0 to -1`, and Pine
// does NOT skip that loop — it counts DOWN, runs once at i = 0, and reads an element that is not
// there. That is RE10040, and this repo has shipped it once before in a table-row loop that compiled
// 0/0 and crashed on a chart. So the loop is only ever entered under `n > 0`, and every index is
// bounded by the caller's own count rather than by the array's allocated size.
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

// ── the time-of-day axis ──────────────────────────────────────────────────────────────────────────
// The slot is the bar's position in the trading day, in units of the chart's own timeframe, so the
// same code gives 96 slots on a 15-minute chart and 288 on a 5-minute one.
//
// 🔴 IT ANCHORS ON `syminfo.timezone` — THE INSTRUMENT'S OWN EXCHANGE TIMEZONE — NOT ON A HARDCODED
// ONE. This matters more than it looks. An indicator that hardcodes New York is secretly a US
// product: it would carve a London stock's day at the wrong boundary, put a Tokyo session's open in
// the middle of a slot, and shift every bucket by a whole hour twice a year for any exchange whose
// daylight-saving dates differ from America's. Going through the exchange's own zone means the day
// is divided the way THAT market's participants actually experience it, and the timezone database
// handles every daylight-saving rule instead of us.
//
// On a 24-hour instrument with no session boundary at all — spot crypto, say — the slots simply
// become clock hours in the exchange's zone, which is still the right axis: the question "is this
// much movement normal for this hour?" is meaningful whether or not a bell rings.
tfMin = math.max(1, math.round(timeframe.in_seconds() / 60))
slotCount = math.max(1, math.min(1440, math.round(1440 / tfMin)))

// The time-of-day layer needs a day to have slots in it. On a daily, weekly or monthly chart every
// bar is the same slot, so the comparison is vacuous — and on a very high intraday timeframe the
// per-slot sample fills too slowly to mean anything. In both cases the product does not guess: it
// falls back to the plain percentile and the panel SAYS it is doing so.
intradayOk = timeframe.isintraday and tfMin <= 240

dayMin = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
rawSlot = math.floor(dayMin / tfMin)
slot = math.max(0, math.min(slotCount - 1, rawSlot))

// ── state ─────────────────────────────────────────────────────────────────────────────────────────
var array<float> plainBuf = array.new_float(0)
var array<float> todBuf = array.new_float(slotCount * todSessions, na)
var array<int> todCnt = array.new_int(slotCount, 0)
var array<int> todAt = array.new_int(slotCount, 0)

var int bandIdx = -1
var int pubIdx = -1
var int pendIdx = -1
var int pendBars = 0
var int lastPubIdx = -1
// the percentile that produced the PUBLISHED band, held across the forming bar so the readout keeps
// showing the number the state was actually decided on rather than blanking between closes
var float pubPct = na

atr = ta.atr(atrLen)
atrPct = close > 0 ? atr / close : na

// ── rate, then append. In that order, always. ─────────────────────────────────────────────────────
// A bar is ranked against history that has already closed, and only then joins it. Reversed, every
// percentile would include the bar it is rating and the product would be reading its own answer.
float pPlain = na
float pTod = na
bool usedTod = false
float pState = na
bool changed = false

if barstate.isconfirmed and not na(atrPct)
    // --- rate ---
    int nPlain = array.size(plainBuf)
    if nPlain >= math.min(120, plainBars)
        pPlain := f_pctRank(plainBuf, 0, nPlain, atrPct)

    int base = slot * todSessions
    int nTod = array.get(todCnt, slot)
    if useTod and intradayOk and nTod >= 10
        pTod := f_pctRank(todBuf, base, nTod, atrPct)

    usedTod := not na(pTod)
    pState := usedTod ? pTod : pPlain

    // --- publish, with hysteresis then dwell ---
    if not na(pState)
        bandIdx := f_hystBand(pState, bandIdx, hystPts / 100.0)
        if pubIdx < 0
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

    // --- append: EVERY closed bar, whatever state was published ---
    // This is the anti-ratchet property. A threshold fed only by what it already passed climbs until
    // nothing can reach it; the state here is downstream of the history and never gates it.
    array.push(plainBuf, atrPct)
    if array.size(plainBuf) > plainBars
        array.shift(plainBuf)

    if array.size(todBuf) >= base + todSessions
        if nTod < todSessions
            array.set(todBuf, base + nTod, atrPct)
            array.set(todCnt, slot, nTod + 1)
            array.set(todAt, slot, (nTod + 1) % todSessions)
        else
            int at = array.get(todAt, slot)
            array.set(todBuf, base + at, atrPct)
            array.set(todAt, slot, (at + 1) % todSessions)

// ── expanding or contracting: the slope of the level, not the level ──────────────────────────────
atrBack = atr[slopeBack]
atrChg = not na(atrBack) and atrBack > 0 ? (atr - atrBack) / atrBack : na
trendWord = na(atrChg) ? "—" : atrChg > slopeDead / 100.0 ? "EXPANDING" : atrChg < -slopeDead / 100.0 ? "CONTRACTING" : "STABLE"

// ── the readouts: points, ticks, percent, money ───────────────────────────────────────────────────
// All four read the instrument's own metadata, so they are correct on a future, a stock, a crypto
// pair or an FX cross with no configuration. `syminfo.pointvalue` is the contract multiplier on a
// future and 1 on a stock, which is exactly right in both cases — the same arithmetic gives dollars
// per contract on ES and dollars per share on AAPL.
//
// ATR as a PERCENT OF PRICE is the row that makes the number portable at all: 14 points means
// nothing across instruments, 0.24% means the same thing everywhere. That is the "cross-instrument
// normalization" half of the job.
atrTicks = syminfo.mintick > 0 ? atr / syminfo.mintick : na
atrPctDisp = na(atrPct) ? na : atrPct * 100.0
atrMoney = atr * syminfo.pointvalue * units

// what one unit of this instrument is CALLED, so the panel never says "contract" on a stock
unitWord = syminfo.type == "futures" ? "contract" : syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" ? "share" : syminfo.type == "crypto" ? "coin" : syminfo.type == "forex" ? "lot" : "unit"
unitWordPlural = unitWord + "s"

// ════════════════════════════════ WHAT IS DRAWN ════════════════════════════════

// ── the regime colour ramp ────────────────────────────────────────────────────────────────────────
// Every colour comes from the design kit by NAME, and the choice of which token means which band is
// a decision worth stating plainly:
//
//   NO BAND USES TE_BULL OR TE_BEAR. Those encode direction, and this product's whole reason to
//   exist is that volatility is not direction. A green "low volatility" and a red "high volatility"
//   would reintroduce exactly the confusion the classic ATR causes.
//
//   NO BAND USES BRAND GOLD. Doc 29 §9.2 is verbatim about it: gold is not good, bullish, actionable
//   or high confidence. It is brand and selection only.
//
//   So the ramp is a RISK-CONTEXT ramp, not a quality ramp: dormant, then neutral structure, then
//   building, then caution. "Caution" at the top is a statement about how wide your stop has to be,
//   not a prediction and not a judgment about the market being bad.
f_bandColor(int i) =>
    i == 0 ? TE_INACTIVE : i == 1 ? TE_STRUCTURE_2 : i == 2 ? TE_STRUCTURE : i == 3 ? TE_DEVELOPING : i == 4 ? TE_CAUTION : TE_TEXT_MUTED

bandCol = f_bandColor(pubIdx)

// the classic line, unchanged and still the main thing on the pane
plot(showAtrLine ? atr : na, "ATR(n)", color = bandCol, linewidth = TE_W_STANDARD)

// the context behind it — this is what turns one number into a reading
bgcolor(showShading and pubIdx >= 0 ? color.new(bandCol, 92) : na, title = "Regime shading")

// ── the data window channels ─────────────────────────────────────────────────────────────────────
// display.data_window rather than display.none on purpose: none of these should draw on the pane,
// but all of them should be readable in the Data Window and bindable by another script.
plot(atrTicks, "ATR / mintick", display = display.data_window)
plot(atrPctDisp, "ATR / close (%)", display = display.data_window)
plot(atrMoney, "ATR * pointvalue * q", display = display.data_window)
plot(na(pTod) ? na : pTod * 100.0, "p | slot k", display = display.data_window)
plot(na(pPlain) ? na : pPlain * 100.0, "p unconditional", display = display.data_window)
plot(pubIdx, "Regime band index (0-4)", display = display.data_window)
plot(na(atrChg) ? na : atrChg * 100.0, "dATR/dt (%)", display = display.data_window)

// ── the panel ─────────────────────────────────────────────────────────────────────────────────────
f_panelPos(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

f_num(float v, int dp) =>
    na(v) ? "—" : str.tostring(v, dp == 0 ? "#" : dp == 1 ? "#.#" : "#.##")

// ── THE HOVER LAYER, AND IT IS A TEACHING LAYER ───────────────────────────────────────────────────
// Every row of this panel explains itself when you hover it. Both cells of a row carry the SAME
// tooltip, so the whole row is a hover target rather than a half-inch of text — you should not have
// to aim.
//
// THE SCHEMA IS HIS, RULED 2026-09-23 11:28 and emitted by the design kit as `teTeach`, which takes
// the four clauses as four arguments so a product cannot quietly ship three of them:
//
//     what it reads  ·  how it is computed  ·  why that information matters  ·  what it does not tell you
//
// Plain language opens and the maths is second — "language all users will understand" — but the
// maths is never dropped, because a formula a reader can check is evidence and one they cannot is
// decoration. Nor is the last clause: a readout that explains what it is and hides what it cannot do
// is the thing that makes people trust a number too much.
//
// ⚠️ NOT "why it WORKS". He was offered that framing and rejected it: it presupposes that it works,
// which is an efficacy claim, and it is the same line he drew at 00:59 when he ruled that the motto
// is a mission and never a per-product performance claim. "Why that information matters" says which
// DECISION the number changes, and stops there.
//
// 🕹️ AND THE CLAUSES ARE COMPOSED AT RUNTIME, WHICH IS THE WHOLE POINT. Pine has no click handlers
// and no buttons, so "interactive" cannot mean what it means in a browser. It can mean this: a
// tooltip is a STRING BUILT ON THIS BAR, so it says "the ATR over 14 bars is 7.10 points" rather
// than "the Average True Range is a measure of volatility". The lesson is about the chart in front
// of the reader instead of about the concept — and it is free, because every number in it was
// already computed for the row it sits beside.
//
// MEASURED, because the received wisdom here is half right: the tooltip TEXT is about one token
// however long it is, but each hover TARGET costs about six, since Pine re-spells every argument at
// every call site. The sixteen cells cost 96 tokens, 2,692 -> 2,788; the teaching rewrite is
// measured in the build log rather than guessed at here.
// ⇒ Write the words freely. Count the targets.

var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    txtSize = compact ? size.small : size.normal

    tipRegime = teTeach(
      "Right now this market reads " + f_bandName(pubIdx) + (na(pubPct) ? "" : ", on a percentile of " + f_num(pubPct * 100.0, 0) + " out of 100") + " — that is how wide its recent range is compared with its own history, not with any other market's.",
      "The band is the quintile of p: 0-20 COMPRESSED, 20-40 SUBDUED, 40-60 BASELINE, 60-80 ELEVATED, 80-100 EXPANDED, where p is the conditional percentile when one is available and the unconditional one otherwise. Leaving a band first costs a margin of " + f_num(hystPts, 1) + " percentile points, and the new band must then hold for " + str.tostring(dwellBars) + " closed bars before it is published.",
      "Distance means different things in different conditions. The same number of points is a wide move in COMPRESSED and an ordinary one in EXPANDED, so this is the row that tells you which market you are actually looking at today.",
      "It does not forecast, and it is not a direction. EXPANDED means the recent range was wide for this hour; it does not mean the range will stay wide, or that price is going anywhere in particular.")

    tipAtr = teTeach(
      "Right now the average bar covers " + f_num(atr, 2) + " points over the last " + str.tostring(atrLen) + " bars — the typical full range of one bar, including any gap left from the previous close.",
      "TR = max(high - low, abs(high - prev close), abs(low - prev close)), and ATR = prev ATR + (TR - prev ATR) / " + str.tostring(atrLen) + ", Wilder's smoothing. This is the same series as the built-in ta.atr, drawn unchanged.",
      "It is the unit this instrument moves in. A distance on the chart is worth reading as a multiple of it rather than as a number of points, because points mean completely different things on different markets.",
      "On its own it carries no context: whether " + f_num(atr, 2) + " is large depends on the instrument and on the hour, which is exactly what the rows below add.")

    tipSlope = teTeach(
      "Right now the level is " + trendWord + (na(atrChg) ? "" : ": the ATR has changed " + f_num(atrChg * 100.0, 1) + "% across the last " + str.tostring(slopeBack) + " bars") + ".",
      "r = (ATR now - ATR " + str.tostring(slopeBack) + " bars ago) / ATR " + str.tostring(slopeBack) + " bars ago. EXPANDING when r is above +" + f_num(slopeDead, 1) + "%, CONTRACTING when below -" + f_num(slopeDead, 1) + "%, STABLE in between. Without that deadband r is almost never exactly zero and the state would carry no information.",
      "How wide the range IS and which way it is CHANGING are two different questions, and this row answers the second one. A market can sit in COMPRESSED and be EXPANDING, which is the moment ranges begin widening before the band above has moved at all.",
      "It measures what the last " + str.tostring(slopeBack) + " bars did. It says nothing about the next one, and nothing about direction of price.")

    table.clear(panel, 0, 0, 1, 7)
    table.cell(panel, 0, 0, "ATR REGIME", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipRegime)
    table.cell(panel, 1, 0, f_bandName(pubIdx) + (na(pubPct) ? "" : "  p" + f_num(pubPct * 100.0, 0)), text_color = bandCol, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipRegime)

    table.cell(panel, 0, 1, "ATR(" + str.tostring(atrLen) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipAtr)
    table.cell(panel, 1, 1, f_num(atr, 2) + " pts", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipAtr)

    table.cell(panel, 0, 2, "dATR/dt (L=" + str.tostring(slopeBack) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipSlope)
    table.cell(panel, 1, 2, trendWord, text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipSlope)

    if not compact
        tipTicks = teTeach(
          "Right now the average bar covers " + f_num(atrTicks, 0) + " of this instrument's minimum price increments.",
          "ATR / syminfo.mintick, where the tick size " + str.tostring(syminfo.mintick) + " is read from the symbol rather than configured.",
          "The tick is the unit an order is actually placed in, so this is the row that converts a volatility reading into the resolution you have to work at.",
          "It is a unit conversion of the row above, not a second measurement. It carries no information the ATR did not already carry.")

        tipPct = teTeach(
          "Right now the average bar covers " + f_num(atrPctDisp, 2) + "% of the current price.",
          "100 * ATR / close, recomputed every bar from the same ATR shown above.",
          "This is the row that makes the number portable: " + f_num(atr, 2) + " points means nothing across markets, while " + f_num(atrPctDisp, 2) + "% means the same thing on an index future, a stock and an FX cross.",
          "It says how wide the range is relative to price. It does not say whether that is expensive, and it is not comparable across instruments with very different tick structures without care.")

        tipMoney = teTeach(
          "Right now one average bar is worth " + syminfo.currency + " " + f_num(atrMoney, 2) + " at the " + str.tostring(units) + " " + (units == 1 ? unitWord : unitWordPlural) + " you typed in the settings.",
          "ATR * syminfo.pointvalue * q, where the multiplier " + str.tostring(syminfo.pointvalue) + " and the currency both come from the instrument, so this reads as currency per contract on a future and currency per share on a stock.",
          "Points and ticks stay abstract until they are money. This is the row that turns a volatility reading into the figure you would actually feel, which is the form most people can judge.",
          "It is arithmetic on a number you entered. It is not connected to any account, broker or position, it does not know your risk, and it is not a sizing recommendation.")

        table.cell(panel, 0, 3, "ATR / mintick", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTicks)
        table.cell(panel, 1, 3, f_num(atrTicks, 0), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTicks)

        table.cell(panel, 0, 4, "ATR / close", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPct)
        table.cell(panel, 1, 4, f_num(atrPctDisp, 2) + "%", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPct)

        // the instrument names its own unit, so this row reads "1 contract" on ES and "1 share" on
        // AAPL without a setting
        table.cell(panel, 0, 5, str.tostring(units) + " " + (units == 1 ? unitWord : unitWordPlural), text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipMoney)
        table.cell(panel, 1, 5, syminfo.currency + " " + f_num(atrMoney, 2), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipMoney)

        // BOTH percentiles, side by side, so the reader can see them disagree. That disagreement IS
        // the product, and hiding the comparison would be hiding the evidence for it.
        //
        // And when the time-of-day layer is NOT available — a daily chart, a timeframe too high, or
        // a slot still filling — the row says which of those it is rather than showing a number that
        // looks like the same measurement. A fallback the reader cannot see is a lie by omission.
        todLabel = not intradayOk ? "needs intraday" : not useTod ? "off" : na(pTod) ? "filling" : f_num(pTod * 100.0, 0)

        tipTod = teTeach(
          not intradayOk ? "This row needs an intraday chart. On a daily or higher timeframe there is no time of day to condition on, so it reports that instead of a number." : not useTod ? "This row is switched off in the settings, so the band above is being decided on the unconditional percentile instead." : na(pTod) ? "This slot of the day is still filling — it needs ten observations before it will rank anything." : "Right now the ATR sits above " + f_num(pTod * 100.0, 0) + "% of the readings seen at this same time of day over the last " + str.tostring(todSessions) + " sessions.",
          "The day is carved into slots one chart timeframe wide, anchored on the exchange's own timezone, and the last " + str.tostring(todSessions) + " observations of THIS slot are kept and ranked: it estimates P(X <= x given slot k). The estimate is quantised to 1/" + str.tostring(todSessions) + ", so it resolves to " + f_num(100.0 / todSessions, 0) + " percentile points at a time.",
          "Markets have a shape to the day — an open is not a lunch hour. Ranking the current reading against the same clock time is what separates \"this is a big move\" from \"this is 10:00\", and it is the one thing the classic single ATR line cannot tell you.",
          "It is a ranking, not a level and not a forecast. A high reading says this hour is busier than this hour usually is; it does not say the market is trending, or which way.")

        table.cell(panel, 0, 6, "p | slot k  (M=" + str.tostring(todSessions) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTod)
        table.cell(panel, 1, 6, todLabel, text_color = usedTod ? TE_TEXT : TE_TEXT_MUTED, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipTod)

        tipPlain = teTeach(
          na(pPlain) ? "Still filling — this needs " + str.tostring(plainBars) + " closed bars before it will rank anything." : "Right now the ATR sits above " + f_num(pPlain * 100.0, 0) + "% of the last " + str.tostring(plainBars) + " bars, ignoring time of day entirely — and the row above says " + (na(pTod) ? "nothing yet" : f_num(pTod * 100.0, 0)) + ".",
          "The same ranking over the last " + str.tostring(plainBars) + " closed bars with no conditioning: it estimates P(X <= x). This is what an ordinary volatility percentile computes, and it is shown so the two can be compared directly rather than taken on trust.",
          "Watching these two disagree is the product. When they are far apart, the reading you would have got from a plain percentile was telling you about the time of day rather than about the market.",
          "The two use very different sample sizes, " + str.tostring(plainBars) + " against " + str.tostring(todSessions) + ", so some disagreement is estimator noise. On ES and NQ a same-sample-size control attributed roughly 37 of the 66 percentage points of disagreement to time of day itself; the rest was not.")

        table.cell(panel, 0, 7, "p uncond. (N=" + str.tostring(plainBars) + ")", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPlain)
        table.cell(panel, 1, 7, na(pPlain) ? "filling" : f_num(pPlain * 100.0, 0), text_color = usedTod ? TE_TEXT_MUTED : TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipPlain)

    table.set_position(panel, f_panelPos(panelPos))

// ════════════════════════════════ ALERTS ════════════════════════════════
//
// STATE-CHANGE ONLY, and on CLOSED BARS ONLY. Never an every-bar alert: a volatility tool that
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
// you later change the ATR length or the dwell, the running alert keeps firing on the old settings
// until you recreate it. That is TradingView's behaviour for every script, not this one's.

alertcondition(changed, title = "ATR regime band changed", message = "ATR regime band changed on {{ticker}} {{interval}} — the published volatility percentile has moved to a new band. See the readout for the new state.")

if changed and barstate.isconfirmed
    alert("TE ATR-R — " + syminfo.ticker + " " + timeframe.period + " is now " + f_bandName(pubIdx) + " and " + trendWord + ". ATR " + f_num(atr, 2) + " (" + f_num(atrPctDisp, 2) + "% of price)" + (usedTod ? ", ranked against this time of day." : ", ranked against recent bars."), alert.freq_once_per_bar_close)

// ── the rail, last line, where it is never edited away by accident ───────────────────────────────
// Decision support. This is not financial advice, and nothing here is a recommendation to buy or
// sell anything.
````
