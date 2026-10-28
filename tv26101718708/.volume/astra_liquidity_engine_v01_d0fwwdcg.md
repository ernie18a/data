# ASTRA: Liquidity Engine v0.1

- url: https://www.tradingview.com/script/d0fwwdCG-ASTRA-Liquidity-Engine-v0-1/
- type: indicator
- pine_id: PUB;4d1e7524c4c04283a84bf9ffd4c462c3
- version: 1.0

## Description

[b]Astra[/b]
[b]Astra[/b] is a specialized technical analysis tool designed to capture market momentum, trend exhaustion, and volatility shifts.

By publishing this script in open form, the goal is to share the underlying logic with the developer and trading community for transparency, optimization, and collaboration.

[b]⚠️ CRITICAL WARNING & DISCLAIMER[/b]
Astra is NOT a standalone trading system. If you attempt to trade blindly based solely on Astra’s signals, you will likely experience significant drawdowns, especially during [insert weak market condition, e.g., choppy, sideways markets / sharp counter-trend reversals].

Context is Key: This indicator is engineered to highlight specific mathematical anomalies or market dynamics. It does not account for overall market structure, higher timeframe trends, or volume validation on its own.

Do Not Solo Trade: This tool is explicitly designed to function as a supporting component of a broader trading framework.

Best Practices: Confluence Over Isolation
To unlock Astra's true potential, it must be combined with complementary tools to filter out false signals. It works best when paired with:

Trend/Structure Filters: Pair it with a Higher Timeframe EMA, Moving Averages, or Market Structure (Market Highs/Lows) to ensure you are only trading in the direction of the primary trend.

Momentum & Volume Validation: Combine Astra with volume-based indicators (like Volume Profiles, VWAP) or structural oscillators (like a customized RSI) to confirm if a move has genuine institutional backing.

Your Own Discretion: Use this to find setups, but rely on solid price action and risk management for your actual entries and exits.

Note to the Community: The code is open. Feel free to fork it, adapt it into your own strategies, or build multi-indicator dashboards (HUDs) around it. If you find an incredible confluence combination with Astra, share your insights in the comments below!

## Source Code

````pine
//@version=6
indicator("ASTRA: Liquidity Engine v0.1", overlay=true, precision=2)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------
price = hlc3

fastLen  = input.int(7,  "Fast Momentum Length")
medLen   = input.int(14, "Medium Momentum Length")
slowLen  = input.int(21, "Slow Momentum Length")

volLookback = input.int(20, "Volume Lookback")

autoMode = input.bool(true, "Auto Intelligence Mode")

showLiquidityManual = input.bool(true, "Show Liquidity Map")
showHeatManual = input.bool(true, "Show Energy Heat")

liqLookback = input.int(30, "Liquidity Lookback")
liqTolerance = input.float(0.15, "EQ Level Tolerance %") / 100
pivotLen = 5
htf = input.timeframe("5", "Higher Timeframe")

//----------------------------------------------------
// 3D MOMENTUM CORE
//----------------------------------------------------
rFast = ta.rsi(price, fastLen) - 50
rMed  = ta.rsi(price, medLen)  - 50
rSlow = ta.rsi(price, slowLen) - 50

momentumCore = (rFast * 0.6) + (rMed * 1.0) + (rSlow * 1.4)
energy = ta.ema(momentumCore, 3)

//----------------------------------------------------
// ENERGY NORMALIZATION
//----------------------------------------------------
volatility = ta.stdev(energy, 50)
normEnergy = volatility != 0 ? (energy / volatility) * 20 : 0
normEnergy := math.max(-100, math.min(100, normEnergy))

//----------------------------------------------------
// TREND EXHAUSTION ENGINE
//----------------------------------------------------

energyFalling = math.abs(normEnergy) < math.abs(normEnergy[1])

// Local volume average (prevents dependency error)
localVolAvg = ta.sma(volume, 20)
volumeWeak = volume < localVolAvg

candleRange = high - low
avgCandleRange = ta.sma(candleRange, 20)

smallCandle = candleRange < avgCandleRange * 0.7

exhaustionScore = 0
exhaustionScore += energyFalling ? 1 : 0
exhaustionScore += volumeWeak ? 1 : 0
exhaustionScore += smallCandle ? 1 : 0

