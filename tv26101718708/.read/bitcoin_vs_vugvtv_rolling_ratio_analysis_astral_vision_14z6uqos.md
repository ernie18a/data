# Bitcoin vs VUG/VTV Rolling Ratio Analysis | Astral Vision 

- url: https://www.tradingview.com/script/14Z6UqoS/
- type: indicator
- pine_id: PUB;eed575161f724d9ab561c870b29eb2f3
- version: 1.0

## Description

[b]Bitcoin vs VUG/VTV Rolling Ratio Analysis | Astral Vision 🌠💠[/b]

This indicator measures the relative momentum of Bitcoin against the VUG/VTV ratio, which is the price of Vanguard's Growth ETF divided by Vanguard's Value ETF. This ratio is one of the most direct and liquid expressions of the growth-versus-value rotation dynamic in institutional equity markets: when VUG outperforms VTV the ratio rises, signaling that markets are rewarding high-multiple, long-duration assets; when VTV outperforms, the ratio falls, signaling a rotation toward defensive, cash-flow-heavy assets typically associated with tightening liquidity or rising rates.

Bitcoin is itself a long-duration, high-beta asset with structural similarities to growth equities: it tends to expand during the same liquidity-driven environments that favor VUG over VTV, and contract during the same risk-off environments that favor VTV over VUG. Tracking the VUG/VTV ratio alongside Bitcoin's own momentum reveals whether the macro environment is confirming or diverging from Bitcoin's price action, which historically has been a more reliable framework for identifying regime shifts than price-only signals.

The indicator operates in three modes. 
[list]
[*]Average Valuation mode averages the normalized momentum of Bitcoin and the VUG/VTV ratio into a single composite score, comparing it against configurable overbought and oversold percentile thresholds to identify when both are simultaneously extended or depressed. 
[*]Average Trend mode compares the composite score against its own midpoint to determine whether aggregate momentum is in its upper or lower historical half. 
[*]Double Signal mode plots Bitcoin and the VUG/VTV ratio momentum separately on the same normalized scale, making divergences between the two directly visible.
[/list]

This is a [b]cross-asset macro momentum and rotation[/b] indicator suited for [b]swing trading and position trading on daily timeframes[/b], functioning as a regime filter that connects Bitcoin's price action to one of the most closely watched equity style rotation signals in institutional markets.

[b]How it differs from standard relative strength tools[/b]

A standard BTC/VUG ratio chart divides prices directly, producing a series with no statistical normalization and no connection to VTV. This indicator uses percentage returns normalized over a rolling window, making readings statistically consistent across different periods, and compares Bitcoin not against a single equity ETF but against the growth-value spread, which is a second-order signal capturing the macro liquidity regime rather than a single sector's performance. The three-mode architecture further distinguishes it from a simple ratio overlay by providing composite valuation, trend, and component-level views within a single indicator.

[b]Plots 📊[/b]
[list]
[*]Averaged normalized momentum oscillator with overbought and oversold threshold lines (Average Valuation mode)
[*]Averaged normalized momentum with fill against the 50 midline (Average Trend mode)
[*]Bitcoin and VUG/VTV normalized momentum plotted separately (Double Signal mode)
[*]Overbought and oversold threshold lines (Average Valuation and Double Signal modes)
[*]50 midline reference
[*]Background color on the price chart when average enters extreme zones (Average Valuation mode)
[*]Candle coloring on the price chart reflecting current regime in all three modes
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Mode: Average Valuation, Average Trend, or Double Signal
[*]Normalization Period: rolling window for the min-max normalization of returns
[*]Lookback Period: return calculation window for both Bitcoin and the VUG/VTV ratio
[*]Overbought Threshold: upper percentile level for extreme zone detection
[*]Oversold Threshold: lower percentile level for extreme zone detection
[*]Transparency: opacity of the background color highlight
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision

//@version=6
indicator("Bitcoin vs VUG/VTV Rolling Ratio Analysis | Astral Vision 🌠💠", overlay=false)

string group1 = "Settings"
string group2 = "Astral Colors"

string mode                = input.string("Average Valuation", "Mode", options=["Average Valuation","Average Trend","Double Signal"], group=group1)
int    normalization_period = input.int(252, "Normalization Period (Bars)", group=group1)
int    lookback             = input.int(60,  "Lookback Period",             group=group1)
int    ob_threshold         = input.int(85,  "Overbought Threshold",        group=group1)
int    os_threshold         = input.int(10,  "Oversold Threshold",          group=group1)
int    transp               = input.int(50,  "Transparency",                group=group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.white, "Custom Positive", group=group2)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group2)

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

color neu_col = color.black

float btc_price   = request.security("INDEX:BTCUSD", timeframe.period, close)
float vug_price   = request.security("AMEX:VUG",     timeframe.period, close)
float vtv_price   = request.security("AMEX:VTV",     timeframe.period, close)
float vugvtv_ratio = vug_price / vtv_price

float btc_ret    = na(btc_price[lookback])    ? na : (btc_price    - btc_price[lookback])    / btc_price[lookback]    * 100
float vugvtv_ret = na(vugvtv_ratio[lookback]) ? na : (vugvtv_ratio - vugvtv_ratio[lookback]) / vugvtv_ratio[lookback] * 100

normalize(src, length) =>
    float mn  = ta.lowest(src,  length)
    float mx  = ta.highest(src, length)
    float rng = mx - mn
    rng > 0 ? (src - mn) / rng * 100 : 50.0

float btc_n    = normalize(btc_ret,    normalization_period)
float vugvtv_n = normalize(vugvtv_ret, normalization_period)
float avg_n    = (btc_n + vugvtv_n) / 2

bool is_valuation = mode == "Average Valuation"
bool is_trend     = mode == "Average Trend"
bool is_double    = mode == "Double Signal"

color avg_val_col   = avg_n > ob_threshold ? neg_col : avg_n < os_threshold ? pos_col : neu_col
color avg_trend_col = avg_n >= 50          ? pos_col : neg_col
color candle_col    = is_valuation ? avg_val_col : is_trend ? avg_trend_col : avg_n >= 50 ? pos_col : neg_col

plot(is_valuation ? avg_n  : na, color=avg_val_col,              linewidth=2)
plot(is_double    ? btc_n  : na, color=pos_col,                  linewidth=2)
plot(is_double    ? vugvtv_n : na, color=neg_col,                linewidth=2)

plot(is_valuation ? ob_threshold : na, color=color.new(neg_col, 20), linewidth=2)
plot(is_valuation ? os_threshold : na, color=color.new(pos_col, 20), linewidth=2)
plot(is_double    ? ob_threshold : na, color=color.new(neg_col, 40), linewidth=1)
plot(is_double    ? os_threshold : na, color=color.new(pos_col, 40), linewidth=1)

p_trend = plot(is_trend ? avg_n : na, color=avg_trend_col, linewidth=2)
p_50    = plot(50, color=color.new(color.rgb(120,120,120), 60), linewidth=1)

fill(p_trend, p_50, is_trend ? (avg_n >= 50 ? color.new(pos_col, 50) : color.new(neg_col, 50)) : na)

bgcolor(is_valuation and avg_n > ob_threshold ? color.new(neg_col, transp) : na, force_overlay=true)
bgcolor(is_valuation and avg_n < os_threshold ? color.new(pos_col, transp) : na, force_overlay=true)

plotcandle(open, high, low, close, "Candles",
     candle_col,
     candle_col,
     bordercolor   = candle_col,
     force_overlay = true)
````
