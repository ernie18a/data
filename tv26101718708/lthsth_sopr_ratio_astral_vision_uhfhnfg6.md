# LTH/STH SOPR Ratio | Astral Vision 

- url: https://www.tradingview.com/script/UhfHnfg6/
- type: indicator
- pine_id: PUB;bffbf6196c4148bfb5c42d190c1a1467
- version: 1.0

## Description

[b]LTH/STH SOPR Ratio | Astral Vision 🌠💠[/b]

The Spent Output Profit Ratio measures whether coins being moved on-chain are doing so at a profit or a loss relative to their acquisition price. 
Separating this metric between long-term and short-term holders reveals a structural divergence in market behavior: long-term holders tend to spend at profit during distribution phases and hold through downturns, while short-term holders are more reactive, spending at loss during capitulation and at profit during momentum-driven rallies.

This indicator computes the ratio between the short-term and long-term EMA of SOPR, expressing how aggressively short-term holder spending behavior is diverging from the long-term baseline. 
When short-term holders are realizing significantly more profit than the long-term average, the ratio rises above 1, a condition historically associated with overheated momentum and distribution. When short-term holders are realizing losses while long-term holders remain in profit, the ratio compresses below 1, historically marking capitulation and accumulation floors.

[b]Calculation ⚙️[/b]

`LTH SOPR = EMA(SOPR, lthlength)`

`STH SOPR = EMA(SOPR, sthlength)`

`Ratio = STH SOPR / LTH SOPR`

`Signal = SMA(Ratio, smooth_len)`

A single raw SOPR series is smoothed at two different EMA lengths to approximate long-term and short-term holder behavior. 
Dividing the faster by the slower produces a ratio oscillating around 1.0, parity between the two cohorts. A final SMA smoothing pass reduces noise before threshold evaluation and coloring.

[b]Plots 📊[/b]
[list]
[*]Smoothed ratio line in the indicator panel, colored by regime or continuous gradient
[*]Fill between the ratio line and the 1.0 parity level
[*]Parity line (1.0), overbought threshold, and oversold threshold
[*]Candle coloring on the price chart by active regime or gradient
[*]Background highlight on the price chart when either threshold is breached
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Length LTH SOPR`: EMA period approximating long-term holder spending behavior (default 200)
[*]`Length STH SOPR`: EMA period approximating short-term holder spending behavior (default 20)
[*]`Smoothing Window`: SMA applied to the ratio before all output (default 10)
[*]`Oversold Threshold`: ratio level marking short-term holder capitulation (default 0.989)
[*]`Overbought Threshold`: ratio level marking short-term holder excess (default 1.017)
[*]`Use Gradient Color`: toggles continuous gradient coloring between thresholds instead of discrete regime coloring
[*]`Overlay BG Transparency`: opacity of the price chart background highlight at extremes (default 60)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Hermes. 
In discrete mode, positive color applies above parity and negative below. In gradient mode, color transitions continuously between the oversold and overbought thresholds. Background and candle coloring follow the same logic.

[b]Purpose 🎯[/b]

Raw SOPR indicators plot a single aggregated series that blends long and short-term holder behavior into one number, obscuring the divergence between the two cohorts that carries the most analytical signal. 
A market where both groups are spending at profit looks identical to one where short-term holders are panic-selling while long-term holders quietly accumulate, yet the two conditions have opposite implications.

This indicator isolates that divergence directly as a ratio, making the relative behavior of the two cohorts the signal rather than their blended average. 
The 1.0 parity level becomes a structural anchor: sustained readings above it identify periods where short-term momentum is running ahead of the long-term baseline, while readings below it identify periods of short-term stress against a stable long-term foundation. 
The gradient coloring option provides a continuous read of the divergence intensity across the entire ratio range without binary threshold jumps.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision

//@version=6
indicator("LTH/STH SOPR Ratio | Astral Vision 🌠💠", format=format.price, precision=4)

group1 = "Settings"
group2 = "Visualization"
group3 = "Astral Colors"

int   lthlength  = input.int(200,   "Length LTH SOPR",       group=group1)
int   sthlength  = input.int(20,    "Length STH SOPR",        group=group1)
int   smooth_len = input.int(10,    "Smoothing Window",        group=group1)
float os_thresh  = input.float(0.989, "Oversold Threshold",   group=group1)
float ob_thresh  = input.float(1.017, "Overbought Threshold", group=group1)
bool  use_grad   = input.bool(false,  "Use Gradient Color",   group=group2)
int   bg_transp  = input.int(60,      "Overlay BG Transparency", minval=0, maxval=100, group=group2)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.green, "Custom Positive", group=group3)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)

float soprraw     = request.security("GLASSNODE:BTC_SOPR", "D", close, barmerge.gaps_off)

float lth_sopr    = ta.ema(soprraw, lthlength)
float sth_sopr    = ta.ema(soprraw, sthlength)
float ratio       = sth_sopr != 0 and not na(lth_sopr) and not na(sth_sopr) ? sth_sopr / lth_sopr : 0.0
float ratio_smooth = ta.sma(ratio, smooth_len)

color grad        = color.from_gradient(ratio_smooth, os_thresh, ob_thresh, neg_col, pos_col)
color trendcol    = ratio_smooth >= 1.0 ? pos_col : neg_col
color colordec    = use_grad ? grad : trendcol
color bgcol       = ratio_smooth < os_thresh ? color.new(pos_col, bg_transp) : ratio_smooth > ob_thresh ? color.new(neg_col, bg_transp) : na

hline(1.0,       "Parity",             color=color.new(color.white, 50), linestyle=hline.style_dotted, linewidth=1)
hline(ob_thresh, "Overbought",         color=color.new(pos_col, 0),      linestyle=hline.style_solid,  linewidth=2)
hline(os_thresh, "Oversold",           color=color.new(neg_col, 0),      linestyle=hline.style_solid,  linewidth=2)

p_ratio = plot(ratio_smooth, "LTH/STH SOPR Ratio", color=use_grad ? grad : trendcol, linewidth=2)
p_one   = plot(1.0, display=display.none)
fill(p_ratio, p_one, top_color=color.new(trendcol, 50), bottom_color=color.new(trendcol, 50))

bgcolor(bgcol, force_overlay=true, title="SOPR Ratio Alert")
plotcandle(open, high, low, close, "Plot Candle", colordec, colordec, bordercolor=colordec, force_overlay=true)
````
