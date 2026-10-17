# TE Position Size & Risk Contract Count Stop Distance and Risk

- url: https://www.tradingview.com/script/BbQ1KLZ1-TE-Position-Size-Risk-Contract-Count-Stop-Distance-and-Risk/
- type: indicator
- pine_id: PUB;699c6686d1934703bfb47e914baff44c
- version: 1.0

## Description

TE Position Size & Risk answers one specific question:

How many units fit this stop and this risk budget?

Set an entry and stop directly on the chart. The indicator measures the distance between them, reads the instrument's own tick size and point value, applies the risk budget and returns the number of whole units that fit.

https://www.tradingview.com/x/KavG5hRP/

ENTRY, STOP AND DIRECTION

Entry E and Stop S are draggable price inputs.

Direction is inferred automatically:

stop < entry = long
stop > entry = short
stop = entry = no plan

There is no separate long/short switch that can contradict the prices drawn on the chart.

Stop distance is:

d = |E - S|

The same distance is also reported in ticks and as a percentage of entry.

POSITION SIZE

Risk per unit is:

riskPerUnit = d × pointValue + cost

Position size is then:

units = min(floor(R / riskPerUnit), cap)

R is the risk budget entered by the user.

The calculation always rounds DOWN to whole units. Rounding upward could produce a position whose calculated risk exceeds the budget.

https://www.tradingview.com/x/DQmPQQBH/

INSTRUMENT-AWARE CALCULATION

There is no hardcoded table of futures contracts or stock symbols.

The indicator reads the symbol's own point value, tick size, currency and instrument type.

This allows the same sizing calculation to adapt to futures, shares and other supported instruments without manually selecting a contract specification.

RISK BUDGET

The budget can be entered as either:

Fixed amount

or

Percent of account

Percent mode calculates:

R = Account Size × Risk % / 100

Both values are manually entered. The indicator has no connection to a brokerage account and does not know the user's actual balance or existing exposure.

COSTS ARE INCLUDED

Commission and slippage allowance can be entered as a round-turn cost per unit.

That cost is included directly in the denominator:

riskPerUnit = stopDistance × pointValue + cost

This matters because ignoring transaction costs can produce a larger calculated position than the stated budget supports.

https://www.tradingview.com/x/EO8XTkHY/

ACTUAL PLANNED RISK

Because position size must be rounded down to whole units, the amount actually at risk may be lower than the original budget.

plannedRisk = units × riskPerUnit

unusedBudget = R - plannedRisk

The panel displays both values rather than implying that the full risk budget is necessarily being used.

If even one unit exceeds the budget, the indicator reports BELOW ONE UNIT and shows what one unit would risk instead of displaying zero as though it were a usable position size.

MAXIMUM SIZE CAP

A user-defined maximum-unit cap can also be applied:

units = min(floor(R / riskPerUnit), cap)

The readout identifies whether the risk budget or the maximum-unit cap actually determined the final position size.

TARGET AND REWARD/RISK

A target is optional.

When supplied:

Gross R = |T - E| / d

The indicator also calculates a cost-adjusted reward multiple using the entered transaction costs.

This allows the chart to display both the geometric reward/risk relationship and the same plan after its entered costs are accounted for.

https://www.tradingview.com/x/adtjg09X/

ON-CHART READOUT

The panel can display:

Position size
Risk at stop
Stop distance
Risk budget
Risk per unit
Binding constraint
Unused budget
Gross and cost-adjusted reward multiple

Entry, stop and target can also be drawn directly on the chart with hover-enabled explanations.

WHAT IT DOES NOT DO

This is a calculator, not a trading system.

It does not recommend an entry.
It does not recommend a stop.
It does not recommend a risk percentage.
It does not recommend a position size independently of the inputs supplied.
It does not manage an open trade.
It does not connect to a broker or account.
It does not measure the probability of reaching a target or stop.

The risk calculation also assumes execution at the specified stop price. Gaps, slippage and fast markets can produce losses greater than the calculated figure.

TE Position Size & Risk converts a user-defined entry, stop and risk budget into transparent position-sizing arithmetic directly on the chart.

Trader's Edge

Financial Disclaimer: For educational and informational purposes only. Nothing in this indicator constitutes financial, investment or trading advice, or a recommendation to buy, sell or hold any instrument. Position sizing calculations are based entirely on user-supplied inputs and assumptions. Actual losses may exceed calculated risk because of slippage, gaps, fees, liquidity and market conditions.

## Source Code

