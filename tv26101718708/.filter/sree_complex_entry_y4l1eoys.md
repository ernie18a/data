# SREE Complex Entry

- url: https://www.tradingview.com/script/y4l1EOYs-SREE-Complex-Entry/
- type: indicator
- pine_id: PUB;3851450498ba49ad9fa5e69ce1efdb76
- version: 5.0

## Description

Key Concepts:
- Sweep = liquidity event (trapped traders)
- Displacement = confirmation (real move starts)
- No fixed time window; signal triggers only when displacement occurs.

## Source Code

````pine
//@version=5
indicator("SREE B&R PM Sweep + Retest + Displacement v4", overlay=true, max_labels_count=500)
//@version=5

//--------------------------------------------------
// Inputs
//--------------------------------------------------
pmSession          = input.session("0400-0929", "Premarket Session")
rthSession         = input.session("0930-1600", "Regular Session")

atrLen             = input.int(6, "ATR Length", minval=1)
bodyATRMult        = input.float(0.6, "Min Body as ATR Multiple", step=0.1)

useRangeFilter     = input.bool(false, "Use minimum candle range filter")
minRange           = input.float(1.2, "Minimum Candle Range", step=0.1)

retestTolerance    = input.float(0.15, "Retest tolerance from PM level", step=0.05)

showLevels         = input.bool(true, "Show PMH / PML")
showSetupLabels    = input.bool(true, "Show setup labels")
showRetestLabels   = input.bool(true, "Show retest labels")
oneSignalPerSide   = input.bool(true, "Only one long and one short per day")

//--------------------------------------------------
// Session detection
//--------------------------------------------------
inPM   = not na(time(timeframe.period, pmSession))
inRTH  = not na(time(timeframe.period, rthSession))
newDay = ta.change(time("D")) != 0

//--------------------------------------------------
// Premarket high / low
//--------------------------------------------------
var float pmHigh = na
var float pmLow  = na

if newDay
    pmHigh := na
    pmLow := na

if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow := na(pmLow) ? low : math.min(pmLow, low)

pmh = pmHigh
pml = pmLow

plot(showLevels and inRTH ? pmh : na, title="PM High", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showLevels and inRTH ? pml : na, title="PM Low", color=color.blue, linewidth=2, style=plot.style_linebr)

//--------------------------------------------------
// Candle measurements
//--------------------------------------------------
atrVal      = ta.atr(atrLen)
candleBody  = math.abs(close - open)
candleRange = high - low
prevHigh    = nz(high[1], high)
prevLow     = nz(low[1], low)

bodyOK  = candleBody >= atrVal * bodyATRMult
rangeOK = not useRangeFilter or candleRange >= minRange

// Displacement candles = confirmation candles
bullDisplacement = inRTH and close > open and bodyOK and rangeOK and close > prevHigh
bearDisplacement = inRTH and close < open and bodyOK and rangeOK and close < prevLow

//--------------------------------------------------
// Base level events
//--------------------------------------------------
// Reversal events
pmhSweepFail = inRTH and not na(pmh) and high > pmh and close < pmh
pmlSweepFail = inRTH and not na(pml) and low < pml and close > pml

// Continuation events
pmhBreak = inRTH and not na(pmh) and close > pmh
pmlBreak = inRTH and not na(pml) and close < pml

plotshape(showSetupLabels and pmhSweepFail, title="PMH Sweep Fail", location=location.abovebar, style=shape.triangledown, color=color.red, size=size.tiny, text="PMH SF")
plotshape(showSetupLabels and pmlSweepFail, title="PML Sweep Fail", location=location.belowbar, style=shape.triangleup, color=color.blue, size=size.tiny, text="PML SF")
plotshape(showSetupLabels and pmhBreak, title="PMH Break", location=location.belowbar, style=shape.circle, color=color.green, size=size.tiny, text="PMH B")
plotshape(showSetupLabels and pmlBreak, title="PML Break", location=location.abovebar, style=shape.circle, color=color.orange, size=size.tiny, text="PML B")

//--------------------------------------------------
// State tracking
//--------------------------------------------------
var bool revBearActive = false   // PMH sweep fail path -> short
var bool revBullActive = false   // PML sweep fail path -> long
var bool contBullActive = false  // PMH break hold path -> long
var bool contBearActive = false  // PML break hold path -> short

var bool revBearRetestDone = false
var bool revBullRetestDone = false
var bool contBullRetestDone = false
var bool contBearRetestDone = false

var bool longFiredToday = false
var bool shortFiredToday = false

if newDay
    revBearActive := false
    revBullActive := false
    contBullActive := false
    contBearActive := false

    revBearRetestDone := false
    revBullRetestDone := false
    contBullRetestDone := false
    contBearRetestDone := false

    longFiredToday := false
    shortFiredToday := false

//--------------------------------------------------
// Activate model states
//--------------------------------------------------
// Reversal branches
if pmhSweepFail
    revBearActive := true
    revBearRetestDone := false

    revBullActive := false
    revBullRetestDone := false
    contBullActive := false
    contBullRetestDone := false
    contBearActive := false
    contBearRetestDone := false

