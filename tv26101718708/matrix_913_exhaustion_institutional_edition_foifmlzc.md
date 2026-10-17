# Matrix 9-13 Exhaustion [Institutional Edition]

- url: https://www.tradingview.com/script/FoIFmLzc/
- type: indicator
- pine_id: PUB;b991f7c395be46a4b3bfb3d9401bd52f
- version: 1.0

## Description

Matrix 9-13 Exhaustion Terminal is a sequential market analysis tool designed to help users monitor extended directional movement and possible momentum fatigue phases.

The script is inspired by count-based exhaustion concepts that track persistent bullish or bearish pressure over multiple bars.

Its purpose is to highlight areas where a trend may be becoming stretched, slowing down, or entering a potential reaction phase.

Rather than predicting reversals, the tool provides a structured framework for observing trend maturity and possible exhaustion conditions.

Designed for multi-market use, it can be applied across different timeframes depending on user preference.

This tool may help users with:

Monitoring prolonged trend movement
Detecting possible momentum fatigue zones
Identifying stretched market phases
Supporting pullback or reversal watchlists
Adding confluence to existing systems
Organizing sequential trend behavior visually

Suitable for:

Reversal traders
Swing traders
Momentum traders
Trend maturity analysts
Multi-indicator traders
Users studying exhaustion logic

If structured trend analysis and momentum-cycle tools are part of your workflow, you may also find additional research tools on this profile useful.

## Source Code

````pine
//@version=5
indicator("Matrix Order Block Institutional Engine — GÖKTUĞ ÖZIŞIK | Matrix Trading Lab", shorttitle="Matrix OBIE | GÖKTUĞ", overlay=true, max_boxes_count=300, max_labels_count=300, max_lines_count=300)

//══════════════════════════════════════════════════════════════════════════════
// MATRIX TRADING LAB
// DEVELOPED BY GÖKTUĞ ÖZIŞIK
//══════════════════════════════════════════════════════════════════════════════

//──────────────────────────────────────────────────────────────────────────────
// CONSTANTS
//──────────────────────────────────────────────────────────────────────────────
BULL = 1
BEAR = -1
NEUTRAL = 0

PRESET_MANUAL   = "Manual"
PRESET_SCALP    = "Scalp"
PRESET_INTRADAY = "Intraday"
PRESET_SWING    = "Swing"
PRESET_CLEAN    = "Clean Chart"

THEME_COLORED = "Colored"
THEME_MONO    = "Monochrome"

SOURCE_FULL = "Full Candle"
SOURCE_BODY = "Body Only"

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupCore   = "1. Core Settings"
groupStruct = "2. Structure Engine"
groupOB     = "3. Order Block Engine"
groupVisual = "4. Visuals"
groupDash   = "5. Dashboard"
groupAlert  = "6. Alerts"

presetInput = input.string(PRESET_INTRADAY, "Preset", options=[PRESET_MANUAL, PRESET_SCALP, PRESET_INTRADAY, PRESET_SWING, PRESET_CLEAN], group=groupCore)
themeInput  = input.string(THEME_COLORED, "Theme", options=[THEME_COLORED, THEME_MONO], group=groupCore)
colorBars   = input.bool(false, "Color Candles By Internal Bias", group=groupCore)

manualSwingLen     = input.int(20, "Swing Length", minval=5, maxval=100, group=groupStruct)
manualInternalLen  = input.int(5, "Internal Length", minval=2, maxval=20, group=groupStruct)
showSwingBlocks    = input.bool(true, "Show Swing Order Blocks", group=groupStruct)
showInternalBlocks = input.bool(true, "Show Internal Order Blocks", group=groupStruct)

