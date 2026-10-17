# The Curly Shuffle

- url: https://www.tradingview.com/script/aRNTjJju-The-Curly-Shuffle/
- type: indicator
- pine_id: PUB;2deced8b5ba540b5873e46f8e09e5f78
- version: 2.0

## Description

The Curly Shuffle

This is a dual CCI oscillator built around one question. When a market has run to an extreme and starts coming back, do both the fast and the slow reading of momentum agree that the run is finished?

A single CCI crossing back inside a threshold is a common event, and on its own it means very little, since it happens constantly in the middle of strong trends. Requiring two CCIs of different speeds to make that same crossing within a few bars of each other is a far narrower condition. The fast line almost always moves first, so what you are really asking is whether the slower and more structural view confirms what the fast one just did, and whether it confirms soon enough that the two are describing the same event rather than two unrelated ones.

How the signal works
The script plots two CCIs on typical price. The slow one defaults to 55 periods and the fast one to 21. Both are watched at a threshold of 170 and negative 170.

A short fires on the bar where the second of the two lines crosses back below 170, provided the first one crossed within the window you set, which defaults to 5 bars. A long fires on the mirror condition at negative 170. A cooldown of 6 bars prevents a line whipsawing across the threshold from producing a cluster of repeat signals. There is also an optional filter, off by default, that requires each line to have travelled a minimum distance past the threshold before its return counts, which stops a CCI that barely touched 171 from carrying the same weight as one that ran to 400.

These defaults are deliberately slow and the threshold is deliberately far out. A 55 period CCI beyond 170 is roughly two and a half mean deviations away from its own moving average, which is not an everyday occurrence, and requiring the 21 period line to be out there with it narrows things further. Expect this to be an infrequent signal on higher timeframes. If you want more of them, shorten both periods together to preserve the speed ratio, or bring the threshold down toward 100, rather than widening the window, which loosens the relationship between the two crossings instead of loosening the setup itself.

The scale
Clamping an oscillator at a fixed ceiling destroys exactly the information you want during capitulation or euphoria, because a reading of 500 and a reading of 250 draw the same flat line. This script does something different. Inside the threshold the plot is completely linear and untouched, so the trigger levels sit where they actually belong. Beyond the threshold the excess is compressed so that the plot approaches a cap of 250 without ever reaching it. The compression softness of 185 controls how gradually that happens. Ordering is preserved throughout, so a more extreme reading always draws further out than a less extreme one, just with tightening spacing. Every calculation behind the signals uses the raw uncompressed values.
Because the visual is compressed above the threshold, a small table shows the true numbers, along with a running count of signals and two diagnostics described below.

Reading the table
Mean gap tells you the average number of bars between the two crossings across every signal so far. Use it to set your window from measured behaviour rather than guesswork. If the mean gap on your instrument and timeframe comes back at 2, a window of 5 is letting through pairs that are not really related.

Fast leads tells you how often the fast CCI crossed first. If that figure sits near 50 percent, the two lines are not in a lead and confirm relationship at all, they are just both crossing a threshold independently, and the pairing rule is not adding information. That is a signal to widen the gap between the two periods.

Notes
Background shading marks stretches where the slow CCI has held one side of zero for 6 or more bars, which is the classic Woodies idea of a trend run.
Signals are evaluated on closing values. A marker can appear and disappear while a bar is still forming and should only be treated as final once the bar closes. The alert is set for once per bar close for the same reason.

This is a signal generator, not a strategy. It produces no stops, no targets and no position sizing, and it makes no claim about profitability. Fading an extreme is a difficult approach and deserves testing on your own instruments before any capital goes near it. The same detector is equally valid read as a continuation signal, since a return inside the threshold during a trend often marks the end of a pullback rather than the end of a move, and comparing both readings on the same data is worth doing. This is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone
// The Curly Shuffle V2 - Adaptive Entry Timing

//@version=6
indicator("The Curly Shuffle V2", overlay = false)

srcCci = input.source(hlc3, "CCI source", group = "Dual CCI")
lenSlow = input.int(55, "Slow CCI length", minval = 1, group = "Dual CCI")
lenFast = input.int(21, "Fast CCI length", minval = 1, group = "Dual CCI")
lvl = input.float(170.0, "Trigger level", minval = 1.0, group = "Dual CCI")
styleSlow = input.string("Histogram", "Slow CCI style", options = ["Line", "Histogram", "Area"], group = "Dual CCI")
runBars = input.int(6, "Trend-run bars", minval = 2, group = "Dual CCI")

