# Previous Session Range + Projected Candles + BOS/CHOCH Protected

- url: https://www.tradingview.com/script/9DG5HeiT-Previous-Session-Range-Projected-Candles-BOS-CHOCH-Protected/
- type: indicator
- pine_id: PUB;e6c54ba056334500a66f9e6426ba3cd3
- version: 1.0

## Description

Overview:

Previous Session Range + Projected Candles + BOS/CHOCH Protected is a multi-feature price action framework designed to combine session context, market structure, and protected liquidity logic into a single overlay.

The indicator builds and extends the previous session range across the active session, projects both the previous and current session candles for quick visual comparison, and tracks BOS (Break of Structure) and CHOCH (Change of Character) events using swing-based structure logic.

In addition, the script introduces protected high/low tracking, allowing traders to monitor structural invalidation levels after bullish or bearish shifts. Optional displacement filtering can also be enabled to require stronger momentum and candle participation before structure breaks are confirmed.

The framework is intended to help traders:

identify continuation vs reversal conditions,
understand session positioning,
track protected liquidity,
monitor structural shifts,
and improve contextual decision-making.

Core features include:

Previous session high/low range box
50% equilibrium midpoint
Previous + active projected session candles
BOS / CHOCH market structure detection
Protected high / low logic
Optional displacement confirmation filter
Structure invalidation tracking
Customizable visuals and alerts

The indicator is best used as a contextual analysis tool rather than a standalone entry system and works especially well when combined with higher timeframe bias, liquidity concepts, fair value gaps (FVGs), VWAP, volume profile, or session-based trading models.

//────────────────────────────────────────────
// DISCLAIMER
//────────────────────────────────────────────
//
// This indicator is provided for educational
// and informational purposes only.
//
// It is a market-structure and price-action
// analysis tool designed to assist with
// contextual decision-making.
//
// The script does NOT provide financial,
// investment, or trading advice.
//
// Nothing in this indicator should be
// interpreted as a recommendation to buy,
// sell, or hold any financial instrument.
//
// Trading involves substantial risk.
// Past performance does not guarantee
// future results.
//
// Users are solely responsible for their
// own trading decisions, risk management,
// and capital allocation.
//
// The author assumes no responsibility
// for financial losses, damages, or
// decisions made from use of this script.
//
// This tool should be used in conjunction
// with additional analysis, confirmation,
// and proper risk management.
//
// BOS, CHOCH, protected levels, session
// ranges, projections, and displacement
// logic are analytical references — not
// guaranteed predictive signals.
//
// Use at your own risk.
//────────────────────────────────────────────

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © getakabu

//@version=6
indicator("Previous Session Range + Projected Candles + BOS/CHOCH Protected", overlay=true,
     max_boxes_count=150, max_lines_count=300, max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpSession = "Session Source"
sessionTZ = input.string("America/New_York", "Session Timezone", group=grpSession)
activeSession = input.session("0100-1659", "Active Daily Session", group=grpSession)

grpRange = "Previous Session Range Box"
showPrevRangeBox = input.bool(true, "Show Previous Session Range Box", group=grpRange)
boxColor  = input.color(color.purple, "Range Box Color", group=grpRange)
boxTransp = input.int(85, "Box Transparency", minval=0, maxval=100, group=grpRange)
midColor  = input.color(color.white, "50% Midline Color", group=grpRange)

grpProj = "Projected Candles"
showProjectedCandles = input.bool(true, "Show Previous + Active Session Candles", group=grpProj)
projOffset = input.int(10, "Projection Offset", minval=2, maxval=100, group=grpProj)
candleWidth = input.int(4, "Projected Candle Width", minval=2, maxval=20, group=grpProj)
candleGap = input.int(7, "Gap Between Projected Candles", minval=3, maxval=50, group=grpProj)
projBullColor = input.color(color.new(color.green, 25), "Bull Candle Color", group=grpProj)
projBearColor = input.color(color.new(color.red, 25), "Bear Candle Color", group=grpProj)
wickColor = input.color(color.gray, "Wick Color", group=grpProj)
wickWidth = input.int(2, "Wick Width", minval=1, maxval=5, group=grpProj)
openLineColor = input.color(color.yellow, "Open Line Color", group=grpProj)
openLineWidth = input.int(2, "Open Line Width", minval=1, maxval=5, group=grpProj)
showProjectionLabels = input.bool(true, "Show Projection Labels", group=grpProj)

grpMS = "Market Structure BOS / CHOCH"
showMS = input.bool(true, "Show BOS / CHOCH", group=grpMS)
swingLen = input.int(5, "Swing Length", minval=2, maxval=50, group=grpMS)
breakMinTicks = input.int(0, "Break Buffer Ticks", minval=0, maxval=50, group=grpMS)
stateOnClose = input.bool(true, "Confirm Structure On Close", group=grpMS)
showMSLabels = input.bool(true, "Show BOS / CHOCH Labels", group=grpMS)
maxMS = input.int(50, "Max Structure Lines", minval=5, maxval=200, group=grpMS)

grpDisp = "Displacement Filter"
useDisplacementBOS = input.bool(false, "Require Displacement For BOS/CHOCH", group=grpDisp)
atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=grpDisp)
dispAtrMult = input.float(0.75, "Body ≥ ATR ×", minval=0.1, maxval=5.0, step=0.05, group=grpDisp)
dispBodyPctMin = input.float(0.50, "Min Body % Of Range", minval=0.05, maxval=1.0, step=0.05, group=grpDisp)

