# Composite Regime Oscillator v6 - Clean Confirmed Reversal

- url: https://www.tradingview.com/script/MTUM6ecT-Composite-Regime-Oscillator-v6-Clean-Confirmed-Reversal/
- type: indicator
- pine_id: PUB;c759e3739608406ca2a22e99955ec40a
- version: 1.0

## Description

Composite Regime Oscillator v6 – Clean Exhaustion Histogram

 Overview

This indicator detects **trend exhaustion** and highlights potential **reversal zones** using a multi-factor model.

Instead of relying on a single condition (like RSI), it combines:

[i]* volatility expansion
* price stretch from equilibrium
* range positioning
* momentum extremes
* volume / pressure[/i]

The goal is simple:

> identify when a move becomes unstable and more likely to[b] **reverse or pull back**[/b]

---

[b] What makes this indicator different[/b]

Most oscillators fail in strong trends — they call tops and bottoms too early.

This script solves that using:

[b]Setup + Trigger + Filter logic[/b]

* **Setup** → market is stretched / exhausted
* **Trigger** → price or momentum starts to turn
* **Filter** → strong trends are filtered (ADX + trend structure)

This prevents constant false signals during strong moves.

---

[b]Visual Signals (Clean System)[/b]

All signals are shape-based (no text clutter):

* ▲ Green triangle → confirmed bullish reversal
* ▼ Red triangle → confirmed bearish reversal
* ● Blue circle → bullish warning (early exhaustion)
* ● Purple circle → bearish warning (early exhaustion)
* ◆ Orange diamond → trend exhaustion / momentum cooling

---

[b]What the histogram shows

Green histogram (Bullish Exhaustion)[/b]

* downside pressure weakening
* panic / oversold conditions
* potential bottoming phase
[b]
 Red histogram (Bearish Exhaustion)[/b]

* upside pressure weakening
* overbought / euphoric conditions
* potential topping phase
[b]
Oscillator line[/b]

* low → washed out
* mid → neutral
* high → strong momentum / overheating

---

[b] How to use it[/b]

---

1. Confirmed Reversal Mode (ADX ON)

Best for:

* swing trading
* cleaner entries
* avoiding fake signals in strong trends

Signals appear only when:

* exhaustion is present
* reversal trigger appears
* trend starts weakening

👉 Interpretation:
**Not just stretched — trend is actually breaking**

2. Aggressive / Scalping Mode (ADX OFF)

Best for:

* scalping
* intraday trading
* early entries
* quick pullbacks

Signals appear earlier because:

* no trend filter
* no ADX restriction

👉 Interpretation:
**Market is stretched and likely to react (not always fully reverse)**

---

[b] Practical usage[/b]

Clean chart (recommended)

* Confirmed Signals = ON
* Warnings = OFF
* Exhaustion Markers = OFF

→ Only triangles → clean and focused

---

[b]Full context mode
[/b]
[i]* Confirmed Signals = ON
* Warnings = ON
* Exhaustion Markers = ON[/i]

→ See full market condition

---
[b]
 How to read the market

 Strong trend[/b]

* many warning circles
* few confirmed signals

→ trend still healthy

---
[b]
Weakening trend
[/b]
[i]* orange diamonds appear
* warnings reduce
* then triangle appears[/i]

→ higher probability reversal

---
[b]
Works best in[/b]

* extended trends
* volatility expansions
* emotional market phases

---
[b]
 Works worse in[/b]

* tight ranges
* low volatility chop
* slow grinding trends

---

Best used with

* support / resistance
* liquidity zones
* Keltner / Bollinger bands
* RSI divergence
* market structure breaks
* higher timeframe bias

---

[b]Summary

This indicator answers one question:

> **Is the trend still strong — or starting to break?**

* Triangles → confirmed reversals
* Circles → early warnings
* Diamonds → momentum fading

With ADX:
→ cleaner, slower, more reliable

