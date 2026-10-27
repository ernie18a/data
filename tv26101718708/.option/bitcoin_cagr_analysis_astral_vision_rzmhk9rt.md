# Bitcoin CAGR Analysis | Astral Vision 

- url: https://www.tradingview.com/script/rZmhK9RT/
- type: indicator
- pine_id: PUB;34df34e33d974cfe84b78429c25a1ffa
- version: 1.0

## Description

[b]Bitcoin CAGR Analysis | Astral Vision 🌠💠[/b]

The Compound Annual Growth Rate expresses Bitcoin's return over any rolling window as an annualized percentage, normalizing for the length of the period being measured. 
Unlike raw percentage returns, CAGR makes every rolling window directly comparable regardless of its duration, a 6-month and a 2-year window both output an annualized rate, allowing the current growth pace to be read in consistent units across the entire price history.

This indicator computes rolling CAGR over a configurable lookback, then offers two analytical layers. 
Raw CAGR plots the annualized return directly, revealing how Bitcoin's structural growth rate has evolved across cycles. 
Z-Score mode standardizes the CAGR against its own rolling distribution, identifying when the current annualized return is statistically extreme relative to historical norms, either overheated or deeply compressed. 
A slope-based trend mode colors by whether CAGR is accelerating or decelerating over a secondary lookback, independent of absolute level.

[b]Calculation ⚙️[/b]

`CAGR = (close / close[length])^(365 / days elapsed) − 1`

Days elapsed is derived from the actual timestamp difference rather than a fixed bar count, ensuring accuracy regardless of gaps or non-trading days in the data.

`Z-Score = (CAGR − SMA(CAGR, length)) / StdDev(CAGR, length)`

In Trend mode, the slope is computed as the difference between the current value and its value N bars ago, coloring by whether the CAGR (or its Z-Score) is rising or falling irrespective of its absolute level.

[b]Plots 📊[/b]
[list]
[*]CAGR or Z-Score line in the indicator panel, colored by active regime
[*]Zero baseline
[*]High and low threshold lines in Z-Score Extremes mode
[*]Fill between the signal line and the breached threshold in Z-Score Extremes mode
[*]Candle coloring on the price chart by active regime (Z-Score modes only)
[*]Background highlight on the price chart when a threshold is breached in Z-Score Extremes mode
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Mode`: Raw CAGR (annualized return) or Z-Score (standardized CAGR)
[*]`Visualization`: Extremes (threshold-based coloring) or Trend (slope-based directional coloring)
[*]`Z-Score Length`: rolling window for both CAGR calculation and Z-Score normalization (default 730)
[*]`Threshold High`: Z-Score level marking overheated growth (default 3.0)
[*]`Threshold Low`: Z-Score level marking compressed or negative growth (default −1.5)
[*]`Slope Length`: bar offset used to compute CAGR acceleration in Trend mode (default 34)
[*]`Show Background`: toggles price chart background highlighting at Z-Score extremes
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Infinito. In Extremes mode, positive color activates below the low threshold and negative above the high threshold. In Trend mode, positive color applies when the signal is rising and negative when falling. Raw CAGR mode uses positive color throughout.

[b]Purpose 🎯[/b]

Raw price charts and standard momentum indicators express returns as absolute price levels or bounded oscillators, neither of which answers the question of what annualized return Bitcoin is currently delivering relative to its own historical pace.

CAGR makes that question answerable directly. 
The Z-Score layer adds statistical context: rather than judging whether a 200% annualized return is "high" by intuition, the Z-Score places it in the distribution of all historical CAGR values over the same window, making the assessment rigorous and cycle-independent. 
The Trend visualization mode repurposes the same calculation as a momentum direction indicator, identifying inflection points in the growth rate before they become obvious in price. The two modes together cover both valuation positioning and tactical momentum within a single indicator.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Bitcoin CAGR Analysis | Astral Vision 🌠💠", overlay=false)

string mode     = input.string("Z-Score", "Mode", options=["Raw CAGR","Z-Score"], group="Settings")
string vismode  = input.string("Extremes", "Visualization", options=["Extremes","Trend"], group="Settings")
int    zlen     = input.int(730, "Z-Score Length", minval=10, group="Settings")
float  i_h1     = input.float(3.0,  "Threshold High", step=0.1, group="Settings")
float  i_l1     = input.float(-1.5, "Threshold Low",  step=0.1, group="Settings")
int    slopelen = input.int(34, "Slope Length", minval=1, group="Settings")
bool   showbg   = input.bool(true, "Show Background", group="Settings")
string theme    = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Colors")
bool   usecustom  = input.bool(false, "Use Custom Colors", group="Colors")
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group="Colors")
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative", group="Colors")

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     theme == "Hermes"   ? color.rgb(255,160,0)   : color.rgb(0,210,255)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     theme == "Hermes"   ? color.rgb(0,180,120)  : color.rgb(0,80,160)

color neutral_col = color.black

[btc_close, btc_time] = request.security("INDEX:BTCUSD", "1D", [close, time], lookahead=barmerge.lookahead_off)

float days       = (btc_time - btc_time[zlen]) / 86400000.0
float cagr       = days > 0 ? math.pow(btc_close / btc_close[zlen], 365.0 / days) - 1.0 : na
float zscore_val = ta.stdev(cagr, zlen) != 0 ? (cagr - ta.sma(cagr, zlen)) / ta.stdev(cagr, zlen) : na
float val        = mode == "Raw CAGR" ? cagr : zscore_val

bool  is_raw    = mode == "Raw CAGR"
bool  is_zscore = mode == "Z-Score"
bool  is_ext    = vismode == "Extremes"
bool  is_trend  = vismode == "Trend"

float slope     = val - val[slopelen]

color ext_col   = val >= i_h1 ? neg_col : val <= i_l1 ? pos_col : neutral_col
color trend_col = slope >= 0  ? pos_col : neg_col
color bar_col   = is_raw ? pos_col : is_ext ? ext_col : trend_col

[o, h, l, c] = request.security("INDEX:BTCUSD", "1D", [open, high, low, close], lookahead=barmerge.lookahead_off)

p_val  = plot(val,  "CAGR", color=bar_col, linewidth=2)
p_zero = plot(0.0,  "Zero", color=color.new(color.gray, 60), linewidth=1)

p_h1 = plot(is_zscore and is_ext ? i_h1 : na, "Threshold High", color=neg_col, linewidth=1)
p_l1 = plot(is_zscore and is_ext ? i_l1 : na, "Threshold Low",  color=pos_col, linewidth=1)

fill(p_val, p_h1, color=is_zscore and is_ext and val >= i_h1 ? color.new(neg_col, 50) : na)
fill(p_val, p_l1, color=is_zscore and is_ext and val <= i_l1 ? color.new(pos_col, 50) : na)

bgcolor(showbg and is_ext and is_zscore and val >= i_h1 ? color.new(neg_col, 50) :
     showbg and is_ext and is_zscore and val <= i_l1    ? color.new(pos_col, 50) : na,
     force_overlay=true)

plotcandle(is_raw ? na : o, is_raw ? na : h, is_raw ? na : l, is_raw ? na : c, "Candle",
     wickcolor=bar_col,
     bordercolor=bar_col,
     color=bar_col,
     force_overlay=true)
````
