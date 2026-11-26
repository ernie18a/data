# TRADERXMOM 200EMA + VWAP

- url: https://www.tradingview.com/script/7h28QSmV-TRADERXMOM-200EMA-VWAP/
- type: indicator
- pine_id: PUB;32d485b0f6c64a499dff252a6207f320
- version: 2.0

## Description

[b]What it does[/b]
Plots trend-continuation signals on the 5-minute chart using VWAP and dual-timeframe 200 EMA confluence. "Signal Up"/"Signal Down" markers indicate a wick tap into a key level followed by a confirmed close back on the trend side — with built-in alert conditions for both directions.

[b]How it works[/b]
Trend bias requires price to be above (or below) both session VWAP and a 200 EMA calculated from a 5-minute anchor timeframe. A separate 200 EMA calculated from a 1-minute anchor is tracked independently and used only as an additional tap level — it doesn't factor into trend bias, since testing showed treating it as a "level to react to" rather than a "level that defines trend" produced cleaner signal timing.

A signal fires when price wicks through VWAP, the 1m 200 EMA, or the 5m 200 EMA, and the candle closes back on the trend side — a confirmed reclaim rather than a simple touch. This filters out level-touches that don't actually hold.

Both 200 EMAs are calculated via request.security() with lookahead=barmerge.lookahead_off, so plotted values are non-repainting.

[b]How to use it[/b]
Built for micro index futures (MNQ, MES) on the 5-minute chart. Optionally restrict signals to a single custom session window. Signal markers indicate confluence worth evaluating, not automatic trade entries — always apply your own risk management, and use the built-in alerts to monitor in real time rather than watching the chart continuously.

## Source Code

````pine
//@version=6
indicator("TRADERXMOM 200EMA + VWAP", overlay=true)
// ============================================================
// 200 EMA (1m) + 200 EMA (5m) + VWAP Pullback — Signal Indicator
// Up:   price above VWAP + above both 200 EMAs,
//       taps into 200EMA(1m) or VWAP and closes back above it
// Down: price below VWAP + below both 200 EMAs,
//       taps into 200EMA(1m) or VWAP and closes back below it
// Run on a 5-minute chart.
// ============================================================
// ── Inputs
emaLen      = input.int(200, "EMA Length", group="EMAs")
tf1         = input.timeframe("1", "Anchor TF 1 (EMA)", group="EMAs")
tf2         = input.timeframe("5", "Anchor TF 2 (EMA)", group="EMAs")
showEMAs    = input.bool(true, "Show EMAs", group="Display")
showVWAP    = input.bool(true, "Show VWAP", group="Display")
showSignals = input.bool(true, "Show Signals", group="Display")
useTimeFilter = input.bool(false, "Use session filter", group="Session Filter")
sessTime      = input.session("1000-1600", "Session (NY time)", group="Session Filter")
showSessionBg = input.bool(true, "Show session background", group="Session Filter", inline="bg")
sessionBgColor = input.color(color.new(color.blue, 90), "", group="Session Filter", inline="bg")
// ── VWAP (session-anchored, resets daily)
vwapVal = ta.vwap(hlc3)
// ── Multi-timeframe 200 EMAs (non-repainting)
ema1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)
ema5 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)
// ── Session filter
inSession    = not na(time(timeframe.period, sessTime, "America/New_York"))
validSession = not useTimeFilter or inSession
// ── Trend filter: price above/below VWAP and both 200 EMAs
aboveTrend = close > vwapVal and close > ema5
belowTrend = close < vwapVal and close < ema5
// ── Tap conditions: wick touches the level, candle closes back on the trend side
tapEma1Long = low <= ema1 and close > ema1
tapEma5Long = low <= ema5 and close > ema5
tapVwapLong = low <= vwapVal and close > vwapVal
tappedLong  = tapEma1Long or tapEma5Long or tapVwapLong
tapEma1Short = high >= ema1 and close < ema1
tapEma5Short = high >= ema5 and close < ema5
tapVwapShort = high >= vwapVal and close < vwapVal
tappedShort  = tapEma1Short or tapEma5Short or tapVwapShort
// ── Signals
longSignal  = aboveTrend and tappedLong  and validSession
shortSignal = belowTrend and tappedShort and validSession
// ── Plots
bgcolor(useTimeFilter and showSessionBg and inSession ? sessionBgColor : na)
plot(showEMAs ? ema1 : na, "200 EMA (TF1)", color=color.orange, linewidth=2)
plot(showEMAs ? ema5 : na, "200 EMA (TF2)", color=color.aqua,   linewidth=2)
plot(showVWAP ? vwapVal : na, "VWAP", color=color.yellow, linewidth=2)
plot(showSignals and longSignal  ? low  : na, "Signal Up",   style=plot.style_circles, color=color.green, linewidth=1)
plot(showSignals and shortSignal ? high : na, "Signal Down", style=plot.style_circles, color=color.red,   linewidth=1)
// ── Alerts
alertcondition(longSignal,  title="Signal Up",   message="Signal Up")
alertcondition(shortSignal, title="Signal Down", message="Signal Down")
if longSignal
    alert("Signal Up", alert.freq_once_per_bar_close)
if shortSignal
    alert("Signal Down", alert.freq_once_per_bar_close)
````
