# Inflow/Outflow Index (IOI)

- url: https://www.tradingview.com/script/C97kjmje-Inflow-Outflow-Index-IOI/
- type: indicator
- pine_id: PUB;45aad2df49284277871450876b596f3d
- version: 1.0

## Description

The Inflow/Outflow Index (IOI) is a high-sensitivity momentum oscillator designed to visualize the tug-of-war between aggressive buying and selling. Unlike a standard RSI (which only tracks price change) the IOI scales price action by actual traded volume, providing a clearer picture of where the "Smart Money" is moving.

- Buying Inflow: Occurs when the price closes higher than it opened, weighted by the volume of that period.

- Selling Outflow: Occurs when the price closes lower than it opened, weighted by volume.

These flows are then smoothed using an Exponential Moving Average (EMA) and processed through an RSI-style formula to create an oscillator that moves between 0 and 100.

How one reads this indicator:

    The Midline (50): The "Control Point" where the tug of war is in a state of balance / indecision.

- Above 50 (Green By Default): Buyers are in command, and capital is flowing into the asset.

- Below 50 (Red By Default): Sellers are dominating, and capital is flowing out of the asset.

- Extreme Inflow (>80): Signal of intense buying pressure; the trend is strong but watch for exhaustion.

- Extreme Outflow (<20): Signal of heavy liquidation; potential for a "oversold" bounce.

- Divergences: If the price makes a new high but the IOI makes a lower high, it suggests the move lacks the "volume fuel" to continue, signaling a potential reversal.

Godspeed friends!

## Source Code

````pine
// Author: Reoky April 17, 2026
// The IOI works like a volume-weighted RSI letting you visualize buying and selling pressure. This can help traders spot when buying pressure is weakening or growing
// for potential reversal setups, and for additional confluence / confirmation of continuations. Try it friends!
//@version=6
indicator("Inflow/Outflow Index (IOI)", overlay=false, precision=2)

// --- Inputs ---
period = input.int(14, "Period", minval=1)
src_type = input.string("close", "Source", options=["open", "high", "low", "close", "hl2", "hlc3"])

// --- Logic ---
src = switch src_type
    "open"  => open
    "high"  => high
    "low"   => low
    "close" => close
    "hl2"   => hl2
    "hlc3"  => hlc3
    => close

// Calculate Money Flow Volume
float moneyFlowVolume = 0.0
if close > open
    moneyFlowVolume := volume * (close - open)
else if close < open
    moneyFlowVolume := -volume * (open - close)

// Separate into Inflow (Gains) and Outflow (Losses)
float inflow  = moneyFlowVolume > 0 ? moneyFlowVolume : 0
float outflow = moneyFlowVolume < 0 ? math.abs(moneyFlowVolume) : 0

// Calculate the Smoothed Averages (EMA)
avgInflow  = ta.ema(inflow, period)
avgOutflow = ta.ema(outflow, period)

// Calculate the Index (RSI Formula)
rs = avgOutflow == 0 ? 999999999 : avgInflow / avgOutflow
ioi = 100 - (100 / (1 + rs))

// Define Plot Colors based on the Midline (50)
plotColor = ioi > 50 ? color.green : ioi < 50 ? color.red : color.gray

// --- Visuals ---
// 1. Plot the Midline as a 'plot' instead of an 'hline' to fix the type mismatch
midline_plot = plot(50, "Midline", color=color.new(color.gray, 50), style=plot.style_steplinebr)

// 2. Plot the IOI Index
ioi_plot = plot(ioi, "IOI", color=plotColor, linewidth=2)

// 3. Perform the fill (Both arguments are now 'plot' types)
fill(midline_plot, ioi_plot, ioi > 50 ? color.new(color.green, 85) : color.new(color.red, 85), title="Background Fill")
````
