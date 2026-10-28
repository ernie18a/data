# The  BREW Apex OMNI: Momentum Execution System

- url: https://www.tradingview.com/script/QYjMFhFB-The-BREW-Apex-OMNI-Momentum-Execution-System/
- type: indicator
- pine_id: PUB;731b123015f642bf84a94a32f4aafdee
- version: 1.0

## Description

The BREW Apex OMNI: Momentum Execution System
The "Why" Behind the Script
In the world of low-float, high-volatility trading, the difference between a "Healthy Dip" and a "Deadly Dump" is often just a few seconds. The Apex OMNI was designed to bridge that gap by automating the discipline required for 1-minute and 3-minute momentum execution. It translates complex price action into a clear, color-coded visual HUD.
 
  // -- USE THE PIN THE SCALE TO THE RIGHT IF IT IS NOT WORKING -- //
Core Systems
The Aqua Coil Ribbon: Identifies the "Pinch" between the 9 and 20 EMAs. This highlights high-probability bases where a stock is coiling for its next leg up (The Dip).

Precision Strike (Green Triangles): A multi-factor entry signal. It only fires when price clears a 10-candle high on Relative Volume (RVOL) expansion while staying above VWAP.

Velocity Protection (Orange/Red Signals): * Orange "WICK" Label: Automatically detects "Topping Tails" and exhaustion wicks (Wick > 2x Body).

Red Triangles: A hard trend-break signal triggered by a 9 EMA snap on volume.

How to Use It
Scanner Check: Find tickers with high RVOL and Low Float (under 20M).

Wait for the Coil: Watch for the Aqua Ribbon to confirm the stock is holding its level.

The Strike: Enter on the Green Triangle.

Manage: Scale out 50% on Orange Wicks; exit 100% on Red Triangles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Wolfwins
// @version=5
indicator("The Apex OMNI: Momentum Execution System", shorttitle="Apex OMNI", overlay=true)

// --- 1. SETTINGS & INPUTS ---
ema9_len  = input.int(9, "Fast EMA", minval=1)
ema20_len = input.int(20, "Slow EMA", minval=1)
rvol_thresh = input.float(1.5, "RVOL Entry Threshold", step=0.1)

// --- 2. CORE CALCULATIONS (Calculated on closed bars) ---
ema9  = ta.ema(close, ema9_len)
ema20 = ta.ema(close, ema20_len)
vwapVal = ta.vwap(close)
avg_vol = ta.sma(volume, 60)
rvol = volume / avg_vol

// --- 3. THE AQUA COIL (DIP DETECTION) ---
ema_dist = math.abs(ema9 - ema20)
is_pinching = ema_dist < ta.ema(ema_dist, 20) 

// Ribbon Color Logic (Using [1] ensures the color doesn't flicker mid-candle)
ribbon_color = ema9[1] > ema20[1] ? (is_pinching[1] ? color.new(color.aqua, 60) : color.new(color.green, 60)) : color.new(color.red, 60)
p1 = plot(ema9, color=color.green, linewidth=2, title="9 EMA")
p2 = plot(ema20, color=color.yellow, linewidth=1, title="20 EMA")
fill(p1, p2, ribbon_color, title="Trend Ribbon")

// --- 4. PRECISION STRIKE (CONFIRMED ON CLOSE) ---
is_bullish = close[1] > vwapVal[1] and ema9[1] > ema20[1]
hi = ta.highest(high, 10)[2] // Look at the high before the trigger candle
bos_strike = ta.crossover(close[1], hi) and is_bullish and rvol[1] > rvol_thresh

plotshape(bos_strike, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.large, title="STRIKE")
plotshape(rvol > 4.0, style=shape.diamond, location=location.abovebar, color=color.fuchsia, size=size.tiny, title="VOL CLIMAX")

// --- 5. THE DUMP PROTECTION (EXHAUSTION) ---
exit_trigger = ta.crossunder(close[1], ema9[1])
upper_wick = high[1] - math.max(open[1], close[1])
body_size = math.abs(open[1] - close[1])
is_exhaustion = upper_wick > (body_size * 2) and rvol[1] > 1.2

plotshape(exit_trigger, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, title="EXIT")
plotshape(is_exhaustion and not exit_trigger, text="WICK", style=shape.labeldown, location=location.abovebar, color=color.orange, textcolor=color.white, size=size.small)

// --- 6. DYNAMIC CANDLE COLORING ---
// If the bar is still open, it uses the previous bar's state to prevent "flashing"
bar_color = exit_trigger ? color.red : (is_exhaustion or is_pinching[1]) ? color.orange : (close > open ? color.green : color.red)
barcolor(bar_color)

plot(vwapVal, color=color.white, linewidth=2, title="VWAP")
````
