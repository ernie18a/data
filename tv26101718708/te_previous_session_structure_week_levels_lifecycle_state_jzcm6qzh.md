# TE Previous Session Structure Week Levels Lifecycle State

- url: https://www.tradingview.com/script/jZCM6qzH-TE-Previous-Session-Structure-Week-Levels-Lifecycle-State/
- type: indicator
- pine_id: PUB;e5ce10e35ad14f218bca70207b397715
- version: 1.0

## Description

TE Previous Session Structure plots key completed reference levels from the prior trading day, prior regular session, overnight session and prior week, then tracks what price has already done at those levels.

The core question is simple:

Which prior references matter now, and what has price already done to them?

The indicator maintains eleven completed-period references:

PDH, PDL, PDC — previous trading day high, low and close
RTHH, RTHL, RTHC — previous regular session high, low and close
ONH, ONL — overnight high and low
PWH, PWL, PWC — previous week high, low and close

Visual example:
https://www.tradingview.com/x/k61d2v22/

SESSION STRUCTURE

The trading day is not treated as the calendar day. It follows the exchange's own trading-day boundary, so a futures session that opens the prior evening is still treated as one trading day.

The regular session comes from the exchange's own session definition rather than a manually entered UTC offset.

RTHC is deliberately labeled as the regular-session CLOSE, not settlement. The official exchange settlement can differ from the final session print, so the script does not present a value it cannot actually obtain from the chart.

LIFECYCLE STATES

Every level carries a state describing what price has already done to it:

SET
BROKEN ABOVE
BROKEN BELOW
RECLAIMED
EXPIRED

When a level is first published, the indicator records which side of the level price is on:

side₀ = sign(close - level)

All later lifecycle changes are evaluated relative to that original side.

This means a previous-day low that begins below price is considered broken when price later closes below it and reclaimed when price closes back above it. A high works in the opposite direction.

Visual example:
https://www.tradingview.com/x/IiZv9QzM/

A WICK IS A TOUCH, NOT A BREAK

One of the most important rules in the indicator is that a break requires a confirmed close beyond the level.

If price trades through a level intrabar but closes back on the original side, the level remains unbroken.

That interaction is recorded as a touch instead.

Touches count closed bars whose full high-low range contained the level, including a bar that later produces a valid close-through break.

This prevents temporary intrabar excursions from creating false lifecycle changes.

Visual example:
https://www.tradingview.com/x/wbTWngQJ/

RECLAIMS AND RETIREMENT

After a level is broken, a confirmed close back on its original side changes the state to RECLAIMED.

A level may move through several legitimate transitions over its life:

SET → BROKEN → RECLAIMED → BROKEN again

Each transition requires its own confirmed close.

The indicator can also retire structure that price has moved away from.

If a level remains broken for N consecutive confirmed bars without being reclaimed, it becomes EXPIRED.

The counter resets immediately on a reclaim.

Default:

N = 0

This keeps levels indefinitely unless the user chooses a retirement period.

Expired levels can either disappear or remain visible in a muted style.

Visual example:
https://www.tradingview.com/x/bAKuMvey/

READOUT

The indicator also maintains a table of the live levels nearest to current price.

For each level it can show:

Level key
Lifecycle state
Distance from current price

The table is ordered by absolute distance only. It does not assign an importance, strength or probability score.

Color and line style identify the source group — trading day, regular session, overnight or week — rather than bullish or bearish direction.

WHAT IT DOES NOT DO

It does not predict price direction.

It does not rank levels by strength or importance.

It does not claim that a level will hold.

It does not generate entries, stops or targets.

SET, BROKEN, RECLAIMED and EXPIRED describe historical interaction with a reference level. They are observations, not forecasts.

All lifecycle transitions are evaluated on confirmed bars. The script also uses zero request.security() calls.

TE Previous Session Structure is designed to turn a static prior-level map into a structured record of what price has actually done at those references.

Trader's Edge

Financial Disclaimer: For educational and informational purposes only. Nothing in this indicator constitutes financial, investment or trading advice, or a recommendation to buy, sell or hold any instrument. Market trading involves risk, and past price behavior does not predict future results.

## Source Code

