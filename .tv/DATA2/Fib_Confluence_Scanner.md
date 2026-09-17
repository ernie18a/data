<!-- tradingview-pine-id: PUB;2ddbd72522674b9e9d8ca0c4ae79b54b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fib Confluence Scanner

Source: https://www.tradingview.com/script/rKsnPJbJ-Fibonacci-Cloud-Multi-Timeframe-Fibonacci-Scanner/

## Description

Fibonacci Cloud stacks three independent retracement grids (short, medium, and long lookback windows) on top of each other and watches for the moments when price sits near multiple levels from multiple grids at once. 

The idea is simple: a fib level that only shows up on one lookback length is easy to dismiss as coincidence, but a zone where the short-term 0.618 lines up with the medium-term 0.5 and the long-term 0.382 is a lot harder to ignore. The script counts how many of the fifteen tracked levels price is currently touching (within a configurable tolerance band) and only considers a trade when that confluence count clears your threshold.
From there, two optional filters can sharpen the signal further: an EMA trend filter (only take longs above the trend line, shorts below it) and an RSI momentum filter (skip longs when momentum is deeply negative, skip shorts when it's deeply positive). Both are off/loose by default so the confluence logic itself stays the star of the show — tighten them if you want fewer, higher-conviction trades.

Features

[*]Three-lookback Fibonacci confluence engine (15 levels tracked simultaneously)
[*]Adjustable confluence tolerance and minimum-overlap threshold
[*]Optional EMA trend filter with clean directional fill
[*]Optional RSI momentum filter (confirmation-style, not fade-style)
[*]Long-only / short-only / both trade direction control
[*]Fixed % stop-loss with configurable R:R take-profit
[*]Minimal two-tone visual design — trend fill, soft confluence background tint, triangle entry markers
[*]Built-in alert conditions for both long and short signals

Tips

[*]Start loose (Min Confluent Levels = 1, wide tolerance) to see how many setups the confluence engine finds on your instrument, then tighten gradually rather than starting strict and wondering why trade count is low.
[*]The three lookback lengths (default 20/50/100) are tunable — pairing a short scalping lookback with a much longer swing lookback tends to produce more meaningful confluence zones than three lookbacks bunched close together.
[*]Try disabling the trend filter entirely on ranging instruments and re-enabling it on trending ones — this single toggle changes the strategy's character more than almost any other input.
[*]Backtest the R:R and stop % together rather than in isolation; a looser confluence threshold usually pairs better with a tighter R:R target.

Warnings

[*]This is a mean-reversion/confluence-zone tool, not a breakout system — it will underperform in strongly trending, low-pullback conditions.
[*]Backtest results are historical and do not guarantee future performance. Past performance shown in the strategy tester does not account for slippage, liquidity gaps, or execution differences on your specific broker/exchange.
[*]The looser default settings favor trade frequency over precision — verify the win rate and expectancy for your instrument and timeframe before trading it live.
[*]This script is provided for research and educational purposes only and is not financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitzlocked
//@version=6
strategy("Fib Confluence Scanner", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.05)

// ── Inputs ─────────────────────────────────────────────────
lenA = input.int(20,  "Lookback A (short)",  minval=2, group="Fibonacci Lookbacks")
lenB = input.int(50,  "Lookback B (medium)", minval=2, group="Fibonacci Lookbacks")
lenC = input.int(100, "Lookback C (long)",   minval=2, group="Fibonacci Lookbacks")

tolerancePct   = input.float(0.5, "Confluence Tolerance (%)", minval=0.01, step=0.01, group="Confluence Settings") / 100
minConfluence  = input.int(1, "Minimum Confluent Levels", minval=1, maxval=15, group="Confluence Settings")

useTrendFilter = input.bool(true, "Use EMA Trend Filter", group="Trend Filter")
trendLen       = input.int(50, "Trend EMA Length", minval=1, group="Trend Filter")

useRsiFilter = input.bool(false, "Use RSI Momentum Filter", group="RSI Filter")
rsiLen       = input.int(14, "RSI Length", minval=1, group="RSI Filter")
rsiLongMin   = input.int(45, "RSI Min for Longs", minval=0, maxval=100, group="RSI Filter")
rsiShortMax  = input.int(55, "RSI Max for Shorts", minval=0, maxval=100, group="RSI Filter")

tradeDirection = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"], group="Trade Management")
slPct          = input.float(1.5, "Stop Loss (%)", minval=0.1, step=0.1, group="Trade Management") / 100
tpRR           = input.float(2.0, "Take Profit R:R", minval=0.1, step=0.1, group="Trade Management")
oneTradeAtTime = input.bool(true, "Only One Position At A Time", group="Trade Management")

showBg    = input.bool(true, "Confluence background", group="Display")
showMarks = input.bool(true, "Entry markers", group="Display")

msg_open_long  = input.string("Open Long", "Alert: Open Long", group="Alerts")
msg_open_short = input.string("Open Short", "Alert: Open Short", group="Alerts")
msg_close_long = input.string("Close Long", "Alert: Close Long", group="Alerts")
msg_close_short = input.string("Close Short", "Alert: Close Short", group="Alerts")

// ── Fib level calculation ──────────────────────────────────
fibLevels(len) =>
    hi  = ta.highest(high, len)
    lo  = ta.lowest(low, len)
    rng = hi - lo
    l236 = hi - 0.236 * rng
    l382 = hi - 0.382 * rng
    l500 = hi - 0.5   * rng
    l618 = hi - 0.618 * rng
    l786 = hi - 0.786 * rng
    [l236, l382, l500, l618, l786]

[a236, a382, a500, a618, a786] = fibLevels(lenA)
[b236, b382, b500, b618, b786] = fibLevels(lenB)
[c236, c382, c500, c618, c786] = fibLevels(lenC)

// ── Confluence counter ─────────────────────────────────────
isNear(level) =>
    math.abs(close - level) / close <= tolerancePct

confluenceCount = (isNear(a236) ? 1 : 0) + (isNear(a382) ? 1 : 0) + (isNear(a500) ? 1 : 0) + (isNear(a618) ? 1 : 0) + (isNear(a786) ? 1 : 0) +
                  (isNear(b236) ? 1 : 0) + (isNear(b382) ? 1 : 0) + (isNear(b500) ? 1 : 0) + (isNear(b618) ? 1 : 0) + (isNear(b786) ? 1 : 0) +
                  (isNear(c236) ? 1 : 0) + (isNear(c382) ? 1 : 0) + (isNear(c500) ? 1 : 0) + (isNear(c618) ? 1 : 0) + (isNear(c786) ? 1 : 0)

confluence = confluenceCount >= minConfluence

// ── Trend + RSI filters ────────────────────────────────────
emaTrend = ta.ema(close, trendLen)
trendUp  = close > emaTrend
trendDn  = close < emaTrend

rsiVal     = ta.rsi(close, rsiLen)
rsiLongOK  = not useRsiFilter or rsiVal >= rsiLongMin
rsiShortOK = not useRsiFilter or rsiVal <= rsiShortMax

// ── Trade conditions ───────────────────────────────────────
longAllowed  = tradeDirection != "Short Only"
shortAllowed = tradeDirection != "Long Only"
positionFree = oneTradeAtTime ? strategy.position_size == 0 : true

longCondition  = confluence and (not useTrendFilter or trendUp) and rsiLongOK  and longAllowed  and positionFree
shortCondition = confluence and (not useTrendFilter or trendDn) and rsiShortOK and shortAllowed and positionFree

// ── Style ──
colUp   = color.new(#26a69a, 0)
colDown = color.new(#ef5350, 0)
colMid  = color.new(color.gray, 40)

trendCol = trendUp ? colUp : colDown

// ── Plots ──────────────────────────────────────────────────
pMid  = plot(useTrendFilter ? emaTrend : na, "Trend EMA", color=colMid, linewidth=1)
pFast = plot(b500, "Fib 0.5 (medium)", color=trendCol, linewidth=2)

fill(pFast, pMid, color=color.new(trendUp ? colUp : colDown, 88), title="Trend fill")

bgcolor(showBg and confluence ? color.new(confluenceCount >= minConfluence + 1 ? colUp : colMid, 90) : na, title="Confluence background")

plotshape(showMarks and longCondition,  "Long",  shape.triangleup,   location.belowbar, colUp,   size=size.small)
plotshape(showMarks and shortCondition, "Short", shape.triangledown, location.abovebar, colDown, size=size.small)

// ── Orders ─────────────────────────────────────────────────
if longCondition
    strategy.entry("Long", strategy.long, alert_message=msg_open_long)

if shortCondition
    strategy.entry("Short", strategy.short, alert_message=msg_open_short)

longStop  = strategy.position_avg_price * (1 - slPct)
longTP    = strategy.position_avg_price * (1 + slPct * tpRR)
shortStop = strategy.position_avg_price * (1 + slPct)
shortTP   = strategy.position_avg_price * (1 - slPct * tpRR)

if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", stop=longStop, limit=longTP, alert_message=msg_close_long)

if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", stop=shortStop, limit=shortTP, alert_message=msg_close_short)
````