Without ADX:
→ faster, noisier, more aggressive[/b]

 Final note

This is **not a trend-following indicator**.

It is designed for:

* exhaustion detection
* reversal timing
* identifying unstable price moves

Use it with context — not in isolation.

## Source Code

````pine
//@version=6
indicator("Composite Regime Oscillator v6 - Clean Confirmed Reversal", overlay=false, max_labels_count=500)

// =====================
// Inputs
// =====================
emaLen          = input.int(20, "EMA Length")
atrFastLen      = input.int(14, "ATR Fast Length")
atrSlowLen      = input.int(50, "ATR Slow Length")
drawdownLen     = input.int(60, "Drawdown Lookback")
rangeLen        = input.int(20, "Range Lookback")
rsiLen          = input.int(14, "RSI Length")
volLen          = input.int(20, "Volume Average Length")

wRegime         = input.float(1.0, "Weight: Regime", step=0.1)
wStretch        = input.float(1.2, "Weight: Stretch", step=0.1)
wLocation       = input.float(1.1, "Weight: Price Location", step=0.1)
wOverreaction   = input.float(1.0, "Weight: Overreaction", step=0.1)
wPressure       = input.float(0.8, "Weight: Pressure", step=0.1)

signalSmoothing         = input.int(5, "Signal Smoothing", minval=1, maxval=10)
smoothLen               = input.int(5, "Oscillator Smoothing", minval=1, maxval=10)
minExhaustionStrength   = input.int(60, "Min Exhaustion Strength", minval=40, maxval=90)
cooldownBars            = input.int(10, "Cooldown Bars Between Signals", minval=1, maxval=100)

useTriggerConfirmation  = input.bool(true, "Use Reversal Trigger Confirmation")
showHistogram           = input.bool(true, "Show Histogram")
showOscillator          = input.bool(true, "Show Oscillator")
showTable               = input.bool(true, "Show Table")
showDebugLines          = input.bool(true, "Show Threshold Lines")

// Visual toggles
showConfirmedSignals    = input.bool(true, "Show Confirmed Signals")
showWarnings            = input.bool(true, "Show Warning Markers")
showExhaustionMarkers   = input.bool(true, "Show Exhaustion Markers")

// New filters
adxLen                  = input.int(14, "ADX Length", minval=5, maxval=50)
adxThreshold            = input.float(25.0, "Strong Trend ADX Threshold", step=0.5)
adxCoolingBars          = input.int(3, "ADX Cooling Bars", minval=1, maxval=10)

emaFastTrendLen         = input.int(20, "Fast Trend EMA")
emaSlowTrendLen         = input.int(50, "Slow Trend EMA")
emaSlopeLen             = input.int(5, "EMA Slope Lookback", minval=1, maxval=20)

requireEMAReclaimLoss   = input.bool(true, "Require EMA20 Reclaim/Loss Confirmation")
requireADXCooling       = input.bool(true, "Require ADX Cooling In Strong Trend")

// =====================
// Core calculations
// =====================
ema20       = ta.ema(close, emaLen)
emaFast     = ta.ema(close, emaFastTrendLen)
emaSlow     = ta.ema(close, emaSlowTrendLen)

atrFast     = ta.atr(atrFastLen)
atrSlow     = ta.atr(atrSlowLen)
atrRatio    = atrSlow != 0 ? atrFast / atrSlow : na

highestDD   = ta.highest(high, drawdownLen)
drawdown60  = highestDD != 0 ? (highestDD - close) / highestDD : na

lowest20    = ta.lowest(low, rangeLen)
highest20   = ta.highest(high, rangeLen)
rangeDenom  = highest20 - lowest20

rebound20   = lowest20 != 0 ? (close - lowest20) / lowest20 : na
distATR     = atrFast != 0 ? (close - ema20) / atrFast : na
rangePos20  = rangeDenom != 0 ? (close - lowest20) / rangeDenom : 0.5
rsiVal      = ta.rsi(close, rsiLen)