````pine
//@version=6
// TE PREVIOUS SESSION STRUCTURE — PRIOR DAY, SESSION, OVERNIGHT AND WEEK LEVELS WITH LIFECYCLE STATE
// This source code is subject to the terms of the TRADERS EDGE license — all rights reserved. Distributed on
// TradingView as a protected / Public; not for resale, or reverse engineering.                                                                                   (catalog TE-004)
//
// THE QUESTION: which prior references matter now, and what has price already done to them?
//
// Eleven levels, every one of them the extreme or the close of a COMPLETED period:
//
//   PDH  PDL  PDC     the previous TRADING DAY — high, low, close
//   RTHH RTHL RTHC    the previous REGULAR SESSION — high, low, close
//   ONH  ONL          the OVERNIGHT stretch between the last session close and the next open
//   PWH  PWL  PWC     the previous WEEK — high, low, close
//
// THE TRADING DAY IS NOT THE CALENDAR DAY. It comes from the exchange's own trading-day boundary, so
// a futures session that opens the previous evening is ONE day, and a shortened or holiday session is
// simply a short one. Nothing here is special-cased for holidays, because a short day is not an
// exception to this — it is an observation in it. The regular session likewise comes from the
// exchange's own declared hours: no session string, no hour literal, no timezone argument, and
// therefore no offset anywhere in this file that could be right in June and wrong in December.
//
// 🔴 RTHC IS LABELLED A CLOSE, NOT A SETTLEMENT, AND THAT IS DELIBERATE. TradingView does not publish
// official exchange settlement prices to a chart, and the regular-session close is NOT the
// settlement: for most futures the settlement is derived from a closing range or a volume-weighted
// window and routinely differs from the last print. So this ships the CLOSE and calls it that.
// Labelling it "settlement" would be a one-word claim that is simply false.
//
// ── THE LIFECYCLE ───────────────────────────────────────────────────────────────────────────────
// Each level carries a state: SET · BROKEN ABOVE · BROKEN BELOW · RECLAIMED · EXPIRED.
//
// When a level is published the script records WHICH SIDE PRICE WAS ON, and everything after is
// relative to that. It is what makes the words mean what traders mean by them: a previous-day low is
// below price when it is born, so BREAKING it is closing below and RECLAIMING it is closing back
// above. A level cannot be broken on the bar it is born, because its original side is taken from that
// same bar's close.
//
// 🔴 A WICK THROUGH A LEVEL IS A TOUCH, NOT A BREAK. A break requires a CLOSE beyond. This is the
// product's one opinion and it is stated here rather than buried: an intrabar spike through a level
// that closes back inside is the single most common thing a naive level tool calls a break, and
// calling it one makes every state downstream of it wrong.
//
// CLEAN RETIREMENT: a level broken for N CONSECUTIVE closed bars without being reclaimed becomes
// EXPIRED and stops being drawn. The counter RESETS on any reclaim, so a level that keeps doing its
// job never ages out. It is a rule rather than a judgment: a price that price has walked away from
// and not returned to is no longer structure.
//
// TOUCHES are counted as closed bars whose RANGE contained the level, and they live in the HOVER
// LAYER rather than on the label — a label carries one state and one value, and a touch count is the
// fourth thing competing for the same inch of chart.
//
// ── WHAT IT DELIBERATELY DOES NOT DO ────────────────────────────────────────────────────────────
//   • NO RANKING, NO SCORE, NO "IMPORTANCE". Which level matters is your judgment. This product's
//     job is to get the levels and their states RIGHT, and a home-made importance number would be a
//     claim nobody measured dressed up as information.
//   • NO DIRECTION. Colour encodes the SOURCE GROUP — day, session, overnight, week — never a bias.
//     A previous-day high is not bearish and a previous-day low is not bullish; they are references.
//   • NO PREDICTION. A state says what price has already done to a level. It says nothing about what
//     it will do next, and nothing here estimates the odds of anything.
//
// HOW IT DECIDES: every publication and every transition happens inside `barstate.isconfirmed` — on
// CLOSED BARS ONLY. The completed period is published BEFORE the current bar is folded into the new
// one, so yesterday's high can never silently include today's first bar. ZERO request.security calls,
// so there is no higher-timeframe repaint surface at all.
//
// DRAWING: the object count is FIXED at eleven lines and eleven tags, allocated once and moved
// thereafter. A drawing leak — the most common defect in overlay scripts — is therefore structurally
// impossible here rather than merely unlikely.
//
// LOGIC SOURCE OF TRUTH: daemons/sim/te-levels/te-levels.mjs, pinned by te-levels.test.mjs — the
// publish-before-fold ordering, birth-bar immunity, the wick-versus-close rule, reclaim in both
// directions, oscillation, retirement and its counter reset, and which lifecycle states this product
// can actually reach. A further test reads THIS Pine and asserts it spells every lifecycle word and
// every level key exactly as the mirror does. If the two ever disagree, the mirror is right.
//
// ── IP PROVENANCE ───────────────────────────────────────────────────────────────────────────────
// PUBLIC MATH — a period's high, low and close are its running extremes and its last print. There is
//   nothing proprietary in any of it.
// INDEPENDENTLY DERIVED — the six-state lifecycle with the original-side convention, the
//   close-beyond break rule, the consecutive-bar retirement with its reset, and the fixed-object
//   rendering. Derived from the behavioural spec at
//   docs/findings/2026-09-23-te-004-previous-session-structure-spec.md, committed before any line of
//   this file existed. No third-party script was read, ported or paraphrased for any of it.
// REUSED from our own catalog — the lifecycle vocabulary and the exchange-session mechanism come
//   from the session product in this same catalog and this same repository.
// ORIGINAL — the TE design kit block below, generated from daemons/forge/design-kit.mjs.
// LEFT OUT RATHER THAN GUESSED AT — any ranking or importance score, any claim that a level will
//   hold, any settlement price we cannot actually obtain, and any prediction of what happens at a
//   level.
//
// Decision support only. No order is placed, no target is promised, no outcome is claimed.

