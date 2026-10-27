# GS Univsersal

- url: https://www.tradingview.com/script/zJZyq8Ru-GS-Univsersal/
- type: indicator
- pine_id: PUB;18a4c8b671f84e678ea81c066d84184d
- version: 1.0

## Description

## GS Universal — Trading System Indicator

**GS Universal** is a clean, multi-layer TradingView indicator designed to help traders read market structure, trend quality, momentum, volatility, and signal strength in one organized chart system.

The goal of GS Universal is not to overload the chart with too many indicators, but to combine the most important trading conditions into a clear visual decision framework. It is built for traders who want a structured way to identify possible buy zones, warning areas, exit signals, and trend continuation setups.

---

## Core Purpose

GS Universal helps traders answer five key questions:

1. **Is the stock trending or ranging?**
2. **Is momentum improving or weakening?**
3. **Is volume supporting the move?**
4. **Is price extended or still healthy?**
5. **Is the signal strong enough to act on, wait, or avoid?**

---

## Main Features

* **Buy / Warning / Exit signal system**
* **A/B/C signal grading for easier decision-making**
* **EMA trend structure and EMA crossover logic**
* **Bollinger Bands for volatility and extension reading**
* **RSI momentum and overextension filter**
* **MACD momentum confirmation**
* **Volume and relative volume participation filter**
* **ATR-based risk and volatility awareness**
* **Dynamic trailing stop guidance**
* **Dashboard summary for quick interpretation**
* **Beginner / Professional terminology switch**
* **Clean chart layout with controlled labels**

---

## Signal Logic

GS Universal evaluates price using multiple confirmation layers:

### Trend Structure

The indicator checks whether price is above or below key moving averages and whether the short-term trend is aligned with the broader structure.

### Momentum

RSI and MACD are used to measure whether the move has strength, acceleration, or early weakness.

### Volume Confirmation

Volume and relative volume help confirm whether buyers are truly participating in the move or whether the signal is weak.

### Volatility and Extension

Bollinger Bands and ATR help identify whether price is expanding from compression, becoming overextended, or entering a risky zone.

### Signal Quality

Signals are graded to make interpretation easier:

* **A Signal** = Stronger setup with better alignment
* **B Signal** = Acceptable setup but needs caution
* **C Signal** = Weak or early signal, usually requires confirmation

---

## How to Use

GS Universal is designed as a decision-support tool.

A trader can use it to:

* Identify potential entry zones
* Confirm whether a breakout has strength
* Monitor whether an existing trade is still healthy
* Spot warning signs before momentum fails
* Use trailing stop guidance for trade management
* Avoid chasing overextended moves

The indicator works best when combined with support and resistance, market context, risk management, and personal trading rules.

---

## Important Notes

GS Universal is not a guaranteed buy or sell system.
It is an analytical framework that organizes trend, momentum, volume, and volatility conditions into clearer visual signals.

All signals should be used with proper risk management. Traders should always define their entry, stop-loss, position size, and exit plan before taking any trade.

---

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not provide financial advice, investment recommendations, or guaranteed trading results. Trading involves risk, and users are responsible for their own trading decisions.

## Source Code

````pine
//====================================================================
// GS MASTER v1.0 — Unified Trading Indicator
// Core: GS + XGS + DTS + RLT + VRM
// Modules: SMC Lite + Order Blocks + Gann/Fib Geometry + Divergence
// Risk: Entry / Initial SL / TP1 / TP2 / Dynamic Trailing SL
//
// Built as an efficient integrated engine, not a visual collage.
// For personal/educational use. If distributed, preserve attribution
// and respect licenses of any third-party logic sources you adapt.
//====================================================================

//@version=6
indicator("GS Univsersal", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=250, max_bars_back=3000)

//====================================================================
// 1. MASTER CONTROLS
//====================================================================

groupMaster = "00. GS Master Controls"
terminologyMode = input.string("Professional", "Terminology Mode", options=["Simple", "Professional"], group=groupMaster)
profile = input.string("Auto 30m/1H", "Mode", options=["Auto 30m/1H", "30m Entry", "1H Swing", "Manual"], group=groupMaster)
filterLevel = input.string("Balanced", "Filter Level", options=["Loose", "Balanced", "Strict", "Institutional"], group=groupMaster)
visualMode = input.string("Clean", "Visual Mode", options=["Minimal", "Clean", "Trading", "Full Map"], group=groupMaster)
useConfirmedBars = input.bool(true, "Confirm Candle Close", group=groupMaster)
useSessionFilter = input.bool(false, "Use Market Session", group=groupMaster)
tradeSession = input.session("1000-1430", "Trading Session", group=groupMaster)
useTradeState = input.bool(true, "Block Repeat Buy While In Trade", group=groupMaster)
benchmarkSymbol = input.symbol("EGX:EGX30", "Benchmark for RLT", group=groupMaster)

isSimple = terminologyMode == "Simple"
confirmedOk = not useConfirmedBars or barstate.isconfirmed
inSession = not useSessionFilter or not na(time(timeframe.period, tradeSession))
is30m = timeframe.isminutes and timeframe.multiplier == 30
is1h = timeframe.isminutes and timeframe.multiplier == 60
isPreferredTf = is30m or is1h
isMinimal = visualMode == "Minimal"
isClean = visualMode == "Clean"
isTrading = visualMode == "Trading"
isFullMap = visualMode == "Full Map"
showMapObjects = isTrading or isFullMap
showFullObjects = isFullMap

//====================================================================
// 2. MODULE SWITCHES
//====================================================================

groupModules = "01. Module Switches"
useGSCore = input.bool(true, "Use GS Core", group=groupModules)
useXGS = input.bool(true, "Use XGS Structural Score", group=groupModules)
useDTS = input.bool(true, "Use DTS Execution Score", group=groupModules)
useRLT = input.bool(true, "Use RLT Relative Leadership", group=groupModules)
useHTF = input.bool(true, "Use HTF Support", group=groupModules)
useVRM = input.bool(true, "Use VRM Volatility Rhythm", group=groupModules)
useSMC = input.bool(true, "Use SMC Structure Module", group=groupModules)
useOB = input.bool(true, "Use Order Block Module", group=groupModules)
useFib = input.bool(true, "Use Gann/Fib Geometry Module", group=groupModules)
useDiv = input.bool(true, "Use Divergence Module", group=groupModules)
useReversal = input.bool(true, "Use Reversal Signal Module", group=groupModules)
useMEF = input.bool(true, "Use Micro EMA Flip Module", group=groupModules)
useBBAdvanced = input.bool(true, "Use BB/VRM Advanced Layer", group=groupModules)

//====================================================================
// 3. CORE INPUTS
//====================================================================

groupTrend = "02. Structure / Trend"
emaFastLen = input.int(9, "Fast EMA", minval=1, group=groupTrend)
emaMidLen = input.int(21, "Main EMA", minval=1, group=groupTrend)
emaBaseLen = input.int(50, "Base EMA", minval=1, group=groupTrend)
emaMacroLen = input.int(200, "Long EMA", minval=1, group=groupTrend)
donLen = input.int(20, "Range Structure / Donchian", minval=5, group=groupTrend)
swingLen = input.int(10, "Swing Lookback", minval=3, group=groupTrend)
htfTf = input.timeframe("D", "HTF Support Timeframe", group=groupTrend)

groupMom = "03. Momentum"
rsiLen = input.int(14, "RSI Length", minval=2, group=groupMom)
rsiBullFloor = input.float(40.0, "RSI Bull Zone", step=0.5, group=groupMom)
rsiPower = input.float(53.0, "RSI Strength", step=0.5, group=groupMom)
rsiExhaust = input.float(72.0, "RSI Overheat", step=0.5, group=groupMom)
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMom)
macdSlow = input.int(26, "MACD Slow", minval=1, group=groupMom)
macdSig = input.int(9, "MACD Signal", minval=1, group=groupMom)
stochLen = input.int(14, "Stochastic Length", minval=2, group=groupMom)
cciLen = input.int(10, "CCI Length", minval=2, group=groupMom)
momLen = input.int(10, "Momentum Length", minval=1, group=groupMom)

groupVol = "04. Volume / Flow"
volLen = input.int(20, "Average Volume Length", minval=2, group=groupVol)
cmfLen = input.int(20, "CMF Length", minval=2, group=groupVol)
mfiLen = input.int(14, "MFI Length", minval=2, group=groupVol)
rvolManual = input.float(140.0, "Manual Needed RVol %", step=5, group=groupVol)
highRvol = input.float(180.0, "Risk / Distribution RVol %", step=5, group=groupVol)

