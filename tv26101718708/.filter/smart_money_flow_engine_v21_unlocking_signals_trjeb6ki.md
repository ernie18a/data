# Smart Money Flow Engine v2.1 (Unlocking Signals)

- url: https://www.tradingview.com/script/TRJeB6ki-Smart-Money-Flow-Engine-v2-1-Unlocking-Signals/
- type: indicator
- pine_id: PUB;7a3a6f508aa048a695dde19262c3cac9
- version: 1.0

## Description

Trend Pulse — Adaptive Momentum Oscillator
Trend Pulse is a momentum oscillator designed to help traders spot shifts in trend strength before they show up clearly on price. It works on any market and timeframe.
How it works: The indicator blends a smoothed rate-of-change calculation with a volatility filter, so readings adapt to current market conditions instead of using fixed thresholds. Rising values suggest building bullish momentum; falling values suggest the opposite.
Features:

– Adaptive overbought/oversold zones

– Optional signal-line crossovers

– Color-coded histogram for quick reads

– Alerts for zone crosses and divergences

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © koushikvarshaa

//@version=6
// =====================================================================
// INSTITUTIONAL SMART MONEY FLOW ENGINE  —  v2.1 (Signal Delivery Fixed)
// =====================================================================

indicator("Smart Money Flow Engine v2.1 (Unlocking Signals)", overlay=true, max_labels_count=500, max_lines_count=200)

// =====================================================================
// INPUTS
// =====================================================================
gMTF = "Multi-Timeframe Hierarchy"
strengthTF   = input.timeframe("60",  "Volume TF (1H)",   group=gMTF, tooltip="1H volume confirmation")
confirmTF    = input.timeframe("240", "Strength TF (4H)", group=gMTF, tooltip="4H trend-strength + direction")
strengthMin = input.int(50, "Min 4H Trend Strength (0-100)", minval=0, maxval=100, group=gMTF, tooltip="50=STRONG")
confirmClose= input.bool(true, "Validate signals on bar close (no repaint)", group=gMTF)

gTrend = "Trend Engine (chart TF = 15m)"
emaFastLen = input.int(9,  "EMA Fast", group=gTrend)
emaMidLen  = input.int(21, "EMA Mid",  group=gTrend)
emaSlowLen = input.int(50, "EMA Slow", group=gTrend)
useEMA200  = input.bool(true, "Require EMA Slow alignment", group=gTrend)
showEMA200 = input.bool(false, "Plot EMA Slow line", group=gTrend)
showVWAP   = input.bool(true, "Plot VWAP line", group=gTrend)
vaMult     = input.float(1.0, "Value-Area band width", group=gTrend)
showVA     = input.bool(false, "Show Value-Area bands", group=gTrend)

gRSI = "RSI Filter"
rsiLen   = input.int(15, "RSI Length", group=gRSI)
rsiBuy   = input.int(55, "CE needs RSI >", group=gRSI)
rsiSell  = input.int(45, "PE needs RSI <", group=gRSI)
rsiOB    = input.int(80, "Overbought block", group=gRSI)
rsiOS    = input.int(20, "Oversold block", group=gRSI)

gADX = "ADX Filter (15m)"
adxLen   = input.int(14, "ADX Length", group=gADX)
adxMin   = input.int(25, "Min ADX for signal (display)", group=gADX)
adxStrong= input.int(30, "Strong-trend ADX", group=gADX)

gVol = "Volume Engine"
volSymInput  = input.symbol("", "Volume Source (Auto-detects NIFTY/BANKNIFTY futures if blank)", group=gVol)
volLen       = input.int(20, "Volume Avg Length", group=gVol)
volMult      = input.float(1.5, "Volume Spike Threshold (15m Sweeps)", group=gVol)
htfVolMin    = input.float(0.9, "Min 1H Volume Ratio (0.9 = Healthy Trend Volume)", group=gVol, tooltip="Lowering this prevents signal starvation.")

gSwing = "Structure / SMC"
swingLen   = input.int(5, "Swing pivot length", group=gSwing)
recentLook = input.int(10,"'Recent' lookback for sweep/BOS scoring", group=gSwing)

gSig = "Signal Control (Balanced-locked)"
maxSignals   = input.int(4, "Max signals per day", group=gSig)
cooldownBars = input.int(6, "Cooldown bars between signals", group=gSig)