````pine
//@version=6
// TE POSITION SIZE & RISK — CONTRACT COUNT FROM STOP DISTANCE AND RISK BUDGET  (catalog TE-005)
// This source code is subject to the terms of the TRADERS EDGE license — all rights reserved. Distributed on
// TradingView as a protected / Public; not for resale, or reverse engineering.
// THE QUESTION: how many units fit this stop and this risk budget?
//
// Position sizers are the most-cloned script category on any platform, and they get four things
// wrong often enough that being right about them is the entire product:
//
//   ① THEY HARDCODE THE INSTRUMENT. A table of "this future is fifty a point" works until someone
//      loads it on gold, on a share, or on a micro contract — at which point it is confidently wrong
//      rather than silent. There is NO instrument table in this script. Every figure comes from the
//      symbol: the contract multiplier, the tick size, the currency and the instrument type. A test
//      reads the source and fails if a ticker is ever hardcoded back into it.
//   ② THEY ROUND THE WRONG WAY. Any rounding that is not DOWNWARD puts you over the budget you just
//      typed in. This floors, always — with a guard against binary floating point rendering an exact
//      division as 2.9999999996 and quietly costing you a unit you could afford.
//   ③ THEY PRINT 0 AS THOUGH IT WERE A SIZE. A stop too wide for the budget is not "size zero", it
//      is a plan that does not fit. So it says BELOW ONE UNIT and shows what ONE unit would risk —
//      the number you actually need in order to decide what to change.
//   ④ THEY IGNORE COSTS. Commission and slippage are part of what a position can lose, so they go in
//      the denominator. Leaving them out overstates the size that fits a budget, which is the
//      direction that hurts.
//
// HOW YOU USE IT: the entry and the stop are PRICE inputs, so you place them by clicking on the
// chart and drag them afterwards. The trade's DIRECTION is not a setting — it is inferred from where
// the stop sits relative to the entry, because a direction you can set independently is a direction
// that can contradict your own levels. A target is optional; give one and it reports reward both
// gross and net of the costs you entered, which are not the same number.
//
// WHAT IT REPORTS: the number of units, what that position actually risks after rounding down, how
// much of the budget is left over, whether the BUDGET or your own CAP bound the answer, the stop
// distance in points, in ticks and as a percent of entry, and the reward multiple if a target is
// set.
//
// WHAT IT DELIBERATELY DOES NOT DO — this is the point, not a limitation:
//   • it is NOT CONNECTED TO ANYTHING. No account, no broker, no position, no order. Every number
//     here is arithmetic on a number you typed. It does not know what you hold or what you risked
//     today, and it cannot.
//   • it never recommends a size, a risk percentage or a stop. "How many units fit THIS budget and
//     THIS stop" is a different question from "what should I do", and only the first one has an
//     arithmetic answer.
//   • it carries no trade management: no trailing, no scaling, no breakeven rule, no instruction to
//     move anything. Those belong to a different tool.
//   • it makes no claim about outcomes. Correct arithmetic is not an edge, and nothing here says or
//     implies that sizing this way produces any particular result.
//
// HOW IT DECIDES: there is no state and no history in this script at all — every output is a pure
// function of the current inputs and the symbol's own metadata. Nothing accumulates, nothing warms
// up, and there is nothing that could repaint. It contains ZERO request.security calls. The drawing
// objects are allocated once and moved thereafter, so the count is fixed and a drawing leak is
// structurally impossible rather than merely unlikely.
//
// LOGIC SOURCE OF TRUTH: daemons/sim/te-size/te-size.mjs, pinned by te-size.test.mjs — the four
// defects above each have a test that would fail if someone "simplified" the code back into them,
// plus an invariant swept across 900 combinations of stop distance, budget and cost asserting that
// the planned risk NEVER exceeds the budget. A further test reads this Pine and asserts it spells
// every user-visible state exactly as the mirror does. If the two ever disagree, the mirror is right.
//
// ── IP PROVENANCE ───────────────────────────────────────────────────────────────────────────────
// PUBLIC MATH — sizing a position from a risk budget and a stop distance is elementary arithmetic
//   and is nobody's intellectual property.
// REUSED from our own work — the floor(budget / (distance x multiplier)) form with its floating-point
//   guard, and the rule that a size below one unit reports what one unit would risk rather than "0",
//   come from daemons/sim/apollo-one-v4/sizing.mjs in this repository.
//   ⚠️ Deliberately NOT reused from it: its hardcoded instrument table, its micro-contract
//   substitution, its daily-loss stand-down and its post-loss halving. Those are one desk's private
//   behaviour, and two of them are trade-management instructions this catalog does not ship.
// INDEPENDENTLY DERIVED — the cost-inclusive denominator, the readout naming which constraint bound
//   the answer, and the net-of-cost reward multiple. Derived from the behavioural spec at
//   docs/findings/2026-09-23-te-005-position-size-and-risk-spec.md, committed before any line of
//   this file existed. No third-party script was read, ported or paraphrased for any of it.
// ORIGINAL — the TE design kit block below, generated from daemons/forge/design-kit.mjs.
// LEFT OUT RATHER THAN GUESSED AT — any suggested risk percentage, any "recommended" cap, and any
//   volatility-scaled or Kelly sizing. Each of those is a claim about what you SHOULD do, and none
//   of them is measured.
//
// Decision support only. No order is placed, no target is promised, no outcome is claimed.