indicator("TE Previous Session Structure — Prior Day, Session, Overnight and Week Levels with Lifecycle State", "TE STRUCT-P", overlay = true, max_lines_count = 20, max_labels_count = 20)

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

gGroups = "WHICH LEVELS"
showDay = input.bool(true, "Previous trading day (PDH, PDL, PDC)", group = gGroups, tooltip = "The high, low and close of the previous TRADING day, which is not the calendar day: it comes from the exchange's own trading-day boundary, so a futures session that opens the previous evening is one day. A shortened or holiday session is simply a short day and is not special-cased.")
showRth = input.bool(true, "Previous regular session (RTHH, RTHL, RTHC)", group = gGroups, tooltip = "The high, low and close of the previous REGULAR session, taken from the exchange's own declared hours - no session string, no hour literal and no timezone argument, so there is no offset that could be right in summer and wrong in winter. On an instrument with no separate regular session this group coincides with the trading day group, which is correct rather than redundant. Note RTHC is a CLOSE and is labelled as one: TradingView does not publish official settlement prices to a chart, and for most futures the settlement is derived from a closing range or a volume-weighted window and differs from the last print.")
showOn = input.bool(true, "Overnight (ONH, ONL)", group = gGroups, tooltip = "The high and low of the stretch between the last regular-session close and the next open - the bars outside the exchange's regular hours. On a market with no out-of-hours trading this group never publishes, and the levels simply do not appear rather than showing a duplicate of the session range.")
showWeek = input.bool(true, "Previous week (PWH, PWL, PWC)", group = gGroups, tooltip = "The high, low and close of the previous week. The week boundary comes from Pine's own calendar rather than from a bar count, so a holiday-shortened week is a short week and nothing is skipped or double-counted.")

gLife = "LIFECYCLE"
retireBars = input.int(0, "Retire after N consecutive broken bars (0 = never)", minval = 0, maxval = 500, group = gLife, tooltip = "Clean retirement. A level that has been broken and NOT reclaimed for N consecutive closed bars becomes EXPIRED and stops being drawn. The counter resets on any close back on the level's original side, so a level that keeps being reclaimed never ages out however long it lives. 0 keeps every level forever, which is the default because the right N depends entirely on your timeframe: 20 bars is an afternoon on a 15-minute chart and a month on a daily one. A break requires a CLOSE beyond the level - a wick through counts as a touch, not a break, and never starts this counter.")
showExpired = input.bool(false, "Keep drawing retired levels", group = gLife, tooltip = "Draws EXPIRED levels in a muted colour instead of removing them. Useful while you are choosing a retirement setting, because it lets you see what the rule is actually discarding before you trust it to discard things silently.")

gDraw = "DRAWING"
extendLines = input.bool(true, "Extend lines to the right", group = gDraw, tooltip = "Extends each level line to the right edge of the chart so it stays visible as price moves away. Off draws each line only across recent bars, which is quieter on a chart that already carries other structure.")
showTags = input.bool(true, "Show level tags", group = gDraw, tooltip = "Draws the hover-enabled tag beside each level carrying its key and its price. Every tag explains its own source, its lifecycle state, how many times price has touched it and how long it has existed. Turn tags off to keep the lines alone.")
lineBack = input.int(120, "Line start, bars back", minval = 5, maxval = 2000, group = gDraw, tooltip = "How far to the left each level line begins, in bars. This is cosmetic only and changes no computed value: the lifecycle is evaluated against every closed bar since the level was published, whatever is drawn.")

gPanel = "READOUT"
showPanel = input.bool(true, "Show readout table", group = gPanel, tooltip = "Lists the live levels nearest to the current price, with the state of each and its distance. Retired levels are excluded from the list whether or not they are still drawn.")
nearCount = input.int(5, "Levels listed", minval = 1, maxval = 11, group = gPanel, tooltip = "How many of the nearest live levels the table lists. Levels exactly equidistant above and below are ordered by their fixed declaration order, so the table never reshuffles itself between bars for no visible reason.")
panelPos = input.string("Top right", "Table anchor", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gPanel, tooltip = "Where the readout table is anchored on the chart. Move it if it overlaps something you need to read.")
compact = input.bool(false, "Compact mode", group = gPanel, tooltip = "Steps the table font down one size and drops the distance column, for small screens. The state of each level is kept, because that is the column the product exists for.")

