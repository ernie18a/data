# XAUUSD Family Bollinger Scalper

- url: https://www.tradingview.com/script/bIjrCSBf-XAUUSD-Family-Bollinger-Scalper/
- type: indicator
- pine_id: PUB;a8b39684f84c46ffb2931c603a8c1faa
- version: 1.0

## Description

XAUUSD Family Bollinger Scalper

Professional scalping indicator for Gold (XAUUSD) based on Bollinger Bands and Keltner Channel squeeze strategy.

Key Features:
• Detects volatility squeeze periods
• Clear BUY and SELL breakout signals
• Clean chart with background squeeze highlight
• Built-in dashboard for quick overview

Best used on 5m and 15m timeframes.

Designed for serious traders looking for high-probability scalping setups on XAUUSD.

Enjoy and trade responsibly.

## Source Code

````pine
//@version=6
indicator("XAUUSD Family Bollinger Scalper", shorttitle="Family Bollinger", overlay=true, max_bars_back=500)

// Inputs
bbLength = input.int(20, "Bollinger Length", minval=10)
bbDev   = input.float(2.0, "Bollinger Deviation", minval=0.5)
kcMult  = input.float(1.5, "Keltner Multiplier", minval=0.5)

// Calculations
basis   = ta.sma(close, bbLength)
dev     = bbDev * ta.stdev(close, bbLength)
upperBB = basis + dev
lowerBB = basis - dev

kcBasis = ta.ema(close, bbLength)
kcRange = kcMult * ta.atr(10)
upperKC = kcBasis + kcRange
lowerKC = kcBasis - kcRange

squeeze = upperBB < upperKC and lowerBB > lowerKC

// Signals
longCondition  = ta.crossover(close, upperKC) and squeeze[1]
shortCondition = ta.crossunder(close, lowerKC) and squeeze[1]

// Plots
plot(upperBB, color=#2962FF, title="Upper BB")
plot(lowerBB, color=#2962FF, title="Lower BB")
plot(basis,   color=color.white, title="Basis", linewidth=2)

plot(upperKC, color=#FF5252, title="Upper KC")
plot(lowerKC, color=#FF5252, title="Lower KC")

plotshape(longCondition,  title="Buy",  location=location.belowbar, color=#00E676, style=shape.triangleup,   size=size.large, text="BUY")
plotshape(shortCondition, title="Sell", location=location.abovebar, color=#FF5252, style=shape.triangledown, size=size.large, text="SELL")

// Background
bgcolor(squeeze ? color.new(#F57F17, 90) : na, title="Squeeze")

// Dashboard
var table t = table.new(position.top_right, 1, 3, bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(t, 0, 0, "XAUUSD Family Bollinger Scalper", text_color = color.yellow)
    table.cell(t, 0, 1, "Squeeze: " + (squeeze ? "YES" : "NO"), text_color = squeeze ? #F57F17 : color.white)
    table.cell(t, 0, 2, "Signal: " + (longCondition ? "BUY" : shortCondition ? "SELL" : "WAIT"), text_color = longCondition ? #00E676 : shortCondition ? #FF5252 : color.gray)

// Alerts
alertcondition(longCondition,  "Bollinger BUY",  "🚀 XAUUSD Family Bollinger BUY")
alertcondition(shortCondition, "Bollinger SELL", "🔻 XAUUSD Family Bollinger SELL")
````
