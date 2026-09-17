<!-- tradingview-pine-id: PUB;df69169b4e774849a58bbc5f1c3a2c5f -->
<!-- tradingview-pine-version: 26.0 -->
<!-- tradingviewscripts-format: 1 -->
# Renko Suite

Source: https://www.tradingview.com/script/goNMbJOu-Renko-Suite/

## Description

all-in-one chart overlay engineered to clean up market noise, map structural order flow, and deliver actionable multi-market context directly on your standard time-based candle charts.

By combining synthetic Renko trend tracking with automated market structure levels and real-time index monitoring, this script allows you to spot structural shifts instantly without switching chart types.

Primary Use Cases
Noise Filtering & Trend Identification: Use synthetic Renko bar coloring to eliminate intraday choppy price movements, allowing you to hold positions during strong trends and spot real structural trend reversals early.

Initial Risk Mapping: The First-Candle Renko Box locks onto the high and low of the exact candle that triggered a new Renko color flip. Traders can use this initial range to set initial stop-losses or measure early breakout consolidation zones.

Target & Reversal Level Execution: Use the forward-looking Continuation / Flip Lines to identify exact price targets where the next Renko brick will print or where price must reverse to trigger a trend flip.

Dynamic Support/Resistance Tracking: Leverage the automated Pivot S/R lines to see where key swing highs and lows align with current Renko trends, identifying high-probability confluence zones for entries and exits.

Multi-Market Confluence: Monitor the live Index Dashboard (QQQ, SPY, DIA) in the corner of your screen to ensure individual stock trades align with the overall direction of the broader indices.

Key Features
Synthetic Renko Bar Coloring: Repaints live chart candles according to a custom-defined Renko box size without losing time-based bar visibility.

First-Candle Renko Trend Boxes: Generates a continuous visual box starting from the precise candle where a Renko color change occurs, locking its top/bottom boundaries to that trigger candle while extending forward until the next trend flip.

Forward-Looking Target & Projection Lines: Dynamically plots forward-extending line levels indicating the exact price target for the next bullish/bearish Renko brick, alongside a shaded Zero Zone marking the last closed Renko brick range.

Automated Pivot Support & Resistance: Identifies structural swing points via a multi-pass matrix algorithm and projects horizontal ray lines across your chart.

Live Index Dashboard: A non-intrusive bottom-right table providing real-time price readouts for QQQ, SPY, and DIA (including extended session data).

Inputs & Customization
Renko Settings: Adjust the primary box size, custom bullish/bearish colors, and toggle forward-looking target projection lines or the Zero Zone overlay.

Box Settings: Toggle trend boxes on/off and adjust transparency to suit dark or light chart themes.

Pivot Support / Resistance: Adjust pivot lookback periods (lb / rb), line styles (dashed, solid, dotted), widths, and distinct colors for support and resistance.

Index Display Settings: Selectively show or hide individual trackers for QQQ, SPY, or DIA.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KinetiCapital
//

//@version=6
indicator("Renko Suite", overlay=true, max_boxes_count=500, max_lines_count=500)

// =============================================================================
// --- INPUTS ---
// =============================================================================
group_renko  = "Renko Settings"
boxSizeInput = input.float(20.0, "Renko Size", minval=0.0001, inline= 'box', group=group_renko)

colorGreen   = input.color(color.rgb(38, 166, 154, 0), "", inline= 'box', group=group_renko)
colorRed     = input.color(color.rgb(239, 83, 80, 0), "", inline= 'box', group=group_renko)
showZeroZone        = true //input.bool(true, "Recently closed Renko Range", inline = 'renko', group=group_renko)
fillZeroZone        = input.bool(true, "Fill", inline = 'box', group=group_renko)
fillZeroTransp      = input.int(72, "", minval=0, maxval=100, inline = 'box', group=group_renko)
showProjLine        = input.bool(true, "Continuation / Flip Lines?", group=group_renko)
extendForecastLines = input.bool(true, "Anchor Start of Brick", inline = 'anchor', group=group_renko)
renko_offset        = input.int(2, "or offset", minval=0, maxval=100, inline = 'anchor', group=group_renko, tooltip = 'if not anchored')
prevBoxCount        = input.int(50, "Historical Boxes", minval=0, maxval=500, group=group_renko)