// NOTE: there is deliberately no theme input here — the design kit above emits its own under the
// APPEARANCE group, and every colour in this file reads from it.
//
// NOTE ALSO: there is deliberately no "importance", "strength" or "score" setting. Which level
// matters is your judgment, and a number invented here to rank them would be a claim nobody measured
// wearing the clothes of information.

// ════════════════════════════════ THE ENGINE ════════════════════════════════
//
// A transliteration of daemons/sim/te-levels/te-levels.mjs. Read that file for the reasoning; this
// one is the same algorithm in Pine's vocabulary. A test in that directory reads THIS FILE and
// asserts every lifecycle word and every level key below is spelled exactly as the mirror spells it.

// ── the lifecycle vocabulary, in ONE place ────────────────────────────────────────────────────────
// Identical to the session product's, deliberately: two copies of a vocabulary is two vocabularies
// the moment someone edits one of them, and a test asserts the two arrays are the same.
//
// FORMING is carried for that identity and is UNREACHABLE here — every level in this product comes
// from a COMPLETED period, so none of them is ever forming. That is a design decision, and the
// mirror pins the reachable set so a reader is never left wondering whether a state is missing.
f_lifeName(int i) =>
    i == 0 ? "FORMING" : i == 1 ? "SET" : i == 2 ? "BROKEN ABOVE" : i == 3 ? "BROKEN BELOW" : i == 4 ? "RECLAIMED" : i == 5 ? "EXPIRED" : "—"

// ── the eleven levels, in the order they are indexed everywhere ──────────────────────────────────
f_key(int i) =>
    i == 0 ? "PDH" : i == 1 ? "PDL" : i == 2 ? "PDC" : i == 3 ? "RTHH" : i == 4 ? "RTHL" : i == 5 ? "RTHC" : i == 6 ? "ONH" : i == 7 ? "ONL" : i == 8 ? "PWH" : i == 9 ? "PWL" : i == 10 ? "PWC" : "—"

// 🔴 "close", never "settlement". TradingView does not publish official exchange settlement to a
// chart, and for most futures the settlement comes from a closing range or a volume-weighted window
// and differs from the last print. Calling it settlement would be a one-word claim that is false.
f_source(int i) =>
    i == 0 ? "previous trading day high" : i == 1 ? "previous trading day low" : i == 2 ? "previous trading day close" : i == 3 ? "previous regular session high" : i == 4 ? "previous regular session low" : i == 5 ? "previous regular session close" : i == 6 ? "overnight high" : i == 7 ? "overnight low" : i == 8 ? "previous week high" : i == 9 ? "previous week low" : i == 10 ? "previous week close" : "—"

// 0 day · 1 regular session · 2 overnight · 3 week
f_group(int i) =>
    i <= 2 ? 0 : i <= 5 ? 1 : i <= 7 ? 2 : 3

f_groupShown(int g) =>
    g == 0 ? showDay : g == 1 ? showRth : g == 2 ? showOn : showWeek

// ── the anchors, all from the exchange's own calendar ────────────────────────────────────────────
// `session.ismarket` is TradingView's answer to "is this bar inside this instrument's regular
// session", taken from the exchange's declared hours — no session string, no hour literal and no
// timezone argument, so there is no offset anywhere here that could be right in June and wrong in
// December. `time_tradingday` is the exchange's own trading-day boundary, which is why a futures
// session opening the previous evening is one day. `time("W")` is Pine's own week, so a
// holiday-shortened week is a short week rather than a miscount.
inSess = session.ismarket
wkStart = time("W")

var array<float> lvPrice = array.new_float(11, na)
var array<int> lvState = array.new_int(11, -1)
var array<int> lvSide0 = array.new_int(11, 0)
var array<int> lvBroke = array.new_int(11, 0)
var array<int> lvBrokeBars = array.new_int(11, 0)
var array<int> lvTouch = array.new_int(11, 0)
var array<int> lvBorn = array.new_int(11, 0)

// the four accumulators
var float dayHi = na
var float dayLo = na
var float dayCl = na
var int dayBars = 0
var float rthHi = na
var float rthLo = na
var float rthCl = na
var int rthBars = 0
var float onHi = na
var float onLo = na
var int onBars = 0
var float wkHi = na
var float wkLo = na
var float wkCl = na
var int wkBars = 0

var int lastTd = na
var int lastWk = na
var int wasIn = -1

// ── publish one completed period into a record ───────────────────────────────────────────────────
// ② BIRTH-BAR IMMUNITY: the original side is taken from THIS bar's close, so a level cannot be born
// already broken. Without it, every level published while price sits beyond it would arrive looking
// like a fresh break, which is both useless and alarming.
//
// A Pine function may mutate a global ARRAY (array.set is a call, not an assignment to a global), so
// the eleven records live in arrays rather than in scalars for exactly this reason.
f_pub(int i, float p, float c) =>
    if not na(p)
        array.set(lvPrice, i, p)
        array.set(lvState, i, 1)
        array.set(lvSide0, i, c > p ? 1 : c < p ? -1 : 0)
        array.set(lvBroke, i, 0)
        array.set(lvBrokeBars, i, 0)
        array.set(lvTouch, i, 0)
        array.set(lvBorn, i, bar_index)

