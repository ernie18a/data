# Whale Accumulation Index | Astral Vision 

- url: https://www.tradingview.com/script/NB9Gzlb3/
- type: indicator
- pine_id: PUB;3d15cbb28d334e99b70a9f77cbd3fec4
- version: 1.0

## Description

[b]Whale Accumulation Index | Astral Vision 🌠💠[/b]

This indicator tracks the proportion of Bitcoin's total on-chain transaction volume attributable to large transactions, using CoinMetrics data to separate whale-scale activity from retail-scale activity, then applies two different analytical lenses to that ratio to identify when large holders are accumulating or distributing at statistically unusual rates.

[b]Calculation ⚙️[/b]

The base input is the ratio of large transaction volume to total transaction volume in USD, both fetched from CoinMetrics on a daily timeframe. Large transaction volume measures the aggregate USD value of all on-chain transactions above a defined size threshold, while total transaction volume covers all on-chain activity. Dividing the two produces a ratio between 0 and 1 that measures what fraction of all Bitcoin moved on-chain each day was moved by large participants. A rising ratio means whale activity is growing as a share of total network flow; a falling ratio means retail activity is proportionally dominant. This ratio is smoothed with a configurable SMA before all subsequent calculations.

The indicator offers two modes that address different analytical questions.

Z-Score mode normalizes the smoothed ratio against its own rolling mean and standard deviation over a configurable lookback window. The formula is: Z = (ratio - mean(ratio, N)) / stdev(ratio, N). This produces a reading that measures how statistically unusual the current whale dominance level is relative to its own history. A positive Z-Score means whale share of volume is elevated above its historical norm; a negative Z-Score means it is depressed. The thresholds mark the statistically extreme zones where readings have historically been rare.

Conviction mode computes a divergence signal between whale momentum and price momentum. For each series, the rate of change over a configurable lookback is computed as (current - past) / abs(past), producing a proportional momentum measure. Both the price ROC and the whale ratio ROC are then independently Z-Score normalized, and the conviction signal is the difference: whale Z-Score minus price Z-Score. A positive conviction reading means whale activity is accelerating faster than price, historically associated with accumulation ahead of price moves. A negative reading means price is running ahead of whale activity, historically associated with distribution or weak institutional participation in the current price move.

[b]Plots 📊[/b]
[list]
[*]Main oscillator in Z-Score or Conviction mode, colored by threshold zone
[*]Overbought and oversold threshold lines
[*]Fill highlight when oscillator enters either extreme zone
[*]Background color on the price chart when oscillator is in extreme zones
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Mode: Z-Score or Conviction
[*]OB Threshold Z-Score and Conviction: configurable upper extreme levels per mode
[*]OS Threshold Z-Score and Conviction: configurable lower extreme levels per mode
[*]Z-Score Window: normalization lookback for both modes
[*]Smoothing: SMA period applied to the raw whale ratio before calculations
[*]Conviction ROC Length: lookback for the rate of change in Conviction mode
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Inferno.

[b]Purpose 🎯[/b]
Standard volume indicators measure total on-chain or exchange volume without distinguishing between the size of individual transactions, treating a single $100 million transfer the same as ten thousand $10,000 transfers in aggregate volume terms. This indicator isolates the large-transaction component specifically, making it possible to detect when whale-scale capital is disproportionately active on-chain relative to its historical baseline. The Conviction mode adds a second dimension by measuring whether whale activity is leading or lagging price, separating periods where large holders are front-running price moves from periods where they are simply responding to them.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Whale Accumulation Index | Astral Vision 🌠💠", format=format.price, precision=4)

group1 = "Mode"
group2 = "Settings"
group3 = "Astral Colors"

string mode = input.string("Z-Score", "Mode", options=["Z-Score","Conviction"], group=group1)

float ob_z       = input.float(2.2,  "OB Threshold (Z-Score)",    step=0.1, group=group2)
float os_z       = input.float(-1.7, "OS Threshold (Z-Score)",    step=0.1, group=group2)
float ob_c       = input.float(1.5,  "OB Threshold (Conviction)", step=0.1, group=group2)
float os_c       = input.float(-2.2, "OS Threshold (Conviction)", step=0.1, group=group2)
int   zscore_len = input.int(365,    "Z-Score Window",  minval=10, group=group2)
int   smooth_len = input.int(7,      "Smoothing",       minval=1,  group=group2)
int   conv_len   = input.int(30,     "Conviction ROC Length", minval=1, group=group2)

string theme      = input.string("Inferno", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.green, "Custom Positive", group=group3)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)
color neu_col = color.black

float largeTxVol = request.security("COINMETRICS:BTC_LARGETXVOLUME", "1D", close)
float totalVol   = request.security("COINMETRICS:BTC_TXVOLUMEUSD",   "1D", close)
float btc        = request.security("INDEX:BTCUSD",                  "1D", close)

zscore(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s != 0 ? (src - m) / s : 0.0

float ratio      = ta.sma(largeTxVol / totalVol, smooth_len)
float zratio     = zscore(ratio, zscore_len)

float price_roc  = (btc   - btc[conv_len])  / math.abs(btc[conv_len])
float whale_roc  = (ratio - ratio[conv_len]) / math.abs(ratio[conv_len])
float z_price    = zscore(price_roc, zscore_len)
float z_whale    = zscore(whale_roc, zscore_len)
float conviction = z_whale - z_price

float ob = mode == "Z-Score" ? ob_z : ob_c
float os = mode == "Z-Score" ? os_z : os_c

float plot_val = mode == "Z-Score" ? zratio : conviction

color col = plot_val >= ob ? pos_col : plot_val <= os ? neg_col : neu_col

p_val = plot(plot_val, color=col,                        linewidth=2)
p_ob  = plot(ob,       color=color.new(pos_col, 0),      linewidth=1)
p_os  = plot(os,       color=color.new(neg_col, 0),      linewidth=1)

fill(p_val, p_ob, plot_val >= ob ? color.new(pos_col, 80) : na)
fill(p_val, p_os, plot_val <= os ? color.new(neg_col, 80) : na)

bgcolor(plot_val >= ob ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(plot_val <= os ? color.new(neg_col, 50) : na, force_overlay=true)
````
