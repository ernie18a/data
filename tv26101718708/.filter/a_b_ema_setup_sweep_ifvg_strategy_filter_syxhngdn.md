# A+ / B+ EMA Setup - Sweep IFVG Strategy Filter

- url: https://www.tradingview.com/script/SyXhnGdN-A-B-EMA-Setup-Sweep-IFVG-Strategy-Filter/
- type: indicator
- pine_id: PUB;9d78e57f882342fb8e1a3f213e7f307d
- version: 8.0

## Description

A+ / B+ Institutional Strategy Filter

A smart-money trade filtering indicator designed to work with the EMA + Liquidity Sweeps + IFVG system.

It analyzes market structure, higher-timeframe trend, liquidity sweeps, momentum (displacement), IFVGs, and retests to score trade quality and highlight only higher-probability opportunities.

Instead of generating random signals, it filters setups using multiple institutional conditions and classifies them as:

A+ Signals → high-confidence, high-probability setups
b+ Signals → decent setups with fewer confirmations

Built to help traders:

align with higher timeframe direction (4H → 1H → 15M)
avoid low-quality trades and chasing moves
identify cleaner entry opportunities during market sessions

In short:

A decision engine that filters market noise and highlights higher-quality institutional trade setups.

## Source Code

````pine
//@version=6
indicator("Sweep IFVG BOS Fib Directive Signal Engine PRO A+ Grade", overlay=true, max_labels_count=500, max_lines_count=500)

//====================
// Inputs - Recommended Defaults Baked In
//====================
emaFastLen = input.int(13, "EMA Fast")
emaMidLen  = input.int(21, "EMA Mid")
emaSlowLen = input.int(34, "EMA Slow")

tfHTF = input.timeframe("240", "HTF Bias TF")
tfMTF = input.timeframe("60", "MTF Confirmation TF")

sweepLen = input.int(5, "Sweep Length")
sweepValidBars = input.int(15, "Sweep Valid Bars")

bosLen = input.int(10, "BOS Structure Length")
bosValidBars = input.int(30, "BOS Valid Bars")

internalLen = input.int(3, "Internal Shift Length")
internalValidBars = input.int(15, "Internal Shift Valid Bars")

atrLen = input.int(14, "ATR Length")
dispMult = input.float(0.6, "Momentum Body x ATR", step=0.1)
momentumValidBars = input.int(8, "Momentum Valid Bars")

useMomentumConfirm = input.bool(true, "Use Momentum Confirmation", group="Momentum / Divergence")
momentumSlopeBars = input.int(3, "EMA Momentum Slope Bars", minval=1, maxval=20, group="Momentum / Divergence")
momentumWeakAtrMult = input.float(0.35, "Weak Momentum Body x ATR", minval=0.1, step=0.05, group="Momentum / Divergence")

useDivergenceWarning = input.bool(true, "Use Divergence Warning", group="Momentum / Divergence")
divPivotLen = input.int(5, "Divergence Pivot Length", minval=2, maxval=20, group="Momentum / Divergence")
divValidBars = input.int(25, "Divergence Valid Bars", minval=5, maxval=100, group="Momentum / Divergence")

//====================
// Market Health / Technical Confluence
// Confirmation layer only: boosts/downgrades A+/probability, but does not create trades alone.
//====================
useMarketHealth = input.bool(true, "Use Market Health Matrix", group="Market Health Matrix")
matrixTf = input.timeframe("60", "Matrix Confirmation TF", group="Market Health Matrix")
matrixAlignedBoost = input.int(6, "Aligned Matrix Score Boost", minval=0, maxval=15, group="Market Health Matrix")
matrixOppositePenalty = input.int(8, "Opposite Matrix Penalty", minval=0, maxval=20, group="Market Health Matrix")
techStrongBoost = input.int(4, "Strong Tech Confluence Boost", minval=0, maxval=10, group="Market Health Matrix")
techWeakPenalty = input.int(3, "Weak Tech Confluence Penalty", minval=0, maxval=10, group="Market Health Matrix")
requireTechForAPlusReady = input.bool(true, "Require Matrix Support For A+ Ready", group="Market Health Matrix")
matrixMinScoreForSupport = input.int(60, "Matrix Support Threshold %", minval=50, maxval=90, group="Market Health Matrix")

ifvgAtrFilter = input.float(0.6, "IFVG ATR Filter", step=0.1)
ifvgValidBars = input.int(20, "IFVG Valid Bars")

useFibPullback = input.bool(true, "Use Fib Pullback Filter")
fibValidBars = input.int(20, "Fib Pullback Valid Bars")

avoidChase = input.bool(true, "Avoid Chasing Far From EMA13")
maxDistanceAtr = input.float(1.5, "Max Distance From EMA13 x ATR", step=0.1)

scalpProb = input.int(60, "Scalp Probability", minval=50, maxval=100)
formingProb = input.int(72, "Forming Probability", minval=50, maxval=100)
readyProb = input.int(78, "Ready Probability", minval=50, maxval=100)
nowProb = input.int(85, "Now Probability", minval=50, maxval=100)

//====================
// Final Execution Filter
// Keeps BUY NOW / SELL NOW high quality without making B+/A- alerts disappear.
//====================
useFinalIfvgCisdFilter = input.bool(true, "Require IFVG or CISD For BUY NOW/SELL NOW", group="Final Execution Filter")
useInternalCisd = input.bool(true, "Use Internal CISD Proxy", group="Final Execution Filter")
cisdValidBars = input.int(20, "CISD Valid Bars", minval=1, maxval=100, group="Final Execution Filter")
allowMatrixMomentumConfirm = input.bool(true, "Allow Matrix To Support Momentum", group="Final Execution Filter")
finalEdge = input.int(15, "Final Prob Edge %", minval=5, maxval=30, group="Final Execution Filter")