// ── advance one record's lifecycle against one CLOSED bar ────────────────────────────────────────
// ③ A WICK IS A TOUCH, NOT A BREAK. Only a CLOSE on the far side reaches the break branch.
f_adv(int i, float h, float l, float c, int retire) =>
    float P = array.get(lvPrice, i)
    int st = array.get(lvState, i)
    if not na(P) and st >= 0 and st != 5
        int s0 = array.get(lvSide0, i)
        if s0 == 0
            s0 := c > P ? 1 : c < P ? -1 : 0
            array.set(lvSide0, i, s0)
        int now = c > P ? 1 : c < P ? -1 : 0
        if now != 0 and s0 != 0
            if now != s0
                array.set(lvState, i, s0 == 1 ? 3 : 2)
                array.set(lvBroke, i, 1)
                array.set(lvBrokeBars, i, array.get(lvBrokeBars, i) + 1)
            else
                if array.get(lvBroke, i) == 1
                    array.set(lvState, i, 4)
                array.set(lvBrokeBars, i, 0)
        // a touch is a closed bar whose RANGE contained the level, which includes the bar that broke
        // it — price did come to the level on that bar
        if l <= P and P <= h
            array.set(lvTouch, i, array.get(lvTouch, i) + 1)
        // clean retirement: N CONSECUTIVE broken bars without a reclaim. The counter above resets on
        // any close back on the original side, so a level that keeps working never ages out.
        if retire > 0 and array.get(lvBrokeBars, i) >= retire
            array.set(lvState, i, 5)

if barstate.isconfirmed
    bool newDay = not na(lastTd) and time_tradingday != lastTd
    bool newWeek = not na(lastWk) and not na(wkStart) and wkStart != lastWk
    bool sessEnded = wasIn == 1 and not inSess
    bool sessStarted = wasIn == 0 and inSess

    // ── ① PUBLISH THE COMPLETED PERIOD FIRST ─────────────────────────────────────────────────────
    // Only then is this bar folded into the fresh accumulator. Reversed, the previous day's high
    // would silently include the first bar of the new day — invisible on a chart until the first bar
    // of a session happens to be the extreme, and then wrong forever.
    if newDay and dayBars > 0
        f_pub(0, dayHi, close)
        f_pub(1, dayLo, close)
        f_pub(2, dayCl, close)
        dayHi := na
        dayLo := na
        dayCl := na
        dayBars := 0
    if sessEnded and rthBars > 0
        f_pub(3, rthHi, close)
        f_pub(4, rthLo, close)
        f_pub(5, rthCl, close)
        rthHi := na
        rthLo := na
        rthCl := na
        rthBars := 0
    if sessStarted and onBars > 0
        f_pub(6, onHi, close)
        f_pub(7, onLo, close)
        onHi := na
        onLo := na
        onBars := 0
    if newWeek and wkBars > 0
        f_pub(8, wkHi, close)
        f_pub(9, wkLo, close)
        f_pub(10, wkCl, close)
        wkHi := na
        wkLo := na
        wkCl := na
        wkBars := 0

    // ── lifecycle, against this bar ──────────────────────────────────────────────────────────────
    for i = 0 to 10
        f_adv(i, high, low, close, retireBars)

    // ── ONLY NOW fold this bar into the fresh accumulators ───────────────────────────────────────
    dayHi := na(dayHi) ? high : math.max(dayHi, high)
    dayLo := na(dayLo) ? low : math.min(dayLo, low)
    dayCl := close
    dayBars += 1

    wkHi := na(wkHi) ? high : math.max(wkHi, high)
    wkLo := na(wkLo) ? low : math.min(wkLo, low)
    wkCl := close
    wkBars += 1

    if inSess
        rthHi := na(rthHi) ? high : math.max(rthHi, high)
        rthLo := na(rthLo) ? low : math.min(rthLo, low)
        rthCl := close
        rthBars += 1
    else
        onHi := na(onHi) ? high : math.max(onHi, high)
        onLo := na(onLo) ? low : math.min(onLo, low)
        onBars += 1

    lastTd := time_tradingday
    lastWk := wkStart
    wasIn := inSess ? 1 : 0

// ── what is live, for the render and the panel ───────────────────────────────────────────────────
f_live(int i) =>
    float p = array.get(lvPrice, i)
    int st = array.get(lvState, i)
    not na(p) and st >= 0 and f_groupShown(f_group(i)) and (st != 5 or showExpired)

f_age(int i) =>
    bar_index - array.get(lvBorn, i)

