# Renko Suite

- url: https://www.tradingview.com/script/goNMbJOu-Renko-Suite/
- type: indicator
- pine_id: PUB;df69169b4e774849a58bbc5f1c3a2c5f
- version: 32.0

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
boxSizeInput = input.float(10.0, "Renko Size", minval=0.0001, inline= 'box', group=group_renko)

colorGreen   = input.color(color.rgb(38, 166, 154, 0), "", inline= 'box', group=group_renko)
colorRed     = input.color(color.rgb(239, 83, 80, 0), "", inline= 'box', group=group_renko)
showZeroZone        = true //input.bool(true, "Recently closed Renko Range", inline = 'renko', group=group_renko)
fillZeroZone        = input.bool(true, "Fill", inline = 'box', group=group_renko)
fillZeroTransp      = input.int(85, "", minval=0, maxval=100, inline = 'box', group=group_renko)
extendForecastLines = input.bool(true, "Anchor Start of Brick", inline = 'anchor', group=group_renko)
renko_offset        = input.int(2, "or offset", minval=0, maxval=100, inline = 'anchor', group=group_renko, tooltip = 'if not anchored')
prevBoxCount        = input.int(50, "Historical Boxes", minval=0, maxval=500, group=group_renko)
showProjLine        = input.bool(true, "Continuation / Flip Lines?", group=group_renko)
showRenkoBoxes   = false 
i_boxTransp      = fillZeroTransp

// --- MACRO RENKO SETTINGS ---

showMacroRenkoBox    = input.bool(true, "Macro Renko", inline = 'renkomacro', group=group_renko)
macroBoxSizeInput    = input.float(20.0, "", minval=0.0001, inline = 'renkomacro', group=group_renko)
macroOffset          = input.int(8, "Offset", minval=0, maxval=100, inline = 'renkomacro', group=group_renko)

// --- TRIGGER SHAPE INPUTS ---
group_markers      = "Renko based markers"
renkoTriggerSource = input.string("Macro", "Renko Engine Source", options = ["Micro (Standard)", "Macro"], group = group_markers)
showTriggerShapes  = input.bool(false, "Brick Trigger", inline = 'triggers', group = group_markers)
onlyColorChanges   = input.bool(false, "Brick change only", inline = 'triggers', group = group_markers)
showStopZone       = input.bool(false, "Stop Zone", inline = 'stopzone', group = group_markers)
stopZoneColor      = input.color(color.rgb(149, 149, 149, 50), "", inline = 'stopzone', group = group_markers)

// =============================================================================
// --- REAL-TIME TOUCH RENKO ENGINE (MICRO) ---
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
bool triggerGreen = false
bool triggerRed   = false

if renkoDir == 1
    // First, process flip down
    if low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        renkoDir      := -1
        trendFlipped  := true
        triggerRed    := true
        flipBarIndex  := bar_index
        brickBarIndex := bar_index

    // Additional downward continuation steps
    while renkoDir == -1 and low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        triggerRed    := true
        brickBarIndex := bar_index

    // Upward continuation steps
    while renkoDir == 1 and high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        triggerGreen  := true
        brickBarIndex := bar_index

else if renkoDir == -1
    // First, process flip up
    if high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        renkoDir      := 1
        trendFlipped  := true
        triggerGreen  := true
        flipBarIndex  := bar_index
        brickBarIndex := bar_index

    // Additional upward continuation steps
    while renkoDir == 1 and high >= renkoTop + boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorGreen)
        renkoBottom   := renkoTop
        renkoTop      := renkoTop + boxSizeInput
        triggerGreen  := true
        brickBarIndex := bar_index

    // Downward continuation steps
    while renkoDir == -1 and low <= renkoBottom - boxSizeInput
        logHistoricalBrick(renkoTop, renkoBottom, brickBarIndex, bar_index, colorRed)
        renkoTop      := renkoBottom
        renkoBottom   := renkoBottom - boxSizeInput
        triggerRed    := true
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

bool macroTrendFlipped = false
bool macroTriggerGreen = false
bool macroTriggerRed   = false

