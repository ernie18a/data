# Equity-Debt Rebalance Signal v6

- url: https://www.tradingview.com/script/iOFLPUH4-Equity-Debt-Rebalance-Signal-v6/
- type: indicator
- pine_id: PUB;07cff971ea334cfa8c85148e79b3d604
- version: 1.0

## Description

For "Selling High": When the red triangle appears, look at your portfolio. If your Equity (e.g., VTI) has grown beyond your target (say 60%), sell the excess and move it to a US Debt fund like BND.

For "Buying Low": When the green triangle appears, it means the US market is "on sale" relative to its 200-day average. Use the cash/debt reserves you built up to buy more Equity.

## Source Code

````pine
//@version=6
indicator("Equity-Debt Rebalance Signal v6", overlay=true)

// --- Inputs ---
emaLen = input.int(200, "EMA Length", minval=1)
rsiLen = input.int(14, "RSI Length", minval=1)
rsiOB  = input.int(70, "RSI Overbought (Sell Equity)")
rsiOS  = input.int(30, "RSI Oversold (Buy Equity)")
extPct = input.float(10.0, "Price % above EMA to Sell", step=0.5)

// --- Calculations ---
emaVal = ta.ema(close, emaLen)
rsiVal = ta.rsi(close, rsiLen)

// Calculate % distance from 200 EMA
distFromEMA = ((close - emaVal) / emaVal) * 100

// --- Signal Logic ---
sellSignal = (distFromEMA >= extPct) and (rsiVal >= rsiOB)
buySignal = (close < emaVal) and (rsiVal <= rsiOS)

// --- Plotting ---
// Fixed style reference for v6
plot(emaVal, color=color.gray, title="200 EMA", linewidth=2)

// Visual "Take Profit" line - Changed style to a supported v6 constant
targetLine = emaVal * (1 + (extPct / 100))
plot(targetLine, color=color.new(color.red, 50), style=plot.style_linebr, title="Extension Zone")

// --- Shapes and Alerts ---
plotshape(sellSignal, title="REBALANCE: SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL EQUITY")
plotshape(buySignal, title="REBALANCE: BUY", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY EQUITY")

// Shading
bgcolor(sellSignal ? color.new(color.red, 90) : na)
bgcolor(buySignal ? color.new(color.green, 90) : na)
````