// ════════════════════════════════ WHAT IS DRAWN ════════════════════════════════

// ── colour encodes the SOURCE GROUP, never direction ──────────────────────────────────────────────
// A previous-day high is not bearish and a previous-day low is not bullish; they are references, and
// a red one would quietly make the tool look like it had a view it does not have. So NO level uses
// TE_BULL or TE_BEAR, and none uses brand gold (doc 29 §9.2: gold is brand and selection only).
//
// The four groups are separated on THREE axes at once — hue, line style and weight — because hue
// alone fails for a colour-blind reader and on a busy chart.
f_groupColor(int g) =>
    g == 0 ? TE_STRUCTURE : g == 1 ? TE_DEVELOPING : g == 2 ? TE_STRUCTURE_2 : TE_TARGET

f_groupStyle(int g) =>
    g == 2 ? line.style_dashed : g == 3 ? line.style_dotted : line.style_solid

f_groupWidth(int g) =>
    g == 1 ? TE_W_STANDARD : g == 3 ? TE_W_EMPHASIS : TE_W_CONTEXT

f_groupName(int g) =>
    g == 0 ? "trading day" : g == 1 ? "regular session" : g == 2 ? "overnight" : "week"

// a retired level, if it is still drawn at all, is drawn as what it is: inactive
f_lvColor(int i) =>
    array.get(lvState, i) == 5 ? TE_INACTIVE : f_groupColor(f_group(i))

