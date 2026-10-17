# TE Session Boundaries Opening Range Initial Balance 

- url: https://www.tradingview.com/script/S7uwcORO-TE-Session-Boundaries-Opening-Range-Initial-Balance/
- type: indicator
- pine_id: PUB;7ea09c88d4764af7821b894e012e5ceb
- version: 1.0

## Description

TE Session Boundaries, Opening Range & Initial Balance maps the active trading session, Opening Range (OR) and Initial Balance (IB) using the instrument’s own exchange session and timezone.

https://www.tradingview.com/x/lr5PlyGi/

The goal is simple: define session structure correctly and consistently, independent of chart timeframe.

https://www.tradingview.com/x/AicBx8F1/

This is a structural measurement tool, not a directional signal. It tracks what price has already done around the session’s defined boundaries.

https://www.tradingview.com/x/poWe2Igr/

SESSION TIME

By default, session boundaries come from the symbol’s exchange-defined regular session and exchange timezone. Custom exchange-local sessions are also supported.

The calculations do not rely on fixed UTC offsets, so daylight-saving changes do not shift the intended local session boundary.

OPENING RANGE

For a window R:

OR_high = max(H_t)
OR_low = min(L_t)

for:

open ≤ t < open + R

OR_width = OR_high - OR_low

The default Opening Range is 30 minutes.

The range is defined by elapsed time rather than bar count. A 30-minute Opening Range therefore represents the same session interval whether viewed on a 1-minute, 5-minute or 15-minute chart.

INITIAL BALANCE

The Initial Balance uses the same time-based approach:

IB_high = max(H_t)
IB_low = min(L_t)

for:

open ≤ t < open + 60 minutes

The default is the traditional 60-minute Initial Balance, or the first two 30-minute periods.

OR and IB remain separate structures. If both are configured to the same window, the indicator recognizes that they coincide rather than drawing duplicate ranges.

RANGE LIFECYCLE

Each range can progress through:

FORMING — the measurement window is still open.

SET — the window has completed.

BROKEN ABOVE — a confirmed bar closes above the completed range.

BROKEN BELOW — a confirmed bar closes below the completed range.

RECLAIMED — after a break, a confirmed bar closes back inside the range.

EXPIRED — the session has ended.

These states describe price relative to the range. They are not trade signals.

SHORT SESSIONS

If a session ends before a configured range window completes, the partial range is retained and identified as SHORT rather than being presented as a completed range.

READOUT

The on-chart panel displays the session, exchange timezone, session open, OR and IB levels, widths, lifecycle states and elapsed session time.

Displayed times can be shown in Exchange time or UTC. This changes display only; the underlying calculations remain anchored to the exchange session.

CUSTOMIZATION

The indicator includes configurable OR and IB windows, custom exchange-local sessions, Dark and Light themes, multiple table positions, compact mode and optional range-edge labels.

SCOPE

Session and timezone information are derived from the symbol. The script uses zero request.security() calls, so the session structures do not depend on a higher-timeframe request layer.

WHAT IT DOES NOT DO

It does not predict price, generate directional forecasts, identify entries, set stops or targets, or assign probabilities to range breaks.

BROKEN ABOVE, BROKEN BELOW and RECLAIMED describe confirmed price behavior around completed session structure. They are observations, not instructions to trade.

TE Session Boundaries, Opening Range & Initial Balance is designed to provide a clean, technically consistent view of the trading day: exchange-aware session boundaries, time-defined OR and IB ranges, and a clear lifecycle showing how those structures develop.

## Source Code