useRenkoBarColor = input.bool(true, "Color Candles by Renko Trend?", group=group_renko)
showRenkoBoxes   = false 
i_boxTransp      = fillZeroTransp

// --- MACRO RENKO SETTINGS ---
group_macro          = "Macro Renko Settings"
showMacroRenkoBox    = input.bool(true, "Macro Renko", inline = 'renkomacro', group=group_macro)
macroBoxSizeInput    = input.float(100.0, "", minval=0.0001, inline = 'renkomacro', group=group_macro)
macroOffset          = input.int(8, "Offset", minval=0, maxval=100, inline = 'renkomacro', group=group_macro)

// =============================================================================
// --- REAL-TIME TOUCH RENKO ENGINE ---
// =============================================================================
var float renkoTop     = na
var float renkoBottom  = na
var int renkoDir       = 0 
var int flipBarIndex   = bar_index
var int brickBarIndex  = bar_index // Tracks the start of the current active brick

// Array to store historical boxes
var box[] historicalBoxes = array.new_box()

// Helper function to record dynamic brick history
logHistoricalBrick(float bTop, float bBottom, int bStart, int bEnd, color bCol) =>
    if prevBoxCount > 0
        color borderCol = bCol
        color bgCol     = color.new(bCol, fillZeroTransp)
        box newHistBox  = box.new(left = bStart, top = bTop, right = bEnd, bottom = bBottom, border_color = borderCol, bgcolor = bgCol)
        array.push(historicalBoxes, newHistBox)
        while array.size(historicalBoxes) > prevBoxCount
            box.delete(array.shift(historicalBoxes))

// Initialize on first bar
if na(renkoTop) or na(renkoBottom)
    renkoBottom   := math.floor(close / boxSizeInput) * boxSizeInput
    renkoTop      := renkoBottom + boxSizeInput
    renkoDir      := close >= open ? 1 : -1
    flipBarIndex  := bar_index
    brickBarIndex := bar_index

bool trendFlipped = false

if renkoDir == 1
    // First, process flip down
    if low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        renkoDir      := -1
        trendFlipped  := true
        flipBarIndex  := bar_index
        brickBarIndex := bar_index

    // Additional downward continuation steps
    while renkoDir == -1 and low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        brickBarIndex := bar_index

    // Upward continuation steps
    while renkoDir == 1 and high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        brickBarIndex := bar_index

else if renkoDir == -1
    // First, process flip up
    if high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        renkoDir      := 1
        trendFlipped  := true
        flipBarIndex  := bar_index
        brickBarIndex := bar_index

    // Additional upward continuation steps
    while renkoDir == 1 and high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        brickBarIndex := bar_index

    // Downward continuation steps
    while renkoDir == -1 and low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        brickBarIndex := bar_index

// Truncate or clear historical boxes dynamically if user lowers the input count
if array.size(historicalBoxes) > prevBoxCount
    while array.size(historicalBoxes) > prevBoxCount
        box.delete(array.shift(historicalBoxes))

// Zero Zone Boundaries
float rkOpen       = renkoDir == 1 ? renkoBottom : renkoBottom + boxSizeInput
float rkClose      = renkoDir == 1 ? renkoBottom + boxSizeInput : renkoBottom
bool isGreenBrick  = renkoDir == 1
bool isRedBrick    = renkoDir == -1

color activeStateColor = isGreenBrick ? colorGreen : colorRed
color dynamicFillColor = color.new(activeStateColor, fillZeroTransp)

// =============================================================================
// --- REAL-TIME MACRO RENKO ENGINE ---
// =============================================================================
var float macroRenkoTop    = na
var float macroRenkoBottom = na
var int macroRenkoDir      = 0