exhaustionState =
     exhaustionScore >= 3 ? "HIGH" :
     exhaustionScore == 2 ? "MODERATE" :
     exhaustionScore == 1 ? "EARLY" :
     "NONE"

//----------------------------------------------------
// MARKET REGIME
//----------------------------------------------------
energyAvg = ta.sma(math.abs(normEnergy), 20)
isExpansion = math.abs(normEnergy) > energyAvg
isCompression = not isExpansion

//----------------------------------------------------
// ENERGY EXPANSION
//----------------------------------------------------
energyStrength = math.abs(normEnergy)
energyExpansion = energyStrength > energyStrength[1] and energyStrength[1] > energyStrength[2]

//----------------------------------------------------
// ADAPTIVE VOLUME ENGINE
//----------------------------------------------------
volAvg = ta.sma(volume, volLookback)
atrFast = ta.atr(14)
atrSlow = ta.sma(atrFast, 50)
volatilityFactor = atrSlow != 0 ? atrFast / atrSlow : 1
adaptiveVolThreshold = 1 + volatilityFactor
strongVolume = volume > volAvg * adaptiveVolThreshold

//----------------------------------------------------
// EQUAL HIGH / LOW LIQUIDITY
//----------------------------------------------------
eqHigh = math.abs(high - high[1]) / high < liqTolerance
eqLow  = math.abs(low - low[1]) / low < liqTolerance

liquidityHigh = eqHigh and eqHigh[1]
liquidityLow  = eqLow and eqLow[1]

recentHigh = ta.highest(high, liqLookback)
recentLow  = ta.lowest(low, liqLookback)


//----------------------------------------------------
// LIQUIDITY CLUSTER DETECTION
//----------------------------------------------------
clusterLookback = 10
clusterTouches  = 3

highTouch =
     math.abs(high - ta.highest(high, clusterLookback)) / high < liqTolerance

lowTouch =
     math.abs(low - ta.lowest(low, clusterLookback)) / low < liqTolerance

highCount = math.sum(highTouch ? 1 : 0, clusterLookback)
lowCount  = math.sum(lowTouch ? 1 : 0, clusterLookback)

liquidityClusterHigh = highCount >= clusterTouches
liquidityClusterLow  = lowCount >= clusterTouches

//----------------------------------------------------
// LIQUIDITY CLUSTER ZONES
//----------------------------------------------------

clusterHighValue = ta.highest(high, clusterLookback)
clusterLowValue  = ta.lowest(low, clusterLookback)

var line highClusterLine = na
var line lowClusterLine  = na

if liquidityClusterHigh
    line.delete(highClusterLine)
    highClusterLine := line.new(
         bar_index,
         clusterHighValue,
         bar_index + 30,
         clusterHighValue,
         color=color.red,
         width=2)

if liquidityClusterLow
    line.delete(lowClusterLine)
    lowClusterLine := line.new(
         bar_index,
         clusterLowValue,
         bar_index + 30,
         clusterLowValue,
         color=color.green,
         width=2)

//----------------------------------------------------
// SWEEP DETECTION
//----------------------------------------------------
buySideSweep  = liquidityClusterHigh and high > recentHigh and close < recentHigh
sellSideSweep = liquidityClusterLow and low < recentLow and close > recentLow

//----------------------------------------------------
// REJECTION LOGIC
//----------------------------------------------------
bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

strongUpperReject = upperWick > bodySize * 1.5
strongLowerReject = lowerWick > bodySize * 1.5

//----------------------------------------------------
// STRUCTURE BREAK
//----------------------------------------------------
structureHigh = ta.highest(high, 10)
structureLow  = ta.lowest(low, 10)

bosBull = close > structureHigh[1]
bosBear = close < structureLow[1]

//----------------------------------------------------
// IMPROVED SWEEP DETECTION
//----------------------------------------------------
instBullSweep =
     low < recentLow
     and close > recentLow

instBearSweep =
     high > recentHigh
     and close < recentHigh

//--------------------------------
// TRAP DETECTION ENGINE
//--------------------------------

bullTrap =
     instBullSweep and
     not energyExpansion and
     close < recentLow

bearTrap =
     instBearSweep and
     not energyExpansion and
     close > recentHigh