````pine
//@version=6
// TE SESSION / OPENING RANGE / INITIAL BALANCE — EXCHANGE-TIMEZONE ANCHORED  (catalog TE-002)
// This source code is subject to the terms of the TRADERS EDGE license — all rights reserved. Distributed on
// TradingView as a protected / Public; not for resale, or reverse engineering.
// THE QUESTION: what happened at the open, and which session references matter now?
//
// THE PROBLEM WITH THE CLASSIC: session boxes and OR/IB tools are everywhere, and the complaint
// about them is always the same three things — the boundaries are wrong twice a year, the chart ends
// up covered in levels from sessions nobody is trading any more, and you cannot tell what a given
// line actually IS once it is drawn.
//
// WHAT THIS ADDS, AND ONLY THIS: it is RIGHT where the alternatives are wrong, and it says what
// every level is. There is no new indicator here and no claim to predict anything.
//
// 🔴 THIS PRODUCT MAKES NO ADDED-VALUE CLAIM, AND THAT IS THE DESIGN, NOT AN OMISSION.
//   A session box is arithmetic on an exchange calendar. Inventing a percentile, a "session quality
//   score" or a breakout probability to make it feel like more of a product would be exactly the
//   overreach the rest of this catalog's evidence discipline exists to prevent. Its quality bar is
//   correctness, which means the TESTS are the product:
//   daemons/sim/te-session/te-session.test.mjs, and every case in it is named in the spec.
//
// HOW THE CLOCK WORKS — the whole product, really:
//   Every boundary resolves through PINE'S SESSION MODEL in `syminfo.timezone`, the instrument's own
//   exchange zone. Nothing here adds or subtracts hours from anything.
//
//   A UTC OFFSET IS A BUG, NOT A SETTING. An offset is correct for part of the year and wrong for
//   the rest, and the wrongness shows up on two weekends a year, in someone else's timezone, months
//   after it shipped. Northern and southern daylight saving do not move together, and some exchanges
//   never observe it at all.
//
//   Measured against the timezone database in the logic mirror, not assumed:
//     · a US spring-forward and fall-back weekend — the session opens at the same LOCAL time on both
//       sides, at two DIFFERENT UTC hours, and the regular session is 6.5 hours of real time on both
//     · a zone whose daylight-saving dates differ from America's — between 8 and 29 March 2026
//       New York and London are 4 hours apart, not 5
//     · a southern-hemisphere zone, which moves the opposite way at the opposite time of year
//     · zones that never observe it, and a zone at a 30-minute offset
//     · a wall-clock time inside the spring-forward gap, which simply does not exist and is reported
//       as absent rather than silently moved to the next hour
//
//   AND ONE THING THE SPEC GOT SLIGHTLY WRONG, WHICH THE TESTS CORRECTED: "no session is 23 or 25
//   hours long" is right for a regular session and WRONG for a 24-hour market. A continuous
//   instrument genuinely has a 23-hour day on spring-forward and a 25-hour day on fall-back. What
//   must not move is the LOCAL boundary, and it does not. (For CME futures the question never
//   arises: both US transitions happen at 02:00 on a Sunday, inside the weekend break.)
//
// WHAT IT DRAWS: the current session's open, its Opening Range, and its Initial Balance. That is the
// default and it is deliberately small — "too many unrelated levels" is half of the stated problem,
// and prior-session references are a different product's job, not this one's.
//
// THE LIFECYCLE: every range is FORMING while its window is open, SET when the window closes, and
// then BROKEN ABOVE / BROKEN BELOW / RECLAIMED as closed bars trade through it, EXPIRED at the end
// of the session.
//
//   ⚠️ RECLAIMED IS A FACT, NOT A SIGNAL. It says a closed bar came back inside a range it had closed
//   outside of. It is not a setup and it does not predict anything. Reclaim logic that MEANS
//   something is a different product entirely, and no copy here implies otherwise.
//
// HOW IT DECIDES: the forming range updates live, because a range that is still forming genuinely is
// changing, and it is labelled FORMING so the reader knows why. Everything else — the range becoming
// final, every break, every reclaim and every alert — is decided inside `barstate.isconfirmed`, on
// closed bars only. This script contains ZERO request.security calls, so there is no
// higher-timeframe repaint surface at all.
//
// THE HOVER LAYER: every value on this chart explains itself when you hover it — what it is, how it
// is computed, and what it does not tell you. That is the house standard across the whole fleet.
//   ⚠️ A touchscreen has no hover state. Anything that must be readable on a phone is PRINTED, not
//   hidden in a tooltip.
//
// LOGIC SOURCE OF TRUTH: daemons/sim/te-session/te-session.mjs, pinned by te-session.test.mjs. This
// file is a transliteration of that mirror; if the two ever disagree, the mirror is right.
//
// ── IP PROVENANCE ───────────────────────────────────────────────────────────────────────────────
// PUBLIC MATH — the Opening Range (the extremes of the first R minutes after the open) and the
//   market-profile Initial Balance (the first hour of the regular session, i.e. the first two
//   30-minute periods). Both are standard, widely documented conventions, implemented from the
//   convention itself and from Pine's own session model.
// INDEPENDENTLY DERIVED — the lifecycle state machine, the short-window marking and the session
//   provenance labelling. Derived from the behavioural spec at
//   docs/findings/2026-09-23-te-002-session-or-ib-spec.md, which was committed before any line of
//   this file existed. No third-party script was read, ported or paraphrased for any of it.
// ORIGINAL — the TE design kit block below and the house tag, generated from
//   daemons/forge/design-kit.mjs.
// LEFT OUT RATHER THAN GUESSED AT — any claim that an Opening Range break, an Initial Balance break
//   or a reclaim predicts anything. That is an open research question and it does not get drawn on a
//   chart until the evidence exists.
//
// Decision support only. No order is placed, no target is promised, no outcome is claimed.

