<!-- tradingview-pine-id: PUB;4366e257beb34b01be43f1b23a1c1f00 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Optimal Trade Entry (OTE) Zone Plotter [algotim]

Source: https://www.tradingview.com/script/zgnsZohM-Optimal-Trade-Entry-OTE-Zone-Plotter-algotim/

## Description

Optimal Trade Entry (OTE) Zone Plotter locates the 62%-79% institutional retracement zone of a confirmed impulsive swing and keeps only the single most relevant zone per direction on the chart, fading it through disclosed mitigation states as price interacts with it.

Problem Statement
The Optimal Trade Entry concept, retracing into the 62%-79% region of an impulsive leg before continuation, is a well-known Fibonacci convention, but most public implementations simply plot every Fibonacci level on every swing they detect. This produces charts covered in overlapping retracement boxes, most of which come from insignificant swings that carry no real weight, and gives no visual indication of which zones are still fresh, already tested, or fully invalidated.

This indicator addresses that gap by filtering which swings are allowed to generate a zone in the first place, by showing only the current zone per direction at full strength, and by changing each zone's appearance as price actually interacts with it.

Methodology
Swing highs and lows are identified with ta.pivothigh/ta.pivotlow using a user-defined Pivot Length, so every swing referenced by the script is a confirmed pivot, evaluated only after barstate.isconfirmed is true.

Consecutive pivots of the same type extend a running swing extreme; a leg is only registered when the pivot type alternates (a low following a high, or a high following a low). Each candidate leg must then clear three disclosed checks before it is allowed to create a zone: the leg's price range must reach a minimum multiple of ATR, the swing candle's own body-to-range ratio must reach a minimum threshold, and, if the Break of Structure filter is enabled, the new swing must exceed the prior swing of the same type. Legs that fail any check produce no zone, no label, and no alert.

A qualifying leg generates one OTE zone: the shaded region between the 62% and 79% retracement of that leg, with the 70.5% level drawn as a two-layer glowing midline inside it. Only one bullish and one bearish zone are ever active at a time. When a new qualifying leg forms, the previous zone of that direction is frozen in place and, if enabled, kept as a single low-opacity historical reference rather than removed outright or left overlapping the new zone.

