# Mirror Dynamic Projection & Regime System

- url: https://www.tradingview.com/script/um0vUuMX/
- type: indicator
- pine_id: PUB;baf0b89796744a508e6086160381a82c
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 MIRROR DYNAMIC REGIME SYSTEM
(OBV + Dynamic Fibonacci + Market Structure Model)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ DISCLAIMER
This indicator is NOT a prediction tool.
All outputs are based on mathematical models using historical price, volume, and volatility data.

It does NOT guarantee future results and may produce false signals in certain market conditions.
Use at your own risk. This tool must NOT be used as the sole decision-making system for trading.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 SYSTEM LOGIC OVERVIEW

This system is built on 4 core components:

━━━━━━━━━━━━━━━━━━━━━━
1) MIRROR EMA STRUCTURE MODEL
━━━━━━━━━━━━━━━━━━━━━━
- EMA baseline:
  emaBase = EMA(close, length)

- Mirror transformation:
  mirror = (2 × EMA) - price

Purpose:
→ Creates a reflective market structure
→ Detects deviation from equilibrium
→ Helps identify trend displacement

━━━━━━━━━━━━━━━━━━━━━━
2) OBV MOMENTUM ENGINE
━━━━━━━━━━━━━━━━━━━━━━
- OBV measures volume pressure:
  + Volume on bullish candles
  - Volume on bearish candles

- Smoothed OBV delta is used to detect:
→ Buying pressure
→ Selling pressure
→ Momentum shifts

Purpose:
→ Adds volume confirmation to trend direction
→ Adjusts slope projection strength

━━━━━━━━━━━━━━━━━━━━━━
3) FORWARD PROJECTION MODEL
━━━━━━━━━━━━━━━━━━━━━━
- Trend slope:
  slope = EMA change × OBV influence

- Future projection:
  midFut = EMA + slope × projection length

Purpose:
→ Estimates forward market direction
→ Builds projected price structure

━━━━━━━━━━━━━━━━━━━━━━
4) DYNAMIC FIBONACCI RISK GRID
━━━━━━━━━━━━━━━━━━━━━━
Fibonacci is NOT used for retracement prediction.

It is used as a dynamic risk segmentation tool inside the projected band.

Band structure:
upperFut = projected resistance zone
lowerFut = projected support zone

Fib levels:
0.236 / 0.382 / 0.500 / 0.618 / 0.786

Formula:
fibLevel = lowerFut + (upperFut - lowerFut) × ratio

Purpose:
→ Market positioning classification
→ Risk distribution mapping
→ Overextension detection

━━━━━━━━━━━━━━━━━━━━━━
📊 RISK ZONE SYSTEM (CORE ENGINE)

Position inside band:

pos = (close - lowerFut) / (upperFut - lowerFut)

Zones:
🟢 0.0 – 0.4 → Low Risk / Accumulation
🟡 0.4 – 0.6 → Neutral / Decision Zone
🔴 0.6 – 1.0 → High Risk / Overheated Zone

━━━━━━━━━━━━━━━━━━━━━━
📌 SYSTEM OUTPUT

This indicator provides:
✔ Market trend structure (Mirror EMA)
✔ Volume-based momentum bias (OBV)
✔ Forward price projection
✔ Dynamic volatility-adjusted Fibonacci grid
✔ Market risk zoning (3-state classification)

━━━━━━━━━━━━━━━━━━━━━━
⚠️ FINAL NOTE

This system is a probabilistic market structure model.
It does NOT predict exact prices or guarantee outcomes.

