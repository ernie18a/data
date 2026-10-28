# Topstep EV Hybrid v14 MNQ ALL Signals LiveLock CSV

- url: https://www.tradingview.com/script/uBt4i4Z5-Topstep-EV-Hybrid-v14-MNQ-ALL-Signals-LiveLock-CSV/
- type: indicator
- pine_id: PUB;608b936f1eed4901a6e529ace016f752
- version: 1.0

## Description

2021-2026 data backtested strategy, still in forward testing phase

## Source Code

````pine
//@version=6
indicator(
     "Topstep EV Hybrid v14 MNQ ALL Signals LiveLock CSV",
     overlay=true,
     max_labels_count=500,
     max_boxes_count=500)

//====================================================
// MODE
//====================================================

riskMode =
     input.string(
         "Balanced",
         "Risk Mode",
         options=[
             "Strict",
             "Balanced",
             "Aggressive"
         ])


//====================================================
// EV TIER / PERMISSION ADD-ON
// Keeps the old signal engine intact.
// Tiers only decide whether a raw old signal is A+, A, B/log, or skipped.
//====================================================

signalPermission =
     input.string(
         "B or Better / Research",
         "Signal Permission",
         options=[
             "A+ Only",
             "A or Better",
             "B or Better / Research"
         ])

tierThreshold =
     signalPermission == "A+ Only" ? 3 :
     signalPermission == "A or Better" ? 2 :
     1

enforceSignalPermission =
     input.bool(
         false,
         "Hard Filter Signals By Permission")

showResearchLabels =
     input.bool(
         false,
         "Show B-Tier Research Labels")

showPriorityBG =
     input.bool(
         true,
         "Show A/A+ Priority Background")

requiredHTFScore =
     riskMode == "Strict" ? 75 :
     riskMode == "Balanced" ? 65 :
     55

blockCounterTrend =
     input.bool(
         true,
         "Block Counter-Trend Signals")

confirmedOnly =
     input.bool(
         true,
         "Confirm Signals On Bar Close")

//====================================================
// SESSION
// Entries only 9:30-10:59 NY.
// Open trades manage until TP, SL, BE, 12:00, or backup timeout.
//====================================================

sessionNY =
     input.session(
         "0930-1200",
         "NY Management Session")

inSession =
     not na(
         time(
             timeframe.period,
             sessionNY))

hourNY =
     hour(
         time,
         "America/New_York")

minuteNY =
     minute(
         time,
         "America/New_York")

dayNY =
     dayofweek(time)

isMonday =
     dayNY == dayofweek.monday

isTuesday =
     dayNY == dayofweek.tuesday

isWednesday =
     dayNY == dayofweek.wednesday

isThursday =
     dayNY == dayofweek.thursday

isFriday =
     dayNY == dayofweek.friday

preferredDay =
     isMonday or isWednesday or isFriday

bestDay =
     isWednesday

weakDay =
     isTuesday or isThursday

//====================================================
// DAY FILTER
// Current full-sample optimization: trade Monday / Wednesday / Friday.
// Tuesday and Thursday were the main weekday drag in the reverted sample.
//====================================================

blockTuesday =
     input.bool(
         false,
         "Block Tuesday")

blockThursday =
     input.bool(
         false,
         "Block Thursday")

allowTuesdayShorts =
     input.bool(
         false,
         "Allow Tuesday Shorts")

tuesdayShortMinBody =
     input.float(
         0.70,
         "Tuesday Short Min Body Ratio",
         minval=0.10,
         maxval=0.95,
         step=0.05)

useMNQDayRiskPatch =
     input.bool(
         true,
         "Use MNQ Day/Risk Patch")

blockMNQTuesdayShorts =
     input.bool(
         true,
         "MNQ Block Tuesday Shorts")

tuesdayLongMinBodyMNQ =
     input.float(
         0.70,
         "MNQ Tuesday Long Min Body",
         minval=0.10,
         maxval=0.95,
         step=0.05)

blockMNQThursdayLate =
     input.bool(
         true,
         "MNQ Block Thursday 10:30-10:59")

thursdayShortMaxRiskPointsMNQ =
     input.float(
         100.0,
         "MNQ Thursday Short Max Risk Points",
         minval=10.0,
         step=5.0)

blockWeakBodyLongs =
     input.bool(
         true,
         "Block Weak Body Longs")

longWeekdayBlocked =
     (blockTuesday and isTuesday) or
     (blockThursday and isThursday)

primaryWindow =
     hourNY == 9 and
     minuteNY >= 30 and
     minuteNY <= 59

secondaryWindow =
     hourNY == 10 and
     minuteNY <= 29

lateWindow =
     hourNY == 10 and
     minuteNY >= 30

timeText =
     str.tostring(hourNY) + ":" +
     (minuteNY < 10 ? "0" : "") +
     str.tostring(minuteNY)

entryWindow =
     (hourNY == 9 and minuteNY >= 30) or
     hourNY == 10

openingWindow =
     hourNY == 9 and
     minuteNY >= 30 and
     minuteNY <= 59

noonExitTime =
     hourNY >= 12

middayChop =
     hourNY >= 12

//====================================================
// DISPLAY INPUTS
//====================================================

showSessionBG =
     input.bool(
         true,
         "Show Session Background")

showGoldenScoreBG =
     input.bool(
         false,
         "Show Golden Score Background")

showEMA =
     input.bool(
         true,
         "Show EMA")

showSignals =
     input.bool(
         true,
         "Show Entry Signals")

showFVG =
     input.bool(
         false,
         "Show FVG")

showLevels =
     input.bool(
         true,
         "Show TP / SL / BE Lines")

showForecast =
     input.bool(
         false,
         "Show Forecast")

showFlow =
     input.bool(
         true,
         "Show Flow Dots")

showOB =
     input.bool(
         false,
         "Show Order Blocks")

showSweeps =
     input.bool(
         true,
         "Show Liquidity Sweeps")

showMgmt =
     input.bool(
         true,
         "Show Trade Management Labels")

showPanel =
     input.bool(
         true,
         "Show Permission Panel")

//====================================================
// CORE INPUTS
//====================================================

emaLength =
     input.int(
         50,
         "EMA Length")

swingLength =
     input.int(
         5,
         "Swing Length")

htf =
     input.timeframe(
         "15",
         "Master HTF")

ltfConfirmTF =
     input.timeframe(
         "1",
         "Micro Confirmation TF")

displacementMult =
     input.float(
         1.15,
         "Displacement Multiplier")

stopATR =
     input.float(
         0.8,
         "ATR Stop Multiplier",
         step=0.1)

rrTarget =
     input.float(
         0.85,
         "RR Target",
         step=0.05)

useBreakEven =
     input.bool(
         true,
         "Use Break Even")

breakEvenTriggerRR =
     input.float(
         0.7,
         "Move To BE At RR",
         step=0.05,
         minval=0.1)

backupTimeoutBars =
     input.int(
         999,
         "Backup Timeout Bars",
         minval=1)