trapState =
     bullTrap ? "BULL TRAP" :
     bearTrap ? "BEAR TRAP" :
     "NONE"

//----------------------------------------------------
// REVERSAL ENGINE
//----------------------------------------------------
bullReversal = instBullSweep and normEnergy > -20
bearReversal = instBearSweep and normEnergy < 20

//----------------------------------------------------
// SWEEP SCORE
//----------------------------------------------------
wickStrength = strongUpperReject or strongLowerReject ? 25 : 0
volumeStrength = strongVolume ? 25 : 0
momentumStrength = energyExpansion ? 25 : 0
structureStrength = bosBull or bosBear ? 25 : 0

sweepScore = wickStrength + volumeStrength + momentumStrength + structureStrength
sweepScore := math.min(sweepScore,100)

//----------------------------------------------------
// CONFIDENCE ENGINE
//----------------------------------------------------
confidence = 0.0
confidence += sweepScore * 0.4
confidence += strongVolume ? 20 : 0
confidence += energyExpansion ? 20 : 0
confidence += math.abs(normEnergy) > 40 ? 20 : 0
confidence := math.min(confidence,100)

//----------------------------------------------------
// AUTO VISIBILITY
//----------------------------------------------------
showLiquidity = autoMode ? isCompression : showLiquidityManual
showHeat = autoMode ? isExpansion : showHeatManual

//----------------------------------------------------
// DIVERGENCE
//----------------------------------------------------
priceLow  = ta.pivotlow(low,pivotLen,pivotLen)
priceHigh = ta.pivothigh(high,pivotLen,pivotLen)

energyLow  = ta.pivotlow(normEnergy,pivotLen,pivotLen)
energyHigh = ta.pivothigh(normEnergy,pivotLen,pivotLen)

priceLowFound = not na(priceLow)
priceHighFound = not na(priceHigh)
energyLowFound = not na(energyLow)
energyHighFound = not na(energyHigh)

bullDiv = priceLowFound and energyLowFound and low[pivotLen] < low[pivotLen*2] and normEnergy[pivotLen] > normEnergy[pivotLen*2]
bearDiv = priceHighFound and energyHighFound and high[pivotLen] > high[pivotLen*2] and normEnergy[pivotLen] < normEnergy[pivotLen*2]

//----------------------------------------------------
// MTF MOMENTUM
//----------------------------------------------------
htfEnergy = request.security(syminfo.tickerid, htf, normEnergy)
mtfBull = htfEnergy > 0
mtfBear = htfEnergy < 0

//----------------------------------------------------
// HIDDEN ACCUMULATION
//----------------------------------------------------
priceRange = ta.highest(high,10) - ta.lowest(low,10)
avgRange = ta.sma(priceRange,20)
tightRange = priceRange < avgRange

hiddenAccum = tightRange and strongVolume and normEnergy > -10 and normEnergy < 10

//----------------------------------------------------
// HEAT GLOW
//----------------------------------------------------
heatColor = normEnergy>0?color.teal:color.maroon
pulseStrength = math.min(math.abs(normEnergy)*1.2,90)
bgcolor(showHeat?color.new(heatColor,100-pulseStrength):na)

//----------------------------------------------------
// LIQUIDITY ZONES (SMC STYLE)
//----------------------------------------------------
liqHigh = ta.highest(high, liqLookback)
liqLow  = ta.lowest(low, liqLookback)

// draw resistance liquidity
plot(showLiquidity ? liqHigh : na,
     title="Sell Side Liquidity",
     color=color.new(color.red,80),
     linewidth=3)

// draw support liquidity
plot(showLiquidity ? liqLow : na,
     title="Buy Side Liquidity",
     color=color.new(color.green,80),
     linewidth=3)

//----------------------------------------------------
// ASTRA INTELLIGENCE STATES
//----------------------------------------------------

//----------------------------------------------------
// MARKET PHASE
//----------------------------------------------------

marketPhase =
     isCompression ? "COMPRESSION" :
     exhaustionScore >= 3 ? "EXHAUSTION" :
     isExpansion ? "EXPANSION" :
     "TRANSITION"

// Momentum Strength
absEnergy = math.abs(normEnergy)

momentumState =
     absEnergy > 70 ? "EXTREME" :
     absEnergy > 40 ? "STRONG" :
     absEnergy > 20 ? "MODERATE" :
     "WEAK"