indicator("TE Position Size & Risk — Contract Count from Stop Distance and Risk Budget", "TE SIZE-R", overlay = true, max_lines_count = 10, max_labels_count = 10)

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
teZone(color c, string band) =>
    color.new(c, band == "context" ? 95 : band == "structure" ? 92 : band == "plan" ? 89 : band == "urgent" ? 82 : 92)

// THE TE TAG — the house label. One state, one number, one separator, monospace, and a
// tooltip that is not optional. Everything else belongs in the hover layer, not on the chart.
// `style_label_left` puts the tag's pointer ON the price, so it is attached, not floating.
teTag(int x, float px, string state, string value, color plate, color ink, string tip) =>
    label.new(x, px, value == "" ? state : state + "  ·  " + value, style = label.style_label_left, color = plate, textcolor = ink, size = size.small, text_font_family = font.family_monospace, textalign = text.align_left, tooltip = tip)

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

gPlan = "THE PLAN (click or drag on the chart)"
entryPx = input.price(0.0, "Entry price E", group = gPlan, confirm = true, tooltip = "The price you intend to enter at. This is a PRICE input, so you place it by clicking on the chart when you add the script and you can drag it afterwards; every figure below recomputes as you move it. Leave it at 0 and nothing is computed, because there is no plan to size. The trade's direction is not a separate setting: it is inferred from whether the stop sits below E (long) or above E (short), so the two can never contradict each other.")
stopPx = input.price(0.0, "Stop price S", group = gPlan, confirm = true, tooltip = "The price at which the plan is wrong. Also a draggable price input. The stop distance is d = abs(E - S), in the instrument's own price units, and it is the denominator of everything below. If S equals E there is no distance to size and the script says NO PLAN rather than dividing by zero.")
targetPx = input.price(0.0, "Target price T (0 = none)", group = gPlan, tooltip = "Optional. Give a target and the reward multiple is reported two ways: gross, abs(T - E) / d, which is the number everyone quotes, and net of the round-turn costs you entered below, which is the one that is true. They are not the same number. A target that is not beyond E in the trade's own direction - below E on a long, above E on a short - is reported as an input error rather than quietly producing a negative multiple.")

gRisk = "RISK BUDGET"
riskMode = input.string("Fixed amount", "Risk budget mode", options = ["Fixed amount", "Percent of account"], group = gRisk, tooltip = "How the budget R for this one trade is stated. Fixed amount uses the figure below directly. Percent of account computes R = A * r / 100 from the account size A and percent r below. Percent mode exists because it is how most people think about risk, NOT because this script knows anything about an account: both A and r are numbers you type, and nothing here is connected to a broker.")
riskFixed = input.float(500.0, "Fixed risk R (account currency)", minval = 0.0, step = 50.0, group = gRisk, tooltip = "The budget R for this trade in your account currency, used when the mode above is Fixed amount. This is the most the position is intended to lose if the stop is reached, including the costs you enter below. It is a number you choose; this script has no opinion about what it should be and deliberately suggests nothing.")
acctSize = input.float(50000.0, "Account size A", minval = 0.0, step = 1000.0, group = gRisk, tooltip = "The account size A used by Percent of account mode, in your account currency. Typed by you and stored only in this script's settings. It is never read from anywhere, and no part of this script can verify it.")
riskPct = input.float(1.0, "Risk percent r (% of A)", minval = 0.0, maxval = 100.0, step = 0.1, group = gRisk, tooltip = "The percent r of account size A to risk on this trade, giving R = A * r / 100. The default of 1 percent is the most commonly cited figure in trading literature and is offered as a starting point only: it is not a recommendation, it is not derived from any measurement, and no percentage has been shown by this script or anyone else to be correct for you.")

gCosts = "COSTS"
costPerUnit = input.float(0.0, "Round-turn cost per unit (currency)", minval = 0.0, step = 0.25, group = gCosts, tooltip = "Commission plus any slippage allowance, in account currency, for ONE unit in and out. It is added to the per-unit risk: riskPerUnit = d * pointValue + cost, so it goes in the DENOMINATOR of the size calculation. Leaving costs out overstates the size that fits a budget, which is the direction that hurts. On a 10-point stop on a 50-per-point contract, 6 of cost turns 500 per unit into 506 - which is enough to remove the fourth unit from a 2,000 budget.")

gLimits = "LIMITS"
maxUnits = input.int(100, "Maximum units cap", minval = 1, group = gLimits, tooltip = "Your own ceiling on position size, applied AFTER the budget division rather than instead of it. That ordering is what lets the readout tell you WHICH constraint produced the answer: if the cap bound it, the panel says CAPPED, and you know that a tighter stop would not have changed the number. A cap that happens to equal the budget's answer is not reported as binding.")

gRender = "ON-CHART PLAN"
showLines = input.bool(true, "Draw entry, stop and target", group = gRender, tooltip = "Draws a horizontal line and a hover-enabled tag at each of the three prices. Every tag explains the number it sits on. Turn this off to keep only the readout table.")
extendLines = input.bool(true, "Extend lines to the right", group = gRender, tooltip = "Extends the three plan lines to the right edge of the chart so they stay visible as price moves away from them. Off draws them only across the recent bars.")