grpProt = "Protected High / Low"
showProtected = input.bool(true, "Show Protected Level", group=grpProt)
invalidateOnClose = input.bool(true, "Invalidate Protected Level On Close", group=grpProt)

grpColors = "Market Structure Colors"
bullStructColor = input.color(color.lime, "Bull BOS/CHOCH Color", group=grpColors)
bearStructColor = input.color(color.red, "Bear BOS/CHOCH Color", group=grpColors)
protectedBullColor = input.color(color.new(color.lime, 0), "Protected Low Color", group=grpColors)
protectedBearColor = input.color(color.new(color.red, 0), "Protected High Color", group=grpColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session Candle Builder
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inSession = not na(time(timeframe.period, activeSession, sessionTZ))
newSession = inSession and not inSession[1]

var float[] sO = array.new_float()
var float[] sH = array.new_float()
var float[] sL = array.new_float()
var float[] sC = array.new_float()
var int[]   sStart = array.new_int()

f_update_session_candle() =>
    if newSession or barstate.isfirst
        array.unshift(sO, open)
        array.unshift(sH, high)
        array.unshift(sL, low)
        array.unshift(sC, close)
        array.unshift(sStart, bar_index)

        if array.size(sO) > 5
            array.pop(sO)
            array.pop(sH)
            array.pop(sL)
            array.pop(sC)
            array.pop(sStart)

    else if inSession and array.size(sO) > 0
        array.set(sH, 0, math.max(array.get(sH, 0), high))
        array.set(sL, 0, math.min(array.get(sL, 0), low))
        array.set(sC, 0, close)

    0

f_update_session_candle()

hasActive = array.size(sO) > 0
hasPrev   = array.size(sO) > 1

activeO = hasActive ? array.get(sO, 0) : na
activeH = hasActive ? array.get(sH, 0) : na
activeL = hasActive ? array.get(sL, 0) : na
activeC = hasActive ? array.get(sC, 0) : na
activeStart = hasActive ? array.get(sStart, 0) : na

prevO = hasPrev ? array.get(sO, 1) : na
prevH = hasPrev ? array.get(sH, 1) : na
prevL = hasPrev ? array.get(sL, 1) : na
prevC = hasPrev ? array.get(sC, 1) : na
prevStart = hasPrev ? array.get(sStart, 1) : na

prevMid = hasPrev ? (prevH + prevL) / 2.0 : na
prevRange = hasPrev ? prevH - prevL : na
validPrev = hasPrev and not na(prevRange) and prevRange > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Previous Session Range Box
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box rangeBox = na
var line midLine = na

if showPrevRangeBox and validPrev and inSession
    if newSession or na(rangeBox)
        if not na(rangeBox)
            box.delete(rangeBox)
        if not na(midLine)
            line.delete(midLine)

        rangeBox := box.new(
             left=activeStart,
             top=prevH,
             right=bar_index,
             bottom=prevL,
             bgcolor=color.new(boxColor, boxTransp),
             border_color=color.new(boxColor, 20))

        midLine := line.new(
             x1=activeStart,
             y1=prevMid,
             x2=bar_index,
             y2=prevMid,
             color=midColor,
             style=line.style_dashed,
             width=1)
    else
        box.set_left(rangeBox, activeStart)
        box.set_right(rangeBox, bar_index)
        box.set_top(rangeBox, prevH)
        box.set_bottom(rangeBox, prevL)

        line.set_x1(midLine, activeStart)
        line.set_x2(midLine, bar_index)
        line.set_y1(midLine, prevMid)
        line.set_y2(midLine, prevMid)
else
    if not showPrevRangeBox
        if not na(rangeBox)
            box.delete(rangeBox)
            rangeBox := na
        if not na(midLine)
            line.delete(midLine)
            midLine := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Projection Objects
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] projBodies = array.new_box()
var line[] projWicks = array.new_line()
var line[] projOpens = array.new_line()
var label[] projLabels = array.new_label()

