# Smart Structure Mapper [StrixEDGE]

- url: https://www.tradingview.com/script/4uMt1459-Smart-Structure-Mapper-StrixEDGE/
- type: indicator
- pine_id: PUB;6a9c8d63cc214522a06c1b8d15384c71
- version: 1.0

## Description

Overview

AetherZone is a market structure analysis toolkit that maps the internal architecture of price action in real time. It identifies swing points, tracks structural shifts (BOS & CHoCH), detects order blocks (supply and demand zones), and highlights fair value gaps — consolidating the core framework of institutional price analysis into a single, self-managing overlay.

What This Indicator Does

AetherZone operates through five interconnected analytical layers:

Swing Detection Engine
Identifies confirmed pivot highs and pivot lows using a configurable lookback window. Each swing point is labeled directly on the chart as "Swing High" or "Swing Low" in clean, neutral text. Pivots are confirmed after the required bars have closed on both sides, ensuring the indicator does not repaint or revise historical swing points. Each swing is classified relative to its predecessor as a Higher High (HH), Lower High (LH), Higher Low (HL), or Lower Low (LL).

https://www.tradingview.com/x/dAkOsK5E/

Market Structure Tracker
Continuously evaluates the relationship between consecutive swing highs and swing lows to determine the prevailing market structure:

- Bullish Structure — Higher Highs + Higher Lows (HH/HL)
https://www.tradingview.com/x/uVazO3QC/
- Bearish Structure — Lower Highs + Lower Lows (LH/LL)
https://www.tradingview.com/x/AupPryZc/
- Ranging — Mixed signals or insufficient structural data
https://www.tradingview.com/x/swOJ2fvJ/

BOS & CHoCH Detection
AetherZone uses a flag-based detection system to identify structural breaks. When a new swing point is confirmed, its level becomes active. The first bar where price closes beyond that level triggers the event:

- BOS ↑ / BOS ↓ (Break of Structure) — Price breaks a swing level in the direction of the prevailing trend, confirming continuation. Labeled with directional arrows on the chart.
https://www.tradingview.com/x/OZwem2z0/
- CHoCH ↑ / CHoCH ↓ (Change of Character) — Price breaks a swing level against the prevailing trend, signaling a potential reversal. Displayed with a more prominent label and color to draw attention to the structural shift.
https://www.tradingview.com/x/7rjIJgEC/

A dashed level line is drawn at the broken swing point for visual reference.

Order Block Detection
AetherZone identifies potential institutional interest zones through two configurable modes:

"All Swings" mode (default): An Order Block is created at every confirmed swing point, providing comprehensive zone coverage. On each confirmed pivot low, the last bearish candle near that swing becomes a Demand zone. On each confirmed pivot high, the last bullish candle near that swing becomes a Supply zone.

Bullish OB

"BOS/CHoCH Only" mode: Order Blocks are created only when a structural break occurs, providing fewer but potentially higher-conviction zones.

Fair Value Gap (FVG) Detection

- BULL FVG — Current candle's low is above the candle-two-bars-ago's high (gap up)
https://www.tradingview.com/x/e5vthOiL/
- BEAR FVG — Current candle's high is below the candle-two-bars-ago's low (gap down)
https://www.tradingview.com/x/qEJ5x4ms/
FVGs are filtered by a minimum size threshold (percentage of ATR) to eliminate insignificant gaps, and are automatically removed when filled by subsequent price action or when they exceed their maximum age.

Inputs & Customization

Structure
- Show BOS / Show CHoCH — Independent visibility toggles for each structural event type.

Order Blocks
- OB Source — "All Swings" (OB at every pivot, more zones) or "BOS/CHoCH Only" (fewer, higher-conviction zones). Default: All Swings.
- Max OB Age — Bars before an OB is removed due to aging. Default: 120.
- Mitigation Grace — Bars after creation during which an OB cannot be mitigated. Default: 10.
- Max Active OBs — Limits simultaneously displayed OBs per side. Default: 6.

Fair Value Gaps
- Max FVG Age — Bars before an unfilled FVG is removed. Default: 50.
- Min FVG Size (% of ATR) — Minimum gap size to qualify. Default: 10%.
- Max Active FVGs — Limits simultaneously displayed FVGs per side. Default: 5.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Smart Structure Mapper [StrixEDGE]", shorttitle="Smart Structure Mapper [StrixEDGE]", overlay=true, max_labels_count=200, max_boxes_count=200, max_lines_count=100, max_bars_back=1000)

