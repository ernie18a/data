# Wolf Scalper v1.8

- url: https://www.tradingview.com/script/23U5LkxR-Wolf-Scalper-v1-8/
- type: indicator
- pine_id: PUB;87cb1168273f4db184fac2d7d1cbe94f
- version: 1.0

## Description

The tracker counts a trade as a Win when TP1 hits before SL (catches partials), and a Loss only on a clean stop out. Trades are tracked from the bar they fire and removed from the active list once outcome is determined.

## Source Code

````pine
//@version=6
indicator("Wolf Scalper v1.8", shorttitle="Wolf Scalp v1.8", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=300)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

grpMaster = "Master"
scalpMode    = input.string("All Patterns", "Active Patterns", options=["All Patterns","Sweep Only","iFVG Only","SMT Only"], group=grpMaster)
strictSession= input.bool(true, "HARD Session Gate (A++ only)", group=grpMaster)

grpGrade = "Signal Grades"
showB        = input.bool(true,  "Show B Setups (small ▲▼)",  group=grpGrade)
showAPlus    = input.bool(true,  "Show A++ Setups (big ▲▼)",  group=grpGrade)
bMinConf     = input.int(2,      "B Setup Min Confluences",    group=grpGrade, minval=1, maxval=4)
aPlusMinConf = input.int(3,      "A++ Setup Min Confluences",  group=grpGrade, minval=2, maxval=7)
showEarly    = input.bool(true,  "Show Real-Time ◇ Diamonds",  group=grpGrade)
showExpired  = input.bool(true,  "Show Expired ✕ Diamonds",    group=grpGrade)
earlyColor   = input.color(color.new(#EF9F27, 0),  "Early Diamond Color",   group=grpGrade)
expiredColor = input.color(color.new(#888780, 40), "Expired Diamond Color", group=grpGrade)
cooldownBars = input.int(10,     "Signal Cooldown (bars)",     group=grpGrade, minval=3, maxval=30)
earlyExpiry  = input.int(5,      "Diamond Expiry (bars)",      group=grpGrade, minval=2, maxval=20)
showPatternBadge = input.bool(true, "Show Pattern Badge on Signals", group=grpGrade, tooltip="Shows [SWP], [iFVG], [OB], or [SMT] next to A++ markers")

grpDisc = "Discipline / Filters"
blockWarned   = input.bool(false, "Block Warned Signals (Hard PD Filter)", group=grpDisc, tooltip="ON = skip A++ signals that contradict premium/discount zone")
showOutcomes  = input.bool(true,  "Track Trade Outcomes (W/L)",            group=grpDisc, tooltip="Counts A++ signal results based on whether T1 or SL hits first")

grpSMT = "SMT Divergence"
showSMT      = input.bool(true,  "Show SMT Labels",            group=grpSMT)
showSMTLine  = input.bool(true,  "Show SMT Lines",             group=grpSMT)
smtSym1      = input.symbol("CME_MINI:ES1!",  "Symbol 1",      group=grpSMT)
smtSym2      = input.symbol("CBOT_MINI:YM1!", "Symbol 2",      group=grpSMT)
smtPivotLen  = input.int(3,  "SMT Pivot Length",   group=grpSMT, minval=2, maxval=10)
smtBullColor = input.color(color.new(#1D9E75, 0), "Bull SMT",   group=grpSMT)
smtBearColor = input.color(color.new(#D85A30, 0), "Bear SMT",   group=grpSMT)
smtMaxAge    = input.int(30, "Max Age (bars)",      group=grpSMT, minval=10, maxval=200)
smtRecentBars= input.int(10, "Recent Window (bars)",group=grpSMT, minval=3,  maxval=30)

grpCISD = "CISD Confirmation"
showCISD     = input.bool(true, "Show C2/C3 Labels",           group=grpCISD)
cisdMinBars  = input.int(5,     "Min Bars Between Labels",     group=grpCISD, minval=2, maxval=20)
cisdColor    = input.color(color.new(#1D9E75, 0), "CISD Color",group=grpCISD)

grpSweep = "Liquidity Sweeps"
showSweeps   = input.bool(true,  "Show Sweeps",         group=grpSweep)
sweepLen     = input.int(5,      "Sweep Pivot Length",  group=grpSweep, minval=2, maxval=15)
sweepWick    = input.float(0.25, "Min Wick % Range",    group=grpSweep, minval=0.1, maxval=0.8, step=0.05)

grpFVG = "Micro FVG / iFVG"
showFVG      = input.bool(true, "Show FVGs",           group=grpFVG)
fvgMinTicks  = input.int(1,     "Min FVG (ticks)",     group=grpFVG, minval=1, maxval=20)
fvgMaxShow   = input.int(2,     "Max Per Direction",   group=grpFVG, minval=1, maxval=10)
fvgBullColor = input.color(color.new(#1D9E75, 88), "Bull FVG",  group=grpFVG)
fvgBearColor = input.color(color.new(#D85A30, 88), "Bear FVG",  group=grpFVG)
showIFVG     = input.bool(true, "Show iFVG",           group=grpFVG)
ifvgBullColor= input.color(color.new(#7F77DD, 80), "Bull iFVG", group=grpFVG)
ifvgBearColor= input.color(color.new(#D4537E, 80), "Bear iFVG", group=grpFVG)

grpOB = "Order Blocks"
showOB          = input.bool(true,  "Show Order Blocks",      group=grpOB)
obMaxShow       = input.int(1,      "Max Per Direction",      group=grpOB, minval=1, maxval=5)
obColorBull     = input.color(color.new(#1D9E75, 90), "Bull OB", group=grpOB)
obColorBear     = input.color(color.new(#D85A30, 90), "Bear OB", group=grpOB)
obMitigPct      = input.float(0.5,  "Mitigation % Into OB",  group=grpOB, minval=0.1, maxval=1.0, step=0.1)

grpBPR = "Balanced Price Range (BPR)"
showBPR      = input.bool(true, "Show BPR Zones",      group=grpBPR)
bprColor     = input.color(color.new(#EF9F27, 85), "BPR Color", group=grpBPR)

grpEQL = "Equal Highs / Equal Lows"
showEQHL     = input.bool(true,  "Show EQH/EQL",       group=grpEQL)
eqhlLen      = input.int(8,      "Pivot Length",       group=grpEQL, minval=3, maxval=20)
eqhlTol      = input.float(0.05, "Tolerance (% ATR)",  group=grpEQL, minval=0.01, maxval=0.5, step=0.01)
eqhColor     = input.color(color.new(#D85A30, 0), "EQH Color", group=grpEQL)
eqlColor     = input.color(color.new(#1D9E75, 0), "EQL Color", group=grpEQL)

grpPD = "Premium / Discount"
showPD       = input.bool(true, "Show Zones",            group=grpPD)
pdLen        = input.int(50,    "Range Lookback",        group=grpPD, minval=20, maxval=200)
pdWarnOnly   = input.bool(true, "Warn Instead of Block", group=grpPD)
pdPremColor  = input.color(color.new(#D85A30, 93), "Premium",  group=grpPD)
pdDiscColor  = input.color(color.new(#1D9E75, 93), "Discount", group=grpPD)

grpNYO = "NY Session Open"
showNYOpen   = input.bool(true, "Show NY Open (9:30)",   group=grpNYO)
nyOpenColor  = input.color(color.new(#EF9F27, 0), "NY Open Color", group=grpNYO)

grpCHoCH = "CHoCH"
showCHoCH    = input.bool(true, "Show CHoCH",            group=grpCHoCH)
chochLen     = input.int(3,     "Pivot Length",          group=grpCHoCH, minval=2, maxval=10)
chochColor   = input.color(color.new(#534AB7, 0), "CHoCH Color", group=grpCHoCH)

grpDisp = "Displacement"
useDisp      = input.bool(true,  "Require Displacement",       group=grpDisp)
dispMult     = input.float(1.0,  "Displacement (× ATR)",       group=grpDisp, minval=0.5, maxval=3.0, step=0.1)
maxEntryDist = input.float(1.5,  "Max Entry Distance (× ATR)", group=grpDisp, minval=0.5, maxval=5.0, step=0.1)

grpVol = "Volume Filter"
useVol       = input.bool(false, "Require High Volume",  group=grpVol)
volMult      = input.float(1.5,  "Vol Multiple",         group=grpVol, minval=1.0, maxval=5.0, step=0.1)
volLen       = input.int(20,     "Avg Length",           group=grpVol, minval=10, maxval=50)

grpSess = "Session Filter"
useNYAM      = input.bool(true,  "NY AM (9:30-11:30)",   group=grpSess)
useNYPM      = input.bool(true,  "NY PM (1:30-3:30)",    group=grpSess)
useLondon    = input.bool(true,  "London (3:00-5:00)",   group=grpSess)

grpChop = "Chop Guard"
useChop      = input.bool(true,  "Skip in Chop",         group=grpChop)
chopAtrMin   = input.float(0.4,  "Min ATR vs 50-bar",    group=grpChop, minval=0.2, maxval=2.0, step=0.1)

grpRisk = "Risk Framework"
showRisk     = input.bool(true,   "Show Risk Lines",          group=grpRisk)
showRiskTxt  = input.bool(true,   "Show Risk Text Label",     group=grpRisk)
slMult       = input.float(1.0,   "SL (× ATR)",   group=grpRisk, minval=0.3, maxval=3.0, step=0.1)
tp1Mult      = input.float(1.0,   "TP1 (× R)",    group=grpRisk, minval=0.5, maxval=3.0, step=0.1)
tp2Mult      = input.float(2.0,   "TP2 (× R)",    group=grpRisk, minval=1.0, maxval=5.0, step=0.1)
dollarRisk   = input.float(100.0, "$ Risk/Trade", group=grpRisk, minval=10.0, maxval=10000.0, step=10.0)
riskLineLen  = input.int(40,      "Line Length (bars)", group=grpRisk, minval=10, maxval=200)

grpSig = "Signal Visuals"
sigBullColor = input.color(color.new(#1D9E75, 0), "Buy Signal",    group=grpSig)
sigBearColor = input.color(color.new(#D85A30, 0), "Sell Signal",   group=grpSig)
bSetupColor  = input.color(color.new(#888780, 0), "B Setup Color", group=grpSig)

grpAlrt = "Alerts"
alertSMT     = input.bool(true, "Alert SMT",        group=grpAlrt)
alertSweep   = input.bool(true, "Alert Sweep",      group=grpAlrt)
alertIFVG    = input.bool(true, "Alert iFVG",       group=grpAlrt)
alertB       = input.bool(true, "Alert B Setups",   group=grpAlrt)
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

inActiveSession  = (useNYAM and inNYAM) or (useNYPM and inNYPM) or (useLondon and inLondon)
aPlusSessionGate = strictSession ? inActiveSession : true
bSessionGate     = true

notChop   = not useChop or atr14 > atr50 * chopAtrMin
volOK     = not useVol  or volume > volAvg * volMult
candleBody= math.abs(close - open)
displaced = not useDisp or candleBody > atr14 * dispMult

// ═══════════════════════════════════════════════════════════════════
// NY SESSION OPEN
// ═══════════════════════════════════════════════════════════════════

var float nyOpenPrice = na
var int   nyOpenTime  = na
var line  nyOpenLine  = na
var label nyOpenLbl   = na

isNYOpen = nyHour == 9 and nyMin == 30
if isNYOpen and barstate.isconfirmed
    nyOpenPrice := open
    nyOpenTime  := time

if barstate.islast and showNYOpen and not na(nyOpenPrice)
    line.delete(nyOpenLine)
    label.delete(nyOpenLbl)
    extT = time + (time - time[1]) * 20
    nyOpenLine := line.new(nyOpenTime, nyOpenPrice, extT, nyOpenPrice, xloc=xloc.bar_time, color=nyOpenColor, style=line.style_solid, width=1)
    nyOpenLbl  := label.new(extT, nyOpenPrice, "NYO", xloc=xloc.bar_time, style=label.style_none, textcolor=nyOpenColor, size=size.tiny)

aboveNYOpen = not na(nyOpenPrice) and close > nyOpenPrice
belowNYOpen = not na(nyOpenPrice) and close < nyOpenPrice

// ═══════════════════════════════════════════════════════════════════
// PREMIUM / DISCOUNT
// ═══════════════════════════════════════════════════════════════════

pdHigh    = ta.highest(high, pdLen)
pdLow     = ta.lowest(low,  pdLen)
pdEQ      = (pdHigh + pdLow) / 2
pdPremBot = (pdHigh + pdEQ) / 2
pdDiscTop = (pdEQ + pdLow) / 2

inPremium  = close > pdPremBot
inDiscount = close < pdDiscTop
inEQ       = not inPremium and not inDiscount

var box pdPremBox = na
var box pdDiscBox = na

if showPD and barstate.islast
    box.delete(pdPremBox)
    box.delete(pdDiscBox)
    extT = time + (time - time[1]) * 30
    pdPremBox := box.new(time, pdHigh,    extT, pdPremBot, xloc=xloc.bar_time, bgcolor=pdPremColor, border_color=color.new(#D85A30, 60), border_width=1, text="Prem", text_size=size.tiny, text_color=color.new(#D85A30, 20))
    pdDiscBox := box.new(time, pdDiscTop, extT, pdLow,     xloc=xloc.bar_time, bgcolor=pdDiscColor, border_color=color.new(#1D9E75, 60), border_width=1, text="Disc", text_size=size.tiny, text_color=color.new(#1D9E75, 20))

// ═══════════════════════════════════════════════════════════════════
// EQUAL HIGHS / EQUAL LOWS
// ═══════════════════════════════════════════════════════════════════

phEQ = ta.pivothigh(high, eqhlLen, eqhlLen)
plEQ = ta.pivotlow(low,  eqhlLen, eqhlLen)

var float prevEQH  = na
var float prevEQL  = na
var int   prevEQHt = na
var int   prevEQLt = na

eqTol = atr14 * eqhlTol

if not na(phEQ) and showEQHL
    if not na(prevEQH) and math.abs(phEQ - prevEQH) <= eqTol
        line.new(prevEQHt, prevEQH, time[eqhlLen] + (time - time[1]) * 15, phEQ, xloc=xloc.bar_time, color=eqhColor, style=line.style_dotted, width=1)
        label.new(time[eqhlLen], phEQ + atr14 * 0.2, "EQH", xloc=xloc.bar_time, style=label.style_none, textcolor=eqhColor, size=size.tiny)
    prevEQH  := phEQ
    prevEQHt := time[eqhlLen]

if not na(plEQ) and showEQHL
    if not na(prevEQL) and math.abs(plEQ - prevEQL) <= eqTol
        line.new(prevEQLt, prevEQL, time[eqhlLen] + (time - time[1]) * 15, plEQ, xloc=xloc.bar_time, color=eqlColor, style=line.style_dotted, width=1)
        label.new(time[eqhlLen], plEQ - atr14 * 0.2, "EQL", xloc=xloc.bar_time, style=label.style_none, textcolor=eqlColor, size=size.tiny)
    prevEQL  := plEQ
    prevEQLt := time[eqhlLen]

// ═══════════════════════════════════════════════════════════════════
// SMT DIVERGENCE
// ═══════════════════════════════════════════════════════════════════

[smt1H, smt1L] = request.security(smtSym1, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
[smt2H, smt2L] = request.security(smtSym2, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)

phMain = ta.pivothigh(high, smtPivotLen, smtPivotLen)
plMain = ta.pivotlow(low,  smtPivotLen, smtPivotLen)

var float lastMainPH  = na
var float lastMainPL  = na
var float last1PH     = na
var float last1PL     = na
var float last2PH     = na
var float last2PL     = na
var int   lastMainPHt = na
var int   lastMainPLt = na

type SMTItem
    label lbl
    line  ln
    int   bar

var array<SMTItem> smtItems = array.new<SMTItem>()
smtBullFire = false
smtBearFire = false

if not na(phMain) and showSMT
    sym1H_at = ta.valuewhen(not na(phMain), smt1H[smtPivotLen], 0)
    sym2H_at = ta.valuewhen(not na(phMain), smt2H[smtPivotLen], 0)
    if not na(lastMainPH)
        if phMain > lastMainPH and (sym1H_at < last1PH or sym2H_at < last2PH)
            smtTxt = "SMT - " + (sym1H_at < last1PH ? "ES" : "") + (sym2H_at < last2PH ? "/YM" : "")
            lb = label.new(time[smtPivotLen], phMain, smtTxt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=smtBearColor, textcolor=color.white, size=size.tiny)
            line ln = na
            if showSMTLine
                ln := line.new(lastMainPHt, lastMainPH, time[smtPivotLen], phMain, xloc=xloc.bar_time, color=smtBearColor, style=line.style_dashed, width=1)
            array.push(smtItems, SMTItem.new(lb, ln, bar_index))
            smtBearFire := true
    lastMainPH  := phMain
    lastMainPHt := time[smtPivotLen]
    last1PH     := sym1H_at
    last2PH     := sym2H_at

if not na(plMain) and showSMT
    sym1L_at = ta.valuewhen(not na(plMain), smt1L[smtPivotLen], 0)
    sym2L_at = ta.valuewhen(not na(plMain), smt2L[smtPivotLen], 0)
    if not na(lastMainPL)
        if plMain < lastMainPL and (sym1L_at > last1PL or sym2L_at > last2PL)
            smtTxt = "SMT - " + (sym1L_at > last1PL ? "ES" : "") + (sym2L_at > last2PL ? "/YM" : "")
            lb = label.new(time[smtPivotLen], plMain, smtTxt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=smtBullColor, textcolor=color.white, size=size.tiny)
            line ln = na
            if showSMTLine
                ln := line.new(lastMainPLt, lastMainPL, time[smtPivotLen], plMain, xloc=xloc.bar_time, color=smtBullColor, style=line.style_dashed, width=1)
            array.push(smtItems, SMTItem.new(lb, ln, bar_index))
            smtBullFire := true
    lastMainPL  := plMain
    lastMainPLt := time[smtPivotLen]
    last1PL     := sym1L_at
    last2PL     := sym2L_at

if showSMT
    i = 0
    while i < array.size(smtItems)
        item = array.get(smtItems, i)
        if bar_index - item.bar > smtMaxAge
            label.delete(item.lbl)
            if not na(item.ln)
                line.delete(item.ln)
            array.remove(smtItems, i)
        else
            i += 1

smtBullRecent = ta.barssince(smtBullFire) <= smtRecentBars
smtBearRecent = ta.barssince(smtBearFire) <= smtRecentBars

// ═══════════════════════════════════════════════════════════════════
// CISD
// ═══════════════════════════════════════════════════════════════════

bullC2 = close > close[1] and close[1] > close[2]
bullC3 = bullC2 and close[2] > close[3]
bearC2 = close < close[1] and close[1] < close[2]
bearC3 = bearC2 and close[2] < close[3]

var int lastCISDDir = 0
var int lastCISDBar = na
cisdBullFire = false
cisdBearFire = false

if showCISD and barstate.isconfirmed
    canFire = na(lastCISDBar) or bar_index - lastCISDBar >= cisdMinBars
    if (bullC2 or bullC3) and lastCISDDir != 1 and canFire
        label.new(time, low - atr14 * 0.4, bullC3 ? "C3 ✓" : "C2 ✓", xloc=xloc.bar_time, style=label.style_none, textcolor=cisdColor, size=size.tiny)
        lastCISDDir  := 1
        lastCISDBar  := bar_index
        cisdBullFire := true
    if (bearC2 or bearC3) and lastCISDDir != -1 and canFire
        label.new(time, high + atr14 * 0.4, bearC3 ? "C3 ✓" : "C2 ✓", xloc=xloc.bar_time, style=label.style_none, textcolor=cisdColor, size=size.tiny)
        lastCISDDir  := -1
        lastCISDBar  := bar_index
        cisdBearFire := true

// ═══════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEPS
// ═══════════════════════════════════════════════════════════════════

phS = ta.pivothigh(high, sweepLen, sweepLen)
plS = ta.pivotlow(low,  sweepLen, sweepLen)

var float lastSwH = na
var float lastSwL = na

if not na(phS)
    lastSwH := phS
if not na(plS)
    lastSwL := plS

candleRange = high - low
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low

bsLiqSwept   = not na(lastSwH) and high > lastSwH and close < lastSwH and (upperWick / math.max(candleRange, 0.0001)) > sweepWick
ssLiqSwept   = not na(lastSwL) and low  < lastSwL and close > lastSwL and (lowerWick / math.max(candleRange, 0.0001)) > sweepWick
bsLiqTesting = not na(lastSwH) and high > lastSwH
ssLiqTesting = not na(lastSwL) and low  < lastSwL

if showSweeps and bsLiqSwept and barstate.isconfirmed
    label.new(time, high + atr14 * 0.4, "BSL ✗", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#888780, 0), size=size.tiny)
if showSweeps and ssLiqSwept and barstate.isconfirmed
    label.new(time, low - atr14 * 0.4, "SSL ✗", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#888780, 0), size=size.tiny)

sweepBullRecent = ta.barssince(ssLiqSwept) <= 5
sweepBearRecent = ta.barssince(bsLiqSwept) <= 5

var float lastSwingLowRef  = na
var float lastSwingHighRef = na
if not na(plS)
    lastSwingLowRef  := plS
if not na(phS)
    lastSwingHighRef := phS

entryTooFarLong  = not na(lastSwingLowRef)  and (close - lastSwingLowRef)  > atr14 * maxEntryDist
entryTooFarShort = not na(lastSwingHighRef) and (lastSwingHighRef - close)  > atr14 * maxEntryDist

// ═══════════════════════════════════════════════════════════════════
// MICRO FVG + iFVG + BPR
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

var float lastBullFVGTop = na
var float lastBullFVGBot = na
var float lastBearFVGTop = na
var float lastBearFVGBot = na
var float lastBPRTop     = na
var float lastBPRBot     = na

if showFVG and barstate.isconfirmed
    bullGap = low > high[2] and (low - high[2]) >= minTickSize
    if bullGap
        bx = box.new(time[2], low, time + (time - time[1]) * 15, high[2], xloc=xloc.bar_time, bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, 50), border_width=1)
        array.push(bullFvgList, FVG.new(bx, low, high[2], true, false))
        lastBullFVGTop := low
        lastBullFVGBot := high[2]
        if array.size(bullFvgList) > fvgMaxShow
            box.delete(array.shift(bullFvgList).bx)

    bearGap = high < low[2] and (low[2] - high) >= minTickSize
    if bearGap
        bx = box.new(time[2], low[2], time + (time - time[1]) * 15, high, xloc=xloc.bar_time, bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, 50), border_width=1)
        array.push(bearFvgList, FVG.new(bx, low[2], high, false, false))
        lastBearFVGTop := low[2]
        lastBearFVGBot := high
        if array.size(bearFvgList) > fvgMaxShow
            box.delete(array.shift(bearFvgList).bx)

    // BPR: only fire once per unique overlap
    if showBPR and not na(lastBullFVGTop) and not na(lastBearFVGTop)
        bprTop = math.min(lastBullFVGTop, lastBearFVGTop)
        bprBot = math.max(lastBullFVGBot, lastBearFVGBot)
        bprValid = bprTop > bprBot and (na(lastBPRTop) or math.abs(bprTop - lastBPRTop) > atr14 * 0.3)
        if bprValid
            box.new(time, bprTop, time + (time - time[1]) * 30, bprBot, xloc=xloc.bar_time, bgcolor=bprColor, border_color=color.new(bprColor, 30), border_width=1, text="BPR", text_size=size.tiny, text_color=color.new(#EF9F27, 0))
            lastBPRTop := bprTop
            lastBPRBot := bprBot

ifvgBullFire = false
ifvgBearFire = false

if showFVG
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

inBullFVG  = false
inBearFVG  = false
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
// ORDER BLOCKS — percentage mitigation, ATR-capped size
// ═══════════════════════════════════════════════════════════════════

type OB
    box   bx
    float top
    float bot

var array<OB> bullOBList = array.new<OB>()
var array<OB> bearOBList = array.new<OB>()

bullDisp = close > high[1] and (close - open) > atr14 * 1.0
bearDisp = close < low[1]  and (open - close) > atr14 * 1.0

if showOB and bullDisp and barstate.isconfirmed
    obTop = math.max(open[1], close[1])
    obBot = math.min(open[1], close[1])
    if obTop - obBot <= atr14 * 2.0
        bx = box.new(time[1], obTop, time + (time - time[1]) * 20, obBot, xloc=xloc.bar_time, bgcolor=obColorBull, border_color=color.new(obColorBull, 20))
        array.push(bullOBList, OB.new(bx, obTop, obBot))
        if array.size(bullOBList) > obMaxShow
            box.delete(array.shift(bullOBList).bx)

if showOB and bearDisp and barstate.isconfirmed
    obTop = math.max(open[1], close[1])
    obBot = math.min(open[1], close[1])
    if obTop - obBot <= atr14 * 2.0
        bx = box.new(time[1], obTop, time + (time - time[1]) * 20, obBot, xloc=xloc.bar_time, bgcolor=obColorBear, border_color=color.new(obColorBear, 20))
        array.push(bearOBList, OB.new(bx, obTop, obBot))
        if array.size(bearOBList) > obMaxShow
            box.delete(array.shift(bearOBList).bx)

if showOB
    i = 0
    while i < array.size(bullOBList)
        ob = array.get(bullOBList, i)
        obMid = ob.bot + (ob.top - ob.bot) * (1.0 - obMitigPct)
        if close < obMid
            box.delete(ob.bx)
            array.remove(bullOBList, i)
        else
            i += 1
    i := 0
    while i < array.size(bearOBList)
        ob = array.get(bearOBList, i)
        obMid = ob.top - (ob.top - ob.bot) * (1.0 - obMitigPct)
        if close > obMid
            box.delete(ob.bx)
            array.remove(bearOBList, i)
        else
            i += 1

if barstate.islast and showOB
    extendT = time + (time - time[1]) * 5
    for ob in bullOBList
        box.set_right(ob.bx, extendT)
    for ob in bearOBList
        box.set_right(ob.bx, extendT)

inBullOB = false
inBearOB = false
for ob in bullOBList
    if low <= ob.top and high >= ob.bot
        inBullOB := true
for ob in bearOBList
    if low <= ob.top and high >= ob.bot
        inBearOB := true

// ═══════════════════════════════════════════════════════════════════
// CHoCH
// ═══════════════════════════════════════════════════════════════════

phC = ta.pivothigh(high, chochLen, chochLen)
plC = ta.pivotlow(low,  chochLen, chochLen)

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
    trendDir  := 1
    if showCHoCH
        label.new(time, low - atr14 * 0.6, "CHoCH ↑", xloc=xloc.bar_time, style=label.style_none, textcolor=chochColor, size=size.tiny)

if not na(lastPivotLow) and close < lastPivotLow and trendDir != -1
    chochBear := true
    trendDir  := -1
    if showCHoCH
        label.new(time, high + atr14 * 0.6, "CHoCH ↓", xloc=xloc.bar_time, style=label.style_none, textcolor=chochColor, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// CONFLUENCE ENGINE
// ═══════════════════════════════════════════════════════════════════

patternsAllowed_Sweep = scalpMode == "All Patterns" or scalpMode == "Sweep Only"
patternsAllowed_IFVG  = scalpMode == "All Patterns" or scalpMode == "iFVG Only"
patternsAllowed_SMT   = scalpMode == "All Patterns" or scalpMode == "SMT Only"

confirmedSweepLong  = patternsAllowed_Sweep and ssLiqSwept  and close > open and displaced and not entryTooFarLong
confirmedSweepShort = patternsAllowed_Sweep and bsLiqSwept  and close < open and displaced and not entryTooFarShort
confirmedIFVGLong   = patternsAllowed_IFVG  and inBullIFVG  and close > open and displaced
confirmedIFVGShort  = patternsAllowed_IFVG  and inBearIFVG  and close < open and displaced
confirmedOBLong     = inBullOB and close > open and displaced
confirmedOBShort    = inBearOB and close < open and displaced

confirmedBull = confirmedSweepLong  or confirmedIFVGLong  or confirmedOBLong
confirmedBear = confirmedSweepShort or confirmedIFVGShort or confirmedOBShort

earlyBull = (patternsAllowed_Sweep and ssLiqTesting) or (patternsAllowed_IFVG and inBullIFVG) or (patternsAllowed_SMT and smtBullFire)
earlyBear = (patternsAllowed_Sweep and bsLiqTesting) or (patternsAllowed_IFVG and inBearIFVG) or (patternsAllowed_SMT and smtBearFire)

// PD filtering — combined warn/block logic
pdContradictBull = inPremium  // long in premium = contradiction
pdContradictBear = inDiscount // short in discount = contradiction

pdBullOK = blockWarned ? not pdContradictBull : true
pdBearOK = blockWarned ? not pdContradictBear : true

bullConf = 0
bullConf += confirmedBull                           ? 1 : 0
bullConf += smtBullRecent                           ? 1 : 0
bullConf += sweepBullRecent                         ? 1 : 0
bullConf += chochBull or trendDir == 1              ? 1 : 0
bullConf += inBullFVG or inBullIFVG or inBullOB     ? 1 : 0
bullConf += cisdBullFire                            ? 1 : 0
bullConf += inDiscount                              ? 1 : 0
bullConf += aboveNYOpen                             ? 1 : 0

bearConf = 0
bearConf += confirmedBear                           ? 1 : 0
bearConf += smtBearRecent                           ? 1 : 0
bearConf += sweepBearRecent                         ? 1 : 0
bearConf += chochBear or trendDir == -1             ? 1 : 0
bearConf += inBearFVG or inBearIFVG or inBearOB     ? 1 : 0
bearConf += cisdBearFire                            ? 1 : 0
bearConf += inPremium                               ? 1 : 0
bearConf += belowNYOpen                             ? 1 : 0

var int lastBullSig   = na
var int lastBearSig   = na
var int lastBullEarly = na
var int lastBearEarly = na

aPlusLong  = confirmedBull and bullConf >= aPlusMinConf and aPlusSessionGate and notChop and volOK and pdBullOK and (na(lastBullSig) or bar_index - lastBullSig > cooldownBars)
aPlusShort = confirmedBear and bearConf >= aPlusMinConf and aPlusSessionGate and notChop and volOK and pdBearOK and (na(lastBearSig) or bar_index - lastBearSig > cooldownBars)

bLong  = confirmedBull and bullConf >= bMinConf and bullConf < aPlusMinConf and bSessionGate and notChop and (na(lastBullSig) or bar_index - lastBullSig > cooldownBars)
bShort = confirmedBear and bearConf >= bMinConf and bearConf < aPlusMinConf and bSessionGate and notChop and (na(lastBearSig) or bar_index - lastBearSig > cooldownBars)

earlyLongOK  = earlyBull and notChop and (na(lastBullEarly) or bar_index - lastBullEarly > 2)
earlyShortOK = earlyBear and notChop and (na(lastBearEarly) or bar_index - lastBearEarly > 2)

// Warning labels (only when warn-only mode)
pdWarnBull = pdWarnOnly and not blockWarned and aPlusLong and pdContradictBull
pdWarnBear = pdWarnOnly and not blockWarned and aPlusShort and pdContradictBear

// Pattern badge — identify which pattern triggered the signal
f_patternBadge(isLong) =>
    string b = ""
    if isLong
        if confirmedSweepLong
            b := "[SWP]"
        else if confirmedIFVGLong
            b := "[iFVG]"
        else if confirmedOBLong
            b := "[OB]"
        else if smtBullRecent
            b := "[SMT]"
    else
        if confirmedSweepShort
            b := "[SWP]"
        else if confirmedIFVGShort
            b := "[iFVG]"
        else if confirmedOBShort
            b := "[OB]"
        else if smtBearRecent
            b := "[SMT]"
    b

// ═══════════════════════════════════════════════════════════════════
// EXPIRED DIAMOND TRACKING
// ═══════════════════════════════════════════════════════════════════

type DiamondItem
    int   bar
    int   t
    float price
    bool  isBull
    bool  confirmed
    bool  expired

var array<DiamondItem> diamonds = array.new<DiamondItem>()

if showEarly and earlyLongOK and barstate.isrealtime
    array.push(diamonds, DiamondItem.new(bar_index, time, low - atr14 * 0.3, true, false, false))
    lastBullEarly := bar_index

if showEarly and earlyShortOK and barstate.isrealtime
    array.push(diamonds, DiamondItem.new(bar_index, time, high + atr14 * 0.3, false, false, false))
    lastBearEarly := bar_index

if aPlusLong and barstate.isconfirmed and array.size(diamonds) > 0
    for i = array.size(diamonds) - 1 to 0
        d = array.get(diamonds, i)
        if d.isBull and not d.confirmed and not d.expired and bar_index - d.bar <= earlyExpiry + 2
            d.confirmed := true
            array.set(diamonds, i, d)
            break

if aPlusShort and barstate.isconfirmed and array.size(diamonds) > 0
    for i = array.size(diamonds) - 1 to 0
        d = array.get(diamonds, i)
        if not d.isBull and not d.confirmed and not d.expired and bar_index - d.bar <= earlyExpiry + 2
            d.confirmed := true
            array.set(diamonds, i, d)
            break

if showExpired and barstate.isconfirmed and array.size(diamonds) > 0
    for i = array.size(diamonds) - 1 to 0
        d = array.get(diamonds, i)
        if not d.confirmed and not d.expired and bar_index - d.bar == earlyExpiry
            label.new(d.t, d.price, "✕", xloc=xloc.bar_time, yloc=yloc.price,
                 style=d.isBull ? label.style_label_up : label.style_label_down,
                 color=expiredColor, textcolor=color.white, size=size.tiny)
            d.expired := true
            array.set(diamonds, i, d)

while array.size(diamonds) > 50
    array.shift(diamonds)

// ═══════════════════════════════════════════════════════════════════
// TRADE OUTCOME TRACKER
// ═══════════════════════════════════════════════════════════════════

type ActiveTrade
    bool  isLong
    float entry
    float sl
    float tp1
    float tp2
    int   barFired

var array<ActiveTrade> activeTrades = array.new<ActiveTrade>()
var int totalWins   = 0
var int totalLosses = 0
var int totalTP2    = 0  // T2 hit specifically (full winner)

// Process active trades — check if SL or TP1 hit on this bar
if showOutcomes and array.size(activeTrades) > 0
    i = 0
    while i < array.size(activeTrades)
        tr = array.get(activeTrades, i)
        hitSL  = tr.isLong ? low  <= tr.sl  : high >= tr.sl
        hitTP1 = tr.isLong ? high >= tr.tp1 : low  <= tr.tp1
        hitTP2 = tr.isLong ? high >= tr.tp2 : low  <= tr.tp2

        if hitSL and not hitTP1
            // Pure stop out
            totalLosses += 1
            array.remove(activeTrades, i)
        else if hitTP2
            // Full winner
            totalWins += 1
            totalTP2  += 1
            array.remove(activeTrades, i)
        else if hitTP1
            // Partial winner — count as win
            totalWins += 1
            array.remove(activeTrades, i)
        else
            i += 1

// ═══════════════════════════════════════════════════════════════════
// RISK FRAMEWORK
// ═══════════════════════════════════════════════════════════════════

var line  riskEntryLine = na
var line  riskSLLine    = na
var line  riskTP1Line   = na
var line  riskTP2Line   = na
var label riskEntryLbl  = na
var label riskSLLbl     = na
var label riskTP1Lbl    = na
var label riskTP2Lbl    = na
var label riskTxtLbl    = na
var float riskSLPrice   = na
var float riskTP1Price  = na
var float riskTP2Price  = na
var bool  riskIsLong    = false

f_calcContracts(riskPts) =>
    pointVal    = syminfo.pointvalue
    riskDollars = riskPts * pointVal
    riskDollars > 0 ? math.floor(dollarRisk / riskDollars) : 0

if not na(riskSLPrice) and not na(riskTP1Price)
    hitSL  = riskIsLong ? low  <= riskSLPrice  : high >= riskSLPrice
    hitTP1 = riskIsLong ? high >= riskTP1Price : low  <= riskTP1Price
    if hitSL or hitTP1
        line.delete(riskEntryLine)
        line.delete(riskSLLine)
        line.delete(riskTP1Line)
        line.delete(riskTP2Line)
        label.delete(riskEntryLbl)
        label.delete(riskSLLbl)
        label.delete(riskTP1Lbl)
        label.delete(riskTP2Lbl)
        label.delete(riskTxtLbl)
        riskSLPrice  := na
        riskTP1Price := na
        riskTP2Price := na

if barstate.islast and not na(riskSLPrice)
    extendT = time + (time - time[1]) * riskLineLen
    if not na(riskEntryLine)
        line.set_x2(riskEntryLine, extendT)
        line.set_x2(riskSLLine,    extendT)
        line.set_x2(riskTP1Line,   extendT)
        line.set_x2(riskTP2Line,   extendT)
        label.set_x(riskEntryLbl,  extendT)
        label.set_x(riskSLLbl,     extendT)
        label.set_x(riskTP1Lbl,    extendT)
        label.set_x(riskTP2Lbl,    extendT)

// ═══════════════════════════════════════════════════════════════════
// SIGNAL DRAWING
// ═══════════════════════════════════════════════════════════════════

// B setups
if showB and bLong and barstate.isconfirmed
    label.new(time, low - atr14 * 0.5, "▲", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=bSetupColor, textcolor=color.white, size=size.tiny)
    lastBullSig := bar_index

if showB and bShort and barstate.isconfirmed
    label.new(time, high + atr14 * 0.5, "▼", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=bSetupColor, textcolor=color.white, size=size.tiny)
    lastBearSig := bar_index

// A++ LONG
if showAPlus and aPlusLong and barstate.isconfirmed
    badge = showPatternBadge ? " " + f_patternBadge(true) : ""
    label.new(time, low - atr14 * 0.5, "▲ A++" + badge, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=sigBullColor, textcolor=color.white, size=size.normal)
    if pdWarnBull
        label.new(time, low - atr14 * 1.1, "⚠ Prem", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#EF9F27, 0), size=size.tiny)
    lastBullSig := bar_index
    if showRisk
        line.delete(riskEntryLine)
        line.delete(riskSLLine)
        line.delete(riskTP1Line)
        line.delete(riskTP2Line)
        label.delete(riskEntryLbl)
        label.delete(riskSLLbl)
        label.delete(riskTP1Lbl)
        label.delete(riskTP2Lbl)
        label.delete(riskTxtLbl)
        _entry  = close
        _sl     = close - atr14 * slMult
        _rPts   = _entry - _sl
        _tp1    = _entry + _rPts * tp1Mult
        _tp2    = _entry + _rPts * tp2Mult
        _endT   = time + (time - time[1]) * riskLineLen
        riskEntryLine := line.new(time, _entry, _endT, _entry, xloc=xloc.bar_time, color=color.new(color.white, 30),  style=line.style_dashed, width=1)
        riskSLLine    := line.new(time, _sl,    _endT, _sl,    xloc=xloc.bar_time, color=color.new(#D85A30, 0),       style=line.style_solid,  width=2)
        riskTP1Line   := line.new(time, _tp1,   _endT, _tp1,   xloc=xloc.bar_time, color=color.new(#EF9F27, 0),       style=line.style_dashed, width=1)
        riskTP2Line   := line.new(time, _tp2,   _endT, _tp2,   xloc=xloc.bar_time, color=color.new(#1D9E75, 0),       style=line.style_solid,  width=2)
        riskEntryLbl  := label.new(_endT, _entry, "Entry", xloc=xloc.bar_time, style=label.style_none, textcolor=color.white,           size=size.small)
        riskSLLbl     := label.new(_endT, _sl,    "SL",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#D85A30, 0), size=size.small)
        riskTP1Lbl    := label.new(_endT, _tp1,   "T1",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#EF9F27, 0), size=size.small)
        riskTP2Lbl    := label.new(_endT, _tp2,   "T2",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#1D9E75, 0), size=size.small)
        if showRiskTxt
            _c = f_calcContracts(_rPts)
            riskTxtLbl := label.new(time, _entry - atr14 * 2.2,
                 "▲ " + str.tostring(_entry, format.mintick) +
                 "  SL " + str.tostring(_sl, format.mintick) +
                 "  T1 " + str.tostring(_tp1, format.mintick) +
                 "  T2 " + str.tostring(_tp2, format.mintick) +
                 "  " + str.tostring(_c) + "c",
                 xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#1D9E75, 0), size=size.small)
        riskSLPrice  := _sl
        riskTP1Price := _tp1
        riskTP2Price := _tp2
        riskIsLong   := true
        // Add to outcome tracker
        if showOutcomes
            array.push(activeTrades, ActiveTrade.new(true, _entry, _sl, _tp1, _tp2, bar_index))

// A++ SHORT
if showAPlus and aPlusShort and barstate.isconfirmed
    badge = showPatternBadge ? " " + f_patternBadge(false) : ""
    label.new(time, high + atr14 * 0.5, "▼ A++" + badge, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=sigBearColor, textcolor=color.white, size=size.normal)
    if pdWarnBear
        label.new(time, high + atr14 * 1.1, "⚠ Disc", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#EF9F27, 0), size=size.tiny)
    lastBearSig := bar_index
    if showRisk
        line.delete(riskEntryLine)
        line.delete(riskSLLine)
        line.delete(riskTP1Line)
        line.delete(riskTP2Line)
        label.delete(riskEntryLbl)
        label.delete(riskSLLbl)
        label.delete(riskTP1Lbl)
        label.delete(riskTP2Lbl)
        label.delete(riskTxtLbl)
        _entry  = close
        _sl     = close + atr14 * slMult
        _rPts   = _sl - _entry
        _tp1    = _entry - _rPts * tp1Mult
        _tp2    = _entry - _rPts * tp2Mult
        _endT   = time + (time - time[1]) * riskLineLen
        riskEntryLine := line.new(time, _entry, _endT, _entry, xloc=xloc.bar_time, color=color.new(color.white, 30),  style=line.style_dashed, width=1)
        riskSLLine    := line.new(time, _sl,    _endT, _sl,    xloc=xloc.bar_time, color=color.new(#D85A30, 0),       style=line.style_solid,  width=2)
        riskTP1Line   := line.new(time, _tp1,   _endT, _tp1,   xloc=xloc.bar_time, color=color.new(#EF9F27, 0),       style=line.style_dashed, width=1)
        riskTP2Line   := line.new(time, _tp2,   _endT, _tp2,   xloc=xloc.bar_time, color=color.new(#1D9E75, 0),       style=line.style_solid,  width=2)
        riskEntryLbl  := label.new(_endT, _entry, "Entry", xloc=xloc.bar_time, style=label.style_none, textcolor=color.white,           size=size.small)
        riskSLLbl     := label.new(_endT, _sl,    "SL",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#D85A30, 0), size=size.small)
        riskTP1Lbl    := label.new(_endT, _tp1,   "T1",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#EF9F27, 0), size=size.small)
        riskTP2Lbl    := label.new(_endT, _tp2,   "T2",    xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#1D9E75, 0), size=size.small)
        if showRiskTxt
            _c = f_calcContracts(_rPts)
            riskTxtLbl := label.new(time, _entry + atr14 * 2.2,
                 "▼ " + str.tostring(_entry, format.mintick) +
                 "  SL " + str.tostring(_sl, format.mintick) +
                 "  T1 " + str.tostring(_tp1, format.mintick) +
                 "  T2 " + str.tostring(_tp2, format.mintick) +
                 "  " + str.tostring(_c) + "c",
                 xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(#D85A30, 0), size=size.small)
        riskSLPrice  := _sl
        riskTP1Price := _tp1
        riskTP2Price := _tp2
        riskIsLong   := false
        if showOutcomes
            array.push(activeTrades, ActiveTrade.new(false, _entry, _sl, _tp1, _tp2, bar_index))

// ═══════════════════════════════════════════════════════════════════
// STATUS TABLE
// ═══════════════════════════════════════════════════════════════════

var table statusTbl = table.new(position.bottom_right, 2, 9, border_width=1, frame_color=color.new(color.gray, 50))

if barstate.islast
    sessTxt   = inNYAM ? "NY AM" : inNYPM ? "NY PM" : inLondon ? "London" : "OUT"
    sessColor = inActiveSession ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    chopTxt   = notChop ? "OK" : "CHOP"
    chopColor = notChop ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    volTxt    = volOK ? "HI" : "LO"
    volColor  = volOK ? color.new(#1D9E75, 0) : color.new(#888780, 0)
    gateTxt   = aPlusSessionGate ? "OPEN" : "GATED"
    gateColor = aPlusSessionGate ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)
    pdTxt     = inPremium ? "PREM" : inDiscount ? "DISC" : "EQ"
    pdClr     = inPremium ? color.new(#D85A30, 0) : inDiscount ? color.new(#1D9E75, 0) : color.new(#888780, 0)
    nyoTxt    = not na(nyOpenPrice) ? (aboveNYOpen ? "↑ NYO" : "↓ NYO") : "—"
    nyoColor  = not na(nyOpenPrice) ? (aboveNYOpen ? color.new(#1D9E75, 0) : color.new(#D85A30, 0)) : color.new(#888780, 0)
    confTxt   = str.tostring(bullConf) + "↑  " + str.tostring(bearConf) + "↓"
    totalTrades = totalWins + totalLosses
    winRate     = totalTrades > 0 ? (totalWins * 100.0 / totalTrades) : 0.0
    wlTxt       = str.tostring(totalWins) + "W " + str.tostring(totalLosses) + "L  (" + str.tostring(winRate, "#") + "%)"
    wlColor     = totalLosses == 0 and totalWins == 0 ? color.new(#888780, 0) : winRate >= 60 ? color.new(#1D9E75, 0) : winRate >= 40 ? color.new(#EF9F27, 0) : color.new(#D85A30, 0)

    table.cell(statusTbl, 0, 0, "Session",  text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 0, sessTxt,    text_color=color.white, bgcolor=sessColor,             text_size=size.small)
    table.cell(statusTbl, 0, 1, "A++ Gate", text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 1, gateTxt,    text_color=color.white, bgcolor=gateColor,             text_size=size.small)
    table.cell(statusTbl, 0, 2, "Zone",     text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 2, pdTxt,      text_color=color.white, bgcolor=pdClr,                 text_size=size.small)
    table.cell(statusTbl, 0, 3, "vs NYO",   text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 3, nyoTxt,     text_color=color.white, bgcolor=nyoColor,              text_size=size.small)
    table.cell(statusTbl, 0, 4, "Chop",     text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 4, chopTxt,    text_color=color.white, bgcolor=chopColor,             text_size=size.small)
    table.cell(statusTbl, 0, 5, "Trend",    text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 5, trendDir == 1 ? "↑" : trendDir == -1 ? "↓" : "—", text_color=color.white, bgcolor=trendDir == 1 ? color.new(#1D9E75, 0) : trendDir == -1 ? color.new(#D85A30, 0) : color.new(#888780, 0), text_size=size.small)
    table.cell(statusTbl, 0, 6, "Conf",     text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 6, confTxt,    text_color=color.white, bgcolor=color.new(#534AB7, 0), text_size=size.small)
    table.cell(statusTbl, 0, 7, "ATR",      text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 7, str.tostring(atr14, format.mintick), text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 0, 8, "Record",   text_color=color.white, bgcolor=color.new(#444441, 0), text_size=size.small)
    table.cell(statusTbl, 1, 8, wlTxt,      text_color=color.white, bgcolor=wlColor,               text_size=size.small)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

if alertSMT and smtBullFire
    alert("Bullish SMT on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSMT and smtBearFire
    alert("Bearish SMT on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSweep and ssLiqSwept and close > open
    alert("Bullish Sweep on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertSweep and bsLiqSwept and close < open
    alert("Bearish Sweep on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertIFVG and ifvgBullFire
    alert("Bullish iFVG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertIFVG and ifvgBearFire
    alert("Bearish iFVG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertB and bLong
    alert("B LONG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertB and bShort
    alert("B SHORT on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertAPlus and aPlusLong
    alert("▲ A++ LONG on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertAPlus and aPlusShort
    alert("▼ A++ SHORT on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
