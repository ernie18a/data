# GS Signal Indicator Final

- url: https://www.tradingview.com/script/yucfCR47-GS-Signal-Indicator-Final/
- type: indicator
- pine_id: PUB;97c261e36cc84b728e4c301c0668a42e
- version: 1.0

## Description

## GS Signal Indicator — Beginner Description

* **GS Signal Indicator** helps you know when a stock is ready, still active, risky, or invalidated.

* It is best used on the **30-minute** and **1-hour** charts.

* The indicator combines trend, momentum, volume, candle strength, and risk into simple signals.

* The system now uses simple signal names:

```text
A = strongest setup
B = main buy setup
```

---

## Main Signals

* **A**
  Strongest signal. Best-quality setup.

* **B**
  Main buy signal. Structure and timing are both aligned.

* **A↑**
  The stock was already in a trade and later upgraded to **A**.
  This is usually a confirmation/hold signal, not automatically a new entry.

* **Warn**
  Risk is increasing. Be careful, tighten risk, or monitor the trade.

* **Exit**
  Exit or avoid. The setup is invalidated.

---

## Screener Status

* **Top A + 1H**
  Best condition. 30m has **A** and 1H supports it.

* **Top B + 1H**
  Strong condition. 30m has **B** and 1H supports it.

* **30m Only**
  30m has **A** or **B**, but 1H is not supporting yet.

* **1H Only**
  1H has **A** or **B**, but 30m is not ready yet.

* **Active**
  An old **A/B** signal is still valid because no **Warn** or **Exit** appeared after it.

* **Warn**
  A warning appeared after the last **A/B** signal. Do not chase.

* **Exit**
  An exit appeared after the last **A/B** signal. Ignore the old signal.

The screener version you uploaded is designed to detect actionable states, keep old A/B-type signals visible while no later risk or exit appears, and mark risk/exit status after the last signal. 

---

## How to Use It

* Use **30m** for entry timing.

* Use **1H** for confirmation.

* Focus mainly on:

```text
A = strongest setup
B = main buy setup
```

* Best alerts:

```text
Top A + 1H
Top B + 1H
```

* If status is **Active**, the old signal may still be valid, but do not chase if price is already far from the signal area.

* If status is **Warn**, avoid new buying unless a fresh **A** or **B** appears later.

* If status is **Exit**, the old setup is no longer valid.

---

## Simple Trading Rule

```text
Buy / Focus: A or B
Best Quality: Top A + 1H or Top B + 1H
Still Review: Active
Be Careful: Warn
Avoid / Exit: Exit
```

---

## Best Settings

* **Timeframe:** 30m or 1H
* **Display Mode:** Clean
* **Show Dashboard:** ON
* **Show Entry / Stop / Targets:** ON
* **Confirm Candle Close:** ON

Disclaimer

* This indicator is for education and analysis only.
* It does not guarantee profits.
* Always use proper risk management.

## Source Code

````pine
//====================================================================
// GS FINAL v3.0 PACK
//
// COPY/PASTE EACH SCRIPT SEPARATELY INTO TRADINGVIEW.
// Do not paste the whole file as one script.
//
// SCRIPT 1: GS Signal Indicator v3.0 Final
// SCRIPT 2: GS Screener Indicator v1.0 Final
//====================================================================


//====================================================================
// GS SIGNAL INDICATOR v3.1 SIMPLE — A + B
//====================================================================

//@version=6
indicator("GS Signal Indicator v3.1 Simple | A + B", overlay=true, max_labels_count=200, max_lines_count=200, max_boxes_count=50)

//====================================================================
// 1. INPUTS
//====================================================================

groupCore = "01. GS Core"
profile = input.string("Auto 30m/1H", "Mode", options=["Auto 30m/1H", "30m Entry", "1H Swing", "Manual"], group=groupCore)
benchmarkSymbol = input.symbol("EGX:EGX30", "Benchmark for RLT", group=groupCore)
htfTf = input.timeframe("D", "Support Timeframe", group=groupCore)
useConfirmedBars = input.bool(true, "Confirm Candle Close", group=groupCore)
useSessionFilter = input.bool(false, "Use Market Session", group=groupCore)
tradeSession = input.session("1000-1430", "EGX Session", group=groupCore)
useTradeState = input.bool(true, "Block Repeat Buy", group=groupCore)