if na(macroRenkoTop) or na(macroRenkoBottom)
    macroRenkoBottom := math.floor(close / macroBoxSizeInput) * macroBoxSizeInput
    macroRenkoTop    := macroRenkoBottom + macroBoxSizeInput
    macroRenkoDir    := close >= open ? 1 : -1

if macroRenkoDir == 1
    if low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput
        macroRenkoDir    := -1

    while macroRenkoDir == -1 and low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput

    while macroRenkoDir == 1 and high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput

else if macroRenkoDir == -1
    if high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput
        macroRenkoDir    := 1

    while macroRenkoDir == 1 and high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput

    while macroRenkoDir == -1 and low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput

// =============================================================================
// --- MACRO RENKO BOX DISPLAY ---
// =============================================================================
var box currentMacroBox = na

if showMacroRenkoBox
    color macroColor     = macroRenkoDir == 1 ? colorGreen : colorRed
    color macroBgColor   = color.new(macroColor, i_boxTransp)
    color macroBorderCol = color.new(macroColor, 40)

    if barstate.islast
        box.delete(currentMacroBox)
        int mLeft  = bar_index + macroOffset
        int mRight = mLeft + 6
        currentMacroBox := box.new(left = mLeft, top = macroRenkoTop, right = mRight, bottom = macroRenkoBottom, border_color = macroBorderCol, bgcolor = macroBgColor)

if not showMacroRenkoBox and not na(currentMacroBox)
    box.delete(currentMacroBox)
    currentMacroBox := na

// =============================================================================
// --- PROJECTION LOGIC ---
// =============================================================================
float upTarget   = isGreenBrick ? rkClose + boxSizeInput : rkOpen + boxSizeInput
float downTarget = isRedBrick   ? rkClose - boxSizeInput : rkOpen - boxSizeInput

// =============================================================================
// --- CURRENT RENKO TREND BOX LOGIC ---
// =============================================================================
var box currentBox = na

if showRenkoBoxes
    color activeColor = isGreenBrick ? colorGreen : colorRed

    if trendFlipped
        currentBox := box.new(
             left         = bar_index, 
             top          = renkoTop, 
             right        = bar_index, 
             bottom       = renkoBottom, 
             border_color = color.new(activeColor, 100), 
             bgcolor      = color.new(activeColor, i_boxTransp)
             )
    else if not na(currentBox)
        box.set_top(currentBox, renkoTop)
        box.set_bottom(currentBox, renkoBottom)
        box.set_right(currentBox, bar_index)

if not showRenkoBoxes and not na(currentBox)
    box.delete(currentBox)
    currentBox := na

// =============================================================================
// --- ZERO ZONE & TARGET PROJECTION LINES ---
// =============================================================================
var line lineUp        = na
var line lineDown      = na
var line lineOpen      = na
var line lineClose     = na
var linefill zFill     = na

if barstate.islast
    line.delete(lineUp)
    line.delete(lineDown)
    line.delete(lineOpen)
    line.delete(lineClose)
    linefill.delete(zFill)

    int startX = extendForecastLines ? brickBarIndex : bar_index + renko_offset
    int endX   = extendForecastLines ? bar_index + 5 : bar_index + renko_offset + 6

    if showZeroZone
        // Make boundary lines transparent if anchored to hide them
        color lineCol = extendForecastLines ? color.new(activeStateColor, 100) : activeStateColor

        lineOpen  := line.new(x1 = startX, y1 = rkOpen, x2 = endX, y2 = rkOpen, color = lineCol, style = line.style_solid, width = 3)
        lineClose := line.new(x1 = startX, y1 = rkClose, x2 = endX, y2 = rkClose, color = lineCol, style = line.style_solid, width = 3)

        if fillZeroZone
            zFill := linefill.new(lineOpen, lineClose, dynamicFillColor)

    if showProjLine
        lineUp   := line.new(x1 = startX, y1 = upTarget, x2 = endX, y2 = upTarget, color = colorGreen, style = line.style_solid, width = 3)
        lineDown := line.new(x1 = startX, y1 = downTarget, x2 = endX, y2 = downTarget, color = colorRed, style = line.style_solid, width = 3)

