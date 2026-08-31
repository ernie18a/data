<!-- tradingview-pine-id: PUB;b8bc86b5e6fe43e8a617685b451fc63d -->
<!-- tradingviewscripts-format: 1 -->
# OBV+ | Percentile Strength, Expiring Flip Gate

Source: https://www.tradingview.com/script/b9il6SXV-OBV/

## Description

OBV+

OBV+ tracks On Balance Volume against a moving average of itself and turns
that relationship into a directional state, then gates entries behind a
statistical trend test and manages the trade with a chandelier stop that only
ever moves in your favor.

HOW THE STATE WORKS

The indicator plots OBV with a configurable moving average (EMA, SMA, WMA,
RMA, or HMA). The distance between the two is ranked as a percentile against
its own recent history, so a strong OBV move is defined relative to what this
symbol has actually been doing rather than by a fixed number that means
something different on every chart. When that strength clears your threshold,
the state turns bullish or bearish and stays there until a qualifying move
flips it the other way. A minimum bar spacing keeps the state from
oscillating.

HOW ENTRIES WORK

A state flip on its own does not open a trade. The flip arms an entry window,
and within that window a linear regression on price must independently confirm
that a trend exists in the same direction, measured by the t statistic of the
regression slope. If the trend test agrees, the trade opens. If the window
closes without confirmation, the flip expires and prints a small gray circle
so you can see exactly which signals were passed over. The next entry then
waits for a fresh flip.

Price bars are colored by the gate rather than by raw OBV, so bars show green
or red only where both conditions are satisfied and gray everywhere else. You
can see at a glance which parts of the chart the indicator considers
tradeable.

HOW EXITS WORK

The stop arms immediately on the entry bar, placed beyond that bar's range so
a wide entry candle cannot take you out on the next bar. From there it trails
from the highest high reached since entry (or lowest low when short) at a
configurable ATR multiple, and it is hard clamped so it can only tighten. In a
long it never moves down. It tightens as volatility contracts and holds its
ground when volatility expands. The stop line is drawn directly on price
alongside entry triangles and exit crosses.

The trailing stop is the only exit by default. Opposite states are ignored
while a position is open, so a brief counter signal that does not reach your
stop leaves the trade running. If you would rather have state changes close
and reverse the position, there is a switch for it.

INPUTS

MA type and length, strength lookback and minimum percentile, minimum bars
between flips, regression lookback, minimum absolute t statistic, confirmation
window length, ATR length and chandelier multiple, plus a flip reverses
position toggle. Display options cover the fill, the trail, trade markers, and
bar coloring, with configurable bull, bear, and neutral colors. An optional
pane mode swaps OBV for the signed strength percentile with the threshold
lines drawn, which makes it easy to see which moves clear the bar.

ALERTS

Separate alert conditions for long entry, short entry, and exit, plus a single
combined alert carrying the ticker, timeframe, strength percentile, t
statistic, and current stop level.

NOTES

Because the signal is built from volume, results depend on the volume series
your data feed provides, and the same symbol can behave differently across
exchanges. Signals evaluate on bar close. Settings are deliberately open
ended: a low strength percentile with a short regression lookback produces
frequent, permissive signals, while raising the percentile and the t threshold
narrows it toward fewer and more selective ones. This is for informational purposes
only and isn't meant as financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("OBV+ | Percentile Strength, Expiring Flip Gate", shorttitle="OBV+", overlay=false, precision=2)

// ---------------- Inputs ----------------
maType   = input.string("EMA", "MA Type", options=["EMA","SMA","WMA","RMA","HMA"], group="Signal")
maLen    = input.int(14, "MA Length", minval=1, group="Signal")
rankLen  = input.int(100, "Strength Lookback", minval=5, group="Signal")
pctMin   = input.float(30.0, "Min Strength Percentile", minval=0.0, maxval=100.0, step=1.0, group="Signal", tooltip="Percentile rank of |OBV - MA| over the lookback. Higher keeps only the largest OBV moves.")
minBars  = input.int(3, "Min Bars Between Flips", minval=0, group="Signal")

regLen   = input.int(5, "Regression Lookback", minval=3, group="Trend Gate")
tMin     = input.float(2.0, "Min |t| to Call It a Trend", minval=0.0, step=0.1, group="Trend Gate")
maxWait  = input.int(2, "Bars for Trend to Confirm a Flip", minval=0, group="Trend Gate", tooltip="A flip arms an entry window this many bars long. If the t-stat doesn't agree by then, the flip expires unused. 0 = must agree on the flip bar itself.")

atrLen   = input.int(14, "ATR Length", minval=1, group="Trade")
atrMult  = input.float(5.0, "Chandelier ATR Mult", minval=0.5, step=0.1, group="Trade")
flipExit = input.bool(false, "Flip Reverses Position", group="Trade")

