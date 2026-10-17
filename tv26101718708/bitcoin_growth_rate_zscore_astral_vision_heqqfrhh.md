# Bitcoin Growth Rate Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/HeqQFrhH/
- type: indicator
- pine_id: PUB;25989e92021a4ffc888bf2cea0749c01
- version: 2.0

## Description

[b]Bitcoin Growth Rate Z-Score 🌠💠
[/b]
Measures the spread between Bitcoin's market capitalization and its realized capitalization, then applies Z-Score normalization to quantify how statistically extreme current market sentiment is relative to its own history. 
When the market cap diverges far above realized cap, the network is in aggregate profit and historically approaching distribution territory; when the spread compresses or inverts, it signals deep undervaluation.

[b]Plots 📊[/b]
[list]
[*]Z-Score of the market cap / realized cap spread
[*]Overbought threshold line
[*]Oversold threshold line
[*]Zero midline
[*]Fill highlight when the oscillator enters extreme zones
[*]Background color overlay on the price chart when thresholds are breached
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Method: Normalized (ratio-based spread) or Absolute (raw USD difference)
[*]Z-Score Lookback: normalization window for mean and standard deviation
[*]Overbought Threshold: upper extreme level
[*]Oversold Threshold: lower extreme level
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Hermes.

[b]Purpose 🎯[/b]
The raw MVRV spread fluctuates on an expanding scale as Bitcoin's market cap grows across cycles, making fixed threshold comparisons unreliable. 
Z-Score normalization corrects for this drift, producing readings that are statistically consistent across all market cycles. The Normalized method further removes the USD scale entirely by working with the ratio, making it robust regardless of where BTC price is trading.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Growth Rate Z-Score | Astral Vision 🌠💠", overlay=false)

string group1 = "Settings"
string group2 = "Astral Colors"

string method  = input.string("Normalized", "Method", options=["Normalized","Absolute"], group=group1)
int    z_len   = input.int(730, "Z-Score Lookback", minval=10, group=group1)
float  ob      = input.float(3.5,  "Overbought Threshold", step=0.1, group=group1)
float  os_     = input.float(-1.2, "Oversold Threshold",   step=0.1, group=group1)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,160,0), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,180,120), "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

float mc  = request.security("GLASSNODE:BTC_MARKETCAP",       "D", close)
float mcr = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)

float delta = method == "Normalized" ?
     (not na(mcr) and mcr != 0 ? (mc - mcr) / mcr : na) :
     (mc - mcr)

float mean   = ta.sma(delta,   z_len)
float stdev  = ta.stdev(delta, z_len)
float zscore = stdev > 0 ? (delta - mean) / stdev : na

bool  is_ob = zscore >= ob
bool  is_os = zscore <= os_
bool  is_bull = zscore >= 0

color col = zscore >= ob ? pos_col : zscore < os_ ? neg_col : color.black
color candle_col = is_bull ? pos_col : neg_col

p_hist = plot(zscore, "Z-Score", color=col, linewidth=2)
p_ob   = plot(ob,     "OB",      color=color.new(pos_col, 0), linewidth=2)
p_os   = plot(os_,    "OS",      color=color.new(neg_col, 40), linewidth=2)
plot(0, "Zero", color=color.new(color.rgb(120,120,120), 50), linewidth=1)

bgcolor(is_ob ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(is_os ? color.new(neg_col, 50) : na, force_overlay=true)

fill(p_hist, p_ob, zscore > ob ? pos_col : na)
fill(p_hist, p_os, zscore < os_ ? neg_col : na)
````