gRisk = "Risk / Targets (UNDERLYING points)"
atrLen     = input.int(14, "ATR Length", group=gRisk)
emMult     = input.float(1.25, "Expected Move = ATR x", group=gRisk)
slAtrMult  = input.float(1.2, "Stop = ATR x (vs swing)", group=gRisk)

gStock = "Stock options -> reference index"
useWk = input.bool(true, "52-week high/low proximity", group=gStock)
refIndexSym = input.symbol("", "Reference index", group=gStock)
useRefIndex = input.bool(false, "Require signal to align with reference index", group=gStock)

gSess = "Session (IST)"
useSession = input.bool(false, "Restrict signals to session", group=gSess)
entryWin   = input.session("0915-1530", "Entry window", group=gSess)

gDash = "Dashboard"
dashSizeOpt = input.string("Small", "Table text size", options=["Tiny","Small","Normal"], group=gDash)
dashPosOpt  = input.string("Top Right", "Top table position", options=["Top Right","Top Left"], group=gDash)

gLvl = "Trade Levels on chart"
showLevels    = input.bool(true,  "Draw Entry / SL / Target lines", group=gLvl)
tgt1Pts       = input.int(45,  "Target 1 (points)", group=gLvl)
tgt2Pts       = input.int(90,  "Target 2 (points)", group=gLvl)
useAtrSL      = input.bool(true,  "SL from ATR/swing engine", group=gLvl)
slPtsFixed    = input.int(40,  "Fixed SL points", group=gLvl)
showStructure = input.bool(true,  "Show BOS / CHoCH labels", group=gLvl)
showEarlyWarn = input.bool(true,  "Show Early-Exit warnings", group=gLvl)

// =====================================================================
// HARDCODED BALANCED THRESHOLDS
// =====================================================================
bullScoreMin = 3
bearScoreMin = 3
flowTh       = 25.0
adxMinEff    = 18

// =====================================================================
// AUTO-DETECT SPOT INDEX FOR VOLUME CORRECTION
// =====================================================================
string autoVolSym = volSymInput
if volSymInput == ""
    if syminfo.ticker == "NIFTY"
        autoVolSym := "NSE:NIFTY1!"
    else if syminfo.ticker == "BANKNIFTY"
        autoVolSym := "NSE:BANKNIFTY1!"
    else
        autoVolSym := syminfo.tickerid

f_htf(_src, _tf) => request.security(syminfo.tickerid, _tf, _src[1], lookahead=barmerge.lookahead_on)
f_htfWk(_src)    => request.security(syminfo.tickerid, "1D", _src[1], lookahead=barmerge.lookahead_on)

// =====================================================================
// CORE CALCS (chart TF, e.g. 15m)
// =====================================================================
ema20 = ta.ema(close, emaFastLen)
ema50 = ta.ema(close, emaMidLen)
ema200= ta.ema(close, emaSlowLen)

anchorDaily = timeframe.change("1D")
[vwapValue, vaHigh, vaLow] = ta.vwap(hlc3, anchorDaily, vaMult)

rsiValue = ta.rsi(close, rsiLen)
atrValue = ta.atr(atrLen)

// ADX
upMove   = high - high[1]
downMove = low[1] - low
plusDM   = (upMove > downMove and upMove > 0)   ? upMove   : 0.0
minusDM  = (downMove > upMove and downMove > 0) ? downMove : 0.0
trur     = ta.rma(ta.tr, adxLen)
plusDI   = trur == 0 ? 0.0 : 100 * ta.rma(plusDM,  adxLen) / trur
minusDI  = trur == 0 ? 0.0 : 100 * ta.rma(minusDM, adxLen) / trur
diSum    = plusDI + minusDI
dx       = diSum == 0 ? 0.0 : 100 * math.abs(plusDI - minusDI) / diSum
adx      = ta.rma(dx, adxLen)

// =====================================================================
// VOLUME ENGINE
// =====================================================================
volSeries = request.security(autoVolSym, timeframe.period, volume, lookahead=barmerge.lookahead_off)
volAvg    = ta.sma(volSeries, volLen)
rvol      = volAvg > 0 ? volSeries / volAvg : 0.0
volSpike  = rvol >= volMult
volDryUp  = rvol < 0.7
volTxt    = rvol >= 2.5 ? "EXTREME" : rvol >= 1.5 ? "HIGH" : rvol >= 0.7 ? "NORMAL" : "LOW"

