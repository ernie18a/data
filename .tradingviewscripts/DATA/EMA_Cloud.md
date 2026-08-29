<!-- tradingview-pine-id: PUB;e15a0f4d125f47378ec1be643979108a -->
<!-- tradingviewscripts-format: 1 -->
# EMA Cloud

Source: https://www.tradingview.com/script/OlgdCtqH-EMA-Cloud-Highs-Lows/

## Description

DESCRIPTION 

A trend-following cloud built from two exponential moving averages — one applied to daily highs, the other to daily lows. Instead of a single EMA line, you get a zone that shows where the average high and average low of recent sessions sit, which makes it easier to judge whether price is extended, pulling back into value, or losing the trend entirely.

How it works

The indicator pulls the daily high and daily low of the instrument and calculates a separate EMA on each:

Upper cloud boundary = EMA of daily highs
Lower cloud boundary = EMA of daily lows
Center line = standard EMA of close, plotted for reference

Because the source values are fetched from the daily timeframe, the cloud stays anchored to daily structure regardless of the chart timeframe you're viewing. The same zone appears on a 5-minute chart as on a daily chart.

How to use it

Price holding above the cloud in an uptrend, with pullbacks that stall at the upper boundary or dip into the zone, is the typical continuation behaviour.
The cloud acts as a dynamic support/resistance band rather than a single line, which reduces the noise of price briefly piercing a lone EMA.
The lower boundary (EMA of daily lows) is a natural reference for trailing stops in long positions; the upper boundary serves the same role for shorts.
Price closing through and holding on the far side of the cloud signals a possible trend change.

Settings

EMA Length — period for both EMAs (default 21)
Cloud Color — fill color and opacity of the zone
Show Border Lines — toggle the outlines of the upper and lower boundaries on or off (off by default for a cleaner look)
Border Color / Border Width — styling for the boundaries when enabled

Notes

On intraday timeframes, the current day's high and low are still forming, so the most recent cloud values update as the session develops and settle once the daily bar closes. Historical values are fixed. This is expected behaviour for any indicator sourced from a higher timeframe.

SHORT VERSION

An EMA cloud built from daily highs and lows rather than closes. The upper boundary is an EMA of daily highs, the lower boundary an EMA of daily lows, with the standard EMA plotted between them. The result is a dynamic support/resistance zone that stays anchored to daily structure on any chart timeframe — useful for judging pullback depth and trailing stops in trending markets. Cloud color, opacity, EMA length, and optional border lines are all configurable.

---

## Source Code

````pine
//@version=6
indicator("EMA Cloud", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================

emaLength = input.int(21, title="EMA Length", minval=1)

// Cloud styling
cloudColor = input.color(color.new(color.gray, 80), title="Cloud Color")
showBorderLines = input.bool(false, title="Show Border Lines")
borderColor = input.color(color.gray, title="Border Color")
borderWidth = input.int(1, title="Border Width", minval=1, maxval=3)

// ============================================================================
// CALCULATIONS
// ============================================================================

// Calculate EMA on daily highs and lows
dailyHigh = request.security(syminfo.tickerid, "D", high)
dailyLow = request.security(syminfo.tickerid, "D", low)

// Calculate EMA of daily highs and lows
emaHigh = ta.ema(dailyHigh, emaLength)
emaLow = ta.ema(dailyLow, emaLength)

// Calculate regular EMA for reference (middle line)
emaMid = ta.ema(close, emaLength)

// ============================================================================
// PLOTTING
// ============================================================================

// Plot lines for cloud creation
highPlot = plot(emaHigh, title="EMA High", color=na, display=display.none)
lowPlot = plot(emaLow, title="EMA Low", color=na, display=display.none)

// Cloud fill
fill(highPlot, lowPlot, color=cloudColor, title="Cloud Fill")

// Optional border lines with conditional color
topColor = showBorderLines ? borderColor : na
bottomColor = showBorderLines ? borderColor : na

plot(emaHigh, title="Cloud Top Line", color=topColor, linewidth=borderWidth)
plot(emaLow, title="Cloud Bottom Line", color=bottomColor, linewidth=borderWidth)

// Plot middle EMA for visual reference
plot(emaMid, title="EMA Middle", color=color.new(color.yellow, 0), linewidth=2)
````
