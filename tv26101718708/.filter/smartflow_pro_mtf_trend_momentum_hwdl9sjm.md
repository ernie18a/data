# SmartFlow Pro  MTF Trend  Momentum

- url: https://www.tradingview.com/script/hwDl9sjm-SmartFlow-Pro-MTF-Trend-Momentum/
- type: indicator
- pine_id: PUB;a9b7af65f49443ba86aeafc98f6be640
- version: 1.0

## Description

Smart Flow Pro is a multi-timeframe (MTF) trend-following and momentum confirmation system built around a layered moving average ribbon combined with momentum divergence and higher-timeframe bias filtering.

Its main purpose is to:

Identify institutional-style trend direction
Filter out low-quality trades using multi-timeframe confirmation
Time entries using MA crossovers + momentum alignment
Visually display market structure through a trend ribbon system
Provide a dashboard-based bias map across higher timeframes

In simple terms:

It is a trend + momentum confluence engine designed to only take trades when multiple layers of trend agree.

2. What It Is Made Of (Core Components)

Smart Flow Pro is built from 5 major systems:

 A. Moving Average Ribbon System (Core Trend Engine)

It uses 3 moving averages:

Fast MA (default 8)
Slow MA (default 21)
Trend MA (default 50)

You can choose:

EMA
SMA
WMA
HMA

 Trend Logic:
Bullish trend: Fast > Slow > Trend
Bearish trend: Fast < Slow < Trend
 Visual Output:
Green ribbon = bullish structure
Red ribbon = bearish structure
Gray = consolidation / unclear structure

 This acts as the primary market structure filter

 B. Momentum Engine (Trend Strength Filter)

Built using:

EMA 14 (fast momentum)
EMA 42 (slow momentum)
Signal smoothing EMA 9

 Logic:
Momentum = EMA14 − EMA42
Signal line confirms direction
Histogram shows acceleration
 Bull Condition:
Momentum > 0
Momentum above signal
 Bear Condition:
Momentum < 0
Momentum below signal

 This prevents entries during weak or fake trend shifts.

 C. Multi-Timeframe (MTF) Bias System

The system evaluates:

Weekly (W)
Daily (D)
4H (H4)
1H (H1)

Each timeframe checks the same ribbon structure:
Fast / Slow / Trend alignment

 Purpose:
Confirms whether higher timeframes support your trade direction
Acts as a “big picture filter”
 
D. Signal Engine (Entry Logic)
 BUY Signal:

Triggered when:

Fast MA crosses above Slow MA
Momentum is bullish
Daily bias is bullish (optional filter)
 SELL Signal:

Triggered when:

Fast MA crosses below Slow MA
Momentum is bearish
Daily bias is bearish (optional filter)

This ensures trades only happen during:

Trend shift OR continuation with confirmation
 E. Visual + Decision Tools

1. Background Color
Green tint = bullish environment
Red tint = bearish environment

2. Entry Arrows
Up arrow = buy signal
Down arrow = sell signal
3. Dashboard (MTF Bias Table)

Displays:

Weekly bias
Daily bias
4H bias
1H bias
Momentum state

Primary Purpose:

Catch high-probability trend continuation and early trend shift entries

Secondary Purposes:
-Filter out choppy markets
-Avoid counter-trend trading mistakes
-Align entries with higher timeframe structure
-Confirm momentum before entry
-Reduce overtrading

Optimal Timeframes:
-5-minute (M5) → scalping entries
-15-minute (M15) → best balance (recommended)
-1-hour (H1) → swing confirmation entries

Best Markets to Trade

Smart Flow Pro works best in:

 High liquidity / trending markets:
Forex majors (EURUSD, GBPUSD, USDJPY)
Indices (NAS100, SPX500, US30)
Crypto (BTC, ETH)

 Avoid:
Low liquidity altcoins
Illiquid stocks
Sideways penny markets

6. Best Trading Sessions
- 1. London Session (BEST)
Strongest institutional momentum
Cleanest breakouts
Best trend follow-through

- 2. New York Session
High volatility
Strong continuation after London
Best for momentum trades

-3. London–NY Overlap (Elite Window)
Maximum volume
Fastest moves
Highest win-rate potential

## Source Code

````pine
//@version=6
indicator("SmartFlow Pro — MTF Trend + Momentum", shorttitle="SmartFlow Pro", overlay=true, max_bars_back=500)

// ─── INPUTS ───
grp1 = "── Ribbon Settings ──"
fastLen = input.int(8, "Fast MA Length", minval=1, group=grp1)
slowLen = input.int(21, "Slow MA Length", minval=1, group=grp1)
trendLen = input.int(50, "Trend MA Length", minval=1, group=grp1)
maType = input.string("EMA", "MA Type", options=["EMA","SMA","WMA","HMA"], group=grp1)

grp3 = "── Signal Filters ──"
requireMTFConfirm = input.bool(true, "Require Daily Bias to Match", group=grp3)
showArrows = input.bool(true, "Show Entry Arrows", group=grp3)
showRibbon = input.bool(true, "Show MA Ribbon", group=grp3)
showBG = input.bool(true, "Show Background Color", group=grp3)