groupTrend = "02. Structure"
emaFastLen = input.int(9, "Fast EMA", minval=1, group=groupTrend)
emaMidLen = input.int(21, "Main EMA", minval=1, group=groupTrend)
emaBaseLen = input.int(50, "Base EMA", minval=1, group=groupTrend)
emaMacroLen = input.int(200, "Long EMA", minval=1, group=groupTrend)
donLen = input.int(20, "Range Structure", minval=5, group=groupTrend)
swingLen = input.int(10, "Swing Lookback", minval=3, group=groupTrend)


groupMom = "03. Momentum"
rsiLen = input.int(14, "RSI", minval=2, group=groupMom)
rsiBullFloor = input.float(40.0, "RSI Bull Zone", step=0.5, group=groupMom)
rsiPower = input.float(53.0, "RSI Strength", step=0.5, group=groupMom)
rsiExhaust = input.float(72.0, "RSI Overheat", step=0.5, group=groupMom)
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMom)
macdSlow = input.int(26, "MACD Slow", minval=1, group=groupMom)
macdSig = input.int(9, "MACD Signal", minval=1, group=groupMom)
stochLen = input.int(14, "Timing Oscillator", minval=2, group=groupMom)


groupVol = "04. Volume / Flow"
volLen = input.int(20, "Average Volume", minval=2, group=groupVol)
cmfLen = input.int(20, "CMF", minval=2, group=groupVol)
mfiLen = input.int(14, "MFI", minval=2, group=groupVol)
rvolManual = input.float(140.0, "Needed Volume %", step=5, group=groupVol)
highRvol = input.float(180.0, "Risk Volume %", step=5, group=groupVol)


groupVRM = "05. Volatility / VRM"
atrLen = input.int(14, "ATR", minval=2, group=groupVRM)
bbLen = input.int(20, "BB Length", minval=5, group=groupVRM)
bbMult = input.float(2.0, "BB Mult", step=0.1, group=groupVRM)
bbwSmoothLen = input.int(50, "Volatility Average", minval=10, group=groupVRM)
squeezeFactor = input.float(0.75, "Compression Factor", step=0.05, group=groupVRM)
maxAtrStretch = input.float(2.8, "Max Price Stretch", step=0.1, group=groupVRM)


groupDTS = "06. DTS Execution"
useVWAP = input.bool(true, "Use VWAP Recovery", group=groupDTS)
wickNeed = input.float(35.0, "Wick Minimum %", step=1, group=groupDTS)
bodyNeed = input.float(45.0, "Strong Candle Body %", step=1, group=groupDTS)
closePosNeed = input.float(0.62, "Strong Close Position", step=0.01, group=groupDTS)


groupScore = "07. Scoring"
xgsBuyThreshold = input.float(75.0, "Score Buy Level", step=1, group=groupScore)
dtsBuyThreshold = input.float(70.0, "Timing Buy Level", step=1, group=groupScore)
apexStrictLayers = input.int(12, "A Required Layers", minval=10, maxval=12, group=groupScore)
pre1Layers = input.int(7, "Early Layers", minval=1, maxval=12, group=groupScore)
pre2Layers = input.int(9, "Close Layers", minval=1, maxval=12, group=groupScore)
cooldownBars = input.int(8, "Buy Cooldown", minval=0, group=groupScore)
warnCooldownBars = input.int(10, "Warn Cooldown", minval=1, group=groupScore)


groupRisk = "08. Risk"
atrSLMult = input.float(1.5, "Stop ATR Mult", step=0.1, group=groupRisk)
swingSLBuffer = input.float(0.20, "Swing Stop Buffer", step=0.05, group=groupRisk)
rr1 = input.float(1.5, "T1 Risk Multiple", step=0.1, group=groupRisk)
rr2 = input.float(3.0, "T2 Risk Multiple", step=0.1, group=groupRisk)


