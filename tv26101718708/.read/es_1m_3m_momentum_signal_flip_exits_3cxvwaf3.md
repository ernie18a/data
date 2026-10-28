# ES 1m - 3m Momentum - Signal Flip Exits

- url: https://www.tradingview.com/script/3cxvWaf3-ES-1m-3m-Momentum-Signal-Flip-Exits/
- type: strategy
- pine_id: PUB;049b77949fa540219104e4cb2fd767cc
- version: 3.0

## Description

How the strategy works on both timeframes

The core logic is identical — four filters must all agree before a trade fires: the fast EMA (8) crosses the slow EMA (21), price is on the correct side of the 50 EMA, smoothed RSI is above or below 50, and volume is above its 20-bar average. When all four line up, you enter long or short. You stay in the trade until the opposite signal fires or the 1-point take profit is hit.

On the 1-minute chart the crossovers fire constantly — you could see 40–80 signals per day. The volume and RSI filters cut most of them, but commission ($5 round-trip) eats deeply into a 1-point target. To make it work on 1m you'd want to tighten the RSI threshold to 52/48 instead of 50/50, and possibly raise the volume multiplier to 1.5× to further reduce trade count. It's workable but requires extra tuning.

On the 3-minute chart (the version built for you) the signal count drops to a healthier 15–30 trades per day. Each bar represents 3× the price action so the EMA and RSI readings are more stable, the trend filter is more meaningful, and you're less likely to get chopped by random 1-minute noise. This is why 3m was the right choice — the filters have room to breathe.

The key risk on both timeframes is a trending day where the signal never flips. You enter long, ES runs 5–10 points, and you sit through the full move. That's fine — that's the plan. The danger is a choppy, range-bound day where you keep flipping long and short at the same price level. The volume filter is your main protection against that scenario.

## Source Code

````pine
//@version=5


// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BuckDiesel



strategy(
     title            = "ES 3m Momentum - Signal Flip Exits",
     overlay          = true,
     default_qty_type = strategy.fixed,
     default_qty_value= 1,
     commission_type  = strategy.commission.cash_per_contract,
     commission_value = 2.50,
     slippage         = 1,
     currency         = currency.USD,
     margin_long      = 500,
     margin_short     = 500
     )

// ── Inputs ──────────────────────────────────────────────────────────────────
emaFast   = input.int(8,   "Fast EMA",       minval=1)
emaSlow   = input.int(21,  "Slow EMA",       minval=1)
emaFilter = input.int(50,  "Trend Filter EMA", minval=1)
rsiLen    = input.int(14,  "RSI Length",     minval=2)
rsiSmooth = input.int(3,   "RSI Smooth",     minval=1)
volMult   = input.float(1.2, "Min Volume vs MA mult", step=0.1)
volLen    = input.int(20,  "Volume MA Length", minval=5)
tradeDir  = input.string("Both", "Direction", options=["Long","Short","Both"])
rthOnly   = input.bool(true, "RTH only (08:30–15:00 CT)")

// ── Session ─────────────────────────────────────────────────────────────────
inRTH = not rthOnly or (time(timeframe.period, "0830-1500", "America/Chicago") != 0)

// ── Indicators ──────────────────────────────────────────────────────────────
fast   = ta.ema(close, emaFast)
slow   = ta.ema(close, emaSlow)
trend  = ta.ema(close, emaFilter)
rsiRaw = ta.rsi(close, rsiLen)
rsi    = ta.ema(rsiRaw, rsiSmooth)   // smoothed RSI — reduces whipsaw
volMA  = ta.sma(volume, volLen)

// MACD-style momentum confirmation
[macdLine, signalLine, _] = ta.macd(close, emaFast, emaSlow, rsiSmooth)
macdBull = macdLine > signalLine
macdBear = macdLine < signalLine

// ── Filters ──────────────────────────────────────────────────────────────────
// 1. Price above/below 50 EMA  → trend direction filter
// 2. Smoothed RSI above/below 50 → momentum confirmation
// 3. Volume above its MA × mult  → only trade with participation
aboveTrend = close > trend
belowTrend = close < trend
rsiLong    = rsi > 50
rsiShort   = rsi < 50
volOK      = volume > volMA * volMult

// ── Entry Conditions ─────────────────────────────────────────────────────────
longEntry  = ta.crossover(fast, slow)  and aboveTrend and rsiLong  and macdBull and volOK and inRTH
shortEntry = ta.crossunder(fast, slow) and belowTrend and rsiShort and macdBear and volOK and inRTH

// ── Strategy Logic ───────────────────────────────────────────────────────────
// Enter on signal, exit only when opposite signal fires (no hard stop)
if longEntry and (tradeDir == "Long" or tradeDir == "Both")
    strategy.close("Short", comment="Flip→Long")
    strategy.entry("Long",  strategy.long)

if shortEntry and (tradeDir == "Short" or tradeDir == "Both")
    strategy.close("Long",  comment="Flip→Short")
    strategy.entry("Short", strategy.short)

// Take 1 point profit to lock in partial gains on strong moves
// (optional — comment out if you want pure signal-flip only)
TP_PT = input.float(1.0, "Partial TP points (0 = off)", step=0.25, minval=0)
if TP_PT > 0
    if strategy.position_size > 0
        strategy.exit("Long TP",  "Long",  limit=strategy.position_avg_price + TP_PT)
    if strategy.position_size < 0
        strategy.exit("Short TP", "Short", limit=strategy.position_avg_price - TP_PT)

// End of day flatten — never hold ES overnight
if rthOnly and time(timeframe.period, "1500-1505", "America/Chicago") != 0
    strategy.close_all(comment="EOD")

// ── Plots ────────────────────────────────────────────────────────────────────
plot(fast,  "EMA 8",  color=color.new(color.aqua,   0), linewidth=1)
plot(slow,  "EMA 21", color=color.new(color.orange, 0), linewidth=2)
plot(trend, "EMA 50", color=color.new(color.gray,  20), linewidth=2, style=plot.style_stepline)

plotshape(longEntry,  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.normal, title="Long")
plotshape(shortEntry, style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.normal, title="Short")

// Color bars by trend
barcolor(aboveTrend and rsiLong  ? color.new(color.green, 60) :
         belowTrend and rsiShort ? color.new(color.red,   60) : na)
````