volAvg      = ta.sma(volume, volLen)
relVol      = volAvg != 0 ? volume / volAvg : na

priceToLow20  = lowest20 != 0 ? (close - lowest20) / lowest20 : na
priceToHigh20 = highest20 != 0 ? (highest20 - close) / highest20 : na

// =====================
// ADX / Trend filters
// =====================
[diplus, diminus, adx] = ta.dmi(adxLen, adxLen)

emaSlope = emaFast - emaFast[emaSlopeLen]

strongUpTrend =
     close > emaFast and
     emaFast > emaSlow and
     emaSlope > 0

strongDownTrend =
     close < emaFast and
     emaFast < emaSlow and
     emaSlope < 0

strongTrend = adx > adxThreshold
adxCooling = ta.falling(adx, adxCoolingBars)
adxRising = ta.rising(adx, adxCoolingBars)

// =====================
// Normalization helpers
// =====================
f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _x))

f_scale(_x, _x0, _x1) =>
    _x1 == _x0 ? 50.0 : f_clamp((_x - _x0) / (_x1 - _x0), 0.0, 1.0) * 100.0

// =====================
// Component scores
// =====================

// 1) Regime stress score
regimeStress_part1 = f_scale(atrRatio,   1.00, 1.50)
regimeStress_part2 = f_scale(drawdown60, 0.00, 0.12)
regimeStress_part3 = f_scale(rebound20,  0.00, 0.10)

regimeStress_raw = 0.45 * regimeStress_part1 + 0.30 * regimeStress_part2 + 0.25 * regimeStress_part3
regimeStress = (na(atrRatio) or na(drawdown60) or na(rebound20)) ? 50.0 : ta.sma(regimeStress_raw, signalSmoothing)

// 2) Stretch score
stretch_part1 = f_scale(math.abs(distATR), 0.00, 2.80)
stretch_part2 = f_scale(math.abs(rangePos20 - 0.5), 0.00, 0.50)

stretchScore_raw = 0.70 * stretch_part1 + 0.30 * stretch_part2
stretchScore = na(distATR) ? 50.0 : ta.sma(stretchScore_raw, signalSmoothing)

// 3) Price-location score
location_part1 = f_scale(rangePos20, 0.00, 1.00)
location_part2 = f_scale(priceToLow20, 0.00, 0.10)
location_part3 = 100.0 - f_scale(priceToHigh20, 0.00, 0.08)

locationScore_raw = 0.60 * location_part1 + 0.25 * location_part2 + 0.15 * location_part3
locationScore = (na(priceToLow20) or na(priceToHigh20)) ? 50.0 : ta.sma(locationScore_raw, signalSmoothing)

// 4) Separate overreaction scores
overreactionBull_raw = 0.75 * f_scale(100 - rsiVal, 20.0, 50.0) + 0.25 * f_scale(-distATR, 0.50, 2.80)
overreactionBear_raw = 0.75 * f_scale(rsiVal, 50.0, 80.0) + 0.25 * f_scale(distATR, 0.50, 2.80)

overreactionBull = na(rsiVal) ? 50.0 : ta.sma(overreactionBull_raw, signalSmoothing)
overreactionBear = na(rsiVal) ? 50.0 : ta.sma(overreactionBear_raw, signalSmoothing)

// 5) Pressure score
pressure_part1 = f_scale(relVol, 0.80, 2.00)
pressure_part2 = f_scale(atrRatio, 1.00, 1.50)

pressureScore_raw = 0.70 * pressure_part1 + 0.30 * pressure_part2
pressureScore = na(relVol) ? 50.0 : ta.sma(pressureScore_raw, signalSmoothing)

