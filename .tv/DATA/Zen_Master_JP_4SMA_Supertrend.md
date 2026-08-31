<!-- tradingview-pine-id: PUB;dd4963e32a1c491a9b02bfbb9bc955e1 -->
<!-- tradingviewscripts-format: 1 -->
# Zen Master JP 4SMA + Supertrend

Source: https://www.tradingview.com/script/ePOHfQXI-Zen-Master-JP-4SMA-Supertrend/

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
     title = "Zen Master JP 4SMA + Supertrend",
     shorttitle = "Zen JP 4SMA + ST",
     overlay = true
)

//─────────────────────────────────────────────
// Simple Moving Average Settings
//─────────────────────────────────────────────
smaGroup = "Simple Moving Averages"

smaSource = input.source(
     close,
     "SMA Source",
     group = smaGroup
)

showSMA9 = input.bool(
     true,
     "Show 9 SMA",
     group = smaGroup
)

showSMA21 = input.bool(
     true,
     "Show 21 SMA",
     group = smaGroup
)

showSMA50 = input.bool(
     true,
     "Show 50 SMA",
     group = smaGroup
)

showSMA200 = input.bool(
     true,
     "Show 200 SMA",
     group = smaGroup
)

// Calculate Simple Moving Averages
sma9 = ta.sma(smaSource, 9)
sma21 = ta.sma(smaSource, 21)
sma50 = ta.sma(smaSource, 50)
sma200 = ta.sma(smaSource, 200)

// Plot Simple Moving Averages
plot(
     showSMA9 ? sma9 : na,
     title = "9 SMA",
     color = color.orange,
     linewidth = 1
)

plot(
     showSMA21 ? sma21 : na,
     title = "21 SMA",
     color = color.white,
     linewidth = 1
)

plot(
     showSMA50 ? sma50 : na,
     title = "50 SMA",
     color = color.red,
     linewidth = 1
)

plot(
     showSMA200 ? sma200 : na,
     title = "200 SMA",
     color = color.yellow,
     linewidth = 1
)

//─────────────────────────────────────────────
// Supertrend Settings
//─────────────────────────────────────────────
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
     "Supertrend Factor",
     minval = 0.1,
     step = 0.1,
     group = supertrendGroup
)

bullishColor = input.color(
     color.lime,
     "Bullish Supertrend Color",
     group = supertrendGroup
)

bearishColor = input.color(
     color.red,
     "Bearish Supertrend Color",
     group = supertrendGroup
)

// Calculate Supertrend
[supertrendValue, supertrendDirection] = ta.supertrend(
     supertrendFactor,
     atrLength
)

// Prevent the Supertrend from plotting on the first bar
supertrendValue := barstate.isfirst ? na : supertrendValue

// Plot Bullish Supertrend
plot(
     showSupertrend and supertrendDirection < 0
         ? supertrendValue
         : na,
     title = "Bullish Supertrend",
     color = bullishColor,
     linewidth = 1,
     style = plot.style_linebr
)

// Plot Bearish Supertrend
plot(
     showSupertrend and supertrendDirection > 0
         ? supertrendValue
         : na,
     title = "Bearish Supertrend",
     color = bearishColor,
     linewidth = 1,
     style = plot.style_linebr
)
````
