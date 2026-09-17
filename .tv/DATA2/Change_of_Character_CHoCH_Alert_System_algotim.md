<!-- tradingview-pine-id: PUB;1dd310e448fc4dd3b821f49ace5e7acf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Change of Character (CHoCH) Alert System [algotim]

Source: https://www.tradingview.com/script/Pt5puJ6O-Change-of-Character-CHoCH-Alert-System-algotim/

## Description

Change of Character (CHoCH) Alert System is a market structure signal tool focused on a single event: a confirmed shift in directional bias. Rather than labeling every Break of Structure and CHoCH the way many public structure scripts do, this indicator deliberately ignores continuation breaks and limits both the chart and the alert feed to the moments where the prevailing character of the market actually flips.

Problem Statement
Most public CHoCH implementations classify a character change purely on the direction of a swing break, with no measure of how convincing that break actually was. This creates two practical issues for anyone building alerts around structure. Every minor swing wobble can trigger a notification, producing alert fatigue, and there is no way to separate a decisive character change from one that barely closed beyond the swing level. This script addresses both issues with a close-confirmed CHoCH-only detection engine and a built-in confidence grading step applied to every signal.

Methodology
The script maintains a single structure register holding the most recent confirmed swing high and swing low, located with standard pivot detection over a user-defined pivot length. When the adaptive swing filter is enabled, a newly confirmed pivot only replaces the stored swing if its distance from the last opposite-type pivot exceeds a configurable ATR-relative threshold, which keeps insignificant micro-swings out of the structure register before they can influence a signal.
A Change of Character is only evaluated on a confirmed candle close, so nothing in the detection logic repaints once a signal has printed. A bullish CHoCH requires a close above the last swing high while the tracked bias is bearish or undefined. A bearish CHoCH requires a close below the last swing low while the tracked bias is bullish or undefined. A break that occurs while the bias already agrees with the break direction is treated as ordinary continuation and is not flagged.
Two optional filters gate confirmation further. A displacement filter requires the breaking close to clear the swing level by a minimum ATR multiple, removing marginal breaks. A momentum filter requires the breakout candle's body to represent a minimum percentage of its total range, removing breaks driven mostly by wick with little real conviction behind the close.
Once a CHoCH is confirmed, the broken swing level is projected forward on the chart as an active structure line. If a later confirmed close moves back through that level, the structure is marked invalidated and the projection line is dimmed, separately from the detection of any new CHoCH.

Signal Workflow
Track the most recent confirmed swing high and swing low using pivot detection.
Apply the adaptive swing filter to reject pivots too close to the last opposite-type pivot.
On each confirmed candle close, test for a close beyond the stored swing level against the current bias.
Apply the displacement filter to confirm the close cleared the level by a minimum ATR multiple.
Apply the momentum filter to confirm the breakout candle's body-to-range ratio meets the minimum threshold.
Score the confirmed breakout candle on displacement in ATR units and body-to-range ratio to produce a Weak, Moderate, or Strong confidence grade.
Flip the tracked bias, plot the CHoCH label with its grade, and project the broken level forward as an active structure line.
Continue monitoring the active structure line and mark it invalidated if a later confirmed close moves back through it.

Why This Indicator Is Different
Many structure tools plot every Break of Structure alongside every CHoCH, leaving the trader to filter out which events represent an actual change in character.
This script omits BOS events entirely and reports only confirmed CHoCH signals, which are the events that correspond to a bias flip.
Each confirmed CHoCH is scored using two independent factors measured on the breakout candle itself, its ATR-normalized displacement past the level and its body-to-range ratio, rather than being treated as a single undifferentiated event.
The confidence grade is written into the alert message text at the moment the event fires, which requires composing the message dynamically rather than relying on a fixed template.
The swing level broken by a CHoCH remains tracked after the signal fires, so a later close back through that level produces a distinct invalidation alert rather than silently vanishing into the next structure calculation.
Detection is restricted to confirmed candle closes throughout, so the bias, the grade, and the invalidation state cannot change intrabar once printed.