//====================
// A+ Alert Engine - Recommended Defaults
//====================
useAPlusEngine = input.bool(true, "Use A+ 80/100 Alert Engine", group="A+ Alert Engine")
aPlusFormingScore = input.int(80, "A+ Forming Alert Score", minval=50, maxval=100, group="A+ Alert Engine")
aPlusReadyScore = input.int(100, "A+ Ready Alert Score", minval=80, maxval=100, group="A+ Alert Engine")
requireSweepForAPlus = input.bool(true, "Require Sweep For A+ Score", group="A+ Alert Engine")
retestValidBars = input.int(10, "Retest Valid Bars After EMA13 Reclaim", minval=1, maxval=50, group="A+ Alert Engine")
showAPlusLabels = input.bool(true, "Show A+ Labels", group="A+ Alert Engine")

sessionTz = input.string("America/New_York", "Session Timezone")

showTable = input.bool(true, "Show Signal Table")
tableTextSizeInput = input.string("Tiny", "Table Text Size", options=["Tiny","Small"], group="Table")
tableBorderWidth = input.int(0, "Table Border Width", minval=0, maxval=2, group="Table")
tablePosInput = input.string("Lower Right", "Table Position", options=["Upper Left","Upper Right","Lower Left","Lower Right","Lower Center"])

tablePos = switch tablePosInput
    "Upper Left" => position.top_left
    "Upper Right" => position.top_right
    "Lower Left" => position.bottom_left
    "Lower Right" => position.bottom_right
    "Lower Center" => position.bottom_center

tableTxtSize = switch tableTextSizeInput
    "Small" => size.small
    => size.tiny

//====================
// EMA / HTF Bias
//====================
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

atr = ta.atr(atrLen)
body = math.abs(close - open)

bullLocal = close > emaFast and emaFast > emaMid and emaMid > emaSlow
bearLocal = close < emaFast and emaFast < emaMid and emaMid < emaSlow

htfClose = request.security(syminfo.tickerid, tfHTF, close)
htfFast  = request.security(syminfo.tickerid, tfHTF, ta.ema(close, emaFastLen))
htfMid   = request.security(syminfo.tickerid, tfHTF, ta.ema(close, emaMidLen))
htfSlow  = request.security(syminfo.tickerid, tfHTF, ta.ema(close, emaSlowLen))

mtfClose = request.security(syminfo.tickerid, tfMTF, close)
mtfFast  = request.security(syminfo.tickerid, tfMTF, ta.ema(close, emaFastLen))
mtfMid   = request.security(syminfo.tickerid, tfMTF, ta.ema(close, emaMidLen))
mtfSlow  = request.security(syminfo.tickerid, tfMTF, ta.ema(close, emaSlowLen))

bullHTF = htfClose > htfFast and htfFast > htfMid and htfMid > htfSlow
bearHTF = htfClose < htfFast and htfFast < htfMid and htfMid < htfSlow

bullMTF = mtfClose > mtfFast and mtfFast > mtfMid and mtfMid > mtfSlow
bearMTF = mtfClose < mtfFast and mtfFast < mtfMid and mtfMid < mtfSlow

htfBiasText =
     bullHTF and bullMTF and bullLocal ? "FULL BULL" :
     bearHTF and bearMTF and bearLocal ? "FULL BEAR" :
     bullHTF and bullMTF and bearLocal ? "COUNTER BEAR" :
     bearHTF and bearMTF and bullLocal ? "COUNTER BULL" :
     "MIXED"

trendText = bullLocal ? "Bull" : bearLocal ? "Bear" : "Mixed"

//====================
// EMA State
//====================
emaSpread = math.abs(emaFast - emaSlow)
emaSpreadPrev = math.abs(emaFast[3] - emaSlow[3])

compression = emaSpread < atr * 0.35
expansionUp = bullLocal and emaSpread > emaSpreadPrev
expansionDown = bearLocal and emaSpread > emaSpreadPrev
crossing = not bullLocal and not bearLocal

emaStateText =
     compression ? "Compression" :
     expansionUp ? "Expansion Up" :
     expansionDown ? "Expansion Down" :
     crossing ? "Crossing" :
     "Neutral"

//====================
// Sweeps
//====================
phSweep = ta.pivothigh(sweepLen, sweepLen)
plSweep = ta.pivotlow(sweepLen, sweepLen)

var float lastSweepHigh = na
var float lastSweepLow = na

if not na(phSweep)
    lastSweepHigh := phSweep

if not na(plSweep)
    lastSweepLow := plSweep

bullSweep = not na(lastSweepLow) and low < lastSweepLow and close > lastSweepLow
bearSweep = not na(lastSweepHigh) and high > lastSweepHigh and close < lastSweepHigh

bullSweepRecent = ta.barssince(bullSweep) <= sweepValidBars
bearSweepRecent = ta.barssince(bearSweep) <= sweepValidBars

sweepText = bullSweepRecent ? "Bull Sweep" : bearSweepRecent ? "Bear Sweep" : "None"

//====================
// Internal CISD Proxy
// BCISD = sell-side sweep followed by close above the sweep candle high.
// SCISD = buy-side sweep followed by close below the sweep candle low.
// This lets the Directive Engine use CISD logic internally; your EMA Sweeps IFVG ZL still handles chart lines.
//====================
var bool bullCisdArmed = false
var bool bearCisdArmed = false
var float bullCisdLevel = na
var float bearCisdLevel = na
var int bullCisdArmBar = na
var int bearCisdArmBar = na

if useInternalCisd and bullSweep
    bullCisdArmed := true
    bullCisdLevel := high
    bullCisdArmBar := bar_index
    bearCisdArmed := false

if useInternalCisd and bearSweep
    bearCisdArmed := true
    bearCisdLevel := low
    bearCisdArmBar := bar_index
    bullCisdArmed := false

bullCisd = useInternalCisd and bullCisdArmed and not na(bullCisdLevel) and bar_index > bullCisdArmBar and bar_index - bullCisdArmBar <= cisdValidBars and close > bullCisdLevel
bearCisd = useInternalCisd and bearCisdArmed and not na(bearCisdLevel) and bar_index > bearCisdArmBar and bar_index - bearCisdArmBar <= cisdValidBars and close < bearCisdLevel

if bullCisd
    bullCisdArmed := false

if bearCisd
    bearCisdArmed := false