groupVRM = "05. VRM / Volatility"
atrLen = input.int(14, "ATR Length", minval=2, group=groupVRM)
bbLen = input.int(20, "BB Length", minval=5, group=groupVRM)
bbMult = input.float(2.0, "BB Multiplier", step=0.1, group=groupVRM)
bbMaType = input.string("SMA", "BB Basis Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=groupVRM)
showBB = input.bool(false, "Show Bollinger Bands", group=groupVRM)
showBBFill = input.bool(false, "Show BB Fill", group=groupVRM)
bbwSmoothLen = input.int(50, "Volatility Average Length", minval=10, group=groupVRM)
squeezeFactor = input.float(0.75, "Compression Factor", step=0.05, group=groupVRM)
maxAtrStretch = input.float(2.8, "Max Price Stretch ATR", step=0.1, group=groupVRM)

groupDTS = "06. DTS Execution"
useVWAP = input.bool(true, "Use VWAP Recovery", group=groupDTS)
wickNeed = input.float(35.0, "Liquidity Wick Minimum %", step=1, group=groupDTS)
bodyNeed = input.float(45.0, "Strong Candle Body %", step=1, group=groupDTS)
closePosNeed = input.float(0.62, "Strong Close Position", step=0.01, group=groupDTS)

groupMEF = "06B. MEF Micro EMA Flip"
microFastLen = input.int(5, "Micro Fast EMA", minval=1, group=groupMEF)
microSlowLen = input.int(13, "Micro Slow EMA", minval=1, group=groupMEF)
microRequireCandle = input.bool(true, "Require Candle Confirmation", group=groupMEF)
microUseDtsBoost = input.bool(true, "Use As DTS Timing Boost", group=groupMEF)
microWarnMode = input.bool(true, "Use Bearish Flip As Warn", group=groupMEF)
showMicroMarkers = input.bool(false, "Show Micro Flip Markers", group=groupMEF)
showMicroEMAs = input.bool(false, "Show Micro EMA Lines", group=groupMEF)

//====================================================================
// 4. SCORING AND FILTER FLEXIBILITY
//====================================================================

groupScore = "07. Scoring / Filter Flexibility"
xgsBuyThresholdManual = input.float(75.0, "Manual XGS Buy Level", step=1, group=groupScore)
dtsBuyThresholdManual = input.float(70.0, "Manual DTS Timing Level", step=1, group=groupScore)
aPlusPctManual = input.float(92.0, "Manual A+ Confluence %", step=1, group=groupScore)
aPctManual = input.float(82.0, "Manual A Confluence %", step=1, group=groupScore)
bPctManual = input.float(70.0, "Manual B Confluence %", step=1, group=groupScore)
watchPctManual = input.float(55.0, "Manual Watch Confluence %", step=1, group=groupScore)
cooldownBars = input.int(8, "Buy Cooldown Bars", minval=0, group=groupScore)
warnCooldownBars = input.int(10, "Warn Cooldown Bars", minval=1, group=groupScore)
requireXGSForBuy = input.bool(true, "Require XGS For Buy", group=groupScore)
requireDTSForBuy = input.bool(true, "Require DTS For Buy", group=groupScore)
requireNoTrapForBuy = input.bool(true, "Require No Trap For Buy", group=groupScore)
requireHTFForBuy = input.bool(false, "Require HTF Support For Buy", group=groupScore)
requireSMCForA = input.bool(false, "Require SMC Confirmation For A/A+", group=groupScore)
requireOBorFibForA = input.bool(false, "Require OB or Fib Location For A/A+", group=groupScore)
signalAuthorityMode = input.string("GS Master Filtered", "Signal Authority Mode", options=["GS Legacy", "GS Master Filtered", "Master Independent"], group=groupScore)
masterConfirmMode = input.string("Balanced Master", "Master Confirmation Mode", options=["GS Classic", "Balanced Master", "Strict Master", "Institutional Master"], group=groupScore)
minModuleConfirmManual = input.int(1, "Manual Min Module Confirms For Buy", minval=0, maxval=6, group=groupScore)
minModuleConfirmAManual = input.int(2, "Manual Min Module Confirms For A/A+", minval=0, maxval=6, group=groupScore)

// Layer switches — all can be checked/unchecked.
groupLayers = "08. Layer Switches"
L01_on = input.bool(true, "01 XGS Score", group=groupLayers)
L02_on = input.bool(true, "02 DTS Score", group=groupLayers)
L03_on = input.bool(true, "03 EMA Structure", group=groupLayers)
L04_on = input.bool(true, "04 RSI + MACD Momentum", group=groupLayers)
L05_on = input.bool(true, "05 MACD Acceleration", group=groupLayers)
L06_on = input.bool(true, "06 RVol Participation", group=groupLayers)
L07_on = input.bool(true, "07 CMF / MFI Flow", group=groupLayers)
L08_on = input.bool(true, "08 RLT Leadership", group=groupLayers)
L09_on = input.bool(true, "09 HTF Support", group=groupLayers)
L10_on = input.bool(true, "10 Candle Authority", group=groupLayers)
L11_on = input.bool(true, "11 No Trap / No Distribution", group=groupLayers)
L12_on = input.bool(true, "12 Phase / Safety", group=groupLayers)
L13_on = input.bool(true, "13 SMC Structure", group=groupLayers)
L14_on = input.bool(true, "14 Order Block Location", group=groupLayers)
L15_on = input.bool(true, "15 Fib / OTE Geometry", group=groupLayers)
L16_on = input.bool(true, "16 Divergence Confirmation", group=groupLayers)

// Filter presets.
xgsBuyThreshold = filterLevel == "Loose" ? math.max(60.0, xgsBuyThresholdManual - 10.0) : filterLevel == "Balanced" ? xgsBuyThresholdManual : filterLevel == "Strict" ? xgsBuyThresholdManual + 5.0 : xgsBuyThresholdManual + 10.0
dtsBuyThreshold = filterLevel == "Loose" ? math.max(55.0, dtsBuyThresholdManual - 10.0) : filterLevel == "Balanced" ? dtsBuyThresholdManual : filterLevel == "Strict" ? dtsBuyThresholdManual + 5.0 : dtsBuyThresholdManual + 10.0
aPlusPct = filterLevel == "Loose" ? math.max(85.0, aPlusPctManual - 4.0) : filterLevel == "Balanced" ? aPlusPctManual : filterLevel == "Strict" ? aPlusPctManual + 3.0 : math.min(98.0, aPlusPctManual + 6.0)
aPct = filterLevel == "Loose" ? math.max(75.0, aPctManual - 5.0) : filterLevel == "Balanced" ? aPctManual : filterLevel == "Strict" ? aPctManual + 4.0 : aPctManual + 7.0
bPct = filterLevel == "Loose" ? math.max(62.0, bPctManual - 6.0) : filterLevel == "Balanced" ? bPctManual : filterLevel == "Strict" ? bPctManual + 4.0 : bPctManual + 8.0
watchPct = filterLevel == "Loose" ? math.max(45.0, watchPctManual - 5.0) : filterLevel == "Balanced" ? watchPctManual : filterLevel == "Strict" ? watchPctManual + 3.0 : watchPctManual + 6.0


// Flexible MA for Bollinger Bands.
f_ma(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

//====================================================================
// 5. BASE ENGINE
//====================================================================

emaFast = ta.ema(close, emaFastLen)
emaMid = ta.ema(close, emaMidLen)
emaBase = ta.ema(close, emaBaseLen)
emaMacro = ta.ema(close, emaMacroLen)
mefFast = ta.ema(close, microFastLen)
mefSlow = ta.ema(close, microSlowLen)
mefBullFlipRaw = ta.crossover(mefFast, mefSlow)
mefBearFlipRaw = ta.crossunder(mefFast, mefSlow)
mefBullTrend = useMEF and mefFast > mefSlow
mefBearTrend = useMEF and mefFast < mefSlow

rsi = ta.rsi(close, rsiLen)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
stochK = ta.stoch(close, high, low, stochLen)
stochD = ta.sma(stochK, 3)
// Pre-calculate stochastic crosses once so all modules can use them safely.
stochCrossUp = ta.crossover(stochK, stochD)
stochCrossDown = ta.crossunder(stochK, stochD)
cci = ta.cci(hlc3, cciLen)
momentum = ta.mom(close, momLen)

atr = ta.atr(atrLen)
atrPct = atr / math.max(close, syminfo.mintick) * 100.0
atrPctAvg = ta.sma(atrPct, bbwSmoothLen)
volAvg = ta.sma(volume, volLen)
rvolPct = volume / math.max(volAvg, 1.0) * 100.0
rvolNeed = profile == "Manual" ? rvolManual : profile == "30m Entry" ? 145.0 : profile == "1H Swing" ? 125.0 : is1h ? 125.0 : 140.0

obv = ta.cum(math.sign(ta.change(close)) * volume)
obvAvg = ta.sma(obv, volLen)
obvRise = obv > obvAvg

mfMult = ((close - low) - (high - close)) / math.max(high - low, syminfo.mintick)
mfVol = mfMult * volume
cmf = ta.sma(mfVol, cmfLen) / math.max(ta.sma(volume, cmfLen), 1.0)

typ = hlc3
posFlow = typ > typ[1] ? typ * volume : 0.0
negFlow = typ < typ[1] ? typ * volume : 0.0
mfr = ta.sma(posFlow, mfiLen) / math.max(ta.sma(negFlow, mfiLen), 1.0)
mfi = 100.0 - 100.0 / (1.0 + mfr)

vwapVal = ta.vwap(hlc3)

bbBasis = f_ma(close, bbLen, bbMaType)
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
bbBullControl = useBBAdvanced and close > bbBasis and bbBasis >= bbBasis[1]
bbUpperWalk = useBBAdvanced and close > bbUpper and close[1] > bbUpper[1]
bbTopReject = useBBAdvanced and high > bbUpper and close < bbUpper and upperWickPct >= 30
bbBottomReject = useBBAdvanced and low < bbLower and close > bbLower and lowerWickPct >= 30
closePos = (close - low) / rng
bullCandle = close > open
bearCandle = close < open
candleAuthority = bullCandle and bodyPct >= bodyNeed and closePos >= closePosNeed
machiA = candleAuthority and rvolPct >= rvolNeed and close > emaMid
machiB = bullCandle and closePos >= 0.55 and bodyPct >= 35 and close >= emaMid
machiGrade = machiA ? "A" : machiB ? "B" : bullCandle ? "C" : "D"
mefBullConfirm = useMEF and mefBullFlipRaw and (not microRequireCandle or bullCandle)
mefBearConfirm = useMEF and mefBearFlipRaw and (not microRequireCandle or bearCandle)

sweepLow = low < swingLowPrev and close > swingLowPrev
sweepHigh = high > swingHighPrev and close < swingHighPrev
reclaimVWAP = useVWAP ? close > vwapVal and close[1] <= vwapVal[1] : close > emaMid and close[1] <= emaMid[1]
reclaimEMA = close > emaMid and close[1] <= emaMid[1]
liquidityReclaim = (sweepLow and lowerWickPct >= wickNeed) or reclaimVWAP or reclaimEMA

fakeBreakout = high > donUpperPrev and close < open and upperWickPct >= 35 and rvolPct < rvolNeed
distHidden = rvolPct >= highRvol and mfi < 50 and cmf < 0 and close < open
operatorTrap = fakeBreakout or distHidden or (sweepHigh and upperWickPct >= 40)
overextended = close > emaMid + atr * maxAtrStretch or rsi >= rsiExhaust or bbTopReject
noTrap = not operatorTrap
noDistribution = not distHidden and cmf > -0.05
safetyOk = not overextended and close > emaMid

trendHealthy = close > emaMid and emaMid > emaBase and emaMid >= emaMid[1]
participation = rvolPct >= rvolNeed and (obvRise or cmf > 0)
phaseAccum = useVRM and vrmCompression and close >= donMid and cmf >= -0.05
phaseExpand = useVRM and vrmExpansion and structBreak and participation
phaseContinue = trendHealthy and close >= emaFast and macdHist >= 0 and rsi > rsiBullFloor
phaseExhaust = overextended or (rsi > 68 and macdHist < macdHist[1]) or operatorTrap or bbTopReject
phaseName = phaseExpand ? "EXPAND" : phaseContinue ? "CONT" : phaseAccum ? "ACCUM" : phaseExhaust ? "EXHAUST" : "BUILD"
phaseBull = phaseExpand or phaseContinue or phaseAccum or (not useVRM and phaseContinue)

//====================================================================
// 6. SMC LITE MODULE — BOS / CHOCH / EQH-EQL / FVG / PREMIUM-DISCOUNT
//====================================================================

groupSMC = "09. SMC Module"
smcInternalLen = input.int(5, "Internal Structure Length", minval=2, group=groupSMC)
smcSwingLen = input.int(20, "Swing Structure Length", minval=5, group=groupSMC)
smcRecentBars = input.int(20, "Recent BOS/CHOCH Valid Bars", minval=1, group=groupSMC)
showSMCLabels = input.bool(false, "Show BOS/CHOCH Labels", group=groupSMC)
showFVG = input.bool(false, "Show Latest FVG", group=groupSMC)
showPremiumDiscount = input.bool(false, "Show Premium / Discount", group=groupSMC)
eqlEqhThresholdAtr = input.float(0.10, "EQH/EQL Threshold x ATR", minval=0.01, step=0.01, group=groupSMC)

intPH = ta.pivothigh(high, smcInternalLen, smcInternalLen)
intPL = ta.pivotlow(low, smcInternalLen, smcInternalLen)
swPH = ta.pivothigh(high, smcSwingLen, smcSwingLen)
swPL = ta.pivotlow(low, smcSwingLen, smcSwingLen)

var float lastIntHigh = na
var float lastIntLow = na
var float prevIntHigh = na
var float prevIntLow = na
var int internalTrend = 0

var float lastSwHigh = na
var float lastSwLow = na
var float prevSwHigh = na
var float prevSwLow = na
var int swingTrendSMC = 0

if not na(intPH)
    prevIntHigh := lastIntHigh
    lastIntHigh := intPH
if not na(intPL)
    prevIntLow := lastIntLow
    lastIntLow := intPL
if not na(swPH)
    prevSwHigh := lastSwHigh
    lastSwHigh := swPH
if not na(swPL)
    prevSwLow := lastSwLow
    lastSwLow := swPL

// Pre-calculate crossover/crossunder calls every bar for Pine consistency.
intBullCrossRaw = ta.crossover(close, lastIntHigh)
intBearCrossRaw = ta.crossunder(close, lastIntLow)
swBullCrossRaw = ta.crossover(close, lastSwHigh)
swBearCrossRaw = ta.crossunder(close, lastSwLow)

intBullCross = useSMC and not na(lastIntHigh) and intBullCrossRaw
intBearCross = useSMC and not na(lastIntLow) and intBearCrossRaw
swBullCross = useSMC and not na(lastSwHigh) and swBullCrossRaw
swBearCross = useSMC and not na(lastSwLow) and swBearCrossRaw

intBullCHOCH = intBullCross and internalTrend == -1
intBullBOS = intBullCross and internalTrend != -1
intBearCHOCH = intBearCross and internalTrend == 1
intBearBOS = intBearCross and internalTrend != 1
swBullCHOCH = swBullCross and swingTrendSMC == -1
swBullBOS = swBullCross and swingTrendSMC != -1
swBearCHOCH = swBearCross and swingTrendSMC == 1
swBearBOS = swBearCross and swingTrendSMC != 1

if intBullCross
    internalTrend := 1
if intBearCross
    internalTrend := -1
if swBullCross
    swingTrendSMC := 1
if swBearCross
    swingTrendSMC := -1

smcBullEvent = intBullCHOCH or intBullBOS or swBullCHOCH or swBullBOS
smcBearEvent = intBearCHOCH or intBearBOS or swBearCHOCH or swBearBOS
smcBullBars = nz(ta.barssince(smcBullEvent), 100000)
smcBearBars = nz(ta.barssince(smcBearEvent), 100000)
recentSmcBull = useSMC and smcBullBars <= smcRecentBars
recentSmcBear = useSMC and smcBearBars <= smcRecentBars
smcBullBias = internalTrend == 1 or swingTrendSMC == 1
smcBearBias = internalTrend == -1 or swingTrendSMC == -1

// Equal highs/lows based on recent pivots.
eqh = useSMC and not na(lastIntHigh) and not na(prevIntHigh) and math.abs(lastIntHigh - prevIntHigh) <= atr * eqlEqhThresholdAtr
eql = useSMC and not na(lastIntLow) and not na(prevIntLow) and math.abs(lastIntLow - prevIntLow) <= atr * eqlEqhThresholdAtr

// FVG logic.
bullFVG = useSMC and low > high[2] and close[1] > high[2]
bearFVG = useSMC and high < low[2] and close[1] < low[2]
var float lastBullFvgTop = na
var float lastBullFvgBtm = na
var float lastBearFvgTop = na
var float lastBearFvgBtm = na
var int lastBullFvgBar = na
var int lastBearFvgBar = na
if bullFVG
    lastBullFvgTop := low
    lastBullFvgBtm := high[2]
    lastBullFvgBar := bar_index
if bearFVG
    lastBearFvgTop := low[2]
    lastBearFvgBtm := high
    lastBearFvgBar := bar_index
priceInBullFVG = useSMC and not na(lastBullFvgTop) and low <= lastBullFvgTop and close >= lastBullFvgBtm
priceInBearFVG = useSMC and not na(lastBearFvgTop) and high >= lastBearFvgBtm and close <= lastBearFvgTop

// Premium / discount range from swing structure.
// Pre-calculate highest/lowest every bar before ternary use.
smcFallbackHigh = ta.highest(high, smcSwingLen)
smcFallbackLow = ta.lowest(low, smcSwingLen)
smcRangeHigh = not na(lastSwHigh) ? lastSwHigh : smcFallbackHigh
smcRangeLow = not na(lastSwLow) ? lastSwLow : smcFallbackLow
smcRange = math.max(smcRangeHigh - smcRangeLow, syminfo.mintick)
smcEq = smcRangeLow + smcRange * 0.50
smcDiscount = close <= smcEq
smcPremium = close >= smcEq
smcLongOk = not useSMC or recentSmcBull or smcBullBias or priceInBullFVG or smcDiscount or liquidityReclaim
smcShortRisk = useSMC and (recentSmcBear or smcBearBias or priceInBearFVG or smcPremium)

//====================================================================
// 7. ORDER BLOCK LITE MODULE — VOLUME PIVOT OB
//====================================================================

groupOB = "10. Order Block Module"
obLen = input.int(5, "Volume Pivot Length", minval=1, group=groupOB)
obMitigation = input.string("Wick", "Mitigation", options=["Wick", "Close"], group=groupOB)
obShowCount = input.int(3, "OB Zones To Show", minval=1, maxval=10, group=groupOB)
obKeepMax = input.int(30, "Max Stored OB Zones", minval=5, maxval=100, group=groupOB)
showOBZones = input.bool(true, "Show OB Zones", group=groupOB)

obUpper = ta.highest(high, obLen)
obLower = ta.lowest(low, obLen)
var int obOS = 0
obOS := high[obLen] > obUpper ? 0 : low[obLen] < obLower ? 1 : nz(obOS[1], 0)
volPivot = ta.pivothigh(volume, obLen, obLen)

var array<float> bullObTop = array.new_float()
var array<float> bullObBtm = array.new_float()
var array<float> bullObAvg = array.new_float()
var array<int> bullObLeft = array.new_int()
var array<float> bearObTop = array.new_float()
var array<float> bearObBtm = array.new_float()
var array<float> bearObAvg = array.new_float()
var array<int> bearObLeft = array.new_int()

newBullOB = useOB and not na(volPivot) and obOS == 1
newBearOB = useOB and not na(volPivot) and obOS == 0

if newBullOB
    float t = hl2[obLen]
    float b = low[obLen]
    array.unshift(bullObTop, t)
    array.unshift(bullObBtm, b)
    array.unshift(bullObAvg, math.avg(t, b))
    array.unshift(bullObLeft, bar_index[obLen])
    if array.size(bullObTop) > obKeepMax
        array.pop(bullObTop)
        array.pop(bullObBtm)
        array.pop(bullObAvg)
        array.pop(bullObLeft)

if newBearOB
    float t = high[obLen]
    float b = hl2[obLen]
    array.unshift(bearObTop, t)
    array.unshift(bearObBtm, b)
    array.unshift(bearObAvg, math.avg(t, b))
    array.unshift(bearObLeft, bar_index[obLen])
    if array.size(bearObTop) > obKeepMax
        array.pop(bearObTop)
        array.pop(bearObBtm)
        array.pop(bearObAvg)
        array.pop(bearObLeft)

// Remove mitigated OBs.
// Pre-calculate highest/lowest every bar before conditional use.
obTargetBullClose = ta.lowest(close, obLen)
obTargetBullWick = ta.lowest(low, obLen)
obTargetBearClose = ta.highest(close, obLen)
obTargetBearWick = ta.highest(high, obLen)
targetBull = obMitigation == "Close" ? obTargetBullClose : obTargetBullWick
targetBear = obMitigation == "Close" ? obTargetBearClose : obTargetBearWick

bullObSize = array.size(bullObTop)
if useOB and bullObSize > 0
    for j = 0 to bullObSize - 1
        i = bullObSize - 1 - j
        if targetBull < array.get(bullObBtm, i)
            array.remove(bullObTop, i)
            array.remove(bullObBtm, i)
            array.remove(bullObAvg, i)
            array.remove(bullObLeft, i)

bearObSize = array.size(bearObTop)
if useOB and bearObSize > 0
    for j = 0 to bearObSize - 1
        i = bearObSize - 1 - j
        if targetBear > array.get(bearObTop, i)
            array.remove(bearObTop, i)
            array.remove(bearObBtm, i)
            array.remove(bearObAvg, i)
            array.remove(bearObLeft, i)

nearestBullTop = useOB and array.size(bullObTop) > 0 ? array.get(bullObTop, 0) : na
nearestBullBtm = useOB and array.size(bullObBtm) > 0 ? array.get(bullObBtm, 0) : na
nearestBearTop = useOB and array.size(bearObTop) > 0 ? array.get(bearObTop, 0) : na
nearestBearBtm = useOB and array.size(bearObBtm) > 0 ? array.get(bearObBtm, 0) : na
priceInBullOB = useOB and not na(nearestBullTop) and low <= nearestBullTop and close >= nearestBullBtm
priceNearBullOB = useOB and not na(nearestBullTop) and close >= nearestBullBtm and close <= nearestBullTop + atr * 0.50
bearOBAbove = useOB and not na(nearestBearBtm) and nearestBearBtm > close
obLongOk = not useOB or priceInBullOB or priceNearBullOB or close > nearestBullTop
obRisk = useOB and bearOBAbove and close < nearestBearBtm

// OB drawings.
var array<box> drawBoxes = array.new_box()
var array<line> drawLines = array.new_line()

f_clear_ob_drawings() =>
    if array.size(drawBoxes) > 0
        for b in drawBoxes
            box.delete(b)
        array.clear(drawBoxes)
    if array.size(drawLines) > 0
        for l in drawLines
            line.delete(l)
        array.clear(drawLines)

if barstate.islast and showMapObjects and showOBZones
    f_clear_ob_drawings()
    if useOB and array.size(bullObTop) > 0
        for i = 0 to math.min(obShowCount - 1, array.size(bullObTop) - 1)
            box bx = box.new(array.get(bullObLeft, i), array.get(bullObTop, i), bar_index + 25, array.get(bullObBtm, i), xloc=xloc.bar_index, extend=extend.right, bgcolor=color.new(color.green, 86), border_color=color.new(color.green, 45))
            line ln = line.new(array.get(bullObLeft, i), array.get(bullObAvg, i), bar_index + 25, array.get(bullObAvg, i), xloc=xloc.bar_index, extend=extend.right, color=color.new(color.green, 25), style=line.style_dashed)
            array.push(drawBoxes, bx)
            array.push(drawLines, ln)
    if useOB and array.size(bearObTop) > 0
        for i = 0 to math.min(obShowCount - 1, array.size(bearObTop) - 1)
            box bx = box.new(array.get(bearObLeft, i), array.get(bearObTop, i), bar_index + 25, array.get(bearObBtm, i), xloc=xloc.bar_index, extend=extend.right, bgcolor=color.new(color.red, 86), border_color=color.new(color.red, 45))
            line ln = line.new(array.get(bearObLeft, i), array.get(bearObAvg, i), bar_index + 25, array.get(bearObAvg, i), xloc=xloc.bar_index, extend=extend.right, color=color.new(color.red, 25), style=line.style_dashed)
            array.push(drawBoxes, bx)
            array.push(drawLines, ln)

//====================================================================
// 8. GANN / FIB GEOMETRY MODULE
//====================================================================

groupFib = "11. Gann / Fib Geometry"
fibLen = input.int(60, "Swing Detection Length", minval=10, group=groupFib)
showFibBox = input.bool(false, "Show Fib Box Levels", group=groupFib)
showOTE = input.bool(true, "Show OTE Zone", group=groupFib)
showGannFan = input.bool(false, "Show Simple Gann/Fib Fan", group=groupFib)
fibRequireHealthy = input.bool(false, "Require Healthy Fib Location", group=groupFib)

fibHigh = ta.highest(high, fibLen)
fibLow = ta.lowest(low, fibLen)
fibRange = math.max(fibHigh - fibLow, syminfo.mintick)
fibUpBias = close >= close[fibLen] or emaMid >= emaMid[1]
fib382 = fibHigh - fibRange * 0.382
fib50 = fibHigh - fibRange * 0.500
fib618 = fibHigh - fibRange * 0.618
fib786 = fibHigh - fibRange * 0.786
fibOTE = useFib and close <= fib618 and close >= fib786
fibHealthyPullback = useFib and close <= fib382 and close >= fib786
fibStrongContinuation = useFib and close > fib382 and close <= fibHigh
fibDangerDeep = useFib and close < fib786
fibLongOk = not useFib or not fibRequireHealthy or fibOTE or fibHealthyPullback or fibStrongContinuation
fibRisk = useFib and fibDangerDeep and not reclaimEMA

var array<line> fibLines = array.new_line()
var array<label> fibLabels = array.new_label()
var box oteBox = na

f_clear_fib_drawings() =>
    if array.size(fibLines) > 0
        for l in fibLines
            line.delete(l)
        array.clear(fibLines)
    if array.size(fibLabels) > 0
        for lb in fibLabels
            label.delete(lb)
        array.clear(fibLabels)
    if not na(oteBox)
        box.delete(oteBox)

f_add_fib_line(float y, string txt, color c) =>
    line ln = line.new(bar_index - fibLen, y, bar_index + 20, y, xloc=xloc.bar_index, extend=extend.right, color=c, style=line.style_dotted)
    label lb = label.new(bar_index + 20, y, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=c, size=size.tiny)
    array.push(fibLines, ln)
    array.push(fibLabels, lb)

if barstate.islast and showMapObjects and useFib
    f_clear_fib_drawings()
    if showFibBox
        f_add_fib_line(fib382, "0.382", color.new(color.green, 0))
        f_add_fib_line(fib50, "0.500", color.new(color.gray, 0))
        f_add_fib_line(fib618, "0.618", color.new(color.orange, 0))
        f_add_fib_line(fib786, "0.786", color.new(color.red, 0))
    if showOTE
        oteBox := box.new(bar_index - fibLen, fib618, bar_index + 20, fib786, xloc=xloc.bar_index, extend=extend.right, bgcolor=color.new(color.orange, 92), border_color=color.new(color.orange, 60))
    if showGannFan
        float startY = fibLow
        int startX = bar_index - fibLen
        for ratio in array.from(1.0, 2.0, 3.0, 4.0, 8.0)
            float y2 = fibLow + fibRange / ratio
            line ln = line.new(startX, startY, bar_index + 20, y2, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.gray, 35), style=ratio == 2.0 or ratio == 3.0 ? line.style_solid : line.style_dashed)
            array.push(fibLines, ln)

//====================================================================
// 9. DIVERGENCE MODULE — MULTI-INDICATOR EFFICIENT VERSION
//====================================================================

groupDiv = "12. Divergence Module"
divLen = input.int(5, "Pivot Period", minval=1, maxval=50, group=groupDiv)
divMinCount = input.int(1, "Minimum Divergence Count", minval=1, maxval=11, group=groupDiv)
divType = input.string("Regular/Hidden", "Divergence Type", options=["Regular", "Hidden", "Regular/Hidden"], group=groupDiv)
showDivLabels = input.bool(false, "Show Divergence Labels", group=groupDiv)
useDivMACD = input.bool(true, "MACD", group=groupDiv)
useDivHist = input.bool(true, "MACD Histogram", group=groupDiv)
useDivRSI = input.bool(true, "RSI", group=groupDiv)
useDivStoch = input.bool(true, "Stochastic", group=groupDiv)
useDivCCI = input.bool(true, "CCI", group=groupDiv)
useDivMOM = input.bool(true, "Momentum", group=groupDiv)
useDivOBV = input.bool(true, "OBV", group=groupDiv)
useDivVWMACD = input.bool(true, "VW-MACD", group=groupDiv)
useDivCMF = input.bool(true, "CMF", group=groupDiv)
useDivMFI = input.bool(true, "MFI", group=groupDiv)
useDivExternal = input.bool(false, "External Source", group=groupDiv)
externalSource = input.source(close, "External Source", group=groupDiv)

vwFast = ta.vwma(close, 12)
vwSlow = ta.vwma(close, 26)
vwMacd = vwFast - vwSlow

divPL = ta.pivotlow(low, divLen, divLen)
divPH = ta.pivothigh(high, divLen, divLen)

f_div_low(series float src) =>
    var float prevPrice = na
    var float prevInd = na
    bool posReg = false
    bool posHid = false
    if not na(divPL)
        float p = low[divLen]
        float v = src[divLen]
        if not na(prevPrice) and not na(prevInd)
            posReg := p < prevPrice and v > prevInd
            posHid := p > prevPrice and v < prevInd
        prevPrice := p
        prevInd := v
    [posReg, posHid]

f_div_high(series float src) =>
    var float prevPrice = na
    var float prevInd = na
    bool negReg = false
    bool negHid = false
    if not na(divPH)
        float p = high[divLen]
        float v = src[divLen]
        if not na(prevPrice) and not na(prevInd)
            negReg := p > prevPrice and v < prevInd
            negHid := p < prevPrice and v > prevInd
        prevPrice := p
        prevInd := v
    [negReg, negHid]

[macdPosReg, macdPosHid] = f_div_low(macdLine)
[macdNegReg, macdNegHid] = f_div_high(macdLine)
[histPosReg, histPosHid] = f_div_low(macdHist)
[histNegReg, histNegHid] = f_div_high(macdHist)
[rsiPosReg, rsiPosHid] = f_div_low(rsi)
[rsiNegReg, rsiNegHid] = f_div_high(rsi)
[stochPosReg, stochPosHid] = f_div_low(stochK)
[stochNegReg, stochNegHid] = f_div_high(stochK)
[cciPosReg, cciPosHid] = f_div_low(cci)
[cciNegReg, cciNegHid] = f_div_high(cci)
[momPosReg, momPosHid] = f_div_low(momentum)
[momNegReg, momNegHid] = f_div_high(momentum)
[obvPosReg, obvPosHid] = f_div_low(obv)
[obvNegReg, obvNegHid] = f_div_high(obv)
[vwPosReg, vwPosHid] = f_div_low(vwMacd)
[vwNegReg, vwNegHid] = f_div_high(vwMacd)
[cmfPosReg, cmfPosHid] = f_div_low(cmf)
[cmfNegReg, cmfNegHid] = f_div_high(cmf)
[mfiPosReg, mfiPosHid] = f_div_low(mfi)
[mfiNegReg, mfiNegHid] = f_div_high(mfi)
[extPosReg, extPosHid] = f_div_low(externalSource)
[extNegReg, extNegHid] = f_div_high(externalSource)

wantReg = divType == "Regular" or divType == "Regular/Hidden"
wantHid = divType == "Hidden" or divType == "Regular/Hidden"

posDivCount = 0
negDivCount = 0
posDivCount += useDivMACD and ((wantReg and macdPosReg) or (wantHid and macdPosHid)) ? 1 : 0
negDivCount += useDivMACD and ((wantReg and macdNegReg) or (wantHid and macdNegHid)) ? 1 : 0
posDivCount += useDivHist and ((wantReg and histPosReg) or (wantHid and histPosHid)) ? 1 : 0
negDivCount += useDivHist and ((wantReg and histNegReg) or (wantHid and histNegHid)) ? 1 : 0
posDivCount += useDivRSI and ((wantReg and rsiPosReg) or (wantHid and rsiPosHid)) ? 1 : 0
negDivCount += useDivRSI and ((wantReg and rsiNegReg) or (wantHid and rsiNegHid)) ? 1 : 0
posDivCount += useDivStoch and ((wantReg and stochPosReg) or (wantHid and stochPosHid)) ? 1 : 0
negDivCount += useDivStoch and ((wantReg and stochNegReg) or (wantHid and stochNegHid)) ? 1 : 0
posDivCount += useDivCCI and ((wantReg and cciPosReg) or (wantHid and cciPosHid)) ? 1 : 0
negDivCount += useDivCCI and ((wantReg and cciNegReg) or (wantHid and cciNegHid)) ? 1 : 0
posDivCount += useDivMOM and ((wantReg and momPosReg) or (wantHid and momPosHid)) ? 1 : 0
negDivCount += useDivMOM and ((wantReg and momNegReg) or (wantHid and momNegHid)) ? 1 : 0
posDivCount += useDivOBV and ((wantReg and obvPosReg) or (wantHid and obvPosHid)) ? 1 : 0
negDivCount += useDivOBV and ((wantReg and obvNegReg) or (wantHid and obvNegHid)) ? 1 : 0
posDivCount += useDivVWMACD and ((wantReg and vwPosReg) or (wantHid and vwPosHid)) ? 1 : 0
negDivCount += useDivVWMACD and ((wantReg and vwNegReg) or (wantHid and vwNegHid)) ? 1 : 0
posDivCount += useDivCMF and ((wantReg and cmfPosReg) or (wantHid and cmfPosHid)) ? 1 : 0
negDivCount += useDivCMF and ((wantReg and cmfNegReg) or (wantHid and cmfNegHid)) ? 1 : 0
posDivCount += useDivMFI and ((wantReg and mfiPosReg) or (wantHid and mfiPosHid)) ? 1 : 0
negDivCount += useDivMFI and ((wantReg and mfiNegReg) or (wantHid and mfiNegHid)) ? 1 : 0
posDivCount += useDivExternal and ((wantReg and extPosReg) or (wantHid and extPosHid)) ? 1 : 0
negDivCount += useDivExternal and ((wantReg and extNegReg) or (wantHid and extNegHid)) ? 1 : 0

positiveDivergence = useDiv and posDivCount >= divMinCount
negativeDivergence = useDiv and negDivCount >= divMinCount
divLongOk = not useDiv or positiveDivergence or not negativeDivergence
divRisk = useDiv and negativeDivergence

//====================================================================
// 9A. REVERSAL MODULE — INDEPENDENT BOTTOM / TOP TURNING SIGNALS
// Purpose:
// - Detect possible bottom reversals after weakness.
// - Detect possible top reversals after strength.
// - Always visible whether in trade or not.
// - Does NOT change the original GS / XGS / DTS structure unless
//   "Allow Bottom REV To Open Trade" is enabled.
//====================================================================

groupRev = "12A. Reversal Module"
revMode = input.string("Balanced", "Reversal Strictness", options=["Early", "Balanced", "Strict"], group=groupRev)
showReversalLabels = input.bool(true, "Show Reversal Labels", group=groupRev)
showBottomReversal = input.bool(true, "Show Bottom Reversal", group=groupRev)
showTopReversal = input.bool(true, "Show Top Reversal", group=groupRev)
revCanTriggerTrade = input.bool(false, "Allow Bottom REV To Open Trade", group=groupRev)
revLookback = input.int(20, "Prior Trend Lookback", minval=5, group=groupRev)
revSweepLen = input.int(10, "Liquidity Sweep Lookback", minval=3, group=groupRev)
revRecentBars = input.int(5, "Recent Reversal Valid Bars", minval=1, group=groupRev)
revRvolNeed = input.float(100.0, "Minimum Reversal RVol %", step=5, group=groupRev)
revBodyNeed = input.float(35.0, "Reversal Body %", step=1, group=groupRev)
revClosePosNeed = input.float(0.58, "Bottom Close Position", step=0.01, group=groupRev)
topClosePosMax = input.float(0.42, "Top Close Position Max", step=0.01, group=groupRev)
revWatchScoreManual = input.float(55.0, "REV Watch Score", step=1, group=groupRev)
revConfirmScoreManual = input.float(70.0, "REV Confirm Score", step=1, group=groupRev)
revRequireSweep = input.bool(true, "Require Liquidity Sweep", group=groupRev)
revRequireReclaim = input.bool(true, "Require EMA/VWAP Reclaim / Loss", group=groupRev)
revRequireDiv = input.bool(false, "Require Divergence", group=groupRev)
revRequireLocation = input.bool(false, "Require OB/FVG/Fib/Premium-Discount Location", group=groupRev)
revBlockIfHTFAgainst = input.bool(false, "Block Bottom REV If HTF Bearish", group=groupRev)

revWatchScore = revMode == "Early" ? math.max(45.0, revWatchScoreManual - 8.0) : revMode == "Balanced" ? revWatchScoreManual : revWatchScoreManual + 8.0
revConfirmScore = revMode == "Early" ? math.max(60.0, revConfirmScoreManual - 8.0) : revMode == "Balanced" ? revConfirmScoreManual : revConfirmScoreManual + 8.0

revSwingLowPrev = ta.lowest(low, revSweepLen)[1]
revSwingHighPrev = ta.highest(high, revSweepLen)[1]

// Bottom reversal components.
botPriorDown = close < emaBase or emaFast < emaMid or close < close[revLookback] or rsi[1] < rsiBullFloor
botExhaustion = rsi[1] < rsiBullFloor or close[1] < emaMid[1] or phaseExhaust[1]
botSweep = low < revSwingLowPrev and close > revSwingLowPrev and lowerWickPct >= wickNeed
botReclaim = reclaimEMA or reclaimVWAP or (close > emaFast and close[1] <= emaFast[1])
botCandle = bullCandle and bodyPct >= revBodyNeed and closePos >= revClosePosNeed
botMomentumTurn = (rsi > rsi[1] and macdHist > macdHist[1]) or stochCrossUp
botLocation = priceInBullOB or priceNearBullOB or priceInBullFVG or smcDiscount or fibOTE or fibHealthyPullback or bbBottomReject
botParticipation = rvolPct >= revRvolNeed or obvRise or cmf > cmf[1]
botNoMajorRisk = noTrap and not distHidden and not smcBearEvent and not negativeDivergence

botRevScore = 0.0
botRevScore += botPriorDown ? 12 : 0
botRevScore += botExhaustion ? 10 : 0
botRevScore += botSweep ? 15 : 0
botRevScore += botReclaim ? 15 : 0
botRevScore += botCandle ? 12 : 0
botRevScore += botMomentumTurn ? 12 : 0
botRevScore += positiveDivergence ? 12 : 0
botRevScore += botLocation ? 8 : 0
botRevScore += botParticipation ? 8 : 0
botRevScore += botNoMajorRisk ? 8 : 0
botRevScore := math.min(botRevScore, 100.0)

botMandatoryOk = useReversal and showBottomReversal and botPriorDown and confirmedOk
botMandatoryOk := botMandatoryOk and (not revRequireSweep or botSweep)
botMandatoryOk := botMandatoryOk and (not revRequireReclaim or botReclaim)
botMandatoryOk := botMandatoryOk and (not revRequireDiv or positiveDivergence)
botMandatoryOk := botMandatoryOk and (not revRequireLocation or botLocation)
botMandatoryOk := botMandatoryOk and (not revBlockIfHTFAgainst or htfBull)

botRevWatch = botMandatoryOk and botRevScore >= revWatchScore and botRevScore < revConfirmScore
botRevConfirm = botMandatoryOk and botRevScore >= revConfirmScore and botNoMajorRisk
botRevConfirmBars = nz(ta.barssince(botRevConfirm), 100000)
botRevRecent = useReversal and botRevConfirmBars <= revRecentBars
botRevWatchEvent = botRevWatch and not botRevWatch[1]
botRevConfirmEvent = botRevConfirm and not botRevConfirm[1]

// Top reversal components.
topPriorUp = close > emaBase or emaFast > emaMid or close > close[revLookback] or rsi[1] > rsiPower
topExhaustion = rsi[1] >= rsiExhaust - 4 or overextended or phaseExhaust or close > emaMid + atr * maxAtrStretch * 0.75
topSweep = high > revSwingHighPrev and close < revSwingHighPrev and upperWickPct >= wickNeed
topLoss = (close < emaFast and close[1] >= emaFast[1]) or (close < emaMid and close[1] >= emaMid[1]) or (useVWAP and close < vwapVal and close[1] >= vwapVal[1])
topCandle = bearCandle and bodyPct >= revBodyNeed and closePos <= topClosePosMax
topMomentumFade = (rsi < rsi[1] and macdHist < macdHist[1]) or stochCrossDown
topLocation = smcPremium or priceInBearFVG or bearOBAbove or close >= fib382 or bbTopReject
topDistribution = distHidden or (rvolPct >= highRvol and close < open and upperWickPct >= 30)
topNoBullContinuation = not phaseExpand or close < emaFast or macdHist < macdHist[1]

topRevScore = 0.0
topRevScore += topPriorUp ? 12 : 0
topRevScore += topExhaustion ? 12 : 0
topRevScore += topSweep ? 15 : 0
topRevScore += topLoss ? 15 : 0
topRevScore += topCandle ? 12 : 0
topRevScore += topMomentumFade ? 12 : 0
topRevScore += negativeDivergence ? 12 : 0
topRevScore += topLocation ? 8 : 0
topRevScore += topDistribution ? 8 : 0
topRevScore += topNoBullContinuation ? 6 : 0
topRevScore := math.min(topRevScore, 100.0)

topMandatoryOk = useReversal and showTopReversal and topPriorUp and confirmedOk
topMandatoryOk := topMandatoryOk and (not revRequireSweep or topSweep)
topMandatoryOk := topMandatoryOk and (not revRequireReclaim or topLoss)
topMandatoryOk := topMandatoryOk and (not revRequireDiv or negativeDivergence)
topMandatoryOk := topMandatoryOk and (not revRequireLocation or topLocation)

topRevWatch = topMandatoryOk and topRevScore >= revWatchScore and topRevScore < revConfirmScore
topRevConfirm = topMandatoryOk and topRevScore >= revConfirmScore
topRevWatchEvent = topRevWatch and not topRevWatch[1]
topRevConfirmEvent = topRevConfirm and not topRevConfirm[1]

// Backward-compatible aliases for existing trade/dashboard references.
// Watch states remain internal only; the chart now shows confirmed BOT REV / TOP REV only.
revWatch = botRevWatch
revConfirm = botRevConfirm
revScore = botRevScore
revRecent = botRevRecent
revWatchEvent = botRevWatchEvent
revConfirmEvent = botRevConfirmEvent

//====================================================================
// 9B. TREND VISUAL MODULE — CLEAN TRENDLINE + BREAK MARKERS
// Visual only. Does not affect GS / XGS / DTS / Reversal decisions.
//====================================================================

groupTrendVis = "12B. Trend Visual Module"
useTrendVisual = input.bool(true, "Use Trend Visual", group=groupTrendVis)
showTrendBreaks = input.bool(true, "Show Trend Break Markers", group=groupTrendVis)
showOnlyActiveTrendLine = input.bool(true, "Show Only Active Trendline", group=groupTrendVis)
trendPivotLen = input.int(8, "Trend Pivot Length", minval=2, group=groupTrendVis)
trendLineWidth = input.int(2, "Trend Line Width", minval=1, maxval=4, group=groupTrendVis)
trendBreakConfirmClose = input.bool(true, "Confirm Break By Close", group=groupTrendVis)

trendPH = ta.pivothigh(high, trendPivotLen, trendPivotLen)
trendPL = ta.pivotlow(low, trendPivotLen, trendPivotLen)

var float prevTrendLow = na
var float lastTrendLow = na
var int prevTrendLowBar = na
var int lastTrendLowBar = na

var float prevTrendHigh = na
var float lastTrendHigh = na
var int prevTrendHighBar = na
var int lastTrendHighBar = na

if not na(trendPL)
    prevTrendLow := lastTrendLow
    prevTrendLowBar := lastTrendLowBar
    lastTrendLow := trendPL
    lastTrendLowBar := bar_index - trendPivotLen

if not na(trendPH)
    prevTrendHigh := lastTrendHigh
    prevTrendHighBar := lastTrendHighBar
    lastTrendHigh := trendPH
    lastTrendHighBar := bar_index - trendPivotLen

f_line_value(int x1, float y1, int x2, float y2, int x) =>
    x2 != x1 ? y1 + (y2 - y1) * (x - x1) / (x2 - x1) : na

bullTrendValid = useTrendVisual and not na(prevTrendLow) and not na(lastTrendLow) and not na(prevTrendLowBar) and not na(lastTrendLowBar) and lastTrendLowBar != prevTrendLowBar and lastTrendLow > prevTrendLow
bearTrendValid = useTrendVisual and not na(prevTrendHigh) and not na(lastTrendHigh) and not na(prevTrendHighBar) and not na(lastTrendHighBar) and lastTrendHighBar != prevTrendHighBar and lastTrendHigh < prevTrendHigh

bullTrendNow = bullTrendValid ? f_line_value(prevTrendLowBar, prevTrendLow, lastTrendLowBar, lastTrendLow, bar_index) : na
bearTrendNow = bearTrendValid ? f_line_value(prevTrendHighBar, prevTrendHigh, lastTrendHighBar, lastTrendHigh, bar_index) : na
bullTrendPrev = bullTrendValid ? f_line_value(prevTrendLowBar, prevTrendLow, lastTrendLowBar, lastTrendLow, bar_index - 1) : na
bearTrendPrev = bearTrendValid ? f_line_value(prevTrendHighBar, prevTrendHigh, lastTrendHighBar, lastTrendHigh, bar_index - 1) : na

trendBreakDownCloseRaw = close < bullTrendNow and close[1] >= bullTrendPrev
trendBreakDownWickRaw = low < bullTrendNow and low[1] >= bullTrendPrev
trendBreakUpCloseRaw = close > bearTrendNow and close[1] <= bearTrendPrev
trendBreakUpWickRaw = high > bearTrendNow and high[1] <= bearTrendPrev
trendBreakDown = showTrendBreaks and bullTrendValid and (trendBreakConfirmClose ? trendBreakDownCloseRaw : trendBreakDownWickRaw) and confirmedOk
trendBreakUp = showTrendBreaks and bearTrendValid and (trendBreakConfirmClose ? trendBreakUpCloseRaw : trendBreakUpWickRaw) and confirmedOk

var line bullTrendLine = na
var line bearTrendLine = na

if useTrendVisual and barstate.islast and not isMinimal
    if not na(bullTrendLine)
        line.delete(bullTrendLine)
    if not na(bearTrendLine)
        line.delete(bearTrendLine)

    activeBullTrend = bullTrendValid and (not showOnlyActiveTrendLine or close >= bullTrendNow)
    activeBearTrend = bearTrendValid and (not showOnlyActiveTrendLine or close <= bearTrendNow)

    if activeBullTrend
        bullTrendLine := line.new(prevTrendLowBar, prevTrendLow, lastTrendLowBar, lastTrendLow, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.green, 20), width=trendLineWidth)
    if activeBearTrend
        bearTrendLine := line.new(prevTrendHighBar, prevTrendHigh, lastTrendHighBar, lastTrendHigh, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.red, 20), width=trendLineWidth)