obSourceLookback   = input.int(12, "Source Candle Lookback", minval=2, maxval=50, group=groupOB)
sourceModeInput    = input.string(SOURCE_FULL, "Block Source", options=[SOURCE_FULL, SOURCE_BODY], group=groupOB)
minDisplacementATR = input.float(0.20, "Minimum Break Displacement (ATR)", step=0.05, minval=0.0, maxval=5.0, group=groupOB)
maxSwingBlocks     = input.int(3, "Max Swing Blocks", minval=1, maxval=10, group=groupOB)
maxInternalBlocks  = input.int(4, "Max Internal Blocks", minval=1, maxval=10, group=groupOB)
showMitigated      = input.bool(true, "Keep Mitigated Blocks Visible", group=groupOB)
mitigatedOpacity   = input.int(90, "Mitigated Opacity", minval=60, maxval=100, group=groupOB)

showLabels         = input.bool(true, "Show Block Labels", group=groupVisual)
showTouchedState   = input.bool(true, "Fade Touched Blocks", group=groupVisual)

showDashboard      = input.bool(true, "Show Dashboard", group=groupDash)
dashboardPos       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)

enableCreationAlerts   = input.bool(true, "Enable Creation Alerts", group=groupAlert)
enableTouchAlerts      = input.bool(true, "Enable Touch Alerts", group=groupAlert)
enableMitigationAlerts = input.bool(true, "Enable Mitigation Alerts", group=groupAlert)

//──────────────────────────────────────────────────────────────────────────────
// COLORS
//──────────────────────────────────────────────────────────────────────────────
green    = #10b981
red      = #ef4444
gray     = #9ca3af
monoBull = #c7cad1
monoBear = #6b7280

bullColor    = themeInput == THEME_MONO ? monoBull : green
bearColor    = themeInput == THEME_MONO ? monoBear : red
neutralColor = gray
panelBg      = color.new(color.black, 12)

