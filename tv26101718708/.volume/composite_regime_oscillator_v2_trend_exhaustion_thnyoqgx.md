# Composite Regime Oscillator v2 - Trend Exhaustion

- url: https://www.tradingview.com/script/tHnYOQGX-Composite-Regime-Oscillator-v2-Trend-Exhaustion/
- type: indicator
- pine_id: PUB;3a389686607d44a3a2e7e01bfa6f7820
- version: 1.0

## Description

# 📊 Composite Regime Oscillator v2 - Trend Exhaustion

## Overview

The **Composite Regime Oscillator** is a sophisticated multi-factor indicator designed to identify **trend exhaustion** and predict **potential reversals or corrections** before they occur. Unlike traditional oscillators that simply measure overbought/oversold conditions, this indicator combines five distinct market dimensions to provide a holistic view of market regime and momentum health.

## 🎯 Core Purpose

**Identify when a trend is losing steam and a reversal or correction is likely on the way.**

## 🔬 Five Component Factors

The oscillator synthesizes five normalized scores (0-100 scale):

| Component | What It Measures | Signal Interpretation |
|-----------|-----------------|----------------------|
| **Regime Stress** | Market volatility, drawdown depth, and rebound intensity | High stress = exhaustion likely |
| **Stretch** | Price distance from EMA and range position | Extreme stretch = mean reversion pending |
| **Price Location** | Position within recent range and distance from extremes | Near lows = bullish reversal potential |
| **Overreaction** | RSI extremes combined with ATR deviation | Extreme readings = reversal warning |
| **Pressure** | Relative volume and volatility ratio | Divergences signal regime shifts |

## 📈 How to Read the Oscillator

### Zone Map

| Oscillator Value | Zone | Actionable Insight |
|-----------------|------|--------------------|
| **< 20** | 🔴 Extreme Oversold | **Bullish reversal expected** - Look for buy signals |
| **20 - 35** | 🟢 Exhaustion Zone | Trend weakening - Watch for bottoming patterns |
| **35 - 65** | ⚪ Neutral | No clear directional bias - Wait for confirmation |
| **65 - 80** | 🟡 Bullish Momentum (Caution) | Strong trend but stretched - Monitor for exhaustion |
| **> 80** | 🔴 Extreme Overbought | **Bearish reversal expected** - Look for sell signals |

### Signal Markers

| Icon | Signal | Meaning |
|------|--------|---------|
| 🔺 **BUY** | Bullish Reversal | Oversold condition - Reversal likely up |
| 🔻 **SELL** | Bearish Reversal | Overbought condition - Reversal likely down |
| 💎 **EXHAUSTED** | Trend Exhaustion | Current trend losing momentum |
| ⚠️ **WARNING** | Early Reversal Warning | Early indication of potential reversal |

## 🎨 Visual Elements

- **Histogram**: Green (bullish reversal potential) / Red (bearish reversal potential)
- **Colored Zones**: Background fills show current market regime at a glance
- **Info Table**: Real-time component scores displayed in top-right corner

## ⚙️ Key Input Parameters

### Weights (Adjust based on market preference)
- `wRegime` (1.0) - Market stress sensitivity
- `wStretch` (1.2) - Price extension importance
- `wLocation` (1.1) - Range position weighting
- `wOverreaction` (1.0) - RSI extreme sensitivity
- `wPressure` (0.8) - Volume/volatility emphasis

### Length Settings
- EMA Length (20)
- ATR Fast/Slow (14/50)
- Drawdown Lookback (60)
- Range Lookback (20)
- RSI Length (14)

## 🚦 Alert Conditions

The indicator generates alerts for:

1. **Bullish Reversal Expected** - Oversold condition detected
2. **Bearish Reversal Expected** - Overbought condition detected
3. **Trend Exhaustion** - Momentum fading signal
4. **Early Reversal Warning** - Pre-reversal divergence
5. **Extreme Oversold** - Deep value zone
6. **Extreme Overbought** - Extended rally zone

## 💡 Trading Strategy Applications

### For Mean Reversion Traders
- Enter longs when oscillator < 20 with bullish reversal signal
- Enter shorts when oscillator > 80 with bearish reversal signal

### For Trend Followers
- Exit longs when `EXHAUSTED` signal appears above 65
- Exit shorts when `EXHAUSTED` signal appears below 35

### For Scalpers
- Use WARNING signals for quick counter-trend moves
- Confirm with histogram divergence

## 🔧 Best Practices

1. **Use with Price Action**: Confirm signals with support/resistance levels
2. **Higher Timeframe Context**: Check oscillator on higher TF for trend bias
3. **Avoid Choppiness**: Oscillator works best in trending or clearly cyclical markets
4. **Adjust Weights**: Increase wStretch for volatile markets, wRegime for ranging markets

