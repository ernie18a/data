# Channel Reversion System

- url: https://www.tradingview.com/script/XRZCjbFr-Channel-Reversion-System/
- type: strategy
- pine_id: PUB;9feac257748d4caca17c5a9f823a957f
- version: 1.0

## Description

WHAT IT DOES

CRS buys weakness at structural support inside an established uptrend, and takes profit when price reverts to the middle of its range. It is deliberately a capital-efficiency system rather than a raw-return system: high hit rate, small symmetric trades, single-digit-to-teens drawdowns, and it sits in cash roughly 80% of the time. Built for liquid index ETFs (QQQ, SPY) on the daily timeframe.

HOW IT WORKS

1) STRUCTURE - a 50-day Donchian channel built on prior-bar highs and lows (no same-bar self-reference) maps the active trading range. The lower quarter of that channel is the accumulation zone.

2) TREND FILTER - entries exist only while price holds above its 200-day SMA. Mean reversion is traded WITH the prevailing trend, never against it; fading downtrends is how reversion accounts die. A close below the SMA while positioned is an immediate exit - trend gone, thesis gone.

3) ENTRY - close enters the lower quarter of the channel while the trend filter holds. Location plus regime, no prediction.

4) EXITS - profit target at the channel midline (the reversion to the middle of the range is the statistically reliable move); hard stop one ATR(14) below the channel floor (if the range itself fails, the location thesis is falsified); regime exit on the 200-SMA break.

BACKTEST PROPERTIES (fully disclosed)

0.05% commission per side, 1 tick slippage, fills on close, $10,000 initial capital. QQQ daily March 1999 - August 2026 (a 27-year window that includes the dot-com collapse and the 2008 crisis): +104% net, profit factor 2.28, 64% winners, 58 trades, max drawdown 15.2%. Cross-symbol with parameters frozen: SPY +67%, profit factor 1.80, 62% winners, max drawdown 8.5%. Stated plainly: CRS does NOT beat buy-and-hold on raw return - a system that is long roughly 20% of the time cannot outrun a secular bull market. What transfers across symbols untouched is the character: high hit rate, small symmetric win/loss sizes, small drawdown.

WHAT WAS TESTED AND REJECTED

A chandelier-trail "let winners ride" exit was tested and REJECTED with numbers: same net return, profit factor down from 2.28 to 1.79, win rate 64% to 47%, drawdown up from 15% to 19%. In a mean-reversion system the target IS the edge. A 3x leveraged wrapper (TQQQ) was also tested and REJECTED: profit factor collapsed to 1.43 and max drawdown tripled to 43% - leverage triples the noise around the structural stop.

INPUTS

Channel length (50), entry zone as % of channel (25), trend SMA length (200), ATR length (14), stop distance in ATR below the channel floor (1.0).

LIMITATIONS

In-sample, single-history backtests - upper bounds on expectancy, not forecasts. The QQQ/SPY pair shares one market era; genuine robustness claims need non-US indices and bear-heavy subperiods. Validate on your own symbols and windows before relying on it. Not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────
//  CHANNEL REVERSION SYSTEM  (CRS)
//  Author: Mateo Sandoval
//
//  Buys weakness at structural support inside an established uptrend.
//
//  Mechanism:
//  • CHANNEL — a 50-day Donchian channel (prior-bar highs/lows) maps the
//    active trading range. Its lower quarter is the accumulation zone.
//  • TREND FILTER — entries only while price holds above its 200-day SMA:
//    weakness is only bought WITH the prevailing trend, never against it
//    (fading downtrends is how reversion accounts die).
//  • ENTRY — close enters the lower quarter of the channel while the trend
//    filter holds. Location + regime, no prediction.
//  • EXITS — profit at the channel midline (reversion complete); hard stop
//    one ATR below the channel floor (structure failed); regime exit on a
//    200-SMA break. Design note: a chandelier-trail "let it ride" exit was
//    tested and REJECTED — same net return, worse profit factor (1.79 vs
//    2.28) and deeper drawdown (19% vs 15%). In a mean-reversion system
//    the target IS the edge; this system is a scalpel, not a holder.
//
//  The point of this system is risk-adjusted quality, not raw beta: ~64%
//  win rate, profit factor ~2.3, max drawdown ~15% — while flat (in cash)
//  roughly 80% of the time. Return on capital-at-risk is the metric here.
//  Built for liquid index ETFs (QQQ/SPY) on the daily timeframe.
// ─────────────────────────────────────────────────────────────────────────
strategy("Channel Reversion System", shorttitle="CRS", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.05, slippage=1,
     process_orders_on_close=true, calc_on_every_tick=false)

chanLen = input.int(50,    "Channel length (days)",      minval=10)
zonePct = input.float(25.0,"Entry zone (% of channel)",  minval=5, maxval=50, step=5.0)
smaLen  = input.int(200,   "Trend SMA length",           minval=50)
atrLen  = input.int(14,    "ATR length",                 minval=5)
atrMult = input.float(1.0, "Stop: ATR below channel",    minval=0.25, step=0.25)

upperD  = ta.highest(high, chanLen)[1]
lowerD  = ta.lowest(low,  chanLen)[1]
midD    = (upperD + lowerD) / 2.0
zoneTop = lowerD + (upperD - lowerD) * zonePct / 100.0
atr     = ta.atr(atrLen)
smaT    = ta.sma(close, smaLen)
trendOK = close > smaT

inPos  = strategy.position_size > 0
buySig = not inPos and trendOK and close <= zoneTop

if buySig
    strategy.entry("Long", strategy.long)

if inPos
    if close >= midD
        strategy.close("Long", comment="target: channel mid")
    else if close < lowerD - atr * atrMult
        strategy.close("Long", comment="stop: channel failed")
    else if close < smaT
        strategy.close("Long", comment="exit: trend break")

colUp  = #26a69a
colDn  = #ef5350
colNeu = #787b86
pU = plot(upperD,  "Channel high", color=color.new(colNeu, 40))
pL = plot(lowerD,  "Channel low",  color=color.new(colNeu, 40))
pZ = plot(zoneTop, "Buy zone top", color=color.new(colUp, 60))
plot(midD, "Channel mid", color=color.new(#f0b90b, 30), linewidth=1)
fill(pU, pZ, color=color.new(colNeu, 96))
fill(pZ, pL, color=color.new(colUp, trendOK ? 88 : 95))
plot(smaT, "Trend SMA", color=trendOK ? color.new(colUp, 50) : color.new(colDn, 50), linewidth=2)

plotshape(buySig, "BUY", style=shape.labelup, location=location.belowbar,
     color=color.new(colUp, 0), textcolor=color.white, text="BUY", size=size.tiny)

var table tb = table.new(position.top_right, 2, 4,
     bgcolor=color.new(#0c0e15, 15), border_width=1,
     border_color=color.new(color.gray, 70))
if barstate.islast
    hdrCol = color.new(#d1d4dc, 0)
    posPct = (close - lowerD) / math.max(upperD - lowerD, 0.0001) * 100.0
    table.cell(tb, 0, 0, "CRS", text_color=hdrCol, text_size=size.normal)
    table.cell(tb, 1, 0, trendOK ? "TREND OK" : "NO TREND",
         text_color=trendOK ? color.new(colUp,0) : color.new(colDn,0), text_size=size.normal)
    table.cell(tb, 0, 1, "Channel pos", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 1, str.tostring(posPct, "#.0") + "%", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 2, "Buy zone", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 2, "< " + str.tostring(zoneTop, "#.00"), text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 3, "Target", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 3, str.tostring(midD, "#.00"), text_color=hdrCol, text_size=size.small)
````