swingBullBg    = themeInput == THEME_MONO ? color.new(monoBull, 82) : color.new(#22c55e, 82)
swingBearBg    = themeInput == THEME_MONO ? color.new(monoBear, 82) : color.new(#ef4444, 82)
internalBullBg = themeInput == THEME_MONO ? color.new(monoBull, 88) : color.new(#34d399, 88)
internalBearBg = themeInput == THEME_MONO ? color.new(monoBear, 88) : color.new(#f87171, 88)

//──────────────────────────────────────────────────────────────────────────────
// PRESETS
//──────────────────────────────────────────────────────────────────────────────
swingLen = presetInput == PRESET_MANUAL ? manualSwingLen : presetInput == PRESET_SCALP ? 10 : presetInput == PRESET_INTRADAY ? 20 : presetInput == PRESET_SWING ? 40 : 18
internalLen = presetInput == PRESET_MANUAL ? manualInternalLen : presetInput == PRESET_SCALP ? 3 : presetInput == PRESET_INTRADAY ? 5 : presetInput == PRESET_SWING ? 8 : 4

showSwPreset = presetInput == PRESET_CLEAN ? true : showSwingBlocks
showInPreset = presetInput == PRESET_CLEAN ? false : showInternalBlocks

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_dash_pos(_pos) =>
    _pos == "Top Left" ? position.top_left : _pos == "Bottom Right" ? position.bottom_right : _pos == "Bottom Left" ? position.bottom_left : position.top_right

f_bias_text(_bias) =>
    _bias == BULL ? "Bullish" : _bias == BEAR ? "Bearish" : "Neutral"

f_bias_color(_bias) =>
    _bias == BULL ? bullColor : _bias == BEAR ? bearColor : neutralColor

f_find_last_bearish_candle(_lookback) =>
    int found = na
    for i = 1 to _lookback
        if close[i] < open[i]
            found := i
            break
    found

f_find_last_bullish_candle(_lookback) =>
    int found = na
    for i = 1 to _lookback
        if close[i] > open[i]
            found := i
            break
    found

f_block_top(_idx) =>
    sourceModeInput == SOURCE_BODY ? math.max(open[_idx], close[_idx]) : high[_idx]

f_block_bottom(_idx) =>
    sourceModeInput == SOURCE_BODY ? math.min(open[_idx], close[_idx]) : low[_idx]

f_create_label(_x, _y, _txt, _txtColor, _style) =>
    label.new(_x, _y, _txt, xloc=xloc.bar_index, style=_style, textcolor=_txtColor, color=color.new(color.black, 100), size=size.tiny)

f_add_bull_block(_left, _top, _bottom, _isSwing) =>
    color boxColor = _isSwing ? swingBullBg : internalBullBg
    color borderCol = color.new(bullColor, 15)
    box b = box.new(_left, _top, bar_index + 1, _bottom, xloc=xloc.bar_index, bgcolor=boxColor, border_color=borderCol)
    label l = na
    if showLabels
        l := f_create_label(_left, _top, _isSwing ? "sOB+" : "iOB+", bullColor, label.style_label_down)
    [b, l]

f_add_bear_block(_left, _top, _bottom, _isSwing) =>
    color boxColor = _isSwing ? swingBearBg : internalBearBg
    color borderCol = color.new(bearColor, 15)
    box b = box.new(_left, _top, bar_index + 1, _bottom, xloc=xloc.bar_index, bgcolor=boxColor, border_color=borderCol)
    label l = na
    if showLabels
        l := f_create_label(_left, _bottom, _isSwing ? "sOB-" : "iOB-", bearColor, label.style_label_up)
    [b, l]

//──────────────────────────────────────────────────────────────────────────────
// CORE DATA
//──────────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)

swingPH = ta.pivothigh(high, swingLen, swingLen)
swingPL = ta.pivotlow(low, swingLen, swingLen)
internalPH = ta.pivothigh(high, internalLen, internalLen)
internalPL = ta.pivotlow(low, internalLen, internalLen)

//──────────────────────────────────────────────────────────────────────────────
// STRUCTURE STATE
//──────────────────────────────────────────────────────────────────────────────
var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na
var bool swingHighCrossed = false
var bool swingLowCrossed = false
var int swingBias = NEUTRAL

var float internalHigh = na
var float internalLow = na
var int internalHighBar = na
var int internalLowBar = na
var bool internalHighCrossed = false
var bool internalLowCrossed = false
var int internalBias = NEUTRAL

if not na(swingPH)
    swingHigh := swingPH
    swingHighBar := bar_index - swingLen
    swingHighCrossed := false

if not na(swingPL)
    swingLow := swingPL
    swingLowBar := bar_index - swingLen
    swingLowCrossed := false

if not na(internalPH)
    internalHigh := internalPH
    internalHighBar := bar_index - internalLen
    internalHighCrossed := false

if not na(internalPL)
    internalLow := internalPL
    internalLowBar := bar_index - internalLen
    internalLowCrossed := false

bullBreakSwing = not na(swingHigh) and not swingHighCrossed and close > swingHigh and close[1] <= swingHigh and (close - swingHigh) >= atr * minDisplacementATR
bearBreakSwing = not na(swingLow) and not swingLowCrossed and close < swingLow and close[1] >= swingLow and (swingLow - close) >= atr * minDisplacementATR
bullBreakInternal = not na(internalHigh) and not internalHighCrossed and close > internalHigh and close[1] <= internalHigh and (close - internalHigh) >= atr * minDisplacementATR
bearBreakInternal = not na(internalLow) and not internalLowCrossed and close < internalLow and close[1] >= internalLow and (internalLow - close) >= atr * minDisplacementATR

if bullBreakSwing
    swingHighCrossed := true
    swingBias := BULL

if bearBreakSwing
    swingLowCrossed := true
    swingBias := BEAR

if bullBreakInternal
    internalHighCrossed := true
    internalBias := BULL

if bearBreakInternal
    internalLowCrossed := true
    internalBias := BEAR

//──────────────────────────────────────────────────────────────────────────────
// ORDER BLOCK STORAGE
//──────────────────────────────────────────────────────────────────────────────
var array<box> swingBullBoxes = array.new_box()
var array<float> swingBullTops = array.new_float()
var array<float> swingBullBottoms = array.new_float()
var array<int> swingBullState = array.new_int()
var array<label> swingBullLabels = array.new_label()

var array<box> swingBearBoxes = array.new_box()
var array<float> swingBearTops = array.new_float()
var array<float> swingBearBottoms = array.new_float()
var array<int> swingBearState = array.new_int()
var array<label> swingBearLabels = array.new_label()

var array<box> internalBullBoxes = array.new_box()
var array<float> internalBullTops = array.new_float()
var array<float> internalBullBottoms = array.new_float()
var array<int> internalBullState = array.new_int()
var array<label> internalBullLabels = array.new_label()

var array<box> internalBearBoxes = array.new_box()
var array<float> internalBearTops = array.new_float()
var array<float> internalBearBottoms = array.new_float()
var array<int> internalBearState = array.new_int()
var array<label> internalBearLabels = array.new_label()

var string lastEvent = "None"

var bool alertNewSwingBull = false
var bool alertNewSwingBear = false
var bool alertNewInternalBull = false
var bool alertNewInternalBear = false
var bool alertTouchBull = false
var bool alertTouchBear = false
var bool alertMitBull = false
var bool alertMitBear = false

alertNewSwingBull := false
alertNewSwingBear := false
alertNewInternalBull := false
alertNewInternalBear := false
alertTouchBull := false
alertTouchBear := false
alertMitBull := false
alertMitBear := false

//──────────────────────────────────────────────────────────────────────────────
// CREATE BLOCKS
//──────────────────────────────────────────────────────────────────────────────
if bullBreakSwing and showSwPreset
    int srcBullSw = f_find_last_bearish_candle(obSourceLookback)
    if not na(srcBullSw)
        float topBullSw = f_block_top(srcBullSw)
        float botBullSw = f_block_bottom(srcBullSw)
        [newBox, newLabel] = f_add_bull_block(bar_index - srcBullSw, topBullSw, botBullSw, true)
        array.unshift(swingBullBoxes, newBox)
        array.unshift(swingBullTops, topBullSw)
        array.unshift(swingBullBottoms, botBullSw)
        array.unshift(swingBullState, 0)
        array.unshift(swingBullLabels, newLabel)
        if array.size(swingBullBoxes) > maxSwingBlocks
            box oldB = array.pop(swingBullBoxes)
            label oldL = array.pop(swingBullLabels)
            array.pop(swingBullTops)
            array.pop(swingBullBottoms)
            array.pop(swingBullState)
            box.delete(oldB)
            if not na(oldL)
                label.delete(oldL)
        alertNewSwingBull := true
        lastEvent := "New Swing Bullish OB"

if bearBreakSwing and showSwPreset
    int srcBearSw = f_find_last_bullish_candle(obSourceLookback)
    if not na(srcBearSw)
        float topBearSw = f_block_top(srcBearSw)
        float botBearSw = f_block_bottom(srcBearSw)
        [newBox, newLabel] = f_add_bear_block(bar_index - srcBearSw, topBearSw, botBearSw, true)
        array.unshift(swingBearBoxes, newBox)
        array.unshift(swingBearTops, topBearSw)
        array.unshift(swingBearBottoms, botBearSw)
        array.unshift(swingBearState, 0)
        array.unshift(swingBearLabels, newLabel)
        if array.size(swingBearBoxes) > maxSwingBlocks
            box oldB = array.pop(swingBearBoxes)
            label oldL = array.pop(swingBearLabels)
            array.pop(swingBearTops)
            array.pop(swingBearBottoms)
            array.pop(swingBearState)
            box.delete(oldB)
            if not na(oldL)
                label.delete(oldL)
        alertNewSwingBear := true
        lastEvent := "New Swing Bearish OB"

if bullBreakInternal and showInPreset
    int srcBullIn = f_find_last_bearish_candle(obSourceLookback)
    if not na(srcBullIn)
        float topBullIn = f_block_top(srcBullIn)
        float botBullIn = f_block_bottom(srcBullIn)
        [newBox, newLabel] = f_add_bull_block(bar_index - srcBullIn, topBullIn, botBullIn, false)
        array.unshift(internalBullBoxes, newBox)
        array.unshift(internalBullTops, topBullIn)
        array.unshift(internalBullBottoms, botBullIn)
        array.unshift(internalBullState, 0)
        array.unshift(internalBullLabels, newLabel)
        if array.size(internalBullBoxes) > maxInternalBlocks
            box oldB = array.pop(internalBullBoxes)
            label oldL = array.pop(internalBullLabels)
            array.pop(internalBullTops)
            array.pop(internalBullBottoms)
            array.pop(internalBullState)
            box.delete(oldB)
            if not na(oldL)
                label.delete(oldL)
        alertNewInternalBull := true
        lastEvent := "New Internal Bullish OB"

if bearBreakInternal and showInPreset
    int srcBearIn = f_find_last_bullish_candle(obSourceLookback)
    if not na(srcBearIn)
        float topBearIn = f_block_top(srcBearIn)
        float botBearIn = f_block_bottom(srcBearIn)
        [newBox, newLabel] = f_add_bear_block(bar_index - srcBearIn, topBearIn, botBearIn, false)
        array.unshift(internalBearBoxes, newBox)
        array.unshift(internalBearTops, topBearIn)
        array.unshift(internalBearBottoms, botBearIn)
        array.unshift(internalBearState, 0)
        array.unshift(internalBearLabels, newLabel)
        if array.size(internalBearBoxes) > maxInternalBlocks
            box oldB = array.pop(internalBearBoxes)
            label oldL = array.pop(internalBearLabels)
            array.pop(internalBearTops)
            array.pop(internalBearBottoms)
            array.pop(internalBearState)
            box.delete(oldB)
            if not na(oldL)
                label.delete(oldL)
        alertNewInternalBear := true
        lastEvent := "New Internal Bearish OB"

//──────────────────────────────────────────────────────────────────────────────
// UPDATE BLOCK STATES
//──────────────────────────────────────────────────────────────────────────────

// Swing Bullish
int sbSize = array.size(swingBullBoxes)
if sbSize > 0
    for i = sbSize - 1 to 0
        box b = array.get(swingBullBoxes, i)
        float top = array.get(swingBullTops, i)
        float bottom = array.get(swingBullBottoms, i)
        int st = array.get(swingBullState, i)
        label lb = array.get(swingBullLabels, i)

        box.set_right(b, bar_index + 1)

        bool touched = low <= top and high >= bottom
        bool mitigated = close < bottom

        if st == 0 and touched
            array.set(swingBullState, i, 1)
            if showTouchedState
                box.set_bgcolor(b, color.new(bullColor, 90))
            if not na(lb)
                label.set_text(lb, "sOB T")
            alertTouchBull := true
            lastEvent := "Swing Bullish OB Touched"

        if (st == 0 or st == 1) and mitigated
            if showMitigated
                array.set(swingBullState, i, 2)
                box.set_bgcolor(b, color.new(bullColor, mitigatedOpacity))
                box.set_border_color(b, color.new(bullColor, 85))
                if not na(lb)
                    label.set_text(lb, "sOB M")
            else
                box.delete(b)
                if not na(lb)
                    label.delete(lb)
                array.remove(swingBullBoxes, i)
                array.remove(swingBullTops, i)
                array.remove(swingBullBottoms, i)
                array.remove(swingBullState, i)
                array.remove(swingBullLabels, i)
            alertMitBull := true
            lastEvent := "Swing Bullish OB Mitigated"

// Internal Bullish
int ibSize = array.size(internalBullBoxes)
if ibSize > 0
    for i = ibSize - 1 to 0
        box b = array.get(internalBullBoxes, i)
        float top = array.get(internalBullTops, i)
        float bottom = array.get(internalBullBottoms, i)
        int st = array.get(internalBullState, i)
        label lb = array.get(internalBullLabels, i)

        box.set_right(b, bar_index + 1)

        bool touched = low <= top and high >= bottom
        bool mitigated = close < bottom

        if st == 0 and touched
            array.set(internalBullState, i, 1)
            if showTouchedState
                box.set_bgcolor(b, color.new(bullColor, 90))
            if not na(lb)
                label.set_text(lb, "iOB T")
            alertTouchBull := true
            lastEvent := "Internal Bullish OB Touched"

        if (st == 0 or st == 1) and mitigated
            if showMitigated
                array.set(internalBullState, i, 2)
                box.set_bgcolor(b, color.new(bullColor, mitigatedOpacity))
                box.set_border_color(b, color.new(bullColor, 85))
                if not na(lb)
                    label.set_text(lb, "iOB M")
            else
                box.delete(b)
                if not na(lb)
                    label.delete(lb)
                array.remove(internalBullBoxes, i)
                array.remove(internalBullTops, i)
                array.remove(internalBullBottoms, i)
                array.remove(internalBullState, i)
                array.remove(internalBullLabels, i)
            alertMitBull := true
            lastEvent := "Internal Bullish OB Mitigated"

// Swing Bearish
int sbrSize = array.size(swingBearBoxes)
if sbrSize > 0
    for i = sbrSize - 1 to 0
        box b = array.get(swingBearBoxes, i)
        float top = array.get(swingBearTops, i)
        float bottom = array.get(swingBearBottoms, i)
        int st = array.get(swingBearState, i)
        label lb = array.get(swingBearLabels, i)

        box.set_right(b, bar_index + 1)

        bool touched = high >= bottom and low <= top
        bool mitigated = close > top

        if st == 0 and touched
            array.set(swingBearState, i, 1)
            if showTouchedState
                box.set_bgcolor(b, color.new(bearColor, 90))
            if not na(lb)
                label.set_text(lb, "sOB T")
            alertTouchBear := true
            lastEvent := "Swing Bearish OB Touched"

        if (st == 0 or st == 1) and mitigated
            if showMitigated
                array.set(swingBearState, i, 2)
                box.set_bgcolor(b, color.new(bearColor, mitigatedOpacity))
                box.set_border_color(b, color.new(bearColor, 85))
                if not na(lb)
                    label.set_text(lb, "sOB M")
            else
                box.delete(b)
                if not na(lb)
                    label.delete(lb)
                array.remove(swingBearBoxes, i)
                array.remove(swingBearTops, i)
                array.remove(swingBearBottoms, i)
                array.remove(swingBearState, i)
                array.remove(swingBearLabels, i)
            alertMitBear := true
            lastEvent := "Swing Bearish OB Mitigated"

// Internal Bearish
int ibrSize = array.size(internalBearBoxes)
if ibrSize > 0
    for i = ibrSize - 1 to 0
        box b = array.get(internalBearBoxes, i)
        float top = array.get(internalBearTops, i)
        float bottom = array.get(internalBearBottoms, i)
        int st = array.get(internalBearState, i)
        label lb = array.get(internalBearLabels, i)

        box.set_right(b, bar_index + 1)

        bool touched = high >= bottom and low <= top
        bool mitigated = close > top

        if st == 0 and touched
            array.set(internalBearState, i, 1)
            if showTouchedState
                box.set_bgcolor(b, color.new(bearColor, 90))
            if not na(lb)
                label.set_text(lb, "iOB T")
            alertTouchBear := true
            lastEvent := "Internal Bearish OB Touched"

        if (st == 0 or st == 1) and mitigated
            if showMitigated
                array.set(internalBearState, i, 2)
                box.set_bgcolor(b, color.new(bearColor, mitigatedOpacity))
                box.set_border_color(b, color.new(bearColor, 85))
                if not na(lb)
                    label.set_text(lb, "iOB M")
            else
                box.delete(b)
                if not na(lb)
                    label.delete(lb)
                array.remove(internalBearBoxes, i)
                array.remove(internalBearTops, i)
                array.remove(internalBearBottoms, i)
                array.remove(internalBearState, i)
                array.remove(internalBearLabels, i)
            alertMitBear := true
            lastEvent := "Internal Bearish OB Mitigated"

//──────────────────────────────────────────────────────────────────────────────
// LAST BLOCK INFO
//──────────────────────────────────────────────────────────────────────────────
float lastSwingBull = array.size(swingBullTops) > 0 ? array.get(swingBullTops, 0) : na
float lastSwingBear = array.size(swingBearTops) > 0 ? array.get(swingBearTops, 0) : na

int activeBullCount = array.size(swingBullBoxes) + array.size(internalBullBoxes)
int activeBearCount = array.size(swingBearBoxes) + array.size(internalBearBoxes)

string priceContext = activeBullCount > activeBearCount ? "Bullish OB Dominance" : activeBearCount > activeBullCount ? "Bearish OB Dominance" : "Balanced"

//──────────────────────────────────────────────────────────────────────────────
// CANDLE COLORING
//──────────────────────────────────────────────────────────────────────────────
barCol = internalBias == BULL ? bullColor : internalBias == BEAR ? bearColor : na
plotcandle(colorBars ? open : na, high, low, close, color=barCol, wickcolor=barCol, bordercolor=barCol)

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast
    table.set_position(dash, f_dash_pos(dashboardPos))

    if showDashboard
        table.cell(dash, 0, 0, "Matrix Trading Lab", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "OB Engine", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Swing Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 1, f_bias_text(swingBias), text_color=f_bias_color(swingBias), bgcolor=panelBg)

        table.cell(dash, 0, 2, "Internal Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 2, f_bias_text(internalBias), text_color=f_bias_color(internalBias), bgcolor=panelBg)

        table.cell(dash, 0, 3, "Bullish Blocks", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 3, str.tostring(activeBullCount), text_color=bullColor, bgcolor=panelBg)

        table.cell(dash, 0, 4, "Bearish Blocks", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 4, str.tostring(activeBearCount), text_color=bearColor, bgcolor=panelBg)

        table.cell(dash, 0, 5, "Last Swing Bull", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 5, na(lastSwingBull) ? "N/A" : str.tostring(lastSwingBull, format.mintick), text_color=bullColor, bgcolor=panelBg)

        table.cell(dash, 0, 6, "Last Swing Bear", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 6, na(lastSwingBear) ? "N/A" : str.tostring(lastSwingBear, format.mintick), text_color=bearColor, bgcolor=panelBg)

        table.cell(dash, 0, 7, "Last Event", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 7, lastEvent, text_color=color.white, bgcolor=panelBg)

        table.cell(dash, 0, 8, "Context", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 8, priceContext, text_color=activeBullCount > activeBearCount ? bullColor : activeBearCount > activeBullCount ? bearColor : neutralColor, bgcolor=panelBg)
    else
        for r = 0 to 8
            table.cell(dash, 0, r, "", bgcolor=color.new(color.black, 100))
            table.cell(dash, 1, r, "", bgcolor=color.new(color.black, 100))

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(enableCreationAlerts and alertNewSwingBull, "New Swing Bullish OB", "Matrix OB Engine: New Swing Bullish Order Block")
alertcondition(enableCreationAlerts and alertNewSwingBear, "New Swing Bearish OB", "Matrix OB Engine: New Swing Bearish Order Block")
alertcondition(enableCreationAlerts and alertNewInternalBull, "New Internal Bullish OB", "Matrix OB Engine: New Internal Bullish Order Block")
alertcondition(enableCreationAlerts and alertNewInternalBear, "New Internal Bearish OB", "Matrix OB Engine: New Internal Bearish Order Block")

alertcondition(enableTouchAlerts and alertTouchBull, "Bullish OB Touched", "Matrix OB Engine: Bullish Order Block Touched")
alertcondition(enableTouchAlerts and alertTouchBear, "Bearish OB Touched", "Matrix OB Engine: Bearish Order Block Touched")

alertcondition(enableMitigationAlerts and alertMitBull, "Bullish OB Mitigated", "Matrix OB Engine: Bullish Order Block Mitigated")
alertcondition(enableMitigationAlerts and alertMitBear, "Bearish OB Mitigated", "Matrix OB Engine: Bearish Order Block Mitigated")
````