// Volume Power
volumeState =
     strongVolume ? "HIGH" :
     "NORMAL"

// Liquidity State
liquidityState =
     liquidityClusterHigh or liquidityClusterLow ? "BUILDING" :
     "QUIET"

// Sweep Event
sweepEvent =
     instBullSweep ? "BUY SWEEP" :
     instBearSweep ? "SELL SWEEP" :
     "NONE"

// Trend Health
trendHealth =
     energyExpansion and strongVolume ? "STRONG" :
     energyExpansion ? "STABLE" :
     "WEAK"

// Energy State
energyState =
     energyExpansion ? "RISING" :
     "FADING"

//--------------------------------
// TREND TYPE ENGINE
//--------------------------------

trendType =
     momentumState == "EXTREME" and volumeState == "NORMAL" ? "VACUUM DRIVE" :
     momentumState == "STRONG" and volumeState == "HIGH" ? "TREND DRIVE" :
     momentumState == "MODERATE" and energyState == "RISING" ? "BALANCED TREND" :
     "NEUTRAL"

//----------------------------------------------------
// SLOW GRIND PERSONALITY ENGINE
//----------------------------------------------------

slowGrindTrend =
     marketPhase == "EXPANSION" and
     momentumState == "MODERATE" and
     energyState == "RISING" and
     (volumeState == "NORMAL") and
     trendHealth == "STABLE"

slowGrindState =
     slowGrindTrend ? "SLOW GRIND TREND" :
     "NONE"

//----------------------------------------------------
// VALUE MIGRATION ENGINE
//----------------------------------------------------

// NOTE:
// Replace obsidianPOC with your actual POC variable if different

poc = request.security(syminfo.tickerid, timeframe.period, close)

// detect drift
pocRising = poc > poc[1]
pocFalling = poc < poc[1]

// price location
priceAbovePOC = close > poc
priceBelowPOC = close < poc

valueState =
     priceAbovePOC and pocRising ? "VALUE BUILDING" :
     priceBelowPOC and pocFalling ? "VALUE FALLING" :
     "VALUE STABLE"

// Environment Filter
environmentState =
     isCompression ? "AVOID" :
     confidence > 60 ? "TRADE" :
     "CAUTION"

//----------------------------------------------------
// TREND IGNITION ENGINE
//----------------------------------------------------

ignition = isCompression[1] and energyExpansion and strongVolume

bullIgnition = ignition and bosBull
bearIgnition = ignition and bosBear

ignitionState =
     bullIgnition ? "BULL IGNITION" :
     bearIgnition ? "BEAR IGNITION" :
     ignition ? "IGNITION" :
     "NONE"

//----------------------------------------------------
// ASTRA PULLBACK ENGINE
//----------------------------------------------------

// Momentum cooling
energyCooling = math.abs(normEnergy) < math.abs(normEnergy[1])

// Candle contraction
pullbackRange = high - low
avgPullbackRange = ta.sma(pullbackRange, 20)

smallPullback = pullbackRange < avgPullbackRange * 0.8

// Pullback detection
pullbackActive = isExpansion and energyCooling and smallPullback

// Direction detection
pullbackBull = pullbackActive and normEnergy > 0
pullbackBear = pullbackActive and normEnergy < 0

pullbackState =
     pullbackBull ? "BULL PULLBACK" :
     pullbackBear ? "BEAR PULLBACK" :
     pullbackActive ? "PULLBACK" :
     "NONE"

//----------------------------------------------------
// CONTINUATION DETECTOR
//----------------------------------------------------

continuationBull = pullbackBull and energyExpansion and strongVolume
continuationBear = pullbackBear and energyExpansion and strongVolume

continuationState =
     continuationBull ? "BULL CONTINUATION" :
     continuationBear ? "BEAR CONTINUATION" :
     "NONE"

//----------------------------------------------------
// ASTRA SIGNAL GRADING
//----------------------------------------------------

grade = "NONE"

// A+ conditions
gradeAplus =
     isExpansion and
     (math.abs(normEnergy) > 60) and
     (strongVolume) and
     (continuationBull or continuationBear) and
     confidence > 80 and
     sweepScore > 70