volNativeAvg = ta.sma(volume, volLen)
rvolNative   = volNativeAvg > 0 ? volume / volNativeAvg : 0.0
volSpikeNative = rvolNative >= volMult

// =====================================================================
// TREND STRENGTH SCORE
// =====================================================================
adxComp = math.min(adx / 40.0, 1.0) * 40.0
emaBullStack = ema20 > ema50 and ema50 > ema200
emaBearStack = ema20 < ema50 and ema50 < ema200
emaComp = (emaBullStack or emaBearStack) ? 30.0 : (ema20 != ema50 ? 15.0 : 0.0)
vwapComp = math.min(math.abs(close - vwapValue) / (atrValue == 0 ? 1 : atrValue), 1.0) * 20.0
volComp = volSpikeNative ? 10.0 : (rvolNative > 1 ? 5.0 : 0.0)
trendStrength = adxComp + emaComp + vwapComp + volComp

// =====================================================================
// MTF HIERARCHY
// =====================================================================
s_e20 = f_htf(ema20, strengthTF)
s_e50 = f_htf(ema50, strengthTF)
htfStrBull = s_e20 > s_e50
htfStrBear = s_e20 < s_e50

c_e20 = f_htf(ema20, confirmTF)
c_e50 = f_htf(ema50, confirmTF)
htfConfBull = c_e20 > c_e50
htfConfBear = c_e20 < c_e50

htfStrength = request.security(syminfo.tickerid, confirmTF, trendStrength[1], lookahead=barmerge.lookahead_on)
htf4hOk = htfStrength >= strengthMin

[v1h, va1h] = request.security(autoVolSym, strengthTF, [volume[1], ta.sma(volume, volLen)[1]], lookahead=barmerge.lookahead_on)
volDataOk = va1h > 0
rvol1h  = volDataOk ? v1h / va1h : 0.0
volOk1h = volDataOk and rvol1h >= htfVolMin

gate4hBull = htfConfBull and htf4hOk
gate4hBear = htfConfBear and htf4hOk
gate1hBull = htfStrBull and volOk1h
gate1hBear = htfStrBear and volOk1h
mtfBull = gate4hBull and gate1hBull   
mtfBear = gate4hBear and gate1hBear

// =====================================================================
// REFERENCE INDEX
// =====================================================================
refSym = refIndexSym == "" ? syminfo.tickerid : refIndexSym
refE20 = request.security(refSym, confirmTF, ta.ema(close, emaFastLen)[1], lookahead=barmerge.lookahead_on)
refE50 = request.security(refSym, confirmTF, ta.ema(close, emaMidLen)[1],  lookahead=barmerge.lookahead_on)
refBull = refE20 > refE50
refBear = refE20 < refE50
refOn   = useRefIndex and refIndexSym != ""
refAlignBull = not refOn or refBull
refAlignBear = not refOn or refBear

// =====================================================================
// 52-WEEK CONTEXT
// =====================================================================
wkHigh = f_htfWk(ta.highest(high, 252))
wkLow  = f_htfWk(ta.lowest(low, 252))
near52H = useWk and not na(wkHigh) and close >= wkHigh * 0.99
near52L = useWk and not na(wkLow)  and close <= wkLow  * 1.01

// =====================================================================
// SWINGS / STRUCTURE
// =====================================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float lastSH = na
var float prevSH = na
var float lastSL = na
var float prevSL = na
var float lastSHrsi = na
var float prevSHrsi = na
var float lastSLrsi = na
var float prevSLrsi = na
var int structTrend = 0

if not na(ph)
    prevSH := lastSH
    lastSH := ph
    prevSHrsi := lastSHrsi
    lastSHrsi := rsiValue[swingLen]
if not na(pl)
    prevSL := lastSL
    lastSL := pl
    prevSLrsi := lastSLrsi
    lastSLrsi := rsiValue[swingLen]

bullStruct = not na(lastSH) and not na(prevSH) and not na(lastSL) and not na(prevSL) and lastSH > prevSH and lastSL > prevSL
bearStruct = not na(lastSH) and not na(prevSH) and not na(lastSL) and not na(prevSL) and lastSH < prevSH and lastSL < prevSL
if bullStruct
    structTrend := 1
if bearStruct
    structTrend := -1

