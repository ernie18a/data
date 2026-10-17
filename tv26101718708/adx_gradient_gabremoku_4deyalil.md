# ADX Gradient [Gabremoku]

- url: https://www.tradingview.com/script/4DEYaLil-ADX-Gradient-Gabremoku/
- type: indicator
- pine_id: PUB;8dd114e1c4a54db58c81cc9b2fb38d13
- version: 3.0

## Description

ADX Gradient is a directional strength indicator built on Wilder's classic ADX, enhanced with a smooth multi-stage color gradient that makes it immediately clear how strong the current trend is — no thresholds to memorize, just read the color.

How it works

The ADX line changes color dynamically based on its current value, following a logical progression from neutral to extreme:

🔘 < 15 — Gray: no trend, range-bound market

🟢 15–25 — Green gradient: trend forming / confirmed

🔵 25–45 — Blue gradient: trend developing

🟠 45–55 — Orange: strong trend

🔴 55+ — Red / bright red: extreme trend strength

Features

Wilder ADX with customizable length and smoothing period

Smooth gradient coloring across 7 strength zones

Optional DI+ / DI− lines for directional context

Colored dashed reference bands at levels 20, 30, 50 and 60

Colored fill bands between levels for quick visual reading

Built-in alert conditions on ADX crossing 20, 30, and 50

How to use

Use this indicator alongside your existing strategy to gauge trend quality. A rising ADX in green/blue suggests a healthy trend worth following. Orange and red zones signal a potentially exhausted or overextended move — use with caution. When ADX is gray and falling, prefer range or mean-reversion setups.

Settings

ADX Length: lookback period for True Range and DM smoothing (default: 14)

ADX Smoothing: RMA smoothing period for the final ADX line (default: 14)

Show DI+ / DI−: toggle directional indicator lines on/off

Published by Gabremoku

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator(title="ADX Gradient Regime [Gabremoku]", shorttitle="ADX Regime [Gabremoku]", overlay=false, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  ADX Gradient Regime [Gabremoku]
//  Wilder ADX with gradient strength, DI dominance, slope logic,
//  regime classification, dashboard, labels and alerts.
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core"
adxLen    = input.int(14, "ADX Length", minval=1, group=grp0)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=grp0)
srcClose  = input.source(close, "Source", group=grp0)
srcHigh   = high
srcLow    = low

grp1 = "📏 Levels"
lvlForming   = input.float(20.0, "Trend Forming", minval=1, step=0.5, group=grp1)
lvlConfirmed = input.float(30.0, "Trend Confirmed", minval=1, step=0.5, group=grp1)
lvlStrong    = input.float(50.0, "Strong Trend", minval=1, step=0.5, group=grp1)
lvlExtreme   = input.float(60.0, "Extreme Trend", minval=1, step=0.5, group=grp1)

grp2 = "🎨 Style"
showDI          = input.bool(true, "Show DI+ / DI-", group=grp2)
showHistogram   = input.bool(true, "Show DI Spread Histogram", group=grp2)
showBgBias      = input.bool(false, "Show Direction Bias Background", group=grp2)
showDashboard   = input.bool(true, "Show Dashboard", group=grp2)
showLastLabels  = input.bool(true, "Show Last Value Labels", group=grp2)
adxWidth        = input.int(2, "ADX Width", minval=1, maxval=5, group=grp2)
diWidth         = input.int(1, "DI Width", minval=1, maxval=4, group=grp2)
histTransparency = input.int(35, "Histogram Transparency", minval=0, maxval=100, group=grp2)
labelMinGap     = input.float(4.0, "Last Labels Min Gap", minval=0.5, step=0.5, group=grp2)

grp3 = "🧠 Logic"
slopeLookback   = input.int(1, "ADX Slope Lookback", minval=1, maxval=10, group=grp3)
dominanceThresh = input.float(5.0, "DI Dominance Threshold", minval=0.0, step=0.5, group=grp3)
normalizeSpread = input.bool(false, "Normalize DI Spread Histogram", group=grp3)