gPanel = "READOUT"
showPanel = input.bool(true, "Show readout table", group = gPanel, tooltip = "The readout table: the position size, what it actually risks after rounding down, the unused budget, which constraint bound the answer, the stop distance in points, ticks and percent, and the reward multiples if a target is set.")
panelPos = input.string("Top right", "Table anchor", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gPanel, tooltip = "Where the readout table is anchored on the chart. Move it if it overlaps something you need to read.")
compact = input.bool(false, "Compact mode (reduced rows)", group = gPanel, tooltip = "Reduces the table to three rows for small screens: the size, what it risks, and the stop distance. Also steps the font down one size. The rows it hides are secondary readouts, not warnings, so nothing load-bearing disappears.")

// NOTE: there is deliberately no theme input here. The design kit above emits its own `teKitDark`
// under the APPEARANCE group, and every colour in this file reads from it.
//
// NOTE ALSO: there is deliberately no "direction" input. Asking for it separately would let the
// stated side disagree with the levels drawn on the chart, and when those two disagree the arithmetic
// is silently about a trade nobody intends to take.

// ════════════════════════════════ THE ENGINE ════════════════════════════════
//
// A transliteration of daemons/sim/te-size/te-size.mjs. Read that file for the reasoning; this one
// is the same arithmetic in Pine's vocabulary. A test in that directory reads THIS FILE and asserts
// every user-visible state below is spelled exactly as the mirror spells it.
//
// There is no `var` in this file and there is no history: every line is a pure function of the
// current inputs and the symbol's metadata. That is why there is no barstate.isconfirmed gate here —
// there is nothing whose value could differ between a forming bar and a closed one.

// ── the state words, in ONE place ─────────────────────────────────────────────────────────────────
STATE_NO_PLAN = "NO PLAN"
STATE_BELOW_ONE = "BELOW ONE UNIT"
STATE_CAPPED = "CAPPED"
STATE_SIZED = "SIZED"
STATE_TARGET_SIDE = "TARGET WRONG SIDE"

// ── the symbol tells us what it is. ① THERE IS NO INSTRUMENT TABLE. ───────────────────────────────
// `syminfo.pointvalue` is the contract multiplier on a future and 1 on a share, so ONE expression
// gives currency per contract on the first and currency per share on the second with nothing to
// configure. The same is true of the tick size, the currency and the instrument type below.
pv = syminfo.pointvalue
tick = syminfo.mintick
cur = syminfo.currency

f_unitWord(bool plural) =>
    string w = syminfo.type == "futures" ? "contract" : syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" ? "share" : syminfo.type == "crypto" ? "coin" : syminfo.type == "forex" ? "lot" : "unit"
    plural ? w + "s" : w

// ── the side is INFERRED, never asked for ────────────────────────────────────────────────────────
// A direction you can set independently is a direction that can contradict the levels you drew. So
// the stop's position relative to the entry IS the direction, and the two cannot disagree.
f_side(float e, float s) =>
    na(e) or na(s) or e <= 0 or s <= 0 or e == s ? 0 : s < e ? 1 : -1

side = f_side(entryPx, stopPx)
planSet = side != 0

// ── the budget ────────────────────────────────────────────────────────────────────────────────────
// Both numbers are typed by the user. A nonsense input yields zero rather than a NaN that would
// propagate silently through every figure below it.
rawBudget = riskMode == "Percent of account" ? acctSize * riskPct / 100.0 : riskFixed
budget = na(rawBudget) or rawBudget <= 0 ? 0.0 : rawBudget

// ── the distance ──────────────────────────────────────────────────────────────────────────────────
stopDist = planSet ? math.abs(entryPx - stopPx) : na
stopTicks = planSet and tick > 0 ? stopDist / tick : na
stopPct = planSet and entryPx > 0 ? stopDist / entryPx * 100.0 : na

// ── ④ COSTS GO IN THE DENOMINATOR ────────────────────────────────────────────────────────────────
// Commission and slippage are part of what the position can lose. Leaving them out overstates the
// size that fits a budget, and that is the direction that costs money.
cost = na(costPerUnit) or costPerUnit < 0 ? 0.0 : costPerUnit
perUnit = planSet and stopDist > 0 and pv > 0 ? stopDist * pv + cost : na

// ── ② FLOOR, NEVER ROUND ─────────────────────────────────────────────────────────────────────────
// The epsilon is not decoration: binary floating point routinely renders an exact division as
// 2.9999999996, and a bare floor would turn a budget that exactly covers three units into two. 1e-9
// is far below any meaningful fraction of a unit and far above the representation error.
wantUnits = not na(perUnit) and perUnit > 0 and budget > 0 ? math.floor(budget / perUnit + 0.000000001) : 0
units = math.min(wantUnits, maxUnits)