crossUp = not na(lastSH) and close > lastSH and close[1] <= lastSH
crossDn = not na(lastSL) and close < lastSL and close[1] >= lastSL
bullBOS   = crossUp and structTrend ==  1
bullCHOCH = crossUp and structTrend == -1
bearBOS   = crossDn and structTrend == -1
bearCHOCH = crossDn and structTrend ==  1

bullSweep = not na(lastSL) and low  < lastSL and close > lastSL and volSpike
bearSweep = not na(lastSH) and high > lastSH and close < lastSH and volSpike

bsBull = ta.barssince(bullSweep)
bsBear = ta.barssince(bearSweep)
boBull = ta.barssince(bullBOS)
boBear = ta.barssince(bearBOS)
bullSweepRecent = not na(bsBull) and bsBull <= recentLook
bearSweepRecent = not na(bsBear) and bsBear <= recentLook
bullBOSRecent   = not na(boBull) and boBull <= recentLook
bearBOSRecent   = not na(boBear) and boBear <= recentLook

bearDiv = not na(lastSH) and not na(prevSH) and lastSH > prevSH and lastSHrsi < prevSHrsi
bullDiv = not na(lastSL) and not na(prevSL) and lastSL < prevSL and lastSLrsi > prevSLrsi

// =====================================================================
// SMART MONEY SCORES
// =====================================================================
bullScore = (close > vwapValue ? 1 : 0) + (ema20 > ema50 ? 1 : 0) + (bullSweepRecent ? 1 : 0) + (bullBOSRecent ? 1 : 0) + (volSpike ? 1 : 0) + (close > vaHigh ? 1 : 0)
bearScore = (close < vwapValue ? 1 : 0) + (ema20 < ema50 ? 1 : 0) + (bearSweepRecent ? 1 : 0) + (bearBOSRecent ? 1 : 0) + (volSpike ? 1 : 0) + (close < vaLow ? 1 : 0)

scoreSum = bullScore + bearScore
bullPct = scoreSum == 0 ? 50.0 : 100.0 * bullScore / scoreSum
bearPct = scoreSum == 0 ? 50.0 : 100.0 * bearScore / scoreSum
flowMeter = scoreSum == 0 ? 0.0 : 100.0 * (bullScore - bearScore) / scoreSum

biasTxt = bullPct >= 75 ? "STRONG BULLISH" : bullPct >= 60 ? "MODERATE BULLISH" : bearPct >= 75 ? "STRONG BEARISH" : bearPct >= 60 ? "MODERATE BEARISH" : "NEUTRAL"
biasCol = bullPct >= 60 ? color.green : bearPct >= 60 ? color.red : color.gray
flowTxt = flowMeter >= 75 ? "HEAVY BULL ACCUM" : flowMeter >= 40 ? "BULL ACCUM" : flowMeter <= -75 ? "HEAVY BEAR ACCUM" : flowMeter <= -40 ? "BEAR ACCUM" : "NEUTRAL"

// =====================================================================
// EXPECTED MOVE / STOP LOSS
// =====================================================================
expMove = atrValue * emMult
bmp = (trendStrength >= 75 ? 2 : trendStrength >= 50 ? 1 : 0) + (volSpike ? 1 : 0) + (math.max(bullScore, bearScore) >= 5 ? 1 : 0) + (adx > adxStrong ? 1 : 0) + ((bullSweep or bearSweep) ? 1 : 0) + ((near52H or near52L) ? 1 : 0)
bmpTxt = bmp >= 5 ? "EXTREME" : bmp >= 4 ? "HIGH" : bmp >= 2 ? "MEDIUM" : "LOW"

slLongDist  = math.max(slAtrMult * atrValue, na(lastSL) ? slAtrMult * atrValue : close - lastSL)
slShortDist = math.max(slAtrMult * atrValue, na(lastSH) ? slAtrMult * atrValue : lastSH - close)

// =====================================================================
// TREND SELECTION
// =====================================================================
inEntryWin = not useSession or not na(time(timeframe.period, entryWin, "Asia/Kolkata"))
emaBull = ema20 > ema50 and (not useEMA200 or ema50 > ema200)
emaBear = ema20 < ema50 and (not useEMA200 or ema50 < ema200)
trendBull = emaBull and close > vwapValue
trendBear = emaBear and close < vwapValue

// =====================================================================
// SIGNAL LOGIC
// =====================================================================
confOk = not confirmClose or barstate.isconfirmed

