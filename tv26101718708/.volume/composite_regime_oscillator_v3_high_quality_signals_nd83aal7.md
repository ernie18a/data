# Composite Regime Oscillator v3 - High Quality Signals

- url: https://www.tradingview.com/script/Nd83AAL7-Composite-Regime-Oscillator-v3-High-Quality-Signals/
- type: indicator
- pine_id: PUB;3f4f5f4703ec44e4b66de935673c41c3
- version: 3.0

## Description

📊 Composite Regime Oscillator v3 - High Quality Signals
Complete User Guide & Description
📖 OVERVIEW
The Composite Regime Oscillator v3 is a high-conviction reversal detection system that filters out market noise and false signals by requiring multiple independent confirmations before generating trading signals. Unlike traditional oscillators that trigger on every minor price swing, this indicator only signals when market conditions reach extreme levels with volume and trend confirmation.

Version 3 specifically addresses the "random walk" problem by implementing a scoring system, bar confirmations, volume filters, and trend context requirements.
The indicator combines six independent confirmation layers:

Layer	What It Confirms
1. Price Extreme	Oscillator oversold/overbought (<15 or >85)
2. Washout Score	Composite of 5 factors showing exhaustion
3. Volume Signature	Capitulation (bottoms) or exhaustion (tops)
4. Trend Context	Price position relative to 50/100 SMA
5. RSI Extreme	Traditional overbought/oversold confirmation
6. Persistence	Signal must last multiple bars
100 ─────────────────────────────────────────────────────
 85 ─────────── 🟥 EXTREME OVERBOUGHT ────────── Red Zone
 70 ─────────── 🟧 BULLISH (Caution) ─────────── Orange
 30 ─────────── ⬜ NEUTRAL ────────────────────── Gray
 15 ─────────── 🟩 EXHAUSTED ──────────────────── Light Green
  0 ─────────── 🟩 EXTREME OVERSOLD ───────────── Dark Green
📈 HOW TO USE - STEP BY STEP
Step 1: Set Up the Indicator
Copy the complete v3 script into TradingView Pine Editor and add to your chart.

Recommended Timeframes:

Day Trading: 15min, 30min, 1hr

Swing Trading: 4hr, Daily

Position Trading: Daily, Weekly

Step 2: Configure Settings for Your Trading Style
🟢 CONSERVATIVE SETTINGS (Fewest signals, highest accuracy)
Signal Smoothing: 8
Min Signal Strength: 25
Confirmation Bars: 3
Require Volume Confirmation: ON
Require Trend Confirmation: ON
Oscillator Smoothing: 8

🟡MODERATE SETTINGS 
Signal Smoothing: 5
Min Signal Strength: 20
Confirmation Bars: 2
Require Volume Confirmation: ON
Require Trend Confirmation: ON
Oscillator Smoothing: 5

## Source Code

````pine
//@version=6
indicator("Composite Regime Oscillator v4 - Exhaustion Histogram", overlay=false, max_labels_count=500)

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
showSignals             = input.bool(true, "Show Signal Markers")
showHistogram           = input.bool(true, "Show Histogram")
showTable               = input.bool(true, "Show Table")
showOscillator          = input.bool(true, "Show Oscillator")
showDebugLines          = input.bool(true, "Show Threshold Lines")

// =====================
// Core calculations
// =====================
ema20       = ta.ema(close, emaLen)
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

// Optional contextual filters still kept
ema100 = ta.ema(close, 100)
trendDirection = ema100 > ema100[5] ? 1 : -1
volumeSpike = relVol > 1.5
volumeCapitulation = relVol > 2.0 and close < close[1]
volumeExhaustion = relVol > 1.8 and close > close[1]

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

// 2) Stretch score (fixed: now measures both upside and downside stretch)
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

// 4) Overreaction scores (fixed: separate bull vs bear)
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
// Exhaustion scores (fixed logic)
// =====================

// Bottom setup: depressed price + panic/oversold + pressure
bullishExhaustion_raw =
     (100 - locationScore) * 0.35 +
     overreactionBull * 0.30 +
     regimeStress * 0.15 +
     pressureScore * 0.20

// Top setup: elevated price + euphoric/overbought + pressure
bearishExhaustion_raw =
     locationScore * 0.35 +
     overreactionBear * 0.30 +
     (100 - regimeStress) * 0.10 +
     pressureScore * 0.25

bullishExhaustion = ta.ema(bullishExhaustion_raw, smoothLen)
bearishExhaustion = ta.ema(bearishExhaustion_raw, smoothLen)

// =====================
// Reversal triggers
// =====================
bullishTrigger =
     close > high[1] or
     (close > open and close[1] < open[1]) or
     ta.crossover(rsiVal, 30) or
     ta.rising(close, 2)

bearishTrigger =
     close < low[1] or
     (close < open and close[1] > open[1]) or
     ta.crossunder(rsiVal, 70) or
     ta.falling(close, 2)

// =====================
// Setup + trigger logic
// =====================
bullishSetup = bullishExhaustion >= minExhaustionStrength
bearishSetup = bearishExhaustion >= minExhaustionStrength