## 📊 Example Interpretation

**Scenario**: Oscillator drops to 15 (extreme oversold), bullishReversal histogram turns bright green, BUY signal appears.

**Interpretation**: Market is heavily oversold, reversal likely imminent. Consider long entries with stop below recent low.

**Scenario**: Oscillator rises to 85 (extreme overbought), bearishExhaustion histogram rises, SELL signal appears with WARNING.

**Interpretation**: Trend is exhausted at highs, correction or reversal probable. Consider profit-taking or short entries.

## ⚠️ Limitations

- Not a standalone system - use with other confirmation tools
- May give false signals in strongly trending markets
- Requires sufficient historical data for normalization
- Best suited for liquid instruments (forex, stocks, crypto majors)

## 🧠 Philosophy

The oscillator is built on the principle that **market extremes contain the seeds of their own reversal**. By measuring multiple dimensions of market stress, stretch, location, reaction, and pressure, it provides a composite view that is more robust than any single indicator.

---

**Version**: v2.0  
**Focus**: Trend Exhaustion & Reversal Detection  
**Compatible With**: Any liquid, non-constant chart (stocks, crypto, forex, futures)

## Source Code

````pine
//@version=6
indicator("Composite Regime Oscillator v2 - Trend Exhaustion", overlay=false, max_labels_count=500)

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

showSignals     = input.bool(true, "Show Signal Markers")
showHistogram   = input.bool(true, "Show Histogram")
smoothLen       = input.int(3, "Oscillator Smoothing", minval=1)

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
regimeStress = (na(atrRatio) or na(drawdown60) or na(rebound20)) ? 50.0 : regimeStress_raw

// 2) Stretch score
stretch_part1 = f_scale(distATR, 0.00, 2.80)
stretch_part2 = f_scale(rangePos20, 0.50, 1.00)

stretchScore_raw = 0.70 * stretch_part1 + 0.30 * stretch_part2
stretchScore = na(distATR) ? 50.0 : stretchScore_raw

// 3) Price-location score
location_part1 = f_scale(rangePos20, 0.00, 1.00)
location_part2 = f_scale(priceToLow20, 0.00, 0.10)
location_part3 = 100.0 - f_scale(priceToHigh20, 0.00, 0.08)

locationScore_raw = 0.60 * location_part1 + 0.25 * location_part2 + 0.15 * location_part3
locationScore = (na(priceToLow20) or na(priceToHigh20)) ? 50.0 : locationScore_raw

// 4) Overreaction score
overreaction_part1 = f_scale(rsiVal, 50.0, 80.0)
overreaction_part2 = f_scale(distATR, 0.50, 2.80)

overreactionScore_raw = 0.75 * overreaction_part1 + 0.25 * overreaction_part2
overreactionScore = na(rsiVal) ? 50.0 : overreactionScore_raw

// 5) Pressure score
pressure_part1 = f_scale(relVol, 0.80, 2.00)
pressure_part2 = f_scale(atrRatio, 1.00, 1.50)

pressureScore_raw = 0.70 * pressure_part1 + 0.30 * pressure_part2
pressureScore = na(relVol) ? 50.0 : pressureScore_raw

// =====================
// Composite oscillator
// =====================
weightedSum = regimeStress * wRegime + stretchScore * wStretch + locationScore * wLocation + overreactionScore * wOverreaction + pressureScore * wPressure

weightTotal = wRegime + wStretch + wLocation + wOverreaction + wPressure
rawOsc = weightTotal != 0 ? weightedSum / weightTotal : 50.0
osc = ta.ema(rawOsc, smoothLen)

// =====================
// Reversal Detection
// =====================
// Bearish reversal (top exhaustion) - HIGH momentum then collapse
bearishWashoutRaw = 0.35 * locationScore + 0.25 * overreactionScore + 0.20 * (100 - regimeStress) + 0.20 * pressureScore
bearishExhaustion = ta.ema(bearishWashoutRaw, smoothLen)

// Bullish reversal (bottom washout) - LOW values
bullishWashoutRaw = 0.35 * (100.0 - locationScore) + 0.25 * (100.0 - overreactionScore) + 0.20 * regimeStress + 0.20 * pressureScore
bullishReversal = ta.ema(bullishWashoutRaw, smoothLen)

// =====================
// Zones / regime flags
// =====================
extremeExhaustion   = osc < 20
strongExhaustion    = osc >= 20 and osc < 35
neutralZone         = osc >= 35 and osc < 65
bullishMomentum     = osc >= 65 and osc < 80
extremeMomentum     = osc >= 80

// Reversal signals
bearishReversalSignal = ta.crossunder(osc, 20) or (extremeMomentum and ta.falling(osc, 2))
bullishReversalSignal = ta.crossover(osc, 80) or (extremeExhaustion and ta.rising(osc, 2))

