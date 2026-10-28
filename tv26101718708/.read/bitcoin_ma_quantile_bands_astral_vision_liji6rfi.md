# Bitcoin MA Quantile Bands | Astral Vision 

- url: https://www.tradingview.com/script/LIjI6rFi/
- type: indicator
- pine_id: PUB;e9393a73f5b349d3ae31eda99a5e2db9
- version: 1.0

## Description

[b]Bitcoin MA Quantile Bands | Astral Vision 🌠💠[/b]

This indicator constructs a dynamic price channel around a configurable moving average by computing the statistical distribution of the log ratio between Bitcoin's price and its MA over a long historical lookback, then mapping specific percentiles of that distribution back into price-space bands. The result is a set of bands that adapt to Bitcoin's actual historical price behavior relative to its trend, rather than using fixed multipliers or standard deviations.

[b]Calculation ⚙️[/b]

The moving average is computed on daily Bitcoin price data over a configurable length, with an optional 2-day mode that doubles the effective lookback. Five MA types are available: SMA, EMA, WMA, VWMA, and HMA. The Hull Moving Average is computed as WMA(2 × WMA(src, len/2) - WMA(src, len), sqrt(len)), which reduces lag significantly compared to a standard WMA of the same length.

For each bar, the log ratio is computed as log(price / MA). This transforms the multiplicative relationship between price and MA into an additive one, making the distribution symmetric and comparable across different price magnitudes. A price trading 50% above its MA produces the same absolute log ratio as a price trading 50% below, which a raw ratio would not.

Six percentiles of this log ratio series are then computed over the configurable quantile lookback window using linear interpolation: the 1st, 10th, 35th, 65th, 90th, and 99th percentiles. Each percentile is converted back to a price level by multiplying the MA by the exponential of that percentile value: band price = MA × exp(percentile). This inversion ensures the bands are always centered on the current MA value and scale proportionally with price.

The resulting six levels represent: the 1st percentile (historic bottoms, price has been lower than this only 1% of historical bars), the 10th percentile (oversold), the 35th and 65th percentiles (fair value range, price spends roughly 30% of its time between these two), the 90th percentile (overbought), and the 99th percentile (historic peaks).

The indicator can be computed on 1-day or 2-day bars, with the 2-day mode doubling both the MA length and the quantile lookback to maintain structural equivalence.

[b]Plots 📊[/b]
[list]
[*]Configurable moving average line
[*]Historic Peaks band at the 99th percentile with fill to Overbought
[*]Overbought band at the 90th percentile
[*]Oversold band at the 10th percentile with fill to Historic Bottoms
[*]Historic Bottoms band at the 1st percentile
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Timeframe: 1D or 2D bar mode
[*]MA Length: lookback period for the moving average
[*]MA Type: SMA, EMA, WMA, VWMA, or HMA
[*]Quantile Lookback: historical window over which percentiles are computed
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard Bollinger Bands use fixed standard deviation multiples, which assume a normal distribution of price deviations around the mean. Bitcoin's price distribution relative to its trend is not normal: it has a heavy right tail during bull markets and periodic extreme downside excursions. Computing bands from actual historical percentiles of the log ratio captures this asymmetry directly, placing the overbought and oversold bands exactly where they have historically been meaningful rather than at a theoretically symmetric distance. The log transformation further ensures that the bands scale correctly with price across Bitcoin's full history, avoiding the distortion that linear band methods produce when comparing early and recent market cycles.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin MA Quantile Bands | Astral Vision 🌠💠", overlay=true)

string mode       = input.string("1D", "Timeframe", ["1D", "2D"])
int    ma_len     = input.int(800, "MA Length", minval=10, group="Settings")
string ma_type    = input.string("VWMA", "MA Type", ["SMA","EMA","WMA","VWMA","HMA"], group="Settings")
int    q_len      = input.int(1460, "Quantile Lookback (bars)", minval=200, group="Settings")
string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Colors")
bool   usecustom  = input.bool(false, "Use Custom Colors", group="Colors")
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group="Colors")
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative", group="Colors")
color  macol      = input.color(color.aqua, "MA Color", group="Colors")

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)   :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255):
     theme == "Hermes"   ? color.rgb(255,160,0)  : color.rgb(0,210,255)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     theme == "Hermes"   ? color.rgb(0,180,120)  : color.rgb(0,80,160)

f_hma(src, len) =>
    wma1 = ta.wma(src, len / 2)
    wma2 = ta.wma(src, len)
    ta.wma(2 * wma1 - wma2, math.round(math.sqrt(len)))

f_ma(src, len, type) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "HMA"  => f_hma(src, len)
        => ta.sma(src, len)

float btc = request.security("INDEX:BTCUSD", "1D", close, lookahead=barmerge.lookahead_off)

int   mult   = mode == "2D" ? 2 : 1
int   eff_len = ma_len * mult
int   q_len_  = math.min(q_len * mult, 4999)

float ma200 = f_ma(btc, eff_len, ma_type)

float log_ratio = math.log(btc / ma200)

float q99 = ta.percentile_linear_interpolation(log_ratio, q_len_, 99)
float q90 = ta.percentile_linear_interpolation(log_ratio, q_len_, 90)
float q65 = ta.percentile_linear_interpolation(log_ratio, q_len_, 65)
float q35 = ta.percentile_linear_interpolation(log_ratio, q_len_, 35)
float q10 = ta.percentile_linear_interpolation(log_ratio, q_len_, 10)
float q01 = ta.percentile_linear_interpolation(log_ratio, q_len_,  1)

float b_peak  = ma200 * math.exp(q99)
float b_ob    = ma200 * math.exp(q90)
float b_fv_hi = ma200 * math.exp(q65)
float b_fv_lo = ma200 * math.exp(q35)
float b_os    = ma200 * math.exp(q10)
float b_bot   = ma200 * math.exp(q01)

p_ma   = plot(ma200,  "MA",              color=macol,   linewidth=2)
p_peak = plot(b_peak, "Historic Peaks",  color=neg_col, linewidth=3)
p_ob   = plot(b_ob,   "Overbought",      color=neg_col, linewidth=3)
p_os   = plot(b_os,   "Oversold",        color=pos_col, linewidth=3)
p_bot  = plot(b_bot,  "Historic Bottoms",color=pos_col, linewidth=3)

fill(p_peak, p_ob,  color=color.new(neg_col, 60))
fill(p_os,   p_bot, color=color.new(pos_col, 60))
````