groupDisplay = "09. Display"
visualMode = input.string("Clean", "Display Mode", options=["Clean", "A Only", "Full"], group=groupDisplay)
showEMAs = input.bool(true, "Show EMAs", group=groupDisplay)
showVWAPLine = input.bool(false, "Show VWAP", group=groupDisplay)
showDonchian = input.bool(false, "Show Donchian", group=groupDisplay)
showPivots = input.bool(false, "Show Pivots", group=groupDisplay)
showRiskMap = input.bool(true, "Show Entry / Stop / Targets", group=groupDisplay)
showBuyLabels = input.bool(true, "Show Buy Label", group=groupDisplay)
showExitLabels = input.bool(true, "Show Exit Label", group=groupDisplay)
showWarnMarker = input.bool(true, "Show Warn Marker", group=groupDisplay)
showApexUpgrade = input.bool(true, "Show A Upgrade Marker", group=groupDisplay)
showWarnLabels = input.bool(false, "Show Warn Label", group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)


groupAlert = "10. Alerts"
enableDynamicAlerts = input.bool(true, "Enable Bot Alerts", group=groupAlert)

isApexOnly = visualMode == "A Only"
isFull = visualMode == "Full"
showPrep = isFull
showDiag = isFull

is30m = timeframe.isminutes and timeframe.multiplier == 30
is1h = timeframe.isminutes and timeframe.multiplier == 60
isPreferredTf = is30m or is1h
rvolNeed = profile == "Manual" ? rvolManual : profile == "30m Entry" ? 145.0 : profile == "1H Swing" ? 125.0 : is1h ? 125.0 : 140.0
confirmedOk = not useConfirmedBars or barstate.isconfirmed
inSession = not useSessionFilter or not na(time(timeframe.period, tradeSession))

//====================================================================
// 2. BASE ENGINE
//====================================================================

emaFast = ta.ema(close, emaFastLen)
emaMid = ta.ema(close, emaMidLen)
emaBase = ta.ema(close, emaBaseLen)
emaMacro = ta.ema(close, emaMacroLen)

rsi = ta.rsi(close, rsiLen)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
stochK = ta.stoch(high, low, close, stochLen)
stochD = ta.sma(stochK, 3)

atr = ta.atr(atrLen)
atrPct = atr / math.max(close, syminfo.mintick) * 100.0
atrPctAvg = ta.sma(atrPct, bbwSmoothLen)
volAvg = ta.sma(volume, volLen)
rvolPct = volume / math.max(volAvg, 1.0) * 100.0

obv = ta.cum(math.sign(ta.change(close)) * volume)
obvAvg = ta.sma(obv, volLen)
obvRise = obv > obvAvg

mfMult = ((close - low) - (high - close)) / math.max(high - low, syminfo.mintick)
mfVol = mfMult * volume
cmf = math.sum(mfVol, cmfLen) / math.max(math.sum(volume, cmfLen), 1.0)

typ = hlc3
posFlow = typ > typ[1] ? typ * volume : 0.0
negFlow = typ < typ[1] ? typ * volume : 0.0
mfr = math.sum(posFlow, mfiLen) / math.max(math.sum(negFlow, mfiLen), 1.0)
mfi = 100.0 - 100.0 / (1.0 + mfr)

vwapVal = ta.vwap(hlc3)

bbBasis = ta.sma(close, bbLen)
bbDev = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbw = (bbUpper - bbLower) / math.max(bbBasis, syminfo.mintick) * 100.0
bbwAvg = ta.sma(bbw, bbwSmoothLen)
vrmCompression = bbw < bbwAvg * squeezeFactor and atrPct < atrPctAvg
vrmExpansion = bbw > bbw[1] and close > bbBasis and rvolPct >= rvolNeed

donUpper = ta.highest(high, donLen)
donLower = ta.lowest(low, donLen)
donMid = (donUpper + donLower) / 2.0
donUpperPrev = donUpper[1]
structBreak = close > donUpperPrev
structSupport = close > donMid and donMid >= donMid[1]

swingLow = ta.lowest(low, swingLen)
swingHigh = ta.highest(high, swingLen)
swingLowPrev = swingLow[1]
swingHighPrev = swingHigh[1]

