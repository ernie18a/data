# MCM 21d EMA Array

- url: https://www.tradingview.com/script/mcm9RQjS-MCM-21d-EMA-Array/
- type: indicator
- pine_id: PUB;787920efbf7142f790c10d6447ccf75e
- version: 1.0

## Description

MA array with 5 moving averages, by default: 8 SMA, 21 EMA, 50 SMA, 150 SMA, 200 SMA

Triangles show consecutive closes across the second (21-day) average: 1st close yellow; second close red or green depending on direction.

Most features are configurable in the settings.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mcmescher

// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// MA Array
// Five-line moving-average array — a simpler, non-HA-based companion to the HA Trend Array.
// Designed for use on charts where the HA Trend Array's 6 lines are too dense, particularly
// on intraday timeframes where a more compact MA visualization is wanted.
//
// Each of the 5 line slots is independently configurable:
//   - Length, MA type (SMA/EMA), width (1-3)
//   - Color mode: solid (single color) or dynamic (slope z-score gradient red→neutral→green)
//
// Right-side labels show the percent distance from current price to each MA, color-matched
// to the line.
//
// Two configurable fill regions: between lines 1-2 and between lines 2-3, each with
// independent bullish/bearish color settings.
//@version=6
indicator("MA Array", "MA Array", overlay=true)

