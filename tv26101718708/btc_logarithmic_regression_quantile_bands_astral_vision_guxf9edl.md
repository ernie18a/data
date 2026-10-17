# BTC Logarithmic Regression Quantile Bands | Astral Vision 

- url: https://www.tradingview.com/script/GUxF9edL/
- type: indicator
- pine_id: PUB;459c75d48cd648058338172532490b58
- version: 1.0

## Description

[b]Bitcoin Anchored Regression Quantile Bands | Astral Vision 🌠💠[/b]

This indicator fits a log-linear regression to Bitcoin's price from a configurable anchor date forward, then constructs a dynamic price channel by mapping the historical quantiles of the regression residuals back into price space. The result is a set of bands that adapt to the actual statistical distribution of how far Bitcoin's price has historically deviated above and below its own long-term trend line, rather than using fixed multipliers or standard deviations.

[b]Calculation ⚙️[/b]

The natural logarithm of close is taken for each bar from the anchor date onward. A linear regression is fitted to this log-price series over the full accumulated history from the anchor date up to a configurable maximum bar count, producing a trend line that represents Bitcoin's long-term log-linear growth trajectory from the chosen starting point. Working in log space is essential: Bitcoin's price has expanded across six orders of magnitude, and a linear regression on raw prices would be dominated entirely by recent data. In log space, proportional moves are treated equally across all price levels and all time periods.

The residual at each bar is the difference between the actual log price and the regression trend value: residual = log(close) - trend. This measures in log-space how far price sits above or below its fitted trend at any given moment. A positive residual means price is above trend; a negative residual means price is below trend.

Five quantiles of the residual distribution are then computed over the active history from the anchor date: the 1st and 99th percentiles forming the outer channel, a configurable inner pair (default 5th and 95th) forming the inner channel, and the 50th percentile as the median. Each quantile is converted back to a price level by exponentiating the sum of the trend value and the quantile: band price = exp(trend + quantile). This inversion ensures the bands are always anchored to the current regression trend and scale proportionally with price.

The 50th percentile band represents the median regression price, where historically half of all price observations have been above and half below. The inner bands mark the zone within which the configurable percentage of historical price observations have occurred. The outer 1st and 99th percentile bands mark the historical extremes, where price has spent only 1% of its time beyond each boundary.

[b]Plots 📊[/b]
[list]
[*]Outer upper band at the 99th percentile of residuals
[*]Inner upper band at the configurable upper quantile
[*]Median band at the 50th percentile
[*]Inner lower band at the configurable lower quantile
[*]Outer lower band at the 1st percentile of residuals
[*]Fills between outer and inner bands on both sides
[*]Background color when price is outside the inner band pair
[*]Bar coloring with six gradient levels reflecting position within the channel
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Anchor Date: starting point for the regression, all quantiles are computed from this date forward
[*]Regression Length: maximum bar count used in the regression and quantile computation
[*]Show Fills: toggle the fill between outer and inner bands
[*]Inner Quantile Pair: percentile level for the inner band pair, symmetric around 50
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Purpose 🎯[/b]
Standard Bollinger Bands use a fixed lookback window and assume a normal distribution of price deviations, which does not hold for Bitcoin's log-price residuals. This indicator uses actual empirical quantiles of the full historical residual distribution from the anchor date, making each band level statistically precise: the 99th percentile band has been exceeded by price exactly 1% of the time since the anchor date, which is a more meaningful and verifiable statement than a fixed 2-standard-deviation level. The anchor date architecture also means the bands incorporate the full available price history rather than only a recent rolling window, making them structurally stable references for long-term cycle analysis.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("BTC Logarithmic Regression Quantile Bands | Astral Vision 🌠💠", overlay=true, max_bars_back=5000)

group1 = "Settings"
group2 = "Colors"

anchor_date = input.time(timestamp("2012-01-01"), "Anchor Date", group=group1)
length      = input.int(1200, "Regression Length (bars)", minval=100, group=group1)
show_fills  = input.bool(true, "Show Fills", group=group1)
int qa      = input.int(5, "Inner Quantile Pair", minval=2, maxval=48, group=group1)

string theme      = input.string("Futura", "Color Theme", ["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)
color  mid_col    = input.color(color.rgb(255,255,255,20), "Median Color", group=group2)

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

after_anchor = time >= anchor_date
lp = math.log(close)
max_bars_back(lp, 5000)

var int n = 0
if after_anchor
    n += 1

active_len = math.min(n, length)

trend = after_anchor and active_len > 0 ? ta.linreg(lp, active_len, 0) : float(na)
resid = not na(trend) ? lp - trend : float(na)
max_bars_back(resid, 5000)

qo_lo_r = n >= 2 ? ta.percentile_nearest_rank(resid, active_len, 1)         : float(na)
qo_hi_r = n >= 2 ? ta.percentile_nearest_rank(resid, active_len, 99)        : float(na)
qi_lo_r = n >= 2 ? ta.percentile_nearest_rank(resid, active_len, qa)        : float(na)
qi_hi_r = n >= 2 ? ta.percentile_nearest_rank(resid, active_len, 100 - qa)  : float(na)
q50_r   = n >= 2 ? ta.percentile_nearest_rank(resid, active_len, 50)        : float(na)

qo_lo_v = math.exp(trend + qo_lo_r)
qo_hi_v = math.exp(trend + qo_hi_r)
qi_lo_v = math.exp(trend + qi_lo_r)
qi_hi_v = math.exp(trend + qi_hi_r)
q50_v   = math.exp(trend + q50_r)

p_o_hi = plot(after_anchor ? qo_hi_v : na, "Q99",  color=color.new(poscol,  0), linewidth=2)
p_i_hi = plot(after_anchor ? qi_hi_v : na, "QHi",  color=color.new(poscol, 20), linewidth=1)
p_50   = plot(after_anchor ? q50_v   : na, "Q50",  color=color.new(mid_col, 50), linewidth=1)
p_i_lo = plot(after_anchor ? qi_lo_v : na, "QLo",  color=color.new(negcol, 20), linewidth=1)
p_o_lo = plot(after_anchor ? qo_lo_v : na, "Q1",   color=color.new(negcol,  0), linewidth=2)

fill(p_o_hi, p_i_hi, show_fills ? color.new(poscol, 50) : na)
fill(p_i_lo, p_o_lo, show_fills ? color.new(negcol, 40) : na)

bgcolor(close < qi_lo_v ? color.new(negcol, 50) : close > qi_hi_v ? color.new(poscol, 50) : na)

barcolor(close > qo_hi_v ? color.new(poscol,  0) :
     close > qi_hi_v ? color.new(poscol, 40) :
     close > q50_v   ? color.new(poscol, 70) :
     close > qi_lo_v ? color.new(negcol, 70) :
     close > qo_lo_v ? color.new(negcol, 40) :
     color.new(negcol, 0))
````
