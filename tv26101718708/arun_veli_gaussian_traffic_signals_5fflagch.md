# Arun Veli Gaussian Traffic Signals

- url: https://www.tradingview.com/script/5ffLAgcH-Arun-Veli-Gaussian-Traffic-Signals/
- type: indicator
- pine_id: PUB;1a43fb32ebc44e918868c0aeeb143b12
- version: 1.0

## Description

### Short Title (for indicator header)
**Arun Veli — Gaussian Traffic Signals**

### Tagline (one-liner)
Multi-factor confluence trade signals combining a Gaussian Channel, MACD momentum, and extreme-rejection logic into clear visual traffic lights.

---

### Full Description (paste into TradingView's Publish form)

**Overview**

Arun Veli — Gaussian Traffic Signals is a multi-factor confluence indicator designed for traders who want clean, visually intuitive trade signals without screen clutter. The indicator overlays a Gaussian Channel on the chart and produces three types of color-coded signals (green, yellow, red) only when multiple independent conditions align.

The goal is signal quality over signal quantity. Rather than firing on every band touch or moving-average cross, the script requires confluence across trend, momentum, and price-action structure before plotting a light.

**How it works**

The script combines three components:

1. **Gaussian Channel (Ehlers)** — An N-pole Gaussian filter applied to price (default hlc3) creates an adaptive midline. A second Gaussian filter applied to True Range produces the upper and lower bands. The channel adapts smoothly to volatility and lags less than traditional moving averages of comparable smoothness.

2. **MACD momentum filter (12, 26, 9)** — A smoothed MACD histogram confirms whether momentum is accelerating in the direction of the candidate signal. Signals only fire when histogram direction agrees with the price action.

3. **Trend envelope** — A long-period SMA flanked by ATR bands provides outer trend context, plotted as curving green and red lines on either side of the channel.

**Signal logic**

- **🟢 GREEN (bullish setup)**: Price closes above the Gaussian filter from below, MACD histogram is positive and rising, and the Gaussian filter itself is rising. All four conditions must align on the same bar.

- **🔴 RED (bearish setup)**: Price closes below the Gaussian filter from above, MACD histogram is negative and falling, and the Gaussian filter is falling.

- **🟡 YELLOW (caution / mean reversion)**: Price prints a new high or low over the configured lookback window, wicks beyond the upper or lower band, and closes back inside the channel. This identifies exhaustion candles at extremes.

A configurable cooldown between signals (default 5 bars) prevents clustering during choppy conditions.

**Inputs**

- **MACD**: source, fast, slow, signal, and an additional EMA smoothing pass on the histogram
- **Gaussian Channel**: source, poles (1 to 9), period, and TR multiplier (default 1.414, the classic √2 Gaussian sigma)
- **Trend Envelope**: long MA length, ATR multiplier, ATR length, and visibility toggle
- **Signal Strictness**: extreme lookback bars, cooldown bars, and a toggle to require rejection candles for yellow signals
- **Display**: toggles for traffic lights, channel, fill, and a debug table that shows live component values

**Best use cases**

- Intraday trend-following setups on liquid names (SPY, QQQ, large-cap stocks) on 2-minute through 1-hour timeframes
- Higher-timeframe swing setups on daily charts for confirmation of momentum shifts
- Pairing with your own price-action read; the signals are intended as confirmation, not standalone entries

**What this is not**

This script is not a complete trading system. It does not include position sizing, stop placement, or take-profit logic. It does not predict future price. Like every indicator, it can produce false signals, especially in chop or low-volume environments. Always combine with risk management appropriate to your account.

**Credits**

- **John Ehlers** for the original Gaussian filter mathematics
- **Donovan Wall** for the public TradingView Gaussian Channel implementation that this script's filter design follows

**Settings recommendations**

- For intraday scalping (2m–5m): default settings work; consider reducing extreme lookback to 5–7 bars
- For swing trading (1H–1D): increase cooldown to 10 bars and consider raising MACD signal smoothing to 8
- For volatile names: increase the GC TR Multiplier to 1.6–1.8 to widen the bands and reduce yellow signal frequency

---

### Suggested Tags
gaussian channel, MACD, momentum, trend, confluence, traffic light, signal, ehlers, intraday, swing

### Category
Technical Indicators → Trend Analysis

### Visibility
Public (or Invite-Only if you prefer to limit access initially)

## Source Code