if useInternalCisd and bullCisdArmed and not na(bullCisdArmBar) and bar_index - bullCisdArmBar > cisdValidBars
    bullCisdArmed := false

if useInternalCisd and bearCisdArmed and not na(bearCisdArmBar) and bar_index - bearCisdArmBar > cisdValidBars
    bearCisdArmed := false

bullCisdRecent = ta.barssince(bullCisd) <= cisdValidBars
bearCisdRecent = ta.barssince(bearCisd) <= cisdValidBars
cisdText = bullCisdRecent ? "BCISD" : bearCisdRecent ? "SCISD" : "None"

//====================
// BOS / CHOCH
//====================
phBos = ta.pivothigh(bosLen, bosLen)
plBos = ta.pivotlow(bosLen, bosLen)

var float lastBosHigh = na
var float lastBosLow = na
var int structureDir = 0

if not na(phBos)
    lastBosHigh := phBos

if not na(plBos)
    lastBosLow := plBos

bullBos = not na(lastBosHigh) and close > lastBosHigh
bearBos = not na(lastBosLow) and close < lastBosLow

bullChoch = bullBos and structureDir == -1
bearChoch = bearBos and structureDir == 1

if bullBos
    structureDir := 1

if bearBos
    structureDir := -1

bullBosRecent = ta.barssince(bullBos) <= bosValidBars
bearBosRecent = ta.barssince(bearBos) <= bosValidBars
bullChochRecent = ta.barssince(bullChoch) <= bosValidBars
bearChochRecent = ta.barssince(bearChoch) <= bosValidBars

bosText = bullBosRecent ? "Bull BOS" : bearBosRecent ? "Bear BOS" : "None"
chochText = bullChochRecent ? "Bull CHOCH" : bearChochRecent ? "Bear CHOCH" : "None"

//====================
// Fib Zone
//====================
var int bosDir = 0
var float fibHigh = na
var float fibLow = na
var float fib50 = na
var float fib75 = na

if bullBos and not na(lastBosLow)
    bosDir := 1
    fibHigh := close
    fibLow := lastBosLow
    fib50 := fibHigh - (fibHigh - fibLow) * 0.50
    fib75 := fibHigh - (fibHigh - fibLow) * 0.75

if bearBos and not na(lastBosHigh)
    bosDir := -1
    fibLow := close
    fibHigh := lastBosHigh
    fib50 := fibLow + (fibHigh - fibLow) * 0.50
    fib75 := fibLow + (fibHigh - fibLow) * 0.75

inBullFibZone = bosDir == 1 and not na(fib50) and low <= fib50 and high >= fib75
inBearFibZone = bosDir == -1 and not na(fib50) and high >= fib50 and low <= fib75

bullFibRecent = ta.barssince(inBullFibZone) <= fibValidBars
bearFibRecent = ta.barssince(inBearFibZone) <= fibValidBars

fibText = bullFibRecent ? "Bull Zone" : bearFibRecent ? "Bear Zone" : "Neutral"

//====================
// Internal Shift
//====================
phInt = ta.pivothigh(internalLen, internalLen)
plInt = ta.pivotlow(internalLen, internalLen)

var float lastInternalHigh = na
var float lastInternalLow = na

if not na(phInt)
    lastInternalHigh := phInt

if not na(plInt)
    lastInternalLow := plInt

internalBullShift = not na(lastInternalHigh) and close > lastInternalHigh
internalBearShift = not na(lastInternalLow) and close < lastInternalLow

internalBullRecent = ta.barssince(internalBullShift) <= internalValidBars
internalBearRecent = ta.barssince(internalBearShift) <= internalValidBars

//====================
// Momentum
//====================
bullMomentum = close > open and body > atr * dispMult
bearMomentum = close < open and body > atr * dispMult

bullMomentumRecent = ta.barssince(bullMomentum) <= momentumValidBars
bearMomentumRecent = ta.barssince(bearMomentum) <= momentumValidBars

emaSlopeUp = emaFast > emaFast[momentumSlopeBars]
emaSlopeDown = emaFast < emaFast[momentumSlopeBars]

bullMomentumConfirmed = useMomentumConfirm and bullMomentumRecent and emaSlopeUp and close > emaFast
bearMomentumConfirmed = useMomentumConfirm and bearMomentumRecent and emaSlopeDown and close < emaFast

bullMomentumWeak = useMomentumConfirm and bullLocal and not bullMomentumConfirmed and body < atr * momentumWeakAtrMult
bearMomentumWeak = useMomentumConfirm and bearLocal and not bearMomentumConfirmed and body < atr * momentumWeakAtrMult

momentumText =
     bullMomentumConfirmed ? "Bull Confirmed" :
     bearMomentumConfirmed ? "Bear Confirmed" :
     bullMomentumWeak ? "Bull Weak" :
     bearMomentumWeak ? "Bear Weak" :
     "Neutral"

//====================
// IFVG
//====================
threshold = atr * ifvgAtrFilter

bullFvg = low > high[2] and (low - high[2]) > threshold
bearFvg = high < low[2] and (low[2] - high) > threshold

var float bullFvgTop = na
var float bullFvgBottom = na
var bool bullFvgActive = false

var float bearFvgTop = na
var float bearFvgBottom = na
var bool bearFvgActive = false

if bullFvg
    bullFvgTop := low
    bullFvgBottom := high[2]
    bullFvgActive := true

if bearFvg
    bearFvgTop := low[2]
    bearFvgBottom := high
    bearFvgActive := true

bullIfvg = bearFvgActive and close > bearFvgTop
bearIfvg = bullFvgActive and close < bullFvgBottom

if bullIfvg
    bearFvgActive := false

if bearIfvg
    bullFvgActive := false

bullIfvgRecent = ta.barssince(bullIfvg) <= ifvgValidBars
bearIfvgRecent = ta.barssince(bearIfvg) <= ifvgValidBars

//====================
// Acceptance / Rejection
//====================
acceptedAbove = close > emaFast and close[1] > emaFast and close[2] > emaFast
acceptedBelow = close < emaFast and close[1] < emaFast and close[2] < emaFast