// =====================
// Composite oscillator
// =====================
weightedSum = regimeStress * wRegime + stretchScore * wStretch + locationScore * wLocation + overreactionBear * wOverreaction + pressureScore * wPressure
weightTotal = wRegime + wStretch + wLocation + wOverreaction + wPressure
rawOsc = weightTotal != 0 ? weightedSum / weightTotal : 50.0
osc = ta.ema(rawOsc, smoothLen)

// =====================
// Exhaustion scores
// =====================
bullishExhaustion_raw =
     (100 - locationScore) * 0.35 +
     overreactionBull * 0.30 +
     regimeStress * 0.15 +
     pressureScore * 0.20

bearishExhaustion_raw =
     locationScore * 0.35 +
     overreactionBear * 0.30 +
     (100 - regimeStress) * 0.10 +
     pressureScore * 0.25

bullishExhaustion = ta.ema(bullishExhaustion_raw, smoothLen)
bearishExhaustion = ta.ema(bearishExhaustion_raw, smoothLen)

// =====================
// Setup conditions
// =====================
bullishSetup = bullishExhaustion >= minExhaustionStrength
bearishSetup = bearishExhaustion >= minExhaustionStrength

// =====================
// Confirmed reversal triggers
// =====================
bullPriceBreak = close > high[1]
bearPriceBreak = close < low[1]

bullReversalCandle = close > open and close[1] < open[1]
bearReversalCandle = close < open and close[1] > open[1]

bullRsiTurn = ta.crossover(rsiVal, 30)
bearRsiTurn = ta.crossunder(rsiVal, 70)

bullMomentumShift = ta.rising(close, 2)
bearMomentumShift = ta.falling(close, 2)

// EMA reclaim / loss confirmation
bullEMAConfirm = close > ema20 and close[1] <= ema20[1]
bearEMAConfirm = close < ema20 and close[1] >= ema20[1]

// Final trigger block
bullishTrigger =
     bullPriceBreak or
     bullReversalCandle or
     bullRsiTurn or
     bullMomentumShift

bearishTrigger =
     bearPriceBreak or
     bearReversalCandle or
     bearRsiTurn or
     bearMomentumShift

bullishConfirmedTrigger = bullishTrigger and (not requireEMAReclaimLoss or bullEMAConfirm or bullPriceBreak)
bearishConfirmedTrigger = bearishTrigger and (not requireEMAReclaimLoss or bearEMAConfirm or bearPriceBreak)

// =====================
// Strong trend blocking logic
// =====================
blockBearishSignal = strongUpTrend and strongTrend and (requireADXCooling ? not adxCooling : adxRising)
blockBullishSignal = strongDownTrend and strongTrend and (requireADXCooling ? not adxCooling : adxRising)

allowBearishSignal = not blockBearishSignal
allowBullishSignal = not blockBullishSignal

// =====================
// Final base signal logic
// =====================
finalBullBase = bullishSetup and (useTriggerConfirmation ? bullishConfirmedTrigger : true) and allowBullishSignal
finalBearBase = bearishSetup and (useTriggerConfirmation ? bearishConfirmedTrigger : true) and allowBearishSignal

// =====================
// Cooldown + one-shot signal control
// =====================
var int lastBullSignalBar = na
var int lastBearSignalBar = na

bullCooldownOk = na(lastBullSignalBar) or (bar_index - lastBullSignalBar > cooldownBars)
bearCooldownOk = na(lastBearSignalBar) or (bar_index - lastBearSignalBar > cooldownBars)

finalBullishSignal = finalBullBase and not finalBullBase[1] and bullCooldownOk
finalBearishSignal = finalBearBase and not finalBearBase[1] and bearCooldownOk

if finalBullishSignal
    lastBullSignalBar := bar_index

if finalBearishSignal
    lastBearSignalBar := bar_index

// =====================
// Secondary markers
// =====================
bullWarning = bullishSetup and not finalBullishSignal and blockBullishSignal
bearWarning = bearishSetup and not finalBearishSignal and blockBearishSignal

