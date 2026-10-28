# STH and LTH NUPL Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/AxgfHfVs/
- type: indicator
- pine_id: PUB;d5c6c94f0187495f945fda8cf3aa5507
- version: 1.0

## Description

[b]STH and LTH NUPL Z-Score | Astral Vision 🌠💠[/b]

Net Unrealized Profit/Loss (NUPL) measures the aggregate unrealized gain or loss held across the entire Bitcoin supply, expressed as a fraction of market capitalization. It quantifies whether the network as a whole is sitting in profit or loss relative to the price at which each coin last moved on-chain.

This indicator standardizes NUPL statistically, offering two distinct time horizons: a short-term window (default 155 days) that captures intra-cycle sentiment extremes, and a long-term window (default 730 days) that identifies macro cycle tops and bottoms. Both produce a Z-Score that measures how far current NUPL deviates from its historical mean in standard deviation units, making every cycle directly comparable regardless of Bitcoin's price level.

A unique Overlay Bands mode back-projects the Z-Score thresholds onto the price chart as dynamic price levels, derived by inverting the NUPL formula through Realized Cap and circulating supply, showing exactly what price corresponds to each statistical extreme in real time.

[b]Calculation ⚙️[/b]

`NUPL = (Market Cap − Realized Cap) / Market Cap`

`Z-Score = (NUPL − SMA(NUPL, length)) / StdDev(NUPL, length)`

Applied independently with a short-term length (STH) and a long-term length (LTH). The overlay band prices are back-calculated by inverting NUPL at the threshold levels:

`Band Price = Realized Cap / (1 − NUPL_threshold) / Supply`