//====================================================================
// 10. XGS / DTS SCORING
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
xgsStructure += (not useHTF or htfBull) ? 10 : 0
xgsStructure += useSMC and recentSmcBull ? 5 : 0
xgsStructure += useOB and priceInBullOB ? 5 : 0
xgsStructure += useFib and (fibOTE or fibHealthyPullback or fibStrongContinuation) ? 5 : 0

xgsMomentum = 0.0
xgsMomentum += rsi > rsiBullFloor ? 6 : 0
xgsMomentum += rsi >= rsiPower ? 6 : 0
xgsMomentum += macdHist > 0 ? 6 : 0
xgsMomentum += macdHist >= macdHist[1] ? 5 : 0
xgsMomentum += useDiv and positiveDivergence ? 4 : 0
xgsMomentum += useMEF and mefBullTrend ? 3 : 0
xgsMomentum += useBBAdvanced and (bbBullControl or bbUpperWalk) ? 3 : 0

xgsLeadership = 0.0
xgsLeadership += (not useRLT or rltBull) ? 10 : 0
xgsLeadership += useRLT and rsBreak ? 5 : 0

xgsRisk = 0.0
xgsRisk += noTrap ? 5 : 0
xgsRisk += safetyOk ? 5 : 0
xgsRisk += not smcShortRisk ? 3 : 0
xgsRisk += not obRisk ? 3 : 0
xgsRisk += not divRisk ? 3 : 0

