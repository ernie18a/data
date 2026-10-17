# Median ATR Trend

- url: https://www.tradingview.com/script/94bFE84Z-Median-ATR-Trend/
- type: indicator
- pine_id: PUB;e6cff5c8c0d94f38bf9ef4d7480ed52f
- version: 1.0

## Description

[b]Median ATR Trend[/b]
Median ATR Trend is a trend-following indicator that identifies the dominant market direction using a percentile-based median combined with an ATR buffer and a standard deviation filter — confirming trend changes only when price shows genuine strength beyond its own statistical boundaries.

The result is a dynamic line that moves with the market — sitting above price in a bullish trend and below price in a bearish trend, with a fill between the line and price for clear visual trend identification.

[b]How It Works[/b]
A moving average of your choice is calculated on a configurable source and length. The median of this MA is then derived using a percentile calculation — giving a robust, noise-resistant central reference level that adapts to recent price behavior.

Two independent filters then validate whether a trend change is genuine:
[list]
[*]ATR buffer — the ATR defines a zone around the median. For longs, price must stay above the lower boundary of this zone — if price drops too far below the median the long condition fails. For shorts, price must fall below the upper boundary of this zone — meaning the bullish momentum has faded and price has re-entered the median zone from above. The ATR Multiplier controls how wide this zone is — higher values create a wider zone and fewer signals, lower values make the indicator more sensitive
[*]Standard deviation filter — price must additionally clear the upper standard deviation band of the median before a long is confirmed, ensuring only statistically significant moves trigger an entry[/list]

A confirmation mechanism requires both conditions to hold for a defined number of bars before the trend state changes — separately configurable for long and short signals. This prevents the indicator from reacting to brief spikes that immediately reverse, keeping the trend state stable and reducing false signals in choppy market conditions.

By default the indicator is asymmetric — longs require SD confirmation while shorts only require the ATR condition. This means the long side is stricter and more selective, while the short side reacts faster to any weakness. Enabling the Short SD Filter makes the short condition equally strict, requiring price to additionally break below the lower standard deviation band before confirming a bearish trend — making both sides symmetric.

In markets like crypto that have a strong structural bullish bias, the default asymmetry makes a lot of sense — price spends significantly more time trending upward than downward. A strict long condition ensures only genuine bullish moves are entered, while a fast short condition allows quick exits when momentum fades. Enable the Short SD Filter in ranging or bearish markets where you want both sides to require the same level of statistical confirmation before triggering.

[b]Why This Approach Works[/b]
Most trend indicators use fixed levels or simple moving average crossovers that trigger on any price touch — even weak or noise-driven ones. By combining a percentile-based median with two independent volatility filters, Median ATR Trend requires price to demonstrate genuine statistical strength before confirming a trend. Minor retracements and noise-driven spikes around the median are ignored — only moves with real conviction behind them trigger a signal.

[b]Settings[/b]
[list]
[*]MA Type — Moving average type used as the basis for the median calculation: DEMA, EMA, SMA, WMA, HMA, RMA (default: DEMA)
[*]MA Length — Lookback period for the moving average (default: 9)
[*]MA Source — Price source for the moving average calculation (default: close)
[*]Median Length — Lookback period for the percentile median calculation (default: 61)
[*]ATR Length — Lookback period for ATR calculation (default: 12)
[*]ATR Multiplier — Controls the size of the ATR buffer. Set to 0 to disable the ATR filter entirely (default: 0.5)
[*]SD Length — Lookback period for standard deviation calculation (default: 29)
[*]SD Multiplier Long — Controls the strength of the standard deviation filter for long signals. Set to 0 to disable (default: 1.0)
[*]Use Short SD Filter — Enables a symmetric standard deviation filter for short signals, matching the long side. When disabled the indicator is asymmetric by default — longs require SD confirmation, shorts do not (default: false)
[*]SD Multiplier Short — Controls the strength of the standard deviation filter for short signals when enabled (default: 1.0)
[*]Long Confirmation Bars — Number of bars the bullish condition must hold before confirming (default: 1)
[*]Short Confirmation Bars — Number of bars the bearish condition must hold before confirming (default: 1)
[*]Use Bar Coloring — Colors bars based on the current trend state (default: true)[/list]

