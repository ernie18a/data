# Rolling Sharpe Ratio Oscillator | Astral Vision 

- url: https://www.tradingview.com/script/2Xz87uME/
- type: indicator
- pine_id: PUB;5b6783900e8048a8abcda6ceb2352860
- version: 1.0

## Description

[b]Rolling Sharpe Ratio Oscillator | Astral Vision 🌠💠[/b]

The Sharpe Ratio measures risk-adjusted return: how much excess return is being generated per unit of volatility. Applied as a rolling oscillator to Bitcoin's daily log returns, it answers a question that neither price nor momentum indicators address: is the current appreciation being earned efficiently relative to the risk being taken, or is it a volatile, noisy move that consumes large drawdowns to produce modest gains?

High rolling Sharpe values indicate sustained, low-volatility uptrends where return per unit of risk is structurally elevated, historically coinciding with the most efficient phases of Bitcoin's bull runs. Negative Sharpe values indicate periods where volatility exceeds returns, marking drawdowns and bear phases. 

This indicator plots the annualized rolling Sharpe as a smoothed oscillator with configurable thresholds, and back-projects those thresholds onto the price chart as dynamic levels representing the price that would produce each Sharpe extreme given current return and volatility conditions.

[b]Calculation ⚙️[/b]

`Log Return = log(close / close[1])`

`Rolling Sharpe = (SMA(Log Return, length) / StdDev(Log Return, length)) × √365`

The ratio is annualized by multiplying by the square root of 365, expressing it in standard annual terms. An EMA of configurable length is then applied to smooth the raw Sharpe before threshold evaluation and coloring.

The price bands invert the Sharpe thresholds back to price space:

`Band Price = close[length] × exp(threshold × StdDev / √365 × length)`

This produces a dynamic price level representing what price would need to be, given current volatility, to produce the specified Sharpe value.

[b]Plots 📊[/b]
[list]
[*]Smoothed Sharpe oscillator line in the indicator panel, colored by regime or continuous gradient
[*]Overbought and oversold threshold lines
[*]Fill between oscillator and overbought threshold when breached (distribution zone)
[*]Fill between oscillator and oversold threshold when breached (accumulation zone)
[*]Dynamic overbought and oversold price bands on the price chart, EMA-smoothed
[*]Candle coloring on the price chart by regime or gradient
[*]Background highlight on the price chart when either threshold is active
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Lookback Period (days)`: rolling window for mean and standard deviation of log returns (default 365)
[*]`Smoothing EMA Length`: EMA applied to the raw Sharpe before all output (default 30)
[*]`Oversold Threshold`: Sharpe level marking risk-adjusted accumulation extremes (default −1.5)
[*]`Overbought Threshold`: Sharpe level marking risk-adjusted distribution extremes (default 2.8)
[*]`Use Gradient Color`: toggles between continuous gradient coloring across the −2 to +2 range and discrete regime-based coloring
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. In gradient mode, color transitions continuously from negative to positive across the Sharpe range. In discrete mode, positive color activates above the overbought threshold, negative below the oversold threshold, and neutral between them.

[b]Purpose 🎯[/b]

Standard momentum indicators like RSI and MACD measure price direction and speed, but are blind to whether that directional move is being achieved efficiently. A 30% Bitcoin rally with 80% annualized volatility carries very different risk-adjusted implications than the same rally with 40% volatility, yet both look identical on a price or momentum chart.

The rolling Sharpe makes that distinction explicit. The price band back-projection eliminates the need to mentally translate Sharpe values into price context: the bands show directly on the chart what price level corresponds to each statistical extreme given current volatility, updating dynamically as the volatility regime evolves. 
The gradient coloring option provides a continuous read of risk-adjusted efficiency across the entire oscillator range, not just at binary threshold crossings.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision

//@version=6
indicator("Rolling Sharpe Ratio Oscillator | Astral Vision 🌠💠", format=format.price, precision=2)

group1 = "Settings"
group2 = "Astral Colors"

int   len        = input.int(365,   "Lookback Period (days)",           group=group1)
int   smooth_len = input.int(30,    "Smoothing EMA Length",             group=group1)
float thresh_os  = input.float(-1.5, "Oversold Threshold",  step=0.1,  group=group1)
float thresh_ob  = input.float(2.8,  "Overbought Threshold", step=0.1, group=group1)
bool  usegrad    = input.bool(true, "Use Gradient Color",              group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.green, "Custom Positive", group=group2)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)

float excess       = math.log(close / close[1])
float mean_excess  = ta.sma(excess, len)
float stdev_excess = ta.stdev(excess, len)
float sharpe       = stdev_excess > 0 ? (mean_excess / stdev_excess) * math.sqrt(365) : na
float sharpe_smooth = ta.ema(sharpe, smooth_len)

color grad        = color.from_gradient(sharpe_smooth, -2, 2, neg_col, pos_col)
color col         = sharpe_smooth > thresh_ob ? pos_col : sharpe_smooth < thresh_os ? neg_col : color.black
color definitecol = usegrad ? grad : col

h1         = plot(thresh_ob,     color=color.new(pos_col, 40), linewidth=1)
h2         = plot(thresh_os,     color=color.new(neg_col, 40), linewidth=1)
sharpeplot = plot(sharpe_smooth, color=definitecol, linewidth=2)

fill(sharpeplot, h2, sharpe_smooth < thresh_os ? color.new(neg_col, 80) : na)
fill(sharpeplot, h1, sharpe_smooth > thresh_ob ? color.new(pos_col, 80) : na)

bgcolor(sharpe_smooth < thresh_os ? color.new(neg_col, 50) : na, force_overlay=true)
bgcolor(sharpe_smooth > thresh_ob ? color.new(pos_col, 50) : na, force_overlay=true)

plotcandle(open, high, low, close, color=definitecol, wickcolor=definitecol, bordercolor=definitecol, force_overlay=true)

float price_ob = close[len] * math.exp(thresh_ob * stdev_excess / math.sqrt(365) * len)
float price_os = close[len] * math.exp(thresh_os * stdev_excess / math.sqrt(365) * len)

plot(ta.ema(price_ob, smooth_len), color=color.new(pos_col, 40), linewidth=1, force_overlay=true)
plot(ta.ema(price_os, smooth_len), color=color.new(neg_col, 40), linewidth=1, force_overlay=true)
````