xgsScoreRaw = xgsTrend + xgsStructure + xgsMomentum + xgsLeadership + xgsRisk
xgsScore = math.min(math.max(xgsScoreRaw, 0.0), 100.0)
xgsBuy = (not useXGS) or (xgsScore >= xgsBuyThreshold and trendHealthy and (not useHTF or htfBull) and noTrap)

dtsLocation = 0.0
dtsLocation += close > emaMid ? 8 : 0
dtsLocation += useVWAP ? close > vwapVal ? 8 : 0 : close > emaMid ? 8 : 0
dtsLocation += liquidityReclaim ? 12 : 0
dtsLocation += close > pivotP ? 5 : 0
dtsLocation += useSMC and (recentSmcBull or priceInBullFVG) ? 5 : 0
dtsLocation += useOB and priceInBullOB ? 5 : 0
dtsLocation += useFib and fibOTE ? 4 : 0

dtsTrigger = 0.0
dtsTrigger += candleAuthority ? 18 : 0
dtsTrigger += machiA ? 8 : machiB ? 4 : 0
dtsTrigger += stochCrossUp or stochK > stochD ? 5 : 0
dtsTrigger += bullCandle and closePos >= 0.60 ? 5 : 0
dtsTrigger += useMEF and microUseDtsBoost and mefBullConfirm ? 4 : 0

