# Goldwave Trend & Extremes | Astral Vision 

- url: https://www.tradingview.com/script/6jBZB8yU/
- type: indicator
- pine_id: PUB;26ff73ac5fa444528893edc857f9abbe
- version: 2.0

## Description

[b]Goldwave Trend & Extremes | Astral Vision 🌠💠[/b]

The Smoothed Moving Average reduces lag compared to a simple moving average while avoiding the whipsaw sensitivity of an EMA, making it particularly suited for trend-following applications where clean crossover signals matter more than immediate reaction to price. 
By measuring the percentage spread between a fast and slow SMMA, this indicator produces a momentum oscillator that is both scale-independent and directly interpretable: positive spread means the fast average is leading the slow, confirming upward trend pressure; negative spread marks the inversion.

Three visualization modes expose different dimensions of the same underlying spread: 
[list]
[*]"SMMA Lines" plots the two averages directly on the price chart with a filled band between them
[*]"Colored Candles" colors price candles by trend direction throughout the chart history
[*]"Extremes" focuses exclusively on statistically significant spread deviations above and below configurable thresholds, filtering out the noise of the trend's middle ground.
[/list]

[b]Calculation ⚙️[/b]

`SMMA(src, length) = (SMMA[1] × (length − 1) + src) / length`

Initialized with a standard SMA on the first bar. Two SMMAss of different lengths are computed and their percentage spread derived:

`Spread % = (Fast SMMA − Slow SMMA) / Slow SMMA × 100`

The spread oscillates around zero, with positive values indicating bullish trend alignment and negative values indicating bearish alignment. Overbought and oversold thresholds define the extreme zones where the spread has stretched beyond its typical range.

[b]Plots 📊[/b]
[list]
[*]Fast and slow SMMA lines on the price chart with a filled band between them (SMMA Lines mode)
[*]Spread percentage oscillator in the indicator panel, colored by trend direction or extreme regime
[*]Zero baseline in the panel
[*]Overbought and oversold threshold lines in the panel (Extremes mode)
[*]Fill between spread and zero baseline in non-Extremes mode
[*]Fill between spread and overbought/oversold thresholds when breached (Extremes mode)
[*]Candle coloring on the price chart by trend direction (Colored Candles mode)
[*]Candle coloring by extreme regime only — neutral shown as black (Extremes mode)
[*]Background highlight on the price chart when spread breaches either threshold (Extremes mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Visualization Mode`: SMMA Lines, Colored Candles, or Extremes
[*]`Fast SMMA Length`: period for the faster smoothed average (default 15)
[*]`Slow SMMA Length`: period for the slower smoothed average (default 29)
[*]`Overbought Threshold`: spread percentage above which the signal is considered extended (default 8.5)
[*]`Oversold Threshold` : spread percentage below which the signal is considered compressed (default −7.0)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. Positive color applies when the fast SMMA leads the slow; negative color applies when the slow leads. In Extremes mode, negative color marks overbought conditions and positive color marks oversold conditions.

[b]Purpose 🎯[/b]

Standard SMMA crossover systems plot two lines and leave threshold definition entirely to the trader's judgment, with no built-in way to distinguish routine crossovers from structurally significant spread extremes. Most spread-based oscillators use fixed absolute thresholds that lose relevance as volatility regimes change.

This indicator separates the three most common use cases, trend following, momentum confirmation, and extreme detection, into distinct visualization modes that share the same underlying calculation, letting traders switch between analytical lenses without changing the indicator. 
The percentage-based spread makes the oscillator scale-independent and directly comparable across all price levels and time periods, so a reading of +8.5% carries the same structural meaning whether Bitcoin is at $10,000 or $100,000.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Goldwave Trend & Extremes | Astral Vision 🌠💠", overlay=false)

smma(src, length) =>
    var float s = na
    s := na(s[1]) ? ta.sma(src, length) : (s[1] * (length - 1) + src) / length
    s

group1 = "Settings"
group2 = "Visualization"
group3 = "Astral Colors"

string mode  = input.string("SMMA Lines", "Visualization Mode",["SMMA Lines", "Colored Candles", "Extremes"], group=group2)
bool showsig = input.bool(true, "Show Signals", group = group2)

int   len1      = input.int(5,   "Fast SMMA Length",    minval=1,   group=group1)
int   len2      = input.int(13,   "Slow SMMA Length",    minval=1,   group=group1)
float ob_thresh = input.float(8.5,  "Overbought Threshold", step=0.1, group=group1)
float os_thresh = input.float(-7.0, "Oversold Threshold",   step=0.1, group=group1)

string theme     = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group3)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group3)

color raw_pos = theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255)  :
     theme == "Hermes"   ? color.rgb(255,160,0)    :
     color.rgb(255,0,0)
color raw_neg = theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)    :
     theme == "Infinito" ? color.rgb(255,220,80)   :
     theme == "Hermes"   ? color.rgb(0,180,120)    :
     color.rgb(120,0,0)

color col_pos = usecustom ? custom_pos : raw_pos
color col_neg = usecustom ? custom_neg : raw_neg

fast = smma(close, len1)
slow = smma(close, len2)

spread_pct = (fast - slow) / slow * 100
is_pos = fast >= slow

bool lines    = mode == "SMMA Lines"
bool candle   = mode == "Colored Candles"
bool extremes = mode == "Extremes"

bool is_ob = spread_pct > ob_thresh
bool is_os = spread_pct < os_thresh

color col = is_pos ? col_pos : col_neg

color bgcol         = is_ob ? col_neg : is_os ? col_pos : na
color candlecol     = candle   ? col : na
color extremes_candle = extremes ? (is_ob ? col_neg : is_os ? col_pos : color.black) : na
color osc_col       = extremes ? (is_ob ? col_neg : is_os ? col_pos : color.black) : col

p_fast = plot(lines ? fast : na, "Fast SMMA", color=col, linewidth=2, force_overlay=true)
p_slow = plot(lines ? slow : na, "Slow SMMA", color=color.new(col, 40), linewidth=1, force_overlay=true)
fill(p_fast, p_slow, color=color.new(col, 82), title="Band Fill")

zero    = plot(0, "Zero", color=color.new(color.white, 70), linewidth=1)
spread  = plot(spread_pct, "Spread", color=osc_col, linewidth=2)
ob_line = plot(extremes ? ob_thresh : na, "OB", color=col_neg)
os_line = plot(extremes ? os_thresh : na, "OS", color=col_pos)

fill(zero, spread, color=extremes ? na : color.new(osc_col,50))
fill(ob_line, spread, color=is_ob ? color.new(col_neg,50) : na)
fill(os_line, spread, color=is_os ? color.new(col_pos,50) : na)

plotcandle(open, high, low, close, "Plot Candle",     candlecol,       candlecol,       bordercolor=candlecol,       force_overlay=true)
plotcandle(open, high, low, close, "Extremes Candle", extremes_candle, extremes_candle, bordercolor=extremes_candle, force_overlay=true)

bgcolor(extremes ? color.new(bgcol, 50) : na, force_overlay=true)

plot(extremes ? ob_thresh : na, color=col_neg)
plot(extremes ? os_thresh : na, color=col_pos)

x = ta.crossunder(spread_pct, ob_thresh)
y = ta.crossover(spread_pct, os_thresh)

plotshape(x, "Short", shape.triangledown, location.abovebar, showsig and extremes ? col_neg : na, force_overlay = true, size = size.small)
plotshape(y, "Long", shape.triangleup, location.belowbar, showsig and extremes ? col_pos : na, force_overlay = true, size = size.small)
````
