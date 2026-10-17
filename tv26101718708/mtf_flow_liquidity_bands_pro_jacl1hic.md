# MTF Flow Liquidity Bands PRO

- url: https://www.tradingview.com/script/JaCl1Hic/
- type: indicator
- pine_id: PUB;e1410527157c4b3e9dbfab95173a1251
- version: 1.0

## Description

MTF Flow Liquidity Bands PRO is a smooth multi-timeframe liquidity and flow visualization system designed to map market structure, trend pressure, volatility expansion, and dynamic liquidity zones directly on the price chart.

Unlike traditional EMA channels, Bollinger Bands, or Keltner Channels, this indicator creates organic “breathing” liquidity envelopes that adapt to momentum, volatility flow, and multi-timeframe market structure.

The system was specifically designed for fast-moving markets such as:

NASDAQ / US100
BTCUSD
XAUUSD
major Forex pairs

but it can also be used on most liquid assets.

Core Concept

The indicator models the market as a dynamic liquidity flow system rather than a simple moving average trend.

It combines:

smoothed EMA structure
flow expansion
volatility pressure
multi-timeframe liquidity curves
adaptive envelopes

to create smooth institutional-style market zones.

The result is:

no stair-stepping
no rigid channels
no aggressive EMA noise

Instead, the bands behave like flowing liquidity tunnels.

What The Indicator Shows

The system displays multiple stacked liquidity bands:

Chart TF → local microstructure
x5 → intraday flow
x15 → session trend structure
H1 → dominant trend body
H4 → macro directional flow
D1 → institutional equilibrium / market magnet

Each timeframe acts like a dynamic liquidity layer.

Smaller timeframes react faster.
Higher timeframes react slower and smoother.

How The Bands Work

Each band consists of:

Basis Line
Upper Liquidity Band
Lower Liquidity Band

The bands expand and contract dynamically depending on:

momentum
volatility
flow pressure
trend acceleration

The system does NOT use fixed volatility calculations like Bollinger Bands.

Instead, it measures:

the distance between fast and slow smoothed flows
directional pressure
volatility curvature

This creates organic market envelopes that “breathe” with price action.

What The Colors Mean

Each timeframe has its own color.

Color intensity and transparency help visualize:

active trend flow
weakening momentum
liquidity compression
expansion phases

When bands become tighter:

market compression increases
breakout probability rises

When bands expand:

momentum and volatility increase
trend continuation becomes more likely
How To Trade It
1. Trend Alignment

The strongest trends occur when:

Chart TF
x5
x15
H1

all point in the same direction.

This creates full liquidity alignment.

Example:

all bands rising
all bands stacked upward
price holding above band midlines

→ strong bullish trend environment.

2. Liquidity Compression

When bands tighten and compress:

volatility is decreasing
energy is building

Compression often appears before:

breakouts
NY session expansions
trend acceleration

Tight stacked bands usually indicate:

low volatility equilibrium
upcoming expansion phase
3. Expansion Trading

When bands rapidly widen:

volatility expands
liquidity imbalance appears
directional momentum increases

This is often the best phase for:

trend continuation trades
momentum scalps
breakout entries

Especially on NASDAQ and BTC.

4. Mean Reversion

Price often overextends beyond local bands while still remaining inside higher timeframe bands.

Example:

price aggressively breaks Chart TF band
but H1/H4 bands remain intact

This frequently leads to:

pullbacks
liquidity reversion
trend resets

Higher timeframe bands act like liquidity magnets.

5. Daily Band (D1)

The D1 band is not intended for precise entries.

It acts as:

institutional equilibrium
macro liquidity zone
long-term magnet field

When price reaches extreme distance from the D1 structure:

probability of exhaustion increases
reversals become more likely
Best Use Cases

This system works exceptionally well for:

NASDAQ scalping
BTC momentum trading
Gold trend trading
intraday liquidity analysis

It is especially effective in:

trending markets
momentum environments
volatility expansion phases
Recommended Trading Style

Best suited for:

scalping
intraday trading
momentum trading
trend continuation
liquidity-based execution

Less suitable for:

illiquid assets
extremely choppy low-volume markets
Key Advantages
Smooth non-stepped curves
Organic liquidity structure
Multi-timeframe flow visualization
Dynamic volatility adaptation
Excellent trend clarity
Strong compression/expansion detection
Institutional-style market behavior
Important Notes

This indicator is NOT:

a signal generator
a predictive AI system
an orderflow tool
a volume profile

It is a market structure and liquidity flow framework designed to help traders:

understand trend pressure
identify volatility states
visualize liquidity expansion
trade with higher timeframe flow alignment

rather than against it.

## Source Code

````pine
//@version=6
indicator("MTF Flow Liquidity Bands PRO", overlay=true)

//━━━━━━━━━━━━━━━━━━━ INPUTS
group_chart = "Chart TF"

show_chart = input.bool(true, "Show Chart Band", group=group_chart)
len_chart = input.int(55, "Chart Length", minval=1, group=group_chart)

group_x5 = "x5"

show_x5 = input.bool(true, "Show x5", group=group_x5)
len_x5 = input.int(120, "x5 Length", minval=1, group=group_x5)

group_x15 = "x15"

show_x15 = input.bool(true, "Show x15", group=group_x15)
len_x15 = input.int(250, "x15 Length", minval=1, group=group_x15)

group_h1 = "H1"

show_h1 = input.bool(true, "Show H1", group=group_h1)
len_h1 = input.int(500, "H1 Length", minval=1, group=group_h1)

group_h4 = "H4"