dtsParticipation = 0.0
dtsParticipation += rvolPct >= rvolNeed ? 12 : 0
dtsParticipation += obvRise ? 5 : 0
dtsParticipation += cmf > 0 ? 5 : 0

dtsContext = 0.0
dtsContext += inSession ? 6 : 0
dtsContext += phaseBull ? 6 : 0
dtsContext += useBBAdvanced and vrmExpansion ? 3 : 0
dtsContext += noTrap ? 6 : 0
dtsContext += not divRisk ? 3 : 0

dtsScore = math.min(math.max(dtsLocation + dtsTrigger + dtsParticipation + dtsContext, 0.0), 100.0)
dtsBuy = (not useDTS) or (dtsScore >= dtsBuyThreshold and inSession and candleAuthority and noTrap and confirmedOk)

//====================================================================
// 11. MASTER LAYER ENGINE
//====================================================================

L01 = useXGS ? xgsScore >= xgsBuyThreshold : true
L02 = useDTS ? dtsScore >= dtsBuyThreshold : true
L03 = trendHealthy and emaMid > emaBase
L04 = rsi >= rsiPower and rsi < 68 and macdHist > 0
L05 = macdHist >= macdHist[1] and macdLine >= macdSignal
L06 = rvolPct >= rvolNeed and participation
L07 = cmf > 0 or mfi >= 55
L08 = not useRLT or rltBull
L09 = not useHTF or htfBull
L10 = candleAuthority and machiA
L11 = noTrap and noDistribution
L12 = phaseBull and safetyOk and not overextended
L13 = not useSMC or smcLongOk
L14 = not useOB or obLongOk
L15 = not useFib or fibLongOk
L16 = not useDiv or divLongOk

//====================================================================
// 11A. GS CORE AUTHORITY ENGINE
// This anchors GS Master to the original GS-style 12-layer logic.
// GS Legacy: closest behavior to original GS.
// GS Master Filtered: GS core must agree, then Master modules grade/filter.
// Master Independent: full master engine can fire from full confluence.
//====================================================================

gsCoreLayers = 0
gsCoreLayers += L01 ? 1 : 0
gsCoreLayers += L02 ? 1 : 0
gsCoreLayers += L03 ? 1 : 0
gsCoreLayers += L04 ? 1 : 0
gsCoreLayers += L05 ? 1 : 0
gsCoreLayers += L06 ? 1 : 0
gsCoreLayers += L07 ? 1 : 0
gsCoreLayers += L08 ? 1 : 0
gsCoreLayers += L09 ? 1 : 0
gsCoreLayers += L10 ? 1 : 0
gsCoreLayers += L11 ? 1 : 0
gsCoreLayers += L12 ? 1 : 0

