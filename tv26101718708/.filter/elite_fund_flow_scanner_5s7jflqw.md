# Elite Fund Flow Scanner

- url: https://www.tradingview.com/script/5s7JFLQw-Elite-Fund-Flow-Scanner/
- type: indicator
- pine_id: PUB;4ae28e0716d44165b34802200d2cb4bf
- version: 1.0

## Description

my new baby


whatyall want I'm new here, don't trust this ,ask chat


lets go

## Source Code

````pine
//@version=5
indicator("Elite Fund Flow Scanner", overlay=true)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
sma200Len = input.int(200, "SMA 200")
sma50Len  = input.int(50, "SMA 50")
rsiLen    = input.int(14, "RSI")

volLen    = input.int(20, "Volume Avg Length")
lookback  = input.int(50, "Breakout Lookback")

// Benchmark symbol (SPY for relative strength)
benchmark = input.symbol("SPY", "Benchmark")

// ─────────────────────────────
// INDICATORS (CURRENT STOCK)
// ─────────────────────────────
sma200 = ta.sma(close, sma200Len)
sma50  = ta.sma(close, sma50Len)
rsi    = ta.rsi(close, rsiLen)

avgVol = ta.sma(volume, volLen)
relVol = volume / avgVol

// Breakout structure
priorHigh = ta.highest(high, lookback)
breakout = close > priorHigh

// ─────────────────────────────
// BENCHMARK (SPY RELATIVE STRENGTH)
// ─────────────────────────────
spyClose = request.security(benchmark, timeframe.period, close)
spySMA50 = request.security(benchmark, timeframe.period, ta.sma(close, sma50Len))
spySMA200 = request.security(benchmark, timeframe.period, ta.sma(close, sma200Len))

// Relative strength vs SPY
stockPerf = close / close[10]
spyPerf   = spyClose / spyClose[10]
relativeStrength = stockPerf / spyPerf

rsStrong = relativeStrength > 1.02  // outperforming SPY

// ─────────────────────────────
// MARKET REGIME FILTER
// ─────────────────────────────
bullMarket = spySMA50 > spySMA200

// ─────────────────────────────
// INSTITUTIONAL CONDITIONS
// ─────────────────────────────

// Trend alignment (big money bias)
trend = close > sma200 and sma50 > sma200

// Volume inflow (fund participation)
fundFlow = relVol > 1.3

// Momentum confirmation
momentum = rsi > 50 and ta.rising(rsi, 3)

// Breakout quality
strongBreakout = breakout and relVol > 1.8

// Accumulation signature (quiet buying)
accumulation = close > sma200 and close < sma200 * 1.05

// ─────────────────────────────
// FUND FLOW SCORE (0–5)
// ─────────────────────────────
score =
     (trend ? 1 : 0) +
     (fundFlow ? 1 : 0) +
     (momentum ? 1 : 0) +
     (rsStrong ? 1 : 0) +
     (bullMarket ? 1 : 0)

// ─────────────────────────────
// FINAL SIGNALS
// ─────────────────────────────
eliteSetup = score >= 4 and accumulation
eliteBreakout = score >= 4 and strongBreakout

// ─────────────────────────────
// VISUALS
// ─────────────────────────────
plot(sma200, color=color.orange, linewidth=2, title="SMA 200")
plot(sma50, color=color.blue, linewidth=2, title="SMA 50")

plotshape(eliteSetup,
     title="Elite Setup",
     location=location.belowbar,
     style=shape.circle,
     size=size.tiny,
     color=color.yellow,
     text="FLOW")

plotshape(eliteBreakout,
     title="Elite Breakout",
     location=location.belowbar,
     style=shape.triangleup,
     size=size.large,
     color=color.lime,
     text="FUNDS")

bgcolor(eliteBreakout ? color.new(color.green, 80) :
       eliteSetup ? color.new(color.yellow, 88) : na)

// ─────────────────────────────
// ALERTS
// ─────────────────────────────
alertcondition(eliteSetup, title="Fund Flow Setup",
     message="Elite Fund Flow SETUP forming on {{ticker}}")

alertcondition(eliteBreakout, title="Fund Flow Breakout",
     message="ELITE BREAKOUT with fund flow on {{ticker}}")
````
