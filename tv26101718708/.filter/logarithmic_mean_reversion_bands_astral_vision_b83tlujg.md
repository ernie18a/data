# Logarithmic Mean Reversion Bands | Astral Vision 

- url: https://www.tradingview.com/script/b83tLUJG/
- type: indicator
- pine_id: PUB;22aac310b9344d338d4c8abfcf9594da
- version: 1.0

## Description

[b]Logarithmic Mean Reversion Bands | Astral Vision 🌠💠[/b]

This indicator computes Bollinger Bands in log-price space rather than raw price space, producing a statistically symmetric channel around the geometric mean of Bitcoin's price that correctly represents proportional deviations across all price levels and all market cycles. The oscillator in the sub-panel expresses the current price position in units of standard deviations from the log-mean, providing a normalized reading that is directly comparable regardless of where absolute price is trading.

[b]Calculation ⚙️[/b]

The natural logarithm of Bitcoin's daily close price is taken for each bar. A simple moving average of this log-price series is computed over the configurable lookback window, producing the log-mean. The standard deviation of the log-price series over the same window is then computed.

The geometric mean line plotted on the price chart is the exponential of the log-mean: exp(log_mean). This is the geometric mean of price over the lookback window, which differs from the arithmetic mean in a meaningful way for assets with exponential growth trajectories. The geometric mean weights all proportional moves equally, so a period where price doubled from $1,000 to $2,000 contributes the same to the mean as a period where price doubled from $30,000 to $60,000, which is the correct treatment for a multiplicative process like Bitcoin's price.

The four band levels are computed as: exp(log_mean ± n × log_std), where n is 2.0 or 2.5. The exponential conversion ensures the bands are multiplicatively symmetric: the upper band is the same percentage above the geometric mean as the lower band is below it. This symmetry does not hold for standard Bollinger Bands computed on raw prices, where the upper band is a larger percentage above the mean than the lower band is below it.

The oscillator is the standardized log-price deviation: (log_price - log_mean) / log_std. This is dimensionless and equivalent to a Z-Score of the log-price series, measuring exactly how many standard deviations the current log-price sits above or below its rolling mean. A reading of +2.0 means log-price is two standard deviations above its mean, regardless of the absolute price level.

Reversal signals are generated when the oscillator crosses back inside the ±2.0 standard deviation boundary from outside: a downward triangle appears above the bar when the oscillator crosses back below +2.0 after being above it, and an upward triangle appears below the bar when it crosses back above -2.0 after being below it. These signals identify the moment when extreme deviation begins to revert, rather than the moment of maximum extension.

[b]Plots 📊[/b]
[list]
[*]Geometric mean line on the price chart
[*]Four band lines at ±2.0σ and ±2.5σ on the price chart
[*]Candle coloring on the price chart by band zone: full color outside ±2.5σ, reduced opacity between ±2.0σ and ±2.5σ, neutral between the bands
[*]Z-Score oscillator in the sub-panel with matching ±2.0σ and ±2.5σ reference lines
[*]Fill highlights when oscillator is beyond the outer ±2.5σ level
[*]Static zone fills between the ±2.0σ and ±2.5σ levels
[*]Reversal triangles on the price chart when oscillator crosses back inside the ±2.0σ boundary
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Length: lookback window for the log-mean and log standard deviation
[*]Plot Long/Short Signals: toggle the reversal triangle signals
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard Bollinger Bands applied to raw Bitcoin price produce bands that are not proportionally symmetric and whose standard deviation readings are not statistically consistent across different price levels. A +2σ reading at $1,000 and a +2σ reading at $50,000 on a raw-price Bollinger Band do not carry the same statistical weight because the distribution of raw price changes is not stationary across Bitcoin's history. Computing the bands in log space corrects this: the log-price distribution is much closer to stationary, making the standard deviation thresholds directly comparable across all cycles. The reversal signals add an entry timing dimension by marking the transition from extreme to normalizing rather than the peak of the extreme.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Logarithmic Mean Reversion Bands | Astral Vision 🌠💠", overlay=false)

