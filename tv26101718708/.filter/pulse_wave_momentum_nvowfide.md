# Pulse Wave Momentum

- url: https://www.tradingview.com/script/nvowfiDE-Pulse-Wave-Momentum/
- type: indicator
- pine_id: PUB;091cfe9251594b638a6d5f502bb4bbeb
- version: 2.0

## Description

[b]Pulse Wave Momentum (PWM)[/b]

A momentum indicator that combines five signals — RSI, MACD, ADX, Rate of Change, and Volume — into one simple score from -100 to +100, so you can see when momentum is building or fading at a glance.
[b]
How It Works[/b]

Instead of watching RSI, MACD, ADX, and volume separately and trying to piece them together yourself, PWM does that work for you. Each indicator "votes" toward bullish or bearish momentum:

MACD histogram expansion (biggest weight) — is the move accelerating?
ADX/DMI — is there real trend strength and clear direction?
RSI — is it rising on the right side of 50?
Rate of Change — is price speeding up?
Volume — does the move have real participation behind it?

These votes are combined into one score, then smoothed to reduce noise. A high positive score means strong bullish momentum. A high negative score means strong bearish momentum. A score near zero means the signals disagree or the market is flat.

When the score crosses above your Building Threshold (default +60), you get a green triangle and background highlight — momentum is building. When it crosses below your Fading Threshold (default -60), you get a red triangle and highlight — momentum is fading.

[b]How to Use It[/b]

Add it below your price chart. Check the dashboard in the top-right corner to see the overall score plus each individual component, so you always know what's driving the signal.

Use the green/red triangles as confirmation, not as a standalone entry trigger — pair them with your own support/resistance or price action analysis. Since momentum indicators lag price by nature, treat a "building" signal as confirmation that a move already has conviction, not a prediction of a move about to start.

You can set alerts for both building and fading signals so you don't have to watch the chart constantly.

[b]Customizing It
[/b]
All the lengths and thresholds are adjustable. For volatile markets like crypto or small-caps, tighten things up (shorter ROC, higher volume multiplier). For slower markets like large-cap stocks on daily charts, the defaults work well.

## Source Code

````pine
//@version=6
indicator("Pulse Wave Momentum", shorttitle="Pulse Wave Momentum", overlay=false, precision=2)