indicator("TE Session Boundaries, Opening Range & Initial Balance — Exchange-Timezone Anchored", "TE SESS-OR", overlay = true, max_boxes_count = 12, max_labels_count = 24, max_lines_count = 12)

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

gSess = "SESSION DEFINITION"
useSymSess = input.bool(true, "Use the symbol's own regular session", group = gSess, tooltip = "ON: the session comes from syminfo.session_regular — the exchange's own declared regular hours for this instrument, resolved in syminfo.timezone. This is the correct default for every symbol and it is why nothing here needs configuring per market. OFF: the custom session below is used instead. Either way the boundary is resolved through Pine's session model and the exchange's timezone database, never through a UTC offset, because an offset is right for part of the year and wrong for the rest.")
custSess = input.session("0930-1600", "Custom session (exchange local time)", group = gSess, tooltip = "A wall-clock session in the EXCHANGE's own local time, as HHMM-HHMM. It is interpreted in syminfo.timezone, so daylight saving is handled by the timezone database rather than by arithmetic. A start later than the end means an overnight session that closes on the following day, which is how most futures trade. Only used when the symbol's own session is switched off above.")
dispTz = input.string("Exchange", "Print times in", options = ["Exchange", "UTC"], group = gSess, tooltip = "Which clock the PRINTED times are shown in. This changes display only: every boundary is still COMPUTED in the exchange's own timezone, because a session is a fact about an exchange and not about the reader. There are two options here rather than three on purpose — Pine cannot read the timezone you have set on your chart, so an option called Chart would have had to quietly fall back to the exchange zone, and a setting that lies about what it does is worse than a setting that is missing.")

gOr = "OPENING RANGE (OR)"
orMin = input.int(30, "Opening Range window R (minutes)", minval = 1, maxval = 480, group = gOr, tooltip = "Window R for the Opening Range: OR_high = max(high) and OR_low = min(low) over the bars whose time t satisfies open <= t < open + R. The window is defined by TIME, not by a bar count, so a gap in the feed cannot shorten it and changing the chart timeframe cannot change what the Opening Range IS. The common presets are 5, 15, 30 and 60 minutes; 30 is the fleet default.")
showOr = input.bool(true, "Draw the Opening Range", group = gOr, tooltip = "Draws the Opening Range as a zone with its high and low labelled. Switch it off to keep only the Initial Balance and the session open.")

gIb = "INITIAL BALANCE (IB)"
showIb = input.bool(true, "Draw the Initial Balance", group = gIb, tooltip = "The Initial Balance is the market-profile convention: the range of the first hour of the regular session, that is the first two 30-minute periods. IB_high = max(high) and IB_low = min(low) over open <= t < open + 60min. It is reported separately from the Opening Range because they are different objects with different conventions, and a tool that silently conflates them is one of the reasons people distrust these scripts.")
ibMin = input.int(60, "Initial Balance window (minutes)", minval = 1, maxval = 480, group = gIb, tooltip = "The Initial Balance window, 60 minutes by convention. It is exposed rather than fixed because some desks use a different first period, but moving it away from 60 means the number you are reading is no longer the market-profile Initial Balance that everyone else means by the term. When this equals the Opening Range window the two coincide, and the panel says so rather than drawing two identical zones.")

gPanel = "READOUT"
showPanel = input.bool(true, "Show readout table", group = gPanel, tooltip = "The readout table: the session and the timezone it was resolved in, the session open, both ranges with their widths and their lifecycle states, and how long the session has been running. Every row explains itself on hover.")
panelPos = input.string("Top right", "Table anchor", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gPanel, tooltip = "Where the readout table is anchored on the chart. Move it if it overlaps something you need to read.")
compact = input.bool(false, "Compact mode (reduced rows)", group = gPanel, tooltip = "Reduces the table to the session, the Opening Range state and the Initial Balance state, for small screens. It also steps the font down one size. Use it on a phone, where there is no hover state and only the printed rows can be read.")
showTags = input.bool(true, "Label range edges on the chart", group = gPanel, tooltip = "Draws the house tag on each range edge: one state word, one price, monospaced, with the full explanation on hover. Switch it off for a clean chart — the readout table carries the same numbers.")