f_panelPos(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

// ── the drawing objects: ELEVEN LINES AND ELEVEN TAGS, ALLOCATED ONCE ────────────────────────────
// The count is fixed whatever the chart does, so a drawing leak — the most common defect in overlay
// scripts — is structurally impossible here rather than merely unlikely. The lines are MOVED; the
// tags are deleted and rebuilt because the kit's tag helper composes a fresh label with its tooltip.
// The tag array starts as eleven `na` slots rather than eleven invisible placeholder labels. A
// placeholder would be a `label.new` carrying no hover and no house typeface — which the fleet rules
// correctly flag, because from the outside it is indistinguishable from a real tag someone forgot to
// explain. Nothing is drawn until there is something to say.
var array<line> lvLine = array.new_line(0)
var array<label> lvTag = array.new_label(11, na)
if array.size(lvLine) == 0
    for i = 0 to 10
        array.push(lvLine, line.new(bar_index, close, bar_index, close, color = TE_INACTIVE, width = TE_W_CONTEXT))

// ── THE HOVER LAYER, AND IT IS A TEACHING LAYER ───────────────────────────────────────────────────
// Every tag and every panel row explains itself on hover through the kit's `teTeach`, in his ruled
// four-clause schema:
//
//     what it reads · how it is computed · why that information matters · what it does not tell you
//
// The clauses are composed at runtime, so a tag says "the previous trading day high at 5,012.25,
// broken above and not reclaimed for 6 bars, touched 3 times" rather than "PDH is the previous day
// high". The lesson is about the level in front of the reader, and it is free — every number in it
// was already computed for the line it sits on.
//
// The fourth clause carries the weight on this product: a level with a confident-looking state is
// exactly the thing a reader will over-trust, and every tag says plainly that a state describes what
// price has ALREADY done and predicts nothing.

if barstate.islast
    for i = 0 to 10
        line ln = array.get(lvLine, i)
        label tg = array.get(lvTag, i)
        if not na(tg)
            label.delete(tg)
        bool live = f_live(i)
        float p = array.get(lvPrice, i)
        int st = array.get(lvState, i)
        int g = f_group(i)

        line.set_xy1(ln, bar_index - lineBack, live ? p : na)
        line.set_xy2(ln, bar_index, live ? p : na)
        line.set_extend(ln, extendLines ? extend.right : extend.none)
        line.set_color(ln, f_lvColor(i))
        line.set_style(ln, f_groupStyle(g))
        line.set_width(ln, f_groupWidth(g))

        if live and showTags
            int touches = array.get(lvTouch, i)
            int age = f_age(i)
            int brokeBars = array.get(lvBrokeBars, i)
            tip = teTeach(
              "This is the " + f_source(i) + " at " + f_px(p) + ", currently " + f_lifeName(st) + ". Price has traded through it on " + str.tostring(touches) + (touches == 1 ? " closed bar" : " closed bars") + " since it was set " + str.tostring(age) + " bars ago" + (st == 2 or st == 3 ? ", and it has been broken for the last " + str.tostring(brokeBars) + (brokeBars == 1 ? " bar" : " bars") + " without being reclaimed" : "") + ".",
              "The " + f_groupName(g) + " period is closed first and published before the current bar is counted into the next one, so this value can never include a bar from the period it is meant to precede. The state is decided on CLOSES only: a close on the far side of where price was when the level was set is a break, a close back on that side afterwards is a reclaim, and a wick through is a touch rather than either.",
              "A level is worth different things depending on what has already happened at it. One that has never been closed through is untested structure; one that broke and was reclaimed has been fought over; one that broke and kept going is behind the market now, and reading all three the same way is how a level map stops being useful.",
              "It says what price has ALREADY done here. It does not say what price will do next, it does not rank this level against the others, and nothing in this script estimates the odds of it holding.")
            label nt = teTag(bar_index, p, f_key(i), f_px(p), teZone(TE_SURFACE_HI, "plan"), f_lvColor(i), tip)
            array.set(lvTag, i, nt)

// ── the readout: the live levels nearest to price ────────────────────────────────────────────────
// Selection rather than a sort, because eleven items make a sort's cost irrelevant and a selection
// is the version whose tie-breaking is obvious: equal distances resolve by the fixed declaration
// order, so the table never reshuffles itself between bars for no visible reason.
var table panel = table.new(position.top_right, 3, 12, border_width = 1)

if showPanel and barstate.islast
    txtSize = compact ? size.tiny : size.small
    table.clear(panel, 0, 0, 2, 11)

    int shown = 0
    for i = 0 to 10
        if f_live(i)
            shown += 1

    // -- ONE TEACHING SURFACE PER COLUMN, not one shared across the row ---------------------------
    // The first draft gave every cell in a row the same tooltip, which is what the tag does and is
    // right THERE, because a tag is one object. A table is not: someone hovering STATE wants the
    // lifecycle explained, and someone hovering DIST wants to know it is a distance and not a
    // target. Sharing one tooltip across three columns answers whichever question the author
    // happened to think of first, and leaves the other two unanswered.
    tipHeadLevel = teTeach(
      "There " + (shown == 1 ? "is " : "are ") + str.tostring(shown) + " live " + (shown == 1 ? "level" : "levels") + " on this chart, listed nearest to the last price of " + f_px(close) + " first.",
      "Each key names its source: PD is the previous trading day, RTH the previous regular session, ON the overnight stretch between them, PW the previous week; H, L and C are that period's high, low and close. Every one of them is a period that has already CLOSED.",
      "Knowing where a line came from is what lets you weigh it. A previous-week high and an overnight high are both just lines until you know which is which, and they are not the same kind of reference.",
      "It is a list of sources and prices. There is no ranking, no strength and no importance score anywhere in this product, and the order here is distance only.")

    tipHeadState = teTeach(
      "Each level's state says what price has ALREADY done to it since it was set.",
      "SET means never closed beyond. BROKEN ABOVE or BROKEN BELOW means price closed on the far side of where it sat when the level was published. RECLAIMED means it closed back again afterwards. EXPIRED means it stayed broken for the number of bars you set without being reclaimed. Every transition needs a CLOSE: a wick through is a touch, not a break.",
      "A level nobody has tested and a level price has already closed through twice are completely different situations, and this is the column where they stop looking alike.",
      "It is a history, not a forecast. Nothing here estimates whether a level will hold, and a state has no bearing on what price does next.")

    tipHeadDist = teTeach(
      "How far each level is from the last price of " + f_px(close) + ", as an absolute distance.",
      "The last price subtracted from the level price, shown without a sign; the row order is this number ascending. Levels exactly equidistant above and below resolve by a fixed order, so the table never reshuffles itself between bars for no visible reason.",
      "What is near is what price can reach next, and distance is the only ordering on this table that is a fact rather than an opinion.",
      "It is a distance today. It is not a target, it is not a prediction, and a near level is not a more likely one.")

    table.cell(panel, 0, 0, "LEVEL", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipHeadLevel)
    table.cell(panel, 1, 0, "STATE", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipHeadState)
    table.cell(panel, 2, 0, compact ? "" : "DIST", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipHeadDist)

    var array<int> picked = array.new_int(0)
    array.clear(picked)
    for slot = 0 to nearCount - 1
        int best = -1
        float bestD = na
        for i = 0 to 10
            if f_live(i) and not array.includes(picked, i)
                float d = math.abs(array.get(lvPrice, i) - close)
                if na(bestD) or d < bestD
                    bestD := d
                    best := i
        if best >= 0
            array.push(picked, best)

    for row = 0 to array.size(picked) - 1
        int i = array.get(picked, row)
        float p = array.get(lvPrice, i)
        int st = array.get(lvState, i)
        int tch = array.get(lvTouch, i)
        int bb = array.get(lvBrokeBars, i)
        float dist = p - close

        tipRowLevel = teTeach(
          "This is the " + f_source(i) + ", at " + f_px(p) + ", set " + str.tostring(f_age(i)) + " bars ago.",
          "It is the " + f_groupName(f_group(i)) + " period's " + (f_key(i) == "PDC" or f_key(i) == "RTHC" or f_key(i) == "PWC" ? "closing price" : "extreme") + ", published only once that period had finished and before the current bar was counted into the next one, so it can never include a bar from the period it is meant to precede.",
          "Where a reference came from is half of what it is worth. A weekly extreme and an overnight one are read at different scales, and this cell says which you are looking at.",
          "It is a price from the past. It carries no claim that price will react here, and this script does not rank it against the others.")

        tipRowState = teTeach(
          "This level is " + f_lifeName(st) + ". Price has traded through it on " + str.tostring(tch) + (tch == 1 ? " closed bar" : " closed bars") + (st == 2 or st == 3 ? ", and it has been broken for the last " + str.tostring(bb) + (bb == 1 ? " bar" : " bars") + " without being reclaimed" : "") + ".",
          "The state is decided on CLOSES only, relative to the side price was on when the level was set: a close on the far side is a break, a close back is a reclaim, and a wick through is neither. Touches count closed bars whose RANGE contained the level, including the bar that broke it.",
          "An untested level, one that was fought over and reclaimed, and one the market has left behind are three different things wearing the same line, and this is where they separate.",
          "It describes what has already happened. It is not a probability, not a signal, and not a statement that this level will do anything again.")

        tipRowDist = teTeach(
          "This level sits " + f_px(math.abs(dist)) + " " + (dist >= 0 ? "above" : "below") + " the last price.",
          "The last price subtracted from the level price. The table is ordered by this distance, smallest first, among live levels only.",
          "It is what tells you which references are actually in play for the session in front of you, rather than the ones you happen to remember.",
          "It is a distance, not a target and not a forecast. Proximity says nothing about whether price will reach it.")

        table.cell(panel, 0, row + 1, f_key(i), text_color = f_lvColor(i), bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipRowLevel)
        table.cell(panel, 1, row + 1, f_lifeName(st), text_color = st == 5 ? TE_TEXT_MUTED : TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipRowState)
        table.cell(panel, 2, row + 1, compact ? "" : f_px(math.abs(dist)), text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipRowDist)

    table.set_position(panel, f_panelPos(panelPos))

// ════════════════════════════════ ALERTS ════════════════════════════════
//
// STATE-CHANGE ONLY, and on CLOSED BARS ONLY — a level tool that notifies on every touch of every
// one of eleven levels is a tool you mute within a day, and a muted alert is worse than no alert
// because you believe you are covered.
//
// So there are exactly two, and they are the two transitions that change what a level MEANS: a break
// and a reclaim. A touch changes nothing about the level's state and does not fire.
//
// Both mechanisms are here on purpose, because they are not interchangeable:
//   alertcondition() makes the alert DISCOVERABLE in TradingView's own dialog, so it can be armed
//     from the UI without reading any documentation.
//   alert() carries the DYNAMIC text, so the message can name WHICH level moved and to what.
//
// ⚠️ Whichever you arm: a TradingView alert freezes the INPUTS as they were when you created it. If
// you later change the retirement setting or switch a level group off, the running alert keeps using
// the old settings until you recreate it. That is TradingView's behaviour for every script.

// Tracking every one of eleven levels' previous state would cost eleven more series for very little:
// what a reader wants from an alert is "a level broke" or "a level was reclaimed", with the name in
// the text. So the transition is detected across the whole set, and the message names the levels.
brokeNow = false
reclaimedNow = false
brokeNames = ""
reclaimNames = ""

var array<int> prevState = array.new_int(11, -1)

if barstate.isconfirmed
    for i = 0 to 10
        int st = array.get(lvState, i)
        int was = array.get(prevState, i)
        if f_groupShown(f_group(i)) and st >= 0 and was >= 0 and st != was
            if st == 2 or st == 3
                brokeNow := true
                brokeNames := brokeNames == "" ? f_key(i) : brokeNames + ", " + f_key(i)
            if st == 4
                reclaimedNow := true
                reclaimNames := reclaimNames == "" ? f_key(i) : reclaimNames + ", " + f_key(i)
        array.set(prevState, i, st)

alertcondition(brokeNow, title = "A prior level was broken", message = "A previous-session level closed through on {{ticker}} {{interval}}. See the readout for which level and its new state.")
alertcondition(reclaimedNow, title = "A prior level was reclaimed", message = "A previous-session level was reclaimed on {{ticker}} {{interval}}. See the readout for which level and its new state.")

if brokeNow
    alert("TE STRUCT-P — " + syminfo.ticker + " " + timeframe.period + " closed through " + brokeNames + ".", alert.freq_once_per_bar_close)

if reclaimedNow
    alert("TE STRUCT-P — " + syminfo.ticker + " " + timeframe.period + " reclaimed " + reclaimNames + ".", alert.freq_once_per_bar_close)

// ── the rail, last line, where it is never edited away by accident ───────────────────────────────
// Decision support. This is not financial advice, and nothing here is a recommendation to buy or
// sell anything.
````
