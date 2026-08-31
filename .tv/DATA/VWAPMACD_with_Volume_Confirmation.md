<!-- tradingview-pine-id: PUB;d2ae20f3ee7e47e2ac0d05ceda0bb5af -->
<!-- tradingviewscripts-format: 1 -->
# VWAP-MACD with Volume Confirmation

Source: https://www.tradingview.com/script/pk3o1KDY-VWAP-MACD-with-Volume-Confirmation/

## Description

VWAP-MACD with Volume Confirmation 

VWAP-MACD+ replaces the price series inside a classic MACD calculation with an anchored VWAP series, then adds a volume-strength filter so that crossover signals are only flagged as "confirmed" when they occur on above-average volume. The result is a momentum oscillator that reflects shifts in the volume-weighted average price rather than raw closing price, with a built-in sanity check against low-conviction crosses.

How it works
Anchored VWAP — VWAP is calculated from hlc3 * volume, accumulated and reset at the start of each new period based on the selected anchor (Session, Week, or Month). This is the same anchoring logic as TradingView's native VWAP, just computed manually so it can feed into the MACD below.
VWAP-based MACD — instead of EMA-ing close like a standard MACD, this script EMAs the VWAP series itself (fast length default 12, slow length default 26). The difference between the fast and slow EMAs of VWAP is the MACD line; a further EMA of that (default 9) is the signal line; their difference is the histogram. Because VWAP is smoother and volume-weighted, the resulting MACD reacts to shifts in the "fair value" price rather than every tick of noise in the close.

Volume Momentum Filter — each bar's volume is compared to its moving average (default 20-period SMA) to get a relative volume ratio. Bars are classified as strong (≥1.5x average), weak (<0.75x average), or normal, and the histogram's color intensity reflects this — brighter columns mean the current move is backed by stronger volume, faded columns mean it's on thin volume.

Volume-Confirmed Crossovers — a standard MACD/signal-line crossover only becomes a plotted "confirmed" signal when relative volume is at or above average (≥1.0x). This is meant to filter out crossovers that happen on quiet, low-conviction bars.
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

Inputs
Fast Length / Slow Length / Signal Smoothing — EMA lengths for the VWAP-MACD calculation
VWAP Anchor Period — Session, Week, or Month
Volume MA Lookback — averaging period for the relative volume filter
Enable Volume Confirmation Shading — toggles both the histogram's volume-based color intensity and the volume requirement on confirmed crossover signals
Alerts

Two alert conditions are built in:

VWAP-MACD Bullish Cross (Vol Confirmed)
VWAP-MACD Bearish Cross (Vol Confirmed)

---

## Source Code

````pine
//@version=6
indicator("VWAP-MACD with Volume Confirmation", shorttitle="VWAP-MACD", overlay=false)

// ============================
// === INPUTS ===
// ============================
fastLength   = input.int(12, "Fast Length", minval=1)
slowLength   = input.int(26, "Slow Length", minval=1)
signalLength = input.int(9, "Signal Smoothing", minval=1)

vwapAnchor = input.string("Session", "VWAP Anchor Period", options=["Session", "Week", "Month"])

volLookback = input.int(20, "Volume MA Lookback (for confirmation)", minval=1)
useVolFilter = input.bool(true, "Enable Volume Confirmation Shading")

// ============================
// === VWAP CALCULATION ===
// ============================
// Anchor timeframe selection
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
// Instead of EMA(close), we EMA the VWAP series itself
fastMA = ta.ema(vwapValue, fastLength)
slowMA = ta.ema(vwapValue, slowLength)

macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, signalLength)
histLine   = macdLine - signalLine

// ============================
// === VOLUME MOMENTUM FILTER (Improvement) ===
// ============================
avgVol = ta.sma(volume, volLookback)
relVol = avgVol != 0 ? volume / avgVol : 1.0

// Classify strength of current bar's volume relative to average
strongVol   = relVol >= 1.5
weakVol     = relVol < 0.75
normalVol   = not strongVol and not weakVol

// Determine histogram color with volume-based intensity
histColor = histLine >= 0 ?
     (strongVol ? color.new(color.lime, 0)   : weakVol ? color.new(color.lime, 70) : color.new(color.lime, 40)) :
     (strongVol ? color.new(color.red, 0)    : weakVol ? color.new(color.red, 70)  : color.new(color.red, 40))

macdColor   = color.new(color.blue, 0)
signalColor = color.new(color.orange, 0)

// ============================
// === PLOTS ===
// ============================
plot(macdLine, title="VWAP-MACD Line", color=macdColor, linewidth=2)
plot(signalLine, title="Signal Line", color=signalColor, linewidth=1)
plot(histLine, title="Histogram", style=plot.style_columns, color=histColor)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// ============================
// === CROSSOVER SIGNALS (volume-confirmed only) ===
// ============================
bullCross = ta.crossover(macdLine, signalLine)
bearCross = ta.crossunder(macdLine, signalLine)

confirmedBull = bullCross and (not useVolFilter or relVol >= 1.0)
confirmedBear = bearCross and (not useVolFilter or relVol >= 1.0)

plotshape(confirmedBull, title="Confirmed Bull Cross", location=location.bottom, style=shape.triangleup, color=color.green, size=size.small)
plotshape(confirmedBear, title="Confirmed Bear Cross", location=location.top, style=shape.triangledown, color=color.red, size=size.small)

// ============================
// === ALERTS ===
// ============================
alertcondition(confirmedBull, title="VWAP-MACD Bullish Cross (Vol Confirmed)", message="VWAP-MACD bullish crossover with volume confirmation")
alertcondition(confirmedBear, title="VWAP-MACD Bearish Cross (Vol Confirmed)", message="VWAP-MACD bearish crossover with volume confirmation")
````