if pmlSweepFail
    revBullActive := true
    revBullRetestDone := false

    revBearActive := false
    revBearRetestDone := false
    contBullActive := false
    contBullRetestDone := false
    contBearActive := false
    contBearRetestDone := false

// Continuation branches
if pmhBreak and not pmhSweepFail
    contBullActive := true
    contBullRetestDone := false

    revBearActive := false
    revBearRetestDone := false

if pmlBreak and not pmlSweepFail
    contBearActive := true
    contBearRetestDone := false

    revBullActive := false
    revBullRetestDone := false

//--------------------------------------------------
// Retest logic
//--------------------------------------------------
// 1) Reversal short: PMH swept and failed, then bounce back near PMH but still close below PMH
revBearRetest = revBearActive and not revBearRetestDone and not na(pmh) and high >= (pmh - retestTolerance) and close < pmh and close > open

// 2) Reversal long: PML swept and reclaimed, then pullback near PML but still close above PML
revBullRetest = revBullActive and not revBullRetestDone and not na(pml) and low <= (pml + retestTolerance) and close > pml and close < open

// 3) Continuation long: broke above PMH, then retests PMH as support and closes above PMH
contBullRetest = contBullActive and not contBullRetestDone and not na(pmh) and low <= (pmh + retestTolerance) and close > pmh

// 4) Continuation short: broke below PML, then retests PML as resistance and closes below PML
contBearRetest = contBearActive and not contBearRetestDone and not na(pml) and high >= (pml - retestTolerance) and close < pml

if revBearRetest
    revBearRetestDone := true

if revBullRetest
    revBullRetestDone := true

if contBullRetest
    contBullRetestDone := true

if contBearRetest
    contBearRetestDone := true

plotshape(showRetestLabels and revBearRetest, title="Rev Bear Retest", location=location.abovebar, style=shape.circle, color=color.red, size=size.tiny, text="RT")
plotshape(showRetestLabels and revBullRetest, title="Rev Bull Retest", location=location.belowbar, style=shape.circle, color=color.lime, size=size.tiny, text="RT")
plotshape(showRetestLabels and contBullRetest, title="Cont Bull Retest", location=location.belowbar, style=shape.circle, color=color.green, size=size.tiny, text="RT")
plotshape(showRetestLabels and contBearRetest, title="Cont Bear Retest", location=location.abovebar, style=shape.circle, color=color.orange, size=size.tiny, text="RT")

//--------------------------------------------------
// Final signals
//--------------------------------------------------
// IMPORTANT:
// Retest is context only.
// Signal prints ONLY on displacement candle AFTER retest.
// That is why [1] is used on retestDone.
revShortSignal  = revBearActive and nz(revBearRetestDone[1], false) and bearDisplacement and (not oneSignalPerSide or not shortFiredToday)
revLongSignal   = revBullActive and nz(revBullRetestDone[1], false) and bullDisplacement and (not oneSignalPerSide or not longFiredToday)

contLongSignal  = contBullActive and nz(contBullRetestDone[1], false) and bullDisplacement and (not oneSignalPerSide or not longFiredToday)
contShortSignal = contBearActive and nz(contBearRetestDone[1], false) and bearDisplacement and (not oneSignalPerSide or not shortFiredToday)

longSignal  = revLongSignal or contLongSignal
shortSignal = revShortSignal or contShortSignal

if longSignal
    revBullActive := false
    revBullRetestDone := false
    contBullActive := false
    contBullRetestDone := false
    longFiredToday := true

if shortSignal
    revBearActive := false
    revBearRetestDone := false
    contBearActive := false
    contBearRetestDone := false
    shortFiredToday := true

//--------------------------------------------------
// Plot final signals
//--------------------------------------------------
plotshape(revShortSignal, title="REV SHORT", location=location.abovebar, style=shape.labeldown, color=color.red, text="REV SHORT", textcolor=color.white, size=size.small)
plotshape(revLongSignal, title="REV LONG", location=location.belowbar, style=shape.labelup, color=color.blue, text="REV LONG", textcolor=color.white, size=size.small)

plotshape(contLongSignal, title="CONT LONG", location=location.belowbar, style=shape.labelup, color=color.lime, text="CONT LONG", textcolor=color.black, size=size.small)
plotshape(contShortSignal, title="CONT SHORT", location=location.abovebar, style=shape.labeldown, color=color.orange, text="CONT SHORT", textcolor=color.white, size=size.small)

barcolor(longSignal ? color.lime : shortSignal ? color.red : na)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(revShortSignal, title="Reversal Short", message="PMH sweep fail -> retest fail -> bearish displacement")
alertcondition(revLongSignal, title="Reversal Long", message="PML sweep fail -> retest hold -> bullish displacement")
alertcondition(contLongSignal, title="Continuation Long", message="PMH break -> retest support -> bullish displacement")
alertcondition(contShortSignal, title="Continuation Short", message="PML break -> retest resistance -> bearish displacement")
````