// =============================================================================
// --- BAR COLORING ---
// =============================================================================
color currentBrickColor = isGreenBrick ? colorGreen : colorRed
barcolor(useRenkoBarColor ? color.new(currentBrickColor, 0) : na)

// =============================================================================
// --- DUAL STRUCTURAL REVERSALS ---
// =============================================================================
grpR = "Potential Change in State"

showStateChange = input.bool(true, "Show Change in State Lines?", group = grpR)
lenMinor        = input.int(6,  "Minor", minval = 2, inline = 'mm', group = grpR)
lenMajor        = input.int(12, "Major", minval = 5, inline = 'mm', group = grpR)

extendBars = 25 

colBull    = input.color(color.rgb(38, 166, 154), "", inline = 'mm', group = grpR)
colBear    = input.color(color.rgb(239, 83, 80), "", inline = 'mm', group = grpR)

// State Variables
var float hiMin     = na
var int   hiMinBar  = na
var bool  hiMinLive = false
var float loMin     = na
var int   loMinBar  = na
var bool  loMinLive = false
var int   trendMin  = 0

var float hiMaj     = na
var int   hiMajBar  = na
var bool  hiMajLive = false
var float loMaj     = na
var int   loMajBar  = na
var bool  loMajLive = false
var int   trendMaj  = 0

// Pivot Memory
var float lastValHiMin    = na
var int   lastValHiMinBar = na
var float lastValLoMin    = na
var int   lastValLoMinBar = na

var float lastValHiMaj    = na
var int   lastValHiMajBar = na
var float lastValLoMaj    = na
var int   lastValLoMajBar = na

// Pivot Calculations
phMin = ta.pivothigh(lenMinor, lenMinor)
plMin = ta.pivotlow(lenMinor, lenMinor)

phMaj = ta.pivothigh(lenMajor, lenMajor)
plMaj = ta.pivotlow(lenMajor, lenMajor)

// Update Minor Levels
if not na(phMin)
    hiMin           := phMin
    hiMinBar        := bar_index - lenMinor
    hiMinLive       := true
    lastValHiMin    := phMin
    lastValHiMinBar := bar_index - lenMinor

if not na(plMin)
    loMin           := plMin
    loMinBar        := bar_index - lenMinor
    loMinLive       := true
    lastValLoMin    := plMin
    lastValLoMinBar := bar_index - lenMinor

// Update Major Levels
if not na(phMaj)
    hiMaj           := phMaj
    hiMajBar        := bar_index - lenMajor
    hiMajLive       := true
    lastValHiMaj    := phMaj
    lastValHiMajBar := bar_index - lenMajor

if not na(plMaj)
    loMaj           := plMaj
    loMajBar        := bar_index - lenMajor
    loMajLive       := true
    lastValLoMaj    := plMaj
    lastValLoMajBar := bar_index - lenMajor

// Execution Logic
if hiMinLive and close > hiMin
    if trendMin == -1 or trendMin == 0
        trendMin := 1
        if showStateChange
            line.new(hiMinBar, hiMin, bar_index, hiMin, color = colBull, width = 1)
        if not na(lastValLoMin)
            loMin     := lastValLoMin
            loMinBar  := lastValLoMinBar
            loMinLive := true
    hiMinLive := false

if loMinLive and close < loMin
    if trendMin == 1 or trendMin == 0
        trendMin := -1
        if showStateChange
            line.new(loMinBar, loMin, bar_index, loMin, color = colBear, width = 1)
        if not na(lastValHiMin)
            hiMin     := lastValHiMin
            hiMinBar  := lastValHiMinBar
            hiMinLive := true
    loMinLive := false

if hiMajLive and close > hiMaj
    if trendMaj == -1 or trendMaj == 0
        trendMaj := 1
        if showStateChange
            line.new(hiMajBar, hiMaj, bar_index, hiMaj, color = colBull, width = 3)
        if not na(lastValLoMaj)
            loMaj     := lastValLoMaj
            loMajBar  := lastValLoMajBar
            loMajLive := true
    hiMajLive := false

