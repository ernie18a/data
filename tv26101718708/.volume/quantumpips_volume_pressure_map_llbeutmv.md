# QuantumPips Volume Pressure Map

- url: https://www.tradingview.com/script/llBEUTmV-QuantumPips-Volume-Pressure-Map/
- type: indicator
- pine_id: PUB;68d2914b12e54dc2b2b8b480885055c0
- version: 1.0

## Description

QuantumPips Volume Pressure Map is a custom volume-analysis tool built to help traders better understand the relationship between price movement, volume participation, and market pressure.

Instead of displaying standard volume alone, the indicator applies a pressure-based model that evaluates how volume behaves inside each candle structure. This allows traders to identify potential accumulation, distribution, imbalance, and absorption conditions directly from price and volume interaction.

The script is designed as a market context tool and works best alongside price action, structure analysis, support/resistance, liquidity zones, and trend analysis.

[b]Core Features
Volume Pressure Histogram[/b]

The main histogram dynamically colors volume bars based on:
• Relative volume strength
• Candle structure
• Pressure direction
• Market compression
• Volume imbalance behavior

This helps separate ordinary market activity from high-participation events where buyers or sellers may be more active.

[b]Smoothed Pressure Model[/b]

The indicator estimates bullish and bearish pressure using:
• Candle close position within the range
• Wick behavior
• Relative candle expansion
• Volume weighting

A smoothed pressure line is then calculated to help visualize directional pressure over time.

Positive pressure suggests stronger bullish participation.

Negative pressure suggests stronger bearish participation.

This is a proxy model and does not use true bid/ask order flow or exchange-level delta data.

[b]Smart Money Concepts Logic
Accumulation Detection[/b]

Accumulation conditions are highlighted when:
• Volume is elevated
• Price is compressing or ranging
• Pressure shifts bullish
• Lower-wick activity suggests buying response

These zones may indicate areas where market participation is increasing before expansion.

Accumulation markers are displayed using diamond markers.

[b]Distribution Detection[/b]

Distribution conditions are highlighted when:
• Volume remains elevated
• Market structure becomes compressed
• Pressure shifts bearish
• Upper-wick rejection increases

These conditions may indicate weakening bullish participation or potential sell-side pressure.

Distribution markers are also displayed using diamond markers.


[b]Volume Event Detection
Bullish / Bearish Imbalance[/b]

The script identifies directional volume imbalance when:
• Volume is significantly above baseline
• Candles close strongly near highs or lows
• Directional conviction increases

Bullish imbalance signals may suggest aggressive buying participation.

Bearish imbalance signals may suggest aggressive selling participation.


[b]Absorption Detection[/b]
Absorption signals attempt to identify situations where:
• Volume increases heavily
• Candle bodies remain relatively small
• Large rejection wicks appear

Bullish absorption focuses on strong lower-wick reactions.

Bearish absorption focuses on strong upper-wick reactions.

These conditions may highlight areas where liquidity is being absorbed despite strong participation.

[b]Dashboard Overview[/b]
The dashboard provides a quick summary of current market conditions:

[b]Vol Ratio[/b]
Shows current volume relative to the selected baseline average.

[b]Pressure[/b]
Displays whether the smoothed pressure model currently favors bullish or bearish conditions.

[b]Regime[/b]
Indicates whether the market is compressed or expanding.

[b]Signal[/b]
Displays the currently active event condition.

[b]CVD Bias[/b]
Compares cumulative pressure flow against its signal baseline.


[b]How To Use[/b]
QuantumPips Volume Pressure Map is intended to help traders read participation and market behavior more clearly.

It can be used to:
• Confirm breakout participation
• Identify possible accumulation or distribution zones
• Detect strong imbalance candles
• Spot potential absorption behavior
• Filter weak or low-participation setups
• Improve contextual trade analysis

The indicator is not designed to generate guaranteed entry or exit signals.

Best results are typically achieved when combined with:
• Market structure
• Trend analysis
• Support and resistance
• Session timing
• Risk management
• Multi-timeframe analysis

## Source Code

````pine
//@version=6
indicator("QuantumPips Volume Pressure Map", shorttitle="QP Volume Pressure", overlay=false, format=format.volume, max_labels_count=100)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────
grpVol = "Volume Engine"
volLen = input.int(20, "Volume Baseline Length", minval=1, group=grpVol)
highVolMult = input.float(1.5, "High Volume Multiplier", minval=1.0, step=0.1, group=grpVol)
extremeVolMult = input.float(2.5, "Extreme Volume Multiplier", minval=1.5, step=0.1, group=grpVol)

grpFlow = "Pressure / Delta Proxy"
showFlowLine = input.bool(true, "Show Smoothed Pressure Line", group=grpFlow)
flowSmoothLen = input.int(3, "Pressure Smoothing", minval=1, group=grpFlow)