ceTrigger = ta.crossover(rsiValue, rsiBuy) or bullBOS or bullSweep
peTrigger = ta.crossunder(rsiValue, rsiSell) or bearBOS or bearSweep

ceFilters = gate4hBull and gate1hBull and refAlignBull and trendBull and rsiValue > rsiBuy and rsiValue < rsiOB and bullScore >= bullScoreMin and flowMeter > flowTh and close > vwapValue and adx > adxMinEff and inEntryWin
peFilters = gate4hBear and gate1hBear and refAlignBear and trendBear and rsiValue < rsiSell and rsiValue > rsiOS and bearScore >= bearScoreMin and flowMeter < -flowTh and close < vwapValue and adx > adxMinEff and inEntryWin

ceRaw = ceTrigger and ceFilters and confOk
peRaw = peTrigger and peFilters and confOk

var int sigCount = 0
if timeframe.change("1D")
    sigCount := 0
var int lastSigBar = na
cooldownOk = na(lastSigBar) or (bar_index - lastSigBar) >= cooldownBars
capOk = sigCount < maxSignals

var int posState = 0

ceSignal = ceRaw and capOk and cooldownOk and posState == 0
peSignal = peRaw and capOk and cooldownOk and posState == 0

// =====================================================================
// DIAGNOSTIC CONDITION COUNTER (For Dashboard debugging)
// =====================================================================
int bullMatches = (gate4hBull?1:0) + (gate1hBull?1:0) + (trendBull?1:0) + (rsiValue > rsiBuy?1:0) + (bullScore >= bullScoreMin?1:0) + (flowMeter > flowTh?1:0) + (adx > adxMinEff?1:0)
int bearMatches = (gate4hBear?1:0) + (gate1hBear?1:0) + (trendBear?1:0) + (rsiValue < rsiSell?1:0) + (bearScore >= bearScoreMin?1:0) + (flowMeter < -flowTh?1:0) + (adx > adxMinEff?1:0)

// =====================================================================
// ACTIVE POSITION MANAGEMENT ENGINE
// =====================================================================
var float tEntry = na
var float tSL    = na
var float tT1    = na
var float tT2    = na

var line lnE = na
var line lnS = na
var line ln1 = na
var line ln2 = na

var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na

if ceSignal
    posState := 1
    sigCount := sigCount + 1
    lastSigBar := bar_index
    
    slDist = useAtrSL ? slLongDist : slPtsFixed
    tEntry := close
    tSL    := close - slDist
    tT1    := close + tgt1Pts
    tT2    := close + tgt2Pts
    
    label.new(bar_index, low, "BUY CE", yloc=yloc.belowbar, style=label.style_label_up, color=color.green, textcolor=color.white, size=size.normal)
    
    if showLevels
        lnE := line.new(bar_index, tEntry, bar_index, tEntry, color=color.white, width=1, style=line.style_solid)
        lnS := line.new(bar_index, tSL,    bar_index, tSL,    color=color.red,   width=1, style=line.style_dashed)
        ln1 := line.new(bar_index, tT1,    bar_index, tT1,    color=color.aqua,  width=1, style=line.style_dotted)
        ln2 := line.new(bar_index, tT2,    bar_index, tT2,    color=color.aqua,  width=1, style=line.style_dotted)
        
        lbE := label.new(bar_index, tEntry, "ENTRY CE " + str.tostring(math.round_to_mintick(tEntry)), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small)
        lbS := label.new(bar_index, tSL,    "SL "     + str.tostring(math.round_to_mintick(tSL)),    style=label.style_label_left, color=color.red,   textcolor=color.white, size=size.tiny)
        lb1 := label.new(bar_index, tT1,    "T1 "     + str.tostring(math.round_to_mintick(tT1)),    style=label.style_label_left, color=color.teal,  textcolor=color.white, size=size.tiny)
        lb2 := label.new(bar_index, tT2,    "T2 "     + str.tostring(math.round_to_mintick(tT2)),    style=label.style_label_left, color=color.teal,  textcolor=color.white, size=size.tiny)

