# ORB 

- url: https://www.tradingview.com/script/fq2sArHU-ORB/
- type: indicator
- pine_id: PUB;bdcb4249ec684d9db4add05983864a20
- version: 1.0

## Description

he ORB (Opening Range Breakout) indicator for TradingView is a trading tool that helps identify potential breakout opportunities based on the first set period of market activity, usually the first 15, 30, or 60 minutes after the market opens.

It works by plotting the high and low of the chosen opening range directly on your chart. Once price breaks above the high or below the low of that range, the indicator signals a possible directional move, helping traders catch early momentum in the session.

Traders use ORB to:

Identify intraday trend direction early
Catch breakout momentum trades
Set clear entry, stop-loss, and target zones
Avoid random trading by focusing only on structured moves after the open

In simple terms, it marks the “battle zone” at the start of the day—once price escapes that zone, it often signals which side (buyers or sellers) is taking control.

It’s especially popular in futures, forex, and stocks during high-volume market opens like the NYSE and NASDAQ sessions.

## Source Code

````pine
//@version=6
// ORB Fib Pullback (Reddit-style) — v2: session low/high anchors + 78.6%
indicator("ORB Fib Pullback", overlay=true, max_labels_count=100, max_lines_count=100)

// ---------- OPENING RANGE ----------
g1 = "Opening Range"
orbChoice  = input.string("15 min", "Opening Range Length", options=["15 min","30 min","1 hour"], group=g1)
startHour  = input.int(8,  "Session Start Hour (exchange tz)", minval=0, maxval=23, group=g1)
startMin   = input.int(30, "Session Start Minute", minval=0, maxval=59, group=g1)
tzInput    = input.string("America/Chicago", "Timezone", group=g1)
signalSess = input.session("0830-1500", "Active Session (signals)", group=g1)

// ---------- ENTRY ----------
g2 = "Entry"
entryChoice  = input.string("Better — 50%", "Pullback Entry Level", options=["Best — 61.8%","Better — 50%","Good — 38.2%"], group=g2, tooltip="Required pullback depth. Deeper = stronger but rarer.")
requireStrong= input.bool(false, "Require strong (above-avg body) candle", group=g2)
useMacd      = input.bool(true,  "MACD must agree (background)", group=g2)
macdFast     = input.int(12, "MACD Fast", minval=1, group=g2)
macdSlow     = input.int(26, "MACD Slow", minval=1, group=g2)
macdSig      = input.int(9,  "MACD Signal", minval=1, group=g2)
useVol       = input.bool(false, "Require breakout-side volume (optional)", group=g2)
volLen       = input.int(20, "Volume Avg Length", minval=1, group=g2)
volMult      = input.float(1.2, "Volume > avg x", minval=0.1, step=0.1, group=g2)

// ---------- RISK / FIB / VISUALS ----------
g3 = "Risk"
slBuffer = input.float(0.1, "SL buffer (ATR)", minval=0.0, step=0.1, group=g3)
g4 = "Fibonacci"
showFib  = input.bool(true, "Show Fibonacci levels + labels", group=g4)
fibWidth = input.int(1, "Fib Line Thickness", minval=1, maxval=5, group=g4)
g5 = "Visuals"
shadeORB  = input.bool(true, "Shade opening-range window", group=g5)
showTPSL  = input.bool(true, "Show Entry / SL / TP", group=g5)
showStatus= input.bool(false, "Show status panel", group=g5)

// ---------- ORB SESSION STRING ----------
orbMins    = orbChoice == "15 min" ? 15 : orbChoice == "30 min" ? 30 : 60
startTotal = startHour * 60 + startMin
endTotal   = startTotal + orbMins
endH       = int(math.floor(endTotal / 60)) % 24
endM       = endTotal % 60
f_pad(x) => (x < 10 ? "0" : "") + str.tostring(x)
orbSession = f_pad(startHour) + f_pad(startMin) + "-" + f_pad(endH) + f_pad(endM)

inORB     = not na(time(timeframe.period, orbSession, tzInput))
inSession = not na(time(timeframe.period, signalSess, tzInput))
newORB    = inORB and not inORB[1]
orbEnded  = not inORB and inORB[1]
newSess   = inSession and not inSession[1]

// ---------- HELPERS ----------
fLong(float hi, float lo, float p) => hi - (hi - lo) * p
fShort(float lo, float hi, float p) => lo + (hi - lo) * p
entryPct = entryChoice == "Best — 61.8%" ? 0.618 : entryChoice == "Better — 50%" ? 0.5 : 0.382

