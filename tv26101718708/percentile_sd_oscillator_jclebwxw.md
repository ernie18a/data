# Percentile SD Oscillator

- url: https://www.tradingview.com/script/JcLEBWxw-Percentile-SD-Oscillator/
- type: indicator
- pine_id: PUB;340a4e4aab4545eaa9022b1bc638f16c
- version: 1.0

## Description

[b]Percentile SD Oscillator[/b]
Percentile SD Oscillator is a momentum oscillator that measures the distance between price and its own dynamic reference levels — derived from percentile bands and a volatility-adjusted standard deviation filter. Rather than using fixed overbought/oversold levels, it continuously adapts to recent price behavior and only confirms a directional state when price demonstrates genuine statistical strength beyond its own boundaries.

The result is a histogram that oscillates around a zero line — positive and blue when the market is in a confirmed bullish state, negative and red when bearish.

[b]How It Works[/b]
A moving average of your choice is calculated on a configurable source and length. Two percentile bands are then derived from this MA — an upper band and a lower band — defining the statistical range of recent price behavior.

A standard deviation of the close price is then calculated and added to the lower percentile band, creating a volatility-adjusted long reference level called sd_long. Price must close above both the upper percentile band AND sd_long to confirm a long — requiring double confirmation before entering a bullish state.

For the short side, a simple and fast condition is used — price only needs to close at or below the lower percentile band. Once a short state is confirmed, the oscillator measures the distance between the close price and the upper percentile band plus standard deviation as the bearish momentum value.

An EMA of the oscillator value acts as a confluence filter — the final signal only confirms when the oscillator is not only positive or negative but also above or below its own EMA. This ensures the oscillator only shows a confirmed state when momentum is genuinely building in that direction.

[b]Why This Approach Works[/b]
Most momentum oscillators use fixed thresholds that do not adapt to changing market conditions. By combining percentile bands with a close-based standard deviation filter, the Percentile SD Oscillator requires price to break beyond levels that are dynamically calculated from both recent price structure and current volatility.

The asymmetric design between long and short is intentional and reflects the structural reality of markets like crypto. Longs require double confirmation — price must clear both the upper percentile band and the volatility-adjusted SD level — ensuring only genuinely strong bullish moves trigger an entry. Shorts are deliberately simpler and faster — price only needs to break below the lower percentile band, allowing quick exits when support is lost. This asymmetry prevents premature long entries while ensuring fast risk-off behavior when the market weakens.

The bullish momentum is measured against the lower percentile band — this captures how far price has risen above its support zone, giving a direct measure of bullish momentum strength. The bearish momentum is measured against the upper percentile band plus standard deviation — this creates a wider reference that captures how far price has fallen from the resistance zone, giving a more meaningful picture of bearish momentum strength.

[b]Settings[/b]
[list]
[*]MA Type — Moving average type used as the basis for the percentile calculation: DEMA, EMA, SMA, WMA, HMA, RMA (default: DEMA)
[*]MA Length — Lookback period for the moving average (default: 8)
[*]MA Source — Price source for the moving average calculation (default: high)
[*]Percentile Length — Lookback period for the percentile band calculation (default: 57)
[*]Percentile Up — Upper percentile threshold defining the bullish boundary (default: 60)
[*]Percentile Down — Lower percentile threshold defining the bearish boundary (default: 46)
[*]SD Length — Lookback period for the standard deviation calculation (default: 19)
[*]SD Multiplier — Controls the strength of the standard deviation filter. Set to 0 to disable the SD filter entirely (default: 1.0)
[*]EMA Length — Lookback period for the EMA confluence filter (default: 48)
[*]Background Transparency — Controls the transparency of the optional background color (default: 85)
[*]Color Background — Enables background coloring of the chart based on the current state (default: false)
[*]Use Bar Coloring — Colors bars based on the current state (default: true)[/list]