grp4 = "── Dashboard ──"
showDash = input.bool(true, "Show MTF Dashboard", group=grp4)
dashPos = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp4)

// ─── MA FUNCTION ───
ma(src, len, t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        => ta.ema(src, len)

// ─── CURRENT TF MAs ───
fast = ma(close, fastLen, maType)
slow = ma(close, slowLen, maType)
trend = ma(close, trendLen, maType)

bullRibbon = fast > slow and slow > trend
bearRibbon = fast < slow and slow < trend

ribbonColor = bullRibbon ? color.new(color.lime, 70) :
     bearRibbon ? color.new(color.red, 70) :
     color.new(color.gray, 85)

f1 = plot(showRibbon ? fast : na, color=color.new(color.lime, 60), linewidth=1)
f2 = plot(showRibbon ? slow : na, color=color.new(color.red, 60), linewidth=1)
plot(showRibbon ? trend : na, color=color.new(color.blue, 40), linewidth=2)
fill(f1, f2, color=ribbonColor)

// ─── MOMENTUM ───
momFast = ta.ema(close, 14)
momSlow = ta.ema(close, 42)
momentum = momFast - momSlow
signal_ = ta.ema(momentum, 9)
hist = momentum - signal_

momBull = momentum > 0 and momentum > signal_
momBear = momentum < 0 and momentum < signal_

// ─── MTF BIAS ───
weeklyFast = request.security(syminfo.tickerid, "W", ma(close, fastLen, maType))
weeklySlow = request.security(syminfo.tickerid, "W", ma(close, slowLen, maType))
weeklyTrend = request.security(syminfo.tickerid, "W", ma(close, trendLen, maType))

dailyFast = request.security(syminfo.tickerid, "D", ma(close, fastLen, maType))
dailySlow = request.security(syminfo.tickerid, "D", ma(close, slowLen, maType))
dailyTrend = request.security(syminfo.tickerid, "D", ma(close, trendLen, maType))

h4Fast = request.security(syminfo.tickerid, "240", ma(close, fastLen, maType))
h4Slow = request.security(syminfo.tickerid, "240", ma(close, slowLen, maType))
h4Trend = request.security(syminfo.tickerid, "240", ma(close, trendLen, maType))

h1Fast = request.security(syminfo.tickerid, "60", ma(close, fastLen, maType))
h1Slow = request.security(syminfo.tickerid, "60", ma(close, slowLen, maType))
h1Trend = request.security(syminfo.tickerid, "60", ma(close, trendLen, maType))

wBull = weeklyFast > weeklySlow and weeklySlow > weeklyTrend
wBear = weeklyFast < weeklySlow and weeklySlow < weeklyTrend
dBull = dailyFast > dailySlow and dailySlow > dailyTrend
dBear = dailyFast < dailySlow and dailySlow < dailyTrend
h4Bull = h4Fast > h4Slow and h4Slow > h4Trend
h4Bear = h4Fast < h4Slow and h4Slow < h4Trend
h1Bull = h1Fast > h1Slow and h1Slow > h1Trend
h1Bear = h1Fast < h1Slow and h1Slow < h1Trend

// ─── SIGNALS ───
buySignal = ta.crossover(fast, slow) and momBull and (requireMTFConfirm ? dBull : true)
sellSignal = ta.crossunder(fast, slow) and momBear and (requireMTFConfirm ? dBear : true)

// ─── BACKGROUND ───
bgcolor(showBG ? (bullRibbon ? color.new(color.lime, 96) : bearRibbon ? color.new(color.red, 96) : na) : na)

// ─── ARROWS ───
plotshape(showArrows and buySignal, location=location.belowbar, color=color.lime, style=shape.triangleup)
plotshape(showArrows and sellSignal, location=location.abovebar, color=color.red, style=shape.triangledown)

// ─── DASHBOARD POSITION ───
pos = switch dashPos
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

// ─── TABLE (FIXED) ───
var table dash = table.new(pos, 3, 6)

// ─── DASHBOARD ───
if showDash and barstate.islast
    table.cell(dash, 0, 0, "SmartFlow", text_color=color.white)
    table.cell(dash, 1, 0, "Bias", text_color=color.yellow)

    table.cell(dash, 0, 1, "Weekly")
    table.cell(dash, 1, 1, wBull ? "BULL" : wBear ? "BEAR" : "NEUT")

    table.cell(dash, 0, 2, "Daily")
    table.cell(dash, 1, 2, dBull ? "BULL" : dBear ? "BEAR" : "NEUT")

    table.cell(dash, 0, 3, "4H")
    table.cell(dash, 1, 3, h4Bull ? "BULL" : h4Bear ? "BEAR" : "NEUT")

    table.cell(dash, 0, 4, "1H")
    table.cell(dash, 1, 4, h1Bull ? "BULL" : h1Bear ? "BEAR" : "NEUT")

    table.cell(dash, 0, 5, "Momentum")
    table.cell(dash, 1, 5, momBull ? "BULL" : momBear ? "BEAR" : "NEUT")

// ─── ALERTS ───
alertcondition(buySignal, "BUY", "SmartFlow BUY")
alertcondition(sellSignal, "SELL", "SmartFlow SELL")
````
