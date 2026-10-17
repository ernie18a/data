# Edward Smart Liquidity Sweep

- url: https://www.tradingview.com/script/i141OEw6-Edward-Smart-Liquidity-Sweep/
- type: indicator
- pine_id: PUB;59a3de6233404bfab60651dec3463e06
- version: 2.0

## Description

[b]Edward Smart Liquidity Sweep[/b] is designed to help traders identify potential liquidity sweeps around recent swing highs and swing lows. The script highlights areas where price briefly moves beyond a previous liquidity level before returning back into the range, which may indicate a possible market reaction.

Features

* Buy-side liquidity sweep detection
* Sell-side liquidity sweep detection
* Automatic swing high and swing low identification
* Liquidity level visualization
* Clear sweep labels
* Built-in alert conditions
* Clean chart layout
* Suitable for multiple markets and timeframes

How It Works

The indicator tracks recent swing highs and swing lows to identify potential liquidity areas. When price moves beyond one of these levels and returns back, the script marks it as a potential liquidity sweep. These areas can be used together with market structure, support and resistance, or price action for additional confirmation.

Suitable Markets

* Forex
* Gold (XAUUSD)
* Cryptocurrency
* Indices
* Stocks

Suggested Timeframes

* M15
* M30
* H1
* H4

Alerts

* Buy-side Liquidity Sweep
* Sell-side Liquidity Sweep

Disclaimer
This script is provided for educational and analytical purposes only. It is designed to assist with chart analysis and should not be considered financial advice or a guarantee of future market performance. Always perform your own analysis and apply appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Edward Smart Liquidity Sweep", overlay = true)

// ===== INPUTS =====
swingLength = input.int(5, "Swing Length", minval=2)
showLevels = input.bool(true, "Show Liquidity Levels")

// ===== SWING POINTS =====
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

// ===== LIQUIDITY SWEEPS =====
buySideSweep = not na(lastHigh) and high > lastHigh and close < lastHigh
sellSideSweep = not na(lastLow) and low < lastLow and close > lastLow

// ===== PLOTS =====
plot(showLevels ? lastHigh : na, color=color.red, linewidth=2, title="Buy-side Liquidity")
plot(showLevels ? lastLow : na, color=color.green, linewidth=2, title="Sell-side Liquidity")

plotshape(
     buySideSweep,
     title="Sell Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SWEEP",
     textcolor=color.white)

plotshape(
     sellSideSweep,
     title="Buy Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="SWEEP",
     textcolor=color.black)

// ===== BACKGROUND =====
bgcolor(buySideSweep ? color.new(color.red,90) : sellSideSweep ? color.new(color.green,90) : na)

// ===== ALERTS =====
alertcondition(buySideSweep, title="Buy-side Liquidity Sweep", message="Buy-side liquidity sweep detected")
alertcondition(sellSideSweep, title="Sell-side Liquidity Sweep", message="Sell-side liquidity sweep detected")
````
