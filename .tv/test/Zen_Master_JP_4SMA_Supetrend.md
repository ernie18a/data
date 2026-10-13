<!-- tradingview-pine-id: PUB;df6b6a6dfdcb42d9970d173369626a47 -->
<!-- tradingviewscripts-format: 1 -->
# Zen Master JP 4SMA + Supetrend

Source: https://www.tradingview.com/script/zAGWwGPE-Zen-Master-JP-4SMA-Supertrend/

## Description

**Zen Master JP 4SMA + Supertrend**

The Zen Master JP 4SMA + Supertrend indicator combines four widely used simple moving averages with the Supertrend indicator to provide a clear view of market direction, trend structure, and potential support or resistance areas.

The indicator includes:

* **9 SMA — Orange:** Highlights short-term price momentum.
* **21 SMA — White:** Tracks the near-term trend and potential pullback areas.
* **50 SMA — Red:** Helps identify the intermediate market trend.
* **200 SMA — Yellow:** Represents the long-term trend and broader market bias.
* **Supertrend:** Displays a dynamic trend-following line based on volatility and ATR.

The Supertrend line appears green during bullish conditions and red during bearish conditions. Its ATR length and multiplier can be adjusted in the indicator settings to fit different markets and timeframes.

Traders can use the moving-average alignment to evaluate trend strength. A bullish structure may be present when the shorter moving averages are positioned above the longer moving averages, while the opposite alignment may indicate bearish conditions.

Potential uses include:

* Identifying the overall market trend
* Spotting moving-average support and resistance
* Evaluating pullbacks within an established trend
* Confirming bullish or bearish momentum
* Filtering trade setups using the Supertrend direction

This indicator is intended to provide additional market context and should be used alongside price action, market structure, volume, and proper risk management.

**Disclaimer:** This indicator is for educational and informational purposes only. It does not constitute financial advice or guarantee future market results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheCryptoJefe

//@version=6
indicator(
     title = "Zen Master JP 4SMA + Supetrend",
     shorttitle = "Zen JP 4SMA + ST",
     overlay = true
)

// ─────────────────────────────────────────────
// Moving Average Settings
// ─────────────────────────────────────────────
smaGroup = "Simple Moving Averages"

smaSource = input.source(close, "SMA Source", group = smaGroup)

showSMA9   = input.bool(true, "Show 9 SMA", group = smaGroup)
showSMA21  = input.bool(true, "Show 21 SMA", group = smaGroup)
showSMA50  = input.bool(true, "Show 50 SMA", group = smaGroup)
showSMA200 = input.bool(true, "Show 200 SMA", group = smaGroup)

smaLineWidth = input.int(
     2,
     "SMA Line Width",
     minval = 1,
     maxval = 5,
     group = smaGroup
)

// Calculate SMAs
sma9   = ta.sma(smaSource, 9)
sma21  = ta.sma(smaSource, 21)
sma50  = ta.sma(smaSource, 50)
sma200 = ta.sma(smaSource, 200)

// Plot SMAs
plot(
     showSMA9 ? sma9 : na,
     title = "9 SMA",
     color = color.orange,
     linewidth = smaLineWidth
)

plot(
     showSMA21 ? sma21 : na,
     title = "21 SMA",
     color = color.white,
     linewidth = smaLineWidth
)

plot(
     showSMA50 ? sma50 : na,
     title = "50 SMA",
     color = color.red,
     linewidth = smaLineWidth
)

plot(
     showSMA200 ? sma200 : na,
     title = "200 SMA",
     color = color.yellow,
     linewidth = smaLineWidth
)

// ─────────────────────────────────────────────
// Supertrend Settings
// ─────────────────────────────────────────────
supertrendGroup = "Supertrend"

showSupertrend = input.bool(
     true,
     "Show Supertrend",
     group = supertrendGroup
)

atrLength = input.int(
     10,
     "ATR Length",
     minval = 1,
     group = supertrendGroup
)

supertrendFactor = input.float(
     3.0,
     "Factor",
     minval = 0.1,
     step = 0.1,
     group = supertrendGroup
)

supertrendLineWidth = input.int(
     2,
     "Supertrend Line Width",
     minval = 1,
     maxval = 5,
     group = supertrendGroup
)

bullishColor = input.color(
     color.lime,
     "Bullish Color",
     group = supertrendGroup
)

bearishColor = input.color(
     color.red,
     "Bearish Color",
     group = supertrendGroup
)

// Calculate Supertrend
[supertrendValue, supertrendDirection] =
     ta.supertrend(supertrendFactor, atrLength)

// Prevent plotting on the first chart bar
supertrendValue := barstate.isfirst ? na : supertrendValue

// Plot bullish and bearish sections separately
plot(
     showSupertrend and supertrendDirection < 0
         ? supertrendValue
         : na,
     title = "Bullish Supertrend",
     color = bullishColor,
     linewidth = supertrendLineWidth,
     style = plot.style_linebr
)

plot(
     showSupertrend and supertrendDirection > 0
         ? supertrendValue
         : na,
     title = "Bearish Supertrend",
     color = bearishColor,
     linewidth = supertrendLineWidth,
     style = plot.style_linebr
)
````