show_h4 = input.bool(true, "Show H4", group=group_h4)
len_h4 = input.int(1200, "H4 Length", minval=1, group=group_h4)

group_d1 = "D1"

show_d1 = input.bool(true, "Show D1", group=group_d1)
len_d1 = input.int(2500, "D1 Length", minval=1, group=group_d1)

group_band = "Band"

band_width = input.float(1.4, "Band Width", step=0.1, group=group_band)

smooth_fast = input.int(5, "Fast Smooth", minval=1, group=group_band)
smooth_slow = input.int(13, "Slow Smooth", minval=1, group=group_band)

group_vis = "Visual"

show_fill = input.bool(true, "Show Fill", group=group_vis)

chart_col = input.color(color.rgb(190,120,40, 80), "Chart Color", group=group_vis)
x5_col = input.color(color.rgb(40,180,220, 80), "x5 Color", group=group_vis)
x15_col = input.color(color.rgb(220,0,255, 80), "x15 Color", group=group_vis)

h1_col = input.color(color.rgb(0,255,140, 80), "H1 Color", group=group_vis)
h4_col = input.color(color.rgb(255,255,0, 80), "H4 Color", group=group_vis)

d1_col = input.color(color.rgb(255,255,255, 80), "D1 Color", group=group_vis)

line_width = input.int(1, "Line Width", minval=1, maxval=5, group=group_vis)

//━━━━━━━━━━━━━━━━━━━ FUNCTION
f_band(_len) =>

    basis =
         ta.ema(
             ta.ema(close, smooth_fast),
             _len
         )

    flow =
         ta.ema(
             math.abs(
                 ta.ema(close, smooth_fast) -
                 ta.ema(close, smooth_slow)
             ),
             _len
         )

    upper =
         ta.ema(
             basis + flow * band_width,
             smooth_fast
         )

    lower =
         ta.ema(
             basis - flow * band_width,
             smooth_fast
         )

    [basis, upper, lower]

//━━━━━━━━━━━━━━━━━━━ BANDS
[basis_c, upper_c, lower_c] = f_band(len_chart)

[basis_5, upper_5, lower_5] = f_band(len_x5)

[basis_15, upper_15, lower_15] = f_band(len_x15)

[basis_h1, upper_h1, lower_h1] = f_band(len_h1)

[basis_h4, upper_h4, lower_h4] = f_band(len_h4)

[basis_d1, upper_d1, lower_d1] = f_band(len_d1)

//━━━━━━━━━━━━━━━━━━━ PLOTS CHART
uc = plot(
     show_chart ? upper_c : na,
     title="Chart Upper",
     color=chart_col,
     linewidth=line_width
)

lc = plot(
     show_chart ? lower_c : na,
     title="Chart Lower",
     color=chart_col,
     linewidth=line_width
)

plot(
     show_chart ? basis_c : na,
     title="Chart Basis",
     color=chart_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ PLOTS x5
u5 = plot(
     show_x5 ? upper_5 : na,
     title="x5 Upper",
     color=x5_col,
     linewidth=line_width
)

l5 = plot(
     show_x5 ? lower_5 : na,
     title="x5 Lower",
     color=x5_col,
     linewidth=line_width
)

plot(
     show_x5 ? basis_5 : na,
     title="x5 Basis",
     color=x5_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ PLOTS x15
u15 = plot(
     show_x15 ? upper_15 : na,
     title="x15 Upper",
     color=x15_col,
     linewidth=line_width
)

l15 = plot(
     show_x15 ? lower_15 : na,
     title="x15 Lower",
     color=x15_col,
     linewidth=line_width
)

plot(
     show_x15 ? basis_15 : na,
     title="x15 Basis",
     color=x15_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ PLOTS H1
uh1 = plot(
     show_h1 ? upper_h1 : na,
     title="H1 Upper",
     color=h1_col,
     linewidth=line_width
)

lh1 = plot(
     show_h1 ? lower_h1 : na,
     title="H1 Lower",
     color=h1_col,
     linewidth=line_width
)

plot(
     show_h1 ? basis_h1 : na,
     title="H1 Basis",
     color=h1_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ PLOTS H4
uh4 = plot(
     show_h4 ? upper_h4 : na,
     title="H4 Upper",
     color=h4_col,
     linewidth=line_width
)

lh4 = plot(
     show_h4 ? lower_h4 : na,
     title="H4 Lower",
     color=h4_col,
     linewidth=line_width
)

plot(
     show_h4 ? basis_h4 : na,
     title="H4 Basis",
     color=h4_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ PLOTS D1
ud1 = plot(
     show_d1 ? upper_d1 : na,
     title="D1 Upper",
     color=d1_col,
     linewidth=line_width
)

ld1 = plot(
     show_d1 ? lower_d1 : na,
     title="D1 Lower",
     color=d1_col,
     linewidth=line_width
)

plot(
     show_d1 ? basis_d1 : na,
     title="D1 Basis",
     color=d1_col,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━ FILLS
fill(
     uc,
     lc,
     color=
         show_fill ?
         chart_col :
         na
)

fill(
     u5,
     l5,
     color=
         show_fill ?
         x5_col :
         na
)

fill(
     u15,
     l15,
     color=
         show_fill ?
         x15_col :
         na
)

fill(
     uh1,
     lh1,
     color=
         show_fill ?
         h1_col :
         na
)

fill(
     uh4,
     lh4,
     color=
         show_fill ?
         h4_col :
         na
)

fill(
     ud1,
     ld1,
     color=
         show_fill ?
         d1_col :
         na
)
````