trendExhaustion =
     (bearishSetup and ta.falling(bearishExhaustion, 3) and osc > 65 and adxCooling) or
     (bullishSetup and ta.falling(bullishExhaustion, 3) and osc < 35 and adxCooling)

// =====================
// Regime zones
// =====================
extremeExhaustion   = osc < 15
strongExhaustion    = osc >= 15 and osc < 30
neutralZone         = osc >= 30 and osc < 70
bullishMomentum     = osc >= 70 and osc < 85
extremeMomentum     = osc >= 85

regimeText = extremeMomentum ? "Extreme Overbought" :
     bullishMomentum ? "Bullish (Caution)" :
     extremeExhaustion ? "Extreme Oversold" :
     strongExhaustion ? "Exhausted" :
     neutralZone ? "Neutral" : "Mixed"

// =====================
// Plots
// =====================
h0   = hline(showDebugLines ? 0 : na, "0", color=color.new(color.gray, 85))
h15  = hline(showDebugLines ? 15 : na, "15", color=color.new(color.green, 70))
h30  = hline(showDebugLines ? 30 : na, "30", color=color.new(color.lime, 70))
h50  = hline(showDebugLines ? 50 : na, "50", color=color.new(color.gray, 75))
h70  = hline(showDebugLines ? 70 : na, "70", color=color.new(color.orange, 70))
h85  = hline(showDebugLines ? 85 : na, "85", color=color.new(color.red, 70))
h100 = hline(showDebugLines ? 100 : na, "100", color=color.new(color.gray, 85))
hSig = hline(showDebugLines ? minExhaustionStrength : na, "Exhaustion Threshold", color=color.new(color.yellow, 0), linestyle=hline.style_dotted)

fill(h0, h15, color=color.new(color.green, 88))
fill(h15, h30, color=color.new(color.lime, 90))
fill(h30, h70, color=color.new(color.gray, 93))
fill(h70, h85, color=color.new(color.orange, 88))
fill(h85, h100, color=color.new(color.red, 88))

oscColor = extremeMomentum ? color.red :
     bullishMomentum ? color.orange :
     extremeExhaustion ? color.green :
     strongExhaustion ? color.lime :
     color.silver

plot(showOscillator ? osc : na, "Exhaustion Oscillator", color=oscColor, linewidth=3)

// Histogram
plot(showHistogram ? bullishExhaustion : na, "Bullish Exhaustion", style=plot.style_histogram, linewidth=3, color=color.new(color.lime, 40))
plot(showHistogram ? bearishExhaustion : na, "Bearish Exhaustion", style=plot.style_histogram, linewidth=3, color=color.new(color.red, 40))

plot(showHistogram ? bullishExhaustion : na, "Bullish Exhaustion Line", color=color.new(color.lime, 0), linewidth=1)
plot(showHistogram ? bearishExhaustion : na, "Bearish Exhaustion Line", color=color.new(color.red, 0), linewidth=1)

// =====================
// Signal markers - CLEAN VERSION
// =====================

// Main confirmed signals
plotshape(showConfirmedSignals and finalBullishSignal, title="Confirmed Bullish Reversal", style=shape.triangleup, location=location.bottom, color=color.new(color.lime, 0), size=size.small)
plotshape(showConfirmedSignals and finalBearishSignal, title="Confirmed Bearish Reversal", style=shape.triangledown, location=location.top, color=color.new(color.red, 0), size=size.small)

// Warning markers
plotshape(showWarnings and bullWarning, title="Bullish Warning", style=shape.circle, location=location.bottom, color=color.new(color.blue, 0), size=size.tiny)
plotshape(showWarnings and bearWarning, title="Bearish Warning", style=shape.circle, location=location.top, color=color.new(color.purple, 0), size=size.tiny)

// Exhaustion marker
plotshape(showExhaustionMarkers and trendExhaustion, title="Trend Exhaustion", style=shape.diamond, location=location.top, color=color.new(color.orange, 0), size=size.tiny)