if macroRenkoDir == 1
    if low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput
        macroRenkoDir    := -1
        macroTrendFlipped:= true
        macroTriggerRed  := true

    while macroRenkoDir == -1 and low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput
        macroTriggerRed  := true

    while macroRenkoDir == 1 and high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput
        macroTriggerGreen:= true

else if macroRenkoDir == -1
    if high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput
        macroRenkoDir    := 1
        macroTrendFlipped:= true
        macroTriggerGreen:= true

    while macroRenkoDir == 1 and high >= macroRenkoTop + macroBoxSizeInput
        macroRenkoBottom := macroRenkoTop
        macroRenkoTop    := macroRenkoTop + macroBoxSizeInput
        macroTriggerGreen:= true

    while macroRenkoDir == -1 and low <= macroRenkoBottom - macroBoxSizeInput
        macroRenkoTop    := macroRenkoBottom
        macroRenkoBottom := macroRenkoBottom - macroBoxSizeInput
        macroTriggerRed  := true

// =============================================================================
// --- RENKO TRIGGER SHAPES LOGIC ---
// =============================================================================
bool activeTriggerGreen  = renkoTriggerSource == "Macro" ? macroTriggerGreen : triggerGreen
bool activeTriggerRed    = renkoTriggerSource == "Macro" ? macroTriggerRed   : triggerRed
bool activeTrendFlipped  = renkoTriggerSource == "Macro" ? macroTrendFlipped : trendFlipped

bool showGreenTriangle = showTriggerShapes and activeTriggerGreen and (not onlyColorChanges or activeTrendFlipped)
bool showRedTriangle   = showTriggerShapes and activeTriggerRed   and (not onlyColorChanges or activeTrendFlipped)

plotshape(showGreenTriangle, title="Renko Bull Trigger", style=shape.triangleup,   location=location.belowbar, color=colorGreen, size=size.tiny)
plotshape(showRedTriangle,   title="Renko Bear Trigger", style=shape.triangledown, location=location.abovebar, color=colorRed,   size=size.tiny)

/// =============================================================================
// --- STOP ZONE BOX LOGIC ---
// =============================================================================
var box stopZoneBox = na

// Get active box size based on trigger engine source
float activeBoxSize = renkoTriggerSource == "Macro" ? macroBoxSizeInput : boxSizeInput

// Check for raw triggers combined with the color change filter (evaluated independently of showTriggerShapes)
bool stopZoneGreenTrigger = activeTriggerGreen and (not onlyColorChanges or activeTrendFlipped)
bool stopZoneRedTrigger   = activeTriggerRed   and (not onlyColorChanges or activeTrendFlipped)

// Create or update stop zone when a trigger fires, provided showStopZone is enabled
if showStopZone and stopZoneGreenTrigger
    float triggerPrice = renkoTriggerSource == "Macro" ? macroRenkoTop : renkoTop
    float sTop    = triggerPrice - activeBoxSize
    float sBottom = triggerPrice - (2.0 * activeBoxSize)
    stopZoneBox  := box.new(left = bar_index, top = sTop, right = bar_index, bottom = sBottom, border_color = color.new(stopZoneColor, 100), bgcolor = stopZoneColor)

else if showStopZone and stopZoneRedTrigger
    float triggerPrice = renkoTriggerSource == "Macro" ? macroRenkoBottom : renkoBottom
    float sBottom = triggerPrice + activeBoxSize
    float sTop    = triggerPrice + (2.0 * activeBoxSize)
    stopZoneBox  := box.new(left = bar_index, top = sTop, right = bar_index, bottom = sBottom, border_color = color.new(stopZoneColor, 100), bgcolor = stopZoneColor)

else if showStopZone and not na(stopZoneBox)
    // Extend current box to current bar
    box.set_right(stopZoneBox, bar_index)

