# VWAP-MACD with Volume Confirmation

- url: https://www.tradingview.com/script/pk3o1KDY-VWAP-MACD-with-Volume-Confirmation/
- type: indicator
- pine_id: PUB;d2ae20f3ee7e47e2ac0d05ceda0bb5af
- version: 2.0

## Description

VWAP-MACD with Volume Confirmation 

VWAP-MACD+ replaces the price series inside a classic MACD calculation with an anchored VWAP series, then adds a volume-strength filter so that crossover signals are only flagged as "confirmed" when they occur on above-average volume. The result is a momentum oscillator that reflects shifts in the volume-weighted average price rather than raw closing price, with a built-in sanity check against low-conviction crosses.

[b]How it works[/b]
[b]Anchored VWAP[/b] — VWAP is calculated from hlc3 * volume, accumulated and reset at the start of each new period based on the selected anchor (Session, Week, or Month). This is the same anchoring logic as TradingView's native VWAP, just computed manually so it can feed into the MACD below.
VWAP-based MACD — instead of EMA-ing close like a standard MACD, this script EMAs the VWAP series itself (fast length default 12, slow length default 26). The difference between the fast and slow EMAs of VWAP is the MACD line; a further EMA of that (default 9) is the signal line; their difference is the histogram. Because VWAP is smoother and volume-weighted, the resulting MACD reacts to shifts in the "fair value" price rather than every tick of noise in the close.

[b]Volume Momentum Filter[/b] — each bar's volume is compared to its moving average (default 20-period SMA) to get a relative volume ratio. Bars are classified as strong (≥1.5x average), weak (<0.75x average), or normal, and the histogram's color intensity reflects this — brighter columns mean the current move is backed by stronger volume, faded columns mean it's on thin volume.

[b]Volume-Confirmed Crossovers[/b] — a standard MACD/signal-line crossover only becomes a plotted "confirmed" signal when relative volume is at or above average (≥1.0x). This is meant to filter out crossovers that happen on quiet, low-conviction bars.
Reading the indicator
Blue line — VWAP-based MACD line.
Orange line — signal line (EMA of the MACD line).
Histogram columns — MACD minus signal, colored green above zero / red below zero, with intensity scaled by relative volume (bright = strong volume, faded = weak volume, mid = normal).
Green up-triangle — bullish crossover confirmed by volume.
Red down-triangle — bearish crossover confirmed by volume.
Zero line — dashed gray reference; crosses of the MACD line through zero can also be used as a secondary trend-context read, though this script's plotted signals are specifically the signal-line crossovers.
Suggested use

This is a trend/momentum tool built around volume-weighted price rather than raw close, intended for:

Traders who already use VWAP as an intraday or swing fair-value reference and want a momentum oscillator derived from that same series instead of close price
Filtering out MACD crossovers that occur on low-volume, low-conviction bars by relying on the "confirmed" triangle markers rather than every raw crossover
Combining with the anchor period that matches your trading horizon — Session for intraday, Week or Month for swing/position context

As with any momentum oscillator, it works best alongside broader trend or structure context (e.g., higher-timeframe trend, support/resistance) rather than as a standalone signal — volume confirmation reduces noise but doesn't guarantee follow-through.

[b]Inputs[/b]
Fast Length / Slow Length / Signal Smoothing — EMA lengths for the VWAP-MACD calculation
VWAP Anchor Period — Session, Week, or Month
Volume MA Lookback — averaging period for the relative volume filter
Enable Volume Confirmation Shading — toggles both the histogram's volume-based color intensity and the volume requirement on confirmed crossover signals
Alerts

[b]Two alert conditions are built in:[/b]

VWAP-MACD Bullish Cross (Vol Confirmed)
VWAP-MACD Bearish Cross (Vol Confirmed)

## Source Code

````pine
//@version=6
indicator("VWAP-MACD with Volume Confirmation", shorttitle="VWAP-MACD", overlay=false)

// ============================
// === INPUTS: CORE ===
// ============================
fastLength   = input.int(12, "Fast Length", minval=1, group="Core")
slowLength   = input.int(26, "Slow Length", minval=1, group="Core")
signalLength = input.int(9, "Signal Smoothing", minval=1, group="Core")

vwapAnchor = input.string("Session", "VWAP Anchor Period", options=["Session", "Week", "Month"], group="Core")

volLookback  = input.int(20, "Volume MA Lookback (for confirmation)", minval=1, group="Core")
useVolFilter = input.bool(true, "Enable Volume Confirmation Shading", group="Core")

