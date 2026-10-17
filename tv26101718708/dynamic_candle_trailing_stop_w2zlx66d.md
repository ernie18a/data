# Dynamic Candle Trailing Stop

- url: https://www.tradingview.com/script/W2ZLx66d-Dynamic-Candle-Trailing-Stop/
- type: indicator
- pine_id: PUB;05eb86f563ee443088f006d5c950c865
- version: 2.0

## Description

[b]Dynamic Candle Trailing Stop[/b] (v1)

The [b]Dynamic Candle Trailing Stop[/b] is a clean, multi-directional trailing stop tool designed to help traders automate exit management, protect profits, and reduce emotional decision-making. 

Instead of relying on volatility indicators like ATR or static percentages, this indicator anchors its trailing stop directly to recent price structure (highs and lows over a customizable candle period, default is 6 candles).

-----

🔹 [b]How It Works[/b]

1. [b]Structural Anchoring:[/b] It continuously calculates the highest high and lowest low over a user-defined lookback window (`# of Candles to Look Back`).
2. [b]One-Way Ratcheting Mechanism:[/b]
   - [b]In a Long Trend:[/b] The trailing stop [b]only moves UP[/b] (ratchets upward as new local lows form) and will never step down.
   - [b]In a Short Trend:[/b] The trailing stop [b]only moves DOWN[/b] (ratchets downward as new local highs form) and will never step up.
3. [b]Automated Trend Reset:[/b] When price closes beyond the trailing stop, the trend state automatically flips, and the stop resets to the opposite structural boundary.

-----

🟢 [b]How to Use It[/b]

* [b]Color Coding:[/b]
  * [b]Green Stepline:[/b] Active Long Trailing Stop.
  * [b]Red Stepline:[/b] Active Short Trailing Stop.
* [b]Exit Signal:[/b] Close a position when the candle [b]closes[/b] beyond the stepline.
* [b]Trend Filtering:[/b] Use the line color as an extra confirmation filter for current short-term directional bias.
* [b]Ranges:[/b] Don't ratchet your stop if the current candles closes opposite direction. Leave space for a range to breath. If you move the stop too aggressively you won't be able to capture the bigger move.

-----

⚙️ [b]Settings[/b]

* [b]# of Candles to Look Back:[/b] 
  * Default: `6`
  * [i]Lower values (e.g., 2–3)[/i] provide a tight, fast-reacting trail for scalping.
  * [i]Higher values (e.g., 5–10)[/i] give the asset more breathing room, suited for longer intraday trading.

-----

[i]Open source under Mozilla Public License 2.0. Enjoy, and safe trading![/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Odeseos

//@version=6
indicator("Dynamic Candle Trailing Stop (Fixed)", overlay=true)

noc = input.int(6, "# of Candles to Look Back")

// 1. Calculate local structural boundaries
highestHigh = ta.highest(high, noc)
lowestLow   = ta.lowest(low, noc)

// 2. Track trend direction so lines reset automatically
var int trend = 1 // 1 for Long, -1 for Short
var float trailStop = na

// Initialize on the very first bar of the chart
if barstate.isfirst
    trailStop := lowestLow

// 3. Determine if trend has flipped (Price crosses the trailing stop)
if trend == 1 and close < trailStop
    trend := -1
    trailStop := highestHigh
else if trend == -1 and close > trailStop
    trend := 1
    trailStop := lowestLow

// 4. Update trailing stop based on active trend direction
if trend == 1
    // Long stop: only steps UP, never down
    trailStop := math.max(lowestLow, nz(trailStop, lowestLow))
else
    // Short stop: only steps DOWN, never up
    trailStop := math.min(highestHigh, nz(trailStop, highestHigh))

// 5. Plot lines with colors that change based on direction
plotColor = trend == 1 ? color.green : color.red
plot(trailStop, color=plotColor, linewidth=2, style=plot.style_stepline, title="Trailing Stop")
````