// which constraint produced the answer — because someone whose size is capped should know that a
// tighter stop would not have changed it
cappedByUser = units == maxUnits and wantUnits > maxUnits

plannedRisk = units >= 1 ? units * perUnit : na
unusedBudget = units >= 1 ? budget - plannedRisk : na

// ── the reward, gross and net, and they are not the same number ──────────────────────────────────
targetSet = not na(targetPx) and targetPx > 0
targetOk = targetSet and planSet ? (side == 1 ? targetPx > entryPx : targetPx < entryPx) : false
reward = targetOk ? math.abs(targetPx - entryPx) : na
rGross = targetOk and stopDist > 0 ? reward / stopDist : na
rNet = targetOk and units >= 1 and not na(plannedRisk) and plannedRisk > 0 ? (reward * pv * units - cost * units) / plannedRisk : na

// ── the one published state ───────────────────────────────────────────────────────────────────────
// ③ ZERO IS NOT A SIZE. A stop too wide for the budget is a plan that does not fit, and the useful
// output is what ONE unit would cost, so the reader can see BY HOW MUCH rather than staring at a 0.
sizeState = not planSet ? STATE_NO_PLAN : targetSet and not targetOk ? STATE_TARGET_SIDE : units < 1 ? STATE_BELOW_ONE : cappedByUser ? STATE_CAPPED : STATE_SIZED

// ── formatting ────────────────────────────────────────────────────────────────────────────────────
f_money(float v) =>
    na(v) ? "—" : (v < 0 ? "-" : "") + cur + " " + str.tostring(math.abs(v), "#,##0.00")

f_num(float v, int dp) =>
    na(v) ? "—" : str.tostring(v, dp == 0 ? "#" : dp == 1 ? "#.#" : "#.##")

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

// ════════════════════════════════ WHAT IS DRAWN ════════════════════════════════

// ── the plan colours ──────────────────────────────────────────────────────────────────────────────
// The design kit has tokens for exactly these three roles, which is the whole reason the kit exists:
// TE_ENTRY, TE_STOP and TE_TARGET mean the same thing in every product in the fleet, so a reader who
// has seen one of our scripts already knows which line is which here.
//
// NOTE the entry tag does NOT use TE_BULL or TE_BEAR even though the side is known. Colouring the
// entry by direction would make the tool look like it had an opinion about the direction, and it has
// none — the side is an arithmetic consequence of where you put the stop.
lineCol(int which) =>
    which == 0 ? TE_ENTRY : which == 1 ? TE_STOP : TE_TARGET

// ── the three plan lines ──────────────────────────────────────────────────────────────────────────
// Allocated ONCE with `var` and moved thereafter. A drawing leak is the most common defect in
// overlay scripts and it is structurally impossible here: the object count is fixed at three lines
// and three tags, whatever the chart does.
var line lnEntry = na
var line lnStop = na
var line lnTarget = na
var label tagEntry = na
var label tagStop = na
var label tagTarget = na

