# Bitcoin WMA Bands | Astral Vision 

- url: https://www.tradingview.com/script/puGRq57c/
- type: indicator
- pine_id: PUB;159baaedd3664c4e91de61668edf7376
- version: 1.0

## Description

[b]Bitcoin WMA Bands | Astral Vision 💠🌠[/b]

This indicator constructs a volatility-adjusted band system around a Weighted Moving Average of price, using the standard deviation of logarithmic daily returns as the volatility measure rather than the standard deviation of price itself. The result is a channel whose width adapts dynamically to the current volatility regime, expanding during high-volatility periods and contracting during low-volatility ones, while remaining anchored to the WMA as the structural fair value reference.

[b]Calculation ⚙️[/b]

The base reference line is a Weighted Moving Average of close over a configurable lookback in days. WMA weights recent bars more heavily than older ones using a linearly declining weight schedule, making it more responsive to recent price action than an SMA of the same length while being less erratic than an EMA.

The volatility measure is computed from logarithmic returns: for each bar, the log return is log(close / close[1]). The standard deviation of these log returns over a configurable lookback window is then multiplied by a configurable scale factor to produce the band half-width `s`. Using log returns rather than raw price changes ensures that the volatility measure is proportional across different price levels, making a 5% move at $10,000 and a 5% move at $100,000 contribute equally to the standard deviation.

The four bands are then computed as: band = WMA × exp(±n × s), where n is 1 or 2. The exponential transformation converts the log-space deviation back to price-space, ensuring the bands are multiplicatively symmetric around the WMA rather than additively symmetric. This means the upper and lower bands are equidistant in percentage terms rather than in absolute dollar terms.

The oscillator in the sub-panel is the log ratio of close to the WMA: log(close / WMA), which measures in log-space how far price has deviated from its trend. The same ±1σ and ±2σ levels are plotted in the sub-panel, allowing direct visual comparison of the oscillator's position within the band structure. Candles on the price chart are colored only when price is outside the ±1σ band, leaving them neutral in the fair value zone between the bands.

Crossover signals are generated when the oscillator crosses back inside the ±1σ boundary from outside: a triangle appears above the bar when the oscillator crosses back below the upper +1σ level from above, and below the bar when it crosses back above the lower -1σ level from below.

[b]Plots 📊[/b]
[list]
[*]WMA reference line on the price chart
[*]Four volatility-adjusted bands at ±1σ and ±2σ on the price chart
[*]Candle coloring on the price chart when price is outside the ±1σ band
[*]Background color on the price chart between the ±1σ and ±2σ zones
[*]Re-entry signals: triangle above bar on upper band exit, triangle below bar on lower band exit
[*]Log-ratio oscillator in the sub-panel with matching ±1σ and ±2σ reference lines
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]STH Length: WMA lookback period in days
[*]StDev Length: rolling window for the log return standard deviation
[*]Band Scale: multiplier applied to the standard deviation before computing band width
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard Bollinger Bands apply a fixed standard deviation multiple to a simple moving average computed on raw prices, which means the band width in percentage terms varies across different price levels and the bands do not correctly represent proportional deviations. This indicator applies the volatility measure in log-return space and converts back with the exponential function, producing bands that are geometrically consistent across Bitcoin's full price history. The WMA further reduces the lag of the central reference compared to an SMA, making the band system more responsive to trend changes without introducing the instability of shorter lookbacks.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin WMA Bands | Astral Vision 💠🌠",
     overlay=false, max_bars_back=5000, format=format.price, precision=4)

group1 = "Settings"
group2 = "Astral Colors"

int   sth_len   = input.int(155,   "STH Length (days)", minval=1, group=group1)
int   stdev_len = input.int(365,   "StDev Length",      minval=1, group=group1)
float vol_scale = input.float(10.0, "Band Scale",       step=0.5, group=group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative",  group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)     :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255)  :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)     :
     theme == "Paradiso" ? color.rgb(0,80,160)    :
     theme == "Futura"   ? color.rgb(180,0,255)   :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

color neu_col = color.rgb(120,120,120)

float sth_cb    = ta.wma(close, sth_len)
float log_ret   = math.log(close / close[1])
float stdev_ret = ta.stdev(log_ret, stdev_len)

float s         = stdev_ret * vol_scale
float osc       = math.log(close / sth_cb)

float band_2up  = sth_cb * math.exp( 2.0 * s)
float band_1up  = sth_cb * math.exp( 1.0 * s)
float band_1dn  = sth_cb * math.exp(-1.0 * s)
float band_2dn  = sth_cb * math.exp(-2.0 * s)

bool in_extreme = osc > 1.0 * s or osc < -1.0 * s

color candle_col = osc > 1.0 * s ? pos_col :
                   osc < -1.0 * s ? neg_col : neu_col

bool long_sig  = ta.crossunder(osc, 1.0 * s)
bool short_sig = ta.crossover(osc, -1.0 * s)

float c_open  = in_extreme ? open  : na
float c_high  = in_extreme ? high  : na
float c_low   = in_extreme ? low   : na
float c_close = in_extreme ? close : na

plot(band_2up, "+2σ overlay", color=pos_col,               linewidth=1, force_overlay=true)
plot(band_1up, "+1σ overlay", color=color.new(pos_col,40),  linewidth=1, force_overlay=true)
plot(sth_cb,   "STH CB",      color=neu_col,               linewidth=2, force_overlay=true)
plot(band_1dn, "-1σ overlay", color=color.new(neg_col,40),  linewidth=1, force_overlay=true)
plot(band_2dn, "-2σ overlay", color=neg_col,               linewidth=1, force_overlay=true)

plotcandle(c_open, c_high, c_low, c_close, "Candle", candle_col, candle_col,
     bordercolor=candle_col, force_overlay=true)

plotshape(long_sig,  "Long",  shape.triangledown,   location.abovebar, color=neg_col, size=size.small, force_overlay=true)
plotshape(short_sig, "Short", shape.triangleup, location.belowbar, color=pos_col, size=size.small, force_overlay=true)

plot( 2.0 * s, "+2σ osc", color=pos_col,               linewidth=1)
plot( 1.0 * s, "+1σ osc", color=color.new(pos_col,40),  linewidth=1)
plot(0.0,      "0",       color=neu_col,               linewidth=2)
plot(-1.0 * s, "-1σ osc", color=color.new(neg_col,40),  linewidth=1)
plot(-2.0 * s, "-2σ osc", color=neg_col,               linewidth=1)

plot(osc, "Oscillator", color=candle_col, linewidth=2)



bgcolor(osc >  1.0 * s and osc <= 2.0 * s  ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(osc < -1.0 * s and osc >= -2.0 * s ? color.new(neg_col, 50) : na, force_overlay=true)
````