// Trend exhaustion detection
trendExhaustion = (bullishMomentum or extremeMomentum) and ta.falling(osc, 3)
reversalWarning = (extremeExhaustion and ta.rising(bullishReversal, 2)) or (extremeMomentum and ta.rising(bearishExhaustion, 2))

regimeText = extremeMomentum ? "⚠️ OVERBOUGHT - Pullback Expected" :
     bullishMomentum ? "📈 Bullish Trend (Caution)" :
     extremeExhaustion ? "✅ OVERSOLD - Reversal Expected" :
     strongExhaustion ? "📉 Weak / Exhausted" :
     neutralZone ? "➖ Neutral" : "Mixed"

// =====================
// Plots
// =====================
h0   = hline(0,   "0",   color=color.new(color.gray, 85))
h20  = hline(20,  "20",  color=color.new(color.red, 70))
h35  = hline(35,  "35",  color=color.new(color.orange, 70))
h65  = hline(65,  "65",  color=color.new(color.yellow, 70))
h80  = hline(80,  "80",  color=color.new(color.green, 70))
h100 = hline(100, "100", color=color.new(color.gray, 85))

fill(h0, h20, color=color.new(color.green, 85))
fill(h20, h35, color=color.new(color.lime, 88))
fill(h35, h65, color=color.new(color.gray, 92))
fill(h65, h80, color=color.new(color.orange, 85))
fill(h80, h100, color=color.new(color.red, 85))

oscColor = extremeMomentum ? color.red :
     bullishMomentum ? color.orange :
     extremeExhaustion ? color.green :
     strongExhaustion ? color.lime :
     color.silver

plot(osc, "Exhaustion Oscillator", color=oscColor, linewidth=3)
plot(showHistogram ? bullishReversal : na, "Bullish Reversal Potential", style=plot.style_histogram, linewidth=2, color=color.new(color.green, 45))
plot(showHistogram ? bearishExhaustion : na, "Bearish Reversal Potential", style=plot.style_histogram, linewidth=2, color=color.new(color.red, 45))

// =====================
// Signal markers
// =====================
plotshape(showSignals and bullishReversalSignal, title="Bullish Reversal Expected", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small, text="BUY")
plotshape(showSignals and bearishReversalSignal, title="Bearish Reversal Expected", style=shape.triangledown, location=location.top, color=color.red, size=size.small, text="SELL")
plotshape(showSignals and trendExhaustion, title="Trend Exhaustion", style=shape.diamond, location=location.top, color=color.orange, size=size.small, text="EXHAUSTED")
plotshape(showSignals and reversalWarning, title="Reversal Warning", style=shape.circle, location=location.top, color=color.purple, size=size.tiny, text="WARNING")

// =====================
// Table
// =====================
var table t = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 10))

if barstate.islast
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Regime Stress", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(regimeStress, "#.0"), text_color=color.white)

    table.cell(t, 0, 2, "Stretch", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(stretchScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 3, "Location", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(locationScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 4, "Overreaction", text_color=color.white)
    table.cell(t, 1, 4, str.tostring(overreactionScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 5, "Pressure", text_color=color.white)
    table.cell(t, 1, 5, str.tostring(pressureScore, "#.0"), text_color=color.white)

    table.cell(t, 0, 6, "Exhaustion Osc", text_color=color.white)
    table.cell(t, 1, 6, str.tostring(osc, "#.0"), text_color=color.white)
    
    table.cell(t, 0, 7, "Bullish Rev", text_color=color.white)
    table.cell(t, 1, 7, str.tostring(bullishReversal, "#.0"), text_color=color.white)
    
    table.cell(t, 0, 8, "Bearish Rev", text_color=color.white)
    table.cell(t, 1, 8, str.tostring(bearishExhaustion, "#.0"), text_color=color.white)
    
    table.cell(t, 0, 9, "Regime", text_color=color.white)
    table.cell(t, 1, 9, regimeText, text_color=color.white)

// =====================
// Alerts
// =====================
alertcondition(bullishReversalSignal, title="Bullish Reversal Expected", message="Oversold condition - Bullish reversal likely")
alertcondition(bearishReversalSignal, title="Bearish Reversal Expected", message="Overbought condition - Bearish reversal likely")
alertcondition(trendExhaustion, title="Trend Exhaustion", message="Trend showing exhaustion - Reversal or correction likely")
alertcondition(reversalWarning, title="Early Reversal Warning", message="Early warning of potential reversal")
alertcondition(extremeExhaustion, title="Extreme Oversold", message="Extreme oversold - Watch for bullish reversal")
alertcondition(extremeMomentum, title="Extreme Overbought", message="Extreme overbought - Watch for bearish reversal")
````