Always combine with:
→ Risk management
→ Confirmation tools
→ Personal trading strategy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
END OF DESCRIPTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=5
indicator("Mirror EMA + OBV + Dynamic Fib Regime System", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━
len     = input.int(100, "Mirror Length")
projLen = input.int(28, "Forward Bars")

//━━━━━━━━━━━━━━━━━━━━━━
// MIRROR CORE
//━━━━━━━━━━━━━━━━━━━━━━
emaBase = ta.ema(close, len)
mirror  = emaBase * 2 - close

//━━━━━━━━━━━━━━━━━━━━━━
// OBV
//━━━━━━━━━━━━━━━━━━━━━━
obvChange = close > close[1] ? volume : close < close[1] ? -volume : 0
obv = ta.cum(obvChange)

obvDelta  = obv - obv[1]
obvSmooth = ta.sma(obvDelta, 20)

obvBias = ta.sma(obvDelta, 20)

//━━━━━━━━━━━━━━━━━━━━━━
// SLOPE
//━━━━━━━━━━━━━━━━━━━━━━
baseSlope = emaBase - emaBase[1]

//━━━━━━━━━━━━━━━━━━━━━━
// ATR + REGIME FACTORS
//━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(14)

squeezeFactor = atr / ta.sma(atr, 50)
trendFactor = math.abs(baseSlope) / atr

//━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC CENTER (OBV BIAS INCLUDED)
//━━━━━━━━━━━━━━━━━━━━━━
bias = obvBias * 0.00001
center = emaBase + bias

//━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC WIDTH
//━━━━━━━━━━━━━━━━━━━━━━
dynWidth = atr * (1 + trendFactor * 1.2) / (1 + squeezeFactor * 0.8)

upper = center + dynWidth
lower = center - dynWidth

//━━━━━━━━━━━━━━━━━━━━━━
// PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━
slope = baseSlope * (1 + (obvSmooth > 0 ? 0.2 : -0.2))

midNow = emaBase
midFut = emaBase + slope * projLen

upperFut = midFut + dynWidth
lowerFut = midFut - dynWidth

//━━━━━━━━━━━━━━━━━━━━━━
// FIB LEVELS (DYNAMIC GRID)
//━━━━━━━━━━━━━━━━━━━━━━
fib236 = lowerFut + (upperFut - lowerFut) * 0.236
fib382 = lowerFut + (upperFut - lowerFut) * 0.382
fib500 = lowerFut + (upperFut - lowerFut) * 0.5
fib618 = lowerFut + (upperFut - lowerFut) * 0.618
fib786 = lowerFut + (upperFut - lowerFut) * 0.786

//━━━━━━━━━━━━━━━━━━━━━━
// RISK SCORE (0–1)
//━━━━━━━━━━━━━━━━━━━━━━
bandRange = upperFut - lowerFut
pos = bandRange > 0 ? (close - lowerFut) / bandRange : 0.5
pos := math.max(0.0, math.min(1.0, pos))

zoneColor =
     pos <= 0.4 ? color.new(color.lime, 82) :
     pos <= 0.6 ? color.new(color.yellow, 82) :
                 color.new(color.red, 82)

//━━━━━━━━━━━━━━━━━━━━━━
// FORWARD BAND
//━━━━━━━━━━━━━━━━━━━━━━
pUpper = plot(upperFut, offset=projLen, display=display.none)
pLower = plot(lowerFut, offset=projLen, display=display.none)

fill(pUpper, pLower, color=zoneColor)

//━━━━━━━━━━━━━━━━━━━━━━
// FORWARD LINES (VISUAL STRUCTURE)
//━━━━━━━━━━━━━━━━━━━━━━
var line midLine = na
var line upLine  = na
var line lowLine = na

if bar_index > len
    line.delete(midLine)
    line.delete(upLine)
    line.delete(lowLine)

    midLine := line.new(bar_index, midNow, bar_index + projLen, midFut, color=color.white, width=2)
    upLine  := line.new(bar_index, upper, bar_index + projLen, upperFut, color=color.green)
    lowLine := line.new(bar_index, lower, bar_index + projLen, lowerFut, color=color.red)

//━━━━━━━━━━━━━━━━━━━━━━
// BASE VISUALS
//━━━━━━━━━━━━━━━━━━━━━━
plot(emaBase, color=color.gray)
plot(mirror, color=color.orange, linewidth=2)
````