grpRegime = "Accumulation / Distribution Logic"
showSmartMarks = input.bool(true, "Show Accumulation / Distribution", group=grpRegime)
structureLen = input.int(10, "Structure Lookback", minval=5, group=grpRegime)
compressionLimit = input.float(0.50, "Compression Sensitivity", minval=0.10, step=0.05, group=grpRegime)

grpSignals = "Volume Events"
showImpulseMarks = input.bool(true, "Show Volume Imbalance", group=grpSignals)
showAbsorptionMarks = input.bool(true, "Show Absorption", group=grpSignals)
bodyAbsorbMax = input.float(0.30, "Absorption Body Max %", minval=0.05, maxval=0.80, step=0.05, group=grpSignals)

grpPanel = "Dashboard"
showPanel = input.bool(true, "Show Dashboard", group=grpPanel)

grpColor = "Colors"
bullCol = input.color(color.new(#00E676, 0), "Bullish Pressure", group=grpColor)
bearCol = input.color(color.new(#FF5252, 0), "Bearish Pressure", group=grpColor)
baseCol = input.color(color.new(#9E9E9E, 55), "Neutral Volume", group=grpColor)
accCol = input.color(color.new(#00BCD4, 0), "Accumulation", group=grpColor)
distCol = input.color(color.new(#FF9800, 0), "Distribution", group=grpColor)
absorbBullCol = input.color(color.new(#64FFDA, 0), "Bullish Absorption", group=grpColor)
absorbBearCol = input.color(color.new(#FF8A80, 0), "Bearish Absorption", group=grpColor)

//────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────
f_safeDiv(a, b, fallback) =>
    b != 0.0 ? a / b : fallback

f_boolScore(condition, value) =>
    condition ? value : 0.0

//────────────────────────────────────────────
// Core Volume
//────────────────────────────────────────────
volBase = ta.sma(volume, volLen)
volRatio = f_safeDiv(volume, volBase, 0.0)

highVolume = volRatio >= highVolMult
extremeVolume = volRatio >= extremeVolMult

//────────────────────────────────────────────
// Candle Pressure Model
//────────────────────────────────────────────
barRange = math.max(high - low, syminfo.mintick)
barBody = math.abs(close - open)
bodyPct = barBody / barRange

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

closePos = (close - low) / barRange
wickBias = (lowerWick - upperWick) / barRange

rawPressure = volume * ((closePos - 0.50) * 2.0)
pressureAdjusted = rawPressure + (volume * wickBias * 0.30)
pressureSmooth = ta.ema(pressureAdjusted, flowSmoothLen)

cvdProxy = ta.cum(pressureAdjusted)
cvdSignal = ta.ema(cvdProxy, volLen)

//────────────────────────────────────────────
// Market Regime
//────────────────────────────────────────────
atr = ta.atr(14)
rangeHigh = ta.highest(high, structureLen)
rangeLow = ta.lowest(low, structureLen)
rangeWidth = rangeHigh - rangeLow

expectedRange = math.max(atr * structureLen, syminfo.mintick)
compressionRatio = rangeWidth / expectedRange
isCompressed = compressionRatio <= compressionLimit

//────────────────────────────────────────────
// Smart Pressure Scoring
//────────────────────────────────────────────
accumScore = 0.0
accumScore += f_boolScore(highVolume, 1.0)
accumScore += f_boolScore(isCompressed, 1.0)
accumScore += f_boolScore(pressureSmooth > 0, 1.0)
accumScore += f_boolScore(closePos >= 0.60, 0.5)
accumScore += f_boolScore(lowerWick > upperWick, 0.5)

distScore = 0.0
distScore += f_boolScore(highVolume, 1.0)
distScore += f_boolScore(isCompressed, 1.0)
distScore += f_boolScore(pressureSmooth < 0, 1.0)
distScore += f_boolScore(closePos <= 0.40, 0.5)
distScore += f_boolScore(upperWick > lowerWick, 0.5)

accumulation = showSmartMarks and highVolume and accumScore >= 3.0
distribution = showSmartMarks and highVolume and distScore >= 3.0

//────────────────────────────────────────────
// Imbalance + Absorption
//────────────────────────────────────────────
bullImbalance = showImpulseMarks and extremeVolume and close > open and closePos >= 0.70
bearImbalance = showImpulseMarks and extremeVolume and close < open and closePos <= 0.30

absorptionBase = highVolume and bodyPct <= bodyAbsorbMax
bullAbsorption = showAbsorptionMarks and absorptionBase and lowerWick > upperWick * 2.0
bearAbsorption = showAbsorptionMarks and absorptionBase and upperWick > lowerWick * 2.0

//────────────────────────────────────────────
// Histogram Color
//────────────────────────────────────────────
color volColor = baseCol

if accumulation
    volColor := accCol
else if distribution
    volColor := distCol
else if bullImbalance
    volColor := bullCol
else if bearImbalance
    volColor := bearCol
else if bullAbsorption
    volColor := absorbBullCol
else if bearAbsorption
    volColor := absorbBearCol
else if close > open
    volColor := highVolume ? bullCol : color.new(bullCol, 55)
else if close < open
    volColor := highVolume ? bearCol : color.new(bearCol, 55)
else
    volColor := baseCol

//────────────────────────────────────────────
// Plots
//────────────────────────────────────────────
plot(volume, "Volume Pressure Bars", style=plot.style_columns, color=volColor)
plot(volBase, "Volume Baseline", color=color.new(color.white, 35), linewidth=2)
plot(volBase * highVolMult, "High Volume Level", color=color.new(color.yellow, 65), linewidth=1)
plot(volBase * extremeVolMult, "Extreme Volume Level", color=color.new(color.orange, 70), linewidth=1)

pressurePlot = showFlowLine ? math.abs(pressureSmooth) : na
pressureColor = pressureSmooth >= 0 ? color.new(bullCol, 25) : color.new(bearCol, 25)
plot(pressurePlot, "Smoothed Pressure Proxy", style=plot.style_line, color=pressureColor, linewidth=2)

//────────────────────────────────────────────
// Signal Markers
//────────────────────────────────────────────
plotshape(accumulation, title="QP Accumulation", style=shape.diamond, location=location.top, color=accCol, size=size.tiny, text="A")
plotshape(distribution, title="QP Distribution", style=shape.diamond, location=location.top, color=distCol, size=size.tiny, text="D")

plotshape(bullImbalance, title="Bullish Volume Imbalance", style=shape.triangleup, location=location.bottom, color=bullCol, size=size.tiny)
plotshape(bearImbalance, title="Bearish Volume Imbalance", style=shape.triangledown, location=location.bottom, color=bearCol, size=size.tiny)

plotshape(bullAbsorption, title="Bullish Absorption", style=shape.circle, location=location.top, color=absorbBullCol, size=size.tiny)
plotshape(bearAbsorption, title="Bearish Absorption", style=shape.circle, location=location.top, color=absorbBearCol, size=size.tiny)

//────────────────────────────────────────────
// Dashboard
//────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 80), border_width=1)

signalText = accumulation ? "Accumulation" : distribution ? "Distribution" : bullAbsorption ? "Bull Absorb" : bearAbsorption ? "Bear Absorb" : bullImbalance ? "Bull Imbalance" : bearImbalance ? "Bear Imbalance" : "—"
signalColor = accumulation ? accCol : distribution ? distCol : bullAbsorption ? absorbBullCol : bearAbsorption ? absorbBearCol : bullImbalance ? bullCol : bearImbalance ? bearCol : color.white

regimeText = isCompressed ? "Compressed" : "Expanding"
regimeColor = isCompressed ? color.yellow : color.white

pressureText = pressureSmooth > 0 ? "Bullish" : pressureSmooth < 0 ? "Bearish" : "Neutral"
pressureTextColor = pressureSmooth > 0 ? bullCol : pressureSmooth < 0 ? bearCol : color.white

cvdText = cvdProxy > cvdSignal ? "Rising" : "Falling"
cvdColor = cvdProxy > cvdSignal ? bullCol : bearCol

if showPanel and barstate.islast
    table.cell(dash, 0, 0, "Vol Ratio", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, str.tostring(volRatio, "#.##") + "x", text_color=extremeVolume ? color.orange : highVolume ? color.lime : color.white, text_size=size.small)

    table.cell(dash, 0, 1, "Pressure", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, pressureText, text_color=pressureTextColor, text_size=size.small)

    table.cell(dash, 0, 2, "Regime", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, regimeText, text_color=regimeColor, text_size=size.small)

    table.cell(dash, 0, 3, "Signal", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, signalText, text_color=signalColor, text_size=size.small)

    table.cell(dash, 0, 4, "CVD Bias", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, cvdText, text_color=cvdColor, text_size=size.small)

//────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────
alertcondition(accumulation, title="QP Accumulation", message="QuantumPips Volume Pressure: Accumulation detected on {{ticker}}")
alertcondition(distribution, title="QP Distribution", message="QuantumPips Volume Pressure: Distribution detected on {{ticker}}")
alertcondition(bullImbalance, title="QP Bullish Imbalance", message="QuantumPips Volume Pressure: Bullish volume imbalance on {{ticker}}")
alertcondition(bearImbalance, title="QP Bearish Imbalance", message="QuantumPips Volume Pressure: Bearish volume imbalance on {{ticker}}")
alertcondition(bullAbsorption, title="QP Bullish Absorption", message="QuantumPips Volume Pressure: Bullish absorption detected on {{ticker}}")
alertcondition(bearAbsorption, title="QP Bearish Absorption", message="QuantumPips Volume Pressure: Bearish absorption detected on {{ticker}}")
````