group1 = "Settings"
group2 = "Astral Colors"

int tmmLen = input.int(155, "Length", minval=50, maxval=1000, group=group1)
bool trian = input.bool(true, "Plot Long/Short Signals")

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative",  group=group2)

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
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

color neu_col = color.black
color blk_col = color.black

float btc_price = request.security("INDEX:BTCUSD", "D", close, barmerge.gaps_off, barmerge.lookahead_on)

float log_price = math.log(btc_price)
float log_mean  = ta.sma(log_price, tmmLen)
float log_sd    = ta.stdev(log_price, tmmLen)
float tmm       = math.exp(log_mean)

float band_2ob  = math.exp(log_mean + 2.0 * log_sd)
float band_25ob = math.exp(log_mean + 2.5 * log_sd)
float band_25os = math.exp(log_mean - 2.5 * log_sd)
float band_2os  = math.exp(log_mean - 2.0 * log_sd)

float osc = log_sd != 0 ? (log_price - log_mean) / log_sd : 0.0

color cndl_col = btc_price >= band_25ob ? pos_col :
                 btc_price >= band_2ob  ? color.new(pos_col, 40) :
                 btc_price <= band_25os ? neg_col :
                 btc_price <= band_2os  ? color.new(neg_col, 40) : blk_col

color osc_col = osc >= 2.5 ? pos_col :
                 osc >= 2.0 ? color.new(pos_col, 40) :
                 osc <= -2.5 ? neg_col :
                 osc <= -2.0 ? color.new(neg_col, 40) : neu_col

plot(tmm,      "Mean",        color=neu_col,                   linewidth=2, force_overlay=true)
plot(band_2ob,  "+2σ",        color=color.new(pos_col, 40),    linewidth=1, force_overlay=true)
plot(band_25ob, "+2.5σ",      color=pos_col,                   linewidth=1, force_overlay=true)
plot(band_25os, "-2.5σ",      color=neg_col,                   linewidth=1, force_overlay=true)
plot(band_2os,  "-2σ",        color=color.new(neg_col, 40),    linewidth=1, force_overlay=true)

plotcandle(open, high, low, close, "Candles", cndl_col, cndl_col, bordercolor=cndl_col, force_overlay=true)

p_osc  = plot(osc,   "Oscillator",  color=osc_col,                linewidth=2)
p_25ob = plot( 2.5,  "+2.5σ",       color=pos_col,                linewidth=1)
p_2ob  = plot( 2.0,  "+2σ",         color=color.new(pos_col, 40), linewidth=1)
p_mid  = plot( 0.0,  "Zero",        color=color.new(neu_col, 50), linewidth=1)
p_2os  = plot(-2.0,  "-2σ",         color=color.new(neg_col, 40), linewidth=1)
p_25os = plot(-2.5,  "-2.5σ",       color=neg_col,                linewidth=1)

fill(p_osc, p_25ob, color=osc >= 2.5  ? color.new(pos_col, 85) : na)
fill(p_osc, p_25os, color=osc <= -2.5 ? color.new(neg_col, 85) : na)
fill(p_2ob, p_25ob, color=color.new(pos_col, 92))
fill(p_2os, p_25os, color=color.new(neg_col, 92))

bool was_above_2ob = osc[1] >= 2.0
bool was_below_2os = osc[1] <= -2.0

bool signal_short = was_above_2ob and osc < 2.0 and trian
bool signal_long  = was_below_2os and osc > -2.0 and trian

plotshape(signal_short, "Short Signal",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = neg_col,
     text     = "",
     textcolor = neg_col,
     size     = size.small,
     force_overlay = true)

plotshape(signal_long, "Long Signal",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = pos_col,
     text     = "",
     textcolor = pos_col,
     size     = size.small,
     force_overlay = true)
````