f_clear_projection() =>
    for bx in projBodies
        box.delete(bx)
    for ln in projWicks
        line.delete(ln)
    for ln in projOpens
        line.delete(ln)
    for lb in projLabels
        label.delete(lb)

    array.clear(projBodies)
    array.clear(projWicks)
    array.clear(projOpens)
    array.clear(projLabels)

f_draw_projected_candle(float o, float h, float l, float c, int startBar, int x1, string txt) =>
    int x2 = x1 + candleWidth
    int xm = math.round((x1 + x2) / 2)

    color baseColor = c >= o ? projBullColor : projBearColor

    box bodyBox = box.new(
         left=x1,
         top=math.max(o, c),
         right=x2,
         bottom=math.min(o, c),
         bgcolor=baseColor,
         border_color=color.new(baseColor, 0))

    line wick = line.new(
         x1=xm,
         y1=h,
         x2=xm,
         y2=l,
         color=wickColor,
         width=wickWidth)

    int safeStart = math.max(startBar, bar_index - 299)

    line openLine = line.new(
         x1=safeStart,
         y1=o,
         x2=x1,
         y2=o,
         color=openLineColor,
         width=openLineWidth,
         style=line.style_solid)

    array.push(projBodies, bodyBox)
    array.push(projWicks, wick)
    array.push(projOpens, openLine)

    if showProjectionLabels
        label lb = label.new(
             x=xm,
             y=l,
             text=txt,
             style=label.style_none,
             textcolor=color.white,
             size=size.small)
        array.push(projLabels, lb)

if barstate.islast
    f_clear_projection()

    if showProjectedCandles and validPrev and hasActive
        int prevX = bar_index + projOffset
        int activeX = prevX + candleWidth + candleGap

        f_draw_projected_candle(prevO, prevH, prevL, prevC, prevStart, prevX, "Prev")
        f_draw_projected_candle(activeO, activeH, activeL, activeC, activeStart, activeX, "Active")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market Structure BOS / CHOCH + Protected Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)

bodySize = math.abs(close - open)
msBarRange = math.max(high - low, syminfo.mintick)
bodyPct  = bodySize / msBarRange

bullDisplacement = close > open and bodyPct >= dispBodyPctMin and bodySize >= atr * dispAtrMult
bearDisplacement = close < open and bodyPct >= dispBodyPctMin and bodySize >= atr * dispAtrMult

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastHighBar   = na
var int   lastLowBar    = na

var bool highTaken = false
var bool lowTaken  = false
var int trend = 0

if not na(ph)
    lastSwingHigh := ph
    lastHighBar := bar_index - swingLen
    highTaken := false

if not na(pl)
    lastSwingLow := pl
    lastLowBar := bar_index - swingLen
    lowTaken := false

breakBuffer = syminfo.mintick * breakMinTicks

bullBreakRaw = showMS and not na(lastSwingHigh) and not highTaken and close > lastSwingHigh + breakBuffer
bearBreakRaw = showMS and not na(lastSwingLow) and not lowTaken and close < lastSwingLow - breakBuffer

dispBullOK = not useDisplacementBOS or bullDisplacement
dispBearOK = not useDisplacementBOS or bearDisplacement

msConfirmOK = not stateOnClose or barstate.isconfirmed

bullBreak = bullBreakRaw and dispBullOK and msConfirmOK
bearBreak = bearBreakRaw and dispBearOK and msConfirmOK

var line[]  msLines = array.new_line()
var label[] msLabs  = array.new_label()

var line  protectedLine  = na
var label protectedLabel = na
var float protectedLevel = na
var int   protectedDir   = 0