rejectingHigher = high > emaFast and close < emaFast and (high - math.max(open, close)) > atr * 0.25
rejectingLower = low < emaFast and close > emaFast and (math.min(open, close) - low) > atr * 0.25

acceptanceText =
     acceptedAbove ? "Accepted Above" :
     acceptedBelow ? "Accepted Below" :
     rejectingHigher ? "Rejecting Higher" :
     rejectingLower ? "Rejecting Lower" :
     "Neutral"

//====================
// Liquidity Position
//====================
liqLookback = 30
recentHigh = ta.highest(high, liqLookback)
recentLow = ta.lowest(low, liqLookback)

nearBuySide = close >= recentHigh - atr * 0.5
nearSellSide = close <= recentLow + atr * 0.5

liquidityText =
     nearBuySide ? "Near Buy-Side" :
     nearSellSide ? "Near Sell-Side" :
     "Mid-Range"

//====================
// Divergence Warning
//====================
rsiDiv = ta.rsi(close, 14)

pricePH = ta.pivothigh(high, divPivotLen, divPivotLen)
pricePL = ta.pivotlow(low, divPivotLen, divPivotLen)
rsiPH = ta.pivothigh(rsiDiv, divPivotLen, divPivotLen)
rsiPL = ta.pivotlow(rsiDiv, divPivotLen, divPivotLen)

var float prevPriceHigh = na
var float prevRsiHigh = na
var float prevPriceLow = na
var float prevRsiLow = na

bearDivNow = false
bullDivNow = false

if not na(pricePH) and not na(rsiPH)
    bearDivNow := not na(prevPriceHigh) and pricePH > prevPriceHigh and rsiPH < prevRsiHigh
    prevPriceHigh := pricePH
    prevRsiHigh := rsiPH

if not na(pricePL) and not na(rsiPL)
    bullDivNow := not na(prevPriceLow) and pricePL < prevPriceLow and rsiPL > prevRsiLow
    prevPriceLow := pricePL
    prevRsiLow := rsiPL

bullDivRecent = useDivergenceWarning and ta.barssince(bullDivNow) <= divValidBars
bearDivRecent = useDivergenceWarning and ta.barssince(bearDivNow) <= divValidBars

divergenceText =
     bullDivRecent ? "Bull Div Warning" :
     bearDivRecent ? "Bear Div Warning" :
     "None"

divergenceAgainstBuy = bearDivRecent
divergenceAgainstSell = bullDivRecent

//====================
// Session State
//====================
inAsia = not na(time(timeframe.period, "1800-0000", sessionTz))
inLondonSweep = not na(time(timeframe.period, "0200-0300", sessionTz))
inLondonExpansion = not na(time(timeframe.period, "0300-0500", sessionTz))
inNYManip = not na(time(timeframe.period, "0800-0930", sessionTz))
inNYExpansion = not na(time(timeframe.period, "0930-1130", sessionTz))

sessionText =
     inAsia ? "Asia Range" :
     inLondonSweep ? "London Sweep" :
     inLondonExpansion ? "London Expansion" :
     inNYManip ? "NY Manipulation" :
     inNYExpansion ? "NY Expansion" :
     "Dead Zone"

sessionBoost = inLondonExpansion or inNYExpansion ? 5 : inLondonSweep or inNYManip ? 3 : inAsia ? 1 : 0

//====================
// Structure Strength
//====================
bullStructurePts = 0
bullStructurePts += bullBosRecent ? 1 : 0
bullStructurePts += bullChochRecent ? 1 : 0
bullStructurePts += internalBullRecent ? 1 : 0
bullStructurePts += bullLocal ? 1 : 0
bullStructurePts += bullMomentumRecent ? 1 : 0

bearStructurePts = 0
bearStructurePts += bearBosRecent ? 1 : 0
bearStructurePts += bearChochRecent ? 1 : 0
bearStructurePts += internalBearRecent ? 1 : 0
bearStructurePts += bearLocal ? 1 : 0
bearStructurePts += bearMomentumRecent ? 1 : 0

structureText =
     bullStructurePts >= 4 ? "Strong Bull" :
     bearStructurePts >= 4 ? "Strong Bear" :
     bullStructurePts >= 2 ? "Weak Bull" :
     bearStructurePts >= 2 ? "Weak Bear" :
     "Neutral"

//====================
// Market Health / Technical Confluence
// Compact version of your friend's large matrix.
//====================
f_matrixPack() =>
    _rsi = ta.rsi(close, 14)
    [_macd, _sig, _hist] = ta.macd(close, 12, 26, 9)
    [_diP, _diM, _adx] = ta.dmi(14, 14)
    _mfi = ta.mfi(hlc3, 14)
    _obvUp = ta.obv > ta.obv[1]
    [_st, _stDir] = ta.supertrend(3.0, 10)
    _ema9 = ta.ema(close, 9)
    _ema21 = ta.ema(close, 21)
    _ema50 = ta.ema(close, 50)
    _ema200 = ta.ema(close, 200)
    _bull = 0
    _bear = 0
    _bull += _ema9 > _ema21 ? 1 : 0
    _bear += _ema9 < _ema21 ? 1 : 0
    _bull += _ema21 > _ema50 ? 1 : 0
    _bear += _ema21 < _ema50 ? 1 : 0
    _bull += _ema50 > _ema200 ? 1 : 0
    _bear += _ema50 < _ema200 ? 1 : 0
    _bull += _rsi > 50 ? 1 : 0
    _bear += _rsi < 50 ? 1 : 0
    _bull += _macd > _sig ? 1 : 0
    _bear += _macd < _sig ? 1 : 0
    _bull += _hist > 0 ? 1 : 0
    _bear += _hist < 0 ? 1 : 0
    _bull += _diP > _diM ? 1 : 0
    _bear += _diM > _diP ? 1 : 0
    _bull += _mfi > 50 ? 1 : 0
    _bear += _mfi < 50 ? 1 : 0
    _bull += _obvUp ? 1 : 0
    _bear += not _obvUp ? 1 : 0
    _bull += _stDir < 0 ? 1 : 0
    _bear += _stDir > 0 ? 1 : 0
    [_bull, _bear, _adx]