Inputs
Structure Engine
Swing Pivot Length
Adaptive Swing Filter
Filter Threshold (ATR multiple)
Break Confirmation
Displacement Filter
Displacement Multiplier
Momentum Filter
Minimum Body % of Range
ATR Length
Visual Settings
Show Swing Points
Show Structure Projection
Projection Extension
Show Trend Background Wash
Color Candles After CHoCH
Show Confidence Grade
Label Size
Bullish, Bearish, and Projection colors
Status Panel
Show Status Panel
Panel Position
Alerts
Alert: Bullish CHoCH
Alert: Bearish CHoCH
Alert: Bullish Structure Invalidated
Alert: Bearish Structure Invalidated

Alerts
Alerts are available for:
Bullish CHoCH confirmed on a closed candle, with the confidence grade included in the alert message
Bearish CHoCH confirmed on a closed candle, with the confidence grade included in the alert message
Bullish structure invalidated after a confirmed close back below an active bullish level
Bearish structure invalidated after a confirmed close back above an active bearish level

Practical Usage
Use a shorter pivot length on intraday charts to react to structure earlier, combined with the displacement and momentum filters to avoid marginal breaks.
Use a longer pivot length on higher timeframes to isolate structurally significant character changes only.
Treat a Strong-grade CHoCH as a higher-conviction event than a Weak-grade CHoCH when weighing entry timing or position sizing.
Watch for a structure invalidated alert shortly after a CHoCH, since it indicates price has returned through the level that produced the signal.
Use the status panel as a quick reference for the current bias and the most recent CHoCH grade without needing to scan the chart for labels.

Limitations
Swing highs and lows depend on confirmed pivots, which require the full pivot length of bars to close on both sides before becoming available, introducing a disclosed confirmation lag.
The displacement and momentum filters reduce signal frequency by design, which means fewer but more selective CHoCH events compared to unfiltered structure break detection.
Structure invalidation reflects a return through a previously broken level and does not attempt to forecast subsequent price direction.
This indicator identifies structural events only and does not constitute financial advice or a complete trading system on its own.

Notes
All structural state, including the tracked bias, the active levels, and the confidence grade, is evaluated only on a confirmed candle close, so nothing in this script repaints once printed.
The only lag in the system is the standard pivot confirmation lag inherent to pivot-based swing detection, which is disclosed above rather than hidden.
Designed for dark theme charts. On light themes, consider darkening the projection line color for improved contrast.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Change of Character (CHoCH) Alert System [algotim]
// Author : algotim
// Version: 1.0.0


indicator(
     title            = "Change of Character (CHoCH) Alert System [algotim]",
     shorttitle       = "CHoCH Alerts [algotim]",
     overlay          = true,
     max_bars_back    = 500,
     max_labels_count = 200,
     max_lines_count  = 50)

// ──────────────────────────────────────────────────────────────────
// INPUT GROUPS
// ──────────────────────────────────────────────────────────────────
GRP_STRUCT = "Structure Engine"
GRP_CONF   = "Break Confirmation"
GRP_VIS    = "Visual Settings"
GRP_PANEL  = "Status Panel"
GRP_ALERT  = "Alerts"

// ── Structure Engine ──────────────────────────────────────────────
i_pivotLen = input.int(5, "Swing Pivot Length",
     minval  = 2,
     maxval  = 50,
     group   = GRP_STRUCT,
     tooltip = "Number of bars required on each side to confirm a swing high or low. Lower values detect structure earlier with more noise; higher values produce fewer, more significant swings.")

i_useAdaptive = input.bool(true, "Adaptive Swing Filter",
     group   = GRP_STRUCT,
     tooltip = "When enabled, a new swing pivot is only accepted if its range from the last opposite-type pivot exceeds the Filter Threshold below, in ATR units. This removes insignificant micro-swings from the structure register.")