grp4 = "🌈 Colors"
bullColor    = input.color(#00BFA5, "Bullish Color", group=grp4)
bearColor    = input.color(#FF6F00, "Bearish Color", group=grp4)
neutralColor = input.color(#78909C, "Neutral Color", group=grp4)
strongColor  = input.color(#2979FF, "Confirmed Trend Color", group=grp4)
extremeColor = input.color(#FF1744, "Extreme Trend Color", group=grp4)

grp5 = "🪧 Dashboard"
dashPosInput = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

// ── DASHBOARD POSITION ────────────────────────────────────────
dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left


// ── WILDER ADX ────────────────────────────────────────────────
upMove   = srcHigh - srcHigh[1]
downMove = srcLow[1] - srcLow

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0.0

tr1 = srcHigh - srcLow
tr2 = math.abs(srcHigh - srcClose[1])
tr3 = math.abs(srcLow - srcClose[1])
trueRange = na(srcClose[1]) ? tr1 : math.max(tr1, math.max(tr2, tr3))

atrAdx   = ta.rma(trueRange, adxLen)
plusRaw  = ta.rma(plusDM, adxLen)
minusRaw = ta.rma(minusDM, adxLen)

plusDI  = atrAdx != 0 ? 100 * plusRaw / atrAdx : 0.0
minusDI = atrAdx != 0 ? 100 * minusRaw / atrAdx : 0.0

sumDI = plusDI + minusDI
dx    = sumDI != 0 ? 100 * math.abs(plusDI - minusDI) / sumDI : 0.0
adx   = ta.rma(dx, adxSmooth)


// ── DERIVED LOGIC ─────────────────────────────────────────────
adxSlope   = adx - adx[slopeLookback]
adxRising  = adxSlope > 0
adxFalling = adxSlope < 0

diSpread   = plusDI - minusDI
spreadPlot = normalizeSpread and sumDI != 0 ? (diSpread / sumDI) * 100 : diSpread

bullDominant     = diSpread > dominanceThresh
bearDominant     = diSpread < -dominanceThresh
neutralDominance = not bullDominant and not bearDominant

string trendDirection = "Neutral"
if bullDominant
    trendDirection := "Bullish"
else if bearDominant
    trendDirection := "Bearish"

string regime = "Extreme"
if adx < lvlForming
    regime := "Range"
else if adx < lvlConfirmed
    regime := "Forming"
else if adx < lvlStrong
    regime := "Confirmed"
else if adx < lvlExtreme
    regime := "Strong"

string state = "Extreme Strength"
if adx < lvlForming and neutralDominance
    state := "No Trend"
else if adx < lvlForming and bullDominant
    state := "Bull Pressure"
else if adx < lvlForming and bearDominant
    state := "Bear Pressure"
else if adx < lvlConfirmed and bullDominant
    state := "Bull Trend Forming"
else if adx < lvlConfirmed and bearDominant
    state := "Bear Trend Forming"
else if adx < lvlStrong and bullDominant
    state := "Bull Trend Confirmed"
else if adx < lvlStrong and bearDominant
    state := "Bear Trend Confirmed"
else if adx < lvlExtreme and bullDominant
    state := "Strong Bull Trend"
else if adx < lvlExtreme and bearDominant
    state := "Strong Bear Trend"
else if bullDominant
    state := "Extreme Bull Trend"
else if bearDominant
    state := "Extreme Bear Trend"


// ── COLORS ────────────────────────────────────────────────────
color adxColorBase = color.gray
if adx < 15
    adxColorBase := color.new(neutralColor, 30)
else if adx < lvlForming
    adxColorBase := color.from_gradient(adx, 15, lvlForming, neutralColor, color.lime)
else if adx < 25
    adxColorBase := color.lime
else if adx < lvlConfirmed
    adxColorBase := color.from_gradient(adx, 25, lvlConfirmed, color.lime, strongColor)
else if adx < 45
    adxColorBase := color.from_gradient(adx, lvlConfirmed, 45, strongColor, color.rgb(21, 101, 192))
else if adx < lvlStrong
    adxColorBase := color.from_gradient(adx, 45, lvlStrong, color.rgb(21, 101, 192), color.rgb(255, 109, 0))
else if adx < lvlExtreme
    adxColorBase := color.from_gradient(adx, lvlStrong, lvlExtreme, color.rgb(255, 109, 0), extremeColor)
else
    adxColorBase := extremeColor

color adxColor = color.new(adxColorBase, 25)
if adxRising
    adxColor := color.new(adxColorBase, 0)

color diBullColor = color.new(bullColor, 45)
if bullDominant
    diBullColor := color.new(bullColor, 0)

color diBearColor = color.new(bearColor, 45)
if bearDominant
    diBearColor := color.new(bearColor, 0)

color histColor = color.new(neutralColor, 60)
if bullDominant
    histColor := color.new(bullColor, histTransparency)
else if bearDominant
    histColor := color.new(bearColor, histTransparency)

color bgBiasColor = na
if bullDominant and adx >= lvlForming
    bgBiasColor := color.new(bullColor, 92)
else if bearDominant and adx >= lvlForming
    bgBiasColor := color.new(bearColor, 92)

color stateColor = neutralColor
if str.contains(state, "Bull")
    stateColor := bullColor
else if str.contains(state, "Bear")
    stateColor := bearColor
else if adx >= lvlStrong
    stateColor := extremeColor


// ── PLOTS ─────────────────────────────────────────────────────
plot(adx, "ADX", color=adxColor, linewidth=adxWidth)
plot(showDI ? plusDI : na, "DI+", color=diBullColor, linewidth=diWidth)
plot(showDI ? minusDI : na, "DI-", color=diBearColor, linewidth=diWidth)
plot(showHistogram ? spreadPlot : na, "DI Spread", style=plot.style_columns, color=histColor, histbase=0)

bgcolor(showBgBias ? bgBiasColor : na, title="Direction Bias Background")


// ── LEVELS ────────────────────────────────────────────────────
hForming = hline(lvlForming, "Trend Forming", color=color.new(color.lime, 55), linestyle=hline.style_dashed, linewidth=1)
hConfirm = hline(lvlConfirmed, "Trend Confirmed", color=color.new(strongColor, 55), linestyle=hline.style_dashed, linewidth=1)
hStrong  = hline(lvlStrong, "Strong Trend", color=color.new(color.rgb(255, 109, 0), 55), linestyle=hline.style_dashed, linewidth=1)
hExtreme = hline(lvlExtreme, "Extreme Trend", color=color.new(extremeColor, 55), linestyle=hline.style_dotted, linewidth=1)
hZero    = hline(0, "Zero", color=color.new(color.gray, 85))

fill(hForming, hConfirm, color=color.new(color.lime, 93), title="Forming Band")
fill(hConfirm, hStrong, color=color.new(strongColor, 93), title="Confirmed Band")
fill(hStrong, hExtreme, color=color.new(color.rgb(255, 109, 0), 90), title="Strong Band")


// ── DASHBOARD ─────────────────────────────────────────────────
var table dash = table.new(dashPos, 2, 6, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, state, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Regime", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, regime, text_color=adxColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Direction", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, trendDirection, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "ADX", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, str.tostring(adx, "#.00"), text_color=adxColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Slope", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, adxRising ? "Rising" : adxFalling ? "Falling" : "Flat", text_color=adxRising ? color.lime : adxFalling ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "DI Spread", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, str.tostring(diSpread, "#.00"), text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 5)


// ── LAST VALUE LABELS ─────────────────────────────────────────
var label lastAdxLabel   = na
var label lastPlusLabel  = na
var label lastMinusLabel = na

if barstate.islast
    if showLastLabels
        label.delete(lastAdxLabel)
        label.delete(lastPlusLabel)
        label.delete(lastMinusLabel)

        float yState = adx
        float yPlus  = plusDI
        float yMinus = minusDI

        if showDI
            float topVal = math.max(yState, math.max(yPlus, yMinus))
            float midVal = yState
            float lowVal = math.min(yState, math.min(yPlus, yMinus))

            string topName = yState >= yPlus and yState >= yMinus ? "state" : yPlus >= yState and yPlus >= yMinus ? "plus" : "minus"
            string lowName = yState <= yPlus and yState <= yMinus ? "state" : yPlus <= yState and yPlus <= yMinus ? "plus" : "minus"
            string midName = topName != "state" and lowName != "state" ? "state" : topName != "plus" and lowName != "plus" ? "plus" : "minus"

            float topY = topVal
            float midY = midVal
            float lowY = lowVal

            if topY - midY < labelMinGap
                midY := topY - labelMinGap
            if midY - lowY < labelMinGap
                lowY := midY - labelMinGap
            if topY - midY < labelMinGap
                midY := topY - labelMinGap

            yState := topName == "state" ? topY : midName == "state" ? midY : lowY
            yPlus  := topName == "plus"  ? topY : midName == "plus"  ? midY : lowY
            yMinus := topName == "minus" ? topY : midName == "minus" ? midY : lowY

        lastAdxLabel := label.new(
             bar_index,
             yState,
             "◀ ADX: " + str.tostring(adx, "#.00") + " | " + state,
             color=color.new(color.black, 100),
             textcolor=adxColor,
             style=label.style_label_left
         )

        if showDI
            lastPlusLabel := label.new(
                 bar_index,
                 yPlus,
                 "◀ DI+: " + str.tostring(plusDI, "#.00"),
                 color=color.new(color.black, 100),
                 textcolor=diBullColor,
                 style=label.style_label_left
             )

            lastMinusLabel := label.new(
                 bar_index,
                 yMinus,
                 "◀ DI-: " + str.tostring(minusDI, "#.00"),
                 color=color.new(color.black, 100),
                 textcolor=diBearColor,
                 style=label.style_label_left
             )
        else
            label.delete(lastPlusLabel)
            label.delete(lastMinusLabel)
    else
        label.delete(lastAdxLabel)
        label.delete(lastPlusLabel)
        label.delete(lastMinusLabel)


// ── ALERTS ────────────────────────────────────────────────────
crossForming   = ta.crossover(adx, lvlForming)
crossConfirmed = ta.crossover(adx, lvlConfirmed)
crossStrong    = ta.crossover(adx, lvlStrong)

alertcondition(crossForming, title="ADX crosses trend forming", message="ADX crossed the trend-forming level on {{ticker}}")
alertcondition(crossConfirmed, title="ADX crosses trend confirmed", message="ADX crossed the trend-confirmed level on {{ticker}}")
alertcondition(crossStrong, title="ADX crosses strong trend", message="ADX crossed the strong-trend level on {{ticker}}")

alertcondition(bullDominant and adx >= lvlForming and adxRising, title="Bull trend pressure", message="Bull trend pressure detected on {{ticker}}")
alertcondition(bearDominant and adx >= lvlForming and adxRising, title="Bear trend pressure", message="Bear trend pressure detected on {{ticker}}")

alertcondition(ta.crossover(plusDI, minusDI), title="DI+ crosses above DI-", message="DI+ crossed above DI- on {{ticker}}")
alertcondition(ta.crossunder(plusDI, minusDI), title="DI- crosses above DI+", message="DI- crossed above DI+ on {{ticker}}")
````
