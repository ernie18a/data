#  GC Trend-Pullback  Volume Gate Signal Indicator 

- url: https://www.tradingview.com/script/BK30CwG5-GC-Trend-Pullback-Volume-Gate-Signal-Indicator/
- type: indicator
- pine_id: PUB;4f94005f4e9049cd9338f7859e7acd2c
- version: 1.0

## Description

A trend-following pullback signal tool for COMEX gold, ported from a strategy validated on GC 1H data. It marks re-entries in the direction of the higher-timeframe trend, confirmed by a volume gate, and plots the intended stop/target frame for each signal.
What it does

Trades only with the trend: long signals when the 4H EMA-50 is above EMA-200, shorts when below. The trend filter reads the previous completed HTF bar with lookahead_off, so it does not repaint.
Signals on RSI(14) re-entry after a pullback — cross up through 40 in uptrends, cross down through 60 in downtrends.
Fires only when volume is at or above its 20-bar average. This volume gate is the validated edge.
Plots an entry/stop/target frame (1.5×ATR stop, 2.0 R:R by default) so you can see the geometry of each signal. The frame is illustrative — this is an indicator, not a backtest, so it shows intent, not fills.
Built-in alerts: named conditions for long/short in the Create Alert dialog, plus a dynamic-price alert() option. Set alerts to Once Per Bar Close to match the tested bar-close logic.

Data requirement — read before using
The volume gate depends on real volume, so a real-time data feed for the instrument is needed for live signals. On GC and other CME/COMEX futures, TradingView volume is true contract volume — exactly what this was built on. On spot/CFD gold (XAUUSD), volume is only tick volume, a different quantity, and the edge does not carry over. Run it on the futures.
Suggested use
GC1! (or the live front month) on the 1H timeframe, with the higher-timeframe trend filter at 240 (4H) — the configuration it was validated on. Note that GC1! is an auto-rolled continuous contract, so expect minor discontinuities at each roll; trade the actual front month live. Real-time COMEX volume on TradingView requires the CME/COMEX real-time data add-on — without it the feed is delayed and live signals will lag.
Scope
The underlying logic was validated on a single ~10.5-month gold uptrend, so treat signals as a starting point, not a finished system, and confirm behavior across other regimes before relying on it.
Research and educational tool, not financial advice. Markets carry risk; past behavior does not guarantee future results.

## Source Code

````pine
//@version=6
// =============================================================================
// GC Trend-Pullback + Volume Gate  —  SIGNAL INDICATOR
// Indicator port of the GC (COMEX gold) 1H strategy.
//
// VALIDATED edge:  volume-confirmation gate (real volume only — see note).
// Same trend/RSI logic as the strategy; backtest engine + sizing removed.
//
// NOTE ON DATA: the volume gate needs REAL volume. On GC/CME futures that's
// true contract volume (what this was built on). On spot XAUUSD it's tick
// volume — a different quantity — so the edge does not transfer there.
//
// NOTE ON REPAINT: signals confirm on bar CLOSE. The HTF trend uses the prior
// completed HTF bar with lookahead off (non-repainting). Set alerts to
// "Once Per Bar Close" so they match the tested logic.
// =============================================================================

indicator("GC Trend-Pullback + VolGate (signals)", overlay = true, max_labels_count = 500)

// ----------------------------- Inputs ---------------------------------------
gT = "Trend filter (higher timeframe)"
htf      = input.timeframe("240", "Higher timeframe", group = gT)
emaFastL = input.int(50,  "EMA fast", minval = 1, group = gT)
emaSlowL = input.int(200, "EMA slow", minval = 2, group = gT)

gE = "Entry (chart timeframe)"
rsiLen = input.int(14, "RSI length", minval = 2, group = gE)
rsiLo  = input.int(40, "Long re-entry RSI cross-up",   group = gE)
rsiHi  = input.int(60, "Short re-entry RSI cross-down", group = gE)

gX = "Trade frame (ATR) — for stop/target plotting only"
atrLen   = input.int(14,    "ATR length", minval = 1, group = gX)
stopMult = input.float(1.5, "Stop = x*ATR", step = 0.1, group = gX)
rr       = input.float(2.0, "Reward : Risk", step = 0.1, group = gX)