i_adaptiveThresh = input.float(0.15, "Filter Threshold (× ATR)",
     minval  = 0.05,
     maxval  = 2.0,
     step    = 0.05,
     group   = GRP_STRUCT,
     tooltip = "Minimum swing range, in ATR multiples, required for a new pivot to be accepted when the Adaptive Swing Filter is enabled.")

// ── Break Confirmation ────────────────────────────────────────────
i_useDisp = input.bool(true, "Displacement Filter",
     group   = GRP_CONF,
     tooltip = "When enabled, the breaking candle's close must clear the swing level by at least (ATR × Displacement Multiplier) before a CHoCH is confirmed.")

i_dispMult = input.float(0.25, "Displacement Multiplier (× ATR)",
     minval  = 0.0,
     maxval  = 3.0,
     step    = 0.05,
     group   = GRP_CONF,
     tooltip = "ATR multiple the close must clear the swing level by when the Displacement Filter is active.")

i_useMomentum = input.bool(true, "Momentum Filter",
     group   = GRP_CONF,
     tooltip = "When enabled, the breakout candle must show a minimum body-to-range ratio to confirm a CHoCH, filtering out breaks driven mostly by wick.")

i_minBodyRatio = input.float(40, "Minimum Body % of Range",
     minval  = 0,
     maxval  = 100,
     step    = 5,
     group   = GRP_CONF,
     tooltip = "Minimum candle body size as a percentage of the candle's total range, required when the Momentum Filter is active.")

i_atrLen = input.int(14, "ATR Length",
     minval  = 5,
     maxval  = 100,
     group   = GRP_CONF,
     tooltip = "ATR period used for the adaptive swing filter, displacement filter, and confidence grading.")

// ── Visual Settings ───────────────────────────────────────────────
i_showSwingPts = input.bool(true, "Show Swing Points",
     group = GRP_VIS,
     tooltip = "Displays small markers at confirmed swing highs and lows for structural context.")

i_showProjection = input.bool(true, "Show Structure Projection",
     group = GRP_VIS,
     tooltip = "Projects the level broken by the most recent CHoCH forward as an active structure line until it is invalidated.")

i_lineExtend = input.int(25, "Projection Extension (bars)",
     minval  = 5,
     maxval  = 100,
     group   = GRP_VIS,
     tooltip = "Number of bars the structure projection line extends ahead of the current bar while active.")

i_showBg = input.bool(true, "Show Trend Background Wash",
     group = GRP_VIS,
     tooltip = "Applies a very subtle background tint reflecting the current confirmed trend bias.")

i_colorCandles = input.bool(false, "Color Candles After CHoCH",
     group = GRP_VIS,
     tooltip = "Colors candle bodies according to the confirmed trend bias following the most recent CHoCH.")

i_showGrade = input.bool(true, "Show Confidence Grade",
     group = GRP_VIS,
     tooltip = "Displays the Weak / Moderate / Strong confidence grade on each CHoCH label.")

i_labelSize = input.string("Small", "Label Size",
     options = ["Tiny", "Small", "Normal"],
     group   = GRP_VIS)