// A conditions
gradeA =
     isExpansion and
     (math.abs(normEnergy) > 40) and
     confidence > 60 and
     trendHealth == "STRONG"

// B conditions
gradeB =
     isExpansion and
     (math.abs(normEnergy) > 20) and
     confidence > 40

grade :=
     gradeAplus ? "A+" :
     gradeA ? "A" :
     gradeB ? "B" :
     "NONE"

//----------------------------------------------------
// ASTRA WAVE CONTEXT ENGINE
//----------------------------------------------------
var int trendPush = 0

// reset when market compresses
if isCompression
    trendPush := 0

// ignition starts first push
if bullIgnition or bearIgnition
    trendPush := 1

// continuation increases push count
if continuationBull or continuationBear
    trendPush := math.min(trendPush + 1, 5)

// convert push count into readable state
pushState =
     trendPush == 0 ? "NONE" :
     trendPush == 1 ? "FIRST PUSH" :
     trendPush == 2 ? "SECOND PUSH" :
     trendPush == 3 ? "THIRD PUSH" :
     trendPush >= 4 ? "LATE TREND" :
     "NONE"

//----------------------------------------------------
// ASTRA MARKET REGIME ENGINE
//----------------------------------------------------

trendDay =
     isExpansion and
     strongVolume and
     confidence > 70

rangeDay =
     isCompression and
     confidence < 40

trapDay =
     (instBullSweep or instBearSweep) and
     not energyExpansion

slowGrind =
     isExpansion and
     not strongVolume

regimeState =
     trendDay ? "TREND DAY" :
     rangeDay ? "RANGE DAY" :
     trapDay ? "TRAP DAY" :
     slowGrind ? "SLOW GRIND" :
     "NEUTRAL"

//----------------------------------------------------
// ASTRA SESSION ENGINE
//----------------------------------------------------

hourValue = hour(time)

morningSession = hourValue >= 9 and hourValue < 11
midSession = hourValue >= 11 and hourValue < 13
afternoonSession = hourValue >= 13

sessionState =
     morningSession ? "MORNING" :
     midSession ? "MID SESSION" :
     afternoonSession ? "AFTERNOON" :
     "UNKNOWN"

//----------------------------------------------------
// ASTRA MICRO COMPRESSION ENGINE
//----------------------------------------------------

// detect impulse candle
impulseRange = high - low
avgImpulseRange = ta.sma(impulseRange, 20)

bigImpulse = impulseRange > avgImpulseRange * 1.5

// detect small cooling candles
smallCoolingCandle = impulseRange < avgImpulseRange * 0.7

// count cooling candles
var int microCount = 0

if smallCoolingCandle
    microCount += 1
else
    microCount := 0

// range contraction pressure
rangeNow = ta.highest(high,5) - ta.lowest(low,5)
rangeAvg = ta.sma(high - low,20)

rangeContracting = rangeNow < rangeAvg * 0.8

// compression logic
microCompression =
     bigImpulse[1] and
     microCount >= 2 and
     microCount <= 7 and
     rangeContracting

microState =
     microCompression ? "CHARGING" :
     microCount > 0 ? "COOLING" :
     "NONE"

// Reset scores
obsidianScore = 0.0
astraScore = 0.0
energyScore = 0.0

//--------------------------------
// STRUCTURE SCORE (simplified)
//--------------------------------

if liquidityState == "BUILDING"
    obsidianScore += 10

if trendHealth == "STRONG"
    obsidianScore += 10

if sweepScore > 50
    obsidianScore += 10

//--------------------------------
// ASTRA ENVIRONMENT SCORE
//--------------------------------

if marketPhase == "EXPANSION"
    astraScore += 10

if momentumState == "STRONG" or momentumState == "EXTREME"
    astraScore += 10

if energyState == "RISING"
    astraScore += 10

if environmentState == "TRADE"
    astraScore += 5

//--------------------------------
// ENERGY / COIL SCORE
//--------------------------------

if microCompression
    energyScore += 10

if energyExpansion
    energyScore += 10

if strongVolume
    energyScore += 10

//--------------------------------
// ADAPTIVE FUSION ENGINE
//--------------------------------

obsidianWeight = isCompression ? 0.8 : 1.2
astraWeight = isExpansion ? 1.2 : 1.0
energyWeight = microCompression ? 1.3 : 1.0