Each active zone tracks its own mitigation state on every confirmed bar: Fresh (untouched), Touched (price has wicked into the 62%-79% region), Mitigated (a confirmed close through the 79% boundary), or Invalidated (a confirmed close back through the leg's own origin point). State can only advance forward, and the zone's fill opacity and border color update automatically at each transition, so the chart communicates a zone's condition without any additional label or panel.

Signal Workflow
Step 1 — a confirmed swing pivot alternates direction, registering a candidate leg from the prior opposite pivot to the new one.
Step 2 — the leg is checked against the Minimum Swing Size, Body Ratio, and optional Break of Structure filters; legs that fail are discarded with no chart output.
Step 3 — a qualifying leg creates a new active OTE zone (62%-79%) with its 70.5% midline, and the previous zone of the same direction is frozen and faded.
Step 4 — the active zone's state advances from Fresh to Touched as price wicks into the zone on a confirmed bar.
Step 5 — the zone advances to Mitigated on a confirmed close through the 79% boundary, or to Invalidated on a confirmed close back through the leg's origin, at which point it is greyed out.
Step 6 — each transition and each zone entry/exit can trigger its own alert, gated by the corresponding toggle in the Alerts group.

Why This Indicator Is Different
Most public OTE/Fibonacci scripts draw a zone for every detected swing regardless of its significance, leaving multiple overlapping retracement boxes on the chart at once.
This script applies a disclosed three-part quality filter (ATR-relative swing size, swing candle body ratio, optional break-of-structure confirmation) before a swing is even allowed to generate a zone.
Only one zone per direction is ever shown at full strength; the prior zone automatically fades to a quiet historical reference the moment a new qualifying swing appears, keeping the chart focused on the current opportunity.
Zone fill opacity and border color are driven entirely by a four-state mitigation engine (Fresh/Touched/Mitigated/Invalidated) computed from confirmed price action against the zone's own boundaries, so the visual state of a zone is informative rather than purely decorative.
The 70.5% equilibrium level is rendered as a two-layer glow line rather than a plain dashed line, giving the zone's mid-point a distinct, non-generic appearance.

Inputs

Swing Detection
Pivot Length
ATR Length

OTE Quality Filter
Minimum Swing Size (x ATR)
Minimum Swing Candle Body Ratio
Require Break of Structure

OTE Zone
Show Bullish OTE Zones
Show Bearish OTE Zones
Zone Extension (bars)
Show Institutional Midline (70.5%)
Fade Previous Zone on New Swing

Visual Settings
Bullish/Bearish Zone Colour
Bullish/Bearish Midline Colour
Label Size

Alerts
Alert: New OTE Zone Created
Alert: Price Entered OTE Zone
Alert: Price Left OTE Zone
Alert: OTE Zone Mitigated
Alert: OTE Zone Invalidated

Alerts
Alerts are available for:
New Bullish/Bearish OTE Zone Created
Price Entered Bullish/Bearish OTE Zone
Price Left Bullish/Bearish OTE Zone
Bullish/Bearish OTE Zone Mitigated
Bullish/Bearish OTE Zone Invalidated

Practical Usage
Treat an active, Fresh OTE zone in the direction of the prevailing structure as a region to watch for a retracement entry, not a standalone entry signal by itself.
Use the Break of Structure filter on trending instruments to restrict zones to swings that genuinely extended structure, and disable it on ranging instruments where internal swings may still be meaningful.
Raise the Minimum Swing Size and Body Ratio filters on lower timeframes or noisy instruments to reduce the number of zones generated.
Watch the zone's fill opacity as a quick visual read of its condition: a bold zone has not been tested, a lighter fill has already been touched or mitigated, and a greyed zone has been invalidated and should generally be disregarded.
Combine the Entered/Exited alerts with your own confirmation criteria (candlestick behavior, lower-timeframe structure, etc.) rather than treating zone entry alone as a trigger.

Limitations
Swing pivots require bars to form on both sides before they confirm, so every zone is inherently placed a Pivot Length number of bars after the actual swing extreme occurred.
The quality filter reduces the number of zones shown but does not evaluate or predict the outcome of any individual retracement.
Only one active zone per direction is displayed at a time; if you want to review multiple historical zones simultaneously, enable "Fade Previous Zone on New Swing" and note that only the single most recent prior zone is retained, not a full history.
As with any retracement-based tool, results will vary across instruments, timeframes, and market regimes.

Notes
This indicator is a zone-location tool intended to highlight the current, quality-filtered Optimal Trade Entry region and its mitigation state through a disclosed, rule-based process.
All swing confirmations, zone creation, mitigation-state transitions, and invalidations are evaluated on confirmed bar closes only, so no element of the script repaints once drawn.
The output is intended to support retracement-based analysis and is not a standalone buy or sell recommendation.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Optimal Trade Entry (OTE) Zone Plotter [algotim]
// Author : algotim
// Version: 1.0.0
//
// ── WHAT THIS SCRIPT DOES ─────────────────────────────────────────
// This is not a Fibonacci drawing tool. It is a zone-location engine
// built around one specific, disclosed institutional convention: the
// 62%-79% retracement of a confirmed impulsive swing, known in ICT
// terminology as the Optimal Trade Entry (OTE). Its job is to answer
// one question — "where is the current statistically favorable
// retracement area, and is it still worth watching?" — and to stop
// cluttering the chart the moment the answer changes.
//
// Every confirmed swing pivot is checked against a disclosed quality
// filter before it is allowed to generate a zone at all. Swings that
// pass generate an OTE zone from the swing's own extreme back toward
// its origin. Only the most recent qualifying zone per direction is
// ever drawn at full strength — the prior one is immediately faded to
// a low-opacity historical reference, so the chart always foregrounds
// the single active opportunity rather than a pile of overlapping
// Fibonacci boxes.
//
// ── CORE INNOVATION 1: OTE QUALITY FILTER ──────────────────────────
// A swing pivot does not create a zone just because ta.pivothigh /
// ta.pivotlow confirmed it. The swing must also clear:
//   • Minimum Swing Size   — the leg's price range vs. a multiple of
//                             ATR, removing insignificant micro-swings.
//   • Body Ratio            — the swing candle's own body-to-range
//                             ratio, removing indecisive, wick-heavy
//                             pivots that rarely represent real
//                             institutional displacement.
//   • Break of Structure    — (optional) requiring the new swing to
//                             exceed the prior swing of the same type,
//                             i.e. a genuine higher high or lower low,
//                             not a minor internal wiggle.
// Swings that fail are simply skipped — no box, no label, no alert.
//
// ── CORE INNOVATION 2: ADAPTIVE ACTIVE ZONE ────────────────────────
// Only one bullish and one bearish OTE zone are ever "live" at a
// time. The instant a new qualifying swing replaces one, the previous
// zone is frozen and faded to a quiet historical tint rather than
// deleted outright or left to compete visually with the new zone.
//
// ── CORE INNOVATION 3: DYNAMIC MITIGATION FILL ─────────────────────
// Zone opacity communicates state at a glance, computed purely from
// confirmed price action against the zone's own boundaries — Fresh
// (untouched, bold fill) → Touched (wicked into the zone) → Mitigated
// (closed through the deep 79% boundary) → Invalidated (closed back
// through the swing's origin, greyed out and deactivated).
//
// ── NON-REPAINTING DESIGN ──────────────────────────────────────────
// ta.pivothigh/ta.pivotlow only confirm once i_pivotLen bars exist on
// both sides of the pivot, and all leg validation, zone creation,
// mitigation tracking and invalidation run inside
// `if barstate.isconfirmed`, evaluated strictly on confirmed closes.
// No element of this script is ever drawn from, or adjusted using, an
// unconfirmed intrabar value.
// ══════════════════════════════════════════════════════════════════

indicator(
     title            = "Optimal Trade Entry (OTE) Zone Plotter [algotim]",
     shorttitle       = "OTE Zone Plotter [algotim]",
     overlay          = true,
     max_bars_back    = 500,
     max_boxes_count  = 50,
     max_lines_count  = 150,
     max_labels_count = 50)

// ──────────────────────────────────────────────────────────────────
// SECTION 1 — INPUTS
// ──────────────────────────────────────────────────────────────────
GRP_SWING = "Swing Detection"
GRP_QUAL  = "OTE Quality Filter"
GRP_ZONE  = "OTE Zone"
GRP_VIS   = "Visual Settings"
GRP_ALERT = "Alerts"

// ── Swing Detection ──────────────────────────────────────────────────
i_pivotLen = input.int(5, "Pivot Length", minval = 2, maxval = 50,
     group   = GRP_SWING,
     tooltip = "Bars required on each side to confirm a swing high/low. A confirmed pivot is only known this many bars after it actually formed — the standard non-repainting pivot configuration.")

i_atrLen = input.int(14, "ATR Length", minval = 2, maxval = 200,
     group   = GRP_SWING,
     tooltip = "ATR period used to size the Minimum Swing Size filter below.")

// ── OTE Quality Filter ─────────────────────────────────────────────────
i_minSwingAtr = input.float(1.0, "Minimum Swing Size (× ATR)",
     minval  = 0.0,
     step    = 0.1,
     group   = GRP_QUAL,
     tooltip = "A swing leg must span at least this many ATR units before it is allowed to generate an OTE zone. Filters out insignificant micro-swings.")

i_minBodyRatio = input.float(0.30, "Minimum Swing Candle Body Ratio",
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GRP_QUAL,
     tooltip = "The swing candle's own body-to-range ratio must reach this minimum. Removes indecisive, wick-heavy pivots that rarely reflect genuine institutional displacement.")

i_requireBOS = input.bool(true, "Require Break of Structure",
     group   = GRP_QUAL,
     tooltip = "When enabled, a new swing high must exceed the prior swing high (and a new swing low must be below the prior swing low) before a zone is created. This confirms the swing is a genuine structural break, not a minor internal wiggle.")

// ── OTE Zone ──────────────────────────────────────────────────────────
i_showBullish = input.bool(true, "Show Bullish OTE Zones", group = GRP_ZONE)
i_showBearish = input.bool(true, "Show Bearish OTE Zones", group = GRP_ZONE)

i_extendBars = input.int(40, "Zone Extension (bars)",
     minval  = 5,
     maxval  = 300,
     group   = GRP_ZONE,
     tooltip = "How many bars forward the active zone, its midline and its origin leg-line extend while still unmitigated.")

i_showMidline = input.bool(true, "Show Institutional Midline (70.5%)",
     group   = GRP_ZONE,
     tooltip = "Draws the 70.5% equilibrium level within the OTE zone as a glowing reference line.")

i_fadeOld = input.bool(true, "Fade Previous Zone on New Swing",
     group   = GRP_ZONE,
     tooltip = "When enabled, the previous OTE zone of the same direction is kept as a quiet, low-opacity historical reference when a new one forms. When disabled, the previous zone is simply removed.")

// ── Visual Settings ───────────────────────────────────────────────────
i_colBull    = input.color(color.new(#00c896, 0), "Bullish Zone Colour", group = GRP_VIS)
i_colBullMid = input.color(color.new(#4dd0e1, 0), "Bullish Midline Colour", group = GRP_VIS)
i_colBear    = input.color(color.new(#ff5c5c, 0), "Bearish Zone Colour", group = GRP_VIS)
i_colBearMid = input.color(color.new(#ffab40, 0), "Bearish Midline Colour", group = GRP_VIS)

i_labelSize = input.string("Small", "Label Size",
     options = ["Tiny", "Small", "Normal"],
     group   = GRP_VIS)

// ── Alerts ────────────────────────────────────────────────────────────
i_alertCreated     = input.bool(true, "Alert: New OTE Zone Created",   group = GRP_ALERT)
i_alertEntered      = input.bool(true, "Alert: Price Entered OTE Zone", group = GRP_ALERT)
i_alertExited        = input.bool(true, "Alert: Price Left OTE Zone",     group = GRP_ALERT)
i_alertMitigated    = input.bool(true, "Alert: OTE Zone Mitigated",      group = GRP_ALERT)
i_alertInvalidated  = input.bool(true, "Alert: OTE Zone Invalidated",    group = GRP_ALERT)

// ──────────────────────────────────────────────────────────────────
// SECTION 2 — STATE VARIABLES
// ──────────────────────────────────────────────────────────────────

// Active bullish zone

var bool   bullActive    = false
var float  bullTop       = na   // 62% boundary (nearer the extreme)
var float  bullBot       = na   // 79% boundary (deeper retracement)
var float  bullMid       = na   // 70.5% institutional equilibrium
var float  bullOrigin    = na   // swing low that started the leg (0%)
var float  bullExtreme   = na   // swing high that ended the leg (100%)
var bool   bullInZonePrev = false
var string bullState     = "fresh"   // fresh -> touched -> mitigated -> invalidated
var box    bullBox       = na
var line   bullMidLine   = na
var line   bullMidGlow   = na
var line   bullLegLine   = na
var label  bullLabel     = na

// Frozen / faded previous bullish zone (single historical slot)
var box   bullBoxOld     = na
var line  bullMidLineOld = na
var line  bullMidGlowOld = na
var line  bullLegLineOld = na
var label bullLabelOld   = na

// Active bearish zone
var bool   bearActive    = false
var float  bearTop       = na   // 79% boundary (deeper retracement, upper side)
var float  bearBot       = na   // 62% boundary (nearer the extreme, lower side)
var float  bearMid       = na
var float  bearOrigin    = na   // swing high that started the leg (0%)
var float  bearExtreme   = na   // swing low that ended the leg (100%)
var bool   bearInZonePrev = false
var string bearState     = "fresh"
var box    bearBox       = na
var line   bearMidLine   = na
var line   bearMidGlow   = na
var line   bearLegLine   = na
var label  bearLabel     = na

// Frozen / faded previous bearish zone
var box   bearBoxOld     = na
var line  bearMidLineOld = na
var line  bearMidGlowOld = na
var line  bearLegLineOld = na
var label bearLabelOld   = na

// ──────────────────────────────────────────────────────────────────
// SECTION 3 — UTILITY FUNCTIONS (must be declared at global scope)
// ──────────────────────────────────────────────────────────────────

f_lblSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

// Fill transparency by mitigation state — darker = fresher / higher value
f_fillColor(color c, string state) =>
    result = state == "fresh" ? color.new(c, 78) : state == "touched" ? color.new(c, 87) : state == "mitigated" ? color.new(c, 95) : color.new(color.gray, 95)
    result

f_borderColor(color c, string state) =>
    state == "invalidated" ? color.new(color.gray, 70) : color.new(c, 35)

// Convert a mitigation state to a comparable rank so state only ever
// advances forward (fresh -> touched -> mitigated -> invalidated).
f_stateRank(string state) =>
    state == "fresh" ? 0 : state == "touched" ? 1 : state == "mitigated" ? 2 : 3

// Freeze a set of drawing objects at the current bar and stop extending
// them further — used the moment a zone resolves (mitigated/invalidated)
// or gets retired in favour of a fresher swing.
f_freeze(bx, ml, mg, ll) =>
    if not na(bx)
        box.set_extend(bx, extend.none)
    if not na(ml)
        line.set_extend(ml, extend.none)
    if not na(mg)
        line.set_extend(mg, extend.none)
    if not na(ll)
        line.set_extend(ll, extend.none)

// ──────────────────────────────────────────────────────────────────
// SECTION 4 — CORE CALCULATIONS & SWING ZIGZAG ENGINE
// ──────────────────────────────────────────────────────────────────
atrVal = ta.atr(i_atrLen)

ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
pl = ta.pivotlow(low, i_pivotLen, i_pivotLen)

// Body ratio of the pivot candle itself, measured at its own bar.
f_bodyRatioAt(int off) =>
    rng = high[off] - low[off]
    rng > 0 ? math.abs(close[off] - open[off]) / rng : 0.0

// Running structural register. A "leg" — and therefore a candidate OTE
// zone — only resolves when the pivot type alternates (low -> high or
// high -> low). Consecutive same-type pivots extend the existing
// extreme instead of manufacturing a duplicate zone.
var float swingHighVal   = na
var int   swingHighBar   = na
var float swingLowVal    = na
var int   swingLowBar    = na
var string lastPivotType = na

bool  bullLegQualified  = false
float bullLegOrigin     = na
int   bullLegOriginBar  = na
float bullLegExtreme    = na
int   bullLegExtremeBar = na

bool  bearLegQualified  = false
float bearLegOrigin     = na
int   bearLegOriginBar  = na
float bearLegExtreme    = na
int   bearLegExtremeBar = na

if barstate.isconfirmed
    if not na(ph)
        pivotBarH = bar_index - i_pivotLen
        bodyRatioH = f_bodyRatioAt(i_pivotLen)
        if lastPivotType != "H"
            oldHigh   = swingHighVal
            legRangeH = na(swingLowVal) ? na : ph - swingLowVal
            sizeOkH   = not na(legRangeH) and legRangeH >= i_minSwingAtr * atrVal
            bodyOkH   = bodyRatioH >= i_minBodyRatio
            bosOkH    = not i_requireBOS or na(oldHigh) or ph > oldHigh
            if sizeOkH and bodyOkH and bosOkH and i_showBullish
                bullLegQualified  := true
                bullLegOrigin     := swingLowVal
                bullLegOriginBar  := swingLowBar
                bullLegExtreme    := ph
                bullLegExtremeBar := pivotBarH
            swingHighVal  := ph
            swingHighBar  := pivotBarH
            lastPivotType := "H"
        else
            if ph > swingHighVal
                swingHighVal := ph
                swingHighBar := pivotBarH

    if not na(pl)
        pivotBarL = bar_index - i_pivotLen
        bodyRatioL = f_bodyRatioAt(i_pivotLen)
        if lastPivotType != "L"
            oldLow    = swingLowVal
            legRangeL = na(swingHighVal) ? na : swingHighVal - pl
            sizeOkL   = not na(legRangeL) and legRangeL >= i_minSwingAtr * atrVal
            bodyOkL   = bodyRatioL >= i_minBodyRatio
            bosOkL    = not i_requireBOS or na(oldLow) or pl < oldLow
            if sizeOkL and bodyOkL and bosOkL and i_showBearish
                bearLegQualified  := true
                bearLegOrigin     := swingHighVal
                bearLegOriginBar  := swingHighBar
                bearLegExtreme    := pl
                bearLegExtremeBar := pivotBarL
            swingLowVal   := pl
            swingLowBar   := pivotBarL
            lastPivotType := "L"
        else
            if pl < swingLowVal
                swingLowVal := pl
                swingLowBar := pivotBarL

// ──────────────────────────────────────────────────────────────────
// SECTION 5 — EVENT FLAGS (drive both alert() calls and alertcondition())
// ──────────────────────────────────────────────────────────────────
bool evtBullCreated     = false
bool evtBullEntered     = false
bool evtBullExited      = false
bool evtBullMitigated   = false
bool evtBullInvalidated = false

bool evtBearCreated     = false
bool evtBearEntered     = false
bool evtBearExited      = false
bool evtBearMitigated   = false
bool evtBearInvalidated = false

// ──────────────────────────────────────────────────────────────────
// SECTION 6 — BULLISH ZONE CREATION & RENDERING
// ──────────────────────────────────────────────────────────────────
lblSizeVal = f_lblSize(i_labelSize)

if barstate.isconfirmed and bullLegQualified
    legRange = bullLegExtreme - bullLegOrigin

    // Retire the current active zone into the single historical slot
    // (or discard it) before the new one takes over as "active".
    if bullActive
        f_freeze(bullBox, bullMidLine, bullMidGlow, bullLegLine)
        if i_fadeOld
            box.delete(bullBoxOld)
            line.delete(bullMidLineOld)
            line.delete(bullMidGlowOld)
            line.delete(bullLegLineOld)
            label.delete(bullLabelOld)
            bullBoxOld     := bullBox
            bullMidLineOld := bullMidLine
            bullMidGlowOld := bullMidGlow
            bullLegLineOld := bullLegLine
            bullLabelOld   := bullLabel
            box.set_bgcolor(bullBoxOld, color.new(i_colBull, 92))
            box.set_border_color(bullBoxOld, color.new(i_colBull, 80))
            if not na(bullMidLineOld)
                line.set_color(bullMidLineOld, color.new(i_colBullMid, 90))
            if not na(bullMidGlowOld)
                line.set_color(bullMidGlowOld, color.new(i_colBullMid, 96))
            line.set_color(bullLegLineOld, color.new(i_colBull, 90))

            label.set_color(bullLabelOld, color.new(i_colBull, 95))
            label.set_textcolor(bullLabelOld, color.new(color.gray, 40))
        else
            box.delete(bullBox)
            line.delete(bullMidLine)
            line.delete(bullMidGlow)
            line.delete(bullLegLine)
            label.delete(bullLabel)

    // New active bullish OTE: retrace zone sits between 62% and 79% of
    // the leg, measured back down from the swing high extreme.
    bullOrigin  := bullLegOrigin
    bullExtreme := bullLegExtreme
    bullTop     := bullLegExtreme - 0.62  * legRange
    bullBot     := bullLegExtreme - 0.79  * legRange
    bullMid     := bullLegExtreme - 0.705 * legRange
    bullState   := "fresh"
    bullInZonePrev := false
    bullActive  := true

    boxRight = bar_index + i_extendBars

    bullBox   := box.new(bullLegExtremeBar, bullTop, boxRight, bullBot,
                 border_color = f_borderColor(i_colBull, "fresh"),
                 border_width = 1,
                 bgcolor      = f_fillColor(i_colBull, "fresh"),
                 extend       = extend.right)

    bullLegLine := line.new(bullLegOriginBar, bullOrigin, boxRight, bullOrigin,
                 color = color.new(i_colBull, 60), width = 1, style = line.style_dotted,
                 extend = extend.right)

    if i_showMidline
        bullMidGlow := line.new(bullLegExtremeBar, bullMid, boxRight, bullMid,
                     color = color.new(i_colBullMid, 75), width = 4,
                     extend = extend.right)
        bullMidLine := line.new(bullLegExtremeBar, bullMid, boxRight, bullMid,
                     color = color.new(i_colBullMid, 15), width = 1,
                     extend = extend.right)

    bullLabel := label.new(bullLegExtremeBar, bullTop,
                 text      = "OTE  62–79%",
                 style     = label.style_label_down,
                 color     = color.new(i_colBull, 85),
                 textcolor = color.new(i_colBull, 5),
                 size      = lblSizeVal)

    evtBullCreated := true

// ──────────────────────────────────────────────────────────────────
// SECTION 7 — BEARISH ZONE CREATION & RENDERING
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed and bearLegQualified
    legRangeBear = bearLegOrigin - bearLegExtreme

    if bearActive
        f_freeze(bearBox, bearMidLine, bearMidGlow, bearLegLine)
        if i_fadeOld
            box.delete(bearBoxOld)
            line.delete(bearMidLineOld)
            line.delete(bearMidGlowOld)
            line.delete(bearLegLineOld)
            label.delete(bearLabelOld)
            bearBoxOld     := bearBox
            bearMidLineOld := bearMidLine
            bearMidGlowOld := bearMidGlow
            bearLegLineOld := bearLegLine
            bearLabelOld   := bearLabel
            box.set_bgcolor(bearBoxOld, color.new(i_colBear, 92))
            box.set_border_color(bearBoxOld, color.new(i_colBear, 80))
            if not na(bearMidLineOld)
                line.set_color(bearMidLineOld, color.new(i_colBearMid, 90))
            if not na(bearMidGlowOld)
                line.set_color(bearMidGlowOld, color.new(i_colBearMid, 96))
            line.set_color(bearLegLineOld, color.new(i_colBear, 90))

            label.set_color(bearLabelOld, color.new(i_colBear, 95))
            label.set_textcolor(bearLabelOld, color.new(color.gray, 40))
        else
            box.delete(bearBox)
            line.delete(bearMidLine)
            line.delete(bearMidGlow)
            line.delete(bearLegLine)
            label.delete(bearLabel)

    // New active bearish OTE: retrace zone sits between 62% and 79% of
    // the leg, measured back up from the swing low extreme.
    bearOrigin  := bearLegOrigin
    bearExtreme := bearLegExtreme
    bearBot     := bearLegExtreme + 0.62  * legRangeBear
    bearTop     := bearLegExtreme + 0.79  * legRangeBear
    bearMid     := bearLegExtreme + 0.705 * legRangeBear
    bearState   := "fresh"
    bearInZonePrev := false
    bearActive  := true

    boxRightBear = bar_index + i_extendBars

    bearBox := box.new(bearLegExtremeBar, bearTop, boxRightBear, bearBot,
               border_color = f_borderColor(i_colBear, "fresh"),
               border_width = 1,
               bgcolor      = f_fillColor(i_colBear, "fresh"),
               extend       = extend.right)

    bearLegLine := line.new(bearLegOriginBar, bearOrigin, boxRightBear, bearOrigin,
               color = color.new(i_colBear, 60), width = 1, style = line.style_dotted,
               extend = extend.right)

    if i_showMidline
        bearMidGlow := line.new(bearLegExtremeBar, bearMid, boxRightBear, bearMid,
                   color = color.new(i_colBearMid, 75), width = 4,
                   extend = extend.right)
        bearMidLine := line.new(bearLegExtremeBar, bearMid, boxRightBear, bearMid,
                   color = color.new(i_colBearMid, 15), width = 1,
                   extend = extend.right)

    bearLabel := label.new(bearLegExtremeBar, bearTop,
               text      = "OTE  62–79%",
               style     = label.style_label_up,
               color     = color.new(i_colBear, 85),
               textcolor = color.new(i_colBear, 5),
               size      = lblSizeVal)

    evtBearCreated := true

// ──────────────────────────────────────────────────────────────────
// SECTION 8 — MITIGATION & INVALIDATION ENGINE (BULLISH)
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed and bullActive
    bullInZoneNow = low <= bullTop and high >= bullBot

    if bullInZoneNow and not bullInZonePrev
        evtBullEntered := true
    if not bullInZoneNow and bullInZonePrev
        evtBullExited := true
    bullInZonePrev := bullInZoneNow

    // State only ever advances forward: fresh -> touched -> mitigated -> invalidated
    newBullState = bullState
    if close < bullOrigin
        newBullState := "invalidated"
    else if close < bullBot
        newBullState := "mitigated"
    else if bullInZoneNow
        newBullState := "touched"

    if f_stateRank(newBullState) > f_stateRank(bullState)
        bullState := newBullState
        box.set_bgcolor(bullBox, f_fillColor(i_colBull, bullState))
        box.set_border_color(bullBox, f_borderColor(i_colBull, bullState))

        if bullState == "mitigated"
            evtBullMitigated := true

        if bullState == "invalidated"
            evtBullInvalidated := true
            bullActive := false
            f_freeze(bullBox, bullMidLine, bullMidGlow, bullLegLine)
            if not na(bullMidLine)
                line.set_color(bullMidLine, color.new(color.gray, 80))
            if not na(bullMidGlow)
                line.set_color(bullMidGlow, color.new(color.gray, 92))
            if not na(bullLegLine)
                line.set_color(bullLegLine, color.new(color.gray, 85))

// ──────────────────────────────────────────────────────────────────
// SECTION 9 — MITIGATION & INVALIDATION ENGINE (BEARISH)
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed and bearActive
    bearInZoneNow = low <= bearTop and high >= bearBot

    if bearInZoneNow and not bearInZonePrev
        evtBearEntered := true
    if not bearInZoneNow and bearInZonePrev
        evtBearExited := true
    bearInZonePrev := bearInZoneNow

    newBearState = bearState
    if close > bearOrigin
        newBearState := "invalidated"
    else if close > bearTop
        newBearState := "mitigated"
    else if bearInZoneNow
        newBearState := "touched"

    if f_stateRank(newBearState) > f_stateRank(bearState)
        bearState := newBearState
        box.set_bgcolor(bearBox, f_fillColor(i_colBear, bearState))
        box.set_border_color(bearBox, f_borderColor(i_colBear, bearState))

        if bearState == "mitigated"
            evtBearMitigated := true

        if bearState == "invalidated"
            evtBearInvalidated := true
            bearActive := false
            f_freeze(bearBox, bearMidLine, bearMidGlow, bearLegLine)
            if not na(bearMidLine)
                line.set_color(bearMidLine, color.new(color.gray, 80))
            if not na(bearMidGlow)
                line.set_color(bearMidGlow, color.new(color.gray, 92))
            if not na(bearLegLine)
                line.set_color(bearLegLine, color.new(color.gray, 85))

// ──────────────────────────────────────────────────────────────────
// SECTION 10 — ALERT ENGINE
// Alerts use alert() with alert.freq_once_per_bar_close, gated by the
// user's toggle for that category. alertcondition() calls are also
// provided for traders who prefer TradingView's legacy Create Alert
// dialog with per-condition selection.
// ──────────────────────────────────────────────────────────────────
if i_alertCreated and evtBullCreated
    alert("New Bullish OTE Zone Created on " + syminfo.ticker, alert.freq_once_per_bar_close)
if i_alertCreated and evtBearCreated
    alert("New Bearish OTE Zone Created on " + syminfo.ticker, alert.freq_once_per_bar_close)

if i_alertEntered and evtBullEntered
    alert("Price Entered Bullish OTE Zone on " + syminfo.ticker, alert.freq_once_per_bar_close)
if i_alertEntered and evtBearEntered
    alert("Price Entered Bearish OTE Zone on " + syminfo.ticker, alert.freq_once_per_bar_close)

if i_alertExited and evtBullExited
    alert("Price Left Bullish OTE Zone on " + syminfo.ticker, alert.freq_once_per_bar_close)
if i_alertExited and evtBearExited
    alert("Price Left Bearish OTE Zone on " + syminfo.ticker, alert.freq_once_per_bar_close)

if i_alertMitigated and evtBullMitigated
    alert("Bullish OTE Zone Mitigated on " + syminfo.ticker, alert.freq_once_per_bar_close)
if i_alertMitigated and evtBearMitigated
    alert("Bearish OTE Zone Mitigated on " + syminfo.ticker, alert.freq_once_per_bar_close)

if i_alertInvalidated and evtBullInvalidated
    alert("Bullish OTE Zone Invalidated on " + syminfo.ticker, alert.freq_once_per_bar_close)
if i_alertInvalidated and evtBearInvalidated
    alert("Bearish OTE Zone Invalidated on " + syminfo.ticker, alert.freq_once_per_bar_close)

// Legacy alertcondition() hooks — one per disclosed event, matching
// the alert() messages above for consistency in the Create Alert dialog.
alertcondition(evtBullCreated,     title = "New Bullish OTE Zone",       message = "New Bullish OTE Zone Created")
alertcondition(evtBearCreated,     title = "New Bearish OTE Zone",       message = "New Bearish OTE Zone Created")
alertcondition(evtBullEntered,     title = "Price Entered Bullish OTE",  message = "Price Entered Bullish OTE Zone")
alertcondition(evtBearEntered,     title = "Price Entered Bearish OTE",  message = "Price Entered Bearish OTE Zone")
alertcondition(evtBullExited,      title = "Price Left Bullish OTE",     message = "Price Left Bullish OTE Zone")
alertcondition(evtBearExited,      title = "Price Left Bearish OTE",     message = "Price Left Bearish OTE Zone")
alertcondition(evtBullMitigated,   title = "Bullish OTE Mitigated",      message = "Bullish OTE Zone Mitigated")
alertcondition(evtBearMitigated,   title = "Bearish OTE Mitigated",      message = "Bearish OTE Zone Mitigated")
alertcondition(evtBullInvalidated, title = "Bullish OTE Invalidated",    message = "Bullish OTE Zone Invalidated")
alertcondition(evtBearInvalidated, title = "Bearish OTE Invalidated",    message = "Bearish OTE Zone Invalidated")
````