if not showStopZone and not na(stopZoneBox)
    box.delete(stopZoneBox)
    stopZoneBox := na

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
        color lineCol = extendForecastLines ? color.new(activeStateColor, 100) : activeStateColor

        lineOpen  := line.new(x1 = startX, y1 = rkOpen, x2 = endX, y2 = rkOpen, color = lineCol, style = line.style_solid, width = 3)
        lineClose := line.new(x1 = startX, y1 = rkClose, x2 = endX, y2 = rkClose, color = lineCol, style = line.style_solid, width = 3)

        if fillZeroZone
            zFill := linefill.new(lineOpen, lineClose, dynamicFillColor)

    if showProjLine
        lineUp   := line.new(x1 = startX, y1 = upTarget, x2 = endX, y2 = upTarget, color = colorGreen, style = line.style_solid, width = 3)
        lineDown := line.new(x1 = startX, y1 = downTarget, x2 = endX, y2 = downTarget, color = colorRed, style = line.style_solid, width = 3)

// =============================================================================
// --- ANCHORED VWAP (6H NY TIME BLOCKS) ---
// =============================================================================

// === Settings === //
float source   = ohlc4
int offset_val = 0

// --- Controls ---
enable_6h = input.bool(true, "6H VWAP", inline = '6H', group = '6H AVWAP')
sd_6h     = input.bool(true, "SD",      inline = '6H', group = '6H AVWAP')
col_6h    = input.color(color.rgb(114, 12, 169, 27), "", inline = '6H', group = '6H AVWAP')
wid_6h    = input.int(2, "", minval = 1, inline = '6H', group = '6H AVWAP')

// === Time Checks (America/New_York Timezone) === //
ny_hour = hour(time, "America/New_York")

s_6h_00 = ny_hour >= 0  and ny_hour < 6    // 00:00 - 06:00 NY
is_6h_00_reset = s_6h_00 and not (s_6h_00[1])

s_6h_06 = ny_hour >= 6  and ny_hour < 12   // 06:00 - 12:00 NY
is_6h_06_reset = s_6h_06 and not (s_6h_06[1])

s_6h_12 = ny_hour >= 12 and ny_hour < 18   // 12:00 - 18:00 NY
is_6h_12_reset = s_6h_12 and not (s_6h_12[1])

s_6h_18 = ny_hour >= 18 and ny_hour < 24   // 18:00 - 24:00 NY
is_6h_18_reset = s_6h_18 and not (s_6h_18[1])

// === Dynamic 6H Calculations === //
var float sum_pv_6h_00   = 0.0
var float sum_v_6h_00    = 0.0
var float sum_pv2_6h_00  = 0.0

if is_6h_00_reset
    sum_pv_6h_00  := source * volume
    sum_v_6h_00   := volume
    sum_pv2_6h_00 := volume * math.pow(source, 2)
else if s_6h_00
    sum_pv_6h_00  += source * volume
    sum_v_6h_00   += volume
    sum_pv2_6h_00 += volume * math.pow(source, 2)

vwap_6h_00 = s_6h_00 and sum_v_6h_00 > 0 ? (sum_pv_6h_00 / sum_v_6h_00) : na
stdev_6h_00 = s_6h_00 and sum_v_6h_00 > 0 ? math.sqrt(math.max(0, (sum_pv2_6h_00 / sum_v_6h_00) - math.pow(vwap_6h_00, 2))) : na

var float sum_pv_6h_06   = 0.0
var float sum_v_6h_06    = 0.0
var float sum_pv2_6h_06  = 0.0

if is_6h_06_reset
    sum_pv_6h_06  := source * volume
    sum_v_6h_06   := volume
    sum_pv2_6h_06 := volume * math.pow(source, 2)
else if s_6h_06
    sum_pv_6h_06  += source * volume
    sum_v_6h_06   += volume
    sum_pv2_6h_06 += volume * math.pow(source, 2)

vwap_6h_06 = s_6h_06 and sum_v_6h_06 > 0 ? (sum_pv_6h_06 / sum_v_6h_06) : na
stdev_6h_06 = s_6h_06 and sum_v_6h_06 > 0 ? math.sqrt(math.max(0, (sum_pv2_6h_06 / sum_v_6h_06) - math.pow(vwap_6h_06, 2))) : na