[prevDHigh, prevDLow, prevDClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], barmerge.gaps_off, barmerge.lookahead_off)
pivotP = (prevDHigh + prevDLow + prevDClose) / 3.0
pivotR1 = 2.0 * pivotP - prevDLow
pivotS1 = 2.0 * pivotP - prevDHigh

[htfClose, htfEmaMid, htfEmaBase] = request.security(syminfo.tickerid, htfTf, [close, ta.ema(close, emaMidLen), ta.ema(close, emaBaseLen)], barmerge.gaps_off, barmerge.lookahead_off)
htfBull = htfClose > htfEmaMid and htfEmaMid >= htfEmaBase

benchClose = request.security(benchmarkSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
rsLine = close / math.max(benchClose, syminfo.mintick)
rsEma = ta.ema(rsLine, emaMidLen)
rsSlopeUp = rsEma > rsEma[1]
rsHigh = ta.highest(rsLine, donLen)
rsBreak = rsLine > rsHigh[1]
rltBull = rsLine > rsEma and rsSlopeUp and rsi > rsiBullFloor
rltWeak = rsLine < rsEma or rsi < rsiBullFloor

rng = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyPct = body / rng * 100.0
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperWickPct = upperWick / rng * 100.0
lowerWickPct = lowerWick / rng * 100.0
closePos = (close - low) / rng
bullCandle = close > open
candleAuthority = bullCandle and bodyPct >= bodyNeed and closePos >= closePosNeed
machiA = candleAuthority and rvolPct >= rvolNeed and close > emaMid
machiB = bullCandle and closePos >= 0.55 and bodyPct >= 35 and close >= emaMid
machiGrade = machiA ? "A" : machiB ? "B" : bullCandle ? "C" : "D"

sweepLow = low < swingLowPrev and close > swingLowPrev
sweepHigh = high > swingHighPrev and close < swingHighPrev
reclaimVWAP = useVWAP ? close > vwapVal and close[1] <= vwapVal[1] : close > emaMid and close[1] <= emaMid[1]
reclaimEMA = close > emaMid and close[1] <= emaMid[1]
liquidityReclaim = (sweepLow and lowerWickPct >= wickNeed) or reclaimVWAP or reclaimEMA

fakeBreakout = high > donUpperPrev and close < open and upperWickPct >= 35 and rvolPct < rvolNeed
distHidden = rvolPct >= highRvol and mfi < 50 and cmf < 0 and close < open
operatorTrap = fakeBreakout or distHidden or (sweepHigh and upperWickPct >= 40)
overextended = close > emaMid + atr * maxAtrStretch or rsi >= rsiExhaust
noTrap = not operatorTrap
noDistribution = not distHidden and cmf > -0.05
safetyOk = not overextended and close > emaMid

trendHealthy = close > emaMid and emaMid > emaBase and emaMid >= emaMid[1]
participation = rvolPct >= rvolNeed and (obvRise or cmf > 0)
phaseAccum = vrmCompression and close >= donMid and cmf >= -0.05
phaseExpand = vrmExpansion and structBreak and participation
phaseContinue = trendHealthy and close >= emaFast and macdHist >= 0 and rsi > rsiBullFloor
phaseExhaust = overextended or (rsi > 68 and macdHist < macdHist[1]) or operatorTrap
phaseName = phaseExpand ? "EXPAND" : phaseContinue ? "CONT" : phaseAccum ? "ACCUM" : phaseExhaust ? "EXHAUST" : "BUILD"
phaseBull = phaseExpand or phaseContinue or phaseAccum

//====================================================================
// 3. XGS / DTS / APEX
//====================================================================

xgsTrend = 0.0
xgsTrend += close > emaMid ? 10 : 0
xgsTrend += emaFast > emaMid ? 8 : 0
xgsTrend += emaMid > emaBase ? 12 : 0
xgsTrend += emaBase > emaMacro ? 10 : 0
xgsTrend += trendHealthy ? 10 : 0

xgsStructure = 0.0
xgsStructure += structSupport ? 8 : 0
xgsStructure += structBreak ? 10 : 0
xgsStructure += close > donMid ? 5 : 0
xgsStructure += htfBull ? 10 : 0

xgsMomentum = 0.0
xgsMomentum += rsi > rsiBullFloor ? 6 : 0
xgsMomentum += rsi >= rsiPower ? 6 : 0
xgsMomentum += macdHist > 0 ? 6 : 0
xgsMomentum += macdHist >= macdHist[1] ? 5 : 0

xgsLeadership = 0.0
xgsLeadership += rltBull ? 10 : 0
xgsLeadership += rsBreak ? 5 : 0

xgsRisk = 0.0
xgsRisk += noTrap ? 5 : 0
xgsRisk += safetyOk ? 5 : 0

xgsScore = math.min(math.max(xgsTrend + xgsStructure + xgsMomentum + xgsLeadership + xgsRisk, 0.0), 100.0)
xgsBuy = xgsScore >= xgsBuyThreshold and trendHealthy and htfBull and noTrap

dtsLocation = 0.0
dtsLocation += close > emaMid ? 8 : 0
dtsLocation += useVWAP ? close > vwapVal ? 8 : 0 : close > emaMid ? 8 : 0
dtsLocation += liquidityReclaim ? 12 : 0
dtsLocation += close > pivotP ? 5 : 0

dtsTrigger = 0.0
dtsTrigger += candleAuthority ? 18 : 0
dtsTrigger += machiA ? 8 : machiB ? 4 : 0
dtsTrigger += ta.crossover(stochK, stochD) or stochK > stochD ? 5 : 0
dtsTrigger += bullCandle and closePos >= 0.60 ? 5 : 0

dtsParticipation = 0.0
dtsParticipation += rvolPct >= rvolNeed ? 12 : 0
dtsParticipation += obvRise ? 5 : 0
dtsParticipation += cmf > 0 ? 5 : 0

dtsContext = 0.0
dtsContext += inSession ? 6 : 0
dtsContext += phaseBull ? 6 : 0
dtsContext += noTrap ? 6 : 0

dtsScore = math.min(math.max(dtsLocation + dtsTrigger + dtsParticipation + dtsContext, 0.0), 100.0)
dtsBuy = dtsScore >= dtsBuyThreshold and inSession and candleAuthority and noTrap and confirmedOk

layer01 = xgsScore >= xgsBuyThreshold
layer02 = dtsScore >= dtsBuyThreshold
layer03 = trendHealthy and emaMid > emaBase
layer04 = rsi >= rsiPower and rsi < 68 and macdHist > 0
layer05 = macdHist >= macdHist[1] and macdLine >= macdSignal
layer06 = rvolPct >= rvolNeed and participation
layer07 = cmf > 0 or mfi >= 55
layer08 = rltBull
layer09 = htfBull
layer10 = candleAuthority and machiA
layer11 = noTrap and noDistribution
layer12 = phaseBull and safetyOk and not overextended

apexLayers = 0
apexLayers += layer01 ? 1 : 0
apexLayers += layer02 ? 1 : 0
apexLayers += layer03 ? 1 : 0
apexLayers += layer04 ? 1 : 0
apexLayers += layer05 ? 1 : 0
apexLayers += layer06 ? 1 : 0
apexLayers += layer07 ? 1 : 0
apexLayers += layer08 ? 1 : 0
apexLayers += layer09 ? 1 : 0
apexLayers += layer10 ? 1 : 0
apexLayers += layer11 ? 1 : 0
apexLayers += layer12 ? 1 : 0

apexReady = apexLayers >= apexStrictLayers and confirmedOk
apexImminent = apexLayers == 11 and confirmedOk
pre1 = apexLayers >= pre1Layers and apexLayers < pre2Layers and confirmedOk
pre2 = apexLayers >= pre2Layers and apexLayers < 11 and confirmedOk
bdSignal = dtsBuy and not xgsBuy and apexLayers >= pre2Layers
bxSignal = xgsBuy and not dtsBuy and apexLayers >= pre2Layers
bxdSignal = xgsBuy and dtsBuy and apexLayers >= 10 and confirmedOk

//====================================================================
// 4. TRADE STATE / EVENTS
//====================================================================

var bool inTrade = false
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var int lastMajorSignalBar = na
var int lastWarnBar = na

slAtr = close - atr * atrSLMult
slSwing = swingLow - atr * swingSLBuffer
candidateSL = math.min(slAtr, slSwing)
candidateRisk = close - candidateSL
candidateTP1 = close + candidateRisk * rr1
candidateTP2 = close + candidateRisk * rr2

majorBuyRaw = apexReady or (bxdSignal and not isApexOnly)
majorCooldownOk = cooldownBars == 0 or na(lastMajorSignalBar) or bar_index - lastMajorSignalBar > cooldownBars
masterBuy = majorBuyRaw and majorCooldownOk and (not useTradeState or not inTrade) and confirmedOk

rawWarn = inTrade and confirmedOk and (operatorTrap or distHidden or overextended or (rsi > 68 and macdHist < macdHist[1]) or close < emaMid)
warnEvent = rawWarn and (na(lastWarnBar) or bar_index - lastWarnBar > warnCooldownBars)

slHit = inTrade and not na(activeSL) and close < activeSL
rawExit = inTrade and confirmedOk and (slHit or (close < emaBase and macdHist < 0) or (rsi < rsiBullFloor and close < emaMid))
exitEvent = rawExit and not rawExit[1]

if masterBuy
    inTrade := true
    activeEntry := close
    activeSL := candidateSL
    activeTP1 := candidateTP1
    activeTP2 := candidateTP2
    lastMajorSignalBar := bar_index

if warnEvent
    lastWarnBar := bar_index

if exitEvent
    inTrade := false
    activeEntry := na
    activeSL := na
    activeTP1 := na
    activeTP2 := na
    lastMajorSignalBar := bar_index

pre1Event = showPrep and pre1 and not pre1[1]
pre2Event = showPrep and pre2 and not pre2[1]
bdEvent = showDiag and bdSignal and not bdSignal[1]
bxEvent = showDiag and bxSignal and not bxSignal[1]
bxdEvent = masterBuy and not apexReady and not isApexOnly
apexEvent = masterBuy and apexReady
// A Upgrade: the stock reaches A after an earlier B entry.
// This solves the visual mismatch where the screener says A,
// but the chart does not print a new A label because trade state is already active.
apexUpgradeEvent = showApexUpgrade and apexReady and not apexReady[1] and inTrade and not apexEvent

//====================================================================
// 5. VISUALS
//====================================================================

plot(showEMAs ? emaFast : na, "EMA 9", color=color.new(color.teal, 0), linewidth=1)
plot(showEMAs ? emaMid : na, "EMA 21", color=color.new(color.orange, 0), linewidth=2)
plot(showEMAs ? emaBase : na, "EMA 50", color=color.new(color.blue, 0), linewidth=1)
plot(showEMAs ? emaMacro : na, "EMA 200", color=color.new(color.gray, 15), linewidth=2)
plot(showVWAPLine and useVWAP ? vwapVal : na, "VWAP", color=color.new(color.purple, 0), linewidth=1)
plot(showDonchian ? donUpper : na, "Donchian Upper", color=color.new(color.green, 70), linewidth=1)
plot(showDonchian ? donMid : na, "Donchian Mid", color=color.new(color.gray, 75), linewidth=1)
plot(showDonchian ? donLower : na, "Donchian Lower", color=color.new(color.red, 70), linewidth=1)
plot(showPivots ? pivotP : na, "Pivot P", color=color.new(color.yellow, 25), linewidth=1, style=plot.style_linebr)
plot(showPivots ? pivotR1 : na, "Pivot R1", color=color.new(color.green, 75), linewidth=1, style=plot.style_linebr)
plot(showPivots ? pivotS1 : na, "Pivot S1", color=color.new(color.red, 75), linewidth=1, style=plot.style_linebr)

plot(showRiskMap and inTrade ? activeEntry : na, "GS Entry", color=color.new(color.white, 0), linewidth=1, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeSL : na, "GS SL", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeTP1 : na, "GS TP1", color=color.new(color.green, 35), linewidth=1, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeTP2 : na, "GS TP2", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)

plotshape(pre1Event, title="Early", text="Early", style=shape.circle, location=location.belowbar, color=color.new(color.gray, 0), textcolor=color.white, size=size.tiny)
plotshape(pre2Event, title="Close", text="Close", style=shape.circle, location=location.belowbar, color=color.new(color.yellow, 0), textcolor=color.black, size=size.tiny)
plotshape(bdEvent, title="Timing", text="Timing", style=shape.triangleup, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.tiny)
plotshape(bxEvent, title="Setup", text="Setup", style=shape.triangleup, location=location.belowbar, color=color.new(color.blue, 0), textcolor=color.white, size=size.tiny)
plotshape(bxdEvent, title="B", text="B", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.normal)
plotshape(apexEvent, title="A", text="A", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.normal)
plotshape(apexUpgradeEvent, title="A Upgrade", text="A↑", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
plotshape(showWarnMarker and warnEvent, title="Warn", text="!", style=shape.triangledown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)
plotshape(exitEvent, title="Exit", text="Exit", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

if showBuyLabels and masterBuy
    label.new(bar_index, low - atr * 0.45, "GS BUY | " + (apexReady ? "A 12/12" : "B") + "\nScore " + str.tostring(xgsScore, "#.0") + " | Timing " + str.tostring(dtsScore, "#.0") + " | L " + str.tostring(apexLayers) + "/12" + "\nEntry " + str.tostring(activeEntry, format.mintick) + " | Stop " + str.tostring(activeSL, format.mintick) + "\nT1 " + str.tostring(activeTP1, format.mintick) + " | T2 " + str.tostring(activeTP2, format.mintick), style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.black)

if showWarnLabels and warnEvent
    label.new(bar_index, high + atr * 0.40, "GS Warn\n" + (operatorTrap ? "Trap" : overextended ? "Stretch" : distHidden ? "Distribution" : close < emaMid ? "EMA loss" : "Momentum fade"), style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.black)

if showExitLabels and exitEvent
    label.new(bar_index, high + atr * 0.50, "GS Exit\nInvalidated", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white)

//====================================================================
// 6. DASHBOARD / ALERTS
//====================================================================

f_scoreColor(float v) => v >= 80 ? color.new(color.green, 0) : v >= 70 ? color.new(color.lime, 15) : v >= 55 ? color.new(color.yellow, 10) : v >= 40 ? color.new(color.orange, 10) : color.new(color.red, 5)
f_boolColor(bool b) => b ? color.new(color.green, 5) : color.new(color.red, 5)

var table dash = table.new(position.top_right, 3, 7, border_width=1)
if showDashboard and barstate.islast
    gsState = apexReady ? "A" : apexImminent ? "11/12" : bxdSignal ? "B" : bxSignal ? "Setup" : bdSignal ? "Timing" : pre2 ? "Close" : pre1 ? "Early" : warnEvent ? "Warn" : "Wait"
    gsBg = apexReady ? color.new(color.green, 0) : apexImminent ? color.new(color.orange, 0) : bxdSignal ? color.new(color.lime, 0) : pre2 ? color.new(color.yellow, 0) : color.new(color.gray, 30)
    riskTxt = operatorTrap ? "Trap" : overextended ? "Stretch" : distHidden ? "Risk Vol" : close < emaMid ? "Watch" : "OK"
    riskBg = riskTxt == "OK" ? color.new(color.green, 10) : riskTxt == "WATCH" ? color.new(color.orange, 20) : color.new(color.red, 0)
    rltTxt = rltBull ? "Leader" : rltWeak ? "Weak" : "Neutral"
    modeTxt = isApexOnly ? "A Only" : isFull ? "Full" : "Clean"
    table.cell(dash, 0, 0, "GS v3.1", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, gsState, text_color=color.black, bgcolor=gsBg)
    table.cell(dash, 2, 0, isPreferredTf ? modeTxt : "USE 30m/1h", text_color=color.white, bgcolor=isPreferredTf ? color.new(color.black, 0) : color.new(color.orange, 0))
    table.cell(dash, 0, 1, "A", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 1, str.tostring(apexLayers) + "/12", text_color=color.white, bgcolor=f_scoreColor(apexLayers / 12.0 * 100.0))
    table.cell(dash, 2, 1, apexLayers >= 12 ? "Buy" : apexLayers == 11 ? "Watch" : "Wait", text_color=color.white, bgcolor=apexLayers >= 12 ? color.new(color.green, 0) : apexLayers == 11 ? color.new(color.orange, 0) : color.new(color.gray, 30))
    table.cell(dash, 0, 2, "Score", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 2, str.tostring(xgsScore, "#.0"), text_color=color.white, bgcolor=f_scoreColor(xgsScore))
    table.cell(dash, 2, 2, htfBull ? "Support Yes" : "Support No", text_color=color.white, bgcolor=f_boolColor(htfBull))
    table.cell(dash, 0, 3, "Timing", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 3, str.tostring(dtsScore, "#.0"), text_color=color.white, bgcolor=f_scoreColor(dtsScore))
    table.cell(dash, 2, 3, machiGrade + " Candle", text_color=color.white, bgcolor=machiGrade == "A" ? color.new(color.green, 0) : machiGrade == "B" ? color.new(color.lime, 25) : color.new(color.orange, 20))
    table.cell(dash, 0, 4, "Leader", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 4, rltTxt, text_color=color.white, bgcolor=rltBull ? color.new(color.green, 0) : rltWeak ? color.new(color.red, 15) : color.new(color.gray, 25))
    table.cell(dash, 2, 4, phaseName, text_color=color.white, bgcolor=phaseBull ? color.new(color.green, 15) : phaseExhaust ? color.new(color.red, 10) : color.new(color.gray, 30))
    table.cell(dash, 0, 5, "Risk", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, riskTxt, text_color=color.white, bgcolor=riskBg)
    table.cell(dash, 2, 5, inTrade ? "In Trade" : "No Trade", text_color=color.white, bgcolor=inTrade ? color.new(color.green, 0) : color.new(color.gray, 30))
    table.cell(dash, 0, 6, "Plan", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 6, inTrade ? "Stop " + str.tostring(activeSL, format.mintick) : "Stop " + str.tostring(candidateSL, format.mintick), text_color=color.white, bgcolor=color.new(color.red, 20))
    table.cell(dash, 2, 6, inTrade ? "T2 " + str.tostring(activeTP2, format.mintick) : "T2 " + str.tostring(candidateTP2, format.mintick), text_color=color.white, bgcolor=color.new(color.green, 20))

f_json(string sig) =>
    '{"system":"GS","script":"signal","version":"3.0","signal":"' + sig + '","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"layers":"' + str.tostring(apexLayers) + '/12","xgs":' + str.tostring(xgsScore, "#.0") + ',"dts":' + str.tostring(dtsScore, "#.0") + ',"rlt":"' + (rltBull ? "LEADER" : "NOT_LEADER") + '","htf":"' + (htfBull ? "YES" : "NO") + '","phase":"' + phaseName + '","sl":' + str.tostring(candidateSL) + ',"tp1":' + str.tostring(candidateTP1) + ',"tp2":' + str.tostring(candidateTP2) + '}'

if enableDynamicAlerts and bxdEvent
    alert(f_json("B"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and apexEvent
    alert(f_json("A"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and apexUpgradeEvent
    alert(f_json("A UPGRADE"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and warnEvent
    alert(f_json("Warn"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and exitEvent
    alert(f_json("Exit"), alert.freq_once_per_bar_close)

alertcondition(bxdEvent, "GS B", "GS B on {{ticker}} @ {{close}}")
alertcondition(apexEvent, "GS A", "GS A on {{ticker}} @ {{close}}")
alertcondition(apexUpgradeEvent, "GS A Upgrade", "GS A upgrade on {{ticker}} @ {{close}}")
alertcondition(warnEvent, "GS Warn", "GS warning on {{ticker}} @ {{close}}")
alertcondition(exitEvent, "GS Exit", "GS exit on {{ticker}} @ {{close}}")
````
