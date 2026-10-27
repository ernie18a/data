# Matrix Market Structure [Institutional Edition]

- url: https://www.tradingview.com/script/8DISahMz/
- type: indicator
- pine_id: PUB;6b707813db214381a267870806c75960
- version: 1.0

## Description

Matrix Market Structure Institutional is a price action analysis tool designed to help users interpret market direction through objective structural behavior.

The script focuses on swing highs, swing lows, break of structure events, and continuation patterns to organize chart movement into a cleaner decision framework.

Instead of relying only on lagging indicators, this tool helps traders observe how price is building, breaking, or transitioning structure over time.

It is intended for users who study trend behavior, directional bias, and structural shifts across multiple markets and timeframes.

Designed with clarity and usability in mind, the script aims to simplify market structure reading without overloading the chart.

This tool may help users with:

Identifying bullish or bearish structure bias
Detecting break of structure (BOS) zones
Reading swing high / swing low formations
Following continuation vs reversal behavior
Supporting trend analysis decisions
Organizing raw price action visually

Suitable for:

Price action traders
Smart money concept users
Swing traders
Intraday traders
Trend traders
Traders seeking cleaner market context

If structure-based chart analysis is part of your trading process, you may also find additional research tools available on this profile worth exploring.

## Source Code

````pine
//@version=5
indicator("Matrix Market Structure Institutional Dashboard — GÖKTUĞ ÖZIŞIK | Matrix Trading Lab", shorttitle="Matrix MSID | GÖKTUĞ", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//══════════════════════════════════════════════════════════════════════════════
// DEVELOPED BY GÖKTUĞ ÖZIŞIK
// MATRIX TRADING LAB
//══════════════════════════════════════════════════════════════════════════════

//══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
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

//══════════════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════════════
groupCore   = "1. Core Settings"
groupStruct = "2. Structure"
groupZones  = "3. Zones"
groupLevels = "4. MTF Levels"
groupDash   = "5. Dashboard"
groupStyle  = "6. Style"
groupAlerts = "7. Alerts"

presetInput = input.string(PRESET_INTRADAY, "Preset", options=[PRESET_MANUAL, PRESET_SCALP, PRESET_INTRADAY, PRESET_SWING, PRESET_CLEAN], group=groupCore)
themeInput  = input.string(THEME_COLORED, "Theme", options=[THEME_COLORED, THEME_MONO], group=groupCore)
colorBars   = input.bool(false, "Color Candles By Internal Bias", group=groupCore)

manualSwingLen    = input.int(20, "Swing Structure Length", minval=5, maxval=100, group=groupStruct)
manualInternalLen = input.int(5, "Internal Structure Length", minval=2, maxval=20, group=groupStruct)
showSwingStructure    = input.bool(true, "Show Swing Structure", group=groupStruct)
showInternalStructure = input.bool(true, "Show Internal Structure", group=groupStruct)
showSwingPoints       = input.bool(false, "Show Swing Points", group=groupStruct)
showEqhEql            = input.bool(true, "Show Equal High / Low", group=groupStruct)
eqThresholdAtr        = input.float(0.10, "EQH / EQL Threshold (ATR Multiplier)", step=0.01, minval=0.01, maxval=1.00, group=groupStruct)

showOrderBlocks      = input.bool(true, "Show Latest Order Blocks", group=groupZones)
obLookback           = input.int(8, "Order Block Source Lookback", minval=2, maxval=30, group=groupZones)
showFVG              = input.bool(true, "Show Latest Fair Value Gaps", group=groupZones)
fvgAtrFilter         = input.float(0.10, "FVG Minimum Size (ATR Multiplier)", step=0.01, minval=0.0, maxval=3.0, group=groupZones)
showPremiumDiscount  = input.bool(true, "Show Premium / Discount Zones", group=groupZones)

showDailyLevels      = input.bool(true, "Previous Day High / Low", group=groupLevels)
showWeeklyLevels     = input.bool(false, "Previous Week High / Low", group=groupLevels)
showMonthlyLevels    = input.bool(false, "Previous Month High / Low", group=groupLevels)

showDashboard        = input.bool(true, "Show Dashboard", group=groupDash)
dashboardPos         = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)

