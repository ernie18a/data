# Median ATR SD Oscillator

- url: https://www.tradingview.com/script/ynJj4SiS-Median-ATR-SD-Oscillator/
- type: indicator
- pine_id: PUB;f603d495c1504834b6a16039d0601555
- version: 1.0

## Description

[b]Median ATR SD Oscillator[/b]
Median ATR SD Oscillator is a trend-following volatility oscillator that measures the distance between price and two independent reference levels — an ATR band and a standard deviation band — both anchored to a percentile-based median. The asymmetric design uses different volatility measures for long and short signals, creating a natural bias toward staying in bullish trends longer while reacting quickly to breakdowns.

The result is an area oscillator that expands above zero in a confirmed bullish state and contracts below zero in a bearish state, with a white EMA line as a momentum confluence filter.

[b]How It Works[/b]
A percentile median is calculated from a configurable price source — giving a robust, noise-resistant central reference level that adapts to recent price behavior.

Two independent volatility bands are then derived from this median:
[list]
[*]ATR Band — median plus ATR multiplied by a configurable factor. The short condition uses the ATR band — price must fall below it to confirm a bearish state
[*]SD Band — median plus the standard deviation of close. The long condition uses the standard deviation band — price must break above it to confirm a bullish state[/list]

Once a directional state is confirmed, the oscillator measures the distance between price and its reference level. An EMA of this distance acts as a confluence filter — the final signal only confirms when the distance is not only positive or negative but also above or below its own EMA, ensuring momentum is genuinely building in that direction.

[b]Why This Approach Works[/b]
Most oscillators use a single volatility measure for both long and short signals. The Median ATR SD Oscillator deliberately uses two different measures — ATR for shorts and SD for longs — because they capture different market dynamics and create a natural asymmetry between entries and exits.

This asymmetric design reflects the structural reality of markets like crypto — price spends more time trending upward than downward. Longs require a statistically significant breakout above the SD band, while shorts only need price to fall back below the ATR band. The result is a system that stays in bullish trends longer while reacting quickly when momentum fades.

[b]Settings[/b]
[list]
[*]Median Source — Price source for the percentile median calculation (default: hl2)
[*]Median Length — Lookback period for the percentile median (default: 63)
[*]ATR Length — Lookback period for the ATR calculation (default: 4)
[*]ATR Factor — Controls the width of the ATR band (default: 1.0)
[*]SD Length — Lookback period for the standard deviation calculation (default: 29)
[*]Use EMA — Enables the EMA confluence filter (default: true)
[*]EMA Length — Lookback period for the EMA confluence filter (default: 35)
[*]Use Bar Coloring — Colors bars based on the current state (default: true)
[*]Color Background — Enables background coloring of the chart based on the current state (default: false)
[*]Background Transparency — Controls the transparency of the background color (default: 85)[/list]

[b]How to trade it[/b]
[list]
[*]Long — when the oscillator expands above zero and the area turns blue, a bullish state has been confirmed. This is the signal to look for long entries or to hold existing long positions
[*]Short / Cash — when the oscillator contracts below zero and the area turns red, the momentum has faded. This is the signal to exit longs, move to cash, or look for short entries depending on your strategy
[*]EMA line — when the area is above the white EMA line momentum is building, when it crosses below momentum is weakening[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe for clean and reliable signal generation
[*]Should not be used alone for trade entries — combine with an additional confirmation indicator for best results
[*]The asymmetric ATR/SD design makes this oscillator particularly well suited for bullish-biased markets like crypto
[*]Higher ATR Factor values make short exits more sensitive — lower values make them less reactive
[*]Higher SD Length values create more stable long signals — lower values make them more reactive to short-term price movements[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("Median ATR SD Oscillator", overlay = false)
//------------------------------------------------------------INPUTS------------------------------------------------------------
medSrc      = input.source(hl2, "Median Source",                group = "Median")
medLen      = input.int(63,   "Median Length",    minval = 1,   group = "Median")
atrLen      = input.int(4,    "ATR Length",       minval = 1,   group = "Volatility")
atrFactor   = input.float(1, "ATR Factor",     step = 0.05,  minval = 0.05, group = "Volatility")
sdLen       = input.int(29,   "SD Length",        minval = 1,   group = "Volatility")
useEma      = input.bool(true, "Use EMA",                       group = "EMA Filter")
emaLen      = input.int(35,   "EMA Length",       minval = 2,   group = "EMA Filter")
barColoring  = input.bool(true,  "Use Bar Coloring?",           group = "Show")
ShowBGCol    = input.bool(false, "Color Background",            group = "Show")
Transparency = input.int(85,    "Background Transparency",      group = "Show", minval = 0, maxval = 100)
//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
median = ta.percentile_nearest_rank(medSrc, medLen, 50)
atr    = median + ta.atr(atrLen) * atrFactor
sd     = median + ta.stdev(close, sdLen)

var trend = 0
if close > sd
    trend := 1
if close < atr
    trend := -1

diff = trend == 1 ? close - atr : close - sd
ema  = ta.ema(diff, emaLen)

var hodl = 0
if useEma
    hodl := trend == 1 and diff > ema ? 1 : trend == -1 and diff < ema ? -1 : hodl
else
    hodl := trend == 1 ? 1 : trend == -1 ? -1 : hodl
//------------------------------------------------------------PLOTS-------------------------------------------------------------
plot(diff, color = hodl == 1 ? color.rgb(0, 200, 255) : color.rgb(255, 0, 0), linewidth = 2, style = plot.style_area)
plot(ema,  color =  color.rgb(255, 255, 255), linewidth = 2)
plot(0,    color = color.gray, style = plot.style_stepline, linewidth = 2)
barcolor(barColoring and hodl == 1 ? color.rgb(0, 200, 255) : barColoring and hodl == -1 ? color.rgb(255, 0, 0) : na)
bgcolor(hodl == 1 ? color.new(color.rgb(0, 200, 255), Transparency) : color.new(color.rgb(255, 0, 0), Transparency), force_overlay = true, display = ShowBGCol ? display.all : display.none)
````