// ════════════════════════════════ THE ENGINE ════════════════════════════════
//
// A transliteration of daemons/sim/te-session/te-session.mjs. Read that file for the reasoning and
// for the DST cases it is tested against; this one is the same algorithm in Pine's vocabulary.

// ── the lifecycle vocabulary, in ONE place ────────────────────────────────────────────────────────
// Spelled once as a function rather than at every call site, because a state word that appears twice
// is a state word that will eventually differ from itself. A test parses this function and asserts
// it equals the mirror's LIFECYCLE array, in order — TE-001 proved a product can disagree with its
// own source of truth while every other check stays green.
f_lifeName(int i) =>
    i == 0 ? "FORMING" : i == 1 ? "SET" : i == 2 ? "BROKEN ABOVE" : i == 3 ? "BROKEN BELOW" : i == 4 ? "RECLAIMED" : i == 5 ? "EXPIRED" : "—"

// ── the session, resolved through the exchange's own clock ────────────────────────────────────────
// `session.ismarket` is TradingView's own answer to "is this bar inside this instrument's regular
// trading session", taken from the exchange's declared hours. It needs no session string, no hour
// literal and no timezone argument, because the exchange's calendar and its daylight-saving rules
// are already inside it. That makes it strictly better than passing hours around: there is no offset
// anywhere in this file that could be right in June and wrong in December.
//
// 🔑 THE FIRST DRAFT OF THIS REACHED FOR `syminfo.session_regular`, WHICH DOES NOT EXIST. Every JS
// test and all seventeen fleet rules were green; the server compile said "undeclared identifier" and
// that was the only thing in the toolchain that knew. Compile is not runtime — and a static check is
// not a compiler either.
//
// The custom path still goes through Pine's session model in syminfo.timezone, so it obeys the same
// rule: a wall clock in the exchange's zone, never an offset.
inSess = useSymSess ? session.ismarket : not na(time(timeframe.period, custSess, syminfo.timezone))

// ── the anchor for a market that never closes ─────────────────────────────────────────────────────
// A 24-hour instrument never leaves its session, so "the session opened" cannot come from a bell
// that never rings — it has to come from the exchange's CALENDAR DAY, in the exchange's own zone.
//
// ⚠️ But a calendar day cannot be the anchor in general: local midnight falls INSIDE an overnight
// futures session, so anchoring on it there would restart the Opening Range in the middle of the
// night. So the calendar anchor is used ONLY while this script has never once observed the session
// close. The moment a real close is seen, the bell wins and the calendar is ignored for good.
var bool everClosed = false
if not inSess
    everClosed := true
newLocalDay = dayofmonth(time, syminfo.timezone) != dayofmonth(time[1], syminfo.timezone)

newSess = (inSess and not inSess[1]) or (inSess and newLocalDay and not everClosed and not na(time[1]))
sessEnded = not inSess and inSess[1]

// ── state ─────────────────────────────────────────────────────────────────────────────────────────
var int openTs = na
var float sessHi = na
var float sessLo = na

var float orHi = na
var float orLo = na
var int orState = 0
var bool orDone = false
var bool orShort = false
var int orSide = 0          // 0 none · 1 above · -1 below

var float ibHi = na
var float ibLo = na
var int ibState = 0
var bool ibDone = false
var bool ibShort = false
var int ibSide = 0

if newSess
    openTs := time
    sessHi := high
    sessLo := low
    orHi := na
    orLo := na
    orState := 0
    orDone := false
    orShort := false
    orSide := 0
    ibHi := na
    ibLo := na
    ibState := 0
    ibDone := false
    ibShort := false
    ibSide := 0

// ── the windows are defined by TIME, never by a bar count ─────────────────────────────────────────
// A missing bar must not shorten a window, and changing the chart timeframe must not change what the
// Opening Range IS. Counting bars breaks both, and it is the commonest way these tools go wrong.
orEndTs = na(openTs) ? na : openTs + orMin * 60000
ibEndTs = na(openTs) ? na : openTs + ibMin * 60000
inOr = inSess and not na(orEndTs) and time < orEndTs
inIb = inSess and not na(ibEndTs) and time < ibEndTs

if inSess
    sessHi := na(sessHi) ? high : math.max(sessHi, high)
    sessLo := na(sessLo) ? low : math.min(sessLo, low)

if inOr
    orHi := na(orHi) ? high : math.max(orHi, high)
    orLo := na(orLo) ? low : math.min(orLo, low)
    orState := 0
