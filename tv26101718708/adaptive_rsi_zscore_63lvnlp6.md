# Adaptive RSI ZScore

- url: https://www.tradingview.com/script/63LvNlP6-Adaptive-RSI-ZScore/
- type: indicator
- pine_id: PUB;422cf061014745c386712c4be411c03f
- version: 1.0

## Description

[b]Adaptive RSI ZScore[/b]
Adaptive RSI ZScore is a normalized momentum oscillator that measures the statistical deviation of the RSI from its own moving average, expressed as a Z-Score. Rather than reading momentum on an absolute scale like traditional RSI, it shows how unusual the current momentum state is relative to its own historical behavior — making it self-adjusting across different market conditions.

The result is an oscillator that turns blue when momentum is unusually strong and red when momentum is unusually weak — always relative to its own recent history, not fixed overbought/oversold levels.

[b]How It Works[/b]
The RSI is calculated on a configurable source and length. A moving average of the RSI is then computed using a separately configurable MA length and type — allowing the smoothing behavior to be tuned independently from the RSI calculation itself. The Z-Score is derived from the difference between the RSI and its moving average, normalized by the standard deviation of the RSI.

When the Z-Score crosses above the Long Threshold a bullish state is confirmed. When it crosses below the Short Threshold a bearish state is confirmed. The state persists until the opposite condition is met.

[b]Why Dynamic Thresholds Matter[/b]
Fixed thresholds work well in stable market conditions but struggle in highly volatile environments — a Z-Score move that would be significant in a calm market may be completely normal during high volatility. The Dynamic Threshold feature solves this by automatically adjusting the Long and Short thresholds based on the current standard deviation of the Z-Score itself. This means the indicator always requires an equally significant statistical deviation to trigger a signal, regardless of how volatile the market currently is.

This makes the indicator particularly well suited for volatile assets where market conditions shift frequently and fixed thresholds would quickly become unreliable. By default Dynamic Thresholds are enabled. They can be disabled in favor of fixed manual thresholds if preferred.

[b]Settings[/b]
[list]
[*]RSI Length — Lookback period for RSI calculation (default: 39)
[*]MA Length — Lookback period for the moving average and standard deviation (default: 37)
[*]Source — Price source for RSI calculation (default: open)
[*]MA Type — Moving average type used to calculate the RSI mean: SMA, EMA, WMA, RMA, HMA, VWMA (default: SMA)
[*]Long Threshold — Z-Score level for bullish confirmation when dynamic thresholds are disabled (default: 0.85)
[*]Short Threshold — Z-Score level for bearish confirmation when dynamic thresholds are disabled (default: -1.71)
[*]Use Dynamic Thresholds — Enables adaptive thresholds based on Z-Score standard deviation (default: true)
[*]Long SD Multiplier — Controls the sensitivity of the dynamic long threshold (default: 1.1)
[*]Short SD Multiplier — Controls the sensitivity of the dynamic short threshold (default: 1.3)
[*]Use Bar Coloring — Colors bars based on the current state (default: true)
[*]Color Background — Colors the chart background based on the current state (default: false)
[*]Background Transparency — Controls the transparency of the background color (default: 85)[/list]

[b]How to trade it[/b]
[list]
[*]Long — when the oscillator turns blue the momentum state is statistically unusually strong. This is the signal to look for long entries or to hold existing long positions
[*]Short / Cash — when the oscillator turns red the momentum state has weakened significantly. This is the signal to exit longs, move to cash, or look for short entries depending on your strategy
[*]Avoid trading against the signal — if the oscillator is red do not look for longs, if it is blue do not look for shorts[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe — the statistical deviation signals are cleaner and more reliable on higher timeframes where noise is reduced
[*]Designed to be used as a confirmation filter alongside a trend-following indicator — it identifies statistically significant momentum shifts that support or contradict the prevailing trend
[*]Should not be used alone for trade entries — combine with a structural or trend filter for best results
[*]Separating RSI Length and MA Length allows fine-tuning of signal sensitivity independently from smoothing behavior
[*]Dynamic Thresholds are recommended for volatile markets and assets — disable them for more stable and predictable signals
[*]Use the Long and Short SD Multipliers to control how extreme the momentum deviation must be before a signal fires — higher values mean fewer but higher quality signals[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("Adaptive RSI ZScore", overlay = false)

//------------------------------------------------------------INPUTS------------------------------------------------------------
rsi_len      = input.int(39, title = "RSI Length")
ma_len       = input.int(37, title = "MA Length")
src          = input.source(open, title = "Source")
maType       = input.string("SMA", title = "MA Type", options = ["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"])
L            = input.float(0.85, step = 0.01, title = "Long Threshold")
S            = input.float(-1.71, step = 0.01, title = "Short Threshold")
use_sd       = input.bool(true, "Use Dynamic Thresholds",  group = "Dynamic Thresholds")
sd_mult_l    = input.float(1.1, "Long SD Multiplier",  step = 0.1, group = "Dynamic Thresholds")
sd_mult_s    = input.float(1.3, "Short SD Multiplier", step = 0.1, group = "Dynamic Thresholds")
barColoring  = input.bool(true,  "Use Bar Coloring?",      group = "Coloring")
ShowBGCol    = input.bool(false, "Color Background",       group = "Coloring")
Transparency = input.int(85,     "Background Transparency", group = "Coloring", minval = 0, maxval = 100)

//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
rsi     = ta.rsi(src, rsi_len)

rsiMean = switch maType
    "SMA"  => ta.sma(rsi, ma_len)
    "EMA"  => ta.ema(rsi, ma_len)
    "WMA"  => ta.wma(rsi, ma_len)
    "RMA"  => ta.rma(rsi, ma_len)
    "HMA"  => ta.hma(rsi, ma_len)
    "VWMA" => ta.vwma(rsi, ma_len)

rsiSD     = ta.stdev(rsi, ma_len)
zScore    = (rsi - rsiMean) / rsiSD

zScore_sd = ta.stdev(zScore, ma_len)
dyn_L     = use_sd ? zScore_sd * sd_mult_l  : L
dyn_S     = use_sd ? -zScore_sd * sd_mult_s : S

Long  = ta.crossover(zScore, dyn_L)
Short = ta.crossunder(zScore, dyn_S)

var hodl = 0
if Long
    hodl := 1
if Short
    hodl := -1
    
//------------------------------------------------------------PLOTS-------------------------------------------------------------
color plotColor = hodl == 1 ? color.rgb(0, 200, 255) : hodl == -1 ? color.rgb(255, 0, 0) : na
zScorePlot     = plot(zScore, linewidth = 1, color = plotColor)
longThreshold  = plot(dyn_L, color = color.rgb(0, 200, 255), title = "Long Threshold")
shortThreshold = plot(dyn_S, color = color.rgb(255, 0, 0),   title = "Short Threshold")
plot((dyn_L + dyn_S) / 2, color = color.rgb(255, 255, 255, 80), title = "Midline")
barcolor(barColoring and hodl == 1 ? color.rgb(0, 200, 255, 0) : barColoring and hodl == -1 ? color.rgb(255, 0, 0, 0) : na)
bgcolor(hodl == 1 ? color.new(color.rgb(0, 200, 255), Transparency) : color.new(color.rgb(255, 0, 0), Transparency), force_overlay = true, display = ShowBGCol ? display.all : display.none)
````