// ---------- BACKGROUND READS ----------
[macdLine, sigLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBull = macdLine > sigLine
macdBear = macdLine < sigLine
avgBody  = ta.sma(math.abs(close - open), 10)
volOk    = not useVol or volume > ta.sma(volume, volLen) * volMult
atr      = ta.atr(14)
slBuf    = atr * slBuffer

// ---------- STATE ----------
var float orbHigh  = na
var float orbLow   = na
var bool  orbReady = false
var int   dir      = 0
var int   dirBar   = na
var float swingHi  = na
var float swingLo  = na
var float pullLow  = na
var float pullHigh = na
var bool  reachedL = false
var bool  reachedS = false
var bool  firedL   = false
var bool  firedS   = false
var bool  posActive= false
var int   posDir   = 0
var float pEntry   = na
var float pSL      = na
var float pTP      = na
// Session extremes = the fib anchors ("session low to high" per the source)
var float sessHi   = na
var float sessLo   = na

if timeframe.change("1D")
    orbHigh := na
    orbLow := na
    orbReady := false
    dir := 0
    dirBar := na
    swingHi := na
    swingLo := na
    pullLow := na
    pullHigh := na
    reachedL := false
    reachedS := false
    firedL := false
    firedS := false
    posActive := false
    sessHi := na
    sessLo := na

if newORB
    orbHigh := high
    orbLow := low
    orbReady := false
    dir := 0
    dirBar := na
    firedL := false
    firedS := false
else if inORB
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow  := math.min(nz(orbLow, low), low)
if orbEnded
    orbReady := true

// ---------- SESSION EXTREMES (fib anchors) ----------
if newSess
    sessHi := high
    sessLo := low
else if inSession
    sessHi := math.max(nz(sessHi, high), high)
    sessLo := math.min(nz(sessLo, low), low)

// ---------- BREAKOUT -> DIRECTION (still uses the ORB range) ----------
upBreak = orbReady and ta.crossover(close, orbHigh)
dnBreak = orbReady and ta.crossunder(close, orbLow)
if upBreak and dir != 1
    dir := 1
    dirBar := bar_index
    swingHi := high
    pullLow := low
    reachedL := false
if dnBreak and dir != -1
    dir := -1
    dirBar := bar_index
    swingLo := low
    pullHigh := high
    reachedS := false

// ---------- IMPULSE TRACK + PULLBACK REACH (anchored to session low/high) ----------
if dir == 1
    if high > swingHi
        swingHi := high
        pullLow := low
        reachedL := false
    else
        pullLow := math.min(nz(pullLow, low), low)
        if low <= fLong(swingHi, sessLo, entryPct)
            reachedL := true
if dir == -1
    if low < swingLo
        swingLo := low
        pullHigh := high
        reachedS := false
    else
        pullHigh := math.max(nz(pullHigh, high), high)
        if high >= fShort(swingLo, sessHi, entryPct)
            reachedS := true

// ---------- ENTRY ----------
canSig = orbReady and inSession
strongUp = not requireStrong or (close - open) > avgBody
strongDn = not requireStrong or (open - close) > avgBody
buySignal  = canSig and dir == 1  and reachedL and not firedL and close > open and close > fLong(swingHi, sessLo, entryPct)  and (not useMacd or macdBull) and volOk and strongUp
sellSignal = canSig and dir == -1 and reachedS and not firedS and close < open and close < fShort(swingLo, sessHi, entryPct) and (not useMacd or macdBear) and volOk and strongDn
if buySignal
    firedL := true
    posActive := true
    posDir := 1
    pEntry := close
    pTP := swingHi
    pSL := fLong(swingHi, sessLo, 0.786) - slBuf  // just below 78.6%
if sellSignal
    firedS := true
    posActive := true
    posDir := -1
    pEntry := close
    pTP := swingLo
    pSL := fShort(swingLo, sessHi, 0.786) + slBuf // just above 78.6%

// ---------- POSITION EXIT TRACKING ----------
if posActive and posDir == 1
    if high >= pTP or low <= pSL
        posActive := false
if posActive and posDir == -1
    if low <= pTP or high >= pSL
        posActive := false

// ---------- FIB LEVEL VALUES ----------
showSetup = orbReady and inSession and dir != 0
lvl0   = dir == 1 ? fLong(swingHi, sessLo, 0.0)   : fShort(swingLo, sessHi, 0.0)
lvl382 = dir == 1 ? fLong(swingHi, sessLo, 0.382) : fShort(swingLo, sessHi, 0.382)
lvl50  = dir == 1 ? fLong(swingHi, sessLo, 0.5)   : fShort(swingLo, sessHi, 0.5)
lvl618 = dir == 1 ? fLong(swingHi, sessLo, 0.618) : fShort(swingLo, sessHi, 0.618)
lvl786 = dir == 1 ? fLong(swingHi, sessLo, 0.786) : fShort(swingLo, sessHi, 0.786)
lvl100 = dir == 1 ? fLong(swingHi, sessLo, 1.0)   : fShort(swingLo, sessHi, 1.0)
fibOn = showFib and showSetup

// ---------- FIB DISPLAY (horizontal line objects -> no squiggle) ----------
var line fl0   = na
var line fl382 = na
var line fl50  = na
var line fl618 = na
var line fl786 = na
var line fl100 = na

f_fibline(line ln, float y, color col) =>
    line.delete(ln)
    na(y) ? na : line.new(nz(dirBar, bar_index), y, bar_index + 3, y, xloc=xloc.bar_index, extend=extend.none, color=col, width=fibWidth)

if barstate.islast
    if fibOn
        fl0   := f_fibline(fl0,   lvl0,   color.new(color.green,  0))
        fl382 := f_fibline(fl382, lvl382, color.new(color.teal,   0))
        fl50  := f_fibline(fl50,  lvl50,  color.new(color.orange, 0))
        fl618 := f_fibline(fl618, lvl618, color.new(color.red,    0))
        fl786 := f_fibline(fl786, lvl786, color.new(color.maroon, 0))
        fl100 := f_fibline(fl100, lvl100, color.new(color.gray,   0))
    else
        line.delete(fl0)
        line.delete(fl382)
        line.delete(fl50)
        line.delete(fl618)
        line.delete(fl786)
        line.delete(fl100)

// ---------- OTHER LINES (flat already) ----------
showRange = (inORB or dir != 0) and inSession
plot(showRange ? orbHigh : na, "ORB High", color=color.new(color.yellow, 0), linewidth=1, style=plot.style_linebr)
plot(showRange ? orbLow  : na, "ORB Low",  color=color.new(color.yellow, 0), linewidth=1, style=plot.style_linebr)

plot(showTPSL and posActive ? pEntry : na, "Entry", color=color.new(color.blue, 0),  linewidth=1, style=plot.style_linebr)
plot(showTPSL and posActive ? pTP    : na, "TP",    color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(showTPSL and posActive ? pSL    : na, "SL",    color=color.new(color.red, 0),   linewidth=2, style=plot.style_linebr)

// ---------- LABELS ----------
f_lbl(label lb, float y, string txt, color col) =>
    label.delete(lb)
    label.new(bar_index + 5, y, txt, xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
var label l0   = na
var label l382 = na
var label l50  = na
var label l618 = na
var label l786 = na
var label l100 = na
if fibOn and barstate.islast
    l0   := f_lbl(l0,   lvl0,   "0% (TP)", color.new(color.green,  0))
    l382 := f_lbl(l382, lvl382, "38.2%",   color.new(color.teal,   0))
    l50  := f_lbl(l50,  lvl50,  "50%",     color.new(color.orange, 0))
    l618 := f_lbl(l618, lvl618, "61.8%",   color.new(color.red,    0))
    l786 := f_lbl(l786, lvl786, "78.6% (SL)", color.new(color.maroon, 0))
    l100 := f_lbl(l100, lvl100, "100%",    color.new(color.gray,   0))

bgcolor(shadeORB and inORB and inSession ? color.new(color.blue, 90) : na, title="ORB Window")
plotshape(buySignal,  "BUY",  shape.labelup,   location.belowbar, color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)

// ---------- STATUS PANEL ----------
f_col(b) => b ? color.new(color.green, 0) : color.new(color.gray, 35)
var table tbl = table.new(position.top_right, 2, 4, border_width=1)
if showStatus and barstate.islast
    dirTxt = dir == 1 ? "Long bias" : dir == -1 ? "Short bias" : "-"
    reached = dir == 1 ? reachedL : dir == -1 ? reachedS : false
    macdOk = dir == 1 ? macdBull : dir == -1 ? macdBear : false
    table.cell(tbl, 0, 0, "Direction", text_color=color.white, bgcolor=color.new(color.gray,0), text_size=size.small)
    table.cell(tbl, 1, 0, dirTxt, text_color=color.white, bgcolor=f_col(dir != 0), text_size=size.small)
    table.cell(tbl, 0, 1, "Pullback", text_color=color.white, bgcolor=color.new(color.gray,0), text_size=size.small)
    table.cell(tbl, 1, 1, reached ? "Reached" : "Waiting", text_color=color.white, bgcolor=f_col(reached), text_size=size.small)
    table.cell(tbl, 0, 2, "MACD", text_color=color.white, bgcolor=color.new(color.gray,0), text_size=size.small)
    table.cell(tbl, 1, 2, macdOk ? "Agrees" : "No", text_color=color.white, bgcolor=f_col(macdOk), text_size=size.small)
    table.cell(tbl, 0, 3, "In Position", text_color=color.white, bgcolor=color.new(color.gray,0), text_size=size.small)
    table.cell(tbl, 1, 3, posActive ? (posDir == 1 ? "Long" : "Short") : "Flat", text_color=color.white, bgcolor=f_col(posActive), text_size=size.small)

// ---------- ALERTS ----------
alertcondition(buySignal,  "ORB Fib BUY",  "ORB fib pullback long")
alertcondition(sellSignal, "ORB Fib SELL", "ORB fib pullback short")
````
