# Nifty Success Analyst Strategy V6 FINAL

- url: https://www.tradingview.com/script/8Pp6hhi0-Nifty-Success-Analyst-Strategy-V6-FINAL/
- type: indicator
- pine_id: PUB;f870055ea40b46a48ea4fc7190af1632
- version: 1.0

## Description

Muru's Nifty Success Analyst Strategy V6 FINAL

It will show entry and exit

## Source Code

````pine
//@version=6
indicator("Nifty Success Analyst Strategy V6 FINAL", overlay=true, max_labels_count=500)

// 1. Core Inputs
emaLength = input.int(20, title="EMA Length")
volMultiplier = input.float(1.5, title="Volume Spike Multiplier")
volLength = input.int(5, title="Volume Average Length")

// 2. Technical Indicators (V6 Logic)
ema20 = ta.ema(close, emaLength)
vwapVal = ta.vwap(close)
avgVol = ta.sma(volume, volLength)

// 3. Perfect Session-Based Daily Levels (Fixes the chart separation and shifting issues)
pdH = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdL = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
prevClose = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

// 4. Pivot Points (V6 Calculations)
pivotVal = (pdH + pdL + prevClose) / 3.0
r1 = (2.0 * pivotVal) - pdL
s1 = (2.0 * pivotVal) - pdH

// 5. Standard Plotting (Guarantees indicators stay ON the candles)
plot(ema20, color=color.blue, title="20 EMA", linewidth=2)
plot(vwapVal, color=color.orange, title="VWAP", linewidth=2)
plot(pdH, color=color.red, title="PDH", linewidth=1)
plot(pdL, color=color.green, title="PDL", linewidth=1)

// 6. Strict Candle & Volume Conditions
candleBody = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

isStrongGreen = (close > open) and (upperWick < candleBody * 0.4)
isStrongRed = (close < open) and (lowerWick < candleBody * 0.4)
volumeSpike = (volume > avgVol * volMultiplier)

// 10-point cushion check to prevent false breakouts near major key levels
notNearResistance = (pdH - close > 10.0) and (r1 - close > 10.0)
notNearSupport = (close - pdL > 10.0) and (close - s1 > 10.0)

// 7. Logic Triggers
buyCondition = (close > vwapVal) and (close > ema20) and isStrongGreen and volumeSpike and notNearResistance and (close > high[1])
sellCondition = (close < vwapVal) and (close < ema20) and isStrongRed and volumeSpike and notNearSupport and (close < low[1])

// 8. Visual Arrow Signals On Chart
plotshape(series=buyCondition, title="BUY Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal, text="BUY (CE)")
plotshape(series=sellCondition, title="SELL Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="SELL (PE)")

// 9. Alerts (V6 Structure)
alertcondition(condition=buyCondition, title="Nifty BUY Alert (CE)", message="BUY Call Option (CE) Match!")
alertcondition(condition=sellCondition, title="Nifty SELL Alert (PE)", message="BUY Put Option (PE) Match!")
````