[matrixBullRaw, matrixBearRaw, matrixAdx] = request.security(syminfo.tickerid, matrixTf, f_matrixPack())

matrixTotal = math.max(matrixBullRaw + matrixBearRaw, 1)
matrixBullPct = math.round(matrixBullRaw / matrixTotal * 100)
matrixBearPct = math.round(matrixBearRaw / matrixTotal * 100)

matrixBullSupport = useMarketHealth and matrixBullPct >= matrixMinScoreForSupport
matrixBearSupport = useMarketHealth and matrixBearPct >= matrixMinScoreForSupport
matrixStrongTrend = useMarketHealth and matrixAdx >= 20
matrixWeakTrend = useMarketHealth and matrixAdx < 18

matrixText =
     matrixBullSupport ? "Bull " + str.tostring(matrixBullPct) + "%" :
     matrixBearSupport ? "Bear " + str.tostring(matrixBearPct) + "%" :
     "Mixed"

techText =
     matrixStrongTrend and (matrixBullSupport or matrixBearSupport) ? "Strong" :
     matrixWeakTrend ? "Weak" :
     "Neutral"

//====================
// Probability Engine
//====================
bullPts = 0
bullPts += bullLocal ? 12 : 0
bullPts += bullHTF ? 12 : 0
bullPts += bullMTF ? 12 : 0
bullPts += bullSweepRecent ? 8 : 0
bullPts += bullBosRecent ? 10 : 0
bullPts += bullChochRecent ? 8 : 0
bullPts += internalBullRecent ? 8 : 0
bullPts += bullMomentumRecent ? 10 : 0
bullPts += bullMomentumConfirmed ? 5 : 0
bullPts -= bullMomentumWeak ? 4 : 0
bullPts -= divergenceAgainstBuy ? 6 : 0
bullPts += bullIfvgRecent ? 8 : 0
bullPts += bullFibRecent ? 5 : 0
bullPts += acceptedAbove ? 10 : 0
bullPts += rejectingLower ? 5 : 0
bullPts += expansionUp ? 8 : compression ? 2 : 0
bullPts += nearSellSide ? 5 : 0
bullPts += sessionBoost
bullPts += matrixBullSupport ? matrixAlignedBoost : 0
bullPts -= matrixBearSupport ? matrixOppositePenalty : 0
bullPts += matrixBullSupport and matrixStrongTrend ? techStrongBoost : 0
bullPts -= matrixWeakTrend ? techWeakPenalty : 0

bearPts = 0
bearPts += bearLocal ? 12 : 0
bearPts += bearHTF ? 12 : 0
bearPts += bearMTF ? 12 : 0
bearPts += bearSweepRecent ? 8 : 0
bearPts += bearBosRecent ? 10 : 0
bearPts += bearChochRecent ? 8 : 0
bearPts += internalBearRecent ? 8 : 0
bearPts += bearMomentumRecent ? 10 : 0
bearPts += bearMomentumConfirmed ? 5 : 0
bearPts -= bearMomentumWeak ? 4 : 0
bearPts -= divergenceAgainstSell ? 6 : 0
bearPts += bearIfvgRecent ? 8 : 0
bearPts += bearFibRecent ? 5 : 0
bearPts += acceptedBelow ? 10 : 0
bearPts += rejectingHigher ? 5 : 0
bearPts += expansionDown ? 8 : compression ? 2 : 0
bearPts += nearBuySide ? 5 : 0
bearPts += sessionBoost
bearPts += matrixBearSupport ? matrixAlignedBoost : 0
bearPts -= matrixBullSupport ? matrixOppositePenalty : 0
bearPts += matrixBearSupport and matrixStrongTrend ? techStrongBoost : 0
bearPts -= matrixWeakTrend ? techWeakPenalty : 0

bullPts := math.max(bullPts, 0)
bearPts := math.max(bearPts, 0)

totalPts = math.max(bullPts + bearPts, 1)
bullProb = math.round(bullPts / totalPts * 100)
bearProb = math.round(bearPts / totalPts * 100)

distanceOk = not avoidChase or math.abs(close - emaFast) <= atr * maxDistanceAtr

//====================
// A+ 80/100 Alert Engine
// This is designed for the workflow:
// Sweep -> Displacement -> EMA13 reclaim/rejection -> Retest -> Manual Entry
// Important: Sweep is mandatory by default. If no sweep exists, score is capped at 70.
//====================
bullEmaReclaimNow = close > emaFast and close[1] <= emaFast[1]
bearEmaRejectNow = close < emaFast and close[1] >= emaFast[1]

bullEmaReclaimRecent = ta.barssince(bullEmaReclaimNow) <= retestValidBars
bearEmaRejectRecent = ta.barssince(bearEmaRejectNow) <= retestValidBars

bullRetestHeld = bullEmaReclaimRecent and low <= emaFast and close > emaFast and close >= open
bearRetestHeld = bearEmaRejectRecent and high >= emaFast and close < emaFast and close <= open

bullAPlusRaw = 0
bullAPlusRaw += bullMTF ? 20 : 0
bullAPlusRaw += bullSweepRecent ? 20 : 0
bullAPlusRaw += (bullBosRecent or bullChochRecent or internalBullRecent) ? 15 : 0
bullAPlusRaw += (expansionUp or bullMomentumConfirmed) ? 15 : 0
bullAPlusRaw += (acceptedAbove or rejectingLower) ? 10 : 0
bullAPlusRaw += (bullMomentumRecent or bullMomentumConfirmed) ? 10 : 0
bullAPlusRaw += bullRetestHeld ? 10 : 0
bullAPlusRaw += matrixBullSupport ? matrixAlignedBoost : 0
bullAPlusRaw += matrixBullSupport and matrixStrongTrend ? techStrongBoost : 0
bullAPlusRaw -= matrixBearSupport ? matrixOppositePenalty : 0
bullAPlusRaw -= matrixWeakTrend ? techWeakPenalty : 0

