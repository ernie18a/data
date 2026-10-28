# Wolf ICT Master v2

- url: https://www.tradingview.com/script/UdRBO3UR-Wolf-ICT-Master-v2/
- type: indicator
- pine_id: PUB;da709536b8d54052bda61e672cacb9a9
- version: 2.0

## Description

This is based on ICT modals, it is a work in progress as it needs back testing and refining.

## Source Code

````pine
//@version=6
indicator("Wolf Scalper v1.3", shorttitle="Wolf Scalp v1.3", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=300)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

grpMaster = "Master"
scalpMode    = input.string("All Patterns", "Active Patterns", options=["All Patterns","Sweep Only","iFVG Only","SMT Only"], group=grpMaster)
strictSession= input.bool(true, "HARD Session Gate", group=grpMaster)

// Signal Grades
grpGrade = "Signal Grades"
showB        = input.bool(true, "Show B Setups (small ▲▼)", group=grpGrade)
showAPlus    = input.bool(true, "Show A++ Setups (big ▲▼)", group=grpGrade)
bMinConf     = input.int(2, "B Setup Min Confluences", minval=2, maxval=4, group=grpGrade)
aPlusMinConf = input.int(4, "A++ Setup Min Confluences", minval=3, maxval=5, group=grpGrade)
showEarly    = input.bool(true, "Show Real-Time ◇ Diamonds", group=grpGrade)
earlyColor   = input.color(color.new(#EF9F27, 0), "Early Diamond Color", group=grpGrade)

// SMT Divergence
grpSMT = "SMT Divergence"
showSMT      = input.bool(true, "Show SMT Labels", group=grpSMT)
showSMTLine  = input.bool(true, "Show SMT Connecting Lines", group=grpSMT)
smtSym1      = input.symbol("CME_MINI:ES1!", "Correlated Symbol 1", group=grpSMT)
smtSym2      = input.symbol("CBOT_MINI:YM1!", "Correlated Symbol 2", group=grpSMT)
smtPivotLen  = input.int(3, "SMT Pivot Length", minval=2, maxval=10, group=grpSMT)
smtBullColor = input.color(color.new(#1D9E75, 0), "Bullish SMT", group=grpSMT)
smtBearColor = input.color(color.new(#D85A30, 0), "Bearish SMT", group=grpSMT)
smtMaxAge    = input.int(30, "Max SMT Label Age (bars)", minval=10, maxval=200, group=grpSMT)

// CISD
grpCISD = "CISD Confirmation"
showCISD     = input.bool(true, "Show C2/C3 Labels", group=grpCISD)
cisdMinBars  = input.int(5, "Min Bars Between CISD Labels", minval=2, maxval=20, group=grpCISD)
cisdColor    = input.color(color.new(#1D9E75, 0), "CISD Color", group=grpCISD)

// Liquidity Sweeps
grpSweep = "Liquidity Sweeps"
showSweeps   = input.bool(true, "Show Sweeps", group=grpSweep)
sweepLen     = input.int(5, "Sweep Pivot Length", minval=2, maxval=15, group=grpSweep)
sweepWick    = input.float(0.3, "Min Wick % of Range", minval=0.1, maxval=0.8, step=0.05, group=grpSweep)

// Micro FVG / iFVG
grpFVG = "Micro FVG / iFVG"
showFVG      = input.bool(true, "Show Micro FVGs", group=grpFVG)
fvgMinTicks  = input.int(2, "Min FVG Size (ticks)", minval=1, maxval=20, group=grpFVG)
fvgMaxShow   = input.int(3, "Max FVGs Per Direction", minval=1, maxval=10, group=grpFVG)
fvgBullColor = input.color(color.new(#1D9E75, 85), "Bull FVG", group=grpFVG)
fvgBearColor = input.color(color.new(#D85A30, 85), "Bear FVG", group=grpFVG)
showIFVG     = input.bool(true, "Show iFVG", group=grpFVG)
ifvgBullColor= input.color(color.new(#7F77DD, 75), "Bull iFVG", group=grpFVG)
ifvgBearColor= input.color(color.new(#D4537E, 75), "Bear iFVG", group=grpFVG)

// CHoCH
grpCHoCH = "CHoCH"
showCHoCH    = input.bool(true, "Show CHoCH", group=grpCHoCH)
chochLen     = input.int(3, "CHoCH Pivot Length", minval=2, maxval=10, group=grpCHoCH)
chochColor   = input.color(color.new(#534AB7, 0), "CHoCH Color", group=grpCHoCH)

// Displacement
grpDisp = "Displacement"
useDisp      = input.bool(true, "Require Displacement", group=grpDisp)
dispMult     = input.float(1.3, "Displacement (× ATR)", minval=1.0, maxval=3.0, step=0.1, group=grpDisp)

// Volume
grpVol = "Volume Filter"
useVol       = input.bool(true, "Require High Volume", group=grpVol)
volMult      = input.float(1.5, "Vol Multiple of Avg", minval=1.0, maxval=5.0, step=0.1, group=grpVol)
volLen       = input.int(20, "Volume Avg Length", minval=10, maxval=50, group=grpVol)

// Session
grpSess = "Session Filter"
useNYAM      = input.bool(true, "NY AM (9:30-11:30)", group=grpSess)
useNYPM      = input.bool(false, "NY PM (1:30-3:30)", group=grpSess)
useLondon    = input.bool(true, "London (3:00-5:00)", group=grpSess)

// Chop
grpChop = "Chop Guard"
useChop      = input.bool(true, "Skip in Chop", group=grpChop)
chopAtrMin   = input.float(0.5, "Min ATR vs 50-bar Avg", minval=0.3, maxval=2.0, step=0.1, group=grpChop)

// Risk
grpRisk = "Risk Framework"
showRisk     = input.bool(true, "Show Risk Labels (A++ only)", group=grpRisk)
slMult       = input.float(1.0, "SL (× ATR)", minval=0.3, maxval=3.0, step=0.1, group=grpRisk)
tp1Mult      = input.float(1.0, "TP1 (× R)", minval=0.5, maxval=3.0, step=0.1, group=grpRisk)
tp2Mult      = input.float(2.0, "TP2 (× R)", minval=1.0, maxval=5.0, step=0.1, group=grpRisk)
dollarRisk   = input.float(100.0, "$ Risk Per Trade", minval=10.0, maxval=10000.0, step=10.0, group=grpRisk)

// Visuals
grpSig = "Signal Visuals"
sigBullColor = input.color(color.new(#1D9E75, 0), "Buy Signal", group=grpSig)
sigBearColor = input.color(color.new(#D85A30, 0), "Sell Signal", group=grpSig)
bSetupColor  = input.color(color.new(#888780, 0), "B Setup Color", group=grpSig)

// Alerts
grpAlrt = "Alerts"
alertSMT     = input.bool(true, "Alert SMT", group=grpAlrt)
alertSweep   = input.bool(true, "Alert Sweep+Reversal", group=grpAlrt)
alertIFVG    = input.bool(true, "Alert iFVG", group=grpAlrt)
alertB       = input.bool(true, "Alert B Setups", group=grpAlrt)
alertAPlus   = input.bool(true, "Alert A++ Setups", group=grpAlrt)

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

nyHour = hour(time, "America/New_York")
nyMin  = minute(time, "America/New_York")
atr14  = ta.atr(14)
atr50  = ta.atr(50)
volAvg = ta.sma(volume, volLen)

inNYAM   = (nyHour == 9 and nyMin >= 30) or (nyHour >= 10 and nyHour < 11) or (nyHour == 11 and nyMin <= 30)
inNYPM   = (nyHour == 13 and nyMin >= 30) or (nyHour >= 14 and nyHour < 15) or (nyHour == 15 and nyMin <= 30)
inLondon = (nyHour == 3) or (nyHour == 4) or (nyHour == 5 and nyMin == 0)

inActiveSession = (useNYAM and inNYAM) or (useNYPM and inNYPM) or (useLondon and inLondon)
sessionGate = strictSession ? inActiveSession : false

notChop = not useChop or atr14 > atr50 * chopAtrMin
volOK = not useVol or volume > volAvg * volMult

candleBody = math.abs(close - open)
displaced = not useDisp or candleBody > atr14 * dispMult

// ═══════════════════════════════════════════════════════════════════
// SMT DIVERGENCE — with connecting lines
// ═══════════════════════════════════════════════════════════════════

[smt1H, smt1L] = request.security(smtSym1, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
[smt2H, smt2L] = request.security(smtSym2, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)

phMain = ta.pivothigh(high, smtPivotLen, smtPivotLen)
plMain = ta.pivotlow(low,  smtPivotLen, smtPivotLen)

var float lastMainPH = na
var float lastMainPL = na
var float last1PH = na
var float last1PL = na
var float last2PH = na
var float last2PL = na
var int   lastMainPHt = na
var int   lastMainPLt = na

// Track SMT labels and lines for cleanup
var array<label> smtLabels = array.new<label>()
var array<line>  smtLines  = array.new<line>()
var array<int>   smtBars   = array.new<int>()

smtBullFire = false
smtBearFire = false

if not na(phMain) and showSMT
    sym1H_at = ta.valuewhen(not na(phMain), smt1H[smtPivotLen], 0)
    sym2H_at = ta.valuewhen(not na(phMain), smt2H[smtPivotLen], 0)
    if not na(lastMainPH)
        if phMain > lastMainPH and (sym1H_at < last1PH or sym2H_at < last2PH)
            smtTxt = "SMT - " + (sym1H_at < last1PH ? "ES" : "") + (sym2H_at < last2PH ? "/YM" : "")
            lb = label.new(time[smtPivotLen], phMain, smtTxt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=smtBearColor, textcolor=color.white, size=size.tiny)
            array.push(smtLabels, lb)
            array.push(smtBars, bar_index)
            if showSMTLine
                ln = line.new(lastMainPHt, lastMainPH, time[smtPivotLen], phMain, xloc=xloc.bar_time, color=smtBearColor, style=line.style_dashed, width=1)
                array.push(smtLines, ln)
            else
                array.push(smtLines, na)
            smtBearFire := true
    lastMainPH := phMain
    lastMainPHt := time[smtPivotLen]
    last1PH := sym1H_at
    last2PH := sym2H_at

if not na(plMain) and showSMT
    sym1L_at = ta.valuewhen(not na(plMain), smt1L[smtPivotLen], 0)
    sym2L_at = ta.valuewhen(not na(plMain), smt2L[smtPivotLen], 0)
    if not na(lastMainPL)
        if plMain < lastMainPL and (sym1L_at > last1PL or sym2L_at > last2PL)
            smtTxt = "SMT - " + (sym1L_at > last1PL ? "ES" : "") + (sym2L_at > last2PL ? "/YM" : "")
            lb = label.new(time[smtPivotLen], plMain, smtTxt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=smtBullColor, textcolor=color.white, size=size.tiny)
            array.push(smtLabels, lb)
            array.push(smtBars, bar_index)
            if showSMTLine
                ln = line.new(lastMainPLt, lastMainPL, time[smtPivotLen], plMain, xloc=xloc.bar_time, color=smtBullColor, style=line.style_dashed, width=1)
                array.push(smtLines, ln)
            else
                array.push(smtLines, na)
            smtBullFire := true
    lastMainPL := plMain
    lastMainPLt := time[smtPivotLen]
    last1PL := sym1L_at
    last2PL := sym2L_at

// Auto-delete old SMT labels and lines
if showSMT
    i = 0
    while i < array.size(smtBars)
        bar = array.get(smtBars, i)
        if bar_index - bar > smtMaxAge
            label.delete(array.get(smtLabels, i))
            ln = array.get(smtLines, i)
            if not na(ln)
                line.delete(ln)
            array.remove(smtLabels, i)
            array.remove(smtLines, i)
            array.remove(smtBars, i)
        else
            i += 1

smtBullRecent = ta.barssince(smtBullFire) <= 8
smtBearRecent = ta.barssince(smtBearFire) <= 8

// ═══════════════════════════════════════════════════════════════════
// CISD — with min bar distance enforcement
// ═══════════════════════════════════════════════════════════════════

bullC2 = close > close[1] and close[1] > close[2]
bullC3 = bullC2 and close[2] > close[3]
bearC2 = close < close[1] and close[1] < close[2]
bearC3 = bearC2 and close[2] < close[3]

var int   lastCISDDir = 0
var int   lastCISDBar = na
cisdBullFire = false
cisdBearFire = false

if showCISD and barstate.isconfirmed
    canFire = na(lastCISDBar) or bar_index - lastCISDBar >= cisdMinBars
    if (bullC2 or bullC3) and lastCISDDir != 1 and canFire
        lblTxt = bullC3 ? "C3 ✓" : "C2 ✓"
        label.new(time, low - atr14 * 0.4, lblTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=cisdColor, size=size.tiny)
        lastCISDDir := 1
        lastCISDBar := bar_index
        cisdBullFire := true
    if (bearC2 or bearC3) and lastCISDDir != -1 and canFire
        lblTxt = bearC3 ? "C3 ✓" : "C2 ✓"
        label.new(time, high + atr14 * 0.4, lblTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=cisdColor, size=size.tiny)
        lastCISDDir := -1
        lastCISDBar := bar_index
        cisdBearFire := true

// ═══════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEPS
// ═══════════════════════════════════════════════════════════════════

phS = ta.pivothigh(high, sweepLen, sweepLen)
plS = ta.pivotlow(low, sweepLen, sweepLen)

var float lastSwH = na
var float lastSwL = na

if not na(phS)
    lastSwH := phS
if not na(plS)
    lastSwL := plS

candleRange = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bsLiqSwept = not na(lastSwH) and high > lastSwH and close < lastSwH and (upperWick / math.max(candleRange, 0.0001)) > sweepWick
ssLiqSwept = not na(lastSwL) and low  < lastSwL and close > lastSwL and (lowerWick / math.max(candleRange, 0.0001)) > sweepWick

bsLiqTesting = not na(lastSwH) and high > lastSwH
ssLiqTesting = not na(lastSwL) and low  < lastSwL

if showSweeps and bsLiqSwept and barstate.isconfirmed
    label.new(time, high + atr14 * 0.4, "BSL ✗", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#888780, 0), size=size.tiny)

if showSweeps and ssLiqSwept and barstate.isconfirmed
    label.new(time, low - atr14 * 0.4, "SSL ✗", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#888780, 0), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// MICRO FVG + iFVG — capped per direction
// ═══════════════════════════════════════════════════════════════════

type FVG
    box   bx
    float top
    float bot
    bool  bullish
    bool  inverted

var array<FVG> bullFvgList = array.new<FVG>()
var array<FVG> bearFvgList = array.new<FVG>()
minTickSize = syminfo.mintick * fvgMinTicks

if showFVG and barstate.isconfirmed
    bullGap = low > high[2] and (low - high[2]) >= minTickSize
    if bullGap
        bx = box.new(time[2], low, time + (time - time[1]) * 15, high[2], xloc=xloc.bar_time, bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, 50), border_width=1)
        f = FVG.new(bx, low, high[2], true, false)
        array.push(bullFvgList, f)
        if array.size(bullFvgList) > fvgMaxShow
            old = array.shift(bullFvgList)
            box.delete(old.bx)

    bearGap = high < low[2] and (low[2] - high) >= minTickSize
    if bearGap
        bx = box.new(time[2], low[2], time + (time - time[1]) * 15, high, xloc=xloc.bar_time, bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, 50), border_width=1)
        f = FVG.new(bx, low[2], high, false, false)
        array.push(bearFvgList, f)
        if array.size(bearFvgList) > fvgMaxShow
            old = array.shift(bearFvgList)
            box.delete(old.bx)

ifvgBullFire = false
ifvgBearFire = false

if showFVG
    // Process bull FVGs
    i = 0
    while i < array.size(bullFvgList)
        f = array.get(bullFvgList, i)
        if not f.inverted
            if close < f.bot
                if showIFVG
                    box.set_bgcolor(f.bx, ifvgBearColor)
                    box.set_border_color(f.bx, color.new(ifvgBearColor, 30))
                    f.inverted := true
                    array.set(bullFvgList, i, f)
                    ifvgBearFire := true
                    i += 1
                else
                    box.delete(f.bx)
                    array.remove(bullFvgList, i)
            else
                i += 1
        else
            if high > f.top
                box.delete(f.bx)
                array.remove(bullFvgList, i)
            else
                i += 1

    // Process bear FVGs
    i := 0
    while i < array.size(bearFvgList)
        f = array.get(bearFvgList, i)
        if not f.inverted
            if close > f.top
                if showIFVG
                    box.set_bgcolor(f.bx, ifvgBullColor)
                    box.set_border_color(f.bx, color.new(ifvgBullColor, 30))
                    f.inverted := true
                    array.set(bearFvgList, i, f)
                    ifvgBullFire := true
                    i += 1
                else
                    box.delete(f.bx)
                    array.remove(bearFvgList, i)
            else
                i += 1
        else
            if low < f.bot
                box.delete(f.bx)
                array.remove(bearFvgList, i)
            else
                i += 1

    extendT = time + (time - time[1]) * 5
    for f in bullFvgList
        box.set_right(f.bx, extendT)
    for f in bearFvgList
        box.set_right(f.bx, extendT)

inBullFVG = false
inBearFVG = false
inBullIFVG = false
inBearIFVG = false

for f in bullFvgList
    if low <= f.top and high >= f.bot
        if f.inverted
            inBearIFVG := true
        else
            inBullFVG := true
for f in bearFvgList
    if low <= f.top and high >= f.bot
        if f.inverted
            inBullIFVG := true
        else
            inBearFVG := true



// ═══════════════════════════════════════════════════════════════════
// CHoCH
// ═══════════════════════════════════════════════════════════════════

phC = ta.pivothigh(high, chochLen, chochLen)
plC = ta.pivotlow(low, chochLen, chochLen)

var float lastPivotHigh = na
var float lastPivotLow  = na
var int   trendDir = 0

if not na(phC)
    lastPivotHigh := phC
if not na(plC)
    lastPivotLow := plC

chochBull = false
chochBear = false

if not na(lastPivotHigh) and close > lastPivotHigh and trendDir != 1
    chochBull := true
    trendDir := 1
    if showCHoCH
        label.new(time, low - atr14 * 0.6, "CHoCH ↑", xloc=xloc.bar_time, style=label.style_none, textcolor=chochColor, size=size.tiny)

if not na(lastPivotLow) and close < lastPivotLow and trendDir != -1
    chochBear := true
    trendDir := -1
    if showCHoCH
        label.new(time, high + atr14 * 0.6, "CHoCH ↓", xloc=xloc.bar_time, style=label.style_none, textcolor=chochColor, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════════

patternsAllowed_Sweep = scalpMode == "All Patterns" or scalpMode == "Sweep Only"
patternsAllowed_IFVG  = scalpMode == "All Patterns" or scalpMode == "iFVG Only"
patternsAllowed_SMT   = scalpMode == "All Patterns" or scalpMode == "SMT Only"

// EARLY (real-time)
earlySweepLong = patternsAllowed_Sweep and ssLiqTesting
earlySweepShort= patternsAllowed_Sweep and bsLiqTesting
earlyIFVGLong  = patternsAllowed_IFVG and inBullIFVG
earlyIFVGShort = patternsAllowed_IFVG and inBearIFVG
earlySMTLong   = patternsAllowed_SMT and smtBullFire
earlySMTShort  = patternsAllowed_SMT and smtBearFire

earlyBull = earlySweepLong or earlyIFVGLong or earlySMTLong
earlyBear = earlySweepShort or earlyIFVGShort or earlySMTShort

// CONFIRMED triggers
confirmedSweepLong = patternsAllowed_Sweep and ssLiqSwept and close > open and displaced
confirmedSweepShort= patternsAllowed_Sweep and bsLiqSwept and close < open and displaced
confirmedIFVGLong  = patternsAllowed_IFVG and inBullIFVG and close > open and displaced
confirmedIFVGShort = patternsAllowed_IFVG and inBearIFVG and close < open and displaced

confirmedBull = confirmedSweepLong or confirmedIFVGLong
confirmedBear = confirmedSweepShort or confirmedIFVGShort

// Confluence scoring (max 5 points each direction)
bullConf =  0
bullConf += confirmedBull ? 1 : 0
bullConf += smtBullRecent ? 1 : 0
bullConf += chochBull or trendDir == 1 ? 1 : 0
bullConf += inBullFVG or inBullIFVG ? 1 : 0
bullConf += cisdBullFire ? 1 : 0

bearConf = 0
bearConf += confirmedBear ? 1 : 0
bearConf += smtBearRecent ? 1 : 0
bearConf += chochBear or trendDir == -1 ? 1 : 0
bearConf += inBearFVG or inBearIFVG ? 1 : 0
bearConf += cisdBearFire ? 1 : 0

var int lastBullSig = na
var int lastBearSig = na
var int lastBullEarly = na
var int lastBearEarly = na

cooldown = 3

// A++ = high confluence
aPlusLong  = confirmedBull and bullConf >= aPlusMinConf and sessionGate and notChop and (na(lastBullSig) or bar_index - lastBullSig > cooldown)
aPlusShort = confirmedBear and bearConf >= aPlusMinConf and sessionGate and notChop and (na(lastBearSig) or bar_index - lastBearSig > cooldown)

// B = decent confluence (but not A++)
bLong  = confirmedBull and bullConf >= bMinConf and bullConf < aPlusMinConf and sessionGate and notChop and (na(lastBullSig) or bar_index - lastBullSig > cooldown)
bShort = confirmedBear and bearConf >= bMinConf and bearConf < aPlusMinConf and sessionGate and notChop and (na(lastBearSig) or bar_index - lastBearSig > cooldown)

earlyLongOK  = earlyBull and sessionGate and notChop and (na(lastBullEarly) or bar_index - lastBullEarly > 2)
earlyShortOK = earlyBear and sessionGate and notChop and (na(lastBearEarly) or bar_index - lastBearEarly > 2)

// ═══════════════════════════════════════════════════════════════════
// SIGNAL DRAWING
// ═══════════════════════════════════════════════════════════════════

f_calcContracts(riskPts) =>
    pointVal = syminfo.pointvalue
    riskDollars = riskPts * pointVal
    riskDollars > 0 ? math.floor(dollarRisk / riskDollars) : 0

// REAL-TIME diamonds
if showEarly and earlyLongOK and barstate.isrealtime
    label.new(time, low - atr14 * 0.3, "◇", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=earlyColor, textcolor=color.white, size=size.tiny)
    lastBullEarly := bar_index

if showEarly and earlyShortOK and barstate.isrealtime
    label.new(time, high + atr14 * 0.3, "◇", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=earlyColor, textcolor=color.white, size=size.tiny)
    lastBearEarly := bar_index

// B SETUPS — small triangles, gray
if showB and bLong and barstate.isconfirmed
    label.new(time, low - atr14 * 0.5, "▲", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=bSetupColor, textcolor=color.white, size=size.tiny)
    lastBullSig := bar_index

if showB and bShort and barstate.isconfirmed
    label.new(time, high + atr14 * 0.5, "▼", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=bSetupColor, textcolor=color.white, size=size.tiny)
    lastBearSig := bar_index

// A++ SETUPS — big triangles, full color, with risk framework
if showAPlus and aPlusLong and barstate.isconfirmed
    label.new(time, low - atr14 * 0.5, "▲ A++", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=sigBullColor, textcolor=color.white, size=size.normal)
    lastBullSig := bar_index
    if showRisk
        entry = close
        stop  = close - atr14 * slMult
        riskPts = entry - stop
        tp1 = entry + riskPts * tp1Mult
        tp2 = entry + riskPts * tp2Mult
        contracts = f_calcContracts(riskPts)
        riskTxt = "L " + str.tostring(entry, format.mintick) + " | SL " + str.tostring(stop, format.mintick) + " | T1 " + str.tostring(tp1, format.mintick) + " | T2 " + str.tostring(tp2, format.mintick) + " | " + str.tostring(contracts) + "c"
        label.new(time, low - atr14 * 1.6, riskTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=sigBullColor, size=size.tiny)

if showAPlus and aPlusShort and barstate.isconfirmed
    label.new(time, high + atr14 * 0.5, "▼ A++", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=sigBearColor, textcolor=color.white, size=size.normal)
    lastBearSig := bar_index
    if showRisk
        entry = close
        stop  = close + atr14 * slMult
        riskPts = stop - entry
        tp1 = entry - riskPts * tp1Mult
        tp2 = entry - riskPts * tp2Mult
        contracts = f_calcContracts(riskPts)
        riskTxt = "S " + str.tostring(entry, format.mintick) + " | SL " + str.tostring(stop, format.mintick) + " | T1 " + str.tostring(tp1, format.mintick) + " | T2 " + str.tostring(tp2, format.mintick) + " | " + str.tostring(contracts) + "c"
        label.new(time, high + atr14 * 1.6, riskTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=sigBearColor, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// STATUS TABLE
// ═══════════════════════════════════════════════════════════════════

var table statusTbl = table.new(position.bottom_right, 2, 6, border_width=1, frame_color=color.new(color.gray, 50))

if barstate.islast
    sessTxt = inNYAM ? "NY AM" : inNYPM ? "NY PM" : inLondon ? "London" : "OUT"
    sessColor = inActiveSession ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    chopTxt = notChop ? "OK" : "CHOP"
    chopColor = notChop ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    volTxt = volOK ? "HI" : "LO"
    volColor = volOK ? color.new(#1D9E75, 0) : color.new(#888780, 0)
    gateTxt = sessionGate ? "OPEN" : "GATED"
    gateColor = sessionGate ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    confTxt = "B" + str.tostring(math.max(bullConf, bearConf))

    table.cell(statusTbl, 0, 0, "Session", text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 0, sessTxt, text_color=color.white, bgcolor=sessColor, text_size=size.small)
    table.cell(statusTbl, 0, 1, "Gate",    text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 1, gateTxt,   text_color=color.white, bgcolor=gateColor, text_size=size.small)
    table.cell(statusTbl, 0, 2, "Chop",    text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 2, chopTxt,   text_color=color.white, bgcolor=chopColor, text_size=size.small)
    table.cell(statusTbl, 0, 3, "Vol",     text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 3, volTxt,    text_color=color.white, bgcolor=volColor, text_size=size.small)
    table.cell(statusTbl, 0, 4, "Trend",   text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 4, trendDir == 1 ? "↑" : trendDir == -1 ? "↓" : "—", text_color=color.white, bgcolor=trendDir == 1 ? color.new(#1D9E75, 0) : trendDir == -1 ? color.new(#D85A30, 0) : color.new(#888780, 0), text_size=size.small)
    table.cell(statusTbl, 0, 5, "ATR",     text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 5, str.tostring(atr14, format.mintick), text_color=color.white, bgcolor=color.new(#534AB7, 0), text_size=size.small)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

if alertSMT and smtBullFire
    alert("Bullish SMT on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSMT and smtBearFire
    alert("Bearish SMT on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSweep and ssLiqSwept and close > open
    alert("Bullish Sweep+Reversal on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSweep and bsLiqSwept and close < open
    alert("Bearish Sweep+Reversal on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertIFVG and ifvgBullFire
    alert("Bullish iFVG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertIFVG and ifvgBearFire
    alert("Bearish iFVG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertB and bLong
    alert("B LONG setup on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertB and bShort
    alert("B SHORT setup on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertAPlus and aPlusLong
    alert("▲ A++ LONG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertAPlus and aPlusShort
    alert("▼ A++ SHORT on " + syminfo.ticker, alert.freq_once_per_bar_close)


// ORDER BLOCKS
grpOB = "Order Blocks"
showOB = input.bool(true, "Show Order Blocks", group=grpOB)
obColorBull = input.color(color.new(#1D9E75, 80), "Bull OB", group=grpOB)
obColorBear = input.color(color.new(#D85A30, 80), "Bear OB", group=grpOB)

var array<box> bullOBs = array.new<box>()
var array<box> bearOBs = array.new<box>()

bullDisplacement = close > high[1] and (close - open) > atr14 * 1.0
bearDisplacement = close < low[1] and (open - close) > atr14 * 1.0

if showOB and bullDisplacement
    obLow = open[1]
    obHigh = close[1]
    bx = box.new(time[1], obHigh, time + (time - time[1]) * 20, obLow,
        xloc=xloc.bar_time, bgcolor=obColorBull, border_color=color.new(obColorBull, 20))
    array.push(bullOBs, bx)

if showOB and bearDisplacement
    obHigh = open[1]
    obLow = close[1]
    bx = box.new(time[1], obHigh, time + (time - time[1]) * 20, obLow,
        xloc=xloc.bar_time, bgcolor=obColorBear, border_color=color.new(obColorBear, 20))
    array.push(bearOBs, bx)
````
