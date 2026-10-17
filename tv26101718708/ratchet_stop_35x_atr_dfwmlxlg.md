# Ratchet Stop (3.5x ATR)

- url: https://www.tradingview.com/script/DFWMlxLG-Ratchet-Stop-3-5x-ATR/
- type: indicator
- pine_id: PUB;26e76885564449c5bec45ffa3f60f368
- version: 1.0

## Description

This indicator provides a strict, volatility-adjusted trailing stop-loss designed for long-only trend-following strategies. Rather than relying on arbitrary percentage drops, this script anchors risk management directly to the asset's current market physics using the Average True Range (ATR).
Core Mechanics:
•	Volatility Baseline: The script calculates the asset's true volatility over a defined lookback period (default 14) using Wilder's Smoothing (RMA) to map the Average True Range.
•	The Multiplier: This baseline volatility is multiplied by a user-defined factor (default 3.5x) to establish a "breathing room" buffer that filters out normal intraday market noise.
•	The Ratchet Logic (Chandelier Exit): The stop-loss floor is calculated by subtracting the ATR buffer from the highest high achieved during the trend. Crucially, this is a strict ratchet. As the price expands upward, the stop floor is dragged up with it. However, during periods of consolidation or price pullbacks, the floor locks in place and remains completely flat. It will never lower to accommodate a failing trend.
•	Reset: The floor only resets when the price action definitively breaks below the active stop line, signaling a structural trend failure.
Why Use It:
Traditional moving averages lag, and static percentage stops are blind to an asset's inherent volatility. The Ratchet Stop dynamically widens on volatile assets to prevent premature stop-outs, and tightens on low-volatility assets to preserve capital, entirely removing emotion from exit execution.
Inputs:
•	ATR Length: The lookback period for calculating the Average True Range (Default: 14).
•	Multiplier: The factor applied to the ATR to determine the width of the stop-loss buffer (Default: 3.5).

## Source Code

````pine
//@version=6
indicator(title="Ratchet Stop (3.5x ATR)", shorttitle="3.5X ATR Ratchet", overlay=true)

// Core Moonfish Parameters
length = input.int(14, title="ATR Length", minval=1)
m = input.float(3.5, title="Multiplier", step=0.1)

// 1. Calculate Wilder's Smoothed ATR (RMA) using 'ta.' namespace
atr_val = ta.rma(ta.tr(true), length) * m

// 2. Calculate the raw floor for the current bar
raw_floor = high - atr_val

// 3. Initialize the Ratchet Memory State (explicit float casting for v6 rules)
var float ratchet_floor = na

// 4. The Ratchet Logic: 
// - If we closed above yesterday's floor, the floor can only move UP (math.max).
// - If the price breaks the floor (liquidation event), it resets to track the new price action.
if na(ratchet_floor[1])
    ratchet_floor := raw_floor
else
    ratchet_floor := close[1] > ratchet_floor[1] ? math.max(raw_floor, ratchet_floor[1]) : raw_floor

// 5. Plot the hard stop line
plot(ratchet_floor, title="Liquidation Floor", color=color.red, linewidth=2, style=plot.style_linebr)
````