// ═════════════════════════════════════════════════════════════════════════
// COLOR PALETTE (defaults — dashboard colors are now overridden by inputs below)
// ═════════════════════════════════════════════════════════════════════════
c_bull       = #26d0a8   // teal-green
c_bull_dim   = color.new(#26d0a8, 75)
c_bear       = #ff4d6d   // coral-red
c_bear_dim   = color.new(#ff4d6d, 75)
c_neutral    = #7c8aa5   // slate gray
c_bg_panel   = color.new(#0f1420, 10)
c_bg_header  = color.new(#1a2233, 0)
c_text       = #e6ebf5
c_text_dim   = #7c8aa5
c_amber      = #ffb020

// ═════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════
grp1 = "RSI"
rsiLen      = input.int(14, "Length", group=grp1, minval=1)
rsiSmooth   = input.int(3, "Smoothing", group=grp1, minval=1)

grp2 = "MACD"
macdFast    = input.int(12, "Fast Length", group=grp2, minval=1)
macdSlow    = input.int(26, "Slow Length", group=grp2, minval=1)
macdSignal  = input.int(9, "Signal Length", group=grp2, minval=1)

grp3 = "ADX / DMI"
adxLen      = input.int(14, "Length", group=grp3, minval=1)
adxThresh   = input.int(20, "Trend Threshold", group=grp3, minval=1)

grp4 = "Rate of Change"
rocLen      = input.int(10, "Length", group=grp4, minval=1)

grp5 = "Volume"
volLen      = input.int(20, "MA Length", group=grp5, minval=1)
volMultiple = input.float(1.2, "Surge Multiple", group=grp5, minval=1.0, step=0.1)

grp6 = "Composite Score"
scoreThreshBuild = input.int(60, "Building Threshold", group=grp6, minval=0, maxval=100)
scoreThreshFade  = input.int(-60, "Fading Threshold", group=grp6, minval=-100, maxval=0)

grp7 = "Display"
showBg      = input.bool(true, "Background Highlight", group=grp7)
showDash    = input.bool(true, "Dashboard Panel", group=grp7)
showSignals = input.bool(true, "Signal Markers", group=grp7)
showFill    = input.bool(true, "Area Fill", group=grp7)

grp8 = "Dashboard Position & Colors"
tablePosInput  = input.string("Top Right", "Table Position (default: chart's upper-right corner)", group=grp8,
     options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
headerTextColor = input.color(color.white, "Heading Text Color", group=grp8)
headerBgColor   = input.color(#1a2233, "Heading Background Color", group=grp8)
rowLabelColor   = input.color(color.white, "Row Label Color (RSI, Score, Volume, etc.)", group=grp8)
panelBgColor    = input.color(color.new(#0f1420, 10), "Panel Background Color", group=grp8)
useWhiteTheme   = input.bool(false, "Use Solid White Dashboard (overrides colors above, no gradient)", group=grp8)
valueColorMode  = input.string("White", "Value Text Color (RSI, Score, MACD, etc.)", group=grp8, options=["White", "Color-Coded (Bull/Bear/Amber)"])
dashTextSize    = input.string("Tiny", "Dashboard Text Size", group=grp8, options=["Tiny", "Small", "Normal", "Large"])
compactMode     = input.bool(true, "Compact Mode (fewer rows, better for phones)", group=grp8)
markerSizeInput = input.string("Tiny", "Signal Marker Size (▲/▼)", group=grp8, options=["Tiny", "Small", "Normal", "Large"])

grp9 = "Divergences"
showDiv       = input.bool(true, "Show Divergences", group=grp9)
divLbL        = input.int(5, "Pivot Lookback Left", group=grp9, minval=1)
divLbR        = input.int(5, "Pivot Lookback Right", group=grp9, minval=1)
divRangeLower = input.int(5, "Min Range Between Pivots", group=grp9, minval=1)
divRangeUpper = input.int(60, "Max Range Between Pivots", group=grp9, minval=1)
showDivLabels = input.bool(false, "Show Divergence Labels", group=grp9)
bullDivColor  = input.color(#26d0a8, "Bullish Divergence Color", group=grp9)
bearDivColor  = input.color(#ff4d6d, "Bearish Divergence Color", group=grp9)

// ═════════════════════════════════════════════════════════════════════════
// HELPER: resolve table position string -> position.*
// ═════════════════════════════════════════════════════════════════════════
tablePosition = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

dashSize = switch dashTextSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

// Note: marker size is resolved inline at each plotshape() call below,
// since plotshape's "size" argument must be a compile-time constant.

// Resolved dashboard colors — solid white theme overrides the custom color inputs (no gradient/transparency)
finalHeaderBg    = useWhiteTheme ? color.white : headerBgColor
finalPanelBg     = useWhiteTheme ? color.white : panelBgColor
finalHeaderText  = useWhiteTheme ? color.black : headerTextColor
finalRowLabel    = useWhiteTheme ? color.black : rowLabelColor

// Resolves a value cell's text color: white theme forces black (contrast on white bg),
// otherwise white values mode forces white, otherwise falls back to the color-coded value passed in.
valColor(coded) =>
    useWhiteTheme ? color.black : (valueColorMode == "White" ? color.white : coded)

// ═════════════════════════════════════════════════════════════════════════
// COMPONENT CALCULATIONS
// ═════════════════════════════════════════════════════════════════════════

// RSI
rsiRaw    = ta.rsi(close, rsiLen)
rsiVal    = ta.sma(rsiRaw, rsiSmooth)
rsiRising = rsiVal > rsiVal[1] and rsiVal[1] > rsiVal[2]

// MACD
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
macdBullCross  = ta.crossover(macdLine, signalLine)
histExpanding  = math.abs(histLine) > math.abs(histLine[1]) and math.abs(histLine[1]) > math.abs(histLine[2])
macdMomentumUp = histLine > 0 and histExpanding

// ADX / DMI
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxRising     = adxVal > adxVal[1] and adxVal[1] > adxVal[2]
trendStrong   = adxVal > adxThresh
bullDirection = diPlus > diMinus

// Rate of Change
rocVal    = ta.roc(close, rocLen)
rocRising = rocVal > rocVal[1] and rocVal[1] > rocVal[2]

// Volume
volMA     = ta.sma(volume, volLen)
volSurge  = volume > volMA * volMultiple

// ═════════════════════════════════════════════════════════════════════════
// COMPOSITE MOMENTUM SCORE (-100 to +100)
// ═════════════════════════════════════════════════════════════════════════
bullVotes = 0.0
bearVotes = 0.0

bullVotes += (rsiRising and rsiVal > 50) ? 20 : 0
bearVotes += (not rsiRising and rsiVal < 50) ? 20 : 0

bullVotes += macdMomentumUp ? 30 : (macdBullCross ? 15 : 0)
bearVotes += (histLine < 0 and histExpanding) ? 30 : 0

bullVotes += (trendStrong and adxRising and bullDirection) ? 25 : 0
bearVotes += (trendStrong and adxRising and not bullDirection) ? 25 : 0

bullVotes += (rocRising and rocVal > 0) ? 15 : 0
bearVotes += (not rocRising and rocVal < 0) ? 15 : 0

volBonus = volSurge ? 10 : 0
bullVotes += (bullVotes > bearVotes) ? volBonus : 0
bearVotes += (bearVotes > bullVotes) ? volBonus : 0

momentumScore = bullVotes - bearVotes
smoothScore   = ta.ema(momentumScore, 2)

// ═════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ═════════════════════════════════════════════════════════════════════════
momentumBuilding = smoothScore >= scoreThreshBuild and smoothScore[1] < scoreThreshBuild
momentumFading   = smoothScore <= scoreThreshFade and smoothScore[1] > scoreThreshFade

stateText  = smoothScore >= scoreThreshBuild ? "BUILDING" :
             smoothScore <= scoreThreshFade  ? "FADING" :
             smoothScore > 0                 ? "MILD BULL" :
             smoothScore < 0                 ? "MILD BEAR" : "NEUTRAL"

stateColor = smoothScore >= scoreThreshBuild ? c_bull :
             smoothScore <= scoreThreshFade  ? c_bear :
             smoothScore > 0                 ? c_bull_dim :
             smoothScore < 0                 ? c_bear_dim : c_neutral

// ═════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION (regular bullish / bearish, oscillator = smoothScore)
// Draws a line directly on the oscillator pane connecting the two pivots
// whenever a divergence is confirmed.
// ═════════════════════════════════════════════════════════════════════════
plFound = not na(ta.pivotlow(smoothScore, divLbL, divLbR))
phFound = not na(ta.pivothigh(smoothScore, divLbL, divLbR))

// Track the most recent confirmed pivot low (oscillator value, price value, bar index)
var float prevPivLowVal   = na
var float prevPivLowPrice = na
var int   prevPivLowBar   = na

// Track the most recent confirmed pivot high (oscillator value, price value, bar index)
var float prevPivHighVal   = na
var float prevPivHighPrice = na
var int   prevPivHighBar   = na

curPivLowVal   = smoothScore[divLbR]
curPivLowPrice = low[divLbR]
curPivLowBar   = bar_index[divLbR]

curPivHighVal   = smoothScore[divLbR]
curPivHighPrice = high[divLbR]
curPivHighBar   = bar_index[divLbR]

bullDivCond = false
bearDivCond = false

// --- Regular Bullish: Oscillator Higher Low, Price Lower Low ---
if plFound
    if not na(prevPivLowBar)
        barsBetween = curPivLowBar - prevPivLowBar
        if barsBetween >= divRangeLower and barsBetween <= divRangeUpper
            oscHL   = curPivLowVal > prevPivLowVal
            priceLL = curPivLowPrice < prevPivLowPrice
            if showDiv and oscHL and priceLL
                bullDivCond := true
                line.new(x1=prevPivLowBar, y1=prevPivLowVal, x2=curPivLowBar, y2=curPivLowVal,
                     xloc=xloc.bar_index, color=bullDivColor, width=2, style=line.style_solid)
                if showDivLabels
                    label.new(x=curPivLowBar, y=curPivLowVal, text="Bull",
                         xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up,
                         color=bullDivColor, textcolor=c_text, size=size.tiny)
    prevPivLowVal   := curPivLowVal
    prevPivLowPrice := curPivLowPrice
    prevPivLowBar   := curPivLowBar

// --- Regular Bearish: Oscillator Lower High, Price Higher High ---
if phFound
    if not na(prevPivHighBar)
        barsBetween = curPivHighBar - prevPivHighBar
        if barsBetween >= divRangeLower and barsBetween <= divRangeUpper
            oscLH   = curPivHighVal < prevPivHighVal
            priceHH = curPivHighPrice > prevPivHighPrice
            if showDiv and oscLH and priceHH
                bearDivCond := true
                line.new(x1=prevPivHighBar, y1=prevPivHighVal, x2=curPivHighBar, y2=curPivHighVal,
                     xloc=xloc.bar_index, color=bearDivColor, width=2, style=line.style_solid)
                if showDivLabels
                    label.new(x=curPivHighBar, y=curPivHighVal, text="Bear",
                         xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down,
                         color=bearDivColor, textcolor=c_text, size=size.tiny)
    prevPivHighVal   := curPivHighVal
    prevPivHighPrice := curPivHighPrice
    prevPivHighBar   := curPivHighBar

// ═════════════════════════════════════════════════════════════════════════
// PLOTTING
// ═════════════════════════════════════════════════════════════════════════
var color lineColor = c_neutral
if smoothScore >= scoreThreshBuild
    lineColor := c_bull
else if smoothScore <= scoreThreshFade
    lineColor := c_bear
else if smoothScore > 0
    lineColor := color.new(c_bull, 35)
else
    lineColor := color.new(c_bear, 35)

scorePlot = plot(smoothScore, title="Momentum Score", color=lineColor, linewidth=3, style=plot.style_line)
zeroPlot  = plot(0, title="Zero", color=color.new(c_neutral, 60), linewidth=1, display=display.pane)

fill(scorePlot, zeroPlot, color=showFill ? (smoothScore >= 0 ? c_bull_dim : c_bear_dim) : na, title="Momentum Fill")

hline(scoreThreshBuild, "Build Threshold", color=color.new(c_bull, 55), linestyle=hline.style_dotted, linewidth=1)
hline(scoreThreshFade, "Fade Threshold", color=color.new(c_bear, 55), linestyle=hline.style_dotted, linewidth=1)
hline(0, "Zero Line", color=color.new(c_neutral, 40), linestyle=hline.style_solid, linewidth=1)

// plotshape() requires a compile-time constant "size" argument, so each marker
// size option gets its own call, gated by whether that size is selected.
plotshape(showSignals and momentumBuilding and markerSizeInput == "Tiny", title="Momentum Building (Tiny)",
     location=location.bottom, style=shape.triangleup, size=size.tiny, color=c_bull, text="▲", textcolor=c_bull)
plotshape(showSignals and momentumBuilding and markerSizeInput == "Small", title="Momentum Building (Small)",
     location=location.bottom, style=shape.triangleup, size=size.small, color=c_bull, text="▲", textcolor=c_bull)
plotshape(showSignals and momentumBuilding and markerSizeInput == "Normal", title="Momentum Building (Normal)",
     location=location.bottom, style=shape.triangleup, size=size.normal, color=c_bull, text="▲", textcolor=c_bull)
plotshape(showSignals and momentumBuilding and markerSizeInput == "Large", title="Momentum Building (Large)",
     location=location.bottom, style=shape.triangleup, size=size.large, color=c_bull, text="▲", textcolor=c_bull)

plotshape(showSignals and momentumFading and markerSizeInput == "Tiny", title="Momentum Fading (Tiny)",
     location=location.top, style=shape.triangledown, size=size.tiny, color=c_bear, text="▼", textcolor=c_bear)
plotshape(showSignals and momentumFading and markerSizeInput == "Small", title="Momentum Fading (Small)",
     location=location.top, style=shape.triangledown, size=size.small, color=c_bear, text="▼", textcolor=c_bear)
plotshape(showSignals and momentumFading and markerSizeInput == "Normal", title="Momentum Fading (Normal)",
     location=location.top, style=shape.triangledown, size=size.normal, color=c_bear, text="▼", textcolor=c_bear)
plotshape(showSignals and momentumFading and markerSizeInput == "Large", title="Momentum Fading (Large)",
     location=location.top, style=shape.triangledown, size=size.large, color=c_bear, text="▼", textcolor=c_bear)

bgcolor(showBg and momentumBuilding ? color.new(c_bull, 88) : na, title="Building BG")
bgcolor(showBg and momentumFading ? color.new(c_bear, 88) : na, title="Fading BG")

// ═════════════════════════════════════════════════════════════════════════
// DASHBOARD PANEL (position, colors, and compact mode are user-configurable)
// Compact Mode drops MACD Hist / ADX / ROC to keep the panel small and
// readable on phone screens; full mode shows everything.
// ═════════════════════════════════════════════════════════════════════════
var table dash = table.new(tablePosition, 2, 8, border_width=2, border_color=finalHeaderBg, frame_width=2, frame_color=finalHeaderBg)

if showDash and barstate.islast
    row = 0

    // Title row — uses configurable heading text/bg colors
    table.cell(dash, 0, row, "MOMENTUM", text_color=finalHeaderText, bgcolor=finalHeaderBg, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, stateText, text_color=valColor(stateColor), bgcolor=finalHeaderBg, text_size=dashSize, text_halign=text.align_right)
    row += 1

    // Score row (large, prominent)
    table.cell(dash, 0, row, "Score", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(math.round(smoothScore, 1)), text_color=valColor(stateColor), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
    row += 1

    // RSI
    table.cell(dash, 0, row, "RSI", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, str.tostring(math.round(rsiVal, 1)) + (rsiRising ? " ↑" : " ↓"),
         text_color=valColor(rsiRising ? c_bull : c_bear), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
    row += 1

    if not compactMode
        // MACD
        table.cell(dash, 0, row, "MACD Hist", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, row, str.tostring(math.round(histLine, 4)) + (macdMomentumUp ? " ↑" : ""),
             text_color=valColor(histLine > 0 ? c_bull : c_bear), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
        row += 1

        // ADX
        table.cell(dash, 0, row, "ADX", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, row, str.tostring(math.round(adxVal, 1)) + (trendStrong ? " strong" : " weak"),
             text_color=valColor(trendStrong ? c_amber : c_text_dim), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
        row += 1

        // ROC
        table.cell(dash, 0, row, "ROC", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, row, str.tostring(math.round(rocVal, 2)) + "%",
             text_color=valColor(rocVal > 0 ? c_bull : c_bear), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
        row += 1

    // Volume
    table.cell(dash, 0, row, "Volume", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, volSurge ? "SURGE" : "normal",
         text_color=valColor(volSurge ? c_amber : c_text_dim), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)
    row += 1

    // Trend direction
    table.cell(dash, 0, row, "Direction", text_color=finalRowLabel, bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, row, bullDirection ? "Bullish" : "Bearish",
         text_color=valColor(bullDirection ? c_bull : c_bear), bgcolor=finalPanelBg, text_size=dashSize, text_halign=text.align_right)

// ═════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════
alertcondition(momentumBuilding, title="Momentum Building", message="Momentum is building bullishly on {{ticker}} ({{interval}})")
alertcondition(momentumFading, title="Momentum Fading", message="Bullish momentum is fading on {{ticker}} ({{interval}})")
alertcondition(bullDivCond, title="Bullish Divergence", message="Bullish divergence detected on {{ticker}} ({{interval}})")
alertcondition(bearDivCond, title="Bearish Divergence", message="Bearish divergence detected on {{ticker}} ({{interval}})")
````