normMode  = input.bool(false, "Show Strength Pane Instead of OBV", group="Display")
showFill  = input.bool(true, "Fill OBV vs MA", group="Display")
showTrail = input.bool(true, "Show Trail on Price", group="Display")
showMarks = input.bool(true, "Show Trade Markers", group="Display")
colorBars = input.bool(true, "Color Price Bars (gate)", group="Display")
upCol     = input.color(#089981, "Bull", group="Display", inline="c")
dnCol     = input.color(#f23645, "Bear", group="Display", inline="c")
neuCol    = input.color(#b2b5be, "Neutral", group="Display", inline="c")

// ---------------- Core ----------------
obv    = ta.obv
obvMa  = maType == "SMA" ? ta.sma(obv, maLen) : maType == "WMA" ? ta.wma(obv, maLen) : maType == "RMA" ? ta.rma(obv, maLen) : maType == "HMA" ? ta.hma(obv, maLen) : ta.ema(obv, maLen)
spread = obv - obvMa
pctl   = nz(ta.percentrank(math.abs(spread), rankLen))
atr    = ta.atr(atrLen)
strong = pctl >= pctMin
sPctl  = spread > 0 ? pctl : -pctl

rCorr  = nz(ta.correlation(close, bar_index, regLen))
tStat  = rCorr * math.sqrt((regLen - 2) / math.max(1e-10, 1.0 - rCorr * rCorr))
trDir  = tStat >= tMin ? 1 : tStat <= -tMin ? -1 : 0

var int   st       = 0
var int   flipBar  = -9999
var bool  armed    = false
var int   pos      = 0
var float ext      = na
var float trail    = na
var int   entryBar = 0

// ---- OBV state machine ----
stNew    = strong and spread > 0 ? 1 : strong and spread < 0 ? -1 : st
stChg    = stNew != st and (bar_index - flipBar) >= minBars
st      := stChg ? stNew : st
flipBar := stChg ? bar_index : flipBar

// ---- flip arms a window, then expires unused ----
expired  = not stChg and armed and (bar_index - flipBar) > maxWait
armed   := stChg ? true : expired ? false : armed

// ---- stop tested against the trail as of the prior bar's close ----
tPrev    = trail[1]
canStop  = pos != 0 and bar_index > entryBar and not na(tPrev)
stopHit  = canStop and pos == 1 and low <= tPrev ? true : canStop and pos == -1 and high >= tPrev ? true : false

revExit  = flipExit and stChg and pos != 0 and st != pos
exitNow  = pos != 0 and (stopHit or revExit)
exitPx   = stopHit ? tPrev : close
pos     := exitNow ? 0 : pos

// ---- entry: armed flip whose direction the t-stat confirms ----
confirm  = armed and pos == 0 and trDir != 0 and trDir == st
goLong   = confirm and st == 1
goShort  = confirm and st == -1
justIn   = goLong or goShort
pos     := goLong ? 1 : goShort ? -1 : pos
entryBar:= justIn ? bar_index : entryBar
armed   := justIn ? false : armed

// ---- ratchet after the test: arm on entry, tighten only ----
ext     := justIn and pos == 1 ? high : justIn and pos == -1 ? low : pos == 1 ? math.max(nz(ext, high), high) : pos == -1 ? math.min(nz(ext, low), low) : na
cand     = pos == 1 ? ext - atrMult * atr : pos == -1 ? ext + atrMult * atr : na
armStop  = justIn and pos == 1 ? math.min(cand, low - syminfo.mintick) : justIn and pos == -1 ? math.max(cand, high + syminfo.mintick) : cand
trail   := justIn ? armStop : pos == 1 ? math.max(nz(trail, cand), cand) : pos == -1 ? math.min(nz(trail, cand), cand) : na

stCol    = st == 1 ? upCol : st == -1 ? dnCol : neuCol
gateCol  = trDir != 0 and trDir == st and st == 1 ? upCol : trDir != 0 and trDir == st and st == -1 ? dnCol : neuCol
mainVal  = normMode ? sPctl : obv
sigVal   = normMode ? na : obvMa
trailPlt = exitNow ? tPrev : pos != 0 ? trail : na

// ---------------- Pane ----------------
pMain = plot(mainVal, "OBV", color=stCol, linewidth=2)
pSig  = plot(sigVal, "Signal MA", color=#ff9800, linewidth=2, style=plot.style_linebr)
fill(pMain, pSig, color=color.new(stCol, showFill ? 88 : 100), title="OBV/MA Fill")
plot(normMode ? 0.0 : na, "Zero", color=color.new(color.gray, 40), style=plot.style_linebr)
plot(normMode ? pctMin : na, "Strength Threshold", color=color.new(upCol, 55), style=plot.style_linebr)
plot(normMode ? -pctMin : na, "Strength Threshold Low", color=color.new(dnCol, 55), style=plot.style_linebr)

// ---------------- Price overlay ----------------
plot(showTrail ? trailPlt : na, "Trail Stop", color=exitNow ? neuCol : pos == 1 ? upCol : dnCol, style=plot.style_linebr, linewidth=2, force_overlay=true)
plotshape(showMarks and goLong ? low : na, "Long", shape.triangleup, location.absolute, upCol, size=size.tiny, force_overlay=true)
plotshape(showMarks and goShort ? high : na, "Short", shape.triangledown, location.absolute, dnCol, size=size.tiny, force_overlay=true)
plotshape(showMarks and exitNow ? exitPx : na, "Exit", shape.xcross, location.absolute, neuCol, size=size.tiny, force_overlay=true)
plotshape(showMarks and expired and pos == 0 ? close : na, "Flip Expired", shape.circle, location.absolute, color.new(neuCol, 55), size=size.tiny, force_overlay=true)
barcolor(colorBars ? gateCol : na, title="Price Bar Color")

// ---------------- Alerts ----------------
alertcondition(goLong, "OBV+ Long", "OBV+ long entry — strong OBV move confirmed by trend")
alertcondition(goShort, "OBV+ Short", "OBV+ short entry — strong OBV move confirmed by trend")
alertcondition(exitNow, "OBV+ Exit", "OBV+ trail stop hit")

if (goLong or goShort or exitNow)
    alert("OBV+ " + (goLong ? "LONG" : goShort ? "SHORT" : "EXIT") + " | " + syminfo.ticker + " " + timeframe.period + " | pctl=" + str.tostring(pctl, "#.#") + " | t=" + str.tostring(tStat, "#.##") + " | trail=" + str.tostring(trail, format.mintick), alert.freq_once_per_bar_close)
````