else if inSess and not orDone and not na(orHi)
    orDone := true
    orState := 1

if inIb
    ibHi := na(ibHi) ? high : math.max(ibHi, high)
    ibLo := na(ibLo) ? low : math.min(ibLo, low)
    ibState := 0
else if inSess and not ibDone and not na(ibHi)
    ibDone := true
    ibState := 1

// ── breaks and reclaims: CLOSED BARS ONLY ─────────────────────────────────────────────────────────
// The forming range moves intrabar because it genuinely is still forming. Nothing else does. A break
// that appeared and vanished inside a bar would be the repaint that makes people stop trusting a
// tool, and it is why every state below is decided under barstate.isconfirmed.
var bool orChanged = false
var bool ibChanged = false
orChanged := false
ibChanged := false

if barstate.isconfirmed and inSess
    if orDone and not na(orHi)
        int was = orState
        if close > orHi and orSide != 1
            orState := 2
            orSide := 1
        else if close < orLo and orSide != -1
            orState := 3
            orSide := -1
        else if close <= orHi and close >= orLo and orSide != 0
            orState := 4
            orSide := 0
        orChanged := orState != was
    if ibDone and not na(ibHi)
        int wasI = ibState
        if close > ibHi and ibSide != 1
            ibState := 2
            ibSide := 1
        else if close < ibLo and ibSide != -1
            ibState := 3
            ibSide := -1
        else if close <= ibHi and close >= ibLo and ibSide != 0
            ibState := 4
            ibSide := 0
        ibChanged := ibState != wasI

// ── the session ends ──────────────────────────────────────────────────────────────────────────────
// A window that never got the minutes it needed is SHORT and says so. On an early close the Initial
// Balance may have had forty minutes instead of sixty: the range is real and still worth drawing, it
// is simply not an hour, and printing "IB" over it without saying so would be silently wrong in
// exactly the way that makes people distrust these scripts.
if sessEnded
    if not na(orHi) and not orDone
        orShort := time < orEndTs
        orDone := true
    if not na(ibHi) and not ibDone
        ibShort := time < ibEndTs
        ibDone := true
    orState := 5
    ibState := 5

// ── the derived readouts ──────────────────────────────────────────────────────────────────────────
orWidth = na(orHi) or na(orLo) ? na : orHi - orLo
ibWidth = na(ibHi) or na(ibLo) ? na : ibHi - ibLo
coincide = orMin == ibMin
elapsedMin = na(openTs) or not inSess ? na : math.floor((time - openTs) / 60000)

// The display clock — PRINTING only. The computation above never reads this.
//
// 🔑 THERE ARE TWO OPTIONS HERE AND NOT THREE, AND THAT IS HONESTY RATHER THAN A LIMITATION: Pine
// cannot read the timezone the USER has set on their chart. A third option called "Chart" would have
// had to quietly resolve to the exchange zone, which is a setting that lies about what it does. It
// was cut instead.
dispTzStr = dispTz == "UTC" ? "UTC" : syminfo.timezone
f_hhmm(int ts) =>
    na(ts) ? "—" : str.format("{0,number,00}:{1,number,00}", hour(ts, dispTzStr), minute(ts, dispTzStr))

// his phrase, and a real feature: every level says WHICH DEFINITION produced it. The commonest
// complaint about these tools is not being able to tell what a line actually is.
provenance = (useSymSess ? "EXCHANGE REGULAR" : "CUSTOM") + "  ·  " + syminfo.timezone + "  ·  OR " + str.tostring(orMin) + "m  ·  IB " + str.tostring(ibMin) + "m" + (coincide ? "  (OR = IB)" : "")

// ════════════════════════════════ WHAT IS DRAWN ════════════════════════════════
//
// The default is THE CURRENT SESSION ONLY. "Too many unrelated levels" is half of the stated problem
// with these tools, and prior-session references belong to a different product. Drawing them here is
// the duplication that makes a chart unreadable.
//
// ── the colour decision, stated plainly ──────────────────────────────────────────────────────────
// NO RANGE USES TE_BULL OR TE_BEAR while it is forming or set. A green Opening Range and a red one
// would say the range itself is bullish or bearish, which is a claim this product does not make and
// has no evidence for. Direction colour appears ONLY on a break, where it is a statement of fact
// about where a bar closed — not a forecast about what happens next.
//
// NO RANGE USES BRAND GOLD. Doc 29 §9.2 is verbatim: gold is not good, bullish, actionable or high
// confidence. It is brand and selection only.
f_stateCol(int st) =>
    st == 0 ? TE_DEVELOPING : st == 1 ? TE_STRUCTURE : st == 2 ? TE_BULL : st == 3 ? TE_BEAR : st == 4 ? TE_ATTENTION : TE_INACTIVE

