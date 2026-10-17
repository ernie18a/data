# SD Stochastic RSI Trend

- url: https://www.tradingview.com/script/mMJQYizY-SD-Stochastic-RSI-Trend/
- type: indicator
- pine_id: PUB;6b98a30ba53045d3b5a5915cb8517beb
- version: 2.0

## Description

[b]SD Stochastic RSI Trend[/b]
SD Stochastic RSI Trend is a trend-following indicator that combines a percentile-based standard deviation filter with a Stochastic RSI momentum confirmation — identifying high-conviction directional moves while keeping exits fast and responsive.

The result is a dynamic line that moves with the market — turning blue when a bullish trend is confirmed and red when bearish, with a fill between the line and price for clear visual trend identification.

[b]How It Works[/b]
Two independent systems validate whether a trend change is genuine:
[list]
[*]Standard Deviation Filter — a percentile median is calculated from a configurable price source. The standard deviation of this median defines an upper statistical boundary. Price must close above this boundary for a long and below it for a short — ensuring only statistically significant moves trigger a signal
[*]Stochastic RSI — measures where the RSI is relative to its own recent range. K must be above D for a long — confirming that momentum is genuinely building in the bullish direction. The Stochastic RSI is only required for long signals, making short exits faster and more responsive than entries[/list]

The long condition requires both systems to agree simultaneously. The short condition only requires the SD filter — exits are deliberately faster than entries.

[b]Why This Approach Works[/b]
Most trend indicators rely on price position alone to detect direction. SD Stochastic RSI Trend adds a second independent layer — momentum confirmation via Stochastic RSI — ensuring that a long signal only fires when price is statistically above its own median boundary AND momentum is genuinely building. This eliminates weak or noise-driven entries where price crosses a level without real conviction behind it.

The asymmetric design is intentional and reflects the structural reality of markets like crypto. Longs require both conditions — statistical price strength and momentum confirmation. Shorts only require the SD filter — allowing quick exits when the statistical boundary is lost without waiting for momentum to fully confirm.

[b]Settings[/b]
[list]
[*]Median Source — Price source for the percentile median calculation (default: hl2)
[*]Median Length — Lookback period for the percentile median (default: 62)
[*]SD Length — Lookback period for the standard deviation calculation (default: 30)
[*]K — Smoothing period for the Stochastic K line (default: 25)
[*]D — Smoothing period for the Stochastic D line (default: 8)
[*]RSI Length — Lookback period for the RSI calculation (default: 9)
[*]Stochastic Length — Lookback period for the Stochastic calculation (default: 30)
[*]Use Bar Coloring — Colors bars based on the current trend state (default: true)
[*]Color Background — Enables background coloring of the chart based on the current state (default: false)
[*]Background Transparency — Controls the transparency of the background color (default: 85)[/list]

[b]How to trade it[/b]
[list]
[*]Long — when the line turns blue and sits below price with a blue fill above it, both systems have confirmed a bullish trend. This is the signal to look for long entries or to hold existing long positions
[*]Short / Cash — when the line turns red and sits above price with a red fill below it, the statistical boundary has been lost. This is the signal to exit longs, move to cash, or look for short entries depending on your strategy
[*]Avoid trading against the trend — if the line is red do not look for longs, if the line is blue do not look for shorts[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe for clean and reliable trend identification
[*]Should not be used alone for trade entries — combine with an additional volume or structural indicator for confirmation
[*]The asymmetric design makes this indicator particularly well suited for bullish-biased markets like crypto — longs require full confirmation while shorts are fast and decisive
[*]Higher Stochastic Length values smooth the momentum signal — lower values make it more sensitive to short-term momentum shifts
[*]Adjust Median Length and SD Length together to control how wide the statistical boundary is — longer values create more stable signals, shorter values make the indicator more reactive[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("SD Stochastic RSI Trend", overlay = true)
//------------------------------------------------------------INPUTS------------------------------------------------------------
medSrc      = input.source(hl2, "Median Source",               group = "Standard Deviation")
medLen      = input.int(62,    "Median Length",                 group = "Standard Deviation")
sdLen       = input.int(30,    "SD Length",                     group = "Standard Deviation")
smoothK     = input.int(25,    "K",             minval = 1,     group = "Stochastic RSI")
smoothD     = input.int(8,     "D",             minval = 1,     group = "Stochastic RSI")
rsiLen      = input.int(9,     "RSI Length",    minval = 1,     group = "Stochastic RSI")
stochLen    = input.int(30,    "Stochastic Length", minval = 1, group = "Stochastic RSI")
barColoring  = input.bool(true,  "Use Bar Coloring?",           group = "Plot")
showCloud    = input.bool(true,  "Show Cloud",                  group = "Plot")
ShowBGCol    = input.bool(false, "Color Background",            group = "Plot")
Transparency = input.int(85,    "Background Transparency",      group = "Plot", minval = 0, maxval = 100)
//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
median     = ta.percentile_nearest_rank(medSrc, medLen, 50)

sd         = ta.stdev(median, sdLen)
sdd        = median + sd
sd_l       = close > sdd
sd_s       = close < sdd

rsi        = ta.rsi(close, rsiLen)
k          = ta.sma(ta.stoch(rsi, rsi, rsi, stochLen), smoothK)
d          = ta.sma(k, smoothD)
stol       = k > d

long       = sd_l and stol
short      = sd_s

var hodl = 0
if long and not short
    hodl := 1
if short
    hodl := -1
//------------------------------------------------------------PLOTS-------------------------------------------------------------
sdd_plot   = plot(sdd,   "SD Upper", color = hodl == 1 ? color.rgb(0, 200, 255) : color.rgb(255, 0, 0), linewidth = 3)
close_plot = plot(close, color = na, editable = false)
fill(sdd_plot, close_plot, color = showCloud ? (hodl == 1 ? color.rgb(0, 200, 255, 85) : color.rgb(255, 0, 0, 85)) : na)
barcolor(barColoring and hodl == 1 ? color.rgb(0, 200, 255) : barColoring and hodl == -1 ? color.rgb(255, 0, 0) : na)
bgcolor(hodl == 1 ? color.new(color.rgb(0, 200, 255), Transparency) : color.new(color.rgb(255, 0, 0), Transparency), force_overlay = true, display = ShowBGCol ? display.all : display.none)
````