// =====================
// Table
// =====================
var table t = table.new(position.top_right, 2, 14, bgcolor=color.new(color.black, 10))

if barstate.islast and showTable
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Bull Exhaustion", text_color=color.lime)
    table.cell(t, 1, 1, str.tostring(bullishExhaustion, "#.0"), text_color=color.lime)

    table.cell(t, 0, 2, "Bear Exhaustion", text_color=color.orange)
    table.cell(t, 1, 2, str.tostring(bearishExhaustion, "#.0"), text_color=color.orange)

    table.cell(t, 0, 3, "Oscillator", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(osc, "#.0"), text_color=color.white)

    table.cell(t, 0, 4, "ADX", text_color=color.white)
    table.cell(t, 1, 4, str.tostring(adx, "#.0"), text_color=adx > adxThreshold ? color.orange : color.white)

    table.cell(t, 0, 5, "ADX State", text_color=color.white)
    table.cell(t, 1, 5, adxCooling ? "Cooling" : adxRising ? "Rising" : "Flat", text_color=color.white)

    table.cell(t, 0, 6, "Trend", text_color=color.white)
    table.cell(t, 1, 6, strongUpTrend ? "Strong Up" : strongDownTrend ? "Strong Down" : "Mixed", text_color=color.white)

    table.cell(t, 0, 7, "Bull Setup", text_color=color.lime)
    table.cell(t, 1, 7, bullishSetup ? "YES" : "NO", text_color=bullishSetup ? color.lime : color.gray)

    table.cell(t, 0, 8, "Bear Setup", text_color=color.orange)
    table.cell(t, 1, 8, bearishSetup ? "YES" : "NO", text_color=bearishSetup ? color.orange : color.gray)

    table.cell(t, 0, 9, "Bull Allowed", text_color=color.lime)
    table.cell(t, 1, 9, allowBullishSignal ? "YES" : "BLOCKED", text_color=allowBullishSignal ? color.lime : color.red)

    table.cell(t, 0, 10, "Bear Allowed", text_color=color.orange)
    table.cell(t, 1, 10, allowBearishSignal ? "YES" : "BLOCKED", text_color=allowBearishSignal ? color.orange : color.red)

    table.cell(t, 0, 11, "EMA Confirm", text_color=color.white)
    table.cell(t, 1, 11, bullEMAConfirm ? "Bull" : bearEMAConfirm ? "Bear" : "None", text_color=color.white)

    signalState = finalBullishSignal ? "Bull Confirmed" : finalBearishSignal ? "Bear Confirmed" : bullWarning ? "Bull Warning" : bearWarning ? "Bear Warning" : trendExhaustion ? "Trend Exhaustion" : "None"
    signalColor = finalBullishSignal ? color.lime : finalBearishSignal ? color.red : bullWarning ? color.blue : bearWarning ? color.purple : trendExhaustion ? color.orange : color.gray

    table.cell(t, 0, 12, "Signal", text_color=color.white)
    table.cell(t, 1, 12, signalState, text_color=signalColor)

    table.cell(t, 0, 13, "Regime", text_color=color.white)
    table.cell(t, 1, 13, regimeText, text_color=color.white)

// =====================
// Alerts
// =====================
alertcondition(finalBullishSignal, title="Confirmed Bullish Reversal", message="Bullish exhaustion + confirmed reversal")
alertcondition(finalBearishSignal, title="Confirmed Bearish Reversal", message="Bearish exhaustion + confirmed reversal")
alertcondition(bullWarning, title="Bullish Warning", message="Bullish exhaustion detected but strong trend still blocks reversal")
alertcondition(bearWarning, title="Bearish Warning", message="Bearish exhaustion detected but strong trend still blocks reversal")
alertcondition(trendExhaustion, title="Trend Exhaustion", message="Trend momentum is cooling")
````