if peSignal
    posState := -1
    sigCount := sigCount + 1
    lastSigBar := bar_index
    
    slDist = useAtrSL ? slShortDist : slPtsFixed
    tEntry := close
    tSL    := close + slDist
    tT1    := close - tgt1Pts
    tT2    := close - tgt2Pts
    
    label.new(bar_index, high, "BUY PE", yloc=yloc.abovebar, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)
    
    if showLevels
        lnE := line.new(bar_index, tEntry, bar_index, tEntry, color=color.white, width=1, style=line.style_solid)
        lnS := line.new(bar_index, tSL,    bar_index, tSL,    color=color.red,   width=1, style=line.style_dashed)
        ln1 := line.new(bar_index, tT1,    bar_index, tT1,    color=color.aqua,  width=1, style=line.style_dotted)
        ln2 := line.new(bar_index, tT2,    bar_index, tT2,    color=color.aqua,  width=1, style=line.style_dotted)
        
        lbE := label.new(bar_index, tEntry, "ENTRY PE " + str.tostring(math.round_to_mintick(tEntry)), style=label.style_label_left, color=color.red,  textcolor=color.white, size=size.small)
        lbS := label.new(bar_index, tSL,    "SL "     + str.tostring(math.round_to_mintick(tSL)),    style=label.style_label_left, color=color.red,  textcolor=color.white, size=size.tiny)
        lb1 := label.new(bar_index, tT1,    "T1 "     + str.tostring(math.round_to_mintick(tT1)),    style=label.style_label_left, color=color.teal, textcolor=color.white, size=size.tiny)
        lb2 := label.new(bar_index, tT2,    "T2 "     + str.tostring(math.round_to_mintick(tT2)),    style=label.style_label_left, color=color.teal, textcolor=color.white, size=size.tiny)

if posState != 0 and showLevels and not na(lnE)
    line.set_x2(lnE, bar_index)
    line.set_x2(lnS, bar_index)
    line.set_x2(ln1, bar_index)
    line.set_x2(ln2, bar_index)
    
    label.set_x(lbE, bar_index)
    label.set_x(lbS, bar_index)
    label.set_x(lb1, bar_index)
    label.set_x(lb2, bar_index)

// =====================================================================
// EARLY EXIT ENGINE
// =====================================================================
lostVwapLong  = close < vwapValue and close[1] >= vwapValue
lostVwapShort = close > vwapValue and close[1] <= vwapValue
exitLongTrig  = adx < adxMinEff or lostVwapLong  or bearDiv or bearSweep or volDryUp or bullScore < 3
exitShortTrig = adx < adxMinEff or lostVwapShort or bullDiv or bullSweep or volDryUp or bearScore < 3

exitLong  = posState == 1  and exitLongTrig  and confOk and not ceSignal
exitShort = posState == -1 and exitShortTrig and confOk and not peSignal

if exitLong
    label.new(bar_index, high, "EXIT CE", yloc=yloc.abovebar, style=label.style_label_down, color=color.orange, textcolor=color.black, size=size.small)
    posState := 0
    tEntry := na, tSL := na, tT1 := na, tT2 := na, lnE := na, lnS := na, ln1 := na, ln2 := na

if exitShort
    label.new(bar_index, low, "EXIT PE", yloc=yloc.belowbar, style=label.style_label_up, color=color.orange, textcolor=color.black, size=size.small)
    posState := 0
    tEntry := na, tSL := na, tT1 := na, tT2 := na, lnE := na, lnS := na, ln1 := na, ln2 := na

bearDivEvent = bearDiv and not bearDiv[1]
bullDivEvent = bullDiv and not bullDiv[1]
warnExitLong  = trendBull and (lostVwapLong  or bearDivEvent or bearSweep) and confOk
warnExitShort = trendBear and (lostVwapShort or bullDivEvent or bullSweep) and confOk
earlyWarnAlert = warnExitLong or warnExitShort

// =====================================================================
// VISUALS
// =====================================================================
plot(ema20, "EMA Fast", color.new(color.green, 0), 1)
plot(ema50, "EMA Mid", color.new(color.orange,0), 1)
plot(useEMA200 and showEMA200 ? ema200 : na, "EMA Slow", color.new(color.red, 0), 1)
vwapPlot = (showVWAP and not anchorDaily) ? vwapValue : na
plot(vwapPlot, "VWAP / POC", color.new(color.yellow, 0), 2)

plotshape(bullSweep, "Bull Sweep", shape.triangleup,   location.belowbar, color.new(color.lime,0), size=size.tiny)
plotshape(bearSweep, "Bear Sweep", shape.triangledown, location.abovebar, color.new(color.fuchsia,0), size=size.tiny)