// ~~ Tooltips {
string TT_LEN      = "MA length in chart bars."
string TT_TYPE     = "Moving average type. SMA = simple, EMA = exponential (faster response)."
string TT_WIDTH    = "Line width: 1 (thin), 2 (medium), 3 (thick)."
string TT_MODE     = "Color mode.\n\nSolid: line uses a single color regardless of slope.\nDynamic: line color smoothly transitions from red (strongly falling) through neutral (flat) to green (strongly rising), based on the slope z-score."
string TT_SLOPELB  = "Bars used to compute slope (current value vs N bars ago) for dynamic coloring."
string TT_SLOPESDLB= "Bars used to compute the standard deviation of slopes — used to normalize slope into a z-score for the gradient mapping."
string TT_GRADIENT = "When dynamic color mode is used: how strong the slope z-score must be to reach the full saturated end of the gradient. Lower values = colors saturate more easily; higher values = colors stay more muted unless slope is extreme."
string TT_FILL     = "Fill region between two adjacent lines. Color dynamically reflects which line is on top — using configured 'bullish stack' color when upper line > lower, 'bearish stack' color when crossed."
string TT_LABEL    = "Show the percent distance from current price to each MA, color-matched to the line."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs — Per-line configuration {
// Five line slots — each can be independently enabled, configured for length, type, width,
// and color mode. Defaults: 8/21/50/150/200 with widths and colors per spec:
//   1: SMA 8,    yellow      (fast)
//   2: EMA 21,   light blue
//   3: SMA 50,   orange
//   4: SMA 150,  dynamic
//   5: SMA 200,  dark red    (long-term anchor)

string GRP_L1 = "Line 1 (default 8 SMA)"
bool   l1On    = input.bool(true,         "Enable",     group=GRP_L1)
int    l1Len   = input.int(8,             "Length",     minval=2, group=GRP_L1, tooltip=TT_LEN)
string l1Type  = input.string("SMA",      "Type",       options=["SMA","EMA"], group=GRP_L1, tooltip=TT_TYPE)
int    l1Width = input.int(2,             "Width",      options=[1,2,3], group=GRP_L1, tooltip=TT_WIDTH)
string l1Mode  = input.string("Solid",    "Color mode", options=["Solid","Dynamic"], group=GRP_L1, tooltip=TT_MODE)
color  l1Solid = input.color(#fdd835,     "Solid color", group=GRP_L1)

string GRP_L2 = "Line 2 (default 21 EMA)"
bool   l2On    = input.bool(true,         "Enable",     group=GRP_L2)
int    l2Len   = input.int(21,            "Length",     minval=2, group=GRP_L2, tooltip=TT_LEN)
string l2Type  = input.string("EMA",      "Type",       options=["SMA","EMA"], group=GRP_L2, tooltip=TT_TYPE)
int    l2Width = input.int(2,             "Width",      options=[1,2,3], group=GRP_L2, tooltip=TT_WIDTH)
string l2Mode  = input.string("Solid",    "Color mode", options=["Solid","Dynamic"], group=GRP_L2, tooltip=TT_MODE)
color  l2Solid = input.color(#64b5f6,     "Solid color", group=GRP_L2)

string GRP_L3 = "Line 3 (default 50 SMA)"
bool   l3On    = input.bool(true,         "Enable",     group=GRP_L3)
int    l3Len   = input.int(50,            "Length",     minval=2, group=GRP_L3, tooltip=TT_LEN)
string l3Type  = input.string("SMA",      "Type",       options=["SMA","EMA"], group=GRP_L3, tooltip=TT_TYPE)
int    l3Width = input.int(2,             "Width",      options=[1,2,3], group=GRP_L3, tooltip=TT_WIDTH)
string l3Mode  = input.string("Solid",    "Color mode", options=["Solid","Dynamic"], group=GRP_L3, tooltip=TT_MODE)
color  l3Solid = input.color(#fb8c00,     "Solid color", group=GRP_L3)

string GRP_L4 = "Line 4 (default 150 SMA, dynamic)"
bool   l4On    = input.bool(true,         "Enable",     group=GRP_L4)
int    l4Len   = input.int(150,           "Length",     minval=2, group=GRP_L4, tooltip=TT_LEN)
string l4Type  = input.string("SMA",      "Type",       options=["SMA","EMA"], group=GRP_L4, tooltip=TT_TYPE)
int    l4Width = input.int(3,             "Width",      options=[1,2,3], group=GRP_L4, tooltip=TT_WIDTH)
string l4Mode  = input.string("Dynamic",  "Color mode", options=["Solid","Dynamic"], group=GRP_L4, tooltip=TT_MODE)
color  l4Solid = input.color(#9e9e9e,     "Solid color", group=GRP_L4)

string GRP_L5 = "Line 5 (default 200 SMA)"
bool   l5On    = input.bool(true,         "Enable",     group=GRP_L5)
int    l5Len   = input.int(200,           "Length",     minval=2, group=GRP_L5, tooltip=TT_LEN)
string l5Type  = input.string("SMA",      "Type",       options=["SMA","EMA"], group=GRP_L5, tooltip=TT_TYPE)
int    l5Width = input.int(2,             "Width",      options=[1,2,3], group=GRP_L5, tooltip=TT_WIDTH)
string l5Mode  = input.string("Solid",    "Color mode", options=["Solid","Dynamic"], group=GRP_L5, tooltip=TT_MODE)
color  l5Solid = input.color(#801922,     "Solid color", group=GRP_L5)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs — Dynamic coloring {
string GRP_D = "Dynamic color settings"
int   slopeLookback      = input.int(4, "Slope lookback (bars)",    minval=2, group=GRP_D, tooltip=TT_SLOPELB)
int   slopeStdevLookback = input.int(50, "Slope stdev lookback (bars)", minval=10, group=GRP_D, tooltip=TT_SLOPESDLB)
float gradientSaturation = input.float(2.0, "Gradient saturation z-score", minval=0.5, step=0.1, group=GRP_D, tooltip=TT_GRADIENT)

color colDynUp      = input.color(#00c853, "Strong rising color",  group=GRP_D)
color colDynNeutral = input.color(#9e9e9e, "Neutral (flat) color", group=GRP_D)
color colDynDn      = input.color(#d50000, "Strong falling color", group=GRP_D)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs — Fills {
// Each fill region has its own bullish/bearish color settings, independently configurable.
string GRP_FA = "Fill A (between lines 1 and 2)"
bool   fillAOn          = input.bool(true, "Show fill", group=GRP_FA, tooltip=TT_FILL)
int    fillATransparency= input.int(70, "Transparency", minval=0, maxval=99, group=GRP_FA)
color  colFillAUp       = input.color(#a5d6a7, "Bullish stack color (upper > lower)", group=GRP_FA)
color  colFillADn       = input.color(#faa1a4, "Bearish stack color (upper < lower)", group=GRP_FA)

string GRP_FB = "Fill B (between lines 2 and 3)"
bool   fillBOn          = input.bool(true, "Show fill", group=GRP_FB, tooltip=TT_FILL)
int    fillBTransparency= input.int(70, "Transparency", minval=0, maxval=99, group=GRP_FB)
color  colFillBUp       = input.color(#388e3c, "Bullish stack color (upper > lower)", group=GRP_FB)
color  colFillBDn       = input.color(#f7525f, "Bearish stack color (upper < lower)", group=GRP_FB)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs — Labels {
string GRP_LB = "Distance labels"
bool   showLabels = input.bool(true, "Show distance-to-price labels", group=GRP_LB, tooltip=TT_LABEL)
int    labelOffset = input.int(7, "Label x-offset (bars right of last bar)", minval=0, group=GRP_LB)
string labelSizeSel = input.string("normal", "Label size", options=["tiny","small","normal","large","huge"], group=GRP_LB)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs — Cross signal {
// Detects price crossing one of the MA lines (default Line 2 — the 21 EMA) after an established
// trend on one side. The "established trend" is N consecutive closes on one side. Once that
// trend is established, the FIRST close on the opposite side fires a yellow warning triangle,
// and the SECOND consecutive close fires a colored confirmation triangle (green up, red down).
//
// State machine:
//   - State "above": price has had `trendBars` consecutive closes above the reference line
//   - First close below in state "above" → yellow down triangle (warning)
//   - Second consecutive close below → red down triangle (confirmed); state flips to "below"
//   - Symmetric for "below" → "above" transitions
string TT_CROSSLINE = "Which line to use as the cross reference. Default is Line 2 (21 EMA)."
string TT_CROSSTREND= "Number of consecutive closes on one side required to consider price 'trending' on that side. Higher values require longer-established trends before signaling. Default 3."
string TT_CROSSWARN = "When ON, a yellow triangle marks the FIRST close on the opposite side of the trend (early warning). When OFF, only the confirmation triangle is shown."
string TT_CROSSCONF = "When ON, a green/red triangle marks the SECOND consecutive close on the opposite side (confirmed cross). This is the main signal."

string GRP_X = "Cross signal"
bool   showCrossSignal = input.bool(true, "Enable cross signal", group=GRP_X)
int    crossLineNum    = input.int(2, "Reference line", minval=1, maxval=5, group=GRP_X, tooltip=TT_CROSSLINE)
int    trendBars       = input.int(3, "Trend establishment bars", minval=2, maxval=20, group=GRP_X, tooltip=TT_CROSSTREND)
bool   showWarning     = input.bool(true,  "Show warning triangle (1st cross close)",     group=GRP_X, tooltip=TT_CROSSWARN)
bool   showConfirm     = input.bool(true,  "Show confirmation triangle (2nd cross close)", group=GRP_X, tooltip=TT_CROSSCONF)
color  colCrossWarn    = input.color(#ffd600, "Warning color (yellow)",                     group=GRP_X)
color  colCrossUp      = input.color(#00e676, "Confirmation up color (green)",              group=GRP_X)
color  colCrossDn      = input.color(#ff1744, "Confirmation down color (red)",              group=GRP_X)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ MA helper {
maChoice(string type, float s, simple int len) =>
    float smaVal = ta.sma(s, len)
    float emaVal = ta.ema(s, len)
    type == "SMA" ? smaVal : emaVal
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ MA computation per line {
float src = close
float ma1 = maChoice(l1Type, src, l1Len)
float ma2 = maChoice(l2Type, src, l2Len)
float ma3 = maChoice(l3Type, src, l3Len)
float ma4 = maChoice(l4Type, src, l4Len)
float ma5 = maChoice(l5Type, src, l5Len)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Dynamic color computation {
dynamicColor(float ma) =>
    float slope = ma - ma[slopeLookback]
    float slopeStdev = ta.stdev(ma - ma[slopeLookback], slopeStdevLookback)
    float zScore = slopeStdev > 0 ? slope / slopeStdev : 0.0
    float clampedZ = math.max(-gradientSaturation, math.min(gradientSaturation, zScore))
    float t = (clampedZ + gradientSaturation) / (2 * gradientSaturation)
    color result = na
    if t <= 0.5
        float subT = t * 2.0
        result := color.from_gradient(subT, 0.0, 1.0, colDynDn, colDynNeutral)
    else
        float subT = (t - 0.5) * 2.0
        result := color.from_gradient(subT, 0.0, 1.0, colDynNeutral, colDynUp)
    result

color col1 = l1Mode == "Solid" ? l1Solid : dynamicColor(ma1)
color col2 = l2Mode == "Solid" ? l2Solid : dynamicColor(ma2)
color col3 = l3Mode == "Solid" ? l3Solid : dynamicColor(ma3)
color col4 = l4Mode == "Solid" ? l4Solid : dynamicColor(ma4)
color col5 = l5Mode == "Solid" ? l5Solid : dynamicColor(ma5)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plot lines {
plot(l1On ? ma1 : na, "Line 1", color=col1, linewidth=l1Width)
plot(l2On ? ma2 : na, "Line 2", color=col2, linewidth=l2Width)
plot(l3On ? ma3 : na, "Line 3", color=col3, linewidth=l3Width)
plot(l4On ? ma4 : na, "Line 4", color=col4, linewidth=l4Width)
plot(l5On ? ma5 : na, "Line 5", color=col5, linewidth=l5Width)

// Plots used as anchors for fills
p1 = plot(l1On ? ma1 : na, "p1", display=display.none)
p2 = plot(l2On ? ma2 : na, "p2", display=display.none)
p3 = plot(l3On ? ma3 : na, "p3", display=display.none)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Fills with dynamic stack-aware color {
// Fill A: between line 1 and line 2
color fillAColor = na
if fillAOn and l1On and l2On
    color base = ma1 >= ma2 ? colFillAUp : colFillADn
    fillAColor := color.new(base, fillATransparency)
fill(p1, p2, color=fillAColor, title="Fill 1-2")

// Fill B: between line 2 and line 3
color fillBColor = na
if fillBOn and l2On and l3On
    color base = ma2 >= ma3 ? colFillBUp : colFillBDn
    fillBColor := color.new(base, fillBTransparency)
fill(p2, p3, color=fillBColor, title="Fill 2-3")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Distance-to-price labels {
formatPctDistance(float price, float ma) =>
    float pct = ma != 0 ? (price - ma) / ma * 100.0 : 0.0
    str.tostring(pct, "0.00;-0.00") + "%"

if showLabels and barstate.islast
    var label lab1 = na
    var label lab2 = na
    var label lab3 = na
    var label lab4 = na
    var label lab5 = na
    label.delete(lab1)
    label.delete(lab2)
    label.delete(lab3)
    label.delete(lab4)
    label.delete(lab5)

    color transparentBg = color.new(color.black, 100)
    string sizeMapped = labelSizeSel == "tiny" ? size.tiny : labelSizeSel == "small" ? size.small : labelSizeSel == "normal" ? size.normal : labelSizeSel == "large" ? size.large : size.huge

    if l1On
        lab1 := label.new(bar_index + labelOffset, ma1, formatPctDistance(close, ma1), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=transparentBg, textcolor=col1, size=sizeMapped)
    if l2On
        lab2 := label.new(bar_index + labelOffset, ma2, formatPctDistance(close, ma2), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=transparentBg, textcolor=col2, size=sizeMapped)
    if l3On
        lab3 := label.new(bar_index + labelOffset, ma3, formatPctDistance(close, ma3), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=transparentBg, textcolor=col3, size=sizeMapped)
    if l4On
        lab4 := label.new(bar_index + labelOffset, ma4, formatPctDistance(close, ma4), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=transparentBg, textcolor=col4, size=sizeMapped)
    if l5On
        lab5 := label.new(bar_index + labelOffset, ma5, formatPctDistance(close, ma5), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=transparentBg, textcolor=col5, size=sizeMapped)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Cross signal detection {
// Pick the reference MA based on user selection
float crossMA = crossLineNum == 1 ? ma1 : crossLineNum == 2 ? ma2 : crossLineNum == 3 ? ma3 : crossLineNum == 4 ? ma4 : ma5

// Track "above" vs "below" state. State flips only after a confirmed cross (2 consecutive
// closes on the opposite side). This prevents whipsaw flagging.
//
// State values: 1 = above (trend), -1 = below (trend), 0 = undetermined (initial bars)
var int crossState = 0

// Establish initial state: once we have `trendBars` consecutive closes on one side, set state.
// After that, state only flips via confirmed cross.
bool sufficientHistory = bar_index >= trendBars
bool allAbove = true
bool allBelow = true
if sufficientHistory
    for i = 0 to trendBars - 1
        if not (close[i] > crossMA[i])
            allAbove := false
        if not (close[i] < crossMA[i])
            allBelow := false

// Initial state seeding (only sets if currently undetermined and a clear trend exists)
if crossState == 0 and sufficientHistory
    if allAbove
        crossState := 1
    else if allBelow
        crossState := -1

// Detect cross events
bool warnDown = false  // first close below while state is "above"
bool warnUp   = false  // first close above while state is "below"
bool confDown = false  // second consecutive close below — confirmed bearish cross
bool confUp   = false  // second consecutive close above — confirmed bullish cross

if crossState == 1
    // Currently in "above" trend. Check for cross-down events.
    if close < crossMA and close[1] >= crossMA[1]
        warnDown := true  // first close below
    if close < crossMA and close[1] < crossMA[1] and close[2] >= crossMA[2]
        confDown := true  // second consecutive close below
        crossState := -1   // flip state
else if crossState == -1
    // Currently in "below" trend. Check for cross-up events.
    if close > crossMA and close[1] <= crossMA[1]
        warnUp := true  // first close above
    if close > crossMA and close[1] > crossMA[1] and close[2] <= crossMA[2]
        confUp := true  // second consecutive close above
        crossState := 1  // flip state
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Cross signal plotting {
// Triangles plot at top (bearish) or bottom (bullish) of the pane to keep them visible
// against the candles and shading. Yellow = warning (1st cross close), green/red = confirmation
// (2nd consecutive cross close).
plotshape(showCrossSignal and showWarning and warnDown, "Warning down (1st close below)", shape.triangledown, location.top,    colCrossWarn, size=size.tiny)
plotshape(showCrossSignal and showWarning and warnUp,   "Warning up (1st close above)",   shape.triangleup,   location.bottom, colCrossWarn, size=size.tiny)
plotshape(showCrossSignal and showConfirm and confDown, "Confirmed cross down",            shape.triangledown, location.top,    colCrossDn,   size=size.tiny)
plotshape(showCrossSignal and showConfirm and confUp,   "Confirmed cross up",              shape.triangleup,   location.bottom, colCrossUp,   size=size.tiny)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(l1On and l2On and ta.crossover(ma1, ma2),  "Line 1 crosses above Line 2", "Line 1 just crossed above Line 2")
alertcondition(l1On and l2On and ta.crossunder(ma1, ma2), "Line 1 crosses below Line 2", "Line 1 just crossed below Line 2")
alertcondition(l2On and l3On and ta.crossover(ma2, ma3),  "Line 2 crosses above Line 3", "Line 2 just crossed above Line 3")
alertcondition(l2On and l3On and ta.crossunder(ma2, ma3), "Line 2 crosses below Line 3", "Line 2 just crossed below Line 3")
alertcondition(l3On and l4On and ta.crossover(ma3, ma4),  "Line 3 crosses above Line 4", "Line 3 just crossed above Line 4")
alertcondition(l3On and l4On and ta.crossunder(ma3, ma4), "Line 3 crosses below Line 4", "Line 3 just crossed below Line 4")

// Cross signal alerts
alertcondition(warnDown, "Cross warning — 1st close below ref line",  "Price closed below reference line for the 1st time after an established uptrend")
alertcondition(warnUp,   "Cross warning — 1st close above ref line",  "Price closed above reference line for the 1st time after an established downtrend")
alertcondition(confDown, "Cross confirmed — 2nd close below ref line", "Price closed below reference line for the 2nd consecutive bar — confirmed bearish cross")
alertcondition(confUp,   "Cross confirmed — 2nd close above ref line", "Price closed above reference line for the 2nd consecutive bar — confirmed bullish cross")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
