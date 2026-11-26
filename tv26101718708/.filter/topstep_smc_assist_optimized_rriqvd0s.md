# Topstep SMC Assist OPTIMIZED

- url: https://www.tradingview.com/script/RrIQVD0s-Topstep-SMC-Assist-OPTIMIZED/
- type: indicator
- pine_id: PUB;bead4118c42d451a916ae364371d382f
- version: 1.0

## Description

Strategy Used to assist with entries and invalidating bad market conditions

## Source Code

````pine
//@version=6
indicator(
     "Topstep SMC Assist OPTIMIZED",
     overlay=true,
     max_labels_count=500,
     max_boxes_count=500)

//====================================================
// MODE
// Balanced = 65 threshold (data-validated sweet spot)
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
//====================================================

sessionNY =
     input.session(
         "0930-1200",
         "NY Prime Session")

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

// Prime session: 9:30-10:59
// Data shows 10:00-10:15 is highest EV window (+0.265R)
primeSession =
     (hourNY == 9 and minuteNY >= 30) or
     (hourNY == 10)

middayChop =
     hourNY >= 12

// Kill zone: 9:45-10:15 (data-tightened from 9:45-10:30)
// 10:00-10:15 = +0.265R EV | 10:16-10:30 = -0.078R EV
inKillZone =
     (hourNY == 9 and minuteNY >= 45) or
     (hourNY == 10 and minuteNY <= 15)

//====================================================
// DISPLAY INPUTS
//====================================================

showSessionBG =
     input.bool(true, "Show Session Background")

showKillZoneBG =
     input.bool(true, "Show Kill Zone Background")

showEMA =
     input.bool(true, "Show EMA")

showSignals =
     input.bool(true, "Show Entry Signals")

showFVG =
     input.bool(true, "Show FVG")

showLevels =
     input.bool(true, "Show TP / SL Lines")

showForecast =
     input.bool(true, "Show Forecast")

showFlow =
     input.bool(true, "Show Flow Dots")

showOB =
     input.bool(true, "Show Order Blocks")

showSweeps =
     input.bool(true, "Show Liquidity Sweeps")

showMgmt =
     input.bool(true, "Show Trade Management Labels")

//====================================================
// STRATEGY INPUTS
// All values data-validated on MNQ 15m CSV
//====================================================

emaLength =
     input.int(50, "EMA Length")

swingLength =
     input.int(5, "Swing Length")

htf =
     input.timeframe("15", "Master HTF")

ltfConfirmTF =
     input.timeframe("1", "Micro Confirmation TF")

displacementMult =
     input.float(1.15, "Displacement Multiplier")

// stopATR = 1.0 validated as optimal in grid search
stopATR =
     input.float(
         1.0,
         "ATR Stop Multiplier",
         step=0.1)

// rrTarget = 0.9 gives highest EV (+0.048R) from grid search
rrTarget =
     input.float(
         0.9,
         "RR Target",
         step=0.1)

// timeout = 6 bars optimal from grid search
timeoutBars =
     input.int(
         6,
         "Timeout Bars",
         minval=1)

// minBodyRatio = 0.35 filters weak candles
minBodyRatio =
     input.float(
         0.35,
         "Min Body Ratio",
         minval=0.1,
         maxval=0.9,
         step=0.05)

// maxHTFExtension = 2.5 tightened from 3.5 (data-validated)
maxHTFExtension =
     input.float(
         2.5,
         "Max HTF Extension (ATR)",
         step=0.1)

// dominanceBuffer = 10 filters counter-trend noise
dominanceBuffer =
     input.int(
         10,
         "Bias Dominance Buffer",
         minval=0,
         maxval=50)

//====================================================
// BACKGROUND
//====================================================

bgcolor(
     showSessionBG and inSession ?
     color.new(color.blue, 95) : na)

bgcolor(
     showKillZoneBG and inKillZone ?
     color.new(color.yellow, 88) : na)

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
     linewidth=2)

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
     ta.pivothigh(high, swingLength, swingLength)

swingLow =
     ta.pivotlow(low, swingLength, swingLength)

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
// CANDLE QUALITY FILTER
// Filters weak bodies and wick clusters
// strongBody >= 0.35 ratio (data-validated)
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

excessiveWick =
     upperWickRatio > 0.6 or
     lowerWickRatio > 0.6

