# Liquidity Rejection Areas (LRA)

- url: https://www.tradingview.com/script/DNthwI3m-Liquidity-Rejection-Areas-LRA/
- type: indicator
- pine_id: PUB;19baf6794eef4473bbcfbe2d33b6a547
- version: 2.0

## Description

[b]Overview[/b]

[b]Liquidity Rejection Areas (LRA) [/b] is a price-action and liquidity-based trading indicator designed to identify liquidity sweeps, rejection zones, and potential institutional reversal areas directly on the chart.

The indicator helps traders visualize where market participants may have been trapped after liquidity is taken above swing highs or below swing lows. By combining liquidity concepts with rejection confirmation, LRA Pro highlights high-probability reaction zones across Crypto, Forex, Indices, and Commodities.

[b]Key Features[/b]

💧 [b]Liquidity Sweep Detection[/b]
* Detects liquidity grabs above swing highs
* Detects liquidity grabs below swing lows
* Highlights stop-hunt activity
* Identifies potential smart money reactions

🎯 [b]Rejection Area Mapping[/b]
* Bullish liquidity rejection zones
* Bearish liquidity rejection zones
* Dynamic zone projection
* Clean chart visualization

📊 [b]Market Reaction Analysis[/b]
* Rejection candle confirmation
* Liquidity-based reversal signals
* Potential reaction areas
* High-visibility trade locations

🚀 [b]Smart Money Concepts Integration[/b]
* Liquidity-driven market analysis
* Institutional behavior visualization
* Price-action confirmation
* Market structure awareness

🔔 [b]Alert System[/b]
* Bullish liquidity rejection alerts
* Bearish liquidity rejection alerts
* Real-time market notifications

📈 [b]Best Market Conditions[/b]
* Trending markets
* Volatile market environments
* London Session
* New York Session
* Breakout and reversal conditions

⏱ [b]Recommended Timeframes[/b]
* 1M – 5M → Scalping
* 15M – 1H → Intraday Trading (Recommended)
* 4H – Daily → Swing Trading

🎯 [b]How to Use[/b]
* Wait for a liquidity sweep above or below key levels
* Confirm rejection from the liquidity area
* Use bullish rejection zones for potential long opportunities
* Use bearish rejection zones for potential short opportunities
* Combine with market structure and risk management

⚠️ [b]Disclaimer[/b]
This indicator is designed to assist traders in identifying liquidity-based market reactions and potential reversal areas. It does not predict future market movements or guarantee profits. Always use proper risk management and additional confirmation before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Liquidity Rejection Areas (LRA) ", overlay=true, max_boxes_count=100, max_labels_count=100)

// Inputs
pivotLen     = input.int(5, "Swing Length", minval=2)
zoneExtend   = input.int(50, "Zone Extension")
showLabels   = input.bool(true, "Show Signals")
showZones    = input.bool(true, "Show Zones")

// Swing Points
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

// Store Last Liquidity Levels
var float lastHighLiquidity = na
var float lastLowLiquidity  = na

if not na(pivotHigh)
    lastHighLiquidity := pivotHigh

if not na(pivotLow)
    lastLowLiquidity := pivotLow

// Liquidity Sweep Conditions
bearSweep =
     not na(lastHighLiquidity) and
     high > lastHighLiquidity and
     close < lastHighLiquidity

bullSweep =
     not na(lastLowLiquidity) and
     low < lastLowLiquidity and
     close > lastLowLiquidity

// Rejection Candle Strength
bearReject = bearSweep and close < open
bullReject = bullSweep and close > open

// Draw Zones
if bearReject and showZones
    box.new(
         bar_index,
         high,
         bar_index + zoneExtend,
         open,
         border_color=color.red,
         bgcolor=color.new(color.red, 85))

if bullReject and showZones
    box.new(
         bar_index,
         open,
         bar_index + zoneExtend,
         low,
         border_color=color.lime,
         bgcolor=color.new(color.lime, 85))

// Labels
if bearReject and showLabels
    label.new(
         bar_index,
         high,
         "LRA SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

if bullReject and showLabels
    label.new(
         bar_index,
         low,
         "LRA BUY",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black)

// Alerts
alertcondition(bearReject, "Bearish Liquidity Rejection", "LRA SELL Signal")
alertcondition(bullReject, "Bullish Liquidity Rejection", "LRA BUY Signal")

// Plot Liquidity Levels
plot(lastHighLiquidity, "Liquidity High", color=color.new(color.red, 70))
plot(lastLowLiquidity, "Liquidity Low", color=color.new(color.green, 70))
````