var float sum_pv_6h_12   = 0.0
var float sum_v_6h_12    = 0.0
var float sum_pv2_6h_12  = 0.0

if is_6h_12_reset
    sum_pv_6h_12  := source * volume
    sum_v_6h_12   := volume
    sum_pv2_6h_12 := volume * math.pow(source, 2)
else if s_6h_12
    sum_pv_6h_12  += source * volume
    sum_v_6h_12   += volume
    sum_pv2_6h_12 += volume * math.pow(source, 2)

vwap_6h_12 = s_6h_12 and sum_v_6h_12 > 0 ? (sum_pv_6h_12 / sum_v_6h_12) : na
stdev_6h_12 = s_6h_12 and sum_v_6h_12 > 0 ? math.sqrt(math.max(0, (sum_pv2_6h_12 / sum_v_6h_12) - math.pow(vwap_6h_12, 2))) : na

var float sum_pv_6h_18   = 0.0
var float sum_v_6h_18    = 0.0
var float sum_pv2_6h_18  = 0.0

if is_6h_18_reset
    sum_pv_6h_18  := source * volume
    sum_v_6h_18   := volume
    sum_pv2_6h_18 := volume * math.pow(source, 2)
else if s_6h_18
    sum_pv_6h_18  += source * volume
    sum_v_6h_18   += volume
    sum_pv2_6h_18 += volume * math.pow(source, 2)

vwap_6h_18 = s_6h_18 and sum_v_6h_18 > 0 ? (sum_pv_6h_18 / sum_v_6h_18) : na
stdev_6h_18 = s_6h_18 and sum_v_6h_18 > 0 ? math.sqrt(math.max(0, (sum_pv2_6h_18 / sum_v_6h_18) - math.pow(vwap_6h_18, 2))) : na