if bullBreak
    bool isChoch = trend == -1
    string txt = isChoch ? "CHOCH" : "BOS"
    color col = bullStructColor

    trend := 1
    highTaken := true

    line l = line.new(
         x1=lastHighBar,
         y1=lastSwingHigh,
         x2=bar_index,
         y2=lastSwingHigh,
         color=col,
         style=line.style_dotted,
         width=2)
    array.push(msLines, l)

    if showMSLabels
        label lb = label.new(
             x=math.round((lastHighBar + bar_index) / 2),
             y=lastSwingHigh,
             text=txt,
             style=label.style_label_down,
             color=col,
             textcolor=color.black,
             size=size.tiny)
        array.push(msLabs, lb)

    if showProtected and not na(lastSwingLow)
        if not na(protectedLine)
            line.delete(protectedLine)
        if not na(protectedLabel)
            label.delete(protectedLabel)

        protectedLevel := lastSwingLow
        protectedDir := 1

        protectedLine := line.new(
             x1=lastLowBar,
             y1=protectedLevel,
             x2=bar_index,
             y2=protectedLevel,
             color=protectedBullColor,
             style=line.style_dashed,
             width=2)

        protectedLabel := label.new(
             x=bar_index,
             y=protectedLevel,
             text="Protected Low",
             style=label.style_label_up,
             color=protectedBullColor,
             textcolor=color.black,
             size=size.tiny)

if bearBreak
    bool isChoch = trend == 1
    string txt = isChoch ? "CHOCH" : "BOS"
    color col = bearStructColor

    trend := -1
    lowTaken := true

    line l = line.new(
         x1=lastLowBar,
         y1=lastSwingLow,
         x2=bar_index,
         y2=lastSwingLow,
         color=col,
         style=line.style_dotted,
         width=2)
    array.push(msLines, l)

    if showMSLabels
        label lb = label.new(
             x=math.round((lastLowBar + bar_index) / 2),
             y=lastSwingLow,
             text=txt,
             style=label.style_label_up,
             color=col,
             textcolor=color.white,
             size=size.tiny)
        array.push(msLabs, lb)

    if showProtected and not na(lastSwingHigh)
        if not na(protectedLine)
            line.delete(protectedLine)
        if not na(protectedLabel)
            label.delete(protectedLabel)

        protectedLevel := lastSwingHigh
        protectedDir := -1

        protectedLine := line.new(
             x1=lastHighBar,
             y1=protectedLevel,
             x2=bar_index,
             y2=protectedLevel,
             color=protectedBearColor,
             style=line.style_dashed,
             width=2)

        protectedLabel := label.new(
             x=bar_index,
             y=protectedLevel,
             text="Protected High",
             style=label.style_label_down,
             color=protectedBearColor,
             textcolor=color.white,
             size=size.tiny)

if showProtected and not na(protectedLine)
    line.set_x2(protectedLine, bar_index)
    if not na(protectedLabel)
        label.set_x(protectedLabel, bar_index)

protectedBullBrokenRaw = protectedDir == 1 and not na(protectedLevel) and (invalidateOnClose ? close < protectedLevel : low < protectedLevel)
protectedBearBrokenRaw = protectedDir == -1 and not na(protectedLevel) and (invalidateOnClose ? close > protectedLevel : high > protectedLevel)

protectedBullBroken = protectedBullBrokenRaw and msConfirmOK
protectedBearBroken = protectedBearBrokenRaw and msConfirmOK

if protectedBullBroken or protectedBearBroken
    if not na(protectedLine)
        line.set_style(protectedLine, line.style_dotted)
        line.set_color(protectedLine, color.gray)

    if not na(protectedLabel)
        label.set_text(protectedLabel, protectedDir == 1 ? "Protected Low Broken" : "Protected High Broken")
        label.set_color(protectedLabel, color.gray)
        label.set_textcolor(protectedLabel, color.white)

    protectedDir := 0
    protectedLevel := na

if array.size(msLines) > maxMS
    line.delete(array.shift(msLines))
    if array.size(msLabs) > 0
        label.delete(array.shift(msLabs))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullBreak, "Bullish BOS / CHOCH", "Bullish BOS/CHOCH detected on {{ticker}} {{interval}}.")
alertcondition(bearBreak, "Bearish BOS / CHOCH", "Bearish BOS/CHOCH detected on {{ticker}} {{interval}}.")
alertcondition(protectedBullBroken, "Protected Low Broken", "Protected Low broken on {{ticker}} {{interval}}.")
alertcondition(protectedBearBroken, "Protected High Broken", "Protected High broken on {{ticker}} {{interval}}.")
````