// ════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════

string GRP_S = "🔹 Swing Detection"
int i_pivotLen   = input.int(5,   "Pivot Lookback",       minval=2, maxval=20, group=GRP_S, tooltip="Bars left & right to confirm a swing point. Higher = fewer, stronger swings")
bool i_showSwings = input.bool(true, "Show Swing Points",  group=GRP_S)

string GRP_ST = "🔹 Structure"
bool i_showBos   = input.bool(true,  "Show BOS Labels",    group=GRP_ST)
bool i_showChoch = input.bool(true,  "Show CHoCH Labels",  group=GRP_ST)

string GRP_OB = "🔹 Order Blocks"
bool   i_showOB     = input.bool(true, "Show Order Blocks",    group=GRP_OB)
string i_obSource   = input.string("All Swings", "OB Source",  options=["All Swings", "BOS/CHoCH Only"], group=GRP_OB, tooltip="All Swings = OB at every pivot (more zones). BOS/CHoCH = only on structural breaks (fewer, higher-quality zones)")
int    i_obMaxAge   = input.int(120,   "Max OB Age (bars)",    minval=20, maxval=500, group=GRP_OB)
int    i_obGrace    = input.int(10,    "Mitigation Grace (bars)", minval=3, maxval=30, group=GRP_OB, tooltip="OBs cannot be mitigated for this many bars after creation — prevents instant deletion")
int    i_obMaxCount = input.int(6,     "Max Active OBs",       minval=1,  maxval=15,  group=GRP_OB)

string GRP_FVG = "🔹 Fair Value Gaps"
bool  i_showFVG    = input.bool(true, "Show FVGs",           group=GRP_FVG)
int   i_fvgMaxAge  = input.int(50,    "Max FVG Age (bars)",  minval=10, maxval=200, group=GRP_FVG)
int   i_fvgMaxCount = input.int(5,    "Max Active FVGs",     minval=1,  maxval=15, group=GRP_FVG)
float i_fvgMinSize = input.float(0.1, "Min FVG Size (% of ATR)", minval=0.01, maxval=1.0, step=0.05, group=GRP_FVG, tooltip="Filter out tiny gaps")

string GRP_VIS = "🔹 Visual"
bool   i_showDash   = input.bool(true,  "Show Dashboard",          group=GRP_VIS)
string i_dashPos    = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_VIS)
bool   i_showBg     = input.bool(true,  "Color Background by Structure", group=GRP_VIS)