fusionProbability =
     (obsidianScore * obsidianWeight) +
     (astraScore * astraWeight) +
     (energyScore * energyWeight)

fusionProbability := math.min(math.max(fusionProbability,0),100)

//----------------------------------------------------
// PROBABILITY SMOOTHING ENGINE
//----------------------------------------------------

fusionProbabilitySmooth = ta.ema(fusionProbability, 3)

//----------------------------------------------------
// VOLATILITY COIL ENGINE
//----------------------------------------------------

// detect short-term range compression
coilRange = ta.highest(high,8) - ta.lowest(low,8)
coilAvgRange = ta.sma(high - low,20)

rangeCompression = coilRange < coilAvgRange * 0.75

// energy building gradually
energyRising =
     absEnergy > absEnergy[1] and
     absEnergy[1] > absEnergy[2]

// count compression candles
var int coilCount = 0

if rangeCompression
    coilCount += 1
else
    coilCount := 0

// valid coil duration (3–8 candles)
coilActive =
     coilCount >= 3 and
     coilCount <= 8 and
     energyRising and
     isExpansion

coilState =
     coilActive ? "COIL BUILDING" :
     "NONE"

//----------------------------------------------------
// CONTINUATION IGNITION DETECTOR
//----------------------------------------------------

continuationIgnition =
     (trendPush == 2 or trendPush == 3) and
     (pullbackBull or pullbackBear) and
     microCompression and
     energyExpansion

ignitionBuildState =
     continuationIgnition ? "IGNITION BUILDING" :
     "NONE"

//----------------------------------------------------
// HUD COLORS
//----------------------------------------------------

titleColor = color.white
labelColor = color.silver
bullColor = color.lime
bearColor = color.red
neutralColor = color.yellow

//----------------------------------------------------
// ASTRA FORECAST ENGINE
//----------------------------------------------------

forecast = "NO EDGE"

if microCompression and energyExpansion and momentumState == "STRONG"
    forecast := "EXPLOSION LIKELY"

else if coilState == "COIL BUILDING"
    forecast := "COIL BUILDING"

else if continuationBull or continuationBear
    forecast := "TREND CONTINUATION"

else if exhaustionScore >= 2
    forecast := "TREND FATIGUE"

//----------------------------------------------------
// FUSION FORECAST
//----------------------------------------------------

fusionForecast =
     fusionProbabilitySmooth > 80 ? "EXPLOSION LIKELY" :
     fusionProbabilitySmooth > 60 ? "TREND CONTINUATION" :
     fusionProbabilitySmooth > 40 ? "ENERGY BUILDING" :
     fusionProbabilitySmooth > 25 ? "WEAK EDGE" :
     "NO EDGE"

//----------------------------------------------------
// MARKET STATE COLOR ENGINE
//----------------------------------------------------

stateColor =
     fusionForecast == "EXPLOSION LIKELY" ? color.purple :
     fusionForecast == "TREND CONTINUATION" ? color.lime :
     fusionForecast == "ENERGY BUILDING" ? color.blue :
     fusionForecast == "WEAK EDGE" ? color.orange :
     color.gray

//----------------------------------------------------
// FUSION FORECAST HUD
//----------------------------------------------------

var table fusionHud = table.new(position.top_center,1,4)

if barstate.islast
    table.cell(fusionHud,0,0,"")

    table.cell(
        fusionHud,
        0,
        1,
        "⚡ MARKET STATE",
        text_color=color.white,
        bgcolor=color.new(color.black,10)
    )

    table.cell(
     fusionHud,
     0,
     2,
     fusionForecast,
     text_color=color.white,
     bgcolor=color.new(stateColor, 0)
)

    table.cell(
        fusionHud,
        0,
        3,
        "Prob: " + str.tostring(math.round(fusionProbabilitySmooth)) + "%",
        text_color=color.white
    )

//----------------------------------------------------
// MERGED DECISION ENGINES
//----------------------------------------------------

// Trend Strength
trendStrength =
     momentumState == "EXTREME" ? "EXTREME" :
     momentumState == "STRONG" and energyState == "RISING" ? "STRONG" :
     momentumState == "MODERATE" ? "MODERATE" :
     "WEAK"