// ── THE HOVER LAYER, AND IT IS A TEACHING LAYER ───────────────────────────────────────────────────
// Every value on this chart explains itself, through the kit's `teTeach` and its four clauses:
//
//     what it reads  ·  how it is computed  ·  why that information matters  ·  what it does not tell you
//
// His schema, ruled 2026-09-23 11:28. Plain language opens and the maths is second; the last clause
// is never dropped, because a readout that explains what it is and hides what it cannot do is how
// people come to trust a number too much. NOT "why it works" — he rejected that framing, because it
// presupposes that it works, which is a claim this product does not make and is not measured to.
//
// 🕹️ THE CLAUSES ARE COMPOSED ON THE BAR, not written in advance. That is what makes the hover a
// lesson about the reader's own chart — "the opening range ran 5,912.25 to 5,927.50, 15.25 points
// wide" rather than "the opening range is the high and low of the first R minutes." It costs
// nothing: every number in the sentence was already computed for the row beside it.
//
// ⚠️ The composition is GUARDED on barstate.islast rather than built inside the drawing block,
// because two different blocks consume these — the tags at the range edges and the panel. Guarding
// at the top is the cheap way to have one definition with two consumers.
//
// ⚠️ A touchscreen has no hover state, so anything that must be readable on a phone is PRINTED in the
// cell, not hidden behind it. The tooltips below are the depth, never the only copy of the fact.
tipSess = not barstate.islast ? "" : teTeach(
  "These levels belong to the " + provenance + " session, resolved in " + syminfo.timezone + " — the exchange's own clock for this symbol, not yours and not the chart's.",
  "The boundaries come from Pine's session model applied to the exchange's declared hours, so daylight saving is handled by the timezone database rather than by adding or subtracting an hour somewhere.",
  "Every level below is only as trustworthy as the session definition behind it. Most session tools quietly use a fixed UTC offset, which is right for part of the year and wrong for the rest — so this row tells you which definition produced the lines you are looking at.",
  "It says nothing about whether this session is a good one to trade, and nothing about what price will do inside it.")

tipOpen = not barstate.islast ? "" : teTeach(
  "This session opened at " + f_hhmm(openTs) + " " + dispTzStr + (na(elapsedMin) ? "" : ", which was " + str.tostring(elapsedMin) + " minutes ago") + ".",
  "Every window below is measured from this instant in TIME, not in bars: open <= t < open + R. A gap in the feed therefore cannot shorten a window, and changing the chart timeframe cannot change what a range IS.",
  "Bar-counted ranges are the most common quiet error in this family of tools — the same \"30-minute range\" comes out different on a 1-minute and a 5-minute chart. Measuring in time is why the levels here do not move when you change timeframe.",
  "It is a boundary, not an event. Nothing about the open being here rather than there makes the next bar more or less likely to do anything.")

tipOr = not barstate.islast ? "" : teTeach(
  na(orHi) ? "The opening range has not formed yet on this chart." : "The opening range is " + f_lifeName(orState) + (orShort ? " and SHORT — the session ended before the window completed" : "") + ": " + str.tostring(orLo, format.mintick) + " to " + str.tostring(orHi, format.mintick) + ", " + str.tostring(orWidth, format.mintick) + " points wide over the first " + str.tostring(orMin) + " minutes.",
  "OR high = max(high) and OR low = min(low) over the bars whose time t satisfies open <= t < open + " + str.tostring(orMin) + "min. FORMING while the window is open, SET once it closes, BROKEN ABOVE or BROKEN BELOW when a closed bar trades beyond an edge, and RECLAIMED when a closed bar comes back inside.",
  "The first minutes of a session are where the day's initial agreement on price gets made, so the edges of that range are the levels the rest of the session is measured against. The lifecycle word tells you which of those things has already happened today.",
  "Every one of those words is a statement about where a bar CLOSED. None of them is a signal, a setup or a prediction, and a BROKEN range is not a reason to do anything.")