// ============================
// === INPUTS: STYLE ===
// ============================
useOG = input.bool(false, "Use OG (original) style", group="Style", tooltip="Reverts colors/plots to the original flat-color version with no gradient fill, no glow, and no divergence markers.")

macdColorIn    = input.color(#2962FF, "MACD Line Color", group="Style")
signalColorIn  = input.color(#FF9800, "Signal Line Color", group="Style")
bullColorIn    = input.color(#00E676, "Bullish Color", group="Style")
bearColorIn    = input.color(#FF1744, "Bearish Color", group="Style")
showFill       = input.bool(true, "Fill Between MACD & Signal", group="Style")
showGlow       = input.bool(true, "Glow on MACD/Signal Lines", group="Style")
showZeroBg     = input.bool(true, "Shade Zero-Line Bias Background", group="Style")

showDivergence = input.bool(true, "Show Bullish/Bearish Divergence", group="Improvements")
divLookbackL   = input.int(5, "Divergence Pivot Left Bars", minval=1, group="Improvements")
divLookbackR   = input.int(5, "Divergence Pivot Right Bars", minval=1, group="Improvements")
showRelVolTable = input.bool(true, "Show Volume Status Table", group="Improvements")

// ============================
// === VWAP CALCULATION ===
// ============================
anchorTimeframe = vwapAnchor == "Session" ? "D" : vwapAnchor == "Week" ? "W" : "M"
isNewPeriod = timeframe.change(anchorTimeframe)

vSrc = hlc3

var float cumVolPrice = 0.0
var float cumVol = 0.0

if isNewPeriod
    cumVolPrice := 0.0
    cumVol := 0.0

cumVolPrice += vSrc * volume
cumVol += volume

vwapValue = cumVol != 0 ? cumVolPrice / cumVol : vSrc

// ============================
// === VWAP-BASED MACD ===
// ============================
fastMA = ta.ema(vwapValue, fastLength)
slowMA = ta.ema(vwapValue, slowLength)

macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, signalLength)
histLine   = macdLine - signalLine

// ============================
// === VOLUME MOMENTUM FILTER ===
// ============================
avgVol = ta.sma(volume, volLookback)
relVol = avgVol != 0 ? volume / avgVol : 1.0

strongVol = relVol >= 1.5
weakVol   = relVol < 0.75
normalVol = not strongVol and not weakVol

// Histogram color: OG keeps flat lime/red, new style uses custom colors + rising/falling shade
histRising = histLine > histLine[1]

histColorOG = histLine >= 0 ?
     (strongVol ? color.new(color.lime, 0)   : weakVol ? color.new(color.lime, 70) : color.new(color.lime, 40)) :
     (strongVol ? color.new(color.red, 0)    : weakVol ? color.new(color.red, 70)  : color.new(color.red, 40))

histColorNew = histLine >= 0 ?
     (strongVol ? color.new(bullColorIn, histRising ? 0 : 25) : weakVol ? color.new(bullColorIn, 75) : color.new(bullColorIn, 45)) :
     (strongVol ? color.new(bearColorIn, histRising ? 25 : 0) : weakVol ? color.new(bearColorIn, 75) : color.new(bearColorIn, 45))

histColor   = useOG ? histColorOG : histColorNew
macdColor   = useOG ? color.new(color.blue, 0)   : macdColorIn
signalColor = useOG ? color.new(color.orange, 0) : signalColorIn

// ============================
// === PLOTS ===
// ============================
macdPlot   = plot(macdLine, title="VWAP-MACD Line", color=macdColor, linewidth=2)
signalPlot = plot(signalLine, title="Signal Line", color=signalColor, linewidth=1)
plot(histLine, title="Histogram", style=plot.style_columns, color=histColor)

// Soft glow effect (new style only) — a wider, more transparent line behind the main plot
plot(useOG or not showGlow ? na : macdLine, title="MACD Glow", color=color.new(macdColorIn, 80), linewidth=6)
plot(useOG or not showGlow ? na : signalLine, title="Signal Glow", color=color.new(signalColorIn, 85), linewidth=5)

fill(macdPlot, signalPlot, color = (useOG or not showFill) ? na : (macdLine >= signalLine ? color.new(bullColorIn, 85) : color.new(bearColorIn, 85)), title="MACD/Signal Fill")

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
bgcolor(useOG or not showZeroBg ? na : (macdLine >= 0 ? color.new(bullColorIn, 93) : color.new(bearColorIn, 93)), title="Zero-Bias Background")

// ============================
// === CROSSOVER SIGNALS (volume-confirmed only) ===
// ============================
bullCross = ta.crossover(macdLine, signalLine)
bearCross = ta.crossunder(macdLine, signalLine)

confirmedBull = bullCross and (not useVolFilter or relVol >= 1.0)
confirmedBear = bearCross and (not useVolFilter or relVol >= 1.0)

plotshape(confirmedBull, title="Confirmed Bull Cross", location=location.bottom, style=shape.triangleup, color=useOG ? color.green : bullColorIn, size=size.small)
plotshape(confirmedBear, title="Confirmed Bear Cross", location=location.top, style=shape.triangledown, color=useOG ? color.red : bearColorIn, size=size.small)

// ============================
// === DIVERGENCE (Improvement) ===
// ============================
// Lines/labels are drawn with explicit bar_index + price coordinates (xloc.bar_index),
// so they stay pinned to the exact pivot bars and rescale correctly with the pane
// on zoom/resize — no plotshape offset drift.
priceLow  = ta.pivotlow(low, divLookbackL, divLookbackR)
priceHigh = ta.pivothigh(high, divLookbackL, divLookbackR)

var int   lastLowBar    = na
var float lastLowPrice  = na
var float lastLowHist   = na

var int   lastHighBar   = na
var float lastHighPrice = na
var float lastHighHist  = na

var line[]  divLines  = array.new_line()
var label[] divLabels = array.new_label()

maxDivMarkers = 20

f_trimDivMarkers() =>
    if array.size(divLines) > maxDivMarkers
        line.delete(array.shift(divLines))
    if array.size(divLabels) > maxDivMarkers
        label.delete(array.shift(divLabels))

if not na(priceLow)
    pivotBar    = bar_index - divLookbackR
    histAtPivot = histLine[divLookbackR]

    if showDivergence and not useOG and not na(lastLowPrice) and priceLow < lastLowPrice and histAtPivot > lastLowHist
        newLine = line.new(x1=lastLowBar, y1=lastLowHist, x2=pivotBar, y2=histAtPivot, xloc=xloc.bar_index, color=bullColorIn, width=2, style=line.style_solid)
        newLabel = label.new(x=pivotBar, y=histAtPivot, text="Bull Div", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(bullColorIn, 0), textcolor=color.white, size=size.small)
        array.push(divLines, newLine)
        array.push(divLabels, newLabel)
        f_trimDivMarkers()

    lastLowBar   := pivotBar
    lastLowPrice := priceLow
    lastLowHist  := histAtPivot

if not na(priceHigh)
    pivotBarH    = bar_index - divLookbackR
    histAtPivotH = histLine[divLookbackR]

    if showDivergence and not useOG and not na(lastHighPrice) and priceHigh > lastHighPrice and histAtPivotH < lastHighHist
        newLineH = line.new(x1=lastHighBar, y1=lastHighHist, x2=pivotBarH, y2=histAtPivotH, xloc=xloc.bar_index, color=bearColorIn, width=2, style=line.style_solid)
        newLabelH = label.new(x=pivotBarH, y=histAtPivotH, text="Bear Div", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(bearColorIn, 0), textcolor=color.white, size=size.small)
        array.push(divLines, newLineH)
        array.push(divLabels, newLabelH)
        f_trimDivMarkers()

    lastHighBar   := pivotBarH
    lastHighPrice := priceHigh
    lastHighHist  := histAtPivotH

// ============================
// === VOLUME STATUS TABLE (Improvement) ===
// ============================
var table statusTable = table.new(position.top_right, 2, 2, border_width=1)

if showRelVolTable and not useOG and barstate.islast
    volState = strongVol ? "Strong" : weakVol ? "Weak" : "Normal"
    volStateColor = strongVol ? bullColorIn : weakVol ? bearColorIn : color.gray
    table.cell(statusTable, 0, 0, "Rel. Volume", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(statusTable, 1, 0, str.tostring(relVol, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(statusTable, 0, 1, "State", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(statusTable, 1, 1, volState, text_color=volStateColor, bgcolor=color.new(color.black, 20))

// ============================
// === ALERTS ===
// ============================
alertcondition(confirmedBull, title="VWAP-MACD Bullish Cross (Vol Confirmed)", message="VWAP-MACD bullish crossover with volume confirmation")
alertcondition(confirmedBear, title="VWAP-MACD Bearish Cross (Vol Confirmed)", message="VWAP-MACD bearish crossover with volume confirmation")
````
