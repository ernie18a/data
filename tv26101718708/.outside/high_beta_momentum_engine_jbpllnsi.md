# High Beta Momentum Engine

- url: https://www.tradingview.com/script/jBPLLnsi-High-Beta-Momentum-Engine/
- type: indicator
- pine_id: PUB;f29f14adb15d4c2e8dd48735e5fb44c0
- version: 1.0

## Description

### High Beta Momentum Engine

The **High Beta Momentum Engine** is a clean, non-repainting momentum indicator designed specifically for volatile, high-beta stocks.

Instead of relying on a single indicator, it combines **trend, momentum, relative strength, volume, volatility, and price action** to identify high-quality momentum breakouts.

### How it works

A **BUY** signal appears only when multiple conditions align:

* **Trend:** Price is above a rising 20 EMA and 50 EMA.
* **Momentum:** RSI is above 55 and increasing.
* **Relative Strength:** The stock is outperforming the selected benchmark.
* **Volume:** Relative volume is above the required threshold.
* **Volatility:** ATR is expanding, indicating increased movement.
* **Breakout:** Price breaks above the previous 20-bar high.

A **SELL** signal uses the opposite conditions:

* Price below a falling EMA structure
* Weakening RSI
* Underperformance versus the benchmark
* Strong selling volume
* Volatility expansion
* Breakdown below the previous 20-bar low

### Signal philosophy

The indicator is intentionally **selective**.

It does not generate a BUY simply because RSI crosses a level or because two moving averages cross. A signal requires several independent pieces of evidence to align.

The goal is to identify moments when a high-beta stock is transitioning from **potential setup → confirmed momentum**, rather than trying to predict every price movement.

### Chart appearance

The indicator is designed to remain simple:

**BUY** and **SELL** labels are displayed directly on the price chart.

The underlying calculations remain hidden so the chart doesn't become cluttered with RSI, MACD, ATR, volume, and multiple moving-average lines.

### Important

This indicator is a **decision-support tool, not a guaranteed prediction system**.

High-beta stocks can move extremely quickly and can produce false breakouts. Always consider market conditions, position size, liquidity, and an appropriate stop-loss before entering a trade.

**Best suited for:** high-beta stocks, momentum trading, break

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © durairaj1936

//@version=6
indicator("High Beta Momentum Engine", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastLen      = input.int(20,  "Fast EMA", minval=1)
slowLen      = input.int(50,  "Slow EMA", minval=2)

rsiLen       = input.int(14,  "RSI Length", minval=2)
rsiBuy       = input.float(55, "RSI Buy Level")
rsiSell      = input.float(45, "RSI Sell Level")

atrLen       = input.int(14,  "ATR Length", minval=2)
atrAvgLen    = input.int(50,  "ATR Average Length", minval=5)

volLen       = input.int(20,  "Volume Average", minval=2)
rvolMin      = input.float(1.5, "Minimum RVOL", step=0.1)

breakoutLen  = input.int(20, "Breakout Lookback", minval=2)

benchmark    = input.symbol("AMEX:SPY", "Benchmark")

cooldownBars = input.int(10, "Signal Cooldown", minval=0)

showEMA      = input.bool(false, "Show EMAs")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Trend
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

// Momentum
rsi = ta.rsi(close, rsiLen)

// Volatility
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrAvgLen)

volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BENCHMARK / RELATIVE STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

benchClose = request.security(
     benchmark,
     timeframe.period,
     close,
     lookahead=barmerge.lookahead_off)

stockReturn = close / close[20] - 1
benchReturn = benchClose / benchClose[20] - 1

relativeStrength = stockReturn > benchReturn

relativeWeakness = stockReturn < benchReturn

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLATILITY EXPANSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

volatilityExpansion = atr > atrAvg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT / BREAKDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Previous resistance/support.
// [1] prevents using the current candle's high/low.
previousHigh = ta.highest(high, breakoutLen)[1]
previousLow  = ta.lowest(low, breakoutLen)[1]

bullBreakout = close > previousHigh
bearBreakdown = close < previousLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTrend =
     close > emaFast and
     emaFast > emaSlow and
     emaFast > emaFast[1]

bearTrend =
     close < emaFast and
     emaFast < emaSlow and
     emaFast < emaFast[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullMomentum =
     rsi > rsiBuy and
     rsi > rsi[1]

bearMomentum =
     rsi < rsiSell and
     rsi < rsi[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

strongVolume = rvol >= rvolMin

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawBuy =
     bullTrend and
     bullMomentum and
     relativeStrength and
     strongVolume and
     volatilityExpansion and
     bullBreakout

rawSell =
     bearTrend and
     bearMomentum and
     relativeWeakness and
     strongVolume and
     volatilityExpansion and
     bearBreakdown

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COOLDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastSignalBar = na

canSignal =
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars

buySignal =
     rawBuy and
     canSignal

sellSignal =
     rawSell and
     canSignal

if buySignal or sellSignal
    lastSignalBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Hidden by default
plot(showEMA ? emaFast : na, "20 EMA")
plot(showEMA ? emaSlow : na, "50 EMA")

// BUY
plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     text="BUY",
     size=size.small)

// SELL
plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     text="SELL",
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buySignal,
     title="High Beta BUY",
     message="High Beta Momentum Engine: BUY signal")

alertcondition(
     sellSignal,
     title="High Beta SELL",
     message="High Beta Momentum Engine: SELL signal")
````