gsCoreBuyRaw = xgsBuy and dtsBuy and gsCoreLayers >= 10 and confirmedOk
gsCoreApexRaw = xgsBuy and dtsBuy and gsCoreLayers >= 12 and confirmedOk
gsCoreWatchRaw = gsCoreLayers >= 7 and confirmedOk
legacyGrade = gsCoreApexRaw ? "A" : gsCoreBuyRaw ? "B" : gsCoreWatchRaw ? "Watch" : "Wait"

//====================================================================
// 11B. MASTER MODULE CONFIRMATION ENGINE
// This prevents GS Master from behaving exactly like classic GS.
// GS Classic mode keeps the old GS-style behavior.
// Balanced/Strict/Institutional modes require real confirmation from
// the added modules before producing B/A/A+ signals.
//====================================================================

smcConfirm = useSMC and (recentSmcBull or intBullCHOCH or swBullCHOCH or intBullBOS or swBullBOS or priceInBullFVG)
obBreakCrossRaw = ta.crossover(close, nearestBullTop)
obBreakConfirm = useOB and not na(nearestBullTop) and obBreakCrossRaw
obConfirm = useOB and (priceInBullOB or priceNearBullOB or obBreakConfirm or newBullOB)
fibConfirm = useFib and (fibOTE or fibHealthyPullback or fibStrongContinuation)
divConfirm = useDiv and positiveDivergence
mefConfirm = useMEF and (mefBullConfirm or mefBullTrend)
bbConfirm = useBBAdvanced and (vrmExpansion or bbBullControl or bbUpperWalk or bbBottomReject)
bbRisk = useBBAdvanced and bbTopReject
noBearDivConfirm = not useDiv or not negativeDivergence

moduleActiveCount = 0
moduleConfirmCount = 0
moduleActiveCount += useSMC ? 1 : 0
moduleConfirmCount += smcConfirm ? 1 : 0
moduleActiveCount += useOB ? 1 : 0
moduleConfirmCount += obConfirm ? 1 : 0
moduleActiveCount += useFib ? 1 : 0
moduleConfirmCount += fibConfirm ? 1 : 0
moduleActiveCount += useDiv ? 1 : 0
moduleConfirmCount += divConfirm ? 1 : 0
moduleActiveCount += useMEF ? 1 : 0
moduleConfirmCount += mefConfirm ? 1 : 0
moduleActiveCount += useBBAdvanced ? 1 : 0
moduleConfirmCount += bbConfirm ? 1 : 0

presetMinBuy = masterConfirmMode == "GS Classic" ? 0 : masterConfirmMode == "Balanced Master" ? 1 : masterConfirmMode == "Strict Master" ? 2 : 3
presetMinA = masterConfirmMode == "GS Classic" ? 0 : masterConfirmMode == "Balanced Master" ? 2 : masterConfirmMode == "Strict Master" ? 3 : 3
presetMinBuyAdj = filterLevel == "Loose" ? math.max(0, presetMinBuy - 1) : filterLevel == "Balanced" ? presetMinBuy : filterLevel == "Strict" ? math.min(6, presetMinBuy + 1) : math.min(6, presetMinBuy + 1)
presetMinAAdj = filterLevel == "Loose" ? math.max(0, presetMinA - 1) : filterLevel == "Balanced" ? presetMinA : filterLevel == "Strict" ? math.min(6, presetMinA + 1) : math.min(6, presetMinA + 1)
minModuleConfirmBuy = masterConfirmMode == "GS Classic" ? 0 : math.max(presetMinBuyAdj, minModuleConfirmManual)
minModuleConfirmA = masterConfirmMode == "GS Classic" ? 0 : math.max(presetMinAAdj, minModuleConfirmAManual)
moduleBuyOk = masterConfirmMode == "GS Classic" or moduleConfirmCount >= minModuleConfirmBuy
moduleAOk = masterConfirmMode == "GS Classic" or (moduleConfirmCount >= minModuleConfirmA and noBearDivConfirm)

activeLayers = 0
passedLayers = 0
activeLayers += L01_on ? 1 : 0
passedLayers += L01_on and L01 ? 1 : 0
activeLayers += L02_on ? 1 : 0
passedLayers += L02_on and L02 ? 1 : 0
activeLayers += L03_on ? 1 : 0
passedLayers += L03_on and L03 ? 1 : 0
activeLayers += L04_on ? 1 : 0
passedLayers += L04_on and L04 ? 1 : 0
activeLayers += L05_on ? 1 : 0
passedLayers += L05_on and L05 ? 1 : 0
activeLayers += L06_on ? 1 : 0
passedLayers += L06_on and L06 ? 1 : 0
activeLayers += L07_on ? 1 : 0
passedLayers += L07_on and L07 ? 1 : 0
activeLayers += L08_on ? 1 : 0
passedLayers += L08_on and L08 ? 1 : 0
activeLayers += L09_on ? 1 : 0
passedLayers += L09_on and L09 ? 1 : 0
activeLayers += L10_on ? 1 : 0
passedLayers += L10_on and L10 ? 1 : 0
activeLayers += L11_on ? 1 : 0
passedLayers += L11_on and L11 ? 1 : 0
activeLayers += L12_on ? 1 : 0
passedLayers += L12_on and L12 ? 1 : 0
activeLayers += L13_on and useSMC ? 1 : 0
passedLayers += L13_on and useSMC and L13 ? 1 : 0
activeLayers += L14_on and useOB ? 1 : 0
passedLayers += L14_on and useOB and L14 ? 1 : 0
activeLayers += L15_on and useFib ? 1 : 0
passedLayers += L15_on and useFib and L15 ? 1 : 0
activeLayers += L16_on and useDiv ? 1 : 0
passedLayers += L16_on and useDiv and L16 ? 1 : 0

confluencePct = activeLayers > 0 ? passedLayers / activeLayers * 100.0 : 0.0

mandatoryOk = true
mandatoryOk := mandatoryOk and (not requireXGSForBuy or xgsBuy)
mandatoryOk := mandatoryOk and (not requireDTSForBuy or dtsBuy)
mandatoryOk := mandatoryOk and (not requireNoTrapForBuy or noTrap)
mandatoryOk := mandatoryOk and (not requireHTFForBuy or htfBull)
mandatoryOk := mandatoryOk and moduleBuyOk

A_requirement_ok = true
A_requirement_ok := A_requirement_ok and (not requireSMCForA or smcConfirm)
A_requirement_ok := A_requirement_ok and (not requireOBorFibForA or obConfirm or fibConfirm)
A_requirement_ok := A_requirement_ok and moduleAOk

gradeAPlusRaw = confluencePct >= aPlusPct and mandatoryOk and A_requirement_ok and confirmedOk
gradeARaw = confluencePct >= aPct and mandatoryOk and A_requirement_ok and confirmedOk
gradeBRaw = confluencePct >= bPct and mandatoryOk and confirmedOk
watchRaw = confluencePct >= watchPct and confirmedOk

independentGrade = gradeAPlusRaw ? "A+" : gradeARaw ? "A" : gradeBRaw ? "B" : watchRaw ? "Watch" : "Wait"
independentBuyRaw = gradeAPlusRaw or gradeARaw or gradeBRaw
legacyBuyRaw = gsCoreBuyRaw
filteredBuyRaw = gsCoreBuyRaw and independentBuyRaw
coreAuthorityBuyRaw = signalAuthorityMode == "GS Legacy" ? legacyBuyRaw : signalAuthorityMode == "GS Master Filtered" ? filteredBuyRaw : independentBuyRaw
masterGrade = signalAuthorityMode == "GS Legacy" ? legacyGrade : independentGrade
revTradeRaw = revCanTriggerTrade and revConfirm
tradeGrade = revTradeRaw and not coreAuthorityBuyRaw ? "REV" : masterGrade
majorBuyRaw = coreAuthorityBuyRaw or revTradeRaw

// Diagnostic states.
setupSignal = xgsBuy and not dtsBuy and confluencePct >= watchPct
timingSignal = dtsBuy and not xgsBuy and confluencePct >= watchPct
apexImminent = confluencePct >= aPct - 5 and confluencePct < aPct and mandatoryOk

//====================================================================
// 12. RISK, TARGETS, AND DYNAMIC TRAILING SL
//====================================================================

groupRisk = "13. Risk / Trailing Stop"
atrSLMult = input.float(1.5, "Initial Stop ATR Mult", step=0.1, group=groupRisk)
swingSLBuffer = input.float(0.20, "Swing Stop Buffer x ATR", step=0.05, group=groupRisk)
rr1 = input.float(1.5, "TP1 Risk Multiple", step=0.1, group=groupRisk)
rr2 = input.float(3.0, "TP2 Risk Multiple", step=0.1, group=groupRisk)
trailMode = input.string("Hybrid Safe", "Trailing Mode", options=["Off", "ATR", "EMA21", "Swing Low", "Hybrid Safe", "Hybrid Tight"], group=groupRisk)
trailStartMode = input.string("After TP1", "Start Trailing", options=["Immediately", "After % Gain", "After TP1"], group=groupRisk)
trailStartPct = input.float(7.0, "Trail Start Gain %", step=0.5, group=groupRisk)
breakevenPct = input.float(7.0, "Move SL To Entry After Gain %", step=0.5, group=groupRisk)
emaTrailPct = input.float(10.0, "Force EMA Trail After Gain %", step=0.5, group=groupRisk)
trailAtrMult = input.float(1.4, "Trailing ATR Mult", step=0.1, group=groupRisk)
trailEmaBuffer = input.float(0.20, "EMA Trail Buffer x ATR", step=0.05, group=groupRisk)
trailSwingLen = input.int(5, "Trailing Swing Low Length", minval=2, group=groupRisk)
trailSwingBuffer = input.float(0.10, "Trailing Swing Buffer x ATR", step=0.05, group=groupRisk)
exitOnWarn = input.bool(false, "Exit On Warn", group=groupRisk)

var bool inTrade = false
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var float activeRisk = na
var string activeGrade = ""
var int lastMajorSignalBar = na
var int lastWarnBar = na
var int entryBar = na
var bool tp1Touched = false
var bool tp2Touched = false

slAtr = close - atr * atrSLMult
slSwing = swingLow - atr * swingSLBuffer
candidateSL = math.min(slAtr, slSwing)
candidateRisk = math.max(close - candidateSL, syminfo.mintick)
candidateTP1 = close + candidateRisk * rr1
candidateTP2 = close + candidateRisk * rr2

majorCooldownOk = cooldownBars == 0 or na(lastMajorSignalBar) or bar_index - lastMajorSignalBar > cooldownBars
masterBuy = majorBuyRaw and majorCooldownOk and (not useTradeState or not inTrade) and confirmedOk

gainPct = inTrade and not na(activeEntry) ? (close - activeEntry) / activeEntry * 100.0 : 0.0
rawWarn = inTrade and confirmedOk and (operatorTrap or distHidden or overextended or divRisk or smcShortRisk or obRisk or fibRisk or bbRisk or topRevConfirm or trendBreakDown or (useMEF and microWarnMode and mefBearConfirm) or (rsi > 68 and macdHist < macdHist[1]) or close < emaMid)
warnEvent = rawWarn and (na(lastWarnBar) or bar_index - lastWarnBar > warnCooldownBars)

if masterBuy
    inTrade := true
    activeEntry := close
    activeSL := candidateSL
    activeTP1 := candidateTP1
    activeTP2 := candidateTP2
    activeRisk := candidateRisk
    activeGrade := tradeGrade
    entryBar := bar_index
    tp1Touched := false
    tp2Touched := false
    lastMajorSignalBar := bar_index

if inTrade
    tp1Touched := tp1Touched or high >= activeTP1
    tp2Touched := tp2Touched or high >= activeTP2

trailAtr = close - atr * trailAtrMult
trailEMA = emaMid - atr * trailEmaBuffer
trailSwing = ta.lowest(low, trailSwingLen) - atr * trailSwingBuffer
trailSafe = math.min(trailAtr, math.max(trailEMA, trailSwing))
trailTight = math.max(trailAtr, math.max(trailEMA, trailSwing))
trailBase = trailMode == "ATR" ? trailAtr : trailMode == "EMA21" ? trailEMA : trailMode == "Swing Low" ? trailSwing : trailMode == "Hybrid Safe" ? trailSafe : trailMode == "Hybrid Tight" ? trailTight : na
trailStartOk = trailMode != "Off" and inTrade and (trailStartMode == "Immediately" or (trailStartMode == "After % Gain" and gainPct >= trailStartPct) or (trailStartMode == "After TP1" and tp1Touched))