tipIb = not barstate.islast ? "" : teTeach(
  coincide ? "The initial balance is set to the same window as the opening range, so it is not drawn separately." : na(ibHi) ? "The initial balance has not formed yet on this chart." : "The initial balance is " + f_lifeName(ibState) + (ibShort ? " and SHORT — a half day ended the session before the window completed" : "") + ": " + str.tostring(ibLo, format.mintick) + " to " + str.tostring(ibHi, format.mintick) + ", " + str.tostring(ibWidth, format.mintick) + " points over the first " + str.tostring(ibMin) + " minutes.",
  "IB high = max(high) and IB low = min(low) over open <= t < open + " + str.tostring(ibMin) + "min. The market-profile convention is 60 minutes, the first two 30-minute periods.",
  "It is the wider, slower cousin of the opening range, and it is kept separate on purpose: they are two different conventions, and tools that quietly conflate them are why people stop trusting this family of indicator.",
  "If the session ends before the window completes, the range is still drawn and marked SHORT rather than presented as a full hour. It is a measurement, not a signal.")

tipWidth = not barstate.islast ? "" : teTeach(
  "The opening range is " + str.tostring(orWidth, format.mintick) + " points wide and the initial balance is " + str.tostring(ibWidth, format.mintick) + ", in this instrument's own points.",
  "high - low across each window. The tick size and point value come from the symbol, so this reads correctly on a future, a stock or an FX cross with nothing configured.",
  "Width is the fastest read on what kind of session this is: a narrow opening range and a wide one are different days, and the number is what lets you compare today with the last twenty without guessing from the picture.",
  "It is a measurement of what has already happened. It is not a stop distance and it is not a target.")

tipElapsed = not barstate.islast ? "" : teTeach(
  na(elapsedMin) ? "The session is not open right now, so nothing has elapsed." : "This session has been open for " + str.tostring(elapsedMin) + " minutes.",
  "The whole minutes from the session open to the current bar's time, measured in time rather than counted in bars.",
  "A level is only as meaningful as the amount of session behind it. A range set in the first ten minutes of a quiet morning is not the same object as one set over four hours, and this is the row that tells you which you are holding.",
  "It measures duration, nothing else. A long session is not a more reliable one, and this number does not weight or grade any level above.")

// ── the zones ─────────────────────────────────────────────────────────────────────────────────────
// 🔴 A BOX CANNOT CARRY A TOOLTIP. Measured with the compiler, not assumed: `box.new(tooltip = ...)`
// is a compile error — the function has no argument of that name. So a zone's explanation rides on
// its anchor TAG, which is why every range edge is tagged rather than left as a bare box. Any spec
// that says "hover the zone" is describing something Pine cannot do.
var box orBox = na
var box ibBox = na

if barstate.islast
    if not na(orBox)
        box.delete(orBox)
    if not na(ibBox)
        box.delete(ibBox)
    if showIb and not na(ibHi) and not coincide
        ibBox := box.new(math.max(0, bar_index - 300), ibHi, bar_index, ibLo, border_color = f_stateCol(ibState), border_width = TE_W_CONTEXT, bgcolor = teZone(f_stateCol(ibState), "context"))
    if showOr and not na(orHi)
        orBox := box.new(math.max(0, bar_index - 300), orHi, bar_index, orLo, border_color = f_stateCol(orState), border_width = TE_W_STANDARD, bgcolor = teZone(f_stateCol(orState), "plan"))

// ── the tags ──────────────────────────────────────────────────────────────────────────────────────
// The house tag: ONE state word, ONE price, monospaced, with the explanation on hover. Doc 29 §12 —
// "one noun/state; optionally one price; optionally one decisive qualifier." Everything else that
// could be said about this level is in the tooltip, where it belongs.
var label tagHi = na
var label tagLo = na

if barstate.islast
    if not na(tagHi)
        label.delete(tagHi)
    if not na(tagLo)
        label.delete(tagLo)
    if showTags and showOr and not na(orHi)
        tagHi := teTag(bar_index, orHi, f_lifeName(orState), str.tostring(orHi, format.mintick), teZone(TE_SURFACE_HI, "plan"), TE_TEXT, tipOr)
        tagLo := teTag(bar_index, orLo, f_lifeName(orState), str.tostring(orLo, format.mintick), teZone(TE_SURFACE_HI, "plan"), TE_TEXT, tipOr)

// ── the data window channels ─────────────────────────────────────────────────────────────────────
// display.data_window rather than display.none on purpose: none of these should draw on the chart,
// but all of them should be readable in the Data Window and bindable by another script.
plot(orHi, "OR high", display = display.data_window)
plot(orLo, "OR low", display = display.data_window)
plot(orWidth, "OR width", display = display.data_window)
plot(orState, "OR lifecycle (0-5)", display = display.data_window)
plot(ibHi, "IB high", display = display.data_window)
plot(ibLo, "IB low", display = display.data_window)
plot(ibWidth, "IB width", display = display.data_window)
plot(ibState, "IB lifecycle (0-5)", display = display.data_window)
plot(elapsedMin, "Session elapsed (min)", display = display.data_window)