structLabelOk = showStructure and barstate.isconfirmed
if bullBOS and structLabelOk
    label.new(bar_index, low,  "BOS", yloc=yloc.price, style=label.style_label_up,   color=color.new(color.green,30), textcolor=color.white, size=size.tiny)
if bearBOS and structLabelOk
    label.new(bar_index, high, "BOS", yloc=yloc.price, style=label.style_label_down, color=color.new(color.red,30),   textcolor=color.white, size=size.tiny)
if bullCHOCH and structLabelOk
    label.new(bar_index, low,  "CHoCH", yloc=yloc.price, style=label.style_label_up,   color=color.new(color.teal,20), textcolor=color.white, size=size.tiny)
if bearCHOCH and structLabelOk
    label.new(bar_index, high, "CHoCH", yloc=yloc.price, style=label.style_label_down, color=color.new(color.maroon,20),textcolor=color.white, size=size.tiny)

plotshape(showEarlyWarn and earlyWarnAlert, "Early Exit Warning", shape.flag, location.abovebar, color.purple, text="WARN", textcolor=color.white, size=size.tiny)

bgcolor(trendBull ? color.new(color.green, 94) : trendBear ? color.new(color.red, 94) : na)

// =====================================================================
// DASHBOARDS
// =====================================================================
f_col(_b, _r) => _b ? color.green : _r ? color.red : color.gray
sweepStat = bullSweep ? "BULL SWEEP" : bearSweep ? "BEAR SWEEP" : bullSweepRecent ? "bull (recent)" : bearSweepRecent ? "bear (recent)" : "NONE"
sigStat   = ceSignal ? "CE FIRED" : peSignal ? "PE FIRED" : posState == 1 ? "IN CE (live)" : posState == -1 ? "IN PE (live)" : ceFilters ? "CE armed" : peFilters ? "PE armed" : "—"
dirTxt    = posState == 1 ? "LONG / CE" : posState == -1 ? "SHORT / PE" : "FLAT"
mktState  = trendBull ? "BULLISH" : trendBear ? "BEARISH" : "RANGE/NEUTRAL"
activeSL  = posState == -1 ? slShortDist : slLongDist
rrWarn    = activeSL > tgt1Pts and posState != 0
f_px(_v)  => na(_v) ? "—" : str.tostring(math.round_to_mintick(_v))

tSize   = dashSizeOpt == "Tiny" ? size.tiny : dashSizeOpt == "Normal" ? size.normal : size.small
topPos  = dashPosOpt == "Top Left" ? position.top_left : position.top_right
botPos  = dashPosOpt == "Top Left" ? position.bottom_left : position.bottom_right

// TOP TABLE
var table topT = table.new(topPos, 2, 10, bgcolor=color.new(color.black, 12), border_color=color.gray, border_width=1)
if barstate.islast
    table.cell(topT, 0, 0, "SMART MONEY v2.1", text_color=color.yellow, text_size=tSize)
    table.cell(topT, 1, 0, sigStat, text_color=color.white, bgcolor=ceSignal?color.green:peSignal?color.red:posState!=0?color.new(color.blue,40):color.new(color.gray,40), text_size=tSize)
    table.cell(topT, 0, 1, "Market State (15m)", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 1, mktState, text_color=color.white, bgcolor=f_col(trendBull, trendBear), text_size=tSize)
    table.cell(topT, 0, 2, "4H Trend", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 2, (htfConfBull?"BULL":"BEAR") + (htf4hOk?" ✓":" ✗"), text_color=gate4hBull?color.green:gate4hBear?color.red:color.gray, text_size=tSize)
    table.cell(topT, 0, 3, "4H Strength", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 3, str.tostring(math.round(htfStrength)) + " / " + str.tostring(strengthMin), text_color=htf4hOk?color.green:color.orange, text_size=tSize)
    table.cell(topT, 0, 4, "1H Volume Ratio", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 4, volDataOk ? (str.tostring(math.round(rvol1h,2)) + "x" + (volOk1h?" ✓":" ✗")) : "NO VOL DATA", text_color=not volDataOk?color.red:volOk1h?color.green:color.orange, text_size=tSize)
    table.cell(topT, 0, 5, "Smart Money Bias", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 5, biasTxt, text_color=color.white, bgcolor=biasCol, text_size=tSize)
    table.cell(topT, 0, 6, "Flow Meter", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 6, str.tostring(math.round(flowMeter)) + " " + flowTxt, text_color=flowMeter>=40?color.green:flowMeter<=-40?color.red:color.gray, text_size=tSize)
    table.cell(topT, 0, 7, "RSI (" + str.tostring(rsiLen) + ")", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 7, str.tostring(math.round(rsiValue)), text_color=rsiValue>rsiBuy?color.green:rsiValue<rsiSell?color.red:color.white, text_size=tSize)
    table.cell(topT, 0, 8, refOn ? "Ref Index" : "52wH / 52wL", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 8, refOn ? (refBull?"BULL":"BEAR") : (near52H?"NEAR HIGH":near52L?"NEAR LOW":"—"), text_color=refOn ? (refBull?color.green:color.red) : (near52H?color.green:near52L?color.red:color.gray), text_size=tSize)
    table.cell(topT, 0, 9, "Signals today", text_color=color.white, text_size=tSize)
    table.cell(topT, 1, 9, str.tostring(sigCount) + " / " + str.tostring(maxSignals), text_color=capOk?color.white:color.orange, text_size=tSize)