bearAPlusRaw = 0
bearAPlusRaw += bearMTF ? 20 : 0
bearAPlusRaw += bearSweepRecent ? 20 : 0
bearAPlusRaw += (bearBosRecent or bearChochRecent or internalBearRecent) ? 15 : 0
bearAPlusRaw += (expansionDown or bearMomentumConfirmed) ? 15 : 0
bearAPlusRaw += (acceptedBelow or rejectingHigher) ? 10 : 0
bearAPlusRaw += (bearMomentumRecent or bearMomentumConfirmed) ? 10 : 0
bearAPlusRaw += bearRetestHeld ? 10 : 0
bearAPlusRaw += matrixBearSupport ? matrixAlignedBoost : 0
bearAPlusRaw += matrixBearSupport and matrixStrongTrend ? techStrongBoost : 0
bearAPlusRaw -= matrixBullSupport ? matrixOppositePenalty : 0
bearAPlusRaw -= matrixWeakTrend ? techWeakPenalty : 0

bullAPlusRaw := math.max(0, math.min(100, bullAPlusRaw))
bearAPlusRaw := math.max(0, math.min(100, bearAPlusRaw))

// Cap score if the required liquidity sweep is missing.
// This prevents 85% bullish/bearish probability from becoming an A+ alert without a sweep.
bullAPlusScore = requireSweepForAPlus and not bullSweepRecent ? math.min(bullAPlusRaw, 70) : bullAPlusRaw
bearAPlusScore = requireSweepForAPlus and not bearSweepRecent ? math.min(bearAPlusRaw, 70) : bearAPlusRaw

// Extra safety caps.
bullAPlusScore := divergenceAgainstBuy ? math.min(bullAPlusScore, 85) : bullAPlusScore
bearAPlusScore := divergenceAgainstSell ? math.min(bearAPlusScore, 85) : bearAPlusScore
bullAPlusScore := not distanceOk ? math.min(bullAPlusScore, 85) : bullAPlusScore
bearAPlusScore := not distanceOk ? math.min(bearAPlusScore, 85) : bearAPlusScore

bullAPlusForming = useAPlusEngine and bullAPlusScore >= aPlusFormingScore and bullAPlusScore < aPlusReadyScore and bullAPlusScore > bearAPlusScore and not bullRetestHeld
bearAPlusForming = useAPlusEngine and bearAPlusScore >= aPlusFormingScore and bearAPlusScore < aPlusReadyScore and bearAPlusScore > bullAPlusScore and not bearRetestHeld

bullAPlusReady = useAPlusEngine and bullAPlusScore >= aPlusReadyScore and bullAPlusScore > bearAPlusScore and bullRetestHeld and (not requireTechForAPlusReady or matrixBullSupport)
bearAPlusReady = useAPlusEngine and bearAPlusScore >= aPlusReadyScore and bearAPlusScore > bullAPlusScore and bearRetestHeld and (not requireTechForAPlusReady or matrixBearSupport)

newBullAPlusForming = bullAPlusForming and not bullAPlusForming[1]
newBearAPlusForming = bearAPlusForming and not bearAPlusForming[1]
newBullAPlusReady = bullAPlusReady and not bullAPlusReady[1]
newBearAPlusReady = bearAPlusReady and not bearAPlusReady[1]

aPlusStateText =
     bullAPlusReady ? "A+ BUY READY" :
     bearAPlusReady ? "A+ SELL READY" :
     bullAPlusForming ? "80% BUY FORMING" :
     bearAPlusForming ? "80% SELL FORMING" :
     "WAIT"

//====================
// Signal Tiers
//====================
buyScalp = bullProb >= scalpProb and bullProb < formingProb and not expansionDown and not acceptedBelow
sellScalp = bearProb >= scalpProb and bearProb < formingProb and not expansionUp and not acceptedAbove

buyForming = bullProb >= formingProb and bullProb < readyProb and not expansionDown
sellForming = bearProb >= formingProb and bearProb < readyProb and not expansionUp

buyReady = bullProb >= readyProb and bullProb < nowProb and (bullBosRecent or bullChochRecent or internalBullRecent) and not acceptedBelow
sellReady = bearProb >= readyProb and bearProb < nowProb and (bearBosRecent or bearChochRecent or internalBearRecent) and not acceptedAbove

bullFinalMomentumOk = bullMomentumConfirmed or (allowMatrixMomentumConfirm and bullMomentumRecent and matrixBullSupport)
bearFinalMomentumOk = bearMomentumConfirmed or (allowMatrixMomentumConfirm and bearMomentumRecent and matrixBearSupport)

bullFinalShiftOk = not useFinalIfvgCisdFilter or bullIfvgRecent or bullCisdRecent
bearFinalShiftOk = not useFinalIfvgCisdFilter or bearIfvgRecent or bearCisdRecent

// Updated BUY NOW / SELL NOW logic:
// Prob + Momentum + Acceptance + BOS + (IFVG or CISD).
// Matrix can support momentum so good B+/A- trades are not filtered too aggressively.
buyNow = bullProb >= nowProb and distanceOk and acceptedAbove and bullBosRecent and bullFinalMomentumOk and bullFinalShiftOk and not divergenceAgainstBuy and bullProb > bearProb + finalEdge
sellNow = bearProb >= nowProb and distanceOk and acceptedBelow and bearBosRecent and bearFinalMomentumOk and bearFinalShiftOk and not divergenceAgainstSell and bearProb > bullProb + finalEdge

//====================
// Setup Grade
// Grade = quality of setup. Final = what to do now.
//====================
bullBPlus = not bullAPlusReady and not bullAPlusForming and bullProb >= 70 and bullProb > bearProb + 10 and (bullBosRecent or bullChochRecent or internalBullRecent) and acceptedAbove and (bullMomentumConfirmed or expansionUp or matrixBullSupport) and not divergenceAgainstBuy
bearBPlus = not bearAPlusReady and not bearAPlusForming and bearProb >= 70 and bearProb > bullProb + 10 and (bearBosRecent or bearChochRecent or internalBearRecent) and acceptedBelow and (bearMomentumConfirmed or expansionDown or matrixBearSupport) and not divergenceAgainstSell