string GRP_CLR = "🎨 Colors"
color i_colBull    = input.color(#00dcb4, "Bullish",       group=GRP_CLR)
color i_colBear    = input.color(#e8446d, "Bearish",       group=GRP_CLR)
color i_colNeutral = input.color(#8d99ae, "Neutral",       group=GRP_CLR)
color i_colOBBull  = input.color(#1b9e77, "Demand OB",    group=GRP_CLR)
color i_colOBBear  = input.color(#d62f5e, "Supply OB",    group=GRP_CLR)
color i_colFVGBull = input.color(#4cc9f0, "Bullish FVG",  group=GRP_CLR)
color i_colFVGBear = input.color(#f77f00, "Bearish FVG",  group=GRP_CLR)

// ════════════════════════════════════════════════════════════
//  SWING DETECTION
// ════════════════════════════════════════════════════════════

float pivotHi = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pivotLo = ta.pivotlow(low, i_pivotLen, i_pivotLen)

bool isPivotHi = not na(pivotHi)
bool isPivotLo = not na(pivotLo)

// Swing markers — text labels
if i_showSwings and isPivotHi
    label.new(bar_index - i_pivotLen, pivotHi, "Swing High", yloc=yloc.abovebar, style=label.style_none, textcolor=chart.fg_color, size=size.small)
if i_showSwings and isPivotLo
    label.new(bar_index - i_pivotLen, pivotLo, "Swing Low", yloc=yloc.belowbar, style=label.style_none, textcolor=chart.fg_color, size=size.small)

// ════════════════════════════════════════════════════════════
//  MARKET STRUCTURE TRACKING
// ════════════════════════════════════════════════════════════

// Persistent swing tracking
var float lastSH     = na     // last swing high price
var int   lastSH_bar = na     // bar index of last swing high
var float prevSH     = na     // previous swing high (for HH/LH comparison)

var float lastSL     = na     // last swing low price
var int   lastSL_bar = na     // bar index of last swing low
var float prevSL     = na     // previous swing low (for HL/LL comparison)

// Structure state
var int structure = 0          // +1 = bullish, -1 = bearish, 0 = undefined

// Swing high/low classification
var string lastHiType = ""     // "HH" or "LH"
var string lastLoType = ""     // "HL" or "LL"

// Update swing highs
if isPivotHi
    prevSH     := lastSH
    lastSH     := pivotHi
    lastSH_bar := bar_index - i_pivotLen
    if not na(prevSH)
        lastHiType := lastSH > prevSH ? "HH" : "LH"

// Update swing lows
if isPivotLo
    prevSL     := lastSL
    lastSL     := pivotLo
    lastSL_bar := bar_index - i_pivotLen
    if not na(prevSL)
        lastLoType := lastSL > prevSL ? "HL" : "LL"

// Determine structure from swing classification
if lastHiType == "HH" and lastLoType == "HL"
    structure := 1
else if lastHiType == "LH" and lastLoType == "LL"
    structure := -1

// ════════════════════════════════════════════════════════════
//  BOS & CHoCH DETECTION
// ════════════════════════════════════════════════════════════

// ── Flag-based break detection ──
// Pivots confirm with delay → price is often already past the level
// Flags track whether each level is "live" (unbroken)
var bool shLive = false        // swing high level is active, waiting to be broken
var bool slLive = false        // swing low level is active, waiting to be broken

// Activate levels when new swings are confirmed
if isPivotHi
    shLive := true
if isPivotLo
    slLive := true

// Detect breaks: first bar where close crosses the live level
bool bullBreak = shLive and not na(lastSH) and close > lastSH
bool bearBreak = slLive and not na(lastSL) and close < lastSL

// Deactivate after break (fire only once per level)
if bullBreak
    shLive := false
if bearBreak
    slLive := false

// Classify as BOS or CHoCH
bool isBullBOS   = bullBreak and structure == 1      // with trend = continuation
bool isBullCHoCH = bullBreak and structure != 1      // against trend or undefined = reversal
bool isBearBOS   = bearBreak and structure == -1     // with trend
bool isBearCHoCH = bearBreak and structure != -1     // against trend or undefined

// Flip structure on CHoCH
if isBullCHoCH
    structure := 1
if isBearCHoCH
    structure := -1

// Draw BOS labels
if i_showBos and isBullBOS
    label.new(bar_index, high, "BOS ↑", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(i_colBull, 10), textcolor=color.white, size=size.tiny)
if i_showBos and isBearBOS
    label.new(bar_index, low, "BOS ↓", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(i_colBear, 10), textcolor=color.white, size=size.tiny)

// Draw CHoCH labels (more prominent)
if i_showChoch and isBullCHoCH
    label.new(bar_index, high, "CHoCH ↑", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(#7b2ff7, 5), textcolor=color.white, size=size.small)
if i_showChoch and isBearCHoCH
    label.new(bar_index, low, "CHoCH ↓", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(#7b2ff7, 5), textcolor=color.white, size=size.small)

// BOS level lines
if isBullBOS or isBullCHoCH
    line.new(bar_index - 10, lastSH, bar_index, lastSH, color=color.new(i_colBull, 40), style=line.style_dashed, width=1)
if isBearBOS or isBearCHoCH
    line.new(bar_index - 10, lastSL, bar_index, lastSL, color=color.new(i_colBear, 40), style=line.style_dashed, width=1)

// ════════════════════════════════════════════════════════════
//  ORDER BLOCKS
// ════════════════════════════════════════════════════════════

// Arrays to track active OBs + creation bars
var array<box> bullOBs     = array.new<box>()
var array<int> bullOBBirth = array.new<int>()
var array<box> bearOBs     = array.new<box>()
var array<int> bearOBBirth = array.new<int>()

// ── Determine OB trigger ──
bool obFromSwings = i_obSource == "All Swings"

// Demand OB triggers: swing-based OR BOS/CHoCH-based
bool demandTrigger = i_showOB and (obFromSwings ? isPivotLo : (isBullBOS or isBullCHoCH))
// Supply OB triggers
bool supplyTrigger = i_showOB and (obFromSwings ? isPivotHi : (isBearBOS or isBearCHoCH))

// ── Create Demand OBs (last bearish candle before bullish move) ──
if demandTrigger
    int   obBar  = na
    float obHigh = na
    float obLow  = na
    int   searchStart = obFromSwings ? i_pivotLen : 1
    for i = searchStart to searchStart + 25
        if close[i] < open[i]
            obBar  := bar_index - i
            obHigh := high[i]
            obLow  := low[i]
            break
    if not na(obBar)
        string obText = "DEMAND\n" + str.tostring(obHigh, format.mintick) + "  →  " + str.tostring(obLow, format.mintick)
        box newOB = box.new(obBar, obHigh, obBar + 20, obLow,
             border_color     = i_colOBBull,
             bgcolor          = color.new(i_colOBBull, 85),
             border_width     = 2,
             border_style     = line.style_solid,
             text             = obText,
             text_color       = color.new(i_colOBBull, 0),
             text_size        = size.small,
             text_halign      = text.align_right,
             text_valign      = text.align_bottom,
             text_font_family = font.family_monospace)
        bullOBs.push(newOB)
        bullOBBirth.push(bar_index)

// ── Create Supply OBs (last bullish candle before bearish move) ──
if supplyTrigger
    int   obBar  = na
    float obHigh = na
    float obLow  = na
    int   searchStart = obFromSwings ? i_pivotLen : 1
    for i = searchStart to searchStart + 25
        if close[i] > open[i]
            obBar  := bar_index - i
            obHigh := high[i]
            obLow  := low[i]
            break
    if not na(obBar)
        string obText = "SUPPLY\n" + str.tostring(obHigh, format.mintick) + "  →  " + str.tostring(obLow, format.mintick)
        box newOB = box.new(obBar, obHigh, obBar + 20, obLow,
             border_color     = i_colOBBear,
             bgcolor          = color.new(i_colOBBear, 85),
             border_width     = 2,
             border_style     = line.style_solid,
             text             = obText,
             text_color       = color.new(i_colOBBear, 0),
             text_size        = size.small,
             text_halign      = text.align_right,
             text_valign      = text.align_bottom,
             text_font_family = font.family_monospace)
        bearOBs.push(newOB)
        bearOBBirth.push(bar_index)

// ── Manage Demand OBs ──
if bullOBs.size() > 0
    for i = bullOBs.size() - 1 to 0
        box ob     = bullOBs.get(i)
        int birth  = bullOBBirth.get(i)
        float obBot = box.get_bottom(ob)
        int   obLeft = box.get_left(ob)
        int   age    = bar_index - birth
        bool  pastGrace = age > i_obGrace
        bool  mitigated = pastGrace and close < obBot
        bool  tooOld    = (bar_index - obLeft) > i_obMaxAge
        if mitigated or tooOld
            box.delete(ob)
            bullOBs.remove(i)
            bullOBBirth.remove(i)

// ── Manage Supply OBs ──
if bearOBs.size() > 0
    for i = bearOBs.size() - 1 to 0
        box ob     = bearOBs.get(i)
        int birth  = bearOBBirth.get(i)
        float obTop = box.get_top(ob)
        int   obLeft = box.get_left(ob)
        int   age    = bar_index - birth
        bool  pastGrace = age > i_obGrace
        bool  mitigated = pastGrace and close > obTop
        bool  tooOld    = (bar_index - obLeft) > i_obMaxAge
        if mitigated or tooOld
            box.delete(ob)
            bearOBs.remove(i)
            bearOBBirth.remove(i)

// Trim excess OBs (keep newest)
while bullOBs.size() > i_obMaxCount
    box.delete(bullOBs.shift())
    bullOBBirth.shift()
while bearOBs.size() > i_obMaxCount
    box.delete(bearOBs.shift())
    bearOBBirth.shift()

// ════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ════════════════════════════════════════════════════════════

var array<box> bullFVGs = array.new<box>()
var array<box> bearFVGs = array.new<box>()

float atrRef = ta.atr(14)
float fvgMinAbs = atrRef * i_fvgMinSize

// Bullish FVG: candle[2].high < candle[0].low  (gap up)
bool isBullFVG = i_showFVG and low > high[2] and (low - high[2]) > fvgMinAbs
// Bearish FVG: candle[2].low > candle[0].high  (gap down)
bool isBearFVG = i_showFVG and high < low[2] and (low[2] - high) > fvgMinAbs

if isBullFVG
    string fvgText = "BULL FVG\n" + str.tostring(low, format.mintick) + "  →  " + str.tostring(high[2], format.mintick)
    box fvg = box.new(bar_index - 2, low, bar_index + 18, high[2],
         border_color = color.new(i_colFVGBull, 30),
         bgcolor      = color.new(i_colFVGBull, 90),
         border_width = 1,
         border_style = line.style_dotted,
         text         = fvgText,
         text_color   = color.new(i_colFVGBull, 0),
         text_size    = size.small,
         text_halign  = text.align_right,
         text_valign  = text.align_bottom,
         text_font_family = font.family_monospace)
    bullFVGs.push(fvg)

if isBearFVG
    string fvgText = "BEAR FVG\n" + str.tostring(low[2], format.mintick) + "  →  " + str.tostring(high, format.mintick)
    box fvg = box.new(bar_index - 2, low[2], bar_index + 18, high,
         border_color = color.new(i_colFVGBear, 30),
         bgcolor      = color.new(i_colFVGBear, 90),
         border_width = 1,
         border_style = line.style_dotted,
         text         = fvgText,
         text_color   = color.new(i_colFVGBear, 0),
         text_size    = size.small,
         text_halign  = text.align_right,
         text_valign  = text.align_bottom,
         text_font_family = font.family_monospace)
    bearFVGs.push(fvg)

// Manage bullish FVGs: fill detection + aging
if bullFVGs.size() > 0
    for i = bullFVGs.size() - 1 to 0
        box fvg = bullFVGs.get(i)
        float gapTop = box.get_top(fvg)
        float gapBot = box.get_bottom(fvg)
        int   gapLeft = box.get_left(fvg)
        bool filled = low <= gapBot
        bool tooOld = (bar_index - gapLeft) > i_fvgMaxAge
        if filled or tooOld
            box.delete(fvg)
            bullFVGs.remove(i)

// Manage bearish FVGs
if bearFVGs.size() > 0
    for i = bearFVGs.size() - 1 to 0
        box fvg = bearFVGs.get(i)
        float gapTop = box.get_top(fvg)
        float gapBot = box.get_bottom(fvg)
        int   gapLeft = box.get_left(fvg)
        bool filled = high >= gapTop
        bool tooOld = (bar_index - gapLeft) > i_fvgMaxAge
        if filled or tooOld
            box.delete(fvg)
            bearFVGs.remove(i)

// Trim excess FVGs
while bullFVGs.size() > i_fvgMaxCount
    box.delete(bullFVGs.shift())
while bearFVGs.size() > i_fvgMaxCount
    box.delete(bearFVGs.shift())

// ════════════════════════════════════════════════════════════
//  BACKGROUND
// ════════════════════════════════════════════════════════════

color bgCol = na
if i_showBg
    bgCol := structure == 1 ? color.new(i_colBull, 95) : structure == -1 ? color.new(i_colBear, 95) : na

bgcolor(bgCol, title="Structure Background")

// ════════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════════

if i_showDash
    var color C_BG   = color.new(#0d1117, 5)
    var color C_HDR  = color.new(#161b22, 0)
    var color C_ROW  = color.new(#0d1117, 10)
    var color C_TXT  = color.new(#e6edf3, 0)
    var color C_DIM  = color.new(#8b949e, 0)
    var color C_BORD = color.new(#30363d, 0)

    var table dash = table.new(
         i_dashPos == "Top Right"    ? position.top_right    :
         i_dashPos == "Top Left"     ? position.top_left     :
         i_dashPos == "Bottom Right" ? position.bottom_right :
                                       position.bottom_left,
         4, 8,
         bgcolor      = C_BG,
         border_width = 1,
         border_color = C_BORD,
         frame_width  = 2,
         frame_color  = C_BORD)

    // Row 0 — Title
    table.cell(dash, 0, 0, "AETHER ZONE StrixEDGE", text_color=C_TXT, text_size=size.normal, bgcolor=C_HDR)
    table.cell(dash, 1, 0, "", bgcolor=C_HDR)
    table.cell(dash, 2, 0, "", bgcolor=C_HDR)
    table.cell(dash, 3, 0, str.tostring(timeframe.period), text_color=C_DIM, text_size=size.small, bgcolor=C_HDR, text_halign=text.align_right)

    // Row 1 — Headers
    table.cell(dash, 0, 1, "",        text_color=C_DIM, text_size=size.tiny, bgcolor=C_HDR)
    table.cell(dash, 1, 1, "STATUS",  text_color=C_DIM, text_size=size.tiny, bgcolor=C_HDR)
    table.cell(dash, 2, 1, "LEVEL",   text_color=C_DIM, text_size=size.tiny, bgcolor=C_HDR)
    table.cell(dash, 3, 1, "",        text_color=C_DIM, text_size=size.tiny, bgcolor=C_HDR)

    // Row 2 — Market Structure
    string strText = structure == 1 ? "BULLISH" : structure == -1 ? "BEARISH" : "RANGING"
    color  strCol  = structure == 1 ? i_colBull : structure == -1 ? i_colBear : i_colNeutral
    string strDot  = structure == 1 ? "🟢" : structure == -1 ? "🔴" : "⚪"
    table.cell(dash, 0, 2, "Structure", text_color=C_TXT, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 1, 2, strText,     text_color=strCol, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 2, 2, lastHiType + " / " + lastLoType, text_color=C_DIM, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 3, 2, strDot,      text_size=size.small, bgcolor=C_ROW)

    // Row 3 — Last Swing High
    table.cell(dash, 0, 3, "Swing High", text_color=C_TXT, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 1, 3, lastHiType,   text_color=lastHiType == "HH" ? i_colBull : i_colBear, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 2, 3, not na(lastSH) ? str.tostring(lastSH, format.mintick) : "—", text_color=C_DIM, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 3, 3, "",           bgcolor=C_ROW)

    // Row 4 — Last Swing Low
    table.cell(dash, 0, 4, "Swing Low",  text_color=C_TXT, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 1, 4, lastLoType,    text_color=lastLoType == "HL" ? i_colBull : i_colBear, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 2, 4, not na(lastSL) ? str.tostring(lastSL, format.mintick) : "—", text_color=C_DIM, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 3, 4, "",           bgcolor=C_ROW)

    // Row 5 — Separator
    table.cell(dash, 0, 5, "", bgcolor=C_HDR)
    table.cell(dash, 1, 5, "", bgcolor=C_HDR)
    table.cell(dash, 2, 5, "", bgcolor=C_HDR)
    table.cell(dash, 3, 5, "", bgcolor=C_HDR)

    // Row 6 — Active Zones
    int totalDemand = bullOBs.size()
    int totalSupply = bearOBs.size()
    int totalBullFVG = bullFVGs.size()
    int totalBearFVG = bearFVGs.size()

    table.cell(dash, 0, 6, "Order Blocks", text_color=C_TXT, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 1, 6, str.tostring(totalDemand) + " Demand", text_color=i_colOBBull, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 2, 6, str.tostring(totalSupply) + " Supply", text_color=i_colOBBear, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 3, 6, str.tostring(totalDemand + totalSupply), text_color=C_DIM, text_size=size.small, bgcolor=C_ROW)

    // Row 7 — FVGs
    table.cell(dash, 0, 7, "Fair Value Gaps", text_color=C_TXT, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 1, 7, str.tostring(totalBullFVG) + " Bull", text_color=i_colFVGBull, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 2, 7, str.tostring(totalBearFVG) + " Bear", text_color=i_colFVGBear, text_size=size.small, bgcolor=C_ROW)
    table.cell(dash, 3, 7, str.tostring(totalBullFVG + totalBearFVG), text_color=C_DIM, text_size=size.small, bgcolor=C_ROW)

// ════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════

alertcondition(isBullBOS,   "Bullish BOS",  "AetherZone: Bullish Break of Structure on {{ticker}} ({{interval}})")
alertcondition(isBearBOS,   "Bearish BOS",  "AetherZone: Bearish Break of Structure on {{ticker}} ({{interval}})")
alertcondition(isBullCHoCH, "Bullish CHoCH", "AetherZone: Bullish Change of Character on {{ticker}} ({{interval}}) — potential reversal")
alertcondition(isBearCHoCH, "Bearish CHoCH", "AetherZone: Bearish Change of Character on {{ticker}} ({{interval}}) — potential reversal")
alertcondition(isBullFVG,   "Bullish FVG",  "AetherZone: Bullish Fair Value Gap on {{ticker}} ({{interval}})")
alertcondition(isBearFVG,   "Bearish FVG",  "AetherZone: Bearish Fair Value Gap on {{ticker}} ({{interval}})")

// ════════════════════════════════════════════════════════════
//  END — AetherZone v1.0
// ════════════════════════════════════════════════════════════
````