// === Plotting 6H Base & SD Lines === //
plot(enable_6h ? vwap_6h_00 : na, '6H (00:00-06:00 NY)', col_6h, wid_6h, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_00 + stdev_6h_00 : na, '6H (00:00-06:00) +1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_00 - stdev_6h_00 : na, '6H (00:00-06:00) -1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_00 + 2 * stdev_6h_00 : na, '6H (00:00-06:00) +2SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_00 - 2 * stdev_6h_00 : na, '6H (00:00-06:00) -2SD', col_6h, 1, plot.style_linebr, offset = offset_val)

plot(enable_6h ? vwap_6h_06 : na, '6H (06:00-12:00 NY)', col_6h, wid_6h, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_06 + stdev_6h_06 : na, '6H (06:00-12:00) +1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_06 - stdev_6h_06 : na, '6H (06:00-12:00) -1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_06 + 2 * stdev_6h_06 : na, '6H (06:00-12:00) +2SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_06 - 2 * stdev_6h_06 : na, '6H (06:00-12:00) -2SD', col_6h, 1, plot.style_linebr, offset = offset_val)

plot(enable_6h ? vwap_6h_12 : na, '6H (12:00-18:00 NY)', col_6h, wid_6h, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_12 + stdev_6h_12 : na, '6H (12:00-18:00) +1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_12 - stdev_6h_12 : na, '6H (12:00-18:00) -1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_12 + 2 * stdev_6h_12 : na, '6H (12:00-18:00) +2SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_12 - 2 * stdev_6h_12 : na, '6H (12:00-18:00) -2SD', col_6h, 1, plot.style_linebr, offset = offset_val)

plot(enable_6h ? vwap_6h_18 : na, '6H (18:00-24:00 NY)', col_6h, wid_6h, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_18 + stdev_6h_18 : na, '6H (18:00-24:00) +1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_18 - stdev_6h_18 : na, '6H (18:00-24:00) -1SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_18 + 2 * stdev_6h_18 : na, '6H (18:00-24:00) +2SD', col_6h, 1, plot.style_linebr, offset = offset_val)
plot(enable_6h and sd_6h ? vwap_6h_18 - 2 * stdev_6h_18 : na, '6H (18:00-24:00) -2SD', col_6h, 1, plot.style_linebr, offset = offset_val)

// =============================================================================
// --- DYNAMIC CANDLE COLORING ---
// =============================================================================
candleGroup = "Candle Shading Settings"
colorMode   = input.string("AVWAP Zones", 
              options = ["Off", "AVWAP Zones"], 
              group = candleGroup)

active_6h_vwap  = s_6h_00 ? vwap_6h_00 : (s_6h_06 ? vwap_6h_06 : (s_6h_12 ? vwap_6h_12 : (s_6h_18 ? vwap_6h_18 : na)))
active_6h_stdev = s_6h_00 ? stdev_6h_00 : (s_6h_06 ? stdev_6h_06 : (s_6h_12 ? stdev_6h_12 : (s_6h_18 ? stdev_6h_18 : na)))

// Colors for Option 2 (6H VWAP SD Zones)
color c2_green_light = color.rgb(129, 199, 132) // Between VWAP and +1SD
color c2_green_med   = color.rgb(67, 160, 72)  // Between +1SD and +2SD
color c2_green_dark  = color.rgb(17, 104, 21)    // Beyond +2SD

color c2_red_light   = color.rgb(229, 115, 115) // Between VWAP and -1SD
color c2_red_med     = color.rgb(209, 65, 62)   // Between -1SD and -2SD
color c2_red_dark    = color.rgb(156, 16, 16)   // Beyond -2SD

color dynamicBarColor = na

if colorMode == "AVWAP Zones" and not na(active_6h_vwap) and not na(active_6h_stdev)
    float sd1_upper = active_6h_vwap + active_6h_stdev
    float sd2_upper = active_6h_vwap + 2 * active_6h_stdev
    float sd1_lower = active_6h_vwap - active_6h_stdev
    float sd2_lower = active_6h_vwap - 2 * active_6h_stdev

    if close >= active_6h_vwap
        if close > sd2_upper
            dynamicBarColor := c2_green_dark
        else if close > sd1_upper
            dynamicBarColor := c2_green_med
        else
            dynamicBarColor := c2_green_light
    else
        if close < sd2_lower
            dynamicBarColor := c2_red_dark
        else if close < sd1_lower
            dynamicBarColor := c2_red_med
        else
            dynamicBarColor := c2_red_light

barcolor(dynamicBarColor)


// =============================================================================
// --- UNIFIED DASHBOARD TABLE WITH SD DISTANCE METRIC ---
// =============================================================================

// --- INPUTS & CONFIGURATION ---
grpToggle    = "Dashboard Settings"
showQQQ      = input.bool(true, "QQQ", inline = 'dash', group = grpToggle)
showSPY      = input.bool(false, "SPY", inline = 'dash', group = grpToggle)
showDIA      = input.bool(false, "DIA", inline = 'dash', group = grpToggle)

sd_caution_threshold = input.float(18.0, "Regime Level 1", inline = 'dashsd', group = grpToggle)
sd_clear_threshold   = input.float(30.0, "level 2", inline = 'dashsd', group = grpToggle)

// --- TICKERS & DATA REQUESTS ---
t_qqq = ticker.new("NASDAQ", "QQQ", session.extended)
t_spy = ticker.new("AMEX", "SPY", session.extended)
t_dia = ticker.new("AMEX", "DIA", session.extended)

assetPriceQQQ = request.security(t_qqq, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceSPY = request.security(t_spy, timeframe.period, close, ignore_invalid_symbol = true)
assetPriceDIA = request.security(t_dia, timeframe.period, close, ignore_invalid_symbol = true)

// --- SD STEP DISTANCE & REGIME CALCULATIONS ---
// Uses active_6h_stdev calculated in your script above
float sd_distance = active_6h_stdev

color sd_cell_color   = color.gray
string sd_status_text = "N/A"

if na(sd_distance)
    sd_cell_color   := color.gray
    sd_status_text  := "WAITING"
else if sd_distance < sd_caution_threshold
    sd_cell_color   := color.new(#FF5252, 20)  // Red: Too Small To Trade
    sd_status_text  := "NO TRADE"
else if sd_distance < sd_clear_threshold
    sd_cell_color   := color.new(#FFEB3B, 20)  // Yellow: Cautious / Range
    sd_status_text  := "CAUTION"
else
    sd_cell_color   := color.new(#4CAF50, 20)  // Green: All Clear
    sd_status_text  := "ALL CLEAR"

string sd_display_val = na(sd_distance) ? "N/A" : str.format("{0,number,#.#} pts | {1}", sd_distance, sd_status_text)

// --- TABLE INITIALIZATION (6 ROWS FOR EXPANDED DASHBOARD) ---
var table dashboard = table.new(position = position.bottom_right, columns = 2, rows = 6, border_width = 0)

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 5)

    // ROW 0: SD Distance & Regime State
    table.cell(dashboard, 0, 0, "state", bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 0, sd_display_val, bgcolor = sd_cell_color, text_color = (sd_cell_color == color.new(#FFEB3B, 20) ? color.black : color.white), text_size = size.small)

    // ROW 1: Visual Divider Header
    table.cell(dashboard, 0, 1, "Index", bgcolor = color.rgb(20, 20, 20), text_color = color.gray, text_size = size.tiny)
    table.cell(dashboard, 1, 1, "Price", bgcolor = color.rgb(20, 20, 20), text_color = color.gray, text_size = size.tiny)

    // ROWS 2+: Dynamic Index Tickers
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
// --- SD DISTANCE FIRST-TOUCH DIAMOND MARKERS ---
// =============================================================================

show_sd_diamonds = input.bool(true, "Regime Markers", inline = 'diamond', group = grpToggle)

// --- LINKED CONDITIONS (Uses thresholds from Dashboard Inputs) ---
bool sd_space_18 = show_sd_diamonds and not na(active_6h_stdev) and (active_6h_stdev >= sd_caution_threshold)
bool sd_space_30 = show_sd_diamonds and not na(active_6h_stdev) and (active_6h_stdev >= sd_clear_threshold)

// --- FIRST-TOUCH FILTER (Only triggers on the first candle of threshold breach) ---
bool is_first_18 = sd_space_18 and not sd_space_18[1]
bool is_first_30 = sd_space_30 and not sd_space_30[1]

// --- PLOTS (Navy Blue Diamonds linked to Dashboard inputs) ---
plotshape(
     is_first_18, 
     title          = "First 18pt SD Space Diamond", 
     style          = shape.diamond, 
     location       = location.abovebar, 
     color          = #000080,  // Navy Blue
     size           = size.tiny,
     offset         = 0
     )

plotshape(
     is_first_30, 
     title          = "First 30pt SD Space Diamond", 
     style          = shape.diamond, 
     location       = location.abovebar, 
     color          = #000080,  // Navy Blue
     size           = size.small,
     offset         = 0
     )


// =============================================================================
// --- SD DIAMOND ALERT CONDITIONS (WITH DYNAMIC TICKER TAGS) ---
// =============================================================================

// String tag for active ticker
string asset_tag = syminfo.ticker

// --- ALERT CONDITION DEFINITIONS (Static UI Alerts) ---
alertcondition(is_first_18, title = "SD Diamond: 18pt Breach", message = "18 pt spread {{ticker}}")
alertcondition(is_first_30, title = "SD Diamond: 30pt Breach", message = "30 pt spread {{ticker}}")
alertcondition(is_first_18 or is_first_30, title = "SD Diamond: Any Breach", message = "1SD Volatility Expansion Detected on {{ticker}}! (First Touch)")

// --- DYNAMIC RUNTIME ALERTS (Pings direct to Mobile App / Desktop) ---
if is_first_30
    alert("[" + asset_tag + "] 30pt 1SD Expansion Detected! Target: +60 pts | Regime: High Volatility", alert.freq_once_per_bar_close)
else if is_first_18
    alert("[" + asset_tag + "] 18pt 1SD Expansion Detected! Target: +40 pts | Regime: Standard Volatility", alert.freq_once_per_bar_close)
````
