# USDT Market Cap Stochastic RSI | Astral Vision 

- url: https://www.tradingview.com/script/lFpJWoER/
- type: indicator
- pine_id: PUB;e3c6fe95735b4a19a960aa10455f63ee
- version: 1.0

## Description

[b]USDT Market Cap Stochastic RSI | Astral Vision 🌠💠[/b]

Inspired by @GeoMetric_9 idea.

This indicator applies a Stochastic RSI to the market capitalization of USDT rather than to any price series, producing an oscillator that measures the momentum and cyclical positioning of stablecoin supply expansion and contraction. The underlying logic is that USDT market cap is a direct proxy for the pool of deployable capital sitting on the sidelines of the crypto market: tracking its momentum with a Stochastic RSI reveals whether that capital is accelerating into or out of the ecosystem, which historically precedes or coincides with significant directional moves in Bitcoin and the broader market.

[b]Calculation ⚙️[/b]

The first step is computing a standard RSI on the USDT market cap series over a configurable lookback. The RSI formula measures the average gain relative to the average loss over the period: average gain divided by the sum of average gain and average loss, multiplied by 100. This transforms the raw market cap series into a momentum oscillator bounded between 0 and 100.

The second step applies the Stochastic formula to the RSI values rather than to price. The Stochastic takes the current RSI value, subtracts the lowest RSI value over the stochastic lookback window, and divides by the range between the highest and lowest RSI values over the same window, multiplied by 100. The result, called the raw K line, measures where the current RSI sits within its own recent range, producing a reading that oscillates between 0 and 100 and is more sensitive to short-term reversals than the RSI alone.

The raw K is then smoothed with a simple moving average over the K smoothing period, producing the final K line. A second simple moving average is applied to the smoothed K over the D smoothing period, producing the D signal line. The fill between K and D visualizes their divergence and convergence over time.

The indicator operates on a configurable timeframe independent of the chart, defaulting to weekly, which filters out daily noise in USDT market cap reporting and produces structurally cleaner signals. A configurable midline (default 50) separates bullish from bearish momentum regimes. A signal highlight window activates for a configurable number of bars after K crosses above the midline, marking the early phase of a potential regime shift on the price chart.

[b]Plots 📊[/b]
[list]
[*]K line: smoothed Stochastic of the USDT market cap RSI, colored by regime
[*]D line: signal line smoothed from K
[*]Fill between K and D
[*]Midline reference
[*]Background color in the sub-panel reflecting current bullish or bearish regime
[*]Signal highlight on the price chart for a configurable number of bars after K crosses the midline
[*]Candle coloring on the price chart reflecting the previous bar's K regime
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]RSI Length: lookback for the RSI applied to USDT market cap
[*]Stochastic Length: lookback for the Stochastic applied to the RSI values
[*]K Smoothing: SMA period applied to the raw Stochastic output
[*]D Smoothing: SMA period applied to the smoothed K line
[*]Timeframe: resolution of the USDT market cap data, independent of the chart
[*]Midline: threshold separating bullish and bearish momentum regimes
[*]Signal Highlight Bars: number of bars the price chart highlight remains active after a midline crossover
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
A standard Stochastic RSI applied to Bitcoin price measures Bitcoin's own momentum in isolation. This indicator measures the momentum of an entirely separate variable: the supply of capital available to enter the market. A K line crossing above the midline on weekly timeframe does not mean Bitcoin is going up immediately; it means the rate of stablecoin creation is accelerating relative to its own recent history, which is a structurally earlier and causally distinct signal. Applying the Stochastic RSI rather than a simpler momentum measure adds the cyclical positioning dimension: it shows not just whether USDT supply is growing, but whether that growth is at an extreme or early stage relative to its own historical oscillation range.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("USDT Market Cap Stochastic RSI | Astral Vision 🌠💠", overlay=false)

string group1 = "Stochastic RSI Settings"
string group2 = "Astral Colors"

int    rsi_len     = input.int(100, "RSI Length",              minval=1, group=group1)
int    stoch_len   = input.int(110, "Stochastic Length",       minval=1, group=group1)
int    k_smooth    = input.int(7,  "K Smoothing",             minval=1, group=group1)
int    d_smooth    = input.int(6,  "D Smoothing",             minval=1, group=group1)
string tf          = input.string("W", "Timeframe", options=["D","W","M"], group=group1)
float  mid_level   = input.float(50.0, "Midline", step=1.0,   group=group1)
int    signal_bars = input.int(5, "Signal Highlight Bars", minval=1, maxval=20, group=group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative", group=group2)

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

float usdt_mc = request.security("CRYPTOCAP:USDT", tf, close)

float rsi_val   = ta.rsi(usdt_mc, rsi_len)
float stoch_val = ta.stoch(rsi_val, rsi_val, rsi_val, stoch_len)
float k         = ta.sma(stoch_val, k_smooth)
float d         = ta.sma(k, d_smooth)

bool bull        = k >= mid_level
bool cross_above = ta.crossover(k, mid_level)

var int bars_since_cross = 999
bars_since_cross := cross_above ? 0 : bars_since_cross + 1

bool signal_window = bars_since_cross < signal_bars

color k_col      = bull ? pos_col : neg_col
color candle_col = k[1] >= mid_level ? pos_col : neg_col

plot(mid_level, "Midline", color=color.new(color.rgb(120,120,120), 50), linewidth=1)

p_k = plot(k, "K", color=k_col,                linewidth=2)
p_d = plot(d, "D", color=color.new(k_col, 40), linewidth=1)

fill(p_k, p_d, color=color.new(k_col, 70))

bgcolor(bull          ? color.new(pos_col, 60) : color.new(neg_col, 60), force_overlay=false)
bgcolor(signal_window ? color.new(pos_col, 20) : na,                     force_overlay=true)

plotcandle(open, high, low, close, "Candles",
     candle_col, candle_col,
     bordercolor=candle_col,
     force_overlay=true)
````