if inTrade and not na(activeSL)
    if gainPct >= breakevenPct
        activeSL := math.max(activeSL, activeEntry)
    if gainPct >= emaTrailPct
        activeSL := math.max(activeSL, trailEMA)
    if trailStartOk and not na(trailBase)
        activeSL := math.max(activeSL, trailBase)

slHit = inTrade and not na(activeSL) and close < activeSL
structInvalid = inTrade and confirmedOk and ((close < emaBase and macdHist < 0) or (rsi < rsiBullFloor and close < emaMid) or (useSMC and swBearBOS))
rawExit = inTrade and confirmedOk and (slHit or structInvalid or (exitOnWarn and warnEvent))
exitEvent = rawExit and not rawExit[1]

if warnEvent
    lastWarnBar := bar_index

if exitEvent
    inTrade := false
    activeEntry := na
    activeSL := na
    activeTP1 := na
    activeTP2 := na
    activeRisk := na
    activeGrade := ""
    lastMajorSignalBar := bar_index
    entryBar := na
    tp1Touched := false
    tp2Touched := false

// Events after state processing.
watchEvent = not isMinimal and watchRaw and not watchRaw[1] and not majorBuyRaw
setupEvent = showFullObjects and setupSignal and not setupSignal[1]
timingEvent = showFullObjects and timingSignal and not timingSignal[1]
buyBEvent = masterBuy and masterGrade == "B"
buyAEvent = masterBuy and masterGrade == "A"
buyAPlusEvent = masterBuy and masterGrade == "A+"
buyRevEvent = masterBuy and tradeGrade == "REV"
aUpgradeEvent = inTrade and not masterBuy and (gradeAPlusRaw or gradeARaw) and not (gradeAPlusRaw[1] or gradeARaw[1])

//====================================================================
// 13. VISUALS
//====================================================================

groupDisplay = "14. Display"
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
showEMAs = input.bool(true, "Show EMAs", group=groupDisplay)
showVWAPLine = input.bool(false, "Show VWAP", group=groupDisplay)
showDonchian = input.bool(false, "Show Donchian", group=groupDisplay)
showPivots = input.bool(false, "Show Daily Pivots", group=groupDisplay)
showRiskMap = input.bool(true, "Show Entry / SL / TP", group=groupDisplay)
showBuyLabels = input.bool(true, "Show Buy Labels", group=groupDisplay)
buyLabelStyle = input.string("Vertical Compact", "Buy Label Style", options=["Off", "Vertical Compact", "Vertical Detailed"], group=groupDisplay)
showBuyBadge = input.bool(false, "Show Separate B/A/A+ Badge", group=groupDisplay)
showWarnMarker = input.bool(true, "Show Warn Marker", group=groupDisplay)
showExitLabels = input.bool(true, "Show Exit Labels", group=groupDisplay)
showTrailingLabel = input.bool(false, "Show Trailing SL Updates", group=groupDisplay)

plot(showEMAs and not isMinimal ? emaFast : na, "EMA 9", color=color.new(color.teal, 0), linewidth=1)
plot(showEMAs and not isMinimal ? emaMid : na, "EMA 21", color=color.new(color.orange, 0), linewidth=2)
plot(showEMAs and not isMinimal ? emaBase : na, "EMA 50", color=color.new(color.blue, 0), linewidth=1)
plot(showEMAs and not isMinimal ? emaMacro : na, "EMA 200", color=color.new(color.gray, 15), linewidth=2)
plot(showMicroEMAs and not isMinimal ? mefFast : na, "Micro EMA Fast", color=color.new(color.aqua, 0), linewidth=1)
plot(showMicroEMAs and not isMinimal ? mefSlow : na, "Micro EMA Slow", color=color.new(color.orange, 0), linewidth=1)
bbBasisPlot = plot(showBB and not isMinimal ? bbBasis : na, "BB Basis", color=color.new(color.blue, 0), linewidth=1)
bbUpperPlot = plot(showBB and not isMinimal ? bbUpper : na, "BB Upper", color=color.new(color.red, 0), linewidth=1)
bbLowerPlot = plot(showBB and not isMinimal ? bbLower : na, "BB Lower", color=color.new(color.green, 0), linewidth=1)
fill(bbUpperPlot, bbLowerPlot, color=showBB and showBBFill and not isMinimal ? color.new(color.blue, 92) : na)
plot(showVWAPLine and useVWAP and showMapObjects ? vwapVal : na, "VWAP", color=color.new(color.purple, 0), linewidth=1)
plot(showDonchian and showFullObjects ? donUpper : na, "Donchian Upper", color=color.new(color.green, 75), linewidth=1)
plot(showDonchian and showFullObjects ? donMid : na, "Donchian Mid", color=color.new(color.gray, 80), linewidth=1)
plot(showDonchian and showFullObjects ? donLower : na, "Donchian Lower", color=color.new(color.red, 75), linewidth=1)
plot(showPivots and showMapObjects ? pivotP : na, "Pivot P", color=color.new(color.yellow, 25), linewidth=1, style=plot.style_linebr)
plot(showPivots and showMapObjects ? pivotR1 : na, "Pivot R1", color=color.new(color.green, 75), linewidth=1, style=plot.style_linebr)
plot(showPivots and showMapObjects ? pivotS1 : na, "Pivot S1", color=color.new(color.red, 75), linewidth=1, style=plot.style_linebr)

plot(showRiskMap and inTrade ? activeEntry : na, "GS Master Entry", color=color.new(color.white, 0), linewidth=1, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeSL : na, "GS Master Active / Trailing SL", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeTP1 : na, "GS Master TP1", color=color.new(color.green, 35), linewidth=1, style=plot.style_linebr)
plot(showRiskMap and inTrade ? activeTP2 : na, "GS Master TP2", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)