bullBMinus = not bullBPlus and not bullAPlusReady and not bullAPlusForming and bullProb >= 60 and bullProb > bearProb and not acceptedBelow and not divergenceAgainstBuy
bearBMinus = not bearBPlus and not bearAPlusReady and not bearAPlusForming and bearProb >= 60 and bearProb > bullProb and not acceptedAbove and not divergenceAgainstSell

setupGradeText =
     bullAPlusReady or bearAPlusReady ? "A+" :
     bullAPlusForming or bearAPlusForming ? "A-" :
     bullBPlus or bearBPlus ? "B+" :
     bullBMinus or bearBMinus ? "B-" :
     "WAIT"

setupGradeBg =
     bullAPlusReady or bullAPlusForming or bullBPlus or bullBMinus ? color.green :
     bearAPlusReady or bearAPlusForming or bearBPlus or bearBMinus ? color.red :
     color.gray

stateText =
     buyNow ? "BUY NOW" :
     sellNow ? "SELL NOW" :
     bullAPlusForming and not bullFinalShiftOk ? "LOOK FOR BULL IFVG" :
     bearAPlusForming and not bearFinalShiftOk ? "LOOK FOR BEAR IFVG" :
     bullAPlusForming ? "LOOK FOR RETEST" :
     bearAPlusForming ? "LOOK FOR RETEST" :
     bullBPlus ? "BULL WATCH" :
     bearBPlus ? "BEAR WATCH" :
     buyReady ? "BUY READY" :
     sellReady ? "SELL READY" :
     buyForming ? "BUY FORMING" :
     sellForming ? "SELL FORMING" :
     buyScalp ? "BUY SCALP" :
     sellScalp ? "SELL SCALP" :
     "WAIT"

newBuySignal = (buyScalp or buyForming or buyReady or buyNow) and not (buyScalp[1] or buyForming[1] or buyReady[1] or buyNow[1])
newSellSignal = (sellScalp or sellForming or sellReady or sellNow) and not (sellScalp[1] or sellForming[1] or sellReady[1] or sellNow[1])

//====================
// Labels - Compact / Candle-Width Friendly
//====================
plotshape(buyScalp and not buyScalp[1], title="Buy Scalp", text="BS", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)
plotshape(buyForming and not buyForming[1], title="Buy Forming", text="BF", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 60), textcolor=color.white, size=size.tiny)
plotshape(buyReady and not buyReady[1], title="Buy Ready", text="BR", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 45), textcolor=color.white, size=size.tiny)
plotshape(buyNow and not buyNow[1], title="Buy Now", text="BN", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 25), textcolor=color.white, size=size.tiny)

plotshape(sellScalp and not sellScalp[1], title="Sell Scalp", text="SS", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)
plotshape(sellForming and not sellForming[1], title="Sell Forming", text="SF", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 60), textcolor=color.white, size=size.tiny)
plotshape(sellReady and not sellReady[1], title="Sell Ready", text="SR", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 45), textcolor=color.white, size=size.tiny)
plotshape(sellNow and not sellNow[1], title="Sell Now", text="SN", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 25), textcolor=color.white, size=size.tiny)

