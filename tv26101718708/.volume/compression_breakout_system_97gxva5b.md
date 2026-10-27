# Compression Breakout System

- url: https://www.tradingview.com/script/97gxVA5b-Compression-Breakout-System/
- type: strategy
- pine_id: PUB;c821c51c640b4ea0bde28eba39b0b08d
- version: 1.0

## Description

WHAT IT DOES

CBS trades the volatility cycle on daily bars. Volatility is cyclical: compression precedes expansion. The system waits for a statistically quiet base, buys the first range break that comes with real participation, and rides the expansion leg on a wide trail. Long-only, designed for trending large-caps and liquid index ETFs.

HOW IT WORKS

1) COMPRESSION DETECTION — Bollinger Band width (20, 2) is expressed as a percentage of the basis and ranked against its own trailing 126-day distribution. A "squeeze" is a bottom-quartile reading (width percentile rank below 25). Because this is a percentile rank rather than an absolute width threshold, it self-normalizes across symbols and volatility regimes — nothing to re-tune per asset.

2) TRIGGER — a close above the prior 20-day high, within 5 bars of the last squeeze reading, on above-average volume (volume above its 20-day mean), while price holds above the 200-day SMA. Location plus participation plus trend — no prediction.

3) POSITION SIZING — fixed-fractional: each trade risks a configurable percentage of equity (default 4%), with the position sized off the 2-ATR stop distance and capped at 100% of equity. Volatile symbols automatically get smaller positions, and a failed breakout always costs roughly the same fraction of the account.

4) EXITS — a hard stop 2 ATR under entry (failed break = thesis falsified), and a 3-ATR chandelier trail from the high-water mark. There is deliberately no profit target: expansion legs are long-tailed and the trail, not a target, books them.

BACKTEST PROPERTIES (fully disclosed)

All results use 0.05% commission per side, 1 tick slippage, fills on close of the signal bar, $10,000 initial capital. On AAPL daily 2005-2026 the default configuration shows +899% net, profit factor 4.33, 59% winners, max drawdown 14.4%. Split-sample with parameters frozen: 2005-2015 +164% (PF 3.35), 2015-2026 +293% (PF 4.97). Slippage stress at 5 ticks per side: +256% (PF 4.77). Cross-symbol with frozen parameters: NVDA +658% (PF 3.26); MSFT +46% (PF 1.32) — the honest miss: the system needs names that actually produce post-squeeze expansion, and low-volatility grinders barely clear costs.

WHAT WAS TESTED AND REJECTED

100%-of-equity sizing was rejected: the identical signal stack produced an 89% drawdown in AAPL's choppy pre-2005 era. Risk sizing is what turns a signal into a system. The backtest start/end inputs exist so any subperiod can be scored from the settings dialog without touching code.

INPUTS

Bollinger length and multiplier; width rank window; squeeze threshold and age; breakout lookback; trend SMA length; ATR length; initial stop multiple; chandelier trail multiple; risk % per trade; backtest start/end dates.

LIMITATIONS

These are in-sample backtests on liquid US equities — upper bounds on expectancy, not forecasts. The system trades infrequently (roughly 2-3 trades per year per symbol) and holds through pullbacks by design. Validate on your own symbols and windows before relying on it. Not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────
//  COMPRESSION BREAKOUT SYSTEM  (CBS)
//  Author: Mateo Sandoval
//
//  Volatility is cyclical: compression precedes expansion. This system
//  waits for a statistically quiet base, then buys the range break with
//  volume confirmation and rides the expansion on a wide trail.
//
//  Mechanism:
//  • COMPRESSION — Bollinger band width (20,2) ranked against its own
//    trailing 6-month distribution; a squeeze is a bottom-quartile reading.
//    Percentile rank self-normalizes across symbols and vol regimes —
//    no absolute width threshold to tune per asset.
//  • TRIGGER — close breaks the prior 20-day high within 5 bars of the
//    squeeze, on above-average volume (participation, not drift), while
//    price holds above its 200-day SMA.
//  • SIZING — fixed-fractional: each trade risks riskPct% of equity,
//    position sized off the 2-ATR stop distance. Measured on AAPL daily
//    2005-2026:  2% risk → +374%, PF 4.85, max DD 7.3%;
//                4% risk → +899%, PF 4.33, max DD 14.4%  (default).
//    Design note: 100%-of-equity sizing was tested and REJECTED — the
//    same signals produced an 89% drawdown in AAPL's choppy pre-2005
//    era. Risk sizing is what turns a signal into a system. The backtest
//    start input exists to score any window: full 40-year history at 2%
//    risk is +458%, PF 3.16 — profitable, but the pre-trend era drags.
//  • EXITS — a fixed 2-ATR stop under entry caps the failed-breakout loss;
//    a 3-ATR chandelier trail from the high-water mark rides the winners.
//    Expansion legs are long-tailed: the trail, not a target, books them.
//
//  Built for trending large-caps and index ETFs on the daily timeframe.
// ─────────────────────────────────────────────────────────────────────────
strategy("Compression Breakout System", shorttitle="CBS", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.05, slippage=1,
     process_orders_on_close=true, calc_on_every_tick=false)

