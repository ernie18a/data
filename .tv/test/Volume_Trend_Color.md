<!-- tradingview-pine-id: PUB;9ed527f4c04b422baf00bd00cf05f984 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Trend Color

Source: https://www.tradingview.com/script/ooAHIP94-Volume-Trend-Color/

## Description

This indicator colors volume bars according to trend context
instead of individual candle direction.

How it works
- A moving average of volume defines the reference level
  (yellow line).
- A second moving average on price defines trend direction.
- Bars are green when price trades above the trend MA, red
  when below, and gray when volume falls under the
  low-volume threshold.

Why color by trend rather than by candle
Coloring volume by candle direction repeats information
already visible on the price chart: a red candle produces a
red bar, and nothing is added. Coloring by trend context
instead answers a different question, namely whether
participation is arriving in the direction the reader is
already tracking. A pullback inside an uptrend will show
red candles but green volume bars, which makes it easy to
separate a pause in an ongoing move from a genuine loss of
participation. The neutral gray state marks bars where
volume is too low to support either reading.

Settings
- Volume MA length: reference average for volume.
- Low-volume threshold: fraction of the volume MA below
  which a bar is treated as noise. Raise it to filter more
  aggressively.
- Trend MA length: default 50. Shorten it on fast intraday
  charts if the color state lags the moves being traded.
- Trend MA type: EMA or SMA.
- Trend source: price series used for the trend MA.

Alerts
Two conditions are available: volume above its average
while price is above the trend MA, and the same while
price is below it.

This script is for chart analysis only and is not
investment advice.

---

## Source Code

````pine
//@version=6
// Volume colored by trend context.
//   Green : price above trend MA, volume at/above noise threshold
//   Red   : price below trend MA, volume at/above noise threshold
//   Gray  : volume below noise threshold (participation too low)
//   Yellow line: moving average of volume (reference level)

indicator("Volume Trend Color", "VTC", overlay = false,
     format = format.volume)

// --- Inputs ---------------------------------------------------------
GRP_VOL = "Volume"
GRP_TRD = "Trend filter"
GRP_COL = "Colors"

volLen = input.int(20, "Volume MA length", minval = 1, group = GRP_VOL,
     tooltip = "Reference average. Bars are compared to this value.")
noiseMult = input.float(0.5, "Low-volume threshold", minval = 0.0,
     step = 0.1, group = GRP_VOL,
     tooltip = "Bars below (threshold x volume MA) are painted neutral.")

trendLen = input.int(50, "Trend MA length", minval = 1, group = GRP_TRD)
trendType = input.string("EMA", "Trend MA type", options = ["EMA", "SMA"],
     group = GRP_TRD)
trendSrc = input.source(close, "Trend source", group = GRP_TRD)

bullCol = input.color(color.new(#26a69a, 20), "Up trend",
     group = GRP_COL, inline = "c")
bearCol = input.color(color.new(#ef5350, 20), "Down trend",
     group = GRP_COL, inline = "c")
flatCol = input.color(color.new(#b2b5be, 40), "Low volume",
     group = GRP_COL, inline = "c")

// --- Calculations ---------------------------------------------------
volMA = ta.sma(volume, volLen)
trendMA = trendType == "EMA" ? ta.ema(trendSrc, trendLen)
     : ta.sma(trendSrc, trendLen)

isUp = trendSrc > trendMA           // price above trend MA
isWeak = volume < volMA * noiseMult // participation below threshold

barCol = isWeak ? flatCol : isUp ? bullCol : bearCol

// --- Plots ----------------------------------------------------------
plot(volume, "Volume", barCol, style = plot.style_columns)
plot(volMA, "Volume MA", color.new(color.yellow, 0), 1)

// --- Alerts ---------------------------------------------------------
expansion = volume > volMA
alertcondition(expansion and isUp, "Volume expansion in up trend",
     "Volume above average while price is above the trend MA.")
alertcondition(expansion and not isUp, "Volume expansion in down trend",
     "Volume above average while price is below the trend MA.")
````