limScale = input.float(250.0, "Asymptotic cap", minval = 20.0, group = "Scale")
softK = input.float(185.0, "Compression softness", minval = 1.0, group = "Scale")

winBars = input.int(5, "Max bars between reclaims", minval = 0, group = "Entry")
minDepth = input.float(0.0, "Min excursion beyond level", minval = 0.0, group = "Entry")
coolDn = input.int(6, "Cooldown bars", minval = 0, group = "Entry")
maxWait = input.int(3, "Max confirmation wait", minval = 1, maxval = 6, group = "Entry")
instantGate = input.float(78.0, "Immediate-entry score", minval = 0.0, maxval = 100.0, group = "Entry")
confirmGate = input.float(64.0, "Confirmation score", minval = 0.0, maxval = 100.0, group = "Entry")
markPx = input.bool(true, "Mark entries on price", group = "Entry")

colBull = input.color(#2E7D32, "Bullish", group = "Colors", inline = "c1")
colBear = input.color(#C62828, "Bearish", group = "Colors", inline = "c1")
colTurb = input.color(#EF6C00, "Turbo", group = "Colors", inline = "c1")

slow = ta.cci(srcCci, lenSlow)
fast = ta.cci(srcCci, lenFast)

aS = math.abs(slow)
aF = math.abs(fast)
eS = math.max(aS - lvl, 0.0)
eF = math.max(aF - lvl, 0.0)
pSlow = (slow < 0 ? -1.0 : 1.0) * (math.min(aS, lvl) + (limScale - lvl) * eS / (eS + softK))
pFast = (fast < 0 ? -1.0 : 1.0) * (math.min(aF, lvl) + (limScale - lvl) * eF / (eF + softK))

var float pkHiS = 0.0
var float pkHiF = 0.0
var float pkLoS = 0.0
var float pkLoF = 0.0

pkHiS := slow > lvl ? math.max(pkHiS, slow) : 0.0
pkHiF := fast > lvl ? math.max(pkHiF, fast) : 0.0
pkLoS := slow < -lvl ? math.min(pkLoS, slow) : 0.0
pkLoF := fast < -lvl ? math.min(pkLoF, fast) : 0.0

exHiS = ta.crossunder(slow, lvl)
exHiF = ta.crossunder(fast, lvl)
exLoS = ta.crossover(slow, -lvl)
exLoF = ta.crossover(fast, -lvl)

var float dHiS = 0.0
var float dHiF = 0.0
var float dLoS = 0.0
var float dLoF = 0.0

dHiS := exHiS ? nz(pkHiS[1]) - lvl : dHiS
dHiF := exHiF ? nz(pkHiF[1]) - lvl : dHiF
dLoS := exLoS ? -lvl - nz(pkLoS[1]) : dLoS
dLoF := exLoF ? -lvl - nz(pkLoF[1]) : dLoF

bHiS = nz(ta.barssince(exHiS), 9999)
bHiF = nz(ta.barssince(exHiF), 9999)
bLoS = nz(ta.barssince(exLoS), 9999)
bLoF = nz(ta.barssince(exLoF), 9999)

gapHi = math.max(bHiS, bHiF)
gapLo = math.max(bLoS, bLoF)

pairHi = math.min(bHiS, bHiF) == 0 and gapHi <= winBars and dHiS >= minDepth and dHiF >= minDepth
pairLo = math.min(bLoS, bLoF) == 0 and gapLo <= winBars and dLoS >= minDepth and dLoF >= minDepth

var int runLen = 0
runLen := na(slow) ? 0 : ((slow > 0) == (nz(slow[1]) > 0)) ? runLen + 1 : 1

cciScale = math.max(lvl, 1.0)
depthRef = math.max(cciScale * 0.55, 1.0)
velRef = math.max(cciScale * 0.30, 1.0)
persistRef = math.max(cciScale * 0.35, 1.0)

depthHiSQ = math.min(math.max(dHiS / depthRef, 0.0), 1.0)
depthHiFQ = math.min(math.max(dHiF / depthRef, 0.0), 1.0)
depthLoSQ = math.min(math.max(dLoS / depthRef, 0.0), 1.0)
depthLoFQ = math.min(math.max(dLoF / depthRef, 0.0), 1.0)

depthHiQ = (depthHiSQ + depthHiFQ) * 0.5
depthLoQ = (depthLoSQ + depthLoFQ) * 0.5

gapHiQ = 1.0 - math.min(gapHi / math.max(winBars, 1), 1.0)
gapLoQ = 1.0 - math.min(gapLo / math.max(winBars, 1), 1.0)

slopeShortQ = (slow < slow[1] ? 0.5 : 0.0) + (fast < fast[1] ? 0.5 : 0.0)
slopeLongQ = (slow > slow[1] ? 0.5 : 0.0) + (fast > fast[1] ? 0.5 : 0.0)

velShortRaw = ((nz(slow[1], slow) - slow) + (nz(fast[1], fast) - fast)) / (2.0 * velRef)
velLongRaw = ((slow - nz(slow[1], slow)) + (fast - nz(fast[1], fast))) / (2.0 * velRef)

velShortQ = math.min(math.max(velShortRaw, 0.0), 1.0)
velLongQ = math.min(math.max(velLongRaw, 0.0), 1.0)

persistShortRaw = ((lvl - slow) + (lvl - fast)) / (2.0 * persistRef)
persistLongRaw = ((slow + lvl) + (fast + lvl)) / (2.0 * persistRef)

persistShortQ = math.min(math.max(persistShortRaw, 0.0), 1.0)
persistLongQ = math.min(math.max(persistLongRaw, 0.0), 1.0)

barRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closePos = math.min(math.max((close - low) / barRange, 0.0), 1.0)

priceShortRaw = 0.45 * (upperWick / barRange) + 0.35 * (1.0 - closePos) + 0.20 * (close < close[1] ? 1.0 : 0.0)
priceLongRaw = 0.45 * (lowerWick / barRange) + 0.35 * closePos + 0.20 * (close > close[1] ? 1.0 : 0.0)

priceShortQ = math.min(math.max(priceShortRaw, 0.0), 1.0)
priceLongQ = math.min(math.max(priceLongRaw, 0.0), 1.0)

regimeShortQ = runLen >= runBars and slow > 0 ? 0.35 : 1.0
regimeLongQ = runLen >= runBars and slow < 0 ? 0.35 : 1.0

syncShortNew = 0.55 * gapHiQ + 0.45 * slopeShortQ
syncLongNew = 0.55 * gapLoQ + 0.45 * slopeLongQ

newShortScore = 15.0 * depthHiQ + 20.0 * syncShortNew + 20.0 * velShortQ + 20.0 * priceShortQ + 15.0 * persistShortQ + 10.0 * regimeShortQ
newLongScore = 15.0 * depthLoQ + 20.0 * syncLongNew + 20.0 * velLongQ + 20.0 * priceLongQ + 15.0 * persistLongQ + 10.0 * regimeLongQ

var int lastHiSetup = -9999
var int lastLoSetup = -9999
var bool shortArmed = false
var bool longArmed = false
var int shortArmBar = na
var int longArmBar = na
var float shortDepthSnap = 0.0
var float longDepthSnap = 0.0
var float shortGapSnap = 0.0
var float longGapSnap = 0.0

rawShortSetup = pairHi and barstate.isconfirmed and bar_index - lastHiSetup > coolDn
rawLongSetup = pairLo and barstate.isconfirmed and bar_index - lastLoSetup > coolDn

armedShortSync = 0.55 * shortGapSnap + 0.45 * slopeShortQ
armedLongSync = 0.55 * longGapSnap + 0.45 * slopeLongQ

armedShortScore = 15.0 * shortDepthSnap + 20.0 * armedShortSync + 20.0 * velShortQ + 20.0 * priceShortQ + 15.0 * persistShortQ + 10.0 * regimeShortQ
armedLongScore = 15.0 * longDepthSnap + 20.0 * armedLongSync + 20.0 * velLongQ + 20.0 * priceLongQ + 15.0 * persistLongQ + 10.0 * regimeLongQ

fireShortImmediate = rawShortSetup and not shortArmed and newShortScore >= instantGate
fireLongImmediate = rawLongSetup and not longArmed and newLongScore >= instantGate

fireShortOverlap = rawShortSetup and shortArmed
fireLongOverlap = rawLongSetup and longArmed

fireShortArmed = shortArmed and not rawShortSetup and barstate.isconfirmed and (armedShortScore >= confirmGate or bar_index - shortArmBar >= maxWait)
fireLongArmed = longArmed and not rawLongSetup and barstate.isconfirmed and (armedLongScore >= confirmGate or bar_index - longArmBar >= maxWait)

fireShort = fireShortImmediate or fireShortOverlap or fireShortArmed
fireLong = fireLongImmediate or fireLongOverlap or fireLongArmed
fireAny = fireLong or fireShort

entryScoreShort = fireShortImmediate ? newShortScore : fireShortOverlap or fireShortArmed ? armedShortScore : na
entryScoreLong = fireLongImmediate ? newLongScore : fireLongOverlap or fireLongArmed ? armedLongScore : na
entryQuality = fireLong and fireShort ? math.max(nz(entryScoreLong), nz(entryScoreShort)) : fireLong ? entryScoreLong : fireShort ? entryScoreShort : na
signalCode = fireLong and fireShort ? 2.0 : fireLong ? 1.0 : fireShort ? -1.0 : 0.0

shortNeedsArm = rawShortSetup and (shortArmed or newShortScore < instantGate)
longNeedsArm = rawLongSetup and (longArmed or newLongScore < instantGate)

lastHiSetup := rawShortSetup ? bar_index : lastHiSetup
lastLoSetup := rawLongSetup ? bar_index : lastLoSetup

shortArmed := rawShortSetup ? shortNeedsArm : fireShortArmed ? false : shortArmed
longArmed := rawLongSetup ? longNeedsArm : fireLongArmed ? false : longArmed

shortArmBar := rawShortSetup and shortNeedsArm ? bar_index : rawShortSetup ? na : fireShortArmed ? na : shortArmBar
longArmBar := rawLongSetup and longNeedsArm ? bar_index : rawLongSetup ? na : fireLongArmed ? na : longArmBar

shortDepthSnap := rawShortSetup and shortNeedsArm ? depthHiQ : shortDepthSnap
longDepthSnap := rawLongSetup and longNeedsArm ? depthLoQ : longDepthSnap
shortGapSnap := rawShortSetup and shortNeedsArm ? gapHiQ : shortGapSnap
longGapSnap := rawLongSetup and longNeedsArm ? gapLoQ : longGapSnap

colRaw = slow > 0 ? colBull : colBear
colCci = (slow > 0) == (slow > slow[1]) ? colRaw : color.new(colRaw, 55)

bgcolor(runLen >= runBars ? color.new(colRaw, 92) : na, title = "Trend run")

plot(styleSlow == "Line" ? pSlow : na, "Slow CCI", color = colCci, linewidth = 2)
plot(styleSlow == "Histogram" ? pSlow : na, "Slow CCI hist", color = colCci, linewidth = 3, style = plot.style_histogram)
plot(styleSlow == "Area" ? pSlow : na, "Slow CCI area", color = color.new(colCci, 65), style = plot.style_area)
plot(pFast, "Fast CCI", color = colTurb, linewidth = 2)

hline(limScale, "Cap", color = color.new(color.gray, 80))
hline(-limScale, "Floor", color = color.new(color.gray, 80))
hline(lvl, "Upper", color = color.new(color.gray, 30), linestyle = hline.style_dashed)
hline(-lvl, "Lower", color = color.new(color.gray, 30), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(color.gray, 20), linestyle = hline.style_dotted)

plotshape(fireShort, "Short", shape.triangledown, location.top, color = colBear, size = size.tiny)
plotshape(fireLong, "Long", shape.triangleup, location.bottom, color = colBull, size = size.tiny)
plotshape(markPx and fireShort, "Short px", shape.triangledown, location.abovebar, color = colBear, size = size.tiny, force_overlay = true)
plotshape(markPx and fireLong, "Long px", shape.triangleup, location.belowbar, color = colBull, size = size.tiny, force_overlay = true)

plot(signalCode, "Signal Code", display = display.none)
plot(entryQuality, "Entry Quality", display = display.none)

alertcondition(fireAny, "Curly Shuffle Any Entry", 'The Curly Shuffle V2 | {{ticker}} | {{interval}} | signal {{plot("Signal Code")}} | 1=LONG -1=SHORT 2=BOTH | quality {{plot("Entry Quality")}} | close {{close}}')
````
