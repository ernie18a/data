# Bitcoin Yardstick Valuation And Trend | Astral Vision 

- url: https://www.tradingview.com/script/4xIVnESU/
- type: indicator
- pine_id: PUB;08ae5692e8304856a805fb053505ee42
- version: 1.0

## Description

[b]Bitcoin Yardstick Valuation and Trend | Astral Vision 🌠💠[/b]

The Bitcoin Yardstick divides market capitalization by hashrate, producing a ratio that expresses how much the market is paying per unit of computational security the network provides. 
When this ratio is elevated, Bitcoin is expensive relative to the mining power securing it, a condition historically associated with speculative excess. 
When compressed, the market is undervaluing the network relative to its security infrastructure, historically marking accumulation opportunities.

This indicator standardizes the Yardstick in log space over a rolling window, producing a Z-Score that makes cycle-to-cycle comparisons statistically rigorous regardless of Bitcoin's absolute price or the long-term growth of hashrate. 
Two visualization modes expose different analytical perspectives on the same signal: 
[list]
[*]"Extremes" identifies statistically significant deviations from the mean with color-coded severity levels.
[*]"Trend" tracks the direction of the smoothed signal's slope to identify momentum shifts before they reach extreme territory.
[/list]

[b]Calculation ⚙️[/b]

`Yardstick = Market Cap / Hashrate`

`Z-Score = (log(Yardstick) − SMA(log(Yardstick), window)) / StdDev(log(Yardstick), window)`

The Z-Score is then smoothed with a 50-bar EMA for the Trend mode, and its slope is computed over a configurable lookback to determine directional momentum.

[b]Plots 📊[/b]
[list]
[*]Z-Score line in the indicator panel with threshold fills at +2σ, +3σ and −2σ (Extremes mode)
[*]Smoothed EMA of the Z-Score (Trend mode)
[*]+3σ, +2σ, −2σ reference lines and zero mean line (Extremes mode)
[*]Candle coloring on the price chart by active regime in both modes
[*]Background highlight on the price chart at +3σ and −2σ extremes (Extremes mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Z-Score Window (bars)`: rolling lookback for mean and standard deviation calculation
[*]`Slope Length`: bar offset for EMA slope computation in Trend mode
[*]`Visualization Mode`: Extremes (threshold-based severity coloring) or Trend (slope-based directional coloring)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override for Trend mode. Default: Paradiso. In Extremes mode, a fixed independent color scale applies: orange at +2σ, red at +3σ, blue at −2σ. In Trend mode, positive color applies when the EMA slope is rising and negative when falling.

[b]Purpose 🎯[/b]

Standard Yardstick implementations plot the raw ratio as an absolute value, which grows monotonically over time as both market cap and hashrate expand, making visual cycle comparison across different price epochs unreliable. 
Log transformation and Z-Score standardization solve this by expressing the current ratio purely as a deviation from its own rolling norm, keeping every cycle on the same statistical scale.

The dual-mode structure separates two distinct use cases: Extremes is suited for identifying macro cycle tops and bottoms where the Yardstick has reached historically rare territory, while Trend provides an earlier directional signal based on the momentum of the smoothed Z-Score before any threshold is breached.
[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Yardstick Valuation And Trend | Astral Vision 🌠💠", overlay=false, max_bars_back=5000)

group1 = "Settings"
group4 = "Colors"

int    z_len     = input.int(730, "Z-Score Window (bars)", group=group1)
int    slope_len = input.int(10,  "Slope Length",          group=group1)
string mode      = input.string("Extremes", "Visualization Mode", ["Extremes","Trend"], group=group1)

string theme      = input.string("Paradiso", "Color Theme", ["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group4)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group4)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group4)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group4)

color poscol = usecustom ? custom_pos :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     theme == "Hermes"   ? color.rgb(255,160,0)   :
     color.rgb(255,0,0)

color negcol = usecustom ? custom_neg :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     theme == "Hermes"   ? color.rgb(0,180,120)  :
     color.rgb(120,0,0)

color neu_col   = color.rgb(120,120,120)
color stdev2col = color.rgb(255,160,0)
color stdev3col = color.rgb(255,0,0)
color stdevncol = color.rgb(0,180,255)

mktcap   = request.security("GLASSNODE:BTC_MARKETCAP", "D", close)
hashrate = request.security("GLASSNODE:BTC_HASHRATE",  "D", close)

valid     = not na(mktcap) and not na(hashrate) and mktcap > 0 and hashrate > 0
raw       = valid ? mktcap / hashrate : float(na)
log_raw   = valid ? math.log(raw)     : float(na)
z_mean    = ta.sma(log_raw, z_len)
z_stdev   = ta.stdev(log_raw, z_len)
yardstick = z_stdev > 0 ? (log_raw - z_mean) / z_stdev : float(na)
emayard   = ta.ema(yardstick, 50)
slope     = (emayard - emayard[slope_len]) / slope_len

color extremes_col = yardstick > 2.8  ? stdev3col :
     yardstick > 2  ? stdev2col :
     yardstick < -2 ? stdevncol :
     color.black

color trend_col  = slope >= 0 ? poscol : negcol
color osc_col    = mode == "Trend" ? trend_col : extremes_col
color candle_col = mode == "Trend" ? trend_col : extremes_col

bool isTrend = mode == "Trend"

p_yard = plot(isTrend ? na      : yardstick, "Yardstick", color=osc_col,              linewidth=2)
p_ema  = plot(isTrend ? emayard : na,        "EMA",       color=trend_col,            linewidth=3)
p_p3   = plot(isTrend ? na      :  2.8,      "+3σ",       color=color.new(stdev3col,0), linewidth=1)
p_p2   = plot(isTrend ? na      :  2.0,      "+2σ",       color=color.new(stdev2col,0), linewidth=1)
p_n2   = plot(isTrend ? na      : -2.0,      "-2σ",       color=color.new(stdevncol,0), linewidth=1)
p_mid  = plot(isTrend ? na      :  0.0,      "Mean",      color=color.new(neu_col,   0), linewidth=1)

fill(p_yard, p_p3, color=not isTrend and yardstick > 3  ? color.new(stdev3col, 70) : na)
fill(p_yard, p_p2, color=not isTrend and yardstick > 2  ? color.new(stdev2col, 70) : na)
fill(p_yard, p_n2, color=not isTrend and yardstick < -2 ? color.new(stdevncol, 70) : na)

bgcolor(not isTrend and yardstick > 3  ? color.new(stdev3col, 50) :
        not isTrend and yardstick < -2 ? color.new(stdevncol, 50) : na, force_overlay=true)

plotcandle(open, high, low, close, "Price", candle_col, candle_col, bordercolor=candle_col, force_overlay=true)
````