// BOTTOM TABLE
var table botT = table.new(botPos, 2, 11, bgcolor=color.new(color.black, 12), border_color=color.gray, border_width=1)
if barstate.islast
    table.cell(botT, 0, 0, "TRADE PLAN", text_color=color.yellow, text_size=tSize)
    table.cell(botT, 1, 0, dirTxt, text_color=color.white, bgcolor=f_col(posState==1, posState==-1), text_size=tSize)
    table.cell(botT, 0, 1, "Entry", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 1, f_px(tEntry), text_color=color.white, text_size=tSize)
    table.cell(botT, 0, 2, "Stop Loss", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 2, f_px(tSL) + " (" + str.tostring(math.round(activeSL)) + "p)", text_color=color.red, text_size=tSize)
    table.cell(botT, 0, 3, "Target 1", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 3, f_px(tT1) + " (" + str.tostring(tgt1Pts) + "p)", text_color=color.teal, text_size=tSize)
    table.cell(botT, 0, 4, "Target 2", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 4, f_px(tT2) + " (" + str.tostring(tgt2Pts) + "p)", text_color=color.teal, text_size=tSize)
    table.cell(botT, 0, 5, "Expected Move", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 5, "+/- " + str.tostring(math.round(expMove)), text_color=color.white, text_size=tSize)
    table.cell(botT, 0, 6, "Liquidity Sweep", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 6, sweepStat, text_color=bullSweep?color.green:bearSweep?color.red:color.gray, text_size=tSize)
    table.cell(botT, 0, 7, "Vol (chart/15m)", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 7, str.tostring(math.round(rvol,2)) + "x " + volTxt, text_color=volSpike?color.orange:color.white, text_size=tSize)
    table.cell(botT, 0, 8, "Big Move Prob.", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 8, bmpTxt, text_color=bmp>=4?color.green:bmp>=2?color.orange:color.gray, text_size=tSize)
    table.cell(botT, 0, 9, "Filter Debugger", text_color=color.yellow, text_size=tSize)
    table.cell(botT, 1, 9, "CE: " + str.tostring(bullMatches) + "/7 | PE: " + str.tostring(bearMatches) + "/7", text_color=color.white, text_size=tSize)
    table.cell(botT, 0, 10, "R:R check", text_color=color.white, text_size=tSize)
    table.cell(botT, 1, 10, rrWarn ? "SL>"+str.tostring(tgt1Pts)+" ⚠" : "ok", text_color=rrWarn?color.orange:color.green, text_size=tSize)

// =====================================================================
// ALERTS
// =====================================================================
alertcondition(ceSignal, "Buy CE", "BUY CE {{ticker}} @ {{close}} | SL & targets on chart")
alertcondition(peSignal, "Buy PE", "BUY PE {{ticker}} @ {{close}} | SL & targets on chart")
alertcondition(exitLong, "Exit CE", "EXIT CE {{ticker}} @ {{close}}")
alertcondition(exitShort, "Exit PE", "EXIT PE {{ticker}} @ {{close}}")
alertcondition(earlyWarnAlert, "Early Exit Warning", "EARLY EXIT warning {{ticker}} @ {{close}}")
````