f_panelPos(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

f_place(line ln, float px, color c) =>
    line.set_xy1(ln, extendLines ? bar_index - 300 : bar_index - 40, px)
    line.set_xy2(ln, bar_index, px)
    line.set_extend(ln, extendLines ? extend.right : extend.none)
    line.set_color(ln, c)

// ── THE HOVER LAYER, AND IT IS A TEACHING LAYER ───────────────────────────────────────────────────
// Every tag and every panel row explains itself on hover, through the kit's `teTeach`, in his ruled
// four-clause schema:
//
//     what it reads  ·  how it is computed  ·  why that information matters  ·  what it does not tell you
//
// The fourth clause is the one a product would silently drop, and on a SIZING tool it is the most
// important clause in the whole script: every one of these numbers is arithmetic on something the
// user typed, and a readout that explains what it is while hiding what it cannot do is exactly how
// people come to trust a number too much.
//
// The clauses are composed at runtime, so a tag says "3 contracts risking 1,518.00" rather than
// "position size is the number of contracts" — the lesson is about the plan in front of the reader.

if barstate.islast
    txtSize = compact ? size.small : size.normal
    uw = f_unitWord(units != 1)

    if na(lnEntry)
        lnEntry := line.new(bar_index, close, bar_index, close, color = TE_ENTRY, width = TE_W_STANDARD)
        lnStop := line.new(bar_index, close, bar_index, close, color = TE_STOP, width = TE_W_EMPHASIS, style = line.style_dashed)
        lnTarget := line.new(bar_index, close, bar_index, close, color = TE_TARGET, width = TE_W_CONTEXT, style = line.style_dotted)

    drawPlan = showLines and planSet
    f_place(lnEntry, drawPlan ? entryPx : na, lineCol(0))
    f_place(lnStop, drawPlan ? stopPx : na, lineCol(1))
    f_place(lnTarget, drawPlan and targetOk ? targetPx : na, lineCol(2))

    label.delete(tagEntry)
    label.delete(tagStop)
    label.delete(tagTarget)

    if drawPlan
        tipEntry = teTeach(
          "Your planned entry is " + f_px(entryPx) + ", and because the stop sits " + (side == 1 ? "below" : "above") + " it this is being sized as a " + (side == 1 ? "long" : "short") + ".",
          "Nothing is computed from E on its own. The direction is inferred as sign(E - S), and every figure below is built on the distance d = abs(E - S) = " + f_num(stopDist, 2) + " rather than on either price alone.",
          "It is the reference every other number here is measured from, and it is draggable — move it and the size, the risk and the reward multiple all recompute as you go.",
          "It is a price you typed or clicked, not a fill. This script has no connection to a broker, does not know whether you are in this trade, and cannot tell you whether this entry is a good one.")

        tipStop = teTeach(
          "Your stop is " + f_px(stopPx) + ", which is " + f_num(stopDist, 2) + " points away" + (na(stopTicks) ? "" : " (" + f_num(stopTicks, 0) + " ticks)") + " and " + f_num(stopPct, 2) + "% of the entry price.",
          "d = abs(E - S). One " + f_unitWord(false) + " therefore risks d x " + str.tostring(pv) + (cost > 0 ? " + " + f_money(cost) + " of cost" : "") + " = " + f_money(perUnit) + ", where the multiplier comes from the symbol rather than from any table in this script.",
          "The stop distance is the denominator of the entire calculation: it, not the entry, is what decides how many " + f_unitWord(true) + " a fixed budget can carry. Widening it does not change your risk, it changes your size.",
          "It is where the plan would be wrong, not where you will actually be filled. Slippage, gaps and fast markets can all fill a stop worse than the price shown, which is part of why the cost input exists.")

        tagEntry := teTag(bar_index, entryPx, "ENTRY", f_px(entryPx), teZone(TE_SURFACE_HI, "plan"), TE_TEXT, tipEntry)
        tagStop := teTag(bar_index, stopPx, "STOP", f_px(stopPx), teZone(TE_SURFACE_HI, "plan"), TE_TEXT, tipStop)

        if targetOk
            tipTarget = teTeach(
              "Your target is " + f_px(targetPx) + ", which is " + f_num(reward, 2) + " points from the entry" + (na(rGross) ? "" : " — a reward multiple of " + f_num(rGross, 2) + " before costs" + (na(rNet) ? "" : " and " + f_num(rNet, 2) + " after them")) + ".",
              "Gross R = abs(T - E) / d. Net R charges the same round-turn cost on the way out that was charged on the way in: (abs(T - E) x " + str.tostring(pv) + " x " + str.tostring(units) + " - " + f_money(cost) + " x " + str.tostring(units) + ") / the planned risk.",
              "The gross figure is the one people quote and the net one is the one that is true. On a tight stop with real costs the gap between them is large enough to change whether a plan is worth taking at all.",
              "A reward multiple is a ratio of distances on a chart. It says nothing about how often either level is reached, and this script measures no outcomes whatsoever.")
            tagTarget := teTag(bar_index, targetPx, "TARGET", f_px(targetPx), teZone(TE_SURFACE_HI, "plan"), TE_TEXT, tipTarget)

// ── the readout table ─────────────────────────────────────────────────────────────────────────────
var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    txtSize2 = compact ? size.small : size.normal
    uw2 = f_unitWord(units != 1)
    stateCol = sizeState == STATE_SIZED ? TE_TEXT : sizeState == STATE_CAPPED ? TE_ATTENTION : sizeState == STATE_NO_PLAN ? TE_TEXT_MUTED : TE_BLOCKED

    tipSize = teTeach(
      sizeState == STATE_NO_PLAN ? "No plan is set yet. Click an entry and a stop on the chart — while they are equal or unset there is no distance to size and this reports nothing rather than a number." : sizeState == STATE_TARGET_SIDE ? "The target is on the wrong side of the entry for a " + (side == 1 ? "long" : "short") + ", so no reward figure is produced from it." : sizeState == STATE_BELOW_ONE ? "Your budget of " + f_money(budget) + " does not cover a single " + f_unitWord(false) + ": one would risk " + f_money(perUnit) + "." : "This plan fits " + str.tostring(units) + " " + uw2 + ", risking " + f_money(plannedRisk) + " of your " + f_money(budget) + " budget.",
      "units = floor(R / (d x " + str.tostring(pv) + (cost > 0 ? " + " + f_money(cost) : "") + ")), then limited to your cap of " + str.tostring(maxUnits) + ". The division floors rather than rounds, because any other rounding puts the position over the budget you set" + (cappedByUser ? " — and here the CAP bound the answer, not the budget, so a tighter stop would not change it." : "."),
      "It converts a decision you have already made - this entry, this stop, this budget - into the one number you have to type into an order ticket, with the rounding going in the direction that protects the budget.",
      "It is arithmetic on numbers you entered. It is not connected to any account, broker or position, it does not know what you already hold or what you have risked today, and it is not a recommendation to take this trade or to risk this amount.")

    tipRisk = teTeach(
      units >= 1 ? "This position risks " + f_money(plannedRisk) + " if the stop is reached, leaving " + f_money(unusedBudget) + " of the budget unused." : "No position fits, so there is no planned risk to report.",
      "plannedRisk = units x (d x " + str.tostring(pv) + (cost > 0 ? " + cost" : "") + "), and the unused figure is R - plannedRisk. They differ because the size was floored: the leftover is real money the plan does not use.",
      "This, not the budget, is what the plan actually puts at stake. Reading the budget instead is how people believe they risked a round number when they risked less - or, with the rounding the other way, more.",
      "It assumes the stop is filled at the stop price. A gap through it, or slippage in a fast market, can lose more than this figure, and no arithmetic here can bound that.")

    tipDist = teTeach(
      planSet ? "The stop is " + f_num(stopDist, 2) + " points away, which is " + (na(stopTicks) ? "—" : f_num(stopTicks, 0) + " ticks") + " and " + f_num(stopPct, 2) + "% of the entry price." : "No stop distance yet: set an entry and a stop.",
      "d = abs(E - S) in points; ticks = d / " + str.tostring(tick) + ", the instrument's own minimum increment; percent = 100 x d / E.",
      "Points do not travel between markets and ticks are the unit an order is actually placed in, so the same distance is worth reading three ways before it is compared with anything.",
      "It measures the plan you drew. It says nothing about whether that distance is appropriate for this instrument's volatility, and this script does not measure volatility.")

    table.clear(panel, 0, 0, 1, 7)
    table.cell(panel, 0, 0, "POSITION SIZE", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize2, tooltip = tipSize)
    table.cell(panel, 1, 0, units >= 1 ? str.tostring(units) + " " + uw2 : sizeState, text_color = stateCol, bgcolor = TE_SURFACE_HI, text_size = txtSize2, tooltip = tipSize)

    table.cell(panel, 0, 1, "Risk at stop", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipRisk)
    table.cell(panel, 1, 1, units >= 1 ? f_money(plannedRisk) : f_money(perUnit) + " for 1", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipRisk)

    table.cell(panel, 0, 2, "Stop distance d", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipDist)
    table.cell(panel, 1, 2, planSet ? f_num(stopDist, 2) + " pts" : "—", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipDist)

    if not compact
        tipBudget = teTeach(
          "Your budget for this trade is " + f_money(budget) + (riskMode == "Percent of account" ? ", which is " + f_num(riskPct, 2) + "% of the " + f_money(acctSize) + " account size you entered." : ", entered directly."),
          riskMode == "Percent of account" ? "R = A x r / 100, from the account size and percent in the settings." : "R is the fixed figure in the settings, used as entered.",
          "Every other number on this panel is derived from it, so it is the one input worth getting right before any of the rest are read.",
          "It is a figure you typed. This script cannot see your account, cannot verify the number, and has no view on what percentage is appropriate for you - the 1% default is a commonly cited starting point, not a finding.")

        tipPerUnit = teTeach(
          "One " + f_unitWord(false) + " risks " + f_money(perUnit) + (cost > 0 ? ", of which " + f_money(cost) + " is the round-turn cost you entered." : ", with no costs entered."),
          "d x " + str.tostring(pv) + (cost > 0 ? " + cost" : "") + ", where " + str.tostring(pv) + " is the symbol's own contract multiplier - 1 on a share, the contract value on a future - so the same expression is correct on any instrument with no table to maintain.",
          "It is the quantity the budget is divided by, so it is where a sizing error hides: if this figure looks wrong for the instrument, the size is wrong and nothing downstream will reveal it.",
          "It does not include financing, exchange fees you did not enter, or any tax. It includes exactly what you typed into the cost input and nothing else.")

        tipBound = teTeach(
          sizeState == STATE_CAPPED ? "Your cap of " + str.tostring(maxUnits) + " bound this answer, not the budget: the budget alone would have allowed " + str.tostring(wantUnits) + "." : units >= 1 ? "The budget bound this answer. Your cap of " + str.tostring(maxUnits) + " " + (wantUnits == maxUnits ? "happens to equal it but did not cause it." : "was not reached.") : "Nothing bound the answer, because no position fits the budget.",
          "The cap is applied AFTER the division rather than instead of it, which is the only reason this row can exist: units = min(floor(R / perUnit), cap), and the two quantities are compared.",
          "A size that is capped will not change when you tighten the stop, and knowing which constraint is active is the difference between adjusting the thing that matters and the thing that does not.",
          "It reports which of two numbers you set was smaller. It has no view on whether either of them is sensible.")

        table.cell(panel, 0, 3, "Budget R", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipBudget)
        table.cell(panel, 1, 3, f_money(budget), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipBudget)

        table.cell(panel, 0, 4, "Risk per " + f_unitWord(false), text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipPerUnit)
        table.cell(panel, 1, 4, f_money(perUnit), text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipPerUnit)

        table.cell(panel, 0, 5, "Bound by", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipBound)
        table.cell(panel, 1, 5, units >= 1 ? (cappedByUser ? "your cap" : "the budget") : "—", text_color = cappedByUser ? TE_ATTENTION : TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipBound)

        tipUnused = teTeach(
          units >= 1 ? f_money(unusedBudget) + " of your " + f_money(budget) + " budget is left unused, because the size was rounded down to a whole " + f_unitWord(false) + "." : "There is no unused figure, because no position fits.",
          "R - units x perUnit. It is never negative: flooring guarantees the planned risk is at most the budget, which is the invariant the tests sweep across 900 combinations of distance, budget and cost.",
          "It is the cost of position sizes being whole numbers, and on a large per-unit risk it can be most of the budget - which is worth seeing before concluding the plan uses the risk you intended.",
          "It is arithmetic left over, not capital set aside. Nothing reserves it and nothing prevents it being used by another plan.")

        table.cell(panel, 0, 6, "Unused budget", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipUnused)
        table.cell(panel, 1, 6, units >= 1 ? f_money(unusedBudget) : "—", text_color = TE_TEXT_MUTED, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipUnused)

        tipR = teTeach(
          targetOk ? "This plan offers " + f_num(rGross, 2) + " to 1 before costs" + (na(rNet) ? "" : " and " + f_num(rNet, 2) + " to 1 after them") + "." : targetSet ? "The target is on the wrong side of the entry for this direction, so no multiple is produced." : "No target is set, so there is no reward figure - which is deliberate: a default target would be a number nobody chose.",
          "Gross = abs(T - E) / d. Net charges the same round-turn cost on the way out as on the way in and divides by the planned risk, so it falls as the stop tightens or the cost rises.",
          "The gross number is the one quoted everywhere and the net one is the one you will actually experience. Comparing them is the quickest way to see whether a tight-stop plan survives its own costs.",
          "Both are ratios of distances on a chart. Neither says how often a target is reached before a stop, and this script measures no outcomes at all.")

        table.cell(panel, 0, 7, "Reward R", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipR)
        table.cell(panel, 1, 7, targetOk ? f_num(rGross, 2) + " / " + f_num(rNet, 2) + " net" : "—", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize2, tooltip = tipR)

    table.set_position(panel, f_panelPos(panelPos))

// ════════════════════════════════ ALERTS ════════════════════════════════
//
// The three alerts here are FACTUAL EVENTS about prices you set yourself — price reached your
// planned entry, your stop price, your target. They are not instructions, and nothing here says what
// to do when one fires.
//
// They fire on CLOSED BARS ONLY and only while a plan is actually set. An alert armed against an
// unset plan would fire on the price 0 and be nonsense.
//
// Both mechanisms are here on purpose, because they are not interchangeable:
//   alertcondition() makes the alert DISCOVERABLE in TradingView's own dialog, so it can be armed
//     from the UI without reading any documentation.
//   alert() carries the DYNAMIC text, so the message can name the price and the size.
//
// ⚠️ A TradingView alert freezes the INPUTS as they were when you created it. If you later drag the
// entry or the stop, the running alert keeps firing on the OLD prices until you recreate it. That is
// TradingView's behaviour for every script, not this one's, and it matters more here than in most
// scripts precisely because these inputs are meant to be dragged.

touchedEntry = planSet and barstate.isconfirmed and low <= entryPx and entryPx <= high
touchedStop = planSet and barstate.isconfirmed and low <= stopPx and stopPx <= high
touchedTarget = targetOk and barstate.isconfirmed and low <= targetPx and targetPx <= high

alertcondition(touchedEntry, title = "Price reached the planned entry", message = "Price traded through the planned entry on {{ticker}} {{interval}}. See the readout for the position size this plan was sized to.")
alertcondition(touchedStop, title = "Price reached the stop price", message = "Price traded through the stop price on {{ticker}} {{interval}}.")
alertcondition(touchedTarget, title = "Price reached the target price", message = "Price traded through the target price on {{ticker}} {{interval}}.")

if touchedEntry
    alert("TE SIZE-R — " + syminfo.ticker + " " + timeframe.period + " traded through your planned entry " + f_px(entryPx) + ". This plan was sized to " + (units >= 1 ? str.tostring(units) + " " + f_unitWord(units != 1) + " risking " + f_money(plannedRisk) : sizeState) + ".", alert.freq_once_per_bar_close)

if touchedStop
    alert("TE SIZE-R — " + syminfo.ticker + " " + timeframe.period + " traded through your stop price " + f_px(stopPx) + ".", alert.freq_once_per_bar_close)

if touchedTarget
    alert("TE SIZE-R — " + syminfo.ticker + " " + timeframe.period + " traded through your target price " + f_px(targetPx) + ".", alert.freq_once_per_bar_close)

// ── the rail, last line, where it is never edited away by accident ───────────────────────────────
// Decision support. This is not financial advice, and nothing here is a recommendation to buy or
// sell anything.
````