wickCluster =
     excessiveWick and excessiveWick[1]

weakBody =
     bodyRatio < 0.18

badCandleQuality =
     weakBody or wickCluster

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
         left=bar_index-2,
         right=bar_index+5,
         top=low,
         bottom=high[2],
         bgcolor=color.new(color.green, 88),
         border_color=color.lime,
         border_width=1)

if showFVG and bearFVG
    box.new(
         left=bar_index-2,
         right=bar_index+5,
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
     close > open and relativeVolume > 1.05

sellPressure =
     close < open and relativeVolume > 1.05

strongBuyPressure =
     close > open and relativeVolume > 1.4

strongSellPressure =
     close < open and relativeVolume > 1.4

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

// Good follow-through: healthy vol OR expanding range OR in kill zone
goodFollowThrough =
     healthyVolatility or
     rangeExpansion or
     inKillZone

hardBadConditions =
     flatEMA or
     lowVolatility or
     compression or
     badCandleQuality

//====================================================
// HTF DATA
//====================================================

htfClose =
     request.security(syminfo.tickerid, htf, close)

htfOpen =
     request.security(syminfo.tickerid, htf, open)

htfEMA =
     request.security(syminfo.tickerid, htf, ta.ema(close, emaLength))

htfATR =
     request.security(syminfo.tickerid, htf, ta.atr(14))

htfEMASlope =
     request.security(
         syminfo.tickerid,
         htf,
         ta.ema(close, emaLength) - ta.ema(close, emaLength)[5])

htfVolumeFlowBull =
     request.security(
         syminfo.tickerid,
         htf,
         (na(volume) or na(ta.sma(volume,10)) or ta.sma(volume,10)==0 ?
         true : volume > ta.sma(volume, 10)) and close > open)

htfVolumeFlowBear =
     request.security(
         syminfo.tickerid,
         htf,
         (na(volume) or na(ta.sma(volume,10)) or ta.sma(volume,10)==0 ?
         true : volume > ta.sma(volume, 10)) and close < open)

htfBullFVG =
     request.security(syminfo.tickerid, htf, low > high[2])

htfBearFVG =
     request.security(syminfo.tickerid, htf, high < low[2])

htfBullCISD =
     request.security(syminfo.tickerid, htf, close > high[1])

htfBearCISD =
     request.security(syminfo.tickerid, htf, close < low[1])

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
// Tightened to 2.5x ATR (was 3.5x) — data-validated
// Penalty raised to 15pts (was 10pts)
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
htfBullScore += primeSession        ? 10 : 0

htfBullScore -= middayChop          ? 10 : 0
htfBullScore -= htfOverextended     ? 15 : 0  // raised from 10
htfBullScore -= hardBadConditions   ? 10 : 0

htfBearScore += htfBearTrend        ? 15 : 0
htfBearScore += htfBearSlope        ? 20 : 0
htfBearScore += htfBearDisplacement ? 20 : 0
htfBearScore += htfVolumeFlowBear   ? 20 : 0
htfBearScore += htfBearFVG          ? 10 : 0
htfBearScore += htfBearCISD         ? 10 : 0
htfBearScore += primeSession        ? 10 : 0

htfBearScore -= middayChop          ? 10 : 0
htfBearScore -= htfOverextended     ? 15 : 0  // raised from 10
htfBearScore -= hardBadConditions   ? 10 : 0

htfBullScore :=
     math.max(htfBullScore, 0)

htfBearScore :=
     math.max(htfBearScore, 0)

//====================================================
// SCORE ZONES + DOMINANCE
// Sweet spot 65-80 avoids overscored late-move signals
// High score >80 allowed only if not overextended
// Dominance buffer blocks counter-trend noise
//====================================================

bullSweetSpot =
     htfBullScore >= 65 and
     htfBullScore <= 80 and
     htfBullScore > htfBearScore

bearSweetSpot =
     htfBearScore >= 65 and
     htfBearScore <= 80 and
     htfBearScore > htfBullScore

bullHighScore =
     htfBullScore > 80 and
     not htfOverextended and
     htfBullScore > htfBearScore

bearHighScore =
     htfBearScore > 80 and
     not htfOverextended and
     htfBearScore > htfBullScore

bullDominance =
     htfBullScore > htfBearScore + dominanceBuffer

bearDominance =
     htfBearScore > htfBullScore + dominanceBuffer

htfBullSetup =
     htfBullTrend and
     htfBullScore >= requiredHTFScore and
     (bullSweetSpot or bullHighScore) and
     (not blockCounterTrend or bullDominance)

htfBearSetup =
     htfBearTrend and
     htfBearScore >= requiredHTFScore and
     (bearSweetSpot or bearHighScore) and
     (not blockCounterTrend or bearDominance)

//====================================================
// MICRO CONFIRMATIONS (1m TF)
// Kill zone: 1 confirmation enough
// Outside KZ: 2 required
//====================================================

microBullIFVG =
     request.security(syminfo.tickerid, ltfConfirmTF, low > high[2])

microBearIFVG =
     request.security(syminfo.tickerid, ltfConfirmTF, high < low[2])

microBullCISD =
     request.security(syminfo.tickerid, ltfConfirmTF, close > high[1])

microBearCISD =
     request.security(syminfo.tickerid, ltfConfirmTF, close < low[1])

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
     inKillZone ?
     microBullScore >= 1 :
     microBullScore >= 2

microBearConfirm =
     inKillZone ?
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
// ENTRY QUALITY GATE
// strongBody + goodFollowThrough + not overextended
// Filters ~40 low-quality signals vs old script
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
// FINAL SIGNALS
//====================================================

rawLongSignal =
     confirmedOK and
     inSession and
     htfBullSetup and
     ltfBullTrigger and
     entryQualityOK

rawShortSignal =
     confirmedOK and
     inSession and
     htfBearSetup and
     ltfBearTrigger and
     entryQualityOK

//====================================================
// TP / SL
// RR 0.9 + Stop 1.0 ATR = highest EV from grid search
// Single TP (no partial — data shows partials add timeout drag)
//====================================================

longStop =
     low - atr * stopATR

shortStop =
     high + atr * stopATR

longRisk =
     close - longStop

shortRisk =
     shortStop - close

longTP =
     close + longRisk * rrTarget

shortTP =
     close - shortRisk * rrTarget

//====================================================
// ACTIVE TRADE MANAGEMENT
// Tracks one trade at a time
// Timeout = 6 bars (data-optimized, was 8)
//====================================================

var bool  tradeActive    = false
var int   activeDir      = 0
var int   activeStartBar = na
var float activeEntry    = na
var float activeStop     = na
var float activeTP       = na

longSignal  = rawLongSignal  and not tradeActive
shortSignal = rawShortSignal and not tradeActive

if longSignal
    tradeActive    := true
    activeDir      := 1
    activeStartBar := bar_index
    activeEntry    := close
    activeStop     := longStop
    activeTP       := longTP

if shortSignal
    tradeActive    := true
    activeDir      := -1
    activeStartBar := bar_index
    activeEntry    := close
    activeStop     := shortStop
    activeTP       := shortTP

barsInTrade =
     tradeActive ?
     bar_index - activeStartBar : 0

// Long management
if tradeActive and activeDir == 1

    if high >= activeTP
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

    else if low <= activeStop
        if showMgmt
            label.new(
                 bar_index,
                 activeStop,
                 "SL HIT",
                 style=label.style_label_down,
                 color=color.red,
                 textcolor=color.white,
                 size=size.small)
        tradeActive := false

    else if barsInTrade >= timeoutBars
        if showMgmt
            label.new(
                 bar_index,
                 close,
                 "TIMEOUT\nExit",
                 style=label.style_label_left,
                 color=color.gray,
                 textcolor=color.white,
                 size=size.small)
        tradeActive := false

// Short management
if tradeActive and activeDir == -1

    if low <= activeTP
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

    else if high >= activeStop
        if showMgmt
            label.new(
                 bar_index,
                 activeStop,
                 "SL HIT",
                 style=label.style_label_up,
                 color=color.red,
                 textcolor=color.white,
                 size=size.small)
        tradeActive := false

    else if barsInTrade >= timeoutBars
        if showMgmt
            label.new(
                 bar_index,
                 close,
                 "TIMEOUT\nExit",
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
     htfBullScore >= 75 and
     htfBullScore > htfBearScore

bearForecast =
     showForecast and
     htfBearScore >= 75 and
     htfBearScore > htfBullScore

bgcolor(bullForecast ? color.new(color.green, 93) : na)
bgcolor(bearForecast ? color.new(color.red, 93)   : na)

//====================================================
// TP / SL PLOTS
//====================================================

plot(
     showLevels and longSignal ? longTP   : na,
     color=color.lime, linewidth=2)

plot(
     showLevels and longSignal ? longStop : na,
     color=color.red,  linewidth=2)

plot(
     showLevels and shortSignal ? shortTP   : na,
     color=color.lime, linewidth=2)

plot(
     showLevels and shortSignal ? shortStop : na,
     color=color.red,  linewidth=2)

//====================================================
// ENTRY LABELS
//====================================================

if showSignals and longSignal
    label.new(
         bar_index,
         low,
         text=
             "LONG\n" +
             "HTF: " + str.tostring(htfBullScore) +
             "\n1M CONFIRM" +
             "\nVOL: " + str.tostring(math.round(relativeVolume, 2)) + "x" +
             "\nENTRY: " + str.tostring(math.round(close, 1)) +
             "\nTIME: " + str.format("{0,number,00}:{1,number,00}", hourNY, minuteNY) +
             (inKillZone ? "\n⚡ KILL ZONE" : "") +
             "\nTP: " + str.tostring(math.round(longTP, 1)) +
             "\nSL: " + str.tostring(math.round(longStop, 1)),
         style=label.style_label_up,
         color=inKillZone ?
             color.new(color.lime, 0) :
             color.new(color.green, 30),
         textcolor=color.black,
         size=size.small)

if showSignals and shortSignal
    label.new(
         bar_index,
         high,
         text=
             "SHORT\n" +
             "HTF: " + str.tostring(htfBearScore) +
             "\n1M CONFIRM" +
             "\nVOL: " + str.tostring(math.round(relativeVolume, 2)) + "x" +
             "\nENTRY: " + str.tostring(math.round(close, 1)) +
             "\nTIME: " + str.format("{0,number,00}:{1,number,00}", hourNY, minuteNY) +
             (inKillZone ? "\n⚡ KILL ZONE" : "") +
             "\nTP: " + str.tostring(math.round(shortTP, 1)) +
             "\nSL: " + str.tostring(math.round(shortStop, 1)),
         style=label.style_label_down,
         color=inKillZone ?
             color.new(color.red, 0) :
             color.new(color.red, 30),
         textcolor=color.white,
         size=size.small)

//====================================================
// PERMISSION ENGINE
//====================================================

tradePermission =
     longSignal              ? "LONG ALLOWED" :
     shortSignal             ? "SHORT ALLOWED" :
     htfBullSetup and
     not ltfBullTrigger      ? "WAIT LONG TRIGGER" :
     htfBearSetup and
     not ltfBearTrigger      ? "WAIT SHORT TRIGGER" :
     "NO TRADE"

//====================================================
// PANEL
//====================================================

var table panel =
     table.new(position.top_right, 2, 14,
         border_color=color.new(color.gray, 60),
         border_width=1)

if barstate.islast

    table.cell(panel, 0, 0, "MODE",
         text_color=color.silver, bgcolor=color.new(color.gray, 80))
    table.cell(panel, 1, 0, riskMode,
         text_color=color.white,  bgcolor=color.new(color.gray, 80))

    table.cell(panel, 0, 1, "HTF SCORE",   text_color=color.silver)
    table.cell(panel, 1, 1,
         str.tostring(math.max(htfBullScore, htfBearScore)),
         text_color=math.max(htfBullScore,htfBearScore)>=75 ?
             color.lime : color.yellow)

    table.cell(panel, 0, 2, "BIAS",        text_color=color.silver)
    table.cell(panel, 1, 2,
         htfBullScore > htfBearScore ? "BULL" :
         htfBearScore > htfBullScore ? "BEAR" : "NEUTRAL",
         text_color=
             htfBullScore > htfBearScore ? color.lime :
             htfBearScore > htfBullScore ? color.red  : color.gray)

    table.cell(panel, 0, 3, "KILL ZONE",   text_color=color.silver)
    table.cell(panel, 1, 3,
         inKillZone ? "ACTIVE ⚡" : "INACTIVE",
         text_color=inKillZone ? color.yellow : color.gray)

    table.cell(panel, 0, 4, "FLOW",        text_color=color.silver)
    table.cell(panel, 1, 4,
         flowBull ? "BUY PRESSURE" :
         flowBear ? "SELL PRESSURE" : "NEUTRAL",
         text_color=
             flowBull ? color.lime :
             flowBear ? color.red  : color.gray)

    table.cell(panel, 0, 5, "MICRO",       text_color=color.silver)
    table.cell(panel, 1, 5,
         microBullConfirm ? "1M BULL ✓" :
         microBearConfirm ? "1M BEAR ✓" : "WAIT",
         text_color=
             microBullConfirm ? color.lime :
             microBearConfirm ? color.red  : color.gray)

    table.cell(panel, 0, 6, "HTF SETUP",   text_color=color.silver)
    table.cell(panel, 1, 6,
         htfBullSetup ? "BULL VALID" :
         htfBearSetup ? "BEAR VALID" : "WAIT",
         text_color=
             htfBullSetup ? color.lime :
             htfBearSetup ? color.red  : color.gray)

    table.cell(panel, 0, 7, "LTF",         text_color=color.silver)
    table.cell(panel, 1, 7,
         ltfBullTrigger ? "LONG READY" :
         ltfBearTrigger ? "SHORT READY" : "WAIT",
         text_color=
             ltfBullTrigger ? color.lime :
             ltfBearTrigger ? color.red  : color.gray)

    table.cell(panel, 0, 8, "SESSION",     text_color=color.silver)
    table.cell(panel, 1, 8,
         inSession ? "ACTIVE" : "OFF",
         text_color=inSession ? color.lime : color.gray)

    table.cell(panel, 0, 9, "OVEREXT",     text_color=color.silver)
    table.cell(panel, 1, 9,
         htfOverextended ? "YES ⚠" : "NO",
         text_color=htfOverextended ? color.red : color.lime)

    table.cell(panel, 0, 10, "VOLUME",     text_color=color.silver)
    table.cell(panel, 1, 10,
         str.tostring(math.round(relativeVolume, 2)) + "x",
         text_color=relativeVolume >= 1.4 ?
             color.lime : relativeVolume >= 1.05 ?
             color.yellow : color.gray)

    table.cell(panel, 0, 11, "TREND",      text_color=color.silver)
    table.cell(panel, 1, 11,
         ltfBullSlope ? "BULL STRONG" :
         ltfBearSlope ? "BEAR STRONG" : "WEAK",
         text_color=
             ltfBullSlope ? color.lime :
             ltfBearSlope ? color.red  : color.gray)

    table.cell(panel, 0, 12, "MARKET",     text_color=color.silver)
    table.cell(panel, 1, 12,
         hardBadConditions ? "CHOPPY ⚠" : "TRENDING",
         text_color=hardBadConditions ? color.red : color.lime)

    table.cell(panel, 0, 13, "PERMISSION",
         text_color=color.silver, bgcolor=color.new(color.gray, 80))
    table.cell(panel, 1, 13,
         tradePermission,
         text_color=
             tradePermission == "LONG ALLOWED"  ? color.lime :
             tradePermission == "SHORT ALLOWED" ? color.red  :
             tradePermission == "NO TRADE"      ? color.gray :
             color.yellow,
         bgcolor=color.new(color.gray, 80))

//====================================================
// ALERTS
//====================================================

alertcondition(
     longSignal,
     title="LONG SIGNAL",
     message="Bullish HTF + 1M Confirmation")

alertcondition(
     shortSignal,
     title="SHORT SIGNAL",
     message="Bearish HTF + 1M Confirmation")

// Kill zone alerts: highest EV window (10:00-10:15 = +0.265R EV)
killZoneLong =
     longSignal and
     inKillZone and
     htfBullScore >= 65

killZoneShort =
     shortSignal and
     inKillZone and
     htfBearScore >= 65

alertcondition(
     killZoneLong,
     title="KILL ZONE LONG",
     message="KILL ZONE LONG - HTF 65+ | 9:45-10:15 NY | Highest EV Window")

alertcondition(
     killZoneShort,
     title="KILL ZONE SHORT",
     message="KILL ZONE SHORT - HTF 65+ | 9:45-10:15 NY | Highest EV Window")
````