[b]How to trade it[/b]
[list]
[*]Long — when the line turns blue and the fill appears above price, a bullish trend has been confirmed. This is the signal to look for long entries or to hold existing long positions
[*]Short / Cash — when the line turns red and the fill appears below price, the bullish structure has broken down. This is the signal to exit longs, move to cash, or look for short entries depending on your strategy
[*]Avoid trading against the trend — if the line is red do not look for longs, if the line is blue do not look for shorts[/list]

[b]Recommended Usage[/b]
[list]
[*]Best used on the 1D timeframe for clean and reliable trend identification
[*]Should not be used alone for trade entries — combine with a momentum or volume indicator for confirmation
[*]Set SD Multiplier Long to 0 to rely solely on the ATR filter — useful in trending markets where the SD filter may delay entries
[*]Keep the Short SD Filter disabled for bullish or trending markets — the default asymmetry keeps long entries strict while allowing fast exits when momentum fades
[*]Enable the Short SD Filter in ranging or bearish markets where you want both sides to require the same level of statistical confirmation before triggering
[*]Higher ATR Multiplier values increase signal quality at the cost of fewer signals — lower values make the indicator more reactive
[*]Higher Confirmation Bar values reduce false signals at the cost of slightly later entries — useful in choppy or ranging markets
[*]Swing trading — the confirmation mechanism keeps the indicator stable during pullbacks, allowing you to hold through minor retracements without being shaken out prematurely
[*]Breakout trading — the combination of ATR buffer and SD filter ensures you only act on genuine breakouts with real momentum behind them[/list]

All signals are confirmed on bar close.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unknownhodler
//@version=6
indicator("Median ATR Trend", overlay = true)
import TradingView/ta/12 as ta
//------------------------------------------------------------INPUTS------------------------------------------------------------
maType      = input.string("DEMA", "MA Type", options = ["DEMA", "EMA", "SMA", "WMA", "HMA", "RMA"])
len_ma      = input.int(9,     "MA Length")
src_ma      = input.source(close, "MA Source")
median_len  = input.int(61,    "Median Length")
atr_len     = input.int(12,    "ATR Length")
atr_mul     = input.float(0.5, "ATR Multiplier",      step = 0.1, minval = 0.0)
len_sd      = input.int(29,    "SD Length")
sd_mul      = input.float(1.0, "SD Multiplier Long",  step = 0.1, minval = 0.0)
use_sd_s    = input.bool(false, "Use Short SD Filter")
sd_mul_s    = input.float(1.0, "SD Multiplier Short", step = 0.1, minval = 0.0)
conf_l      = input.int(1, "Long Confirmation Bars",  minval = 1, group = "Confirmation")
conf_s      = input.int(1, "Short Confirmation Bars", minval = 1, group = "Confirmation")
barColoring = input.bool(true, "Use Bar Coloring?", group = "Coloring")
//---------------------------------------------------------CALCULATIONS---------------------------------------------------------
var hodl = 0

ma = switch maType
    "DEMA" => ta.dema(src_ma, len_ma)
    "EMA"  => ta.ema(src_ma, len_ma)
    "SMA"  => ta.sma(src_ma, len_ma)
    "WMA"  => ta.wma(src_ma, len_ma)
    "HMA"  => ta.hma(src_ma, len_ma)
    "RMA"  => ta.rma(src_ma, len_ma)

median = ta.percentile_nearest_rank(ma, median_len, 50)
atr    = atr_mul * ta.atr(atr_len)
sd_l   = ta.stdev(median, len_sd) * sd_mul
sd_s   = ta.stdev(median, len_sd) * sd_mul_s

L = close > (median - atr) and close >= (median + sd_l)
S = use_sd_s ? close < (median + atr) and close <= (median - sd_s) : close < (median + atr)

long_conf  = math.sum(L ? 1 : 0, conf_l) >= conf_l
short_conf = math.sum(S ? 1 : 0, conf_s) >= conf_s

if long_conf and not short_conf
    hodl := 1
if short_conf
    hodl := -1
//------------------------------------------------------------PLOTS-------------------------------------------------------------
median_plot = plot(median, "Median", color = hodl == 1 ? color.rgb(0, 200, 255) : color.rgb(255, 0, 0), linewidth = 2)
close_plot  = plot(close, color = na, editable = false)
fill(median_plot, close_plot, color = hodl == 1 ? color.rgb(0, 200, 255, 80) : color.rgb(255, 0, 0, 80))
barcolor(barColoring and hodl == 1 ? color.rgb(0, 200, 255) : barColoring and hodl == -1 ? color.rgb(255, 0, 0) : na)
````
