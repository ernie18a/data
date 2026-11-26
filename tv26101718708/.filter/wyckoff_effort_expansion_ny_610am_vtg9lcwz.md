# wyckoff Effort Expansion NY 6-10am 

- url: https://www.tradingview.com/script/vTG9lcwz-wyckoff-Effort-Expansion-NY-6-10am/
- type: indicator
- pine_id: PUB;7f3ae9674c4144ecb13cddf8683d221b
- version: 1.0

## Description

This indicator identifies volume expansion events during a high-impact intraday window.

It highlights bars where:
- Current volume exceeds the highest volume of the previous 5 bars
- Time is strictly between 6:00 AM and 10:00 AM New York time

This period captures the transition from early session activity into peak liquidity, where institutional participation and volatility increase.

Purpose:
This indicator is designed to detect unusual participation spikes, highlight potential order flow imbalances, and identify expansion phases following consolidation.

Key Features:
- Strict New York time filter (DST-adjusted automatically)
- Relative volume comparison (not fixed thresholds)
- Clean visual signals (triangle markers above bars)
- Optional bar highlighting and alert support

Usage:
Use this tool to confirm breakout strength, identify high-activity candles during key trading hours, and filter out low-quality signals outside peak liquidity periods.

Note:
This indicator does not provide trade entries on its own. It should be used alongside a structured trading model, price action, and proper risk management.

## Source Code

````pine
//@version=6
indicator("Volume Spike (NY 6AM–10AM)", overlay=true)

// === INPUT ===
lookback = input.int(5, "Lookback Bars", minval=1)

// === NEW YORK TIME ===
nyHour = hour(time, "America/New_York")

// === TIME FILTER (6AM–10AM NY) ===
inTimeWindow = (nyHour >= 6 and nyHour < 10)

// === VOLUME CONDITION ===
isHigherVolume = volume > ta.highest(volume[1], lookback)

// === FINAL SIGNAL ===
signal = isHigherVolume and inTimeWindow

// === PLOT ===
plotshape(signal,
     title="Volume Spike",
     location=location.abovebar,
     style=shape.triangleup,
     size=size.small,
     color=color.green)

// === BAR COLOR (OPTIONAL) ===
barcolor(signal ? color.new(color.green, 0) : na)

// === ALERT ===
alertcondition(signal,
     title="Volume Spike Alert",
     message="Volume higher than last 5 bars (6AM–10AM NY)")
````