minBodyRatio =
     input.float(
         0.35,
         "Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

openingMinBodyRatio =
     input.float(
         0.45,
         "Opening Window Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

maxHTFExtension =
     input.float(
         2.5,
         "Max HTF Extension ATR",
         step=0.1)

dominanceBuffer =
     input.int(
         10,
         "Bias Dominance Buffer",
         minval=0,
         maxval=50)

strongDominanceBuffer =
     input.int(
         20,
         "Strong Dominance Buffer",
         minval=0,
         maxval=50)

//====================================================
// GOLDEN HTF SCORE RANGE
//====================================================

goldenScoreMin =
     input.int(
         65,
         "Golden HTF Score Min",
         minval=0,
         maxval=100)

goldenScoreMax =
     input.int(
         84,
         "Golden HTF Score Max",
         minval=0,
         maxval=100)

allowHighScoreIfClean =
     input.bool(
         true,
         "Allow 85+ Only If Clean")

highScoreMin =
     input.int(
         95,
         "High Score Min",
         minval=0,
         maxval=100)

leverageScoreMin =
     input.int(
         75,
         "A+ Leverage Score Min",
         minval=0,
         maxval=100)

leverageScoreMax =
     input.int(
         84,
         "A+ Leverage Score Max",
         minval=0,
         maxval=100)

cautionHighMin =
     input.int(
         85,
         "Caution High Score Min",
         minval=0,
         maxval=100)

cautionHighMax =
     input.int(
         94,
         "Caution High Score Max",
         minval=0,
         maxval=100)

//====================================================
// 5M RULES
// 15m signals both directions allowed.
// 5m longs allowed.
// 5m shorts blocked by default unless extreme 15m bear is enabled.
//====================================================

blockFiveMinuteShorts =
     input.bool(
         true,
         "Block 5m Shorts")

allowFiveMinuteShortsOnlyIfExtreme =
     input.bool(
         false,
         "Allow 5m Shorts Only If Extreme 15m Bear Trend")

extremeBearScore =
     input.int(
         80,
         "Extreme 15m Bear Score For 5m Shorts",
         minval=0,
         maxval=100)

//====================================================
// TARGET SPACE SOFT TIERING
// Target space does not kill raw signals.
// It only downgrades A+/A tiers.
//====================================================

useTargetSpaceTiering =
     input.bool(
         true,
         "Use Target Space As Tier Modifier")

minTargetSpaceRR =
     input.float(
         0.8,
         "Good Target Space RR",
         step=0.05)

usePriorDayLiquidity =
     input.bool(
         true,
         "Use Prior Day Liquidity")

useRecentSwingLiquidity =
     input.bool(
         true,
         "Use Recent Swing Liquidity")

//====================================================
// MISSED MOVE EXCEPTIONS
// These are surgical add-ons for the exact weakness we saw:
// 1) breakout continuation that does not form a classic sweep/OB trigger
// 2) reversal short after an aggressive high sweep / rejection
//====================================================

useBreakoutException =
     input.bool(
         true,
         "Use Breakout Continuation Exception")

breakoutMinHTFScore =
     input.int(
         40,
         "Breakout Exception Min HTF Score",
         minval=0,
         maxval=100)

breakoutLookback =
     input.int(
         12,
         "Breakout Lookback Bars",
         minval=3,
         maxval=50)

breakoutMinBodyRatio =
     input.float(
         0.30,
         "Breakout Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

breakoutMinRangeATR =
     input.float(
         0.75,
         "Breakout Min Range ATR",
         minval=0.1,
         maxval=3.0,
         step=0.05)

breakoutMaxExtensionATR =
     input.float(
         4.5,
         "Breakout Max Extension ATR",
         minval=1.0,
         maxval=8.0,
         step=0.1)

useReversalShortException =
     input.bool(
         true,
         "Use A+ Reversal Short Exception")

reversalShortMinBodyRatio =
     input.float(
         0.30,
         "Reversal Short Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

reversalShortMinHTFScore =
     input.int(
         40,
         "Reversal Short Min Bear HTF Score",
         minval=0,
         maxval=100)

reversalShortMaxExtensionATR =
     input.float(
         5.0,
         "Reversal Short Max Extension ATR",
         minval=1.0,
         maxval=8.0,
         step=0.1)

//====================================================
// LIVE POCKET FILTER
// Keeps old raw signals visible, but pushes live risk toward the proven pocket:
// Mon/Wed/Fri strong-bodied 5m longs with clean lower wick.
// A long requires body >= 0.65 by default. A+ long requires body >= 0.70.
// Normal shorts remain B/log unless they qualify as body >= 0.75 reversal exceptions.
//====================================================

useLivePocketTiering =
     input.bool(
         true,
         "Use Live Pocket Tiering")

monThuLogOnly =
     input.bool(
         true,
         "Only Rank Mon / Wed / Fri As Live Days")

normalShortsLogOnly =
     input.bool(
         true,
         "Normal Shorts Log Only")

liveLongMinBodyRatio =
     input.float(
         0.70,
         "A Long Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

liveLongAPlusBodyRatio =
     input.float(
         0.80,
         "A+ Long Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

liveLongMaxLowerWickRatio =
     input.float(
         0.35,
         "Live Long Max Lower Wick Ratio",
         minval=0.05,
         maxval=0.8,
         step=0.05)

liveShortMaxCloseLocation =
     input.float(
         0.45,
         "Reversal Short Max Close Location",
         minval=0.05,
         maxval=0.8,
         step=0.05)

liveShortMinBodyRatio =
     input.float(
         0.75,
         "A Short Min Body Ratio",
         minval=0.1,
         maxval=0.95,
         step=0.05)

//====================================================
// SHORT BODY BUCKET FILTER
// Current full-sample optimization: short body 0.55-0.65 was the negative bucket.
// This blocks that specific short profile without changing long logic.
//====================================================

blockNegativeShortBodyBucket =
     input.bool(
         true,
         "Block Negative Short Body Bucket")

shortBadBodyMin =
     input.float(
         0.50,
         "Bad Short Body Min",
         minval=0.1,
         maxval=0.95,
         step=0.05)

shortBadBodyMax =
     input.float(
         0.65,
         "Bad Short Body Max",
         minval=0.1,
         maxval=0.95,
         step=0.05)

//====================================================
// SHORT ICEBERG STRUCTURE INPUTS
// Short-only model: keeps long logic unchanged.
// Iceberg shorts require an open downside objective, structural invalidation,
// strong candle quality, and enough RR to the objective.
//====================================================

useIcebergShortModel =
     input.bool(
         true,
         "Use Short Iceberg Structure Model")

shortInvalidationLookback =
     input.int(
         2,
         "Short Meaningful High Lookback",
         minval=2)

shortObjectiveLookback =
     input.int(
         4,
         "Short Meaningful Low Lookback",
         minval=3,
         maxval=50)

shortStopBufferATR =
     input.float(
         0.01,
         "Short Structure Stop Buffer ATR",
         step=0.01)

minIcebergObjectiveRR =
     input.float(
         2.00,
         "Min Iceberg Objective RR",
         step=0.05)

useStructureShortStop =
     input.bool(
         true,
         "Use Structure Stop For Iceberg Shorts")

includeSignalHighInShortStop =
     input.bool(
         false,
         "Include Signal High In Iceberg Stop")

icebergImpulseMult =
     input.float(
         0.18,
         "Iceberg Short Impulse Multiplier",
         minval=0.05,
         maxval=1.0,
         step=0.05)

blockIcebergIfSignalTouchesObjective =
     input.bool(
         true,
         "Block Iceberg If Signal Already Touched Objective")

icebergMinBodyRatio =
     input.float(
         0.50,
         "Iceberg Short Min Body Ratio",
         minval=0.1,
         maxval=0.95,
         step=0.05)

icebergMinRelativeVolume =
     input.float(
         1.00,
         "Iceberg Short Min Relative Volume",
         minval=0.1,
         step=0.05)

icebergObjectiveTapLookback =
     input.int(
         1,
         "Iceberg Objective Tap Lookback",
         minval=1,
         maxval=20)

icebergMaxCloseLocation =
     input.float(
         0.50,
         "Iceberg Short Max Close Location",
         minval=0.05,
         maxval=0.8,
         step=0.05)

icebergMinBearScore =
     input.int(
         25,
         "Iceberg Short Min Bear HTF Score",
         minval=0,
         maxval=100)

maxIcebergEmaExtensionATR =
     input.float(
         1.50,
         "Max Iceberg EMA Extension ATR",
         minval=0.25,
         maxval=5.0,
         step=0.25)

maxIcebergRiskPoints =
     input.float(
         55.0,
         "Max Iceberg Short Risk Points",
         minval=5.0,
         step=5.0)

icebergUseClosestObjective =
     input.bool(
         true,
         "Use Closest Short Objective")

//====================================================
// BACKGROUND
//====================================================

bgcolor(
     showSessionBG and inSession ?
     color.new(color.blue, 95) : na)

//====================================================
// ATR + EMA
//====================================================

atr =
     ta.atr(14)

atrSMA =
     ta.sma(atr, 20)

emaLTF =
     ta.ema(close, emaLength)

plot(
     showEMA ? emaLTF : na,
     color=color.orange,
     linewidth=2,
     title="EMA")

//====================================================
// LTF TREND
//====================================================

emaSlope =
     emaLTF - emaLTF[5]

ltfBullTrend =
     close > emaLTF

ltfBearTrend =
     close < emaLTF

ltfBullSlope =
     emaSlope > atr * 0.015

ltfBearSlope =
     emaSlope < -atr * 0.015

//====================================================
// SWINGS + LIQUIDITY SWEEPS
//====================================================

swingHigh =
     ta.pivothigh(
         high,
         swingLength,
         swingLength)

swingLow =
     ta.pivotlow(
         low,
         swingLength,
         swingLength)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

bullSweep =
     not na(lastLow) and
     low < lastLow and
     close > lastLow

bearSweep =
     not na(lastHigh) and
     high > lastHigh and
     close < lastHigh

plotshape(
     showSweeps and bullSweep,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     title="Bull Sweep")

plotshape(
     showSweeps and bearSweep,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     title="Bear Sweep")

//====================================================
// CANDLE QUALITY
//====================================================

totalRange =
     high - low

bodySize =
     math.abs(close - open)

bodyRatio =
     totalRange > 0 ?
     bodySize / totalRange : 0

upperWick =
     high - math.max(open, close)

lowerWick =
     math.min(open, close) - low

upperWickRatio =
     totalRange > 0 ?
     upperWick / totalRange : 0

lowerWickRatio =
     totalRange > 0 ?
     lowerWick / totalRange : 0

strongBody =
     bodyRatio >= minBodyRatio

openingStrongBody =
     bodyRatio >= openingMinBodyRatio

excessiveWick =
     upperWickRatio > 0.6 or
     lowerWickRatio > 0.6

wickCluster =
     excessiveWick and excessiveWick[1]

weakBody =
     bodyRatio < 0.18

badCandleQuality =
     weakBody or wickCluster

shortNegativeBodyBucket =
     blockNegativeShortBodyBucket and
     bodyRatio >= shortBadBodyMin and
     bodyRatio <= shortBadBodyMax

weakBodyLongBlocked =
     blockWeakBodyLongs and
     bodyRatio < liveLongMinBodyRatio

tuesdayLongAllowedMNQ =
     useMNQDayRiskPatch and
     isTuesday and
     bodyRatio >= tuesdayLongMinBodyMNQ

tuesdayWeakLongBlockedMNQ =
     useMNQDayRiskPatch and
     isTuesday and
     bodyRatio < tuesdayLongMinBodyMNQ

thursdayLateBlockedMNQ =
     useMNQDayRiskPatch and
     blockMNQThursdayLate and
     isThursday and
     lateWindow

tuesdayShortBlockedMNQ =
     useMNQDayRiskPatch and
     blockMNQTuesdayShorts and
     isTuesday

longWeekdayBlocked :=
     longWeekdayBlocked or
     tuesdayWeakLongBlockedMNQ or
     thursdayLateBlockedMNQ

tuesdayShortAllowed =
     allowTuesdayShorts and
     isTuesday and
     bodyRatio >= tuesdayShortMinBody

shortWeekdayBlocked =
     (blockThursday and isThursday) or
     (blockTuesday and isTuesday and not tuesdayShortAllowed) or
     tuesdayShortBlockedMNQ or
     thursdayLateBlockedMNQ

weekdayBlocked =
     longWeekdayBlocked and shortWeekdayBlocked

//====================================================
// DISPLACEMENT
//====================================================

bullDisplacement =
     close > open and
     (close - open) > atr * 0.35 * displacementMult

bearDisplacement =
     close < open and
     (open - close) > atr * 0.35 * displacementMult

//====================================================
// CISD
//====================================================

bullCISD =
     close > high[1]

bearCISD =
     close < low[1]

//====================================================
// FVG
//====================================================

bullFVG =
     low > high[2]

bearFVG =
     high < low[2]

if showFVG and bullFVG
    box.new(
         left=bar_index - 2,
         right=bar_index + 5,
         top=low,
         bottom=high[2],
         bgcolor=color.new(color.green, 88),
         border_color=color.lime,
         border_width=1)

if showFVG and bearFVG
    box.new(
         left=bar_index - 2,
         right=bar_index + 5,
         top=low[2],
         bottom=high,
         bgcolor=color.new(color.red, 88),
         border_color=color.red,
         border_width=1)

//====================================================
// ORDER BLOCKS
//====================================================

bullOB =
     close[1] < open[1] and
     close > high[1]

bearOB =
     close[1] > open[1] and
     close < low[1]

plotshape(
     showOB and bullOB,
     style=shape.square,
     location=location.belowbar,
     color=color.new(color.green, 0),
     size=size.tiny,
     title="Bull OB")

plotshape(
     showOB and bearOB,
     style=shape.square,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.tiny,
     title="Bear OB")

//====================================================
// VOLUME FLOW
//====================================================

volSMA =
     ta.sma(volume, 20)

relativeVolume =
     na(volume) or na(volSMA) or volSMA == 0 ?
     1.0 : volume / volSMA

buyPressure =
     close > open and
     relativeVolume > 1.05

sellPressure =
     close < open and
     relativeVolume > 1.05

strongBuyPressure =
     close > open and
     relativeVolume > 1.4

strongSellPressure =
     close < open and
     relativeVolume > 1.4

flowBull =
     buyPressure and close > emaLTF

flowBear =
     sellPressure and close < emaLTF

plotshape(
     showFlow and flowBull,
     style=shape.circle,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     title="Bull Flow")

plotshape(
     showFlow and flowBear,
     style=shape.circle,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     title="Bear Flow")

//====================================================
// MARKET CONDITIONS
//====================================================

flatEMA =
     math.abs(emaSlope) < atr * 0.01

lowVolatility =
     atr < atrSMA * 0.7

compression =
     ta.highest(high, 10) -
     ta.lowest(low, 10) < atr * 1.4

healthyVolatility =
     atr > atrSMA * 0.9

rangeExpansion =
     ta.highest(high, 5) -
     ta.lowest(low, 5) > atr * 2.0

goodFollowThrough =
     healthyVolatility or rangeExpansion

hardBadConditions =
     flatEMA or
     lowVolatility or
     compression or
     badCandleQuality


// HTF volume-flow helper functions.
// These keep ta.sma() outside conditional ternaries so Pine executes it consistently.
f_htfVolumeFlowBull() =>
    volMA = ta.sma(volume, 10)
    volOK = na(volume) or na(volMA) or volMA == 0 ? true : volume > volMA
    volOK and close > open

f_htfVolumeFlowBear() =>
    volMA = ta.sma(volume, 10)
    volOK = na(volume) or na(volMA) or volMA == 0 ? true : volume > volMA
    volOK and close < open

//====================================================
// HTF DATA
//====================================================

htfClose =
     request.security(
         syminfo.tickerid,
         htf,
         close[1],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on)

htfOpen =
     request.security(
         syminfo.tickerid,
         htf,
         open)

htfEMA =
     request.security(
         syminfo.tickerid,
         htf,
         ta.ema(close, emaLength))

htfATR =
     request.security(
         syminfo.tickerid,
         htf,
         ta.atr(14))

htfEMASlope =
     request.security(
         syminfo.tickerid,
         htf,
         ta.ema(close, emaLength) - ta.ema(close, emaLength)[5])

htfVolumeFlowBull =
     request.security(
         syminfo.tickerid,
         htf,
         f_htfVolumeFlowBull())

htfVolumeFlowBear =
     request.security(
         syminfo.tickerid,
         htf,
         f_htfVolumeFlowBear())

htfBullFVG =
     request.security(
         syminfo.tickerid,
         htf,
         low > high[2])

htfBearFVG =
     request.security(
         syminfo.tickerid,
         htf,
         high < low[2])

htfBullCISD =
     request.security(
         syminfo.tickerid,
         htf,
         close > high[1])

htfBearCISD =
     request.security(
         syminfo.tickerid,
         htf,
         close < low[1])

//====================================================
// HTF TREND + DISPLACEMENT
//====================================================

htfBullTrend =
     htfClose > htfEMA

htfBearTrend =
     htfClose < htfEMA

htfBullSlope =
     htfEMASlope > htfATR * 0.03

htfBearSlope =
     htfEMASlope < -htfATR * 0.03

htfBullDisplacement =
     htfClose > htfOpen and
     (htfClose - htfOpen) > htfATR * 0.35 * displacementMult

htfBearDisplacement =
     htfClose < htfOpen and
     (htfOpen - htfClose) > htfATR * 0.35 * displacementMult

//====================================================
// HTF OVEREXTENSION
//====================================================

htfDistance =
     math.abs(htfClose - htfEMA)

htfOverextended =
     htfDistance > htfATR * maxHTFExtension

//====================================================
// HTF SCORE
//====================================================

htfBullScore = 0
htfBearScore = 0

htfBullScore += htfBullTrend        ? 15 : 0
htfBullScore += htfBullSlope        ? 20 : 0
htfBullScore += htfBullDisplacement ? 20 : 0
htfBullScore += htfVolumeFlowBull   ? 20 : 0
htfBullScore += htfBullFVG          ? 10 : 0
htfBullScore += htfBullCISD         ? 10 : 0
htfBullScore += entryWindow         ? 10 : 0

htfBullScore -= middayChop          ? 10 : 0
htfBullScore -= htfOverextended     ? 15 : 0
htfBullScore -= hardBadConditions   ? 10 : 0

htfBearScore += htfBearTrend        ? 15 : 0
htfBearScore += htfBearSlope        ? 20 : 0
htfBearScore += htfBearDisplacement ? 20 : 0
htfBearScore += htfVolumeFlowBear   ? 20 : 0
htfBearScore += htfBearFVG          ? 10 : 0
htfBearScore += htfBearCISD         ? 10 : 0
htfBearScore += entryWindow         ? 10 : 0

htfBearScore -= middayChop          ? 10 : 0
htfBearScore -= htfOverextended     ? 15 : 0
htfBearScore -= hardBadConditions   ? 10 : 0

htfBullScore :=
     math.max(htfBullScore, 0)

htfBearScore :=
     math.max(htfBearScore, 0)

//====================================================
// GOLDEN RANGE + DOMINANCE
//====================================================

bullGoldenRange =
     htfBullScore >= goldenScoreMin and
     htfBullScore <= goldenScoreMax and
     htfBullScore > htfBearScore

bearGoldenRange =
     htfBearScore >= goldenScoreMin and
     htfBearScore <= goldenScoreMax and
     htfBearScore > htfBullScore

bullLeverageRange =
     htfBullScore >= leverageScoreMin and
     htfBullScore <= leverageScoreMax and
     htfBullScore > htfBearScore

bearLeverageRange =
     htfBearScore >= leverageScoreMin and
     htfBearScore <= leverageScoreMax and
     htfBearScore > htfBullScore

bullCautionHigh =
     htfBullScore >= cautionHighMin and
     htfBullScore <= cautionHighMax

bearCautionHigh =
     htfBearScore >= cautionHighMin and
     htfBearScore <= cautionHighMax

bullHighScoreClean =
     allowHighScoreIfClean and
     htfBullScore >= highScoreMin and
     not htfOverextended and
     rangeExpansion and
     strongBody and
     htfBullScore > htfBearScore

bearHighScoreClean =
     allowHighScoreIfClean and
     htfBearScore >= highScoreMin and
     not htfOverextended and
     rangeExpansion and
     strongBody and
     htfBearScore > htfBullScore

bullDominance =
     htfBullScore > htfBearScore + dominanceBuffer

bearDominance =
     htfBearScore > htfBullScore + dominanceBuffer

bullStrongDominance =
     htfBullScore > htfBearScore + strongDominanceBuffer

bearStrongDominance =
     htfBearScore > htfBullScore + strongDominanceBuffer

bullTradableScore =
     bullGoldenRange or bullHighScoreClean

bearTradableScore =
     bearGoldenRange or bearHighScoreClean

goldenRangeActive =
     bullGoldenRange or bearGoldenRange

bgcolor(
     showGoldenScoreBG and goldenRangeActive ?
     color.new(color.yellow, 88) : na)

//====================================================
// HTF SETUPS
//====================================================

htfBullSetup =
     htfBullTrend and
     htfBullScore >= requiredHTFScore and
     bullTradableScore and
     (not blockCounterTrend or bullDominance)

htfBearSetup =
     htfBearTrend and
     htfBearScore >= requiredHTFScore and
     bearTradableScore and
     (not blockCounterTrend or bearDominance)

//====================================================
// MICRO CONFIRMATIONS
// Golden range = 1 confirmation.
// Outside golden range = 2 confirmations.
//====================================================

microBullIFVG =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         low > high[2])

microBearIFVG =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         high < low[2])

microBullCISD =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         close > high[1])

microBearCISD =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         close < low[1])

microBullOB =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         close[1] < open[1] and close > high[1])

microBearOB =
     request.security(
         syminfo.tickerid,
         ltfConfirmTF,
         close[1] > open[1] and close < low[1])

microBullScore =
     (microBullIFVG ? 1 : 0) +
     (microBullCISD ? 1 : 0) +
     (microBullOB   ? 1 : 0)

microBearScore =
     (microBearIFVG ? 1 : 0) +
     (microBearCISD ? 1 : 0) +
     (microBearOB   ? 1 : 0)

microBullConfirm =
     bullGoldenRange ?
     microBullScore >= 1 :
     microBullScore >= 2

microBearConfirm =
     bearGoldenRange ?
     microBearScore >= 1 :
     microBearScore >= 2

//====================================================
// LTF TRIGGERS
//====================================================

trendContinuationBull =
     ltfBullTrend and
     ltfBullSlope and
     (flowBull or strongBuyPressure)

trendContinuationBear =
     ltfBearTrend and
     ltfBearSlope and
     (flowBear or strongSellPressure)

bullRetracement =
     (bullSweep or bullFVG or bullCISD or bullOB) and
     flowBull

bearRetracement =
     (bearSweep or bearFVG or bearCISD or bearOB) and
     flowBear

ltfBullTrigger =
     trendContinuationBull or
     bullRetracement or
     microBullConfirm

ltfBearTrigger =
     trendContinuationBear or
     bearRetracement or
     microBearConfirm

//====================================================
// 5M SIGNAL RULES
//====================================================

isFiveMinuteChart =
     timeframe.isminutes and
     timeframe.multiplier == 5

extreme15mBearTrend =
     htfBearTrend and
     htfBearSlope and
     htfBearScore >= extremeBearScore and
     bearStrongDominance and
     not htfOverextended and
     not hardBadConditions

fiveMinuteShortOK =
     not isFiveMinuteChart or
     not blockFiveMinuteShorts or
     (allowFiveMinuteShortsOnlyIfExtreme and extreme15mBearTrend)

//====================================================
// OPENING WINDOW STRICT FILTER
//====================================================

openLongOK =
     not openingWindow or
     (
         htfBullScore >= 75 and
         bullStrongDominance and
         openingStrongBody and
         microBullScore >= 2
     )

openShortOK =
     not openingWindow or
     (
         htfBearScore >= 75 and
         bearStrongDominance and
         openingStrongBody and
         microBearScore >= 2
     )

//====================================================
// ENTRY QUALITY
//====================================================

entryQualityOK =
     strongBody and
     goodFollowThrough and
     not hardBadConditions and
     not htfOverextended

confirmedOK =
     confirmedOnly ?
     barstate.isconfirmed :
     true

//====================================================
// MISSED MOVE EXCEPTIONS
// Breakout exception catches clean continuation days where PA breaks structure
// but does not print the classic sweep / OB / flow stack.
// Reversal short exception catches high-sweep rejection shorts without opening
// the door to every normal 5m short.
//====================================================

breakoutBodyOK =
     bodyRatio >= breakoutMinBodyRatio

breakoutRangeOK =
     totalRange >= atr * breakoutMinRangeATR

breakoutLongStructure =
     close > ta.highest(high[1], breakoutLookback)

breakoutShortStructure =
     close < ta.lowest(low[1], breakoutLookback)

breakoutExtensionOK =
     htfDistance <= htfATR * breakoutMaxExtensionATR

breakoutLongException =
     useBreakoutException and
     confirmedOK and
     entryWindow and
     close > emaLTF and
     emaSlope > 0 and
     breakoutLongStructure and
     breakoutBodyOK and
     breakoutRangeOK and
     htfBullScore >= breakoutMinHTFScore and
     (microBullScore >= 1 or bullDisplacement or strongBuyPressure) and
     breakoutExtensionOK and
     not lowVolatility and
     not compression

breakoutShortException =
     useBreakoutException and
     confirmedOK and
     entryWindow and
     close < emaLTF and
     emaSlope < 0 and
     breakoutShortStructure and
     breakoutBodyOK and
     breakoutRangeOK and
     htfBearScore >= breakoutMinHTFScore and
     (microBearScore >= 1 or bearDisplacement or strongSellPressure) and
     breakoutExtensionOK and
     not lowVolatility and
     not compression

reversalShortException =
     useReversalShortException and
     confirmedOK and
     entryWindow and
     bearSweep and
     bearDisplacement and
     bearCISD and
     bodyRatio >= reversalShortMinBodyRatio and
     htfBearScore >= reversalShortMinHTFScore and
     microBearScore >= 1 and
     htfDistance <= htfATR * reversalShortMaxExtensionATR and
     not lowVolatility and
     not compression

//====================================================
// PRIOR DAY LIQUIDITY
// Defined before TP/SL so the short iceberg model can use objective logic.
//====================================================

priorDayHigh =
     request.security(
         syminfo.tickerid,
         "D",
         high[1])

priorDayLow =
     request.security(
         syminfo.tickerid,
         "D",
         low[1])

//====================================================
// SHORT ICEBERG STRUCTURE LOGIC
// Short-only add-on. Long logic is intentionally untouched.
// Iceberg shorts are objective-based scalp shorts:
// - stop = last meaningful high + small ATR buffer
// - target = last meaningful low / nearest open downside objective
// - signal must appear before the objective has already been tapped
//====================================================

shortRecentHigh =
     ta.highest(
         high[1],
         shortInvalidationLookback)

// Precision invalidation for iceberg shorts:
// choose the nearest meaningful high above entry, not the widest ATR/range stop.
// This keeps long logic unchanged and makes shorts behave like objective scalps.
float shortMeaningfulHigh = na

if includeSignalHighInShortStop and high > close
    shortMeaningfulHigh := high

if not na(high[1]) and high[1] > close
    shortMeaningfulHigh :=
         na(shortMeaningfulHigh) ?
         high[1] :
         math.min(shortMeaningfulHigh, high[1])

if not na(shortRecentHigh) and shortRecentHigh > close
    shortMeaningfulHigh :=
         na(shortMeaningfulHigh) ?
         shortRecentHigh :
         math.min(shortMeaningfulHigh, shortRecentHigh)

if not na(lastHigh) and lastHigh > close
    shortMeaningfulHigh :=
         na(shortMeaningfulHigh) ?
         lastHigh :
         math.min(shortMeaningfulHigh, lastHigh)

shortStructureStop =
     not na(shortMeaningfulHigh) ?
     shortMeaningfulHigh + atr * shortStopBufferATR :
     high + atr * shortStopBufferATR

shortRecentLow =
     ta.lowest(
         low[1],
         shortObjectiveLookback)

// Precision downside objective:
// choose the closest untapped low below entry first, not the largest distant target.
// This forces iceberg shorts to behave like early objective scalps.
float shortObjective = na

if icebergUseClosestObjective and not na(low[1]) and low[1] < close
    shortObjective := low[1]

if icebergUseClosestObjective and not na(low[2]) and low[2] < close
    shortObjective :=
         na(shortObjective) ?
         low[2] :
         math.max(shortObjective, low[2])

if icebergUseClosestObjective and not na(low[3]) and low[3] < close
    shortObjective :=
         na(shortObjective) ?
         low[3] :
         math.max(shortObjective, low[3])

if icebergUseClosestObjective and not na(low[4]) and low[4] < close
    shortObjective :=
         na(shortObjective) ?
         low[4] :
         math.max(shortObjective, low[4])

if useRecentSwingLiquidity and not na(lastLow) and lastLow < close
    shortObjective :=
         na(shortObjective) ?
         lastLow :
         math.max(shortObjective, lastLow)

if not icebergUseClosestObjective and not na(shortRecentLow) and shortRecentLow < close
    shortObjective :=
         na(shortObjective) ?
         shortRecentLow :
         math.max(shortObjective, shortRecentLow)

if usePriorDayLiquidity and not na(priorDayLow) and priorDayLow < close
    shortObjective :=
         na(shortObjective) ?
         priorDayLow :
         math.max(shortObjective, priorDayLow)

objectiveAlreadyTapped =
     not na(shortObjective) and
     (
         blockIcebergIfSignalTouchesObjective ?
         low <= shortObjective :
         ta.lowest(
             low,
             icebergObjectiveTapLookback) <= shortObjective
     )

shortStructureRisk =
     shortStructureStop - close

shortObjectiveRR =
     not na(shortObjective) and shortStructureRisk > 0 ?
     (close - shortObjective) / shortStructureRisk :
     na

shortEmaExtensionATR =
     atr > 0 ?
     math.abs(close - emaLTF) / atr : 0.0

icebergExtensionOK =
     shortEmaExtensionATR <= maxIcebergEmaExtensionATR

icebergRiskCapOK =
     shortStructureRisk <= maxIcebergRiskPoints

icebergObjectiveOpen =
     not na(shortObjective) and
     low > shortObjective

icebergCloseLocation =
     totalRange > 0 ?
     (close - low) / totalRange : 0.5

icebergCloseNearLow =
     icebergCloseLocation <= icebergMaxCloseLocation

icebergBearImpulse =
     close < open and
     (open - close) > atr * icebergImpulseMult

icebergEarlyBreakdown =
     bearCISD or
     close < low[1] or
     close < ta.lowest(low[1], 2)

icebergRejectionContext =
     bearSweep or
     upperWickRatio >= 0.15 or
     close < open

icebergShortConfluence =
     icebergEarlyBreakdown and
     icebergRejectionContext and
     (microBearScore >= 1 or flowBear or strongSellPressure or bearDisplacement) and
     htfBearScore >= icebergMinBearScore

icebergShortValid =
     useIcebergShortModel and
     confirmedOK and
     entryWindow and
     icebergShortConfluence and
     icebergBearImpulse and
     bodyRatio >= icebergMinBodyRatio and
     relativeVolume >= icebergMinRelativeVolume and
     icebergCloseNearLow and
     not objectiveAlreadyTapped and
     icebergObjectiveOpen and
     icebergExtensionOK and
     icebergRiskCapOK and
     not na(shortObjectiveRR) and
     shortObjectiveRR >= minIcebergObjectiveRR and
     shortStructureRisk > 0 and
     not lowVolatility and
     not compression

prospectiveShortStop =
     useStructureShortStop and icebergShortValid ?
     shortStructureStop :
     high + atr * stopATR

prospectiveShortRisk =
     prospectiveShortStop - close

thursdayWideShortBlockedMNQ =
     useMNQDayRiskPatch and
     isThursday and
     prospectiveShortRisk >= thursdayShortMaxRiskPointsMNQ

shortWeekdayBlocked :=
     shortWeekdayBlocked or
     thursdayWideShortBlockedMNQ

//====================================================
// FINAL RAW SIGNALS
//====================================================

rawLongCandidate =
     (
         confirmedOK and
         entryWindow and
         htfBullSetup and
         ltfBullTrigger and
         entryQualityOK and
         openLongOK
     ) or
     breakoutLongException

rawShortCandidate =
     (
         confirmedOK and
         entryWindow and
         htfBearSetup and
         ltfBearTrigger and
         entryQualityOK and
         openShortOK and
         fiveMinuteShortOK
     ) or
     breakoutShortException or
     reversalShortException or
     icebergShortValid

rawLongSignal =
     not longWeekdayBlocked and
     not weakBodyLongBlocked and
     rawLongCandidate

rawShortSignal =
     not shortWeekdayBlocked and
     not shortNegativeBodyBucket and
     rawShortCandidate

//====================================================
// TP / SL / BE LEVELS
//====================================================

longStop =
     low - atr * stopATR

shortStop =
     prospectiveShortStop

longRisk =
     close - longStop

shortRisk =
     prospectiveShortRisk

longTP =
     close + longRisk * rrTarget

shortTP =
     useStructureShortStop and icebergShortValid and not na(shortObjective) ?
     shortObjective :
     close - shortRisk * rrTarget

longBETrigger =
     close + longRisk * breakEvenTriggerRR

shortBETrigger =
     close - shortRisk * breakEvenTriggerRR

//====================================================
// TARGET SPACE CALCULATION
//====================================================

float nearestLongLiquidity = na
float nearestShortLiquidity = na

if useRecentSwingLiquidity and not na(lastHigh) and lastHigh > close
    nearestLongLiquidity := lastHigh

if usePriorDayLiquidity and not na(priorDayHigh) and priorDayHigh > close
    nearestLongLiquidity :=
         na(nearestLongLiquidity) ?
         priorDayHigh :
         math.min(nearestLongLiquidity, priorDayHigh)

if useRecentSwingLiquidity and not na(lastLow) and lastLow < close
    nearestShortLiquidity := lastLow

if usePriorDayLiquidity and not na(priorDayLow) and priorDayLow < close
    nearestShortLiquidity :=
         na(nearestShortLiquidity) ?
         priorDayLow :
         math.max(nearestShortLiquidity, priorDayLow)

longTargetSpaceRR =
     not na(nearestLongLiquidity) and longRisk > 0 ?
     (nearestLongLiquidity - close) / longRisk :
     na

shortTargetSpaceRR =
     not na(nearestShortLiquidity) and shortRisk > 0 ?
     (close - nearestShortLiquidity) / shortRisk :
     na

longTargetSpaceGood =
     not useTargetSpaceTiering or
     na(longTargetSpaceRR) or
     longTargetSpaceRR >= minTargetSpaceRR

shortTargetSpaceGood =
     not useTargetSpaceTiering or
     na(shortTargetSpaceRR) or
     shortTargetSpaceRR >= minTargetSpaceRR

//====================================================
// EV-BASED TIER ENGINE
// 3 = A+
// 2 = A
// 1 = B / research
// Keeps the old raw signals intact, then ranks them.
//====================================================

// Live-pocket quality conditions.
// These do not delete old raw signals. They mainly decide what deserves A/A+ risk.
longCleanWick =
     lowerWickRatio <= liveLongMaxLowerWickRatio

longStrongBodyLive =
     bodyRatio >= liveLongMinBodyRatio

longAPlusBodyLive =
     bodyRatio >= liveLongAPlusBodyRatio

shortCloseLocation =
     totalRange > 0 ?
     (close - low) / totalRange : 0.5

reversalShortCloseOK =
     shortCloseLocation <= liveShortMaxCloseLocation

liveLongDayOK =
     monThuLogOnly ? (not longWeekdayBlocked and (preferredDay or tuesdayLongAllowedMNQ or (isThursday and not thursdayLateBlockedMNQ))) : not longWeekdayBlocked

liveShortDayOK =
     monThuLogOnly ? (not shortWeekdayBlocked and (preferredDay or (isThursday and not thursdayLateBlockedMNQ and not thursdayWideShortBlockedMNQ))) : not shortWeekdayBlocked

liveLongPocket =
     rawLongSignal and
     liveLongDayOK and
     longStrongBodyLive and
     longCleanWick and
     not hardBadConditions and
     not htfOverextended and
     (bullGoldenRange or bullHighScoreClean or breakoutLongException) and
     bullDominance and
     microBullConfirm

liveLongPocketAPlus =
     liveLongPocket and
     longAPlusBodyLive and
     longTargetSpaceGood and
     (bullLeverageRange or breakoutLongException) and
     bullStrongDominance and
     (primaryWindow or secondaryWindow)

liveReversalShortPocket =
     rawShortSignal and
     reversalShortException and
     liveShortDayOK and
     bodyRatio >= liveShortMinBodyRatio and
     reversalShortCloseOK and
     shortTargetSpaceGood and
     microBearScore >= 1 and
     not lowVolatility and
     not compression

liveReversalShortPocketAPlus =
     liveReversalShortPocket and
     primaryWindow and
     microBearScore >= 2 and
     bearStrongDominance

liveIcebergShortPocket =
     rawShortSignal and
     icebergShortValid and
     liveShortDayOK and
     (primaryWindow or secondaryWindow or lateWindow)

liveIcebergShortPocketAPlus =
     liveIcebergShortPocket and
     primaryWindow and
     shortObjectiveRR >= minIcebergObjectiveRR + 0.30 and
     icebergCloseNearLow and
     (microBearScore >= 1 or strongSellPressure) and
     (bearDominance or htfBearScore >= icebergMinBearScore)

// Tuesday short exception:
// Tuesday longs remain blocked, but the historical positive pocket was
// strong-bodied Tuesday shorts. This lets those qualify for live tiering
// without reopening all Tuesday trades.
liveTuesdayShortPocket =
     rawShortSignal and
     tuesdayShortAllowed and
     not shortNegativeBodyBucket and
     bodyRatio >= tuesdayShortMinBody and
     microBearScore >= 1 and
     not lowVolatility and
     not compression

liveTuesdayShortPocketAPlus =
     liveTuesdayShortPocket and
     bodyRatio >= 0.80 and
     shortTargetSpaceGood and
     (primaryWindow or secondaryWindow)

longAPlusBase =
     (
         rawLongSignal and
         bullLeverageRange and
         primaryWindow and
         preferredDay and
         bullStrongDominance and
         microBullScore >= 2 and
         longTargetSpaceGood and
         not bullCautionHigh
     ) or
     (
         breakoutLongException and
         primaryWindow and
         preferredDay and
         microBullScore >= 2 and
         longTargetSpaceGood and
         htfBullScore >= 50
     )

longABase =
     (
         rawLongSignal and
         (bullGoldenRange or bullHighScoreClean) and
         (primaryWindow or secondaryWindow or lateWindow) and
         bullDominance and
         microBullConfirm and
         not htfOverextended and
         not hardBadConditions
     ) or
     (
         breakoutLongException and
         (primaryWindow or secondaryWindow or lateWindow) and
         microBullScore >= 1 and
         not lowVolatility and
         not compression
     )

shortAPlusBase =
     (
         rawShortSignal and
         bearLeverageRange and
         primaryWindow and
         preferredDay and
         bearStrongDominance and
         microBearScore >= 2 and
         shortTargetSpaceGood and
         not bearCautionHigh and
         extreme15mBearTrend
     ) or
     (
         reversalShortException and
         primaryWindow and
         preferredDay and
         microBearScore >= 2 and
         shortTargetSpaceGood
     ) or
     (
         icebergShortValid and
         primaryWindow and
         shortTargetSpaceGood and
         shortObjectiveRR >= minIcebergObjectiveRR
     )

shortABase =
     (
         rawShortSignal and
         (bearGoldenRange or bearHighScoreClean) and
         (primaryWindow or secondaryWindow) and
         preferredDay and
         bearStrongDominance and
         microBearConfirm and
         not htfOverextended and
         not hardBadConditions and
         (extreme15mBearTrend or not isFiveMinuteChart)
     ) or
     (
         reversalShortException and
         (primaryWindow or secondaryWindow or lateWindow) and
         microBearScore >= 1 and
         not lowVolatility and
         not compression
     ) or
     (
         icebergShortValid and
         (primaryWindow or secondaryWindow or lateWindow) and
         not lowVolatility and
         not compression
     )

longAPlus =
     useLivePocketTiering ?
     liveLongPocketAPlus :
     longAPlusBase

longA =
     useLivePocketTiering ?
     liveLongPocket :
     longABase

longB =
     rawLongSignal

shortAPlus =
     useLivePocketTiering ?
     (liveReversalShortPocketAPlus or liveIcebergShortPocketAPlus or liveTuesdayShortPocketAPlus) :
     shortAPlusBase

shortA =
     useLivePocketTiering ?
     (liveReversalShortPocket or liveIcebergShortPocket or liveTuesdayShortPocket) :
     shortABase

shortB =
     rawShortSignal

longTierRaw =
     longAPlus ? 3 :
     longA ? 2 :
     longB ? 1 :
     0

shortTierRaw =
     shortAPlus ? 3 :
     shortA ? 2 :
     shortB ? 1 :
     0

longTier =
     useLivePocketTiering ?
     longTierRaw :
     weakDay and longTierRaw > 1 ? longTierRaw - 1 :
     lateWindow and longTierRaw > 1 ? longTierRaw - 1 :
     not longTargetSpaceGood and longTierRaw > 1 ? longTierRaw - 1 :
     longTierRaw

shortTier =
     useLivePocketTiering ?
     (normalShortsLogOnly and not liveReversalShortPocket and not liveIcebergShortPocket and not liveTuesdayShortPocket and shortTierRaw > 1 ? 1 : shortTierRaw) :
     shortTierRaw > 1 ? shortTierRaw - 1 :
     weakDay and shortTierRaw > 1 ? shortTierRaw - 1 :
     lateWindow and shortTierRaw > 1 ? shortTierRaw - 1 :
     not shortTargetSpaceGood and shortTierRaw > 1 ? shortTierRaw - 1 :
     shortTierRaw

setupTier =
     math.max(longTier, shortTier)

setupTierText =
     setupTier == 3 ? "A+" :
     setupTier == 2 ? "A" :
     setupTier == 1 ? "B" :
     "NONE"

//====================================================
// ACTIVE TRADE STATE
//====================================================

var bool  tradeActive     = false
var int   activeDir       = 0
var int   activeStartBar  = na
var float activeEntry     = na
var float activeStop      = na
var float activeTP        = na
var float activeBETrigger = na
var bool  beActive        = false
var int   activeTier      = 0

longPermissionOK =
     longTier >= tierThreshold

shortPermissionOK =
     shortTier >= tierThreshold

longSignal =
     rawLongSignal and
     not tradeActive and
     (not enforceSignalPermission or longPermissionOK)

shortSignal =
     rawShortSignal and
     not tradeActive and
     (not enforceSignalPermission or shortPermissionOK)

researchLong =
     showResearchLabels and
     rawLongSignal and
     longTier == 1 and
     not tradeActive

researchShort =
     showResearchLabels and
     rawShortSignal and
     shortTier == 1 and
     not tradeActive

priorityBull =
     showPriorityBG and
     longTier >= 2 and
     not tradeActive

priorityBear =
     showPriorityBG and
     shortTier >= 2 and
     not tradeActive

bgcolor(
     priorityBull ?
     color.new(color.green, 92) : na)

bgcolor(
     priorityBear ?
     color.new(color.red, 92) : na)

if longSignal
    tradeActive     := true
    activeDir       := 1
    activeStartBar  := bar_index
    activeEntry     := close
    activeStop      := longStop
    activeTP        := longTP
    activeBETrigger := longBETrigger
    beActive        := false
    activeTier      := longTier

if shortSignal
    tradeActive     := true
    activeDir       := -1
    activeStartBar  := bar_index
    activeEntry     := close
    activeStop      := shortStop
    activeTP        := shortTP
    activeBETrigger := shortBETrigger
    beActive        := false
    activeTier      := shortTier

barsInTrade =
     tradeActive ?
     bar_index - activeStartBar : 0

noonTimeout =
     tradeActive and noonExitTime

backupTimeout =
     tradeActive and barsInTrade >= backupTimeoutBars

//====================================================
// EXIT EVENT EXPORT FLAGS
// 1 = TP
// -1 = SL
// 0 = BE
// 2 = 12:00 exit
// 3 = backup timeout
//====================================================

bool tpExitEvent = false
bool slExitEvent = false
bool beExitEvent = false
bool noonExitEvent = false
bool timeoutExitEvent = false
float exitR = na

//====================================================
// LONG MANAGEMENT
//====================================================

if tradeActive and activeDir == 1

    if high >= activeTP
        tpExitEvent := true
        exitR :=
             (activeTP - activeEntry) /
             math.max(activeEntry - activeStop, syminfo.mintick)

        if showMgmt
            label.new(
                 bar_index,
                 activeTP,
                 "TP HIT",
                 style=label.style_label_down,
                 color=color.lime,
                 textcolor=color.black,
                 size=size.small)

        tradeActive := false

    else
        if useBreakEven and not beActive and high >= activeBETrigger
            beActive := true

            if showMgmt
                label.new(
                     bar_index,
                     activeBETrigger,
                     "BE ARMED",
                     style=label.style_label_down,
                     color=color.gray,
                     textcolor=color.white,
                     size=size.tiny)

        if low <= (beActive ? activeEntry : activeStop)

            if beActive
                beExitEvent := true
                exitR := 0.0
            else
                slExitEvent := true
                exitR := -1.0

            if showMgmt
                label.new(
                     bar_index,
                     beActive ? activeEntry : activeStop,
                     beActive ? "BE EXIT" : "SL HIT",
                     style=label.style_label_down,
                     color=beActive ? color.gray : color.red,
                     textcolor=color.white,
                     size=size.small)

            tradeActive := false

        else if noonTimeout or backupTimeout
            noonExitEvent := noonTimeout
            timeoutExitEvent := backupTimeout and not noonTimeout
            exitR :=
                 (close - activeEntry) /
                 math.max(activeEntry - activeStop, syminfo.mintick)

            if showMgmt
                label.new(
                     bar_index,
                     close,
                     noonTimeout ? "12:00 EXIT" : "TIMEOUT",
                     style=label.style_label_left,
                     color=color.gray,
                     textcolor=color.white,
                     size=size.small)

            tradeActive := false

//====================================================
// SHORT MANAGEMENT
//====================================================

if tradeActive and activeDir == -1

    if low <= activeTP
        tpExitEvent := true
        exitR :=
             (activeEntry - activeTP) /
             math.max(activeStop - activeEntry, syminfo.mintick)

        if showMgmt
            label.new(
                 bar_index,
                 activeTP,
                 "TP HIT",
                 style=label.style_label_up,
                 color=color.lime,
                 textcolor=color.black,
                 size=size.small)

        tradeActive := false

    else
        if useBreakEven and not beActive and low <= activeBETrigger
            beActive := true

            if showMgmt
                label.new(
                     bar_index,
                     activeBETrigger,
                     "BE ARMED",
                     style=label.style_label_up,
                     color=color.gray,
                     textcolor=color.white,
                     size=size.tiny)

        if high >= (beActive ? activeEntry : activeStop)

            if beActive
                beExitEvent := true
                exitR := 0.0
            else
                slExitEvent := true
                exitR := -1.0

            if showMgmt
                label.new(
                     bar_index,
                     beActive ? activeEntry : activeStop,
                     beActive ? "BE EXIT" : "SL HIT",
                     style=label.style_label_up,
                     color=beActive ? color.gray : color.red,
                     textcolor=color.white,
                     size=size.small)

            tradeActive := false

        else if noonTimeout or backupTimeout
            noonExitEvent := noonTimeout
            timeoutExitEvent := backupTimeout and not noonTimeout
            exitR :=
                 (activeEntry - close) /
                 math.max(activeStop - activeEntry, syminfo.mintick)

            if showMgmt
                label.new(
                     bar_index,
                     close,
                     noonTimeout ? "12:00 EXIT" : "TIMEOUT",
                     style=label.style_label_left,
                     color=color.gray,
                     textcolor=color.white,
                     size=size.small)

            tradeActive := false

//====================================================
// FORECAST BACKGROUND
//====================================================

bullForecast =
     showForecast and
     htfBullScore >= goldenScoreMin and
     htfBullScore > htfBearScore and
     not htfOverextended

bearForecast =
     showForecast and
     htfBearScore >= goldenScoreMin and
     htfBearScore > htfBullScore and
     not htfOverextended

bgcolor(
     bullForecast ? color.new(color.green, 93) : na)

bgcolor(
     bearForecast ? color.new(color.red, 93) : na)

//====================================================
// LEVEL PLOTS
//====================================================

plot(
     showLevels and longSignal ? longTP : na,
     color=color.lime,
     linewidth=2,
     title="Long TP")

plot(
     showLevels and longSignal ? longStop : na,
     color=color.red,
     linewidth=2,
     title="Long SL")

plot(
     showLevels and longSignal and useBreakEven ? longBETrigger : na,
     color=color.gray,
     linewidth=1,
     title="Long BE Trigger")

plot(
     showLevels and shortSignal ? shortTP : na,
     color=color.lime,
     linewidth=2,
     title="Short TP")

plot(
     showLevels and shortSignal ? shortStop : na,
     color=color.red,
     linewidth=2,
     title="Short SL")

plot(
     showLevels and shortSignal and useBreakEven ? shortBETrigger : na,
     color=color.gray,
     linewidth=1,
     title="Short BE Trigger")

plot(
     showLevels and tradeActive and beActive ? activeEntry : na,
     color=color.gray,
     linewidth=2,
     title="Active Break Even",
     style=plot.style_linebr)

plot(
     showLevels and tradeActive ? activeTP : na,
     color=color.new(color.lime, 50),
     linewidth=1,
     title="Active TP",
     style=plot.style_linebr)

plot(
     showLevels and tradeActive ? (beActive ? activeEntry : activeStop) : na,
     color=color.new(color.red, 50),
     linewidth=1,
     title="Active Stop / BE",
     style=plot.style_linebr)

//====================================================
// ENTRY LABELS
//====================================================

longTierLabel =
     longTier == 3 ? "A+ LONG" :
     longTier == 2 ? "A LONG" :
     "B LONG"

shortTierLabel =
     shortTier == 3 ? "A+ SHORT" :
     shortTier == 2 ? "A SHORT" :
     "B SHORT"

if showSignals and longSignal
    label.new(
         bar_index,
         low,
         text=
             longTierLabel + "\n" +
             "HTF: " + str.tostring(htfBullScore) +
             "\nZONE: " + (bullGoldenRange ? "GOLDEN" : "HIGH CLEAN") +
             "\n1M: " + str.tostring(microBullScore) +
             "\nVOL: " + str.tostring(math.round(relativeVolume, 2)) + "x" +
             "\nRR: " + str.tostring(rrTarget) +
             "\nBE: " + str.tostring(breakEvenTriggerRR) + "R" +
             "\nENTRY: " + str.tostring(math.round(close, 1)) +
             "\nTIME: " + str.format("{0,number,00}:{1,number,00}", hourNY, minuteNY) +
             "\nTP: " + str.tostring(math.round(longTP, 1)) +
             "\nSL: " + str.tostring(math.round(longStop, 1)),
         style=label.style_label_up,
         color=bullGoldenRange ? color.lime : color.new(color.green, 30),
         textcolor=color.black,
         size=size.small)

if showSignals and shortSignal
    label.new(
         bar_index,
         high,
         text=
             shortTierLabel + "\n" +
             "HTF: " + str.tostring(htfBearScore) +
             "\nZONE: " + (bearGoldenRange ? "GOLDEN" : "HIGH CLEAN") +
             "\nTYPE: " + (icebergShortValid ? "ICEBERG" : reversalShortException ? "REV" : "NORMAL") +
             "\nOBJ RR: " + str.tostring(shortObjectiveRR, "#.##") +
             "\n1M: " + str.tostring(microBearScore) +
             "\nVOL: " + str.tostring(math.round(relativeVolume, 2)) + "x" +
             "\nRR: " + (icebergShortValid ? str.tostring(shortObjectiveRR, "#.##") : str.tostring(rrTarget)) +
             "\nBE: " + str.tostring(breakEvenTriggerRR) + "R" +
             "\nENTRY: " + str.tostring(math.round(close, 1)) +
             "\nTIME: " + str.format("{0,number,00}:{1,number,00}", hourNY, minuteNY) +
             "\nTP: " + str.tostring(math.round(shortTP, 1)) +
             "\nSL: " + str.tostring(math.round(shortStop, 1)),
         style=label.style_label_down,
         color=bearGoldenRange ? color.red : color.new(color.red, 30),
         textcolor=color.white,
         size=size.small)

if researchLong
    label.new(
         bar_index,
         low,
         "B LONG LOG",
         style=label.style_label_up,
         color=color.new(color.gray, 25),
         textcolor=color.white,
         size=size.tiny)

if researchShort
    label.new(
         bar_index,
         high,
         "B SHORT LOG",
         style=label.style_label_down,
         color=color.new(color.gray, 25),
         textcolor=color.white,
         size=size.tiny)

//====================================================
// PERMISSION ENGINE
//====================================================

tradePermission =
     tradeActive ? "MANAGE ACTIVE" :
     rawShortCandidate and tuesdayShortBlockedMNQ ? "TUE SHORT BLOCKED" :
     rawLongCandidate and tuesdayWeakLongBlockedMNQ ? "TUE LONG BODY BLOCK" :
     rawLongCandidate and thursdayLateBlockedMNQ ? "THU LATE BLOCKED" :
     rawShortCandidate and thursdayWideShortBlockedMNQ ? "THU SHORT RISK BLOCK" :
     rawLongCandidate and longWeekdayBlocked ? "LONG DAY BLOCKED" :
     rawShortCandidate and shortWeekdayBlocked ? "SHORT DAY BLOCKED" :
     rawShortCandidate and shortNegativeBodyBucket ? "SHORT BODY BLOCKED" :
     longSignal and longTier == 3 ? "A+ LONG" :
     longSignal and longTier == 2 ? "A LONG" :
     longSignal and longTier == 1 ? "B LONG LOG" :
     shortSignal and shortTier == 3 ? "A+ SHORT" :
     shortSignal and shortTier == 2 ? "A SHORT" :
     shortSignal and shortTier == 1 ? "B SHORT LOG" :
     icebergShortValid ? "ICEBERG SHORT READY" :
     not entryWindow ? "NO NEW ENTRIES" :
     isFiveMinuteChart and htfBearSetup and not fiveMinuteShortOK ? "5M SHORT BLOCKED" :
     htfBullSetup and not ltfBullTrigger ? "WAIT LONG TRIGGER" :
     htfBearSetup and not ltfBearTrigger ? "WAIT SHORT TRIGGER" :
     htfOverextended ? "WAIT - EXTENDED" :
     hardBadConditions ? "NO TRADE - CHOP" :
     "NO TRADE"

//====================================================
// CLEAN PANEL
//====================================================

var table panel =
     table.new(
         position.top_right,
         2,
         19,
         border_color=color.new(color.gray, 70),
         border_width=1)

if barstate.islast and showPanel

    table.cell(panel, 0, 0, "MODE", text_color=color.silver, bgcolor=color.new(color.gray, 82))
    table.cell(panel, 1, 0, riskMode, text_color=color.white, bgcolor=color.new(color.gray, 82))

    table.cell(panel, 0, 1, "PERMISSION", text_color=color.silver, bgcolor=color.new(color.gray, 82))
    table.cell(panel, 1, 1, tradePermission, text_color=str.contains(tradePermission, "LONG") ? color.lime : str.contains(tradePermission, "SHORT") ? color.red : tradePermission == "MANAGE ACTIVE" ? color.yellow : str.contains(tradePermission, "BLOCKED") ? color.orange : color.gray, bgcolor=color.new(color.gray, 82))

    table.cell(panel, 0, 2, "SETUP TIER", text_color=color.silver)
    table.cell(panel, 1, 2, setupTierText, text_color=setupTier == 3 ? color.lime : setupTier == 2 ? color.yellow : setupTier == 1 ? color.gray : color.red)

    table.cell(panel, 0, 3, "DAY", text_color=color.silver)
    table.cell(panel, 1, 3, tuesdayShortBlockedMNQ ? "TUE NO SHORT" : tuesdayLongAllowedMNQ ? "TUE LONG OK" : thursdayLateBlockedMNQ ? "THU LATE BLOCK" : thursdayWideShortBlockedMNQ ? "THU RISK BLOCK" : longWeekdayBlocked and shortWeekdayBlocked ? "BLOCKED" : bestDay ? "WED BEST" : isMonday ? "MON OK" : isFriday ? "FRI OK" : isThursday ? "THU OK" : "OK", text_color=tuesdayShortBlockedMNQ or thursdayLateBlockedMNQ or thursdayWideShortBlockedMNQ ? color.orange : tuesdayLongAllowedMNQ ? color.lime : longWeekdayBlocked and shortWeekdayBlocked ? color.red : bestDay ? color.lime : color.yellow)

    table.cell(panel, 0, 4, "TIME", text_color=color.silver)
    table.cell(panel, 1, 4, primaryWindow ? "9:30-9:59" : secondaryWindow ? "10:00-10:29" : lateWindow ? "10:30-10:59" : "CLOSED", text_color=primaryWindow ? color.lime : secondaryWindow ? color.yellow : lateWindow ? color.orange : color.gray)

    table.cell(panel, 0, 5, "BULL / BEAR", text_color=color.silver)
    table.cell(panel, 1, 5, str.tostring(htfBullScore) + " / " + str.tostring(htfBearScore), text_color=htfBullScore > htfBearScore ? color.lime : htfBearScore > htfBullScore ? color.red : color.gray)

    table.cell(panel, 0, 6, "ZONE", text_color=color.silver)
    table.cell(panel, 1, 6, goldenRangeActive ? "GOLDEN" : bullHighScoreClean or bearHighScoreClean ? "HIGH CLEAN" : "OUTSIDE", text_color=goldenRangeActive ? color.lime : bullHighScoreClean or bearHighScoreClean ? color.yellow : color.gray)

    table.cell(panel, 0, 7, "DOMINANCE", text_color=color.silver)
    table.cell(panel, 1, 7, bullStrongDominance ? "BULL STRONG" : bearStrongDominance ? "BEAR STRONG" : bullDominance ? "BULL" : bearDominance ? "BEAR" : "WEAK", text_color=bullDominance ? color.lime : bearDominance ? color.red : color.gray)

    table.cell(panel, 0, 8, "MICRO", text_color=color.silver)
    table.cell(panel, 1, 8, microBullConfirm ? "BULL " + str.tostring(microBullScore) : microBearConfirm ? "BEAR " + str.tostring(microBearScore) : "WAIT", text_color=microBullConfirm ? color.lime : microBearConfirm ? color.red : color.gray)

    table.cell(panel, 0, 9, "HTF / LTF", text_color=color.silver)
    table.cell(panel, 1, 9, (htfBullSetup ? "HTF BULL" : htfBearSetup ? "HTF BEAR" : "HTF WAIT") + " / " + (ltfBullTrigger ? "LTF LONG" : ltfBearTrigger ? "LTF SHORT" : "LTF WAIT"), text_color=htfBullSetup or ltfBullTrigger ? color.lime : htfBearSetup or ltfBearTrigger ? color.red : color.gray)

    table.cell(panel, 0, 10, "MARKET", text_color=color.silver)
    table.cell(panel, 1, 10, hardBadConditions ? "CHOPPY" : htfOverextended ? "EXTENDED" : "OK", text_color=hardBadConditions or htfOverextended ? color.red : color.lime)

    table.cell(panel, 0, 11, "LONG BODY", text_color=color.silver)
    table.cell(panel, 1, 11, str.tostring(bodyRatio, "#.##"), text_color=bodyRatio >= liveLongAPlusBodyRatio ? color.lime : bodyRatio >= liveLongMinBodyRatio ? color.yellow : color.gray)

    table.cell(panel, 0, 12, "SHORT BODY", text_color=color.silver)
    table.cell(panel, 1, 12, shortNegativeBodyBucket ? "BLOCK " + str.tostring(bodyRatio, "#.##") : str.tostring(bodyRatio, "#.##"), text_color=shortNegativeBodyBucket ? color.red : color.gray)

    table.cell(panel, 0, 13, "LIVE POCKET", text_color=color.silver)
    table.cell(panel, 1, 13, liveLongPocketAPlus ? "A+ LONG" : liveLongPocket ? "A LONG" : liveIcebergShortPocketAPlus ? "A+ ICEBERG" : liveIcebergShortPocket or liveReversalShortPocket ? "A SHORT" : "WAIT", text_color=liveLongPocket ? color.lime : liveIcebergShortPocket or liveReversalShortPocket ? color.red : color.gray)

    table.cell(panel, 0, 14, "ICEBERG", text_color=color.silver)
    table.cell(panel, 1, 14, icebergShortValid ? "VALID" : objectiveAlreadyTapped ? "OBJ TAPPED" : "WAIT", text_color=icebergShortValid ? color.red : objectiveAlreadyTapped ? color.orange : color.gray)

    table.cell(panel, 0, 15, "SHORT OBJ RR", text_color=color.silver)
    table.cell(panel, 1, 15, str.tostring(shortObjectiveRR, "#.##"), text_color=icebergShortValid ? color.lime : color.gray)

    table.cell(panel, 0, 16, "RR / STOP", text_color=color.silver)
    table.cell(panel, 1, 16, str.tostring(rrTarget) + " / " + str.tostring(stopATR), text_color=color.white)

    table.cell(panel, 0, 17, "TRADE", text_color=color.silver)
    table.cell(panel, 1, 17, tradeActive ? beActive ? "ACTIVE - BE" : "ACTIVE" : "NONE", text_color=tradeActive ? color.yellow : color.gray)

    table.cell(panel, 0, 18, "FILTERS", text_color=color.silver, bgcolor=color.new(color.gray, 82))
    table.cell(panel, 1, 18, "No Tue/Thu | Block S 0.55-0.65", text_color=color.white, bgcolor=color.new(color.gray, 82))

//====================================================
// CSV EXPORT DATA
//====================================================

exportSignal =
     longSignal ? 1 :
     shortSignal ? -1 :
     0

exportRawSignal =
     rawLongSignal ? 1 :
     rawShortSignal ? -1 :
     0

exportSetupTier =
     setupTier

exportLivePocket =
     liveLongPocket or liveReversalShortPocket or liveIcebergShortPocket or liveTuesdayShortPocket ? 1 : 0

exportIcebergShort =
     icebergShortValid ? 1 : 0

exportObjectiveTapped =
     objectiveAlreadyTapped ? 1 : 0

exportIcebergBlocked =
     (useIcebergShortModel and rawShortCandidate and objectiveAlreadyTapped) or
     (rawShortCandidate and shortNegativeBodyBucket) or
     (rawShortCandidate and shortWeekdayBlocked) ? 1 : 0

exportShortObjectiveRR =
     shortObjectiveRR

exportShortStructureStop =
     shortStructureStop

exportShortObjective =
     shortObjective

exportLivePermission =
     longSignal ? (longPermissionOK ? 1 : 0) :
     shortSignal ? (shortPermissionOK ? 1 : 0) :
     na

exportHTFScore =
     rawLongSignal ? htfBullScore :
     rawShortSignal ? htfBearScore :
     na

exportOpposingHTFScore =
     rawLongSignal ? htfBearScore :
     rawShortSignal ? htfBullScore :
     na

exportEntry =
     longSignal or shortSignal ?
     close : na

exportTP =
     longSignal ? longTP :
     shortSignal ? shortTP :
     na

exportSL =
     longSignal ? longStop :
     shortSignal ? shortStop :
     na

exportBETrigger =
     longSignal ? longBETrigger :
     shortSignal ? shortBETrigger :
     na

exportGoldenRange =
     goldenRangeActive ? 1 : 0

exportHighScoreClean =
     bullHighScoreClean or bearHighScoreClean ? 1 : 0

exportEntryWindow =
     entryWindow ? 1 : 0

exportOpeningWindow =
     openingWindow ? 1 : 0

exportOverextended =
     htfOverextended ? 1 : 0

exportBodyRatio =
     bodyRatio

exportRelativeVolume =
     relativeVolume

exportMicroScore =
     longSignal ? microBullScore :
     shortSignal ? microBearScore :
     na

exportFiveMinuteShortOK =
     fiveMinuteShortOK ? 1 : 0

exportExtreme15mBearTrend =
     extreme15mBearTrend ? 1 : 0

exportTargetSpaceRR =
     rawLongSignal ? longTargetSpaceRR :
     rawShortSignal ? shortTargetSpaceRR :
     na

exportPreferredDay =
     preferredDay ? 1 : 0

exportBestDay =
     bestDay ? 1 : 0

exportWeakDay =
     weakDay ? 1 : 0

exportPrimaryWindow =
     primaryWindow ? 1 : 0

exportSecondaryWindow =
     secondaryWindow ? 1 : 0

exportLateWindow =
     lateWindow ? 1 : 0

exportExitType =
     tpExitEvent ? 1 :
     slExitEvent ? -1 :
     beExitEvent ? 0 :
     noonExitEvent ? 2 :
     timeoutExitEvent ? 3 :
     na

// Reduced export set to stay below TradingView's 64-plot limit.
// Full logic is unchanged; only nonessential hidden CSV plots were removed.
plot(exportSignal, title="EXPORT Signal Direction", display=display.none)
plot(exportRawSignal, title="EXPORT Raw Signal Direction", display=display.none)
plot(exportSetupTier, title="EXPORT Setup Tier", display=display.none)
plot(exportLivePocket, title="EXPORT Live Pocket", display=display.none)
plot(exportIcebergShort, title="EXPORT Iceberg Short", display=display.none)
plot(exportObjectiveTapped, title="EXPORT Objective Tapped", display=display.none)
plot(exportIcebergBlocked, title="EXPORT Iceberg Blocked", display=display.none)
plot(exportShortObjectiveRR, title="EXPORT Short Objective RR", display=display.none)
plot(exportHTFScore, title="EXPORT HTF Score", display=display.none)
plot(exportEntry, title="EXPORT Entry", display=display.none)
plot(exportTP, title="EXPORT TP", display=display.none)
plot(exportSL, title="EXPORT SL", display=display.none)
plot(exportExitType, title="EXPORT Exit Type", display=display.none)
plot(exitR, title="EXPORT Exit R", display=display.none)

//====================================================
//====================================================
// ALERTS - RESTORED v14 LIVE BEHAVIOR + LIVE LOCK
// No generic EV reject. No soft bleed blocks.
// Keeps the original v14 promising signal logic, then locks the live alert
// once the condition appears during the bar.
//====================================================

promisingAPlusLong =
     longSignal and
     longTier == 3 and
     liveLongPocketAPlus and
     not longWeekdayBlocked

promisingALong =
     longSignal and
     longTier == 2 and
     liveLongPocket and
     not longWeekdayBlocked

promisingShort =
     shortSignal and
     shortTier >= 2 and
     (liveIcebergShortPocket or liveReversalShortPocket or liveTuesdayShortPocket) and
     not shortWeekdayBlocked and
     not shortNegativeBodyBucket

// Original executable set expanded for full automation:
// ALL v14 long/short signals are live-locked for automation, including B.
// This is intended to match the full current automated signal set / 529-trade behavior.

// Intrabar one-shot locks.
// If the live condition appears and then disappears, the alert still fires once
// during that bar. This preserves the v13/v14 live behavior while preventing
// duplicate flicker alerts on the same candle.
varip bool sentLongAll = false
varip bool sentShortAll = false

if barstate.isnew
    sentLongAll := false
    sentShortAll := false

bool firedLongAll = false
bool firedShortAll = false

if longSignal and not sentLongAll
    firedLongAll := true
    sentLongAll  := true

if shortSignal and not sentShortAll
    firedShortAll := true
    sentShortAll  := true

// Tier-specific fired flags for labels, CSV, and optional alert creation.
bool firedAPlusLong = firedLongAll and longTier == 3
bool firedALong     = firedLongAll and longTier == 2
bool firedBLong     = firedLongAll and longTier == 1

bool firedAPlusShort = firedShortAll and shortTier == 3
bool firedAShort     = firedShortAll and shortTier == 2
bool firedBShort     = firedShortAll and shortTier == 1

// Backward-compatible short fired flag.
bool firedShort = firedShortAll

promisingTrade =
     firedLongAll or
     firedShortAll

//====================================================
// CSV / DATA EXPORT - RESTORED v14 + LOCK FIELDS
// These are data-only fields. They do not block trades.
//====================================================

csvSignalSide =
     longSignal ? 1 :
     shortSignal ? -1 :
     0

csvSetupTier =
     setupTier

csvSetupGroup =
     setupTier >= 2 ? 2 :
     setupTier == 1 ? 1 :
     0

csvAPlusSetup =
     setupTier == 3 ? 1 : 0

csvASetup =
     setupTier == 2 ? 1 : 0

csvAAPlusSetup =
     setupTier >= 2 ? 1 : 0

csvBSetup =
     setupTier == 1 ? 1 : 0

csvLongTier =
     longTier

csvShortTier =
     shortTier

csvAlertFiredDirection =
     firedAPlusLong or firedALong ? 1 :
     firedShort ? -1 :
     0

csvAlertFiredTier =
     firedAPlusLong ? 3 :
     firedALong ? 2 :
     firedShort ? shortTier :
     0

csvStopPoints =
     longSignal ? longRisk :
     shortSignal ? shortRisk :
     na

csvTargetPoints =
     longSignal ? math.abs(longTP - close) :
     shortSignal ? math.abs(close - shortTP) :
     na

csvLiveLockEnabled =
     1

plot(csvSignalSide, title="CSV Signal Side 1Long -1Short", display=display.data_window)
plot(csvSetupTier, title="CSV Setup Tier 3Aplus 2A 1B", display=display.data_window)
plot(csvSetupGroup, title="CSV Setup Group 2AAplus 1B", display=display.data_window)
plot(csvAPlusSetup, title="CSV APlus Setup", display=display.data_window)
plot(csvASetup, title="CSV A Setup", display=display.data_window)
plot(csvAAPlusSetup, title="CSV AAPlus Setup", display=display.data_window)
plot(csvBSetup, title="CSV B Setup", display=display.data_window)
plot(csvLongTier, title="CSV Long Tier", display=display.data_window)
plot(csvShortTier, title="CSV Short Tier", display=display.data_window)
plot(csvAlertFiredDirection, title="CSV Alert Fired Direction", display=display.data_window)
plot(csvAlertFiredTier, title="CSV Alert Fired Tier", display=display.data_window)
plot(csvStopPoints, title="CSV Stop Points", display=display.data_window)
plot(csvTargetPoints, title="CSV Target Points", display=display.data_window)
plot(csvLiveLockEnabled, title="CSV Live Lock Enabled", display=display.data_window)

//====================================================
// PERMANENT LIVE-FIRED LABELS
//====================================================

if showSignals and firedAPlusLong
    label.new(
         bar_index,
         low,
         "A+ LONG\nLOCKED",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

if showSignals and firedALong
    label.new(
         bar_index,
         low,
         "A LONG\nLOCKED",
         style=label.style_label_up,
         color=color.new(color.green, 20),
         textcolor=color.black,
         size=size.small)

if showSignals and firedBLong
    label.new(
         bar_index,
         low,
         "B LONG\nLOCKED",
         style=label.style_label_up,
         color=color.new(color.gray, 20),
         textcolor=color.white,
         size=size.tiny)

if showSignals and firedAPlusShort
    label.new(
         bar_index,
         high,
         "A+ SHORT\nLOCKED",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

if showSignals and firedAShort
    label.new(
         bar_index,
         high,
         "A SHORT\nLOCKED",
         style=label.style_label_down,
         color=color.new(color.red, 20),
         textcolor=color.white,
         size=size.small)

if showSignals and firedBShort
    label.new(
         bar_index,
         high,
         "B SHORT\nLOCKED",
         style=label.style_label_down,
         color=color.new(color.gray, 20),
         textcolor=color.white,
         size=size.tiny)

//====================================================
// EXECUTION ALERTS - ALL v14 SIGNALS, LIVE-LOCKED
//====================================================

// PRIMARY AUTOMATION ALERTS:
// To automate the full 529-style signal set, create ONLY these two alerts:
// 1) AUTO LONG ALL
// 2) AUTO SHORT ALL
//
// Do not also create the tier-specific alerts below unless your bot is configured
// to prevent duplicate orders.

alertcondition(
     firedLongAll,
     title="AUTO LONG ALL",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"LONG ALL\",\"side\":\"buy\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Long SL\")}}\",\"target\":\"{{plot(\"Long TP\")}}\",\"permission\":\"ALL_V14_LONGS\",\"session\":\"NY\"}")

alertcondition(
     firedShortAll,
     title="AUTO SHORT ALL",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"SHORT ALL\",\"side\":\"sell\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Short SL\")}}\",\"target\":\"{{plot(\"Short TP\")}}\",\"permission\":\"ALL_V14_SHORTS\",\"session\":\"NY\"}")

// OPTIONAL TIER-SPECIFIC ALERTS FOR LOGGING / SEPARATE RISK ROUTING ONLY.
// Use these only if you are NOT using AUTO LONG ALL / AUTO SHORT ALL.

alertcondition(
     firedAPlusLong,
     title="AUTO A+ LONG",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"A+ LONG\",\"side\":\"buy\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Long SL\")}}\",\"target\":\"{{plot(\"Long TP\")}}\",\"riskTier\":\"full\",\"permission\":\"A+\",\"session\":\"NY\"}")

alertcondition(
     firedALong,
     title="AUTO A LONG",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"A LONG\",\"side\":\"buy\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Long SL\")}}\",\"target\":\"{{plot(\"Long TP\")}}\",\"riskTier\":\"normal\",\"permission\":\"A\",\"session\":\"NY\"}")

alertcondition(
     firedBLong,
     title="AUTO B LONG",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"B LONG\",\"side\":\"buy\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Long SL\")}}\",\"target\":\"{{plot(\"Long TP\")}}\",\"riskTier\":\"reduced\",\"permission\":\"B\",\"session\":\"NY\"}")

alertcondition(
     firedAPlusShort,
     title="AUTO A+ SHORT",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"A+ SHORT\",\"side\":\"sell\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Short SL\")}}\",\"target\":\"{{plot(\"Short TP\")}}\",\"riskTier\":\"full\",\"permission\":\"A+\",\"session\":\"NY\"}")

alertcondition(
     firedAShort,
     title="AUTO A SHORT",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"A SHORT\",\"side\":\"sell\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Short SL\")}}\",\"target\":\"{{plot(\"Short TP\")}}\",\"riskTier\":\"normal\",\"permission\":\"A\",\"session\":\"NY\"}")

alertcondition(
     firedBShort,
     title="AUTO B SHORT",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"B SHORT\",\"side\":\"sell\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"stop\":\"{{plot(\"Short SL\")}}\",\"target\":\"{{plot(\"Short TP\")}}\",\"riskTier\":\"reduced\",\"permission\":\"B\",\"session\":\"NY\"}")

alertcondition(
     promisingTrade,
     title="AUTO PROMISING TRADE",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"PROMISING TRADE\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"riskTier\":\"check_signal_type\",\"session\":\"NY\",\"note\":\"Notification only - all v14 signal set, live locked\"}")

alertcondition(
     tradeActive and beActive,
     title="BE ACTIVE",
     message="{\"secret\":\"Tony2707\",\"strategy\":\"Topstep_v14_AllSignals_LiveLock_CSV\",\"signal\":\"BE ACTIVE\",\"ticker\":\"{{ticker}}\",\"time\":\"{{time}}\",\"entry\":\"{{close}}\",\"note\":\"Break even armed - notification only\"}")
````