bbLen    = input.int(20,    "Bollinger length",             minval=5)
bbMult   = input.float(2.0, "Bollinger mult",               minval=0.5, step=0.25)
rankLen  = input.int(126,   "Width rank window (days)",     minval=30)
sqzPct   = input.float(25.0,"Squeeze: width %-rank below",  minval=5, maxval=50, step=5.0)
sqzAge   = input.int(5,     "Breakout within N bars of squeeze", minval=1)
brkLen   = input.int(20,    "Breakout lookback (days)",     minval=5)
smaLen   = input.int(200,   "Trend SMA length",             minval=50)
atrLen   = input.int(22,    "ATR length",                   minval=5)
stopAtr  = input.float(2.0, "Initial stop (x ATR)",         minval=0.5, step=0.25)
riskPct  = input.float(4.0, "Risk per trade (% of equity)",  minval=0.25, maxval=10.0, step=0.25)
startT   = input.time(timestamp("1 Jan 2005 00:00 +0000"), "Backtest start")
endT     = input.time(timestamp("1 Jan 2099 00:00 +0000"), "Backtest end")
trailAtr = input.float(3.0, "Chandelier trail (x ATR)",     minval=1.0, step=0.25)

basis  = ta.sma(close, bbLen)
dev    = ta.stdev(close, bbLen) * bbMult
bbW    = (2.0 * dev) / basis * 100.0
wRank  = ta.percentrank(bbW, rankLen)
sqzOn  = wRank < sqzPct
sqzRecent = math.sum(sqzOn ? 1 : 0, sqzAge) > 0

brkLvl = ta.highest(high, brkLen)[1]
volOK  = volume > ta.sma(volume, 20)
atr    = ta.atr(atrLen)
smaT   = ta.sma(close, smaLen)
trendOK = close > smaT

inPos  = strategy.position_size > 0
buySig = not inPos and time >= startT and time <= endT and sqzRecent and close > brkLvl and volOK and trendOK

var float entryStop = na
var float hwm = na
if buySig
    stopDist = atr * stopAtr
    qty = math.min(strategy.equity * riskPct / 100.0 / stopDist, strategy.equity / close)
    strategy.entry("Long", strategy.long, qty=qty)
    entryStop := close - stopDist
    hwm := close
if inPos
    hwm := math.max(hwm, close)

if inPos and time > endT
    strategy.close("Long", comment="window end")

stopLvl = math.max(entryStop, hwm - atr * trailAtr)
if inPos and close < stopLvl
    strategy.close("Long", comment=close <= entryStop ? "stop: failed break" : "exit: trail")

colUp  = #26a69a
colDn  = #ef5350
colSqz = #f0b90b
pB = plot(basis,       "BB basis", color=color.new(#787b86, 60))
pH = plot(basis + dev, "BB upper", color=color.new(#787b86, 75))
pD = plot(basis - dev, "BB lower", color=color.new(#787b86, 75))
fill(pH, pD, color=color.new(sqzOn ? colSqz : #787b86, sqzOn ? 88 : 97))
plot(inPos ? stopLvl : na, "Stop/Trail", color=color.new(colSqz, 20), style=plot.style_linebr)
plot(smaT, "Trend SMA", color=trendOK ? color.new(colUp, 55) : color.new(colDn, 55), linewidth=2)

plotshape(buySig, "BREAK", style=shape.labelup, location=location.belowbar,
     color=color.new(colUp, 0), textcolor=color.white, text="BRK", size=size.tiny)
bgcolor(sqzOn ? color.new(colSqz, 94) : na)

var table tb = table.new(position.top_right, 2, 4,
     bgcolor=color.new(#0c0e15, 15), border_width=1,
     border_color=color.new(color.gray, 70))
if barstate.islast
    hdrCol = color.new(#d1d4dc, 0)
    stCol  = sqzOn ? color.new(colSqz, 0) : hdrCol
    table.cell(tb, 0, 0, "CBS", text_color=hdrCol, text_size=size.normal)
    table.cell(tb, 1, 0, sqzOn ? "SQUEEZE" : (trendOK ? "TREND OK" : "NO TREND"),
         text_color=sqzOn ? stCol : (trendOK ? color.new(colUp,0) : color.new(colDn,0)), text_size=size.normal)
    table.cell(tb, 0, 1, "Width %-rank", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 1, str.tostring(wRank, "#.0") + "%", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 2, "Break above", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 2, str.tostring(brkLvl, "#.00"), text_color=hdrCol, text_size=size.small)
    table.cell(tb, 0, 3, "Stop", text_color=hdrCol, text_size=size.small)
    table.cell(tb, 1, 3, inPos ? str.tostring(stopLvl, "#.00") : "—", text_color=hdrCol, text_size=size.small)
````
