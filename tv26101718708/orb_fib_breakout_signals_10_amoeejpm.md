# ORB + Fib Breakout Signals 1.0

- url: https://www.tradingview.com/script/AmOEEJpM-ORB-Fib-Breakout-Signals-1-0/
- type: indicator
- pine_id: PUB;333f294bacd74ea79cc23b5b9f89f612
- version: 1.0

## Description

Overview

ORB + Fib Breakout Signals 1.0 is a trading indicator designed to combine Opening Range Breakout (ORB) analysis with Fibonacci extension and retracement levels to identify high-probability trade opportunities. The script automatically plots key ORB levels, detects breakout conditions, and generates long and short trade signals when price confirms momentum beyond the opening range.

Features
Automatic Opening Range High and Low detection
Bullish and bearish breakout signals
Fibonacci retracement and extension levels
Visual buy and sell markers
Customizable session settings
Adjustable Fibonacci targets
Clear chart overlays for fast decision making
How It Works
The script defines the opening range during a user-selected session.
Once the range is established, it monitors price action for confirmed breakouts.
When price closes above the ORB high, a bullish signal may be generated.
When price closes below the ORB low, a bearish signal may be generated.
Fibonacci levels are used to identify potential profit targets, pullback zones, and areas of support or resistance.
Best Use Cases
Index Futures (NQ, ES, YM)
Forex Markets
Major Stock Indices
High Volume Equities
Intraday Momentum Trading
Risk Disclaimer

This indicator is intended for educational and informational purposes only. Trading involves substantial risk and no indicator can guarantee profits. Always use proper risk management, stop-loss protection, and independent analysis before entering any trade.

Version

Version 1.0

Created by Chad Lee

## Source Code

````pine
//@version=6
// ORB + Fib Breakout Signals
indicator("ORB + Fib Breakout Signals", overlay=true)

// ---------- INPUTS: OPENING RANGE ----------
g1 = "Opening Range"
orbChoice  = input.string("15 min", "Opening Range Length", options=["15 min","30 min","1 hour"], group=g1)
startHour  = input.int(8,  "Session Start Hour (exchange tz)", minval=0, maxval=23, group=g1)
startMin   = input.int(30, "Session Start Minute", minval=0, maxval=59, group=g1)
tzInput    = input.string("America/Chicago", "Timezone", tooltip="e.g. America/Chicago, America/New_York", group=g1)
signalSess = input.session("0830-1500", "Active Session (levels + signals)", group=g1)

// ---------- INPUTS: SIGNALS ----------
g2 = "Signals"
breakChoice = input.string("Close", "Breakout Trigger", options=["Close","Wick (High/Low)"], group=g2)
oncePerDay  = input.bool(true, "One signal per direction per day", group=g2)

// ---------- INPUTS: FIBONACCI ----------
g3 = "Fibonacci"
showInner = input.bool(true, "Show inner fibs (.236/.382/.5/.618/.786)", group=g3)
showExt   = input.bool(true, "Show extension targets (1.272 / 1.618)", group=g3)

// ---------- INPUTS: VISUALS ----------
g4 = "Visuals"
shadeORB = input.bool(true, "Shade opening-range window", group=g4)

// ---------- BUILD ORB SESSION STRING ----------
orbMins    = orbChoice == "15 min" ? 15 : orbChoice == "30 min" ? 30 : 60
startTotal = startHour * 60 + startMin
endTotal   = startTotal + orbMins
endH       = int(math.floor(endTotal / 60)) % 24
endM       = endTotal % 60
f_pad(x) => (x < 10 ? "0" : "") + str.tostring(x)
orbSession = f_pad(startHour) + f_pad(startMin) + "-" + f_pad(endH) + f_pad(endM)

// ---------- SESSION DETECTION ----------
inORB     = not na(time(timeframe.period, orbSession, tzInput))
inSession = not na(time(timeframe.period, signalSess, tzInput))
newORB    = inORB and not inORB[1]
orbEnded  = not inORB and inORB[1]

// ---------- BUILD / LOCK THE OPENING RANGE ----------
var float orbHigh   = na
var float orbLow    = na
var bool  orbReady  = false
var bool  buyFired  = false
var bool  sellFired = false

if newORB
    orbHigh   := high
    orbLow    := low
    orbReady  := false
    buyFired  := false
    sellFired := false
else if inORB
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow  := math.min(nz(orbLow, low), low)

if orbEnded
    orbReady := true

// ---------- FIB LEVELS ----------
rng    = orbHigh - orbLow
fib236 = orbLow + rng * 0.236
fib382 = orbLow + rng * 0.382
fib500 = orbLow + rng * 0.500
fib618 = orbLow + rng * 0.618
fib786 = orbLow + rng * 0.786
extUp1 = orbHigh + rng * 0.272
extUp2 = orbHigh + rng * 0.618
extDn1 = orbLow  - rng * 0.272
extDn2 = orbLow  - rng * 0.618

showRange = inSession and (inORB or orbReady)
disp      = inSession and orbReady

// ---------- SIGNALS (ORB breakout only) ----------
useClose = breakChoice == "Close"
upSrc = useClose ? close : high
dnSrc = useClose ? close : low

rawBuy  = disp and ta.crossover(upSrc, orbHigh)
rawSell = disp and ta.crossunder(dnSrc, orbLow)
buySignal  = rawBuy  and (not oncePerDay or not buyFired)
sellSignal = rawSell and (not oncePerDay or not sellFired)
if buySignal
    buyFired := true
if sellSignal
    sellFired := true

// ---------- PLOTS ----------
plot(showRange ? orbHigh : na, "ORB High", color=color.new(color.teal, 0),   linewidth=2, style=plot.style_linebr)
plot(showRange ? orbLow  : na, "ORB Low",  color=color.new(color.maroon, 0), linewidth=2, style=plot.style_linebr)

plot(disp and showInner ? fib500 : na, "Fib 0.5",   color=color.new(color.gray, 20), style=plot.style_linebr)
plot(disp and showInner ? fib236 : na, "Fib 0.236", color=color.new(color.blue, 50), style=plot.style_linebr)
plot(disp and showInner ? fib382 : na, "Fib 0.382", color=color.new(color.blue, 50), style=plot.style_linebr)
plot(disp and showInner ? fib618 : na, "Fib 0.618", color=color.new(color.blue, 50), style=plot.style_linebr)
plot(disp and showInner ? fib786 : na, "Fib 0.786", color=color.new(color.blue, 50), style=plot.style_linebr)

plot(disp and showExt ? extUp1 : na, "Ext 1.272 Up", color=color.new(color.green, 30), style=plot.style_linebr)
plot(disp and showExt ? extUp2 : na, "Ext 1.618 Up", color=color.new(color.green, 30), style=plot.style_linebr)
plot(disp and showExt ? extDn1 : na, "Ext 1.272 Dn", color=color.new(color.red, 30),   style=plot.style_linebr)
plot(disp and showExt ? extDn2 : na, "Ext 1.618 Dn", color=color.new(color.red, 30),   style=plot.style_linebr)

bgcolor(shadeORB and inORB and inSession ? color.new(color.blue, 90) : na, title="ORB Window")

plotshape(buySignal,  "BUY",  shape.labelup,   location.belowbar, color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)

// ---------- ALERTS ----------
alertcondition(buySignal,  "ORB Breakout BUY",   "ORB breakout long")
alertcondition(sellSignal, "ORB Breakdown SELL", "ORB breakout short")
````