plotshape(watchEvent, title="Watch", text="Watch", style=shape.circle, location=location.belowbar, color=color.new(color.gray, 0), textcolor=color.white, size=size.tiny)
plotshape(setupEvent, title="Setup", text="Setup", style=shape.triangleup, location=location.belowbar, color=color.new(color.blue, 0), textcolor=color.white, size=size.tiny)
plotshape(timingEvent, title="Timing", text="Timing", style=shape.triangleup, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.tiny)
plotshape(showBuyBadge and buyBEvent, title="GS Master B Badge", text="B", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
plotshape(showBuyBadge and buyAEvent, title="GS Master A Badge", text="A", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
plotshape(showBuyBadge and buyAPlusEvent, title="GS Master A+ Badge", text="A+", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
plotshape(buyRevEvent, title="GS Master REV Trade", text="REV", style=shape.labelup, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.normal)
// Reversal labels are confirmed-only to keep the chart clean.
plotshape(showReversalLabels and botRevConfirmEvent and not buyRevEvent, title="GS Master Bottom REV Confirm", text="BOT REV", style=shape.triangleup, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.small)
plotshape(showReversalLabels and topRevConfirmEvent, title="GS Master Top REV Confirm", text="TOP REV", style=shape.triangledown, location=location.abovebar, color=color.new(color.purple, 0), textcolor=color.white, size=size.small)

// Trendline break markers are visual-only.
plotshape(showTrendBreaks and trendBreakUp and not isMinimal, title="Trend Break Up", text="TBU", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.tiny)
plotshape(showTrendBreaks and trendBreakDown and not isMinimal, title="Trend Break Down", text="TBD", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
plotshape(showMicroMarkers and mefBullConfirm and not isMinimal, title="MEF Bull Flip", text="μ↑", style=shape.circle, location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.tiny)
plotshape(showMicroMarkers and mefBearConfirm and not isMinimal, title="MEF Bear Flip", text="μ↓", style=shape.circle, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)
plotshape(aUpgradeEvent and not isMinimal, title="A Upgrade", text="A↑", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.black, size=size.small)
plotshape(showWarnMarker and warnEvent, title="GS Master Warn", text="!", style=shape.triangledown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)
plotshape(exitEvent, title="GS Master Exit", text="Exit", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

plotshape(showDivLabels and positiveDivergence, title="Positive Divergence", text="+Div", style=shape.labelup, location=location.belowbar, color=color.new(color.yellow, 0), textcolor=color.black, size=size.tiny, offset=-divLen)
plotshape(showDivLabels and negativeDivergence, title="Negative Divergence", text="-Div", style=shape.labeldown, location=location.abovebar, color=color.new(color.navy, 0), textcolor=color.white, size=size.tiny, offset=-divLen)

if showSMCLabels and showFullObjects
    if intBullCHOCH or swBullCHOCH
        label.new(bar_index, low - atr * 0.25, "CHOCH↑", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.black, size=size.tiny)
    if intBullBOS or swBullBOS
        label.new(bar_index, low - atr * 0.25, "BOS↑", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.black, size=size.tiny)
    if intBearCHOCH or swBearCHOCH
        label.new(bar_index, high + atr * 0.25, "CHOCH↓", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    if intBearBOS or swBearBOS
        label.new(bar_index, high + atr * 0.25, "BOS↓", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)

if showBuyLabels and masterBuy and buyLabelStyle != "Off"
    buyLabelColor = tradeGrade == "A+" ? color.new(color.green, 0) : tradeGrade == "A" ? color.new(color.green, 8) : tradeGrade == "B" ? color.new(color.lime, 5) : color.new(color.aqua, 5)
    labelTitle = isSimple ? tradeGrade == "A+" ? "BUY - BEST" : tradeGrade == "A" ? "BUY - STRONG" : tradeGrade == "B" ? "BUY - NORMAL" : "BUY - REVERSAL" : "GS MASTER BUY | " + tradeGrade
    labelStrength = isSimple ? "Strength " : "XGS "
    labelTiming = isSimple ? "Timing " : "DTS "
    labelLine1 = labelTitle
    labelLine2 = "Entry " + str.tostring(activeEntry, format.mintick) + " | SL " + str.tostring(activeSL, format.mintick)
    labelLine3 = "TP1 " + str.tostring(activeTP1, format.mintick) + " | TP2 " + str.tostring(activeTP2, format.mintick)
    labelLine4 = "Conf " + str.tostring(confluencePct, "#.0") + "% | " + labelStrength + str.tostring(xgsScore, "#.0") + " | " + labelTiming + str.tostring(dtsScore, "#.0")
    buyLabelText = labelLine1 + "\n" + labelLine2 + "\n" + labelLine3 + "\n" + labelLine4
    label.new(bar_index, low - atr * 0.65, buyLabelText, style=label.style_label_up, color=buyLabelColor, textcolor=color.black, size=size.small)

if showExitLabels and exitEvent
    exitReason = slHit ? "SL / Trail Hit" : structInvalid ? "Structure Invalid" : exitOnWarn and warnEvent ? "Warn Exit" : "Exit"
    label.new(bar_index, high + atr * 0.55, "GS MASTER EXIT\n" + exitReason, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white)

if showTrailingLabel and inTrade and trailStartOk and activeSL > activeSL[1]
    label.new(bar_index, activeSL, "Trail SL\n" + str.tostring(activeSL, format.mintick), style=label.style_label_left, color=color.new(color.red, 25), textcolor=color.white, size=size.tiny)

// SMC / FVG visuals.
var box fvgBox = na
if barstate.islast and showMapObjects and useSMC and showFVG
    if not na(fvgBox)
        box.delete(fvgBox)
    if priceInBullFVG or (not na(lastBullFvgTop) and bar_index - lastBullFvgBar <= smcRecentBars)
        fvgBox := box.new(lastBullFvgBar, lastBullFvgTop, bar_index + 20, lastBullFvgBtm, xloc=xloc.bar_index, extend=extend.right, bgcolor=color.new(color.green, 90), border_color=color.new(color.green, 65))
    else if priceInBearFVG or (not na(lastBearFvgTop) and bar_index - lastBearFvgBar <= smcRecentBars)
        fvgBox := box.new(lastBearFvgBar, lastBearFvgTop, bar_index + 20, lastBearFvgBtm, xloc=xloc.bar_index, extend=extend.right, bgcolor=color.new(color.red, 90), border_color=color.new(color.red, 65))

//====================================================================
// 14. DASHBOARD
//====================================================================

f_scoreColor(float v) => v >= 85 ? color.new(color.green, 0) : v >= 70 ? color.new(color.lime, 12) : v >= 55 ? color.new(color.yellow, 10) : v >= 40 ? color.new(color.orange, 10) : color.new(color.red, 5)
f_boolColor(bool b) => b ? color.new(color.green, 5) : color.new(color.red, 8)

var table dash = table.new(position.top_right, 4, 9, border_width=1)
if showDashboard and barstate.islast
    stateText = isSimple ? inTrade ? "IN TRADE" : topRevConfirm ? "TOP WARNING" : botRevConfirm ? "BOTTOM TURN" : masterGrade == "A+" ? "BUY BEST" : masterGrade == "A" ? "BUY STRONG" : masterGrade == "B" ? "BUY NORMAL" : masterGrade : inTrade ? "IN " + activeGrade : topRevConfirm ? "TOP REV" : botRevConfirm ? "BOT REV" : masterGrade
    stateBg = inTrade ? color.new(color.green, 0) : topRevConfirm ? color.new(color.purple, 0) : botRevConfirm ? color.new(color.aqua, 0) : masterGrade == "A+" ? color.new(color.green, 0) : masterGrade == "A" ? color.new(color.green, 10) : masterGrade == "B" ? color.new(color.lime, 0) : masterGrade == "Watch" ? color.new(color.yellow, 0) : color.new(color.gray, 35)
    riskTxt = operatorTrap ? "Trap" : overextended ? "Stretch" : distHidden ? "Dist" : topRevConfirm ? "TOP REV" : divRisk ? "Div Risk" : smcShortRisk ? "SMC Risk" : obRisk ? "OB Risk" : botRevConfirm ? "BOT Ready" : close < emaMid ? "Watch" : "OK"
    riskBg = riskTxt == "OK" ? color.new(color.green, 10) : riskTxt == "BOT Ready" ? color.new(color.aqua, 5) : riskTxt == "TOP REV" ? color.new(color.purple, 0) : riskTxt == "Watch" ? color.new(color.orange, 20) : color.new(color.red, 0)
    rltTxt = rltBull ? "Leader" : rltWeak ? "Weak" : "Neutral"
    smcTxt = recentSmcBull ? "Bull" : recentSmcBear ? "Bear" : smcBullBias ? "Bias↑" : smcBearBias ? "Bias↓" : "Neutral"
    obTxt = priceInBullOB ? "In Bull OB" : priceNearBullOB ? "Near OB" : obRisk ? "Bear OB" : "Neutral"
    fibTxt = fibOTE ? "OTE" : fibHealthyPullback ? "Healthy" : fibStrongContinuation ? "Strong" : fibRisk ? "Deep" : "Neutral"
    divTxt = positiveDivergence ? "+Div " + str.tostring(posDivCount) : negativeDivergence ? "-Div " + str.tostring(negDivCount) : "Neutral"

    table.cell(dash, 0, 0, "GS MASTER", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, stateText, text_color=color.black, bgcolor=stateBg)
    modeShort = signalAuthorityMode == "GS Legacy" ? "Legacy" : signalAuthorityMode == "GS Master Filtered" ? "Filtered" : "Indep"
    table.cell(dash, 2, 0, modeShort + " / " + (masterConfirmMode == "GS Classic" ? "Classic" : masterConfirmMode == "Balanced Master" ? "Bal" : masterConfirmMode == "Strict Master" ? "Strict" : "Inst"), text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 0, isPreferredTf ? timeframe.period : "Use 30m/1H", text_color=color.white, bgcolor=isPreferredTf ? color.new(color.black, 0) : color.new(color.orange, 0))

    table.cell(dash, 0, 1, "Layers", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 1, str.tostring(passedLayers) + "/" + str.tostring(activeLayers), text_color=color.white, bgcolor=f_scoreColor(confluencePct))
    table.cell(dash, 2, 1, str.tostring(confluencePct, "#.0") + "%", text_color=color.white, bgcolor=f_scoreColor(confluencePct))
    table.cell(dash, 3, 1, apexImminent ? "Near A" : majorBuyRaw ? "Buy" : signalAuthorityMode == "GS Master Filtered" and not gsCoreBuyRaw ? "Need GS" : moduleBuyOk ? "Wait" : "Need Mod", text_color=color.white, bgcolor=majorBuyRaw ? color.new(color.green, 0) : apexImminent ? color.new(color.orange, 0) : signalAuthorityMode == "GS Master Filtered" and not gsCoreBuyRaw ? color.new(color.orange, 15) : moduleBuyOk ? color.new(color.gray, 35) : color.new(color.red, 10))

    table.cell(dash, 0, 2, "XGS", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 2, str.tostring(xgsScore, "#.0"), text_color=color.white, bgcolor=f_scoreColor(xgsScore))
    table.cell(dash, 2, 2, "DTS", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 2, str.tostring(dtsScore, "#.0"), text_color=color.white, bgcolor=f_scoreColor(dtsScore))

    table.cell(dash, 0, 3, "RLT", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 3, rltTxt, text_color=color.white, bgcolor=rltBull ? color.new(color.green, 0) : rltWeak ? color.new(color.red, 15) : color.new(color.gray, 30))
    table.cell(dash, 2, 3, "HTF", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 3, htfBull ? "Support" : "No", text_color=color.white, bgcolor=f_boolColor(htfBull))

    table.cell(dash, 0, 4, "Phase", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 4, phaseName, text_color=color.white, bgcolor=phaseBull ? color.new(color.green, 15) : phaseExhaust ? color.new(color.red, 10) : color.new(color.gray, 30))
    table.cell(dash, 2, 4, "Candle", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 4, machiGrade, text_color=color.white, bgcolor=machiGrade == "A" ? color.new(color.green, 0) : machiGrade == "B" ? color.new(color.lime, 25) : color.new(color.orange, 20))

    table.cell(dash, 0, 5, "Modules", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, str.tostring(moduleConfirmCount) + "/" + str.tostring(moduleActiveCount), text_color=color.white, bgcolor=moduleBuyOk ? color.new(color.green, 12) : color.new(color.red, 10))
    table.cell(dash, 2, 5, "SMC/OB", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 5, (smcConfirm ? "SMC✓ " : "") + (obConfirm ? "OB✓ " : obRisk ? "OB Risk " : "") + (mefConfirm ? "MEF✓" : "Neutral"), text_color=color.white, bgcolor=smcConfirm or obConfirm or mefConfirm ? color.new(color.green, 10) : obRisk ? color.new(color.red, 15) : color.new(color.gray, 30))

    table.cell(dash, 0, 6, "Fib", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 6, fibConfirm ? fibTxt + "✓" : fibTxt, text_color=color.white, bgcolor=fibConfirm ? color.new(color.green, 12) : fibRisk ? color.new(color.red, 15) : color.new(color.gray, 30))
    table.cell(dash, 2, 6, "REV", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 6, topRevConfirm ? "TOP REV " + str.tostring(topRevScore, "#.0") : botRevConfirm ? "BOT REV " + str.tostring(botRevScore, "#.0") : divConfirm ? "+Div " + str.tostring(posDivCount) : negativeDivergence ? "-Div " + str.tostring(negDivCount) : trendBreakUp ? "TBU" : trendBreakDown ? "TBD" : "Neutral", text_color=color.white, bgcolor=topRevConfirm ? color.new(color.purple, 0) : botRevConfirm ? color.new(color.aqua, 0) : divConfirm ? color.new(color.green, 12) : negativeDivergence ? color.new(color.red, 15) : trendBreakUp ? color.new(color.green, 10) : trendBreakDown ? color.new(color.red, 10) : color.new(color.gray, 30))

    table.cell(dash, 0, 7, "Risk", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 7, riskTxt, text_color=color.white, bgcolor=riskBg)
    table.cell(dash, 2, 7, "RVol", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 3, 7, str.tostring(rvolPct, "#.0") + "%", text_color=color.white, bgcolor=rvolPct >= rvolNeed ? color.new(color.green, 10) : color.new(color.orange, 20))

    table.cell(dash, 0, 8, "Plan", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 8, inTrade ? "SL " + str.tostring(activeSL, format.mintick) : "SL " + str.tostring(candidateSL, format.mintick), text_color=color.white, bgcolor=color.new(color.red, 20))
    table.cell(dash, 2, 8, inTrade ? "TP2 " + str.tostring(activeTP2, format.mintick) : "TP2 " + str.tostring(candidateTP2, format.mintick), text_color=color.white, bgcolor=color.new(color.green, 20))
    table.cell(dash, 3, 8, trailMode, text_color=color.white, bgcolor=color.new(color.black, 0))

//====================================================================
// 15. ALERTS
//====================================================================

groupAlert = "15. Alerts"
enableDynamicAlerts = input.bool(true, "Enable Dynamic JSON Alerts", group=groupAlert)

f_json(string sig) =>
    '{"system":"GS Master","version":"3.1","signal":"' + sig + '","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"grade":"' + tradeGrade + '","confluence":' + str.tostring(confluencePct, "#.0") + ',"layers":"' + str.tostring(passedLayers) + '/' + str.tostring(activeLayers) + '","xgs":' + str.tostring(xgsScore, "#.0") + ',"dts":' + str.tostring(dtsScore, "#.0") + ',"rlt":"' + (rltBull ? "LEADER" : rltWeak ? "WEAK" : "NEUTRAL") + '","phase":"' + phaseName + '","risk":"' + (operatorTrap ? "TRAP" : overextended ? "STRETCH" : distHidden ? "DISTRIBUTION" : divRisk ? "DIV_RISK" : "OK") + '","entry":' + str.tostring(inTrade ? activeEntry : close) + ',"sl":' + str.tostring(inTrade ? activeSL : candidateSL) + ',"tp1":' + str.tostring(inTrade ? activeTP1 : candidateTP1) + ',"tp2":' + str.tostring(inTrade ? activeTP2 : candidateTP2) + '}'

if enableDynamicAlerts and buyBEvent
    alert(f_json("B"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and buyAEvent
    alert(f_json("A"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and buyAPlusEvent
    alert(f_json("A+"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and buyRevEvent
    alert(f_json("REV_TRADE"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and botRevConfirmEvent
    alert(f_json("BOTTOM_REVERSAL"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and topRevConfirmEvent
    alert(f_json("TOP_REVERSAL"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and aUpgradeEvent
    alert(f_json("A_UPGRADE"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and warnEvent
    alert(f_json("WARN"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and exitEvent
    alert(f_json("EXIT"), alert.freq_once_per_bar_close)

alertcondition(buyBEvent, "GS Master B", "GS Master B on {{ticker}} @ {{close}}")
alertcondition(buyAEvent, "GS Master A", "GS Master A on {{ticker}} @ {{close}}")
alertcondition(buyAPlusEvent, "GS Master A+", "GS Master A+ on {{ticker}} @ {{close}}")
alertcondition(buyRevEvent, "GS Master REV Trade", "GS Master REV trade on {{ticker}} @ {{close}}")
alertcondition(botRevConfirmEvent, "GS Master Bottom Reversal", "GS Master bottom reversal confirmed on {{ticker}} @ {{close}}")
alertcondition(botRevWatchEvent, "GS Master Bottom Reversal Watch", "GS Master bottom reversal watch on {{ticker}} @ {{close}}")
alertcondition(topRevConfirmEvent, "GS Master Top Reversal", "GS Master top reversal confirmed on {{ticker}} @ {{close}}")
alertcondition(topRevWatchEvent, "GS Master Top Reversal Watch", "GS Master top reversal watch on {{ticker}} @ {{close}}")
alertcondition(trendBreakUp, "GS Master Trend Break Up", "Trend break up on {{ticker}} @ {{close}}")
alertcondition(trendBreakDown, "GS Master Trend Break Down", "Trend break down on {{ticker}} @ {{close}}")
alertcondition(aUpgradeEvent, "GS Master A Upgrade", "GS Master A upgrade on {{ticker}} @ {{close}}")
alertcondition(warnEvent, "GS Master Warn", "GS Master warning on {{ticker}} @ {{close}}")
alertcondition(exitEvent, "GS Master Exit", "GS Master exit on {{ticker}} @ {{close}}")
alertcondition(positiveDivergence, "GS Master Positive Divergence", "Positive divergence on {{ticker}} @ {{close}}")
alertcondition(negativeDivergence, "GS Master Negative Divergence", "Negative divergence on {{ticker}} @ {{close}}")
alertcondition(smcBullEvent, "GS Master Bullish SMC Event", "Bullish SMC event on {{ticker}} @ {{close}}")
alertcondition(smcBearEvent, "GS Master Bearish SMC Event", "Bearish SMC event on {{ticker}} @ {{close}}")
alertcondition(newBullOB, "GS Master Bullish OB", "Bullish order block detected on {{ticker}}")
alertcondition(newBearOB, "GS Master Bearish OB", "Bearish order block detected on {{ticker}}")
````