[b]How to trade it[/b]
[list]
[*]Long — when the histogram turns blue and rises above zero, a bullish state has been confirmed. This is the signal to look for long entries or to hold existing long positions
[*]Short / Cash — when the histogram turns red and falls below zero, the bearish state has been confirmed. This is the signal to exit longs, move to cash, or look for short entries depending on your strategy
[*]Avoid trading against the signal — if the histogram is red do not look for longs, if it is blue do not look for shorts
[*]The EMA line acts as a dynamic reference — when the histogram is above the EMA momentum is building, when it crosses below the EMA momentum is weakening[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe for clean and reliable signal generation
[*]Should not be used alone for trade entries — combine with a trend-following indicator for best results
[*]Set SD Multiplier to 0 to rely solely on the percentile bands — useful when you want more frequent signals in trending markets
[*]Higher SD Multiplier values increase signal quality at the cost of fewer signals — lower values make the indicator more reactive
[*]The asymmetric design makes this oscillator particularly well suited for bullish-biased markets like crypto — long entries require double confirmation while short exits are fast and decisive[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("Percentile SD Oscillator", overlay = false)
import TradingView/ta/12 as ta
//------------------------------------------------------------INPUTS------------------------------------------------------------
maType      = input.string("DEMA", "MA Type", options = ["DEMA", "EMA", "SMA", "WMA", "HMA", "RMA"], group = "MA")
maLen       = input.int(8,    "MA Length",               group = "MA")
maSrc       = input.source(high, "MA Source",            group = "MA")
PctLen      = input.int(57,   "Percentile Length",       group = "Percentile")
PctUp       = input.int(60,   "Percentile Up",   minval = 1, maxval = 99, group = "Percentile")
PctDown     = input.int(46,   "Percentile Down", minval = 1, maxval = 99, group = "Percentile")
SDlen       = input.int(19,   "SD Length",               group = "Standard Deviation")
sd_mult     = input.float(1.0, "SD Multiplier",   step = 0.1, minval = 0.0, group = "Standard Deviation")
EmaLen      = input.int(48,   "EMA Length",              group = "EMA Filter")
Transparency = input.int(85,  "Background Transparency", group = "Customization", minval = 0, maxval = 100)
ShowBGCol   = input.bool(false, "Color Background",      group = "Show")
barColoring = input.bool(true,  "Use Bar Coloring?",     group = "Show")
//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
ma = switch maType
    "DEMA" => ta.dema(maSrc, maLen)
    "EMA"  => ta.ema(maSrc, maLen)
    "SMA"  => ta.sma(maSrc, maLen)
    "WMA"  => ta.wma(maSrc, maLen)
    "HMA"  => ta.hma(maSrc, maLen)
    "RMA"  => ta.rma(maSrc, maLen)

pct_up   = ta.percentile_nearest_rank(ma, PctLen, PctUp)
pct_down = ta.percentile_nearest_rank(ma, PctLen, PctDown)

sd       = ta.stdev(close, SDlen) * sd_mult
sd_long  = pct_down + sd
sd_short = pct_up   + sd

L = close > pct_up and close > sd_long
S = close <= pct_down

var isLong = false
if L
    isLong := true
if S
    isLong := false

Delta_long  = close - pct_down
Delta_short = close - sd_short
Delta       = isLong ? Delta_long : Delta_short

EMA = ta.ema(Delta, EmaLen)

var hodl = 0
if Delta > 0 and Delta > EMA
    hodl := 1
if Delta < 0 and Delta < EMA
    hodl := -1
//------------------------------------------------------------PLOTS-------------------------------------------------------------
plot(Delta, color = hodl == 1 ? color.rgb(0, 200, 255, 40) : color.rgb(255, 0, 0, 40), linewidth = 2, style = plot.style_histogram)
plot(EMA,   color = hodl == 1 ? color.rgb(0, 200, 255) : color.rgb(255, 0, 0), linewidth = 2)
plot(0,     color = color.gray, style = plot.style_stepline, linewidth = 2)
barcolor(barColoring and hodl == 1 ? color.rgb(0, 200, 255) : barColoring and hodl == -1 ? color.rgb(255, 0, 0) : na)
bgcolor(hodl == 1 ? color.new(color.rgb(0, 200, 255), Transparency) : color.new(color.rgb(255, 0, 0), Transparency), force_overlay = true, display = ShowBGCol ? display.all : display.none)
````