// ── the panel ─────────────────────────────────────────────────────────────────────────────────────
f_panelPos(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

var table panel = table.new(position.top_right, 2, 7, border_width = 1)

if showPanel and barstate.islast
    txtSize = compact ? size.small : size.normal
    table.clear(panel, 0, 0, 1, 6)
    table.cell(panel, 0, 0, "SESSION", text_color = TE_TEXT, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipSess)
    table.cell(panel, 1, 0, provenance, text_color = TE_TEXT_2, bgcolor = TE_SURFACE_HI, text_size = txtSize, tooltip = tipSess)

    table.cell(panel, 0, 1, "OR " + str.tostring(orMin) + "m", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipOr)
    table.cell(panel, 1, 1, f_lifeName(orState) + (orShort ? "  ·  SHORT" : "") + "  ·  " + f_px(orLo) + " - " + f_px(orHi), text_color = f_stateCol(orState), bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipOr)

    table.cell(panel, 0, 2, coincide ? "IB (= OR)" : "IB " + str.tostring(ibMin) + "m", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipIb)
    table.cell(panel, 1, 2, coincide ? "same window as OR" : f_lifeName(ibState) + (ibShort ? "  ·  SHORT" : "") + "  ·  " + f_px(ibLo) + " - " + f_px(ibHi), text_color = f_stateCol(ibState), bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipIb)

    if not compact
        table.cell(panel, 0, 3, "Session open", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipOpen)
        table.cell(panel, 1, 3, f_hhmm(openTs) + "  " + dispTz, text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipOpen)

        table.cell(panel, 0, 4, "OR width", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipWidth)
        table.cell(panel, 1, 4, f_px(orWidth) + " pts", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipWidth)

        table.cell(panel, 0, 5, "IB width", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipWidth)
        table.cell(panel, 1, 5, f_px(ibWidth) + " pts", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipWidth)

        table.cell(panel, 0, 6, "Elapsed", text_color = TE_TEXT_2, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipElapsed)
        table.cell(panel, 1, 6, na(elapsedMin) ? "—" : str.tostring(elapsedMin) + " min", text_color = TE_TEXT, bgcolor = TE_SURFACE, text_size = txtSize, tooltip = tipElapsed)

    table.set_position(panel, f_panelPos(panelPos))

// ════════════════════════════════ ALERTS ════════════════════════════════
//
// LIFECYCLE TRANSITIONS ONLY, and on CLOSED BARS ONLY. Never an every-bar alert: a session tool that
// notifies you on every bar is a tool you mute in a week, and a muted alert is worse than no alert
// because you believe you are covered.
//
// ⚠️ AND THE THING THESE ALERTS ARE NOT: a break of the Opening Range is a statement that a bar
// closed beyond an edge. It is not an entry, it is not a setup, and it carries no evidence that
// anything follows from it. The alert says what happened, in the same words the chart says it.
//
// ⚠️ Whichever you arm: a TradingView alert freezes the INPUTS as they were when you created it. If
// you later change the Opening Range window, the running alert keeps firing on the old one until you
// recreate it. That is TradingView's behaviour for every script, not this one's.

alertcondition(orChanged, title = "Opening Range lifecycle changed", message = "Opening Range lifecycle changed on {{ticker}} {{interval}} — see the readout for the new state.")
alertcondition(ibChanged, title = "Initial Balance lifecycle changed", message = "Initial Balance lifecycle changed on {{ticker}} {{interval}} — see the readout for the new state.")

if orChanged and barstate.isconfirmed
    alert("TE SESS-OR — " + syminfo.ticker + " " + timeframe.period + " Opening Range is now " + f_lifeName(orState) + ". Range " + f_px(orLo) + " to " + f_px(orHi) + ", " + provenance, alert.freq_once_per_bar_close)

if ibChanged and barstate.isconfirmed
    alert("TE SESS-OR — " + syminfo.ticker + " " + timeframe.period + " Initial Balance is now " + f_lifeName(ibState) + ". Range " + f_px(ibLo) + " to " + f_px(ibHi) + ", " + provenance, alert.freq_once_per_bar_close)

// ── the rail, last line, where it is never edited away by accident ───────────────────────────────
// Decision support. This is not financial advice, and nothing here is a recommendation to buy or
// sell anything.
````
