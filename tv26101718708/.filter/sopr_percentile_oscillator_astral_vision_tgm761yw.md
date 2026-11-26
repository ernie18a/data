# SOPR Percentile Oscillator | Astral Vision 

- url: https://www.tradingview.com/script/TgM761YW/
- type: indicator
- pine_id: PUB;59a4d36982654c24ad2a968d55d702ca
- version: 1.0

## Description

[b]SOPR Percentile Oscillator | Astral Vision 🌠💠[/b]

This indicator transforms the Spent Output Profit Ratio into a percentile-ranked oscillator, measuring where today's SOPR reading sits relative to its own history over a configurable lookback window. SOPR is an on-chain metric that divides the realized value of all Bitcoin outputs spent on a given day by their value at the time they were created: a reading above 1.0 means coins are being sold at a profit on aggregate, below 1.0 means coins are being sold at a loss.

[b]Calculation ⚙️[/b]

The raw SOPR is fetched from Glassnode on a daily timeframe. A percentile rank is then computed over a configurable lookback window using `ta.percentrank`, which counts how many of the past N values are lower than the current value and expresses the result as a percentage from 0 to 100. A reading of 85 means the current SOPR is higher than 85% of all daily readings over the lookback period, placing it in historically elevated territory. A reading of 15 means SOPR is lower than 85% of historical readings, placing it in historically depressed territory.

Two simple moving averages are applied to the percentile rank series: a short-term SMA over a configurable window (default 30 days) that captures recent momentum, and a long-term SMA over a configurable window (default 365 days) that represents the structural trend of the percentile rank. The short-term SMA is the primary signal line; the long-term SMA is used in Trend mode as the reference for directional classification.

The indicator operates in two modes. 
[list]
[*]Extremes mode colors the oscillator neutrally between the configurable overbought and oversold percentile thresholds, and highlights only when the short-term SMA enters one of the two extreme zones, also applying background color to the price chart. 
[*]Trend mode compares the short-term SMA against the long-term SMA: when the short is above the long, the regime is bullish; when below, bearish. A fill between the two lines visually represents the spread between short and long-term percentile positioning.
[/list]

[b]Plots 📊[/b]
[list]
[*]Short-term SMA of the SOPR percentile rank, colored by mode and regime
[*]Long-term SMA of the SOPR percentile rank (Trend mode only)
[*]Fill between short and long-term SMA (Trend mode only)
[*]Overbought and oversold percentile threshold lines (Extremes mode only)
[*]Background color on the price chart when short SMA enters extreme zones (Extremes mode)
[*]Candle coloring on the price chart reflecting current regime in both modes
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Mode: Extremes or Trend
[*]Short Term SMA: smoothing window applied to the percentile rank for the signal line
[*]Long Term SMA: smoothing window for the structural trend reference
[*]Lookback: historical window for the percentile rank computation
[*]Overbought Threshold: upper percentile level marking historically elevated SOPR
[*]Oversold Threshold: lower percentile level marking historically depressed SOPR
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Raw SOPR fluctuates around 1.0 on an expanding scale as Bitcoin matures, making fixed absolute thresholds unreliable across different market cycles. Converting to a percentile rank normalizes the series against its own historical distribution, so a percentile reading of 85 in 2017 and a reading of 85 in 2024 are statistically equivalent statements about how extreme current on-chain profit-taking behavior is relative to its own history. The dual SMA structure further separates short-term extremes from structural regime shifts, which are analytically distinct signals that a single moving average cannot distinguish.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("SOPR Percentile Oscillator | Astral Vision 🌠💠", overlay=false)

string mode    = input.string("Extremes", "Mode", ["Extremes", "Trend"], group = "Mode")

int sma30_len  = input.int(30,  "Short Term SMA",      group = "Settings")
int sma365_len = input.int(365, "Long Term SMA",       group = "Settings")
int lookback   = input.int(1460, "Lookback",           group = "Settings")
int obthresh   = input.int(85, "Overbought Threshold", group = "Settings")
int osthresh   = input.int(15, "Oversold Threshold",   group = "Settings")

string theme      = input.string("Paradiso", "Color Theme", ["Inferno", "Paradiso", "Futura", "Infinito", "Hermes"], group = "Colors")
bool   usecustom  = input.bool(false, "Use Custom Colors", group = "Colors")
color  custom_pos = input.color(color.rgb(255, 255, 255), "Custom Positive", group = "Colors")
color  custom_neg = input.color(color.rgb(100, 100, 100), "Custom Negative", group = "Colors")

color theme_pos = theme == "Paradiso" ? color.rgb(0, 210, 255) : theme == "Futura" ? color.rgb(0, 255, 180) : theme == "Infinito" ? color.rgb(180, 120, 255) : theme == "Hermes" ? color.rgb(255, 160, 0) : color.rgb(255, 0, 0)
color theme_neg = theme == "Paradiso" ? color.rgb(0, 80, 160) : theme == "Futura" ? color.rgb(180, 0, 255) : theme == "Infinito" ? color.rgb(255, 220, 80) : theme == "Hermes" ? color.rgb(0, 180, 120) : color.rgb(120, 0, 0)
color bullcol   = usecustom ? custom_pos : theme_pos
color bearcol   = usecustom ? custom_neg : theme_neg

sopr = request.security("GLASSNODE:BTC_SOPR", "1D", close)

bool extremes = mode == "Extremes"
bool trend    = mode == "Trend"

raw    = ta.percentrank(sopr, lookback)
sma30  = ta.sma(raw, sma30_len)
sma365 = ta.sma(raw, sma365_len)

var float sum_r  = 0.0
var float sum_r2 = 0.0
var int   n      = 0
if not na(raw)
    sum_r  += raw
    sum_r2 += raw * raw
    n      += 1
hist_mean = n > 1 ? sum_r / n : na

color bgcol    = sma30 < osthresh ? bullcol : sma30 > obthresh ? bearcol : na
color extrcol  = sma30 < osthresh ? bullcol : sma30 > obthresh ? bearcol : color.black
color trendcol = sma30 > sma365 ? bullcol : bearcol
color defcol   = trend ? trendcol : extrcol

p1 = plot(sma30,   "SMA-30d",     defcol,  2)
p2 = plot(sma365,  "SMA-365d",    trend ? defcol : na, 2)

fill(p1, p2, trend ? color.new(defcol, 70) : na)

ob_line = plot(extremes ? obthresh : na, "OB", bearcol, 1, plot.style_line)
os_line = plot(extremes ? osthresh : na, "OS", bullcol, 1, plot.style_line)
bgcolor(extremes ? color.new(bgcol,50) : na, force_overlay = true)
plotcandle(open,high,low,close, "Plot Candle", defcol, defcol, bordercolor = defcol, force_overlay = true)
````