finalBullBase = bullishSetup and (useTriggerConfirmation ? bullishTrigger : true)
finalBearBase = bearishSetup and (useTriggerConfirmation ? bearishTrigger : true)

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
// Additional regime flags
// =====================
trendExhaustion =
     (bearishSetup and ta.falling(bearishExhaustion, 3) and osc > 65) or
     (bullishSetup and ta.falling(bullishExhaustion, 3) and osc < 35)

earlyWarning =
     (bearishExhaustion > (minExhaustionStrength - 10) and overreactionBear > 60) or
     (bullishExhaustion > (minExhaustionStrength - 10) and overreactionBull > 60)

extremeExhaustion   = osc < 15
strongExhaustion    = osc >= 15 and osc < 30
neutralZone         = osc >= 30 and osc < 70
bullishMomentum     = osc >= 70 and osc < 85
extremeMomentum     = osc >= 85

regimeText = extremeMomentum ? "⚠️ EXTREME OVERBOUGHT" :
     bullishMomentum ? "📈 Bullish (Caution)" :
     extremeExhaustion ? "✅ EXTREME OVERSOLD" :
     strongExhaustion ? "📉 Exhausted" :
     neutralZone ? "➖ Neutral" : "Mixed"

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

// Histogram stays in pane
plot(showHistogram ? bullishExhaustion : na, "Bullish Exhaustion", style=plot.style_histogram, linewidth=3, color=color.new(color.lime, 40))
plot(showHistogram ? bearishExhaustion : na, "Bearish Exhaustion", style=plot.style_histogram, linewidth=3, color=color.new(color.red, 40))

// Optional thin lines for reading easier
plot(showHistogram ? bullishExhaustion : na, "Bullish Exhaustion Line", color=color.new(color.lime, 0), linewidth=1)
plot(showHistogram ? bearishExhaustion : na, "Bearish Exhaustion Line", color=color.new(color.red, 0), linewidth=1)

// =====================
// Signal markers in pane
// =====================
plotshape(showSignals and finalBullishSignal, title="BOTTOM", style=shape.triangleup, location=location.bottom, color=color.new(color.lime, 0), size=size.small, text="BUY", textcolor=color.black)
plotshape(showSignals and finalBearishSignal, title="TOP", style=shape.triangledown, location=location.top, color=color.new(color.orange, 0), size=size.small, text="SELL", textcolor=color.black)
plotshape(showSignals and trendExhaustion, title="Trend Exhaustion", style=shape.diamond, location=location.top, color=color.new(color.orange, 0), size=size.tiny, text="EX")
plotshape(showSignals and earlyWarning, title="Early Warning", style=shape.circle, location=location.top, color=color.new(color.purple, 0), size=size.tiny, text="W")

// =====================
// Table
// =====================
var table t = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 10))

if barstate.islast and showTable
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Regime Stress", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(regimeStress, "#.0"), text_color=color.white)

    table.cell(t, 0, 2, "Stretch", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(stretchScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 3, "Location", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(locationScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 4, "Bull Exhaustion", text_color=color.lime)
    table.cell(t, 1, 4, str.tostring(bullishExhaustion, "#.0"), text_color=color.lime)

    table.cell(t, 0, 5, "Bear Exhaustion", text_color=color.orange)
    table.cell(t, 1, 5, str.tostring(bearishExhaustion, "#.0"), text_color=color.orange)

    table.cell(t, 0, 6, "Oscillator", text_color=color.white)
    table.cell(t, 1, 6, str.tostring(osc, "#.0"), text_color=color.white)

    table.cell(t, 0, 7, "Bull Setup", text_color=color.lime)
    table.cell(t, 1, 7, bullishSetup ? "YES" : "NO", text_color=bullishSetup ? color.lime : color.gray)

    table.cell(t, 0, 8, "Bear Setup", text_color=color.orange)
    table.cell(t, 1, 8, bearishSetup ? "YES" : "NO", text_color=bearishSetup ? color.orange : color.gray)

    table.cell(t, 0, 9, "Trend", text_color=color.white)
    table.cell(t, 1, 9, trendDirection == 1 ? "UPTREND" : "DOWNTREND", text_color=color.white)

    table.cell(t, 0, 10, "Volume", text_color=color.white)
    table.cell(t, 1, 10, volumeSpike ? "SPIKE" : "Normal", text_color=color.white)

    table.cell(t, 0, 11, "Regime", text_color=color.white)
    table.cell(t, 1, 11, finalBullishSignal ? "🔺 BOTTOM" : finalBearishSignal ? "🔻 TOP" : regimeText, text_color=color.white)

// =====================
// Alerts
// =====================
alertcondition(finalBullishSignal, title="🔥 BULLISH EXHAUSTION", message="Downtrend exhausted - Bottom detected")
alertcondition(finalBearishSignal, title="⚠️ BEARISH EXHAUSTION", message="Uptrend exhausted - Top detected")
alertcondition(trendExhaustion, title="⚠️ Trend Exhaustion", message="Trend losing momentum - reversal risk rising")
alertcondition(earlyWarning, title="🔔 Early Warning", message="Early exhaustion conditions developing")
````
