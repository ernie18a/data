# Detrended Price Oscillator - Valuation and Trend | Astral Vision

- url: https://www.tradingview.com/script/cRKejCke/
- type: indicator
- pine_id: PUB;ce21ab16361140258e93d5ffeb0a6b68
- version: 1.0

## Description

[b]Detrended Price Oscillator - Valuation and Trend | Astral Vision 🌠💠[/b]

The Detrended Price Oscillator removes the dominant trend from price by subtracting a lagged moving average, isolating the cyclical component that trends obscure. 
The result is an oscillator centered around zero that reflects how far price has deviated from its medium-term mean, independent of whether the broader trend is up or down.

This indicator extends the standard DPO with two structural additions. 
First, dynamic overbought and oversold bands are derived from the rolling standard deviation of the DPO itself, making the extremes statistically adaptive rather than fixed. 
Second, an optional moving average smoothing layer can be applied to the DPO before all calculations, reducing noise on lower timeframes. 

Two modes cover different use cases: 
"Extremes" identifies statistically significant deviations from the mean with explicit entry/exit signals, while "Trend" tracks whether the smoothed DPO is above or below its rolling mean as a directional read.

[b]Calculation ⚙️[/b]

`DPO = close − SMA(close, length)[length/2 + 1]`

The lookback shift centers the moving average on the period being measured, removing the trend component while preserving cyclical deviations. An optional EMA or SMA of configurable length can then be applied to the raw DPO.

`Overbought = SMA(DPO, stdLookback) + ob_multiplier × StdDev(DPO, stdLookback)`

`Oversold   = SMA(DPO, stdLookback) − os_multiplier × StdDev(DPO, stdLookback)`

Both bands float dynamically with the evolving distribution of DPO values, tightening during low-volatility periods and expanding during high-volatility ones.

[b]Plots 📊[/b]
[list]
[*]DPO line with 6-layer glow (linewidths 12/8/5/3/2/1, transparencies 88/78/65/50/30/0), colored by active regime
[*]Dynamic overbought and oversold band lines
[*]Rolling mean line
[*]Zero baseline (dashed)
[*]Triangle signals in the panel and on the price chart when DPO crosses back inside a band from an extreme (Extremes mode, signals enabled)
[*]Candle coloring on the price chart by active regime
[*]Background highlight on the price chart when either band is breached (Extremes mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Mode`: Extremes (band-crossing signals) or Trend (mean-relative direction)
[*]`DPO Length`: period of the internal SMA used to detrend price (default 21)
[*]`StDev Lookback`: rolling window for mean and standard deviation of the DPO (default 250)
[*]`Oversold StDev Multiplier`: band distance below the mean (default 1.8)
[*]`Overbought StDev Multiplier`: band distance above the mean (default 2.0)
[*]`Show Signals`: toggles triangle markers for band re-entry crossings
[*]`Use Moving Average` applies a smoothing MA to the DPO before all calculations
[*]`Moving Average Length` : period of the smoothing MA (default 10)
[*]`Moving Average Type`: EMA or SMA
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Hermes. Positive color activates at oversold extremes and above-mean trend; negative color activates at overbought extremes and below-mean trend; neutral applies to the mean line.

[b]Purpose 🎯[/b]

Standard DPO implementations plot a raw oscillator with no threshold logic and no statistical context, leaving the trader to visually judge whether a given deviation is significant or routine. Fixed overbought/oversold levels carry no meaning as market volatility changes over time.

This indicator makes the extremes statistically rigorous: the bands adapt to the actual distribution of DPO values over the chosen lookback, so a breach always represents a genuinely unusual deviation regardless of the prevailing volatility regime. 
The signal markers fire specifically on band re-entries, not on the initial breach, identifying the moment mean reversion has begun rather than flagging the extreme itself. 
The six-layer glow rendering makes the oscillator's position relative to its bands immediately readable at a glance without requiring precise level inspection.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Detrended Price Oscillator - Valuation and Trend | Astral Vision 🌠💠", overlay=false)

group1 = "Settings"
group2 = "Moving Average Settings"
group3 = "Astral Colors"

string mode    = input.string("Extremes", "Mode", ["Extremes", "Trend"], group=group1)
int    length  = input.int(21,    "DPO Length",                          group=group1)
int    std_len = input.int(250,   "StDev Lookback",                      group=group1)
float  os_mult = input.float(1.8, "Oversold StDev Multiplier",  step=0.1, group=group1)
float  ob_mult = input.float(2.0, "Overbought StDev Multiplier", step=0.1, group=group1)
bool   showsig = input.bool(true, "Show Signals",                        group=group1)

bool   usema   = input.bool(true,  "Use Moving Average",                 group=group2)
int    malen   = input.int(10,      "Moving Average Length",              group=group2)
string matype  = input.string("EMA", "Moving Average Type", ["EMA","SMA"], group=group2)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Custom Colors", group=group3)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group3)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

color neu_col = color.rgb(120,120,120)
color blk_col = color.black

int   shift   = length / 2 + 1
float dpo     = close - ta.sma(close, length)[shift]
float ma_dpo  = matype == "EMA" ? ta.ema(dpo, malen) : ta.sma(dpo, malen)
float val     = usema ? ma_dpo : dpo

float val_mean = ta.sma(val,   std_len)
float val_std  = ta.stdev(val, std_len)
float os       = val_mean - os_mult * val_std
float ob       = val_mean + ob_mult * val_std

bool usetrend  = mode == "Trend"
color col_val   = val > ob ? neg_col : val < os ? pos_col : blk_col
color col_trend = val > val_mean ? pos_col : neg_col
color defcol    = usetrend ? col_trend : col_val

color bgcol = val > ob and not usetrend ? color.new(neg_col, 50) :
              val < os and not usetrend ? color.new(pos_col, 50) : na

bool long_sig  = showsig and not usetrend and val[1] < os[1] and val >= os
bool short_sig = showsig and not usetrend and val[1] > ob[1] and val <= ob

plot(ob,       "Overbought Band", color=pos_col,                linewidth=1)
plot(os,       "Oversold Band",   color=neg_col,                linewidth=1)
plot(val_mean, "Mean",            color=color.new(neu_col, 50), linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed, linewidth=1)

plot(val, "Glow L5", color=color.new(defcol, 88), linewidth=12)
plot(val, "Glow L4", color=color.new(defcol, 78), linewidth=8)
plot(val, "Glow L3", color=color.new(defcol, 65), linewidth=5)
plot(val, "Glow L2", color=color.new(defcol, 50), linewidth=3)
plot(val, "Glow L1", color=color.new(defcol, 30), linewidth=2)
plot(val, "DPO",     color=defcol,                linewidth=1)

plotshape(long_sig,  "Long Signal",  shape.triangleup,   location.bottom,   pos_col, size=size.small)
plotshape(short_sig, "Short Signal", shape.triangledown, location.top,      neg_col, size=size.small)

plotshape(long_sig,  "Long Overlay",  shape.triangleup,   location.belowbar, pos_col, size=size.small, force_overlay=true)
plotshape(short_sig, "Short Overlay", shape.triangledown, location.abovebar, neg_col, size=size.small, force_overlay=true)

bgcolor(bgcol, force_overlay=true)

plotcandle(open, high, low, close, "Plot Candle", defcol, defcol, bordercolor=defcol, force_overlay=true)
````