if loMajLive and close < loMaj
    if trendMaj == 1 or trendMaj == 0
        trendMaj := -1
        if showStateChange
            line.new(loMajBar, loMaj, bar_index, loMaj, color = colBear, width = 3)
        if not na(lastValHiMaj)
            hiMaj     := lastValHiMaj
            hiMajBar  := lastValHiMajBar
            hiMajLive := true
    hiMajLive := false

// Proactive Dual Projection
var line projMin = na
var line projMaj = na

line.delete(projMin)
line.delete(projMaj)

if showStateChange
    if trendMin == -1 and hiMinLive
        projMin := line.new(hiMinBar, hiMin, bar_index + extendBars, hiMin, color = colBull, style = line.style_dotted, width = 1)

    if trendMin == 1 and loMinLive
        projMin := line.new(loMinBar, loMin, bar_index + extendBars, loMin, color = colBear, style = line.style_dotted, width = 1)

    if trendMaj == -1 and hiMajLive
        projMaj := line.new(hiMajBar, hiMaj, bar_index + extendBars, hiMaj, color = colBull, style = line.style_dotted, width = 3)

    if trendMaj == 1 and loMajLive
        projMaj := line.new(loMajBar, loMaj, bar_index + extendBars, loMaj, color = colBear, style = line.style_dotted, width = 3)

// =============================================================================
// --- UNIFIED DASHBOARD TABLE ---
// =============================================================================
grpToggle    = "Index Display Settings"
showQQQ      = input.bool(true, "QQQ", inline = 'dash', group = grpToggle)
showSPY      = input.bool(false, "SPY", inline = 'dash', group = grpToggle)
showDIA      = input.bool(false, "DIA", inline = 'dash', group = grpToggle)

t_qqq = ticker.new("NASDAQ", "QQQ", session.extended)
t_spy = ticker.new("AMEX", "SPY", session.extended)
t_dia = ticker.new("AMEX", "DIA", session.extended)

assetPriceQQQ = request.security(t_qqq, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceSPY = request.security(t_spy, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceDIA = request.security(t_dia, timeframe.period, close, ignore_invalid_symbol = true)

var table dashboard = table.new(position = position.bottom_right, columns = 2, rows = 5, border_width = 0)

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 4)
    int curRow = 2

    if showQQQ
        table.cell(dashboard, 0, curRow, "QQQ", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceQQQ, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

    if showSPY
        table.cell(dashboard, 0, curRow, "SPY", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceSPY, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

    if showDIA
        table.cell(dashboard, 0, curRow, "DIA", bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        table.cell(dashboard, 1, curRow, str.tostring(assetPriceDIA, "#.##"), bgcolor = color.rgb(174, 171, 171), text_color = color.black, text_size = size.small)
        curRow += 1

// =============================================================================
// --- DAILY ANCHORED VWAP (AVWAP) ---
// =============================================================================
grp_avwap   = "Daily AVWAP Settings"
showAVWAP   = input.bool(true, "Daily AVWAP", inline = 'vwap', group = grp_avwap)
colorAVWAP  = input.color(color.rgb(132, 33, 190, 23), "", inline = 'vwap', group = grp_avwap)
widthAVWAP  = input.int(1, "", minval = 1, maxval = 4, inline = 'vwap', group = grp_avwap)

bool isNewDay = ta.change(time("D")) != 0

var float sumPV  = 0.0
var float sumVol = 0.0

if isNewDay
    sumPV  := hlc3 * volume
    sumVol := volume
else
    sumPV  += hlc3 * volume
    sumVol += volume

float dailyAVWAP = sumVol > 0 ? sumPV / sumVol : na

plot(showAVWAP ? dailyAVWAP : na, title = "Daily AVWAP", color = colorAVWAP, linewidth = widthAVWAP)
````