i_colBull = input.color(color.new(#00e676, 0), "Bullish Colour", group = GRP_VIS)
i_colBear = input.color(color.new(#ef5350, 0), "Bearish Colour", group = GRP_VIS)
i_colProj = input.color(color.new(#787b86, 0), "Projection Colour", group = GRP_VIS)

// ── Status Panel ──────────────────────────────────────────────────
i_showPanel = input.bool(true, "Show Status Panel", group = GRP_PANEL)
i_panelPos  = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = GRP_PANEL)

// ── Alerts ────────────────────────────────────────────────────────
i_alertBullCHoCH = input.bool(true, "Alert: Bullish CHoCH",                 group = GRP_ALERT)
i_alertBearCHoCH = input.bool(true, "Alert: Bearish CHoCH",                 group = GRP_ALERT)
i_alertBullInv   = input.bool(true, "Alert: Bullish Structure Invalidated", group = GRP_ALERT)
i_alertBearInv   = input.bool(true, "Alert: Bearish Structure Invalidated", group = GRP_ALERT)

// ──────────────────────────────────────────────────────────────────
// STATE VARIABLES
// ──────────────────────────────────────────────────────────────────

// Trend bias: 1 = bullish, -1 = bearish, 0 = undefined
var int trendBias = 0

// Confirmed swing register
var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastSHBar     = na
var int   lastSLBar     = na

// Active structure (the level broken by the most recent CHoCH in each direction)
var float activeBullLevel   = na
var bool  bullLevelActive   = false
var line  bullProjLine      = na

var float activeBearLevel   = na
var bool  bearLevelActive   = false
var line  bearProjLine      = na

// Counters and last-event memory for the status panel
var int    totalChochCount = 0
var int    bullChochCount  = 0
var int    bearChochCount  = 0
var string lastChochDir    = "—"
var string lastChochGrade  = "—"

// Label pruning array
var array<label> lblArr = array.new<label>()

// ──────────────────────────────────────────────────────────────────
// UTILITY FUNCTIONS
// ──────────────────────────────────────────────────────────────────

f_lblSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small


f_pruneLabels() =>
    if array.size(lblArr) > 100
        label.delete(array.shift(lblArr))

// Confidence grade: combines breakout displacement (ATR units) and
// candle body conviction (% of range) into a 0-3 score.
f_calcGrade(float dispAtr, float bodyPct) =>
    int dispScore = dispAtr >= 1.0 ? 2 : dispAtr >= 0.4 ? 1 : 0
    int bodyScore = bodyPct >= 65 ? 1 : 0
    dispScore + bodyScore

f_gradeStars(int score) =>
    score >= 3 ? "★★★" : score == 2 ? "★★☆" : "★☆☆"

f_gradeWord(int score) =>
    score >= 3 ? "Strong" : score == 2 ? "Moderate" : "Weak"

// Status panel row writer — draws a label/value pair into a two-column table.
// Declared at global scope (Pine Script does not permit function declarations
// inside local blocks such as if/for).
f_row(table tbl, int r, string lbl, string val, color vc) =>
    table.cell(tbl, 0, r, lbl,
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(#1a1a2e, 15),
         text_halign = text.align_left)
    table.cell(tbl, 1, r, val,
         text_color  = vc,
         text_size   = size.small,
         bgcolor     = color.new(#1a1a2e, 15),
         text_halign = text.align_right)

// Draw a CHoCH label at the confirmed break bar
f_drawChochLabel(int barIdx, float lvl, bool isBull, int score, float atrVal) =>

    string gradeTxt = i_showGrade ? "\n" + f_gradeStars(score) + " " + f_gradeWord(score) : ""
    string txt = (isBull ? "CHoCH ▲" : "CHoCH ▼") + gradeTxt
    color  col = isBull ? i_colBull : i_colBear
    float  offs = isBull ? -atrVal * 0.6 : atrVal * 0.6
    lbl = label.new(
         x         = barIdx,
         y         = lvl + offs,
         text      = txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = isBull ? label.style_label_up : label.style_label_down,
         color     = color.new(col, 15),
         textcolor = color.white,
         size      = f_lblSize(i_labelSize))
    array.push(lblArr, lbl)
    f_pruneLabels()

// ──────────────────────────────────────────────────────────────────
// CALCULATIONS
// ──────────────────────────────────────────────────────────────────

float atrVal = ta.atr(i_atrLen)

// Confirmed pivots — standard ta.pivothigh/low lag applies (disclosed, not repainting once confirmed)
float pivHigh = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pivLow  = ta.pivotlow(low,  i_pivotLen, i_pivotLen)

// ── Adaptive swing register update ────────────────────────────────
if not na(pivHigh)
    bool significantHigh = not i_useAdaptive or na(lastSwingLow) or math.abs(pivHigh - lastSwingLow) >= atrVal * i_adaptiveThresh
    if significantHigh
        lastSwingHigh := pivHigh
        lastSHBar     := bar_index[i_pivotLen]

if not na(pivLow)
    bool significantLow = not i_useAdaptive or na(lastSwingHigh) or math.abs(lastSwingHigh - pivLow) >= atrVal * i_adaptiveThresh
    if significantLow
        lastSwingLow := pivLow
        lastSLBar    := bar_index[i_pivotLen]

// ── Swing point markers (context only, no chart clutter) ──────────
plotshape(i_showSwingPts and not na(pivHigh) ? high[i_pivotLen] : na,
     title    = "Swing High",
     style    = shape.triangledown,
     location = location.absolute,
     color    = color.new(color.gray, 35),
     size     = size.tiny,
     offset   = -i_pivotLen)

plotshape(i_showSwingPts and not na(pivLow) ? low[i_pivotLen] : na,
     title    = "Swing Low",
     style    = shape.triangleup,
     location = location.absolute,
     color    = color.new(color.gray, 35),
     size     = size.tiny,
     offset   = -i_pivotLen)

// ──────────────────────────────────────────────────────────────────
// EVENT FLAGS (reset every bar, drive alertcondition() at the bottom)
// ──────────────────────────────────────────────────────────────────
bool bullChochEvent = false
bool bearChochEvent = false
bool bullInvEvent   = false
bool bearInvEvent   = false

// ──────────────────────────────────────────────────────────────────
// CHoCH DETECTION — evaluated only on a confirmed candle close
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed and not na(lastSwingHigh) and not na(lastSwingLow)

    float dispBuffer  = i_useDisp ? atrVal * i_dispMult : 0.0
    float rangeVal    = high - low
    float bodyRatioPct = rangeVal > 0 ? math.abs(close - open) / rangeVal * 100 : 0.0
    bool  momentumOK  = not i_useMomentum or bodyRatioPct >= i_minBodyRatio

    bool breakAbove = close > lastSwingHigh + dispBuffer
    bool breakBelow = close < lastSwingLow  - dispBuffer

    // ── Bullish CHoCH: break above a swing high while bias is bearish/undefined ──
    if breakAbove and momentumOK and trendBias <= 0
        float dispAtr = (close - lastSwingHigh) / atrVal
        int   score   = f_calcGrade(dispAtr, bodyRatioPct)

        f_drawChochLabel(bar_index, lastSwingHigh, true, score, atrVal)

        trendBias := 1
        totalChochCount += 1
        bullChochCount  += 1
        lastChochDir   := "▲ Bullish"
        lastChochGrade := f_gradeStars(score) + " " + f_gradeWord(score)
        bullChochEvent := true

        // Replace previous bull structure projection and activate the new one
        if not na(bullProjLine)
            line.delete(bullProjLine)
        activeBullLevel := lastSwingHigh
        bullLevelActive := true
        if i_showProjection
            bullProjLine := line.new(
                 x1    = lastSHBar,
                 y1    = lastSwingHigh,
                 x2    = bar_index + i_lineExtend,
                 y2    = lastSwingHigh,
                 xloc  = xloc.bar_index,
                 color = color.new(i_colProj, 30),
                 style = line.style_dashed,
                 width = 1)

        if i_alertBullCHoCH
            alert(
                 "CHoCH Alerts [algotim] — " + syminfo.ticker + " " + timeframe.period +
                 ": Bullish Change of Character confirmed at " + str.tostring(lastSwingHigh, format.mintick) +
                 ". Confidence: " + f_gradeWord(score) + " " + f_gradeStars(score) +
                 ". Trend bias flipped to bullish on a confirmed close.",
                 alert.freq_once_per_bar)

    // ── Bearish CHoCH: break below a swing low while bias is bullish/undefined ──
    if breakBelow and momentumOK and trendBias >= 0
        float dispAtr = (lastSwingLow - close) / atrVal
        int   score   = f_calcGrade(dispAtr, bodyRatioPct)

        f_drawChochLabel(bar_index, lastSwingLow, false, score, atrVal)

        trendBias := -1
        totalChochCount += 1
        bearChochCount  += 1
        lastChochDir   := "▼ Bearish"
        lastChochGrade := f_gradeStars(score) + " " + f_gradeWord(score)
        bearChochEvent := true

        // Replace previous bear structure projection and activate the new one
        if not na(bearProjLine)
            line.delete(bearProjLine)
        activeBearLevel := lastSwingLow
        bearLevelActive := true
        if i_showProjection
            bearProjLine := line.new(
                 x1    = lastSLBar,
                 y1    = lastSwingLow,
                 x2    = bar_index + i_lineExtend,
                 y2    = lastSwingLow,
                 xloc  = xloc.bar_index,
                 color = color.new(i_colProj, 30),
                 style = line.style_dashed,
                 width = 1)

        if i_alertBearCHoCH
            alert(
                 "CHoCH Alerts [algotim] — " + syminfo.ticker + " " + timeframe.period +
                 ": Bearish Change of Character confirmed at " + str.tostring(lastSwingLow, format.mintick) +
                 ". Confidence: " + f_gradeWord(score) + " " + f_gradeStars(score) +
                 ". Trend bias flipped to bearish on a confirmed close.",
                 alert.freq_once_per_bar)

// ──────────────────────────────────────────────────────────────────
// STRUCTURE INVALIDATION — confirmed close back through an active level
// ──────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    if bullLevelActive and close < activeBullLevel
        bullLevelActive := false
        bullInvEvent    := true
        if not na(bullProjLine)
            line.set_color(bullProjLine, color.new(color.gray, 70))
            line.set_x2(bullProjLine, bar_index)
        if i_alertBullInv
            alert(
                 "CHoCH Alerts [algotim] — " + syminfo.ticker + " " + timeframe.period +
                 ": Bullish structure invalidated. Price closed back below " +
                 str.tostring(activeBullLevel, format.mintick) + " — the prior bullish CHoCH may be a failed break.",
                 alert.freq_once_per_bar)

    if bearLevelActive and close > activeBearLevel
        bearLevelActive := false
        bearInvEvent    := true
        if not na(bearProjLine)
            line.set_color(bearProjLine, color.new(color.gray, 70))
            line.set_x2(bearProjLine, bar_index)
        if i_alertBearInv
            alert(
                 "CHoCH Alerts [algotim] — " + syminfo.ticker + " " + timeframe.period +
                 ": Bearish structure invalidated. Price closed back above " +
                 str.tostring(activeBearLevel, format.mintick) + " — the prior bearish CHoCH may be a failed break.",
                 alert.freq_once_per_bar)

// Keep active projection lines extending forward while still valid
if i_showProjection and barstate.isconfirmed
    if bullLevelActive and not na(bullProjLine)
        line.set_x2(bullProjLine, bar_index + i_lineExtend)
    if bearLevelActive and not na(bearProjLine)
        line.set_x2(bearProjLine, bar_index + i_lineExtend)

// ──────────────────────────────────────────────────────────────────
// VISUAL LAYER — trend background wash and candle coloring
// ──────────────────────────────────────────────────────────────────
bgcolor(i_showBg ? (trendBias == 1 ? color.new(i_colBull, 95) : trendBias == -1 ? color.new(i_colBear, 95) : na) : na,
     title = "Trend Background")

barcolor(i_colorCandles ? (trendBias == 1 ? i_colBull : trendBias == -1 ? i_colBear : na) : na,
     title = "CHoCH Trend Candles")

// ──────────────────────────────────────────────────────────────────
// STATUS PANEL
// ──────────────────────────────────────────────────────────────────
panelPos = i_panelPos == "Top Right"    ? position.top_right    :
           i_panelPos == "Top Left"     ? position.top_left     :
           i_panelPos == "Bottom Right" ? position.bottom_right :
                                           position.bottom_left


var table statusTbl = na

if i_showPanel and barstate.islast
    if na(statusTbl)
        statusTbl := table.new(panelPos, 2, 6,
             bgcolor      = color.new(#1a1a2e, 15),
             border_color = color.new(color.gray, 65),
             border_width = 1,
             frame_color  = color.new(color.gray, 50),
             frame_width  = 1)

    // Header

    table.cell(statusTbl, 0, 0, "CHoCH Alerts [algotim]",
         text_color  = color.new(#29b6f6, 0),
         text_size   = size.small,
         bgcolor     = color.new(#0d0d1a, 0),
         text_halign = text.align_left)
    table.cell(statusTbl, 1, 0, syminfo.ticker + " · " + timeframe.period,
         text_color  = color.new(color.gray, 30),
         text_size   = size.small,
         bgcolor     = color.new(#0d0d1a, 0),
         text_halign = text.align_right)

    // Trend bias
    string biasStr = trendBias == 1 ? "▲ BULLISH" : trendBias == -1 ? "▼ BEARISH" : "— UNDEFINED"
    color  biasCol = trendBias == 1 ? color.new(i_colBull, 0) : trendBias == -1 ? color.new(i_colBear, 0) : color.new(color.gray, 30)
    f_row(statusTbl, 1, "Trend Bias", biasStr, biasCol)

    // Last CHoCH
    color lastCol = lastChochDir == "▲ Bullish" ? color.new(i_colBull, 0) : lastChochDir == "▼ Bearish" ? color.new(i_colBear, 0) : color.new(color.gray, 30)
    f_row(statusTbl, 2, "Last CHoCH", lastChochDir == "—" ? "—" : lastChochDir + " " + lastChochGrade, lastCol)

    // Total CHoCH count
    f_row(statusTbl, 3, "Total CHoCH", str.tostring(totalChochCount), color.new(color.gray, 20))

    // Active structure levels
    string bullStructStr = na(activeBullLevel) ? "—" : str.tostring(math.round(activeBullLevel, 5)) + (bullLevelActive ? " (active)" : " (invalid)")
    color  bullStructCol = na(activeBullLevel) ? color.new(color.gray, 30) : bullLevelActive ? color.new(i_colBull, 10) : color.new(color.gray, 40)
    f_row(statusTbl, 4, "Bull Structure", bullStructStr, bullStructCol)

    string bearStructStr = na(activeBearLevel) ? "—" : str.tostring(math.round(activeBearLevel, 5)) + (bearLevelActive ? " (active)" : " (invalid)")
    color  bearStructCol = na(activeBearLevel) ? color.new(color.gray, 30) : bearLevelActive ? color.new(i_colBear, 10) : color.new(color.gray, 40)
    f_row(statusTbl, 5, "Bear Structure", bearStructStr, bearStructCol)


// ──────────────────────────────────────────────────────────────────
// ALERTS — alertcondition() calls for the TradingView alert dialogue.
// Dynamic, grade-aware messages are delivered via alert() above; these
// static conditions exist so all four events remain selectable in the
// standard "Create Alert" dropdown regardless of alert() usage.
// ──────────────────────────────────────────────────────────────────
alertcondition(bullChochEvent and i_alertBullCHoCH,
     title   = "CHoCH: Bullish Change of Character",
     message = "CHoCH Alerts [algotim] — {{ticker}} {{interval}}: Bullish Change of Character confirmed on a closed candle. Trend bias has flipped bullish.")

alertcondition(bearChochEvent and i_alertBearCHoCH,
     title   = "CHoCH: Bearish Change of Character",
     message = "CHoCH Alerts [algotim] — {{ticker}} {{interval}}: Bearish Change of Character confirmed on a closed candle. Trend bias has flipped bearish.")

alertcondition(bullInvEvent and i_alertBullInv,
     title   = "CHoCH: Bullish Structure Invalidated",
     message = "CHoCH Alerts [algotim] — {{ticker}} {{interval}}: Bullish structure invalidated. The prior bullish CHoCH may be a failed break.")

alertcondition(bearInvEvent and i_alertBearInv,
     title   = "CHoCH: Bearish Structure Invalidated",
     message = "CHoCH Alerts [algotim] — {{ticker}} {{interval}}: Bearish structure invalidated. The prior bearish CHoCH may be a failed break.")

// ── End of Script ─────────────────────────────────────────────────
````