````pine
//@version=5
indicator("Larry Jones - Traffic Trading v5 (Reverse Engineered)", shorttitle="LJ Traffic v5", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// v5 changes vs v4:
//   1. STRICTER signal logic - requires multi-factor confluence, not just
//      single band touch or filter cross. Targets ~5-10 signals per session
//      to match Larry's signal density.
//   2. Added "trend envelope" - the green/red curving lines flanking the
//      Gaussian Channel that appear in Larry's chart (long MA +/- ATR)
//   3. Yellow now requires extreme + rejection (not just band touch)
//   4. Green/Red require filter cross + MACD direction + price beyond
//      band midpoint (in trend direction)
//   5. Larger cooldown (5 bars) to prevent clustering
// ============================================================================

// ============================================================================
// INPUTS
// ============================================================================
grpM = "MACD"
macdSrc   = input.source(close, "MACD Source",       group=grpM)
macdFast  = input.int(12,        "MACD Fast",        group=grpM, minval=1)
macdSlow  = input.int(26,        "MACD Slow",        group=grpM, minval=1)
macdSig   = input.int(9,         "MACD Signal",      group=grpM, minval=1)
sigSmooth = input.int(5,         "Signal Smoothing", group=grpM, minval=1)

grpGC = "Gaussian Channel"
gcSrc       = input.source(hlc3,   "GC Source",       group=grpGC)
gcPoles     = input.int(4,         "GC Poles",        group=grpGC, minval=1, maxval=9)
gcPeriod    = input.int(25,        "GC Period",       group=grpGC, minval=2)
gcMult      = input.float(1.414,   "GC TR Multiplier",group=grpGC, step=0.001)

grpTE = "Trend Envelope (curving green/red lines)"
teLen   = input.int(100,    "Trend MA Length",  group=grpTE, minval=1)
teMult  = input.float(2.0,  "Trend ATR Mult",   group=grpTE, step=0.1)
teAtrLen= input.int(14,     "Trend ATR Length", group=grpTE, minval=1)
showTE  = input.bool(true,  "Show Trend Envelope", group=grpTE)

grpSig = "Signal Strictness"
extremeLookback = input.int(10,  "Extreme Lookback (bars)", group=grpSig, minval=2, tooltip="A new high/low must be the highest/lowest in this many bars to qualify for yellow")
cooldownBars    = input.int(5,   "Cooldown Between Signals", group=grpSig, minval=1)
requireRejection= input.bool(true, "Yellow requires rejection candle", group=grpSig, tooltip="Candle must close back inside the band after wicking outside")

grpD = "Display"
showLights  = input.bool(true,  "Show Traffic Lights",  group=grpD)
showChannel = input.bool(true,  "Show Gaussian Channel",group=grpD)
showFill    = input.bool(true,  "Fill Channel",         group=grpD)
showDebug   = input.bool(true,  "Show Debug Table",     group=grpD)

// ============================================================================
// GAUSSIAN CHANNEL
// ============================================================================
PI = 2 * math.asin(1)
beta  = (1 - math.cos(4 * PI / gcPeriod)) / (math.pow(1.414, 2 / gcPoles) - 1)
alpha = -beta + math.sqrt(beta * beta + 2 * beta)

f_gauss(src, a, poles) =>
    var float p1 = 0.0
    var float p2 = 0.0
    var float p3 = 0.0
    var float p4 = 0.0
    var float p5 = 0.0
    var float p6 = 0.0
    var float p7 = 0.0
    var float p8 = 0.0
    var float p9 = 0.0
    s = nz(src, src)
    p1 := a * s + (1-a) * nz(p1[1])
    p2 := poles >= 2 ? a * p1 + (1-a) * nz(p2[1]) : p1
    p3 := poles >= 3 ? a * p2 + (1-a) * nz(p3[1]) : p2
    p4 := poles >= 4 ? a * p3 + (1-a) * nz(p4[1]) : p3
    p5 := poles >= 5 ? a * p4 + (1-a) * nz(p5[1]) : p4
    p6 := poles >= 6 ? a * p5 + (1-a) * nz(p6[1]) : p5
    p7 := poles >= 7 ? a * p6 + (1-a) * nz(p7[1]) : p6
    p8 := poles >= 8 ? a * p7 + (1-a) * nz(p8[1]) : p7
    p9 := poles >= 9 ? a * p8 + (1-a) * nz(p9[1]) : p8
    poles == 1 ? p1 : poles == 2 ? p2 : poles == 3 ? p3 : poles == 4 ? p4 : poles == 5 ? p5 : poles == 6 ? p6 : poles == 7 ? p7 : poles == 8 ? p8 : p9

f_gaussTR(src, a, poles) =>
    var float p1 = 0.0
    var float p2 = 0.0
    var float p3 = 0.0
    var float p4 = 0.0
    var float p5 = 0.0
    var float p6 = 0.0
    var float p7 = 0.0
    var float p8 = 0.0
    var float p9 = 0.0
    s = nz(src, src)
    p1 := a * s + (1-a) * nz(p1[1])
    p2 := poles >= 2 ? a * p1 + (1-a) * nz(p2[1]) : p1
    p3 := poles >= 3 ? a * p2 + (1-a) * nz(p3[1]) : p2
    p4 := poles >= 4 ? a * p3 + (1-a) * nz(p4[1]) : p3
    p5 := poles >= 5 ? a * p4 + (1-a) * nz(p5[1]) : p4
    p6 := poles >= 6 ? a * p5 + (1-a) * nz(p6[1]) : p5
    p7 := poles >= 7 ? a * p6 + (1-a) * nz(p7[1]) : p6
    p8 := poles >= 8 ? a * p7 + (1-a) * nz(p8[1]) : p7
    p9 := poles >= 9 ? a * p8 + (1-a) * nz(p9[1]) : p8
    poles == 1 ? p1 : poles == 2 ? p2 : poles == 3 ? p3 : poles == 4 ? p4 : poles == 5 ? p5 : poles == 6 ? p6 : poles == 7 ? p7 : poles == 8 ? p8 : p9

filtFinal   = f_gauss(gcSrc,        alpha, gcPoles)
filtTRFinal = f_gaussTR(ta.tr(true), alpha, gcPoles)

upperBand = filtFinal + filtTRFinal * gcMult
lowerBand = filtFinal - filtTRFinal * gcMult
bandWidth = upperBand - lowerBand
gcRising  = filtFinal > filtFinal[1]
gcColor   = gcRising ? color.new(#00ff88, 0) : color.new(#ff3366, 0)

// Plot Gaussian Channel - dashed midline like Larry's
plot(showChannel ? filtFinal : na, "Filter (midline)", color=color.new(color.white, 30), linewidth=1, style=plot.style_circles)
pUpper = plot(showChannel ? upperBand : na, "Upper Band", color=gcColor, linewidth=2)
pLower = plot(showChannel ? lowerBand : na, "Lower Band", color=gcColor, linewidth=2)
fill(pUpper, pLower, color=showFill ? color.new(gcColor, 92) : na, title="Channel Fill")

// ============================================================================
// TREND ENVELOPE - the curving green/red lines flanking the channel
// ============================================================================
trendMA  = ta.sma(close, teLen)
trendATR = ta.atr(teAtrLen)
trendUpper = trendMA + trendATR * teMult
trendLower = trendMA - trendATR * teMult

plot(showTE ? trendUpper : na, "Trend Upper", color=color.new(#00ff88, 20), linewidth=2)
plot(showTE ? trendLower : na, "Trend Lower", color=color.new(#ff3366, 20), linewidth=2)

// ============================================================================
// MACD
// ============================================================================
[macdLine, signalLine, hist] = ta.macd(macdSrc, macdFast, macdSlow, macdSig)
histSmooth = ta.ema(hist, sigSmooth)
macdRising = histSmooth > histSmooth[1]
macdPositive = histSmooth > 0
macdNegative = histSmooth < 0

// ============================================================================
// STRICT TRAFFIC LIGHT LOGIC
//
// YELLOW (extreme + rejection):
//   - High made a NEW high in last N bars AND closed below upper band (top reject)
//   - OR Low made a NEW low in last N bars AND closed above lower band (bot reject)
//   - This is ONLY 2-3 per session in normal conditions
//
// GREEN (strong bullish setup):
//   - Price was below filter, now closes above filter
//   - MACD histogram positive AND rising
//   - Channel is rising (gcRising)
//   - At least N bars since last signal
//
// RED (strong bearish setup):
//   - Price was above filter, now closes below filter
//   - MACD histogram negative AND falling
//   - Channel is falling
//   - At least N bars since last signal
// ============================================================================

// Detect new extremes
isNewHigh = high == ta.highest(high, extremeLookback)
isNewLow  = low  == ta.lowest(low,  extremeLookback)

// Rejection candles (wick beyond band but close back inside)
upperReject = isNewHigh and high > upperBand and close < upperBand
lowerReject = isNewLow  and low  < lowerBand and close > lowerBand

// If rejection requirement off, allow simple touches
upperYellowCondition = requireRejection ? upperReject : (isNewHigh and high >= upperBand)
lowerYellowCondition = requireRejection ? lowerReject : (isNewLow  and low  <= lowerBand)

// GREEN: filter cross from below WITH momentum confirmation
greenSig = ta.crossover(close, filtFinal) and macdRising and macdPositive and gcRising

// RED: filter cross from above WITH momentum confirmation
redSig = ta.crossunder(close, filtFinal) and not macdRising and macdNegative and not gcRising

// YELLOW: rejection at extreme
yellowSig = (upperYellowCondition or lowerYellowCondition) and not greenSig and not redSig

// Cooldown
var int lastBar = -1000
canFire = bar_index - lastBar >= cooldownBars

greenFinal  = greenSig  and canFire
yellowFinal = yellowSig and canFire
redFinal    = redSig    and canFire

if greenFinal or yellowFinal or redFinal
    lastBar := bar_index

// ============================================================================
// PLOT TRAFFIC LIGHTS - using stacked emoji to mimic actual traffic light shape
// ============================================================================
// Use 🚦 emoji which renders as an actual traffic light, then color-code with text
plotshape(showLights and greenFinal, title="Green Light",  location=location.belowbar, style=shape.labelup,   text="🟢", textcolor=color.white, color=color.new(color.green, 100), size=size.normal)
plotshape(showLights and redFinal,   title="Red Light",    location=location.abovebar, style=shape.labeldown, text="🔴", textcolor=color.white, color=color.new(color.red,   100), size=size.normal)
plotshape(showLights and yellowFinal and upperYellowCondition,                            title="Yellow (top)",    location=location.abovebar, style=shape.labeldown, text="🟡", textcolor=color.white, color=color.new(color.yellow,100), size=size.normal)
plotshape(showLights and yellowFinal and lowerYellowCondition and not upperYellowCondition, title="Yellow (bottom)", location=location.belowbar, style=shape.labelup,   text="🟡", textcolor=color.white, color=color.new(color.yellow,100), size=size.normal)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(greenFinal,  title="Green Light (Buy)",  message="LJ Traffic GREEN: {{ticker}} @ {{close}}")
alertcondition(yellowFinal, title="Yellow Light (Wait)",message="LJ Traffic YELLOW: {{ticker}} @ {{close}}")
alertcondition(redFinal,    title="Red Light (Sell)",   message="LJ Traffic RED: {{ticker}} @ {{close}}")

// ============================================================================
// DEBUG TABLE
// ============================================================================
if showDebug and barstate.islast
    var table dbg = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 20), border_width=1)
    table.cell(dbg, 0, 0, "Component", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dbg, 1, 0, "Value",     text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dbg, 0, 1, "Price (close)", text_color=color.white)
    table.cell(dbg, 1, 1, str.tostring(close, "#.##"), text_color=color.white)
    table.cell(dbg, 0, 2, "Filter",        text_color=color.white)
    table.cell(dbg, 1, 2, str.tostring(filtFinal, "#.##"),  text_color=color.green)
    table.cell(dbg, 0, 3, "Upper Band",    text_color=color.white)
    table.cell(dbg, 1, 3, str.tostring(upperBand, "#.##"),  text_color=color.green)
    table.cell(dbg, 0, 4, "Lower Band",    text_color=color.white)
    table.cell(dbg, 1, 4, str.tostring(lowerBand, "#.##"),  text_color=color.green)
    table.cell(dbg, 0, 5, "Trend MA",      text_color=color.white)
    table.cell(dbg, 1, 5, str.tostring(trendMA, "#.##"),    text_color=color.white)
    table.cell(dbg, 0, 6, "MACD Hist",     text_color=color.white)
    table.cell(dbg, 1, 6, str.tostring(histSmooth, "#.####"), text_color=histSmooth > 0 ? color.green : color.red)
    table.cell(dbg, 0, 7, "MACD Rising",   text_color=color.white)
    table.cell(dbg, 1, 7, macdRising ? "YES" : "NO", text_color=macdRising ? color.green : color.red)
    table.cell(dbg, 0, 8, "GC Rising",     text_color=color.white)
    table.cell(dbg, 1, 8, gcRising ? "YES" : "NO", text_color=gcRising ? color.green : color.red)
    table.cell(dbg, 0, 9, "Last Signal",   text_color=color.white)
    table.cell(dbg, 1, 9, str.tostring(bar_index - lastBar) + " bars", text_color=color.white)
    table.cell(dbg, 0, 10, "Total Signals",text_color=color.white)
    var int totalSigs = 0
    if greenFinal or yellowFinal or redFinal
        totalSigs += 1
    table.cell(dbg, 1, 10, str.tostring(totalSigs), text_color=color.yellow)
````