[b]Plots 📊[/b]
[list]
[*]Z-Score line in the indicator panel, colored by active regime or trend direction depending on visualization mode
[*]Overbought and oversold threshold lines for the active time horizon
[*]Zero midline when Trend mode is active
[*]Overlay Bands projected on the price chart: overbought price level (negative color) and oversold price level (positive color)
[*]Background highlight on the price chart when Z-Score breaches either threshold (Background Color mode)
[*]Candle coloring on the price chart by active regime (Plot Candle mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Time Horizon` switches between Short Term NUPL (STH) and Long Term NUPL (LTH) Z-Score
[*]`Visualization` selects display mode: Background Color, Plot Candle, Trend, or Overlay Bands
[*]`Z-Score Length LTH` : lookback for long-term standardization (default 730)
[*]`Z-Score Length STH` : lookback for short-term standardization (default 155)
[*]`STH OB / OS Threshold` : Z-Score extremes for the short-term window (default +2.2 / −2.7)
[*]`LTH OB / OS Threshold` : Z-Score extremes for the long-term window (default +1.7 / −4.0)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Hermes. Positive color activates at oversold extremes and below-zero trend; negative color activates at overbought extremes and above-zero trend.

[b]Purpose 🎯[/b]

Standard NUPL indicators plot the raw ratio with fixed absolute thresholds, which lose relevance as Bitcoin's market structure evolves across cycles. A level that defined a top in 2017 carries different statistical weight in 2024.

This indicator solves that by standardizing NUPL dynamically, making thresholds statistically consistent across all cycles. The dual time horizon (STH for tactical entries and exits, LTH for macro positioning) gives traders two independent lenses on the same underlying metric. 
The Overlay Bands mode eliminates the need to mentally translate Z-Score levels back to price: the indicator does it directly on the chart, showing the exact price at which NUPL would reach each statistical extreme given the current Realized Cap and supply.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("STH and LTH NUPL Z-Score | Astral Vision 🌠💠", overlay=false)

string group1 = "Mode"
string group2 = "Thresholds"
string group3 = "Astral Colors"

string showsth       = input.string("Short Term NUPL", "Time Horizon", ["Short Term NUPL","Long Term NUPL"], group=group1)
string visualization = input.string("Background Color", "Visualization", ["Background Color","Plot Candle","Trend","Overlay Bands"], group=group1)
int    lengthlth     = input.int(730, "Z-Score Length LTH", group=group1)
int    lengthsth     = input.int(155,  "Z-Score Length STH", group=group1)

float sthob = input.float(2.2,  "STH OB Threshold", group=group2)
float sthos = input.float(-2.7, "STH OS Threshold", group=group2)
float lthob = input.float(1.7,  "LTH OB Threshold", group=group2)
float lthos = input.float(-4, "LTH OS Threshold", group=group2)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.white, "Custom Positive", group=group3)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group3)

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

float MC     = request.security("GLASSNODE:BTC_MARKETCAP",       "D", close, barmerge.gaps_off, barmerge.lookahead_on)
float MCR    = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close, barmerge.gaps_off, barmerge.lookahead_on)
float supply = request.security("GLASSNODE:BTC_SUPPLY",          "D", close, barmerge.gaps_off, barmerge.lookahead_on)

float nupl    = MC != 0 ? (MC - MCR) / MC : na
float sma_sth = ta.sma(nupl, lengthsth)
float std_sth = ta.stdev(nupl, lengthsth)
float sma_lth = ta.sma(nupl, lengthlth)
float std_lth = ta.stdev(nupl, lengthlth)

float sth_z  = std_sth != 0 ? (nupl - sma_sth) / std_sth : na
float nupl_z = std_lth != 0 ? (nupl - sma_lth) / std_lth : na

bool sthplot = showsth       == "Short Term NUPL"
bool lthplot = showsth       == "Long Term NUPL"
bool bgyes   = visualization == "Background Color"
bool canyes  = visualization == "Plot Candle"
bool trndyes = visualization == "Trend"
bool overlay = visualization == "Overlay Bands"

color colsth    = sth_z  > sthob ? neg_col : sth_z  < sthos ? pos_col : color.black
color collth    = nupl_z > lthob ? neg_col : nupl_z < lthos ? pos_col : color.black
color colsthtr  = sth_z  > 0 ? pos_col : neg_col
color collthtrd = nupl_z > 0 ? pos_col : neg_col

color bgcolsth = sth_z  > sthob ? color.new(neg_col, 50) : sth_z  < sthos ? color.new(pos_col, 50) : na
color bgcollth = nupl_z > lthob ? color.new(neg_col, 50) : nupl_z < lthos ? color.new(pos_col, 50) : na

color plotcol      = canyes and sthplot ? colsth : canyes and lthplot ? collth : trndyes and sthplot ? colsthtr : trndyes and lthplot ? collthtrd : na
color panelcol_sth = trndyes ? colsthtr : colsth
color panelcol_lth = trndyes ? collthtrd : collth

float nupl_ob = sthplot ? sma_sth + sthob * std_sth : sma_lth + lthob * std_lth
float nupl_os = sthplot ? sma_sth + sthos * std_sth : sma_lth + lthos * std_lth
float ob_band = (1 - nupl_ob) != 0 and supply != 0 ? MCR / (1 - nupl_ob) / supply : na
float os_band = (1 - nupl_os) != 0 and supply != 0 ? MCR / (1 - nupl_os) / supply : na

plot(sthplot ? sth_z  : na, color=panelcol_sth, linewidth=2)
plot(lthplot ? nupl_z : na, color=panelcol_lth, linewidth=2)

plot(sthplot ? sthob : na, color=color.new(neg_col, 20), linewidth=2)
plot(sthplot ? sthos : na, color=color.new(pos_col, 20), linewidth=2)
plot(lthplot ? lthob : na, color=color.new(neg_col, 20), linewidth=2)
plot(lthplot ? lthos : na, color=color.new(pos_col, 20), linewidth=2)
plot(trndyes ? 0 : na,     color=color.new(color.rgb(120,120,120), 50), linewidth=1)

plot(overlay ? ob_band : na, color=color.new(neg_col, 20), linewidth=1, force_overlay=true)
plot(overlay ? os_band : na, color=color.new(pos_col, 20), linewidth=1, force_overlay=true)

bgcolor(sthplot and bgyes ? bgcolsth : na, force_overlay=true)
bgcolor(lthplot and bgyes ? bgcollth : na, force_overlay=true)

plotcandle(open, high, low, close, "Plot Candle", plotcol, plotcol, bordercolor=plotcol, force_overlay=true)
````