enableStructureAlerts = input.bool(true, "Enable Structure Alerts", group=groupAlerts)
enableZoneAlerts      = input.bool(true, "Enable Zone Alerts", group=groupAlerts)

//══════════════════════════════════════════════════════════════════════════════
// COLORS
//══════════════════════════════════════════════════════════════════════════════
green    = #10b981
red      = #ef4444
blue     = #3b82f6
orange   = #f59e0b
gray     = #9ca3af
monoBull = #c7cad1
monoBear = #6b7280

bullColor       = themeInput == THEME_MONO ? monoBull : green
bearColor       = themeInput == THEME_MONO ? monoBear : red
neutralColor    = gray
obBullColor     = themeInput == THEME_MONO ? color.new(monoBull, 82) : color.new(#22c55e, 82)
obBearColor     = themeInput == THEME_MONO ? color.new(monoBear, 82) : color.new(#ef4444, 82)
fvgBullColor    = themeInput == THEME_MONO ? color.new(monoBull, 84) : color.new(#14b8a6, 84)
fvgBearColor    = themeInput == THEME_MONO ? color.new(monoBear, 84) : color.new(#f97316, 84)
premiumColor    = themeInput == THEME_MONO ? monoBear : red
discountColor   = themeInput == THEME_MONO ? monoBull : green
equilibriumColor= gray
panelBg         = color.new(color.black, 15)

//══════════════════════════════════════════════════════════════════════════════
// PRESETS
//══════════════════════════════════════════════════════════════════════════════
swingLen = presetInput == PRESET_MANUAL   ? manualSwingLen :
           presetInput == PRESET_SCALP    ? 10 :
           presetInput == PRESET_INTRADAY ? 20 :
           presetInput == PRESET_SWING    ? 40 : 18

internalLen = presetInput == PRESET_MANUAL   ? manualInternalLen :
              presetInput == PRESET_SCALP    ? 3 :
              presetInput == PRESET_INTRADAY ? 5 :
              presetInput == PRESET_SWING    ? 8 : 4

showSwPreset  = presetInput == PRESET_CLEAN ? true  : showSwingStructure
showIntPreset = presetInput == PRESET_CLEAN ? true  : showInternalStructure
showEqPreset  = presetInput == PRESET_CLEAN ? false : showEqhEql
showObPreset  = presetInput == PRESET_CLEAN ? true  : showOrderBlocks
showFvgPreset = presetInput == PRESET_CLEAN ? false : showFVG
showPdPreset  = presetInput == PRESET_CLEAN ? false : showPremiumDiscount

//══════════════════════════════════════════════════════════════════════════════
// HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_bias_text(_bias) =>
    _bias == BULL ? "Bullish" : _bias == BEAR ? "Bearish" : "Neutral"

f_bias_color(_bias) =>
    _bias == BULL ? bullColor : _bias == BEAR ? bearColor : neutralColor

f_dash_pos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

f_zone_status(_top, _bottom) =>
    string result = "N/A"
    if not na(_top) and not na(_bottom) and _top > _bottom
        rng = _top - _bottom
        result := close >= _top - rng * 0.25 ? "Premium" : close <= _bottom + rng * 0.25 ? "Discount" : "Equilibrium"
    result

f_zone_color(_txt) =>
    _txt == "Premium" ? premiumColor : _txt == "Discount" ? discountColor : equilibriumColor

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

f_draw_structure(_barIndex, _price, _tag, _col, _lineStyle, _labelStyle, _size) =>
    line.new(_barIndex, _price, bar_index, _price, xloc=xloc.bar_index, color=_col, style=_lineStyle, width=1)
    label.new(math.round((_barIndex + bar_index) * 0.5), _price, _tag, xloc=xloc.bar_index, style=_labelStyle, textcolor=_col, color=color.new(color.black, 100), size=_size)

f_draw_swing_point(_barIndex, _price, _txt, _col, _style) =>
    label.new(_barIndex, _price, _txt, xloc=xloc.bar_index, style=_style, textcolor=_col, color=color.new(color.black, 100), size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
//══════════════════════════════════════════════════════════════════════════════
atr = ta.atr(14)

swingPH = ta.pivothigh(high, swingLen, swingLen)
swingPL = ta.pivotlow(low, swingLen, swingLen)

internalPH = ta.pivothigh(high, internalLen, internalLen)
internalPL = ta.pivotlow(low, internalLen, internalLen)

//══════════════════════════════════════════════════════════════════════════════
// STATE VARIABLES
//══════════════════════════════════════════════════════════════════════════════
var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na
var bool swingHighCrossed = false
var bool swingLowCrossed = false
var int swingBias = NEUTRAL

var float prevSwingHigh = na
var float prevSwingLow = na
var int prevSwingHighBar = na
var int prevSwingLowBar = na

var float internalHigh = na
var float internalLow = na
var int internalHighBar = na
var int internalLowBar = na
var bool internalHighCrossed = false
var bool internalLowCrossed = false
var int internalBias = NEUTRAL

var float trailingTop = na
var float trailingBottom = na
var int trailingTopBar = na
var int trailingBottomBar = na

var box bullObBox = na
var box bearObBox = na
var box bullFvgBox = na
var box bearFvgBox = na

var float latestBullObTop = na
var float latestBullObBottom = na
var float latestBearObTop = na
var float latestBearObBottom = na

var float latestBullFvgTop = na
var float latestBullFvgBottom = na
var float latestBearFvgTop = na
var float latestBearFvgBottom = na

// premium / discount plot values
var float premiumTopPlot = na
var float premiumBottomPlot = na
var float eqTopPlot = na
var float eqBottomPlot = na
var float discountTopPlot = na
var float discountBottomPlot = na

// alerts
var bool alertSwingBullBOS = false
var bool alertSwingBearBOS = false
var bool alertSwingBullCHOCH = false
var bool alertSwingBearCHOCH = false
var bool alertInternalBullBOS = false
var bool alertInternalBearBOS = false
var bool alertInternalBullCHOCH = false
var bool alertInternalBearCHOCH = false
var bool alertBullOB = false
var bool alertBearOB = false
var bool alertBullFVG = false
var bool alertBearFVG = false
var bool alertEQH = false
var bool alertEQL = false

alertSwingBullBOS := false
alertSwingBearBOS := false
alertSwingBullCHOCH := false
alertSwingBearCHOCH := false
alertInternalBullBOS := false
alertInternalBearBOS := false
alertInternalBullCHOCH := false
alertInternalBearCHOCH := false
alertBullOB := false
alertBearOB := false
alertBullFVG := false
alertBearFVG := false
alertEQH := false
alertEQL := false

//══════════════════════════════════════════════════════════════════════════════
// STORE SWING PIVOTS
//══════════════════════════════════════════════════════════════════════════════
if not na(swingPH)
    prevSwingHigh := swingHigh
    prevSwingHighBar := swingHighBar
    swingHigh := swingPH
    swingHighBar := bar_index - swingLen
    swingHighCrossed := false

    if showSwingPoints
        txt = na(prevSwingHigh) ? "SH" : swingHigh > prevSwingHigh ? "HH" : "LH"
        f_draw_swing_point(swingHighBar, swingHigh, txt, bearColor, label.style_label_down)

    if showEqPreset and not na(prevSwingHigh) and math.abs(swingHigh - prevSwingHigh) <= atr * eqThresholdAtr
        line.new(prevSwingHighBar, prevSwingHigh, swingHighBar, swingHigh, xloc=xloc.bar_index, color=bearColor, style=line.style_dotted, width=1)
        label.new(math.round((prevSwingHighBar + swingHighBar) * 0.5), swingHigh, "EQH", xloc=xloc.bar_index, style=label.style_label_down, textcolor=bearColor, color=color.new(color.black, 100), size=size.tiny)
        alertEQH := true

if not na(swingPL)
    prevSwingLow := swingLow
    prevSwingLowBar := swingLowBar
    swingLow := swingPL
    swingLowBar := bar_index - swingLen
    swingLowCrossed := false

    if showSwingPoints
        txt = na(prevSwingLow) ? "SL" : swingLow < prevSwingLow ? "LL" : "HL"
        f_draw_swing_point(swingLowBar, swingLow, txt, bullColor, label.style_label_up)

    if showEqPreset and not na(prevSwingLow) and math.abs(swingLow - prevSwingLow) <= atr * eqThresholdAtr
        line.new(prevSwingLowBar, prevSwingLow, swingLowBar, swingLow, xloc=xloc.bar_index, color=bullColor, style=line.style_dotted, width=1)
        label.new(math.round((prevSwingLowBar + swingLowBar) * 0.5), swingLow, "EQL", xloc=xloc.bar_index, style=label.style_label_up, textcolor=bullColor, color=color.new(color.black, 100), size=size.tiny)
        alertEQL := true

//══════════════════════════════════════════════════════════════════════════════
// STORE INTERNAL PIVOTS
//══════════════════════════════════════════════════════════════════════════════
if not na(internalPH)
    internalHigh := internalPH
    internalHighBar := bar_index - internalLen
    internalHighCrossed := false

if not na(internalPL)
    internalLow := internalPL
    internalLowBar := bar_index - internalLen
    internalLowCrossed := false

//══════════════════════════════════════════════════════════════════════════════
// TRAILING EXTREMES
//══════════════════════════════════════════════════════════════════════════════
if na(trailingTop)
    trailingTop := high
    trailingBottom := low
    trailingTopBar := bar_index
    trailingBottomBar := bar_index

if not na(swingHigh) and (na(trailingTop) or swingHigh >= trailingTop)
    trailingTop := swingHigh
    trailingTopBar := swingHighBar

if not na(swingLow) and (na(trailingBottom) or swingLow <= trailingBottom)
    trailingBottom := swingLow
    trailingBottomBar := swingLowBar

//══════════════════════════════════════════════════════════════════════════════
// STRUCTURE BREAKS
//══════════════════════════════════════════════════════════════════════════════
bullBreakSwing = not na(swingHigh) and not swingHighCrossed and close > swingHigh and close[1] <= swingHigh
bearBreakSwing = not na(swingLow) and not swingLowCrossed and close < swingLow and close[1] >= swingLow

bullBreakInternal = not na(internalHigh) and not internalHighCrossed and close > internalHigh and close[1] <= internalHigh
bearBreakInternal = not na(internalLow) and not internalLowCrossed and close < internalLow and close[1] >= internalLow

if bullBreakSwing
    tag = swingBias == BEAR ? "CHoCH" : "BOS"
    swingHighCrossed := true
    swingBias := BULL
    if showSwPreset
        f_draw_structure(swingHighBar, swingHigh, tag, bullColor, line.style_solid, label.style_label_down, size.small)
    alertSwingBullCHOCH := tag == "CHoCH"
    alertSwingBullBOS   := tag == "BOS"

    if showObPreset
        src = f_find_last_bearish_candle(obLookback)
        if not na(src)
            latestBullObTop := high[src]
            latestBullObBottom := low[src]
            if not na(bullObBox)
                box.delete(bullObBox)
            bullObBox := box.new(bar_index - src, latestBullObTop, bar_index + 1, latestBullObBottom, xloc=xloc.bar_index, border_color=color.new(bullColor, 10), bgcolor=obBullColor)
            alertBullOB := true

if bearBreakSwing
    tag = swingBias == BULL ? "CHoCH" : "BOS"
    swingLowCrossed := true
    swingBias := BEAR
    if showSwPreset
        f_draw_structure(swingLowBar, swingLow, tag, bearColor, line.style_solid, label.style_label_up, size.small)
    alertSwingBearCHOCH := tag == "CHoCH"
    alertSwingBearBOS   := tag == "BOS"

    if showObPreset
        src = f_find_last_bullish_candle(obLookback)
        if not na(src)
            latestBearObTop := high[src]
            latestBearObBottom := low[src]
            if not na(bearObBox)
                box.delete(bearObBox)
            bearObBox := box.new(bar_index - src, latestBearObTop, bar_index + 1, latestBearObBottom, xloc=xloc.bar_index, border_color=color.new(bearColor, 10), bgcolor=obBearColor)
            alertBearOB := true

if bullBreakInternal
    tag = internalBias == BEAR ? "CHoCH" : "BOS"
    internalHighCrossed := true
    internalBias := BULL
    if showIntPreset
        f_draw_structure(internalHighBar, internalHigh, tag, bullColor, line.style_dashed, label.style_label_down, size.tiny)
    alertInternalBullCHOCH := tag == "CHoCH"
    alertInternalBullBOS   := tag == "BOS"

if bearBreakInternal
    tag = internalBias == BULL ? "CHoCH" : "BOS"
    internalLowCrossed := true
    internalBias := BEAR
    if showIntPreset
        f_draw_structure(internalLowBar, internalLow, tag, bearColor, line.style_dashed, label.style_label_up, size.tiny)
    alertInternalBearCHOCH := tag == "CHoCH"
    alertInternalBearBOS   := tag == "BOS"

//══════════════════════════════════════════════════════════════════════════════
// ORDER BLOCK UPDATE
//══════════════════════════════════════════════════════════════════════════════
if not na(bullObBox)
    box.set_right(bullObBox, bar_index + 1)
    if close < latestBullObBottom
        box.delete(bullObBox)
        bullObBox := na
        latestBullObTop := na
        latestBullObBottom := na

if not na(bearObBox)
    box.set_right(bearObBox, bar_index + 1)
    if close > latestBearObTop
        box.delete(bearObBox)
        bearObBox := na
        latestBearObTop := na
        latestBearObBottom := na

//══════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
//══════════════════════════════════════════════════════════════════════════════
bullFvg = showFvgPreset and low > high[2] and (low - high[2]) >= atr * fvgAtrFilter
bearFvg = showFvgPreset and high < low[2] and (low[2] - high) >= atr * fvgAtrFilter

if bullFvg
    latestBullFvgTop := low
    latestBullFvgBottom := high[2]
    if not na(bullFvgBox)
        box.delete(bullFvgBox)
    bullFvgBox := box.new(bar_index - 2, latestBullFvgTop, bar_index + 1, latestBullFvgBottom, xloc=xloc.bar_index, border_color=color.new(bullColor, 0), bgcolor=fvgBullColor)
    alertBullFVG := true

if bearFvg
    latestBearFvgTop := low[2]
    latestBearFvgBottom := high
    if not na(bearFvgBox)
        box.delete(bearFvgBox)
    bearFvgBox := box.new(bar_index - 2, latestBearFvgTop, bar_index + 1, latestBearFvgBottom, xloc=xloc.bar_index, border_color=color.new(bearColor, 0), bgcolor=fvgBearColor)
    alertBearFVG := true

if not na(bullFvgBox)
    box.set_right(bullFvgBox, bar_index + 1)
    if low <= latestBullFvgBottom
        box.delete(bullFvgBox)
        bullFvgBox := na
        latestBullFvgTop := na
        latestBullFvgBottom := na

if not na(bearFvgBox)
    box.set_right(bearFvgBox, bar_index + 1)
    if high >= latestBearFvgTop
        box.delete(bearFvgBox)
        bearFvgBox := na
        latestBearFvgTop := na
        latestBearFvgBottom := na

//══════════════════════════════════════════════════════════════════════════════
// PREMIUM / DISCOUNT ZONES
//══════════════════════════════════════════════════════════════════════════════
if showPdPreset and not na(trailingTop) and not na(trailingBottom) and trailingTop > trailingBottom
    premiumTopPlot    := trailingTop
    premiumBottomPlot := trailingTop * 0.95 + trailingBottom * 0.05
    eqTopPlot         := trailingTop * 0.525 + trailingBottom * 0.475
    eqBottomPlot      := trailingBottom * 0.525 + trailingTop * 0.475
    discountTopPlot   := trailingBottom * 0.95 + trailingTop * 0.05
    discountBottomPlot:= trailingBottom
else
    premiumTopPlot    := na
    premiumBottomPlot := na
    eqTopPlot         := na
    eqBottomPlot      := na
    discountTopPlot   := na
    discountBottomPlot:= na

pPremiumTop = plot(premiumTopPlot, title="Premium Top", display=display.none)
pPremiumBot = plot(premiumBottomPlot, title="Premium Bottom", display=display.none)
pEqTop      = plot(eqTopPlot, title="Equilibrium Top", display=display.none)
pEqBot      = plot(eqBottomPlot, title="Equilibrium Bottom", display=display.none)
pDiscTop    = plot(discountTopPlot, title="Discount Top", display=display.none)
pDiscBot    = plot(discountBottomPlot, title="Discount Bottom", display=display.none)

fill(pPremiumTop, pPremiumBot, color=color.new(premiumColor, 88), title="Premium Zone")
fill(pEqTop, pEqBot, color=color.new(equilibriumColor, 90), title="Equilibrium Zone")
fill(pDiscTop, pDiscBot, color=color.new(discountColor, 88), title="Discount Zone")

//══════════════════════════════════════════════════════════════════════════════
// MTF LEVELS
//══════════════════════════════════════════════════════════════════════════════
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

showDailyPlot   = showDailyLevels and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("D")
showWeeklyPlot  = showWeeklyLevels and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("W")
showMonthlyPlot = showMonthlyLevels and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("M")

plot(showDailyPlot ? pdh : na, "PDH", color=blue, linewidth=1, style=plot.style_linebr)
plot(showDailyPlot ? pdl : na, "PDL", color=blue, linewidth=1, style=plot.style_linebr)
plot(showWeeklyPlot ? pwh : na, "PWH", color=orange, linewidth=1, style=plot.style_linebr)
plot(showWeeklyPlot ? pwl : na, "PWL", color=orange, linewidth=1, style=plot.style_linebr)
plot(showMonthlyPlot ? pmh : na, "PMH", color=gray, linewidth=1, style=plot.style_linebr)
plot(showMonthlyPlot ? pml : na, "PML", color=gray, linewidth=1, style=plot.style_linebr)

//══════════════════════════════════════════════════════════════════════════════
// CANDLE COLORING
//══════════════════════════════════════════════════════════════════════════════
barCol = internalBias == BULL ? bullColor : internalBias == BEAR ? bearColor : na
plotcandle(colorBars ? open : na, high, low, close, color=barCol, wickcolor=barCol, bordercolor=barCol)

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 10, border_width=1)

if barstate.islast
    table.set_position(dash, f_dash_pos(dashboardPos))

    if showDashboard
        zoneText = f_zone_status(trailingTop, trailingBottom)
        bullObText = not na(bullObBox) ? "Active" : "None"
        bearObText = not na(bearObBox) ? "Active" : "None"
        bullFvgText = not na(bullFvgBox) ? "Active" : "None"
        bearFvgText = not na(bearFvgBox) ? "Active" : "None"

        table.cell(dash, 0, 0, "Matrix Trading Lab", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, 0, "SMC Dashboard", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(dash, 0, 1, "Swing Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 1, f_bias_text(swingBias), text_color=f_bias_color(swingBias), bgcolor=panelBg)

        table.cell(dash, 0, 2, "Internal Bias", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 2, f_bias_text(internalBias), text_color=f_bias_color(internalBias), bgcolor=panelBg)

        table.cell(dash, 0, 3, "Swing High", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 3, na(swingHigh) ? "N/A" : str.tostring(swingHigh, format.mintick), text_color=color.white, bgcolor=panelBg)

        table.cell(dash, 0, 4, "Swing Low", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 4, na(swingLow) ? "N/A" : str.tostring(swingLow, format.mintick), text_color=color.white, bgcolor=panelBg)

        table.cell(dash, 0, 5, "Bullish OB", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 5, bullObText, text_color=not na(bullObBox) ? bullColor : gray, bgcolor=panelBg)

        table.cell(dash, 0, 6, "Bearish OB", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 6, bearObText, text_color=not na(bearObBox) ? bearColor : gray, bgcolor=panelBg)

        table.cell(dash, 0, 7, "Bullish FVG", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 7, bullFvgText, text_color=not na(bullFvgBox) ? bullColor : gray, bgcolor=panelBg)

        table.cell(dash, 0, 8, "Bearish FVG", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 8, bearFvgText, text_color=not na(bearFvgBox) ? bearColor : gray, bgcolor=panelBg)

        table.cell(dash, 0, 9, "Price Zone", text_color=color.white, bgcolor=panelBg)
        table.cell(dash, 1, 9, zoneText, text_color=f_zone_color(zoneText), bgcolor=panelBg)
    else
        for r = 0 to 9
            table.cell(dash, 0, r, "", bgcolor=color.new(color.black, 100))
            table.cell(dash, 1, r, "", bgcolor=color.new(color.black, 100))

//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(enableStructureAlerts and alertSwingBullBOS, "Swing Bullish BOS", "Matrix Market Structure: Swing Bullish BOS")
alertcondition(enableStructureAlerts and alertSwingBearBOS, "Swing Bearish BOS", "Matrix Market Structure: Swing Bearish BOS")
alertcondition(enableStructureAlerts and alertSwingBullCHOCH, "Swing Bullish CHoCH", "Matrix Market Structure: Swing Bullish CHoCH")
alertcondition(enableStructureAlerts and alertSwingBearCHOCH, "Swing Bearish CHoCH", "Matrix Market Structure: Swing Bearish CHoCH")

alertcondition(enableStructureAlerts and alertInternalBullBOS, "Internal Bullish BOS", "Matrix Market Structure: Internal Bullish BOS")
alertcondition(enableStructureAlerts and alertInternalBearBOS, "Internal Bearish BOS", "Matrix Market Structure: Internal Bearish BOS")
alertcondition(enableStructureAlerts and alertInternalBullCHOCH, "Internal Bullish CHoCH", "Matrix Market Structure: Internal Bullish CHoCH")
alertcondition(enableStructureAlerts and alertInternalBearCHOCH, "Internal Bearish CHoCH", "Matrix Market Structure: Internal Bearish CHoCH")

alertcondition(enableZoneAlerts and alertBullOB, "New Bullish Order Block", "Matrix Market Structure: New Bullish Order Block")
alertcondition(enableZoneAlerts and alertBearOB, "New Bearish Order Block", "Matrix Market Structure: New Bearish Order Block")
alertcondition(enableZoneAlerts and alertBullFVG, "New Bullish Fair Value Gap", "Matrix Market Structure: New Bullish Fair Value Gap")
alertcondition(enableZoneAlerts and alertBearFVG, "New Bearish Fair Value Gap", "Matrix Market Structure: New Bearish Fair Value Gap")
alertcondition(enableZoneAlerts and alertEQH, "Equal Highs Detected", "Matrix Market Structure: Equal Highs detected")
alertcondition(enableZoneAlerts and alertEQL, "Equal Lows Detected", "Matrix Market Structure: Equal Lows detected")
````