// A+ labels
plotshape(showAPlusLabels and newBullAPlusForming, title="A+ Buy 80% Forming", text="80%\nBUY", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 10), textcolor=color.white, size=size.tiny)
plotshape(showAPlusLabels and newBearAPlusForming, title="A+ Sell 80% Forming", text="80%\nSELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 10), textcolor=color.white, size=size.tiny)
plotshape(showAPlusLabels and newBullAPlusReady, title="A+ Buy 100% Ready", text="A+\nBUY", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)
plotshape(showAPlusLabels and newBearAPlusReady, title="A+ Sell 100% Ready", text="A+\nSELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), textcolor=color.white, size=size.tiny)

//====================
// Alerts
//====================
alertcondition(newBuySignal, title="BUY SIGNAL", message="BUY signal on {{ticker}} {{interval}}")
alertcondition(newSellSignal, title="SELL SIGNAL", message="SELL signal on {{ticker}} {{interval}}")

// A+ phone alerts.
// Create TradingView alerts using "Any alert() function call" to receive the detailed messages below.
alertcondition(newBullAPlusForming, title="A- BUY 80% FORMING", message="A+ BUY 80% forming on {{ticker}} {{interval}}")
alertcondition(newBearAPlusForming, title="A- SELL 80% FORMING", message="A+ SELL 80% forming on {{ticker}} {{interval}}")
alertcondition(newBullAPlusReady, title="A+ BUY 100% READY", message="A+ BUY 100% ready on {{ticker}} {{interval}}")
alertcondition(newBearAPlusReady, title="A+ SELL 100% READY", message="A+ SELL 100% ready on {{ticker}} {{interval}}")

if newBuySignal
    alert(syminfo.ticker + " " + timeframe.period + " → " + stateText + "\nGrade: " + setupGradeText + "\nBull Prob: " + str.tostring(bullProb) + "%\nMatrix: " + matrixText + "\nTech: " + techText + "\nCISD: " + cisdText + "\nSession: " + sessionText + "\nEMA: " + emaStateText + "\nMomentum: " + momentumText + "\nDivergence: " + divergenceText + "\nAcceptance: " + acceptanceText, alert.freq_once_per_bar_close)

if newSellSignal
    alert(syminfo.ticker + " " + timeframe.period + " → " + stateText + "\nGrade: " + setupGradeText + "\nBear Prob: " + str.tostring(bearProb) + "%\nMatrix: " + matrixText + "\nTech: " + techText + "\nCISD: " + cisdText + "\nSession: " + sessionText + "\nEMA: " + emaStateText + "\nMomentum: " + momentumText + "\nDivergence: " + divergenceText + "\nAcceptance: " + acceptanceText, alert.freq_once_per_bar_close)

if newBullAPlusForming
    alert("🟢 " + syminfo.ticker + " " + timeframe.period + " → A- BUY 80% FORMING\nScore: " + str.tostring(bullAPlusScore) + "/100\nCome to chart. Wait for EMA13 retest/reclaim completion.\nSweep: " + sweepText + "\nBOS/CHOCH: " + bosText + " / " + chochText + "\nEMA: " + emaStateText + "\nAcceptance: " + acceptanceText + "\nMomentum: " + momentumText + "\nMatrix: " + matrixText + "\nTech: " + techText + "\nSession: " + sessionText, alert.freq_once_per_bar_close)

if newBearAPlusForming
    alert("🔴 " + syminfo.ticker + " " + timeframe.period + " → A- SELL 80% FORMING\nScore: " + str.tostring(bearAPlusScore) + "/100\nCome to chart. Wait for EMA13 retest/rejection completion.\nSweep: " + sweepText + "\nBOS/CHOCH: " + bosText + " / " + chochText + "\nEMA: " + emaStateText + "\nAcceptance: " + acceptanceText + "\nMomentum: " + momentumText + "\nMatrix: " + matrixText + "\nTech: " + techText + "\nSession: " + sessionText, alert.freq_once_per_bar_close)

if newBullAPlusReady
    alert("✅ " + syminfo.ticker + " " + timeframe.period + " → A+ BUY 100% READY\nScore: " + str.tostring(bullAPlusScore) + "/100\nRetest held. Manual execution only if SL below sweep low is clean.\nSweep: " + sweepText + "\nEMA: " + emaStateText + "\nAcceptance: " + acceptanceText + "\nMatrix: " + matrixText + "\nTech: " + techText + "\nSession: " + sessionText, alert.freq_once_per_bar_close)

if newBearAPlusReady
    alert("✅ " + syminfo.ticker + " " + timeframe.period + " → A+ SELL 100% READY\nScore: " + str.tostring(bearAPlusScore) + "/100\nRetest held. Manual execution only if SL above sweep high is clean.\nSweep: " + sweepText + "\nEMA: " + emaStateText + "\nAcceptance: " + acceptanceText + "\nMatrix: " + matrixText + "\nTech: " + techText + "\nSession: " + sessionText, alert.freq_once_per_bar_close)

//====================
// Table
//====================
// Smallest TradingView table font is size.tiny. To reduce vertical footprint
// without losing fields, Bull/Bear probability and A+ scores are combined.
var table t = table.new(tablePos, 2, 19, border_width=tableBorderWidth)

f_row(_r, _name, _value, _bg) =>
    table.cell(t, 0, _r, _name, bgcolor=color.black, text_color=color.white, text_size=tableTxtSize)
    table.cell(t, 1, _r, _value, bgcolor=_bg, text_color=color.white, text_size=tableTxtSize)

signalBg =
     buyNow or buyReady or buyForming or buyScalp or bullAPlusForming or bullBPlus or bullBMinus ? color.green :
     sellNow or sellReady or sellForming or sellScalp or bearAPlusForming or bearBPlus or bearBMinus ? color.red :
     color.gray

matrixBg =
     matrixBullSupport ? color.green :
     matrixBearSupport ? color.red :
     color.gray

techBg =
     techText == "Strong" ? color.green :
     techText == "Weak" ? color.orange :
     color.gray

if barstate.islast and showTable
    f_row(0, "Trend", trendText, bullLocal ? color.green : bearLocal ? color.red : color.gray)
    f_row(1, "HTF", htfBiasText, str.contains(htfBiasText, "BULL") ? color.green : str.contains(htfBiasText, "BEAR") ? color.red : color.gray)
    f_row(2, "Struct", structureText, str.contains(structureText, "Bull") ? color.green : str.contains(structureText, "Bear") ? color.red : color.gray)
    f_row(3, "Sweep", sweepText, str.contains(sweepText, "Bull") ? color.green : str.contains(sweepText, "Bear") ? color.red : color.gray)
    f_row(4, "BOS", bosText, str.contains(bosText, "Bull") ? color.green : str.contains(bosText, "Bear") ? color.red : color.gray)
    f_row(5, "CHOCH", chochText, str.contains(chochText, "Bull") ? color.green : str.contains(chochText, "Bear") ? color.red : color.gray)
    f_row(6, "Accept", acceptanceText, str.contains(acceptanceText, "Above") or str.contains(acceptanceText, "Lower") ? color.green : str.contains(acceptanceText, "Below") or str.contains(acceptanceText, "Higher") ? color.red : color.gray)
    f_row(7, "EMA", emaStateText, str.contains(emaStateText, "Up") ? color.green : str.contains(emaStateText, "Down") ? color.red : color.gray)
    f_row(8, "Liq", liquidityText, nearSellSide ? color.green : nearBuySide ? color.red : color.gray)
    f_row(9, "Session", sessionText, sessionBoost >= 3 ? color.blue : color.gray)
    f_row(10, "Fib", fibText, str.contains(fibText, "Bull") ? color.green : str.contains(fibText, "Bear") ? color.red : color.gray)
    f_row(11, "Mom", momentumText, str.contains(momentumText, "Bull") ? color.green : str.contains(momentumText, "Bear") ? color.red : str.contains(momentumText, "Weak") ? color.orange : color.gray)
    f_row(12, "Div", divergenceText, str.contains(divergenceText, "Bull") ? color.green : str.contains(divergenceText, "Bear") ? color.red : color.gray)
    f_row(13, "Prob", "B " + str.tostring(bullProb) + "% / S " + str.tostring(bearProb) + "%", bullProb > bearProb ? color.green : bearProb > bullProb ? color.red : color.gray)
    f_row(14, "A+ Score", "B " + str.tostring(bullAPlusScore) + " / S " + str.tostring(bearAPlusScore), bullAPlusScore > bearAPlusScore ? color.green : bearAPlusScore > bullAPlusScore ? color.red : color.gray)
    f_row(15, "Matrix", matrixText, matrixBg)
    f_row(16, "Tech", techText, techBg)
    f_row(17, "Grade", setupGradeText, setupGradeBg)
    f_row(18, "FINAL", stateText, signalBg)

if barstate.islast and not showTable
    table.clear(t, 0, 0, 1, 18)
````