gV = "Volume gate (VALIDATED edge)"
useVolGate = input.bool(true, "Require volume >= average", group = gV)
volAvgLen  = input.int(20, "Volume average length", minval = 2, group = gV)

gSess = "Asian session (validated vol forecast — info only)"
showAsia = input.bool(true, "Shade Asian session (00:00–07:00 UTC)", group = gSess)

// ------------------- Higher-timeframe trend (non-repainting) -----------------
htfFast = request.security(syminfo.tickerid, htf, ta.ema(close, emaFastL)[1], lookahead = barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htf, ta.ema(close, emaSlowL)[1], lookahead = barmerge.lookahead_off)
trendUp = htfFast > htfSlow
trendDn = htfFast < htfSlow

// ------------------------------ Signals --------------------------------------
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(atrLen)
volOK  = not useVolGate or volume >= ta.sma(volume, volAvgLen)

longSig  = trendUp and ta.crossover(rsiVal, rsiLo)  and volOK
shortSig = trendDn and ta.crossunder(rsiVal, rsiHi) and volOK

// --------------------- Trade-frame state (entry/stop/target) -----------------
// No position engine in an indicator — this just tracks the most recent
// signal's stop/target so you can see the frame. Close-based, non-repainting.
var bool  inLong  = false
var bool  inShort = false
var float entryPx = na
var float stopPx  = na
var float tgtPx   = na

// exits clear the active frame (close beyond stop/target, or opposite signal)
if inLong and (close <= stopPx or close >= tgtPx or shortSig)
    inLong := false
if inShort and (close >= stopPx or close <= tgtPx or longSig)
    inShort := false

// entry eligibility evaluated AFTER exits (allows a same-bar flip)
longEntry  = longSig  and not inLong and not inShort
shortEntry = shortSig and not inShort and not inLong

if longEntry
    inLong  := true
    entryPx := close
    stopPx  := close - stopMult * atrVal
    tgtPx   := close + stopMult * atrVal * rr
if shortEntry
    inShort := true
    entryPx := close
    stopPx  := close + stopMult * atrVal
    tgtPx   := close - stopMult * atrVal * rr

active = inLong or inShort

// ------------------------------ Plots ----------------------------------------
plot(htfFast, "HTF EMA fast", color = color.new(color.teal, 0),   linewidth = 2)
plot(htfSlow, "HTF EMA slow", color = color.new(color.orange, 0), linewidth = 2)
bgcolor(trendUp ? color.new(color.green, 92) : trendDn ? color.new(color.red, 92) : na, title = "Trend regime")

plotshape(longEntry,  "Long signal",  shape.triangleup,   location.belowbar, color.new(color.green, 0), size = size.tiny)
plotshape(shortEntry, "Short signal", shape.triangledown, location.abovebar, color.new(color.red, 0),   size = size.tiny)

// trade frame (line breaks when flat)
plot(active ? entryPx : na, "Entry",  color = color.new(color.gray, 0),  style = plot.style_linebr, linewidth = 1)
plot(active ? stopPx  : na, "Stop",   color = color.new(color.red, 0),   style = plot.style_linebr, linewidth = 1)
plot(active ? tgtPx   : na, "Target", color = color.new(color.green, 0), style = plot.style_linebr, linewidth = 1)

// Asian session shading (informational vol-forecast window)
inAsia = not na(time(timeframe.period, "0000-0700", "GMT+0"))
bgcolor(showAsia and inAsia ? color.new(color.blue, 90) : na, title = "Asian session")

// ------------------------------ Alerts ---------------------------------------
// Named conditions (pick these in the Create Alert dialog):
alertcondition(longEntry,  "GC Long signal",  "GC long re-entry (trend + RSI + volume gate)")
alertcondition(shortEntry, "GC Short signal", "GC short re-entry (trend + RSI + volume gate)")

// Dynamic-message alternative (choose "Any alert() function call" instead).
// Set frequency to Once Per Bar Close to match the tested logic.
if longEntry
    alert("GC LONG @ "  + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if shortEntry
    alert("GC SHORT @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