// Trend Structure
trendStructure =
     continuationBull or continuationBear ? "CONTINUATION" :
     pullbackBull or pullbackBear ? "PULLBACK" :
     pushState

// Liquidity Activity (WITH TRAP)
liquidityActivity =
     bullTrap ? "BULL TRAP" :
     bearTrap ? "BEAR TRAP" :
     instBullSweep ? "BUY SWEEP" :
     instBearSweep ? "SELL SWEEP" :
     liquidityState

// Trade Quality
tradeQuality =
     grade == "A+" ? "A+ HIGH" :
     grade == "A" ? "A GOOD" :
     grade == "B" ? "B MODERATE" :
     "LOW"

//----------------------------------------------------
// HUD COLOR LOGIC
//----------------------------------------------------

// Environment color
envColor =
     environmentState == "TRADE" ? color.new(color.green, 0) :
     environmentState == "CAUTION" ? color.new(color.orange, 0) :
     color.new(color.red, 0)

// Trade Quality color
qualityColor =
     tradeQuality == "A+ HIGH" ? color.new(color.lime, 0) :
     tradeQuality == "A GOOD" ? color.new(color.green, 0) :
     tradeQuality == "B MODERATE" ? color.new(color.orange, 0) :
     color.new(color.red, 0)

// Trend Strength color
strengthColor =
     trendStrength == "EXTREME" ? color.new(color.purple, 0) :
     trendStrength == "STRONG" ? color.new(color.lime, 0) :
     trendStrength == "MODERATE" ? color.new(color.yellow, 0) :
     color.new(color.gray, 0)

// Liquidity color (TRAP priority)
liquidityColor =
     liquidityActivity == "BULL TRAP" or liquidityActivity == "BEAR TRAP" ? color.new(color.red, 0) :
     liquidityActivity == "BUY SWEEP" or liquidityActivity == "SELL SWEEP" ? color.new(color.orange, 0) :
     color.new(color.gray, 0)

//----------------------------------------------------
// ASTRA HUD
//----------------------------------------------------

var table hud = table.new(position.top_right, 2, 12)

//----------------------------------------------------
// ASTRA HUD (MERGED)
//----------------------------------------------------

if barstate.islast

    table.cell(hud,0,1,"Session")
    table.cell(hud,1,1,sessionState)

    table.cell(hud,0,2,"HTF Bias")
    table.cell(hud,1,2,mtfBull ? "BULLISH" : mtfBear ? "BEARISH" : "NEUTRAL")

    table.cell(hud,0,3,"Market Phase")
    table.cell(hud,1,3,marketPhase)

    table.cell(hud,0,4,"Trend Type")
    table.cell(hud,1,4,trendType)

    table.cell(hud,0,5,"Market Personality")
    table.cell(hud,1,5,slowGrindState)

    table.cell(hud,0,6,"Trend Strength")
    table.cell(hud,1,6,trendStrength, bgcolor=strengthColor)

    table.cell(hud,0,7,"Trend Structure")
    table.cell(hud,1,7,trendStructure)

    table.cell(hud,0,8,"Liquidity Activity")
    table.cell(hud,1,8,liquidityActivity, bgcolor=liquidityColor)

    table.cell(hud,0,9,"Value Migration")
    table.cell(hud,1,9,valueState)

    table.cell(hud,0,10,"Trade Quality")
    table.cell(hud,1,10,tradeQuality, bgcolor=qualityColor)

    table.cell(hud,0,11,"Environment")
    table.cell(hud,1,11,environmentState, bgcolor=envColor)

//----------------------------------------------------
// ALERT SYSTEM (SMART FILTER)
//----------------------------------------------------

// Detect new conditions
newAplus = grade == "A+" and grade[1] != "A+" and environmentState == "TRADE"
newExplosion = fusionProbabilitySmooth > 80 
     and fusionProbabilitySmooth[1] <= 80 
     and environmentState == "TRADE"
newVacuum = trendType == "VACUUM DRIVE" and trendType[1] != "VACUUM DRIVE"

// Alerts
alertcondition(newAplus, title="ASTRA A+ Setup", message="A+ Setup")
alertcondition(newExplosion, title="Explosion Likely", message="Explosion Incoming")
alertcondition(newVacuum, title="Vacuum Move", message="Fast Move Incoming")
````
