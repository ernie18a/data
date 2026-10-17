# Liquidity Flow Zones (LFZ)

- url: https://www.tradingview.com/script/5n9CIJkC-Liquidity-Flow-Zones-LFZ/
- type: indicator
- pine_id: PUB;7e994d5bd4aa487c87fb3a093c6b8d16
- version: 2.0

## Description

[b]Overview[/b]

Liquidity Flow Zones (LFZ) is an original liquidity-based indicator designed to help traders identify potential liquidity sweeps around important swing highs and swing lows. The indicator highlights areas where price may briefly move beyond recent market structure before reversing back into the range.

Rather than predicting the future, LFZ helps visualize key liquidity events that can support market analysis and trade planning.

## Features

• Automatic Swing High and Swing Low detection
• Bullish Liquidity Sweep identification
• Bearish Liquidity Sweep identification
• ATR-based confirmation filter to reduce weak signals
• Dynamic liquidity level plotting
• Buy and Sell signal markers after confirmed sweeps
• Built-in TradingView alert conditions
• Clean and lightweight Pine Script v6 implementation

## How It Works

* A bullish liquidity sweep occurs when price moves below a recent swing low and then closes back above that level.
* A bearish liquidity sweep occurs when price moves above a recent swing high and then closes back below that level.
* ATR filtering helps ignore small or insignificant price movements.

## Best Use

LFZ performs best when combined with:

* Market Structure Analysis
* Trend Confirmation
* Support and Resistance
* Proper Risk Management

It is intended to assist decision-making and should not be used as the sole basis for entering or exiting trades.

## Thank You

Thank you for checking out Liquidity Flow Zones (LFZ).

If you find this indicator useful, please consider leaving a **Like**, adding it to your **Favorites**, and sharing your feedback in the comments. Your support helps improve future updates.

Happy Trading!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Liquidity Flow Zones (LFZ)", overlay=true, max_labels_count=500)

// === Inputs ===
pivotLen = input.int(5, "Swing Length", minval=2)
atrLen   = input.int(14, "ATR Length")
atrMult  = input.float(0.20, "Sweep Filter (ATR)", step=0.05)
showZones = input.bool(true, "Show Liquidity Levels")

// === ATR ===
atr = ta.atr(atrLen)

// === Swing High / Low ===
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// === Draw Liquidity Levels ===
plot(showZones ? lastHigh : na, "Buy Side Liquidity", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showZones ? lastLow : na, "Sell Side Liquidity", color=color.lime, linewidth=2, style=plot.style_linebr)

// === Liquidity Sweep Logic ===
bearSweep = not na(lastHigh) and high > lastHigh + atr * atrMult and close < lastHigh
bullSweep = not na(lastLow) and low < lastLow - atr * atrMult and close > lastLow

// === Signals ===
plotshape(bullSweep, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(bearSweep, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

// === Background ===
bgcolor(bullSweep ? color.new(color.green, 90) : bearSweep ? color.new(color.red, 90) : na)

// === Alerts ===
alertcondition(bullSweep, title="Bullish Liquidity Sweep", message="Bullish Liquidity Sweep detected")
alertcondition(bearSweep, title="Bearish Liquidity Sweep", message="Bearish Liquidity Sweep detected")
````
