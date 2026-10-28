# RocketFlow

- url: https://www.tradingview.com/script/GlOWOPqh-RocketFlow/
- type: indicator
- pine_id: PUB;620c83dad21044d1b167259d04e69500
- version: 1.0

## Description

RocketFlow is a volatility-compression breakout indicator designed to identify when price is preparing to aggressively challenge or cross the Ichimoku Cloud. The system combines cloud structure, ATR-based resistance proximity, momentum acceleration, candle expansion, RSI pressure, trend behavior, and compression analysis to detect high-pressure market conditions before expansion moves occur. Signals are graded into multiple strength tiers based on breakout quality, momentum force, and structural alignment, helping traders identify early pressure buildup as well as stronger breakout attempts. The indicator is built around the idea that explosive moves often originate from compressed price action positioned just beneath key resistance zones, particularly near the Ichimoku Cloud and ATR-defined pressure areas.

In addition to the Rocket breakout system, the indicator also includes ATR-based LONG signals designed to detect reclaim setups, support holds, and momentum continuation opportunities near dynamic ATR support zones.

The visual system is designed to show the different stages of breakout development and post-signal behavior:

Red, yellow, and dark green circles represent “Pre-Rocket” formation stages, showing when pressure and momentum are beginning to build beneath the cloud before a full breakout signal is confirmed.
Green and aqua triangles represent Rocket breakout signals. Smaller green triangles indicate weaker or earlier breakout attempts, while larger aqua triangles represent the strongest “God Rocket” expansion conditions with the highest momentum and breakout quality.
LONG triangles below price represent ATR Support LONG signals triggered from reclaim or support continuation setups.
Orange and red squares monitor post-breakout behavior. Orange squares warn of weakening momentum or rejection behavior after a launch, while red squares indicate more serious breakdown or stop-risk conditions.
Yellow and green lower squares track healthy pullbacks and potential re-entry opportunities after an initial breakout move.
The purple ATR line acts as a dynamic volatility-based support and trailing structure level.
The Ichimoku Cloud itself functions as the primary resistance and pressure zone the system is attempting to predict price crossing through.

## Source Code

````pine
//@version=6
indicator("Combined Kumo Rocket + ATR Stop + ATR Support Long Signals", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=1000)

// Inputs
tenkanLen = input.int(9, "Tenkan Length")
kijunLen = input.int(26, "Kijun Length")
senkouBLen = input.int(52, "Senkou B Length")
displacement = input.int(26, "Ichimoku Displacement")

atrLen = input.int(14, "ATR Length")
rsiLen = input.int(14, "RSI Length")
adxLen = input.int(14, "ADX Length")
volLen = input.int(20, "Volume Average Length")

confirmedThreshold = input.float(13.0, "Confirmed Pressure Threshold")
earlyThreshold = input.float(9.0, "Early Pressure Threshold")
maxGapATR = input.float(0.65, "Max Gap ATR", step=0.05)
maxCompression = input.float(3.8, "Max Compression", step=0.1)
cooldownBars = input.int(5, "Cooldown Bars")
godGapATR = input.float(0.08, "GOD Max Gap ATR", step=0.01)
godPressureSlope = input.float(65.0, "GOD Min PressureSlope", step=1.0)
godRangeATR = input.float(0.85, "GOD Min Range ATR", step=0.05)
godImpulse = input.float(0.42, "GOD Min ImpulseStrength", step=0.01)
godRsiSlope = input.float(13.0, "GOD Min RSI Slope", step=0.5)
godCoilQuality = input.float(30.0, "GOD Min CoilQuality", step=1.0)
godMomentumComposite = input.float(22.0, "GOD Min MomentumComposite", step=1.0)

showDebugLabels = input.bool(false, "Show Data Labels")
showCloud = input.bool(true, "Show Cloud")
strictUnderCloud = input.bool(false, "Require Full Candle Below Cloud")
showTradeMap = input.bool(true, "Show Stop/Targets")
tradeMapBars = input.int(18, "Stop/Target Line Bars", minval=1)
stopLineExtraBars = input.int(6, "Stop Line Extra Bars", minval=0)
useAngledStopLine = input.bool(true, "Use Angled Trailing Stop Line")
angledStopRiseATR = input.float(0.06, "Angled Stop Rise ATR/Bar", minval=0.0, step=0.01)
maxAngledStopLines = input.int(120, "Max Angled Stop Lines", minval=10, maxval=300)
angledStopRayBars = input.int(500, "Angled Stop Ray Projection Bars", minval=50, maxval=500)
earlyStopATR = input.float(0.55, "Early Stop Buffer ATR", step=0.05)
confirmedStopATR = input.float(0.45, "Confirmed Stop Buffer ATR", step=0.05)
godStopATR = input.float(0.35, "GOD Stop Buffer ATR", step=0.05)
earlyMinStopATR = input.float(0.75, "Early Min Stop Distance ATR", step=0.05)
confirmedMinStopATR = input.float(0.65, "Confirmed Min Stop Distance ATR", step=0.05)
godMinStopATR = input.float(0.55, "GOD Min Stop Distance ATR", step=0.05)
tp1RiskMultiple = input.float(1.0, "TP1 Min R", step=0.25)
tp2RiskMultiple = input.float(1.75, "TP2 Min R", step=0.25)
tp3RiskMultiple = input.float(2.75, "TP3 Min R", step=0.25)
useAbsoluteDots = input.bool(true, "Dots: Absolute Y (Fix stuck/placement)")
rocketDotOffsetATR = input.float(0.85, "Rocket Dot Offset (ATR)", step=0.05)
rocketDotOffsetRange = input.float(0.20, "Rocket Dot Offset (Range %)", step=0.05, minval=0.0)
rocketDotMinTicks = input.int(25, "Rocket Dot Min Ticks", minval=0)
rocketDotBelowBarFallback = input.bool(false, "Dots: Belowbar fallback")
debugLabelOffsetATR = input.float(0.08, "Debug Triangle Offset (ATR)", step=0.01)
showPreRocketDots = input.bool(true, "Show Pre-Rocket Formation Dots")
preMaxGapATR = input.float(1.35, "Pre-Rocket Max Gap ATR", step=0.05)
preMaxBarsToCloud = input.float(7.0, "Pre-Rocket Max Bars To Cloud", step=0.5)
preMinRSISlope = input.float(2.5, "Pre-Rocket Min RSI Slope", step=0.5)
preMaxCompression = input.float(4.4, "Pre-Rocket Max Compression", step=0.1)
preRedScore = input.int(35, "Pre-Rocket Red Min Score", minval=0, maxval=100)
preYellowScore = input.int(55, "Pre-Rocket Yellow Min Score", minval=0, maxval=100)
preGreenScore = input.int(75, "Pre-Rocket Dark Green Min Score", minval=0, maxval=100)
showCampaignSquares = input.bool(true, "Show Post-Rocket Campaign Squares")
campaignBars = input.int(34, "Campaign Monitor Bars", minval=5)
campaignPushATR = input.float(0.60, "Campaign Push Confirm ATR", step=0.05)
campaignUpperWickPct = input.float(0.32, "Campaign Warning Upper Wick %", step=0.01)
campaignWeakClosePos = input.float(0.55, "Campaign Warning Weak Close Pos", step=0.01)
campaignReloadStopBufferATR = input.float(0.20, "Campaign Reload Min Stop Buffer ATR", step=0.05)
campaignReentryRsiSlope = input.float(5.0, "Campaign Re-entry Min RSI Slope", step=0.5)
campaignReentryImpulse = input.float(0.34, "Campaign Re-entry Min Impulse", step=0.01)

// Ichimoku
donchian(len) =>
    (ta.highest(high, len) + ta.lowest(low, len)) / 2.0

tenkan = donchian(tenkanLen)
kijun = donchian(kijunLen)
senkouA = (tenkan + kijun) / 2.0
senkouB = donchian(senkouBLen)

signalSenkouA = senkouA[displacement]
signalSenkouB = senkouB[displacement]
cloudTop = math.max(signalSenkouA, signalSenkouB)
cloudBottom = math.min(signalSenkouA, signalSenkouB)
cloudThickness = cloudTop - cloudBottom

// Core metrics
atr = ta.atr(atrLen)
rsi = ta.rsi(close, rsiLen)
rsiSlope = rsi - rsi[5]

avgVol = ta.sma(volume, volLen)
relVol = volume / math.max(avgVol, 1)

gapATR = (cloudBottom - close) / math.max(atr, syminfo.mintick)
cloudATR = cloudThickness / math.max(atr, syminfo.mintick)

underCloud = strictUnderCloud ? high < cloudBottom : close < cloudBottom
nearCloud = gapATR > 0 and gapATR <= maxGapATR

// Candle metrics
candleRange = high - low
body = math.abs(close - open)
bodyPct = body / math.max(candleRange, syminfo.mintick)
closePos = (close - low) / math.max(candleRange, syminfo.mintick)
rangeATR = candleRange / math.max(atr, syminfo.mintick)
bodyATR = body / math.max(atr, syminfo.mintick)
bullishCandle = close > open
upperWick = high - math.max(open, close)
upperWickPct = upperWick / math.max(candleRange, syminfo.mintick)

// Compression
lookback = 12
recentRange = ta.highest(high, lookback) - ta.lowest(low, lookback)
compressionATR = recentRange / math.max(atr, syminfo.mintick)
compressed = compressionATR <= maxCompression

// Momentum
priceReclaimedTenkan = close > tenkan
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
macdSlope = hist - hist[3]

// DI / ADX
upMove = high - high[1]
downMove = low[1] - low
plusDM = upMove > downMove and upMove > 0 ? upMove : 0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0
trur = ta.rma(ta.tr(true), adxLen)
plusDI = 100 * ta.rma(plusDM, adxLen) / math.max(trur, syminfo.mintick)
minusDI = 100 * ta.rma(minusDM, adxLen) / math.max(trur, syminfo.mintick)
dx = 100 * math.abs(plusDI - minusDI) / math.max(plusDI + minusDI, 0.0001)
adx = ta.rma(dx, adxLen)
diSpread = plusDI - minusDI
diMomentum = diSpread - diSpread[3]

// Structure
recentLow = ta.lowest(low, 20)[1]
liquiditySweep = low < recentLow and close > recentLow
priorHigh = ta.highest(high, 10)[1]
microBreakout = close > priorHigh

// Pressure engine
pressure = (math.max(rsiSlope, 0.1) * math.max(rangeATR, 0.1)) / math.max(gapATR * compressionATR, 0.1)
pressureSlope = pressure - pressure[3]
cloudPull = 1 / math.max(gapATR, 0.05)
impulseStrength = bodyPct * closePos * rangeATR
momentumComposite = math.max(rsiSlope, 0) + math.max(macdSlope, 0) + math.max(diMomentum, 0)
coilQuality = compressionATR / math.max(gapATR, 0.05)
cloudTravelPotential = rangeATR / math.max(cloudATR, 0.10)
cloudTouch = high >= cloudBottom
cloudPiercePct = cloudTouch ? ((math.min(high, cloudTop) - cloudBottom) / math.max(cloudThickness, syminfo.mintick)) : 0
kijunGapATR = (kijun - close) / math.max(atr, syminfo.mintick)
tenkanSlope = tenkan - tenkan[3]
tenkanSlopeATR = tenkanSlope / math.max(atr, syminfo.mintick)
futureCloudBias = senkouA > senkouB
cleanThrust = rangeATR >= 0.85 and impulseStrength >= 0.42 and closePos >= 0.70 and gapATR <= 0.25
ignitionMomentum = rsiSlope >= 13 and momentumComposite >= 22
earlyCloudConversion = cloudPiercePct >= 0.01 or cleanThrust
strongCandleRescue = closePos >= 0.68 and bodyATR >= 0.60 and rsiSlope >= 13 and gapATR <= 0.35
earlyTrapBlock = not strongCandleRescue and not cleanThrust and not futureCloudBias and cloudATR >= 2.50 and upperWickPct >= 0.24
violentCloudEngagement = cloudPiercePct >= 0.15 and rangeATR >= 0.90 and bodyATR >= 0.70 and (closePos >= 0.66 or (closePos >= 0.62 and impulseStrength >= 0.55 and upperWickPct <= 0.34) or (closePos >= 0.62 and kijunGapATR <= -0.75 and rsiSlope >= 10))
cleanRipCandle = strongCandleRescue and rangeATR >= 1.00 and impulseStrength >= 0.60
ripQuality = (violentCloudEngagement or cleanRipCandle) and rsiSlope >= 10 and gapATR <= 0.30 and (pressureSlope >= 50 or ignitionMomentum or strongCandleRescue)
godDisplacementQuality = rangeATR >= 1.35 or impulseStrength >= 0.85 or (closePos >= 0.82 and upperWickPct <= 0.25) or (rangeATR >= 1.20 and kijunGapATR <= -1.00 and rsiSlope >= 15)
confirmedTrapBlock = not ripQuality and not cleanThrust and not futureCloudBias and tenkanSlopeATR <= 0 and kijunGapATR >= 0.45 and cloudTravelPotential < 1.00 and cloudPiercePct <= 0.35
thinCloudExhaustion = cloudPiercePct >= 0.90 and cloudATR <= 0.35 and not futureCloudBias and not violentCloudEngagement and not cleanThrust and not strongCandleRescue and rsiSlope < 10
cloudRejectProbe = cloudTouch and cloudPiercePct >= 0.12 and closePos <= 0.65 and upperWickPct >= 0.36 and not ripQuality and not strongCandleRescue and not cleanThrust
shallowWeakProbe = cloudTouch and cloudPiercePct <= 0.10 and kijunGapATR < 0 and impulseStrength < 0.32 and not ignitionMomentum and not ripQuality and not strongCandleRescue and not cleanThrust
confirmedAirPocket = not cloudTouch and not earlyCloudConversion and not ripQuality and not cleanThrust
postMoveKijunReject = kijunGapATR >= 0.35 and tenkanSlopeATR <= 0 and closePos <= 0.66 and upperWickPct >= 0.33 and rsiSlope < 13 and not ripQuality and not strongCandleRescue and not cleanThrust
confirmedSoftPop = cloudTouch and cloudPiercePct <= 0.18 and cloudTravelPotential < 1.00 and tenkanSlopeATR <= 0.05 and rsiSlope < 13 and not ripQuality and not violentCloudEngagement and not strongCandleRescue
godStructureQuality = tenkanSlopeATR >= 0 or impulseStrength >= 0.85 or closePos >= 0.82 or kijunGapATR <= -1.00
thinCloudOverrunTrap = cloudATR <= 0.35 and cloudTravelPotential >= 4.50 and cloudPiercePct >= 0.30 and not ripQuality and not strongCandleRescue and not cleanThrust
earlyKijunOverheadTrap = kijunGapATR >= 1.20 and rsiSlope < 10 and cloudPiercePct <= 0.05 and not ripQuality and not strongCandleRescue and not cleanThrust
weakAirPocketLaunch = not cloudTouch and not godDisplacementQuality and not godStructureQuality and not ripQuality and not strongCandleRescue and not cleanThrust
shallowGodEngagementTrap = cloudTouch and cloudPiercePct <= 0.10 and cloudTravelPotential <= 1.10 and kijunGapATR > -1.00 and tenkanSlopeATR < 0.15 and not violentCloudEngagement
confirmedLowMomentumPop = rsiSlope < 10 and closePos <= 0.66 and upperWickPct >= 0.33 and impulseStrength < 0.65 and not ripQuality and not violentCloudEngagement and not strongCandleRescue

// Pre-Rocket formation layer
// This does not replace EARLY / CONFIRMED / GOD. It shows the setup forming
// farther below the cloud, before the sacred Rocket dots are allowed to fire.
advanceATR = math.max((close - close[3]) / math.max(atr, syminfo.mintick), 0.01)
barsToCloud = gapATR / advanceATR
preDistanceScore = gapATR <= 0.75 ? 25 : gapATR <= 1.05 ? 18 : gapATR <= preMaxGapATR ? 10 : 0
preTimingScore = barsToCloud <= 3 ? 20 : barsToCloud <= 5 ? 15 : barsToCloud <= preMaxBarsToCloud ? 8 : 0
preMomentumScore = rsiSlope >= 10 or momentumComposite >= 18 ? 20 : rsiSlope >= 6 ? 14 : rsiSlope >= preMinRSISlope ? 8 : 0
preCandleScore = closePos >= 0.72 and bodyPct >= 0.45 ? 15 : closePos >= 0.62 ? 10 : closePos >= 0.55 ? 5 : 0
preStructureScore = priceReclaimedTenkan and tenkanSlopeATR >= 0 ? 10 : priceReclaimedTenkan or tenkanSlopeATR >= -0.05 ? 5 : 0
preCompressionScore = compressionATR <= maxCompression ? 10 : compressionATR <= preMaxCompression ? 5 : 0
preTrap = upperWickPct >= 0.42 and closePos <= 0.64 or kijunGapATR >= 1.65 and rsiSlope < 10 or tenkanSlopeATR <= -0.25 and not strongCandleRescue
preRocketScore = math.min(100, preDistanceScore + preTimingScore + preMomentumScore + preCandleScore + preStructureScore + preCompressionScore)
preRocketCandidate = showPreRocketDots and underCloud and gapATR > maxGapATR and gapATR <= preMaxGapATR and compressionATR <= preMaxCompression and bullishCandle and closePos >= 0.55 and bodyPct >= 0.35 and rsiSlope >= preMinRSISlope and barsToCloud <= preMaxBarsToCloud and not preTrap

// Signals
baseConditions = underCloud and nearCloud and compressed and bullishCandle and closePos >= 0.60 and bodyPct >= 0.50
godRocket = baseConditions and godDisplacementQuality and godStructureQuality and not thinCloudOverrunTrap and not shallowGodEngagementTrap and ((gapATR <= godGapATR and pressureSlope >= godPressureSlope and rangeATR >= godRangeATR and impulseStrength >= godImpulse and closePos >= 0.66 and rsiSlope >= godRsiSlope and coilQuality >= godCoilQuality and momentumComposite >= godMomentumComposite) or ripQuality)
confirmedRocket = baseConditions and not godRocket and not confirmedTrapBlock and not cloudRejectProbe and not shallowWeakProbe and not confirmedAirPocket and not confirmedSoftPop and not thinCloudOverrunTrap and not shallowGodEngagementTrap and not confirmedLowMomentumPop and pressureSlope >= 18 and pressure >= confirmedThreshold and gapATR <= 0.35 and rangeATR >= 0.75 and closePos >= 0.62 and rsiSlope >= 7 and impulseStrength >= 0.38 and (ignitionMomentum or cloudTravelPotential >= 0.05)
earlyRocket = baseConditions and not godRocket and not confirmedRocket and not earlyTrapBlock and not thinCloudExhaustion and not cloudRejectProbe and not shallowWeakProbe and not postMoveKijunReject and not confirmedSoftPop and not thinCloudOverrunTrap and not earlyKijunOverheadTrap and not weakAirPocketLaunch and not shallowGodEngagementTrap and pressure >= earlyThreshold and gapATR <= 0.45 and rangeATR >= 0.55 and (earlyCloudConversion or strongCandleRescue) and ((pressureSlope >= 8 and rsiSlope >= 5) or cleanThrust or strongCandleRescue)

anyRocket = godRocket or confirmedRocket or earlyRocket
barsSinceRocket = ta.barssince(anyRocket[1])
cooldownClear = na(barsSinceRocket) or barsSinceRocket > cooldownBars

finalGod = godRocket and cooldownClear
finalConfirmed = confirmedRocket and cooldownClear
finalEarly = earlyRocket and cooldownClear
rocketDotPad = math.max(math.max(atr * rocketDotOffsetATR, (high - low) * rocketDotOffsetRange), syminfo.mintick * rocketDotMinTicks)
rocketDotY = low - rocketDotPad
dotEarlyY = useAbsoluteDots ? rocketDotY : na
dotConfY = useAbsoluteDots ? rocketDotY : na
dotGodY = useAbsoluteDots ? rocketDotY : na
finalRocket = finalGod or finalConfirmed or finalEarly
finalPreRocket = preRocketCandidate and not finalRocket
preRocketRed = finalPreRocket and preRocketScore >= preRedScore and preRocketScore < preYellowScore
preRocketYellow = finalPreRocket and preRocketScore >= preYellowScore and preRocketScore < preGreenScore
preRocketGreen = finalPreRocket and preRocketScore >= preGreenScore
preDotY = useAbsoluteDots ? low - (rocketDotPad * 0.55) : na
stopBufferATR = finalGod ? godStopATR : finalConfirmed ? confirmedStopATR : earlyStopATR
minStopDistanceATR = finalGod ? godMinStopATR : finalConfirmed ? confirmedMinStopATR : earlyMinStopATR
signalEntry = close
signalSwingLow = ta.lowest(low, 5)
rawStopPrice = math.min(low, signalSwingLow) - (atr * stopBufferATR)
stopPrice = math.min(rawStopPrice, signalEntry - (atr * minStopDistanceATR))
riskPrice = math.max(signalEntry - stopPrice, atr * 0.35)
tp1Price = math.max(cloudBottom, signalEntry + (riskPrice * tp1RiskMultiple))
tp2Price = math.max(math.max(cloudTop, signalEntry + (riskPrice * tp2RiskMultiple)), tp1Price + (atr * 0.10))
tp3Extension = finalGod ? math.max(cloudThickness * 1.25, atr * 1.50) : finalConfirmed ? math.max(cloudThickness * 0.85, atr * 1.00) : math.max(cloudThickness * 0.55, atr * 0.75)
tp3Price = math.max(math.max(cloudTop + tp3Extension, signalEntry + (riskPrice * tp3RiskMultiple)), tp2Price + (atr * 0.10))

// Post-Rocket campaign monitor
// Only wakes up after a real Rocket triangle. It tracks whether the first push is
// rejecting, dying, pulling back healthily, or offering a second re-entry.
var bool rocketCampaignActive = false
var int rocketCampaignStartBar = na
var float rocketCampaignEntry = na
var float rocketCampaignStop = na
var float rocketCampaignSignalLow = na
var float rocketCampaignHigh = na
var bool rocketCampaignHadPush = false
var bool rocketCampaignReloadArmed = false
var bool rocketCampaignWarned = false
var bool rocketCampaignDangered = false
var bool rocketCampaignReentered = false

campaignWarningSquare = false
campaignDangerSquare = false
campaignReloadSquare = false
campaignReentrySquare = false

if finalRocket
    rocketCampaignActive := true
    rocketCampaignStartBar := bar_index
    rocketCampaignEntry := close
    rocketCampaignStop := stopPrice
    rocketCampaignSignalLow := low
    rocketCampaignHigh := high
    rocketCampaignHadPush := false
    rocketCampaignReloadArmed := false
    rocketCampaignWarned := false
    rocketCampaignDangered := false
    rocketCampaignReentered := false
else if rocketCampaignActive
    campaignAge = bar_index - rocketCampaignStartBar
    if campaignAge > campaignBars
        rocketCampaignActive := false
    else
        rocketCampaignHigh := math.max(rocketCampaignHigh, high)
        campaignPushMoveATR = (rocketCampaignHigh - rocketCampaignEntry) / math.max(atr, syminfo.mintick)
        rocketCampaignHadPush := rocketCampaignHadPush or campaignPushMoveATR >= campaignPushATR
        campaignWeakRejection = rocketCampaignHadPush and closePos <= campaignWeakClosePos and upperWickPct >= campaignUpperWickPct
        campaignTenkanLoss = rocketCampaignHadPush and close < tenkan and close < close[1]
        campaignStopBreak = close < rocketCampaignStop or (low < rocketCampaignStop and close < rocketCampaignSignalLow)
        campaignHealthyPullback = rocketCampaignHadPush and low > rocketCampaignStop + atr * campaignReloadStopBufferATR and closePos >= 0.42 and (low <= tenkan or low <= kijun or close <= rocketCampaignEntry + atr * 0.30)
        campaignReentrySetup = rocketCampaignReloadArmed and close > high[1] and close > tenkan and rsiSlope >= campaignReentryRsiSlope and impulseStrength >= campaignReentryImpulse
        campaignWarningSquare := showCampaignSquares and not rocketCampaignWarned and not rocketCampaignDangered and (campaignWeakRejection or campaignTenkanLoss) and not campaignStopBreak
        campaignDangerSquare := showCampaignSquares and not rocketCampaignDangered and campaignStopBreak
        campaignReloadSquare := showCampaignSquares and not rocketCampaignReentered and not campaignStopBreak and campaignHealthyPullback
        campaignReentrySquare := showCampaignSquares and not rocketCampaignReentered and not campaignStopBreak and campaignReentrySetup
        if campaignWarningSquare
            rocketCampaignWarned := true
        if campaignReloadSquare
            rocketCampaignReloadArmed := true
        if campaignReentrySquare
            rocketCampaignReentered := true
            rocketCampaignReloadArmed := false
        if campaignDangerSquare
            rocketCampaignDangered := true
            rocketCampaignActive := false

campaignUpperY = high + rocketDotPad * 0.45
campaignLowerY = low - rocketDotPad * 0.45

// Angled trailing stop lines
// TradingView screen degrees change with zoom, so this uses ATR-per-bar slope as
// the stable version of a slow conservative trailing stop. The line starts at the
// original calculated stop and stops extending once a candle tags it.
var array<line> angledStopLines = array.new_line()
var array<int> angledStopStartBars = array.new_int()
var array<float> angledStopStartPrices = array.new_float()
var array<float> angledStopAtrValues = array.new_float()
var array<int> angledStopMaxBars = array.new_int()
var array<bool> angledStopActive = array.new_bool()

angledStopHit = false
if array.size(angledStopLines) > 0
    for angledIndex = 0 to array.size(angledStopLines) - 1
        if array.get(angledStopActive, angledIndex)
            angledStartBar = array.get(angledStopStartBars, angledIndex)
            angledStartPrice = array.get(angledStopStartPrices, angledIndex)
            angledAtr = array.get(angledStopAtrValues, angledIndex)
            angledMaxBars = array.get(angledStopMaxBars, angledIndex)
            angledAge = bar_index - angledStartBar
            angledCurrentStop = angledStartPrice + angledAtr * angledStopRiseATR * angledAge
            angledRayStop = angledStartPrice + angledAtr * angledStopRiseATR * angledStopRayBars
            angledLine = array.get(angledStopLines, angledIndex)
            if angledAge > 0 and low <= angledCurrentStop
                line.set_x2(angledLine, bar_index)
                line.set_y2(angledLine, angledCurrentStop)
                array.set(angledStopActive, angledIndex, false)
                angledStopHit := true
            else
                line.set_x2(angledLine, angledStartBar + angledStopRayBars)
                line.set_y2(angledLine, angledRayStop)

// True overlay plots
plot(tenkan, "Tenkan", color=color.new(color.blue, 0), force_overlay=true)
plot(kijun, "Kijun", color=color.new(color.orange, 0), force_overlay=true)

pA = plot(showCloud ? senkouA : na, "Senkou A", color=color.new(color.green, 60), offset=displacement, force_overlay=true)
pB = plot(showCloud ? senkouB : na, "Senkou B", color=color.new(color.red, 60), offset=displacement, force_overlay=true)
fill(pA, pB, color=senkouA > senkouB ? color.new(color.green, 85) : color.new(color.red, 85))

plotshape(preRocketRed ? preDotY : na, title="Pre-Rocket Forming Red", style=shape.circle, location=location.absolute, size=size.small, color=color.new(color.red, 20), text="", force_overlay=true)
plotshape(preRocketYellow ? preDotY : na, title="Pre-Rocket Forming Yellow", style=shape.circle, location=location.absolute, size=size.small, color=color.new(color.yellow, 0), text="", force_overlay=true)
plotshape(preRocketGreen ? preDotY : na, title="Pre-Rocket Forming Dark Green", style=shape.circle, location=location.absolute, size=size.small, color=color.rgb(0, 90, 0), text="", force_overlay=true)
plotshape(finalEarly ? dotEarlyY : na, title="Early Rocket", style=shape.triangleup, location=location.absolute, size=size.small, color=color.new(color.lime, 40), text="", force_overlay=true)
plotshape(finalConfirmed ? dotConfY : na, title="Confirmed Rocket", style=shape.triangleup, location=location.absolute, size=size.small, color=color.lime, text="", force_overlay=true)
plotshape(finalGod ? dotGodY : na, title="God Rocket", style=shape.triangleup, location=location.absolute, size=size.normal, color=color.aqua, text="", force_overlay=true)
plotshape(rocketDotBelowBarFallback and finalEarly, title="Early Rocket (belowbar)", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.new(color.lime, 40), text="", force_overlay=true)
plotshape(rocketDotBelowBarFallback and finalConfirmed, title="Confirmed Rocket (belowbar)", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.lime, text="", force_overlay=true)
plotshape(rocketDotBelowBarFallback and finalGod, title="God Rocket (belowbar)", style=shape.triangleup, location=location.belowbar, size=size.normal, color=color.aqua, text="", force_overlay=true)
plotshape(campaignWarningSquare ? campaignUpperY : na, title="Campaign Reversal Risk", style=shape.square, location=location.absolute, size=size.tiny, color=color.new(color.orange, 0), text="", force_overlay=true)
plotshape(campaignDangerSquare ? campaignUpperY : na, title="Campaign Stop Danger", style=shape.square, location=location.absolute, size=size.small, color=color.new(color.red, 0), text="", force_overlay=true)
plotshape(campaignReloadSquare ? campaignLowerY : na, title="Campaign Reload Watch", style=shape.square, location=location.absolute, size=size.tiny, color=color.new(color.yellow, 0), text="", force_overlay=true)
plotshape(campaignReentrySquare ? campaignLowerY : na, title="Campaign Re-entry Trigger", style=shape.square, location=location.absolute, size=size.small, color=color.new(color.lime, 0), text="", force_overlay=true)

// Per-signal trade map lines
if showTradeMap and finalRocket
    stopLineBars = tradeMapBars + stopLineExtraBars
    if useAngledStopLine
        angledStopEndPrice = stopPrice + atr * angledStopRiseATR * angledStopRayBars
        angledStopLine = line.new(bar_index, stopPrice, bar_index + angledStopRayBars, angledStopEndPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=2, force_overlay=true)
        array.push(angledStopLines, angledStopLine)
        array.push(angledStopStartBars, bar_index)
        array.push(angledStopStartPrices, stopPrice)
        array.push(angledStopAtrValues, atr)
        array.push(angledStopMaxBars, stopLineBars)
        array.push(angledStopActive, true)
        if array.size(angledStopLines) > maxAngledStopLines
            oldAngledStopLine = array.shift(angledStopLines)
            line.delete(oldAngledStopLine)
            array.shift(angledStopStartBars)
            array.shift(angledStopStartPrices)
            array.shift(angledStopAtrValues)
            array.shift(angledStopMaxBars)
            array.shift(angledStopActive)
    else
        line.new(bar_index, stopPrice, bar_index + stopLineBars, stopPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=2, force_overlay=true)
    line.new(bar_index, tp1Price, bar_index + tradeMapBars, tp1Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.lime, 35), style=line.style_dotted, width=1, force_overlay=true)
    line.new(bar_index, tp2Price, bar_index + tradeMapBars, tp2Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.lime, 20), style=line.style_dotted, width=1, force_overlay=true)
    line.new(bar_index, tp3Price, bar_index + tradeMapBars, tp3Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.lime, 0), style=line.style_solid, width=2, force_overlay=true)

// Optional debug triangle, off by default
if (finalGod or finalConfirmed or finalEarly) and showDebugLabels
    labelColor = finalGod ? color.new(color.aqua, 0) : finalConfirmed ? color.new(color.lime, 0) : color.new(color.lime, 35)
    labelY = (useAbsoluteDots ? rocketDotY : low) - (atr * debugLabelOffsetATR)
    label.new(time, labelY, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_triangleup, textcolor=color.black, color=labelColor, size=size.small, force_overlay=true)

// Alerts
alertcondition(finalGod, "God Rocket", "GOD-tier Kumo Rocket ignition detected.")
alertcondition(finalConfirmed, "Confirmed Rocket", "Confirmed Kumo Rocket setup detected.")
alertcondition(finalEarly, "Early Rocket", "Early Kumo Rocket setup detected.")
alertcondition(preRocketRed, "Pre-Rocket Forming Red", "Pre-Rocket formation is starting.")
alertcondition(preRocketYellow, "Pre-Rocket Forming Yellow", "Pre-Rocket formation is strengthening.")
alertcondition(preRocketGreen, "Pre-Rocket Forming Dark Green", "Strong Pre-Rocket formation detected before cloud contact.")
alertcondition(campaignWarningSquare, "Rocket Campaign Reversal Risk", "Post-Rocket campaign warning: first push is showing rejection or Tenkan loss.")
alertcondition(campaignDangerSquare, "Rocket Campaign Stop Danger", "Post-Rocket campaign danger: stop/signal-low failure risk detected.")
alertcondition(campaignReloadSquare, "Rocket Campaign Reload Watch", "Post-Rocket campaign reload watch: pullback may still be alive.")
alertcondition(campaignReentrySquare, "Rocket Campaign Re-entry Trigger", "Post-Rocket campaign re-entry trigger: pullback reclaimed with renewed impulse.")
alertcondition(angledStopHit, "Angled Stop Tagged", "The angled trailing stop line was tagged by price.")

// -----------------------------------------------------------------------------
// ATR support stop line and ATR Support Coil/Reclaim LONG signals
// This shared calculation replaces loading the purple ATR stop indicator and
// the separate ATR Support LONG signal indicator.
// -----------------------------------------------------------------------------
supportGroup = "ATR Support Stop + Long Signal"
supportLowLookback = input.int(40, "Lowest Low Lookback", minval=1, maxval=500, group=supportGroup)
supportAtrLength = input.int(20, "ATR SMA Length", minval=1, group=supportGroup)
supportAtrMultiplier = input.float(1.0, "ATR Buffer Below Low", minval=0.0, step=0.1, group=supportGroup)
supportShowLowReference = input.bool(false, "Show Lowest Low Reference", group=supportGroup)

supportSetupGroup = "ATR Support LONG Setups"
supportReclaimWindow = input.int(5, "Reclaim Window (Bars)", minval=1, maxval=100, group=supportSetupGroup)
supportCoilDistanceAtr = input.float(1.0, "Max Coil Distance (ATR)", minval=0.0, step=0.1, group=supportSetupGroup)

supportFilterGroup = "ATR Support LONG Filters"
supportUseTrendFilter = input.bool(false, "Use Trend Filter", group=supportFilterGroup)
supportTrendLength = input.int(20, "Trend SMA Length", minval=1, group=supportFilterGroup)
supportUseVolumeFilter = input.bool(false, "Use Volume Filter", group=supportFilterGroup)
supportVolumeLength = input.int(20, "Volume SMA Length", minval=1, group=supportFilterGroup)

supportTrueRange = ta.tr(true)
supportCurrentAtr = ta.sma(supportTrueRange, supportAtrLength)
supportCurrentLowestLow = ta.lowest(low, supportLowLookback)
supportAtrStop = supportCurrentLowestLow - supportCurrentAtr * supportAtrMultiplier
supportRecentFrozenStop = ta.lowest(supportAtrStop[1], supportReclaimWindow)

supportTrendAverage = ta.sma(close, supportTrendLength)
supportVolumeAverage = ta.sma(volume, supportVolumeLength)
supportTrendPass = not supportUseTrendFilter or close > supportTrendAverage
supportVolumePass = not supportUseVolumeFilter or volume > supportVolumeAverage
supportFiltersPass = supportTrendPass and supportVolumePass

// The original strategy accepted entries only while flat. This hidden virtual
// position follows its 1R/2R/3R and ATR-stop lifecycle only to suppress LONG
// markers until that original trade would have completed.
var bool supportVirtualLongOpen = false
var float supportVirtualEntryPrice = na
var float supportVirtualInitialStop = na
var float supportVirtualTp1 = na
var float supportVirtualTp2 = na
var float supportVirtualTp3 = na
var float supportVirtualTrailStop = na
var float supportVirtualActiveStop = na
var bool supportVirtualTp1Reached = false
var bool supportVirtualTp2Reached = false
var bool supportVirtualTp3Reached = false

// Process an existing virtual position first. A strategy using orders already
// active from the prior close can exit during this bar and enter again at close.
if supportVirtualLongOpen
    supportStopWasHit = not na(supportVirtualActiveStop) and low <= supportVirtualActiveStop
    if supportStopWasHit
        supportVirtualLongOpen := false
        supportVirtualEntryPrice := na
        supportVirtualInitialStop := na
        supportVirtualTp1 := na
        supportVirtualTp2 := na
        supportVirtualTp3 := na
        supportVirtualTrailStop := na
        supportVirtualActiveStop := na
        supportVirtualTp1Reached := false
        supportVirtualTp2Reached := false
        supportVirtualTp3Reached := false
    else
        supportVirtualTp1Reached := supportVirtualTp1Reached or high >= supportVirtualTp1
        supportVirtualTp2Reached := supportVirtualTp2Reached or high >= supportVirtualTp2
        supportVirtualTp3Reached := supportVirtualTp3Reached or high >= supportVirtualTp3
        supportRawTrailStop = supportAtrStop
        supportVirtualTrailStop := na(supportVirtualTrailStop) ? supportRawTrailStop : math.max(supportVirtualTrailStop, supportRawTrailStop)
        supportBreakevenStop = math.max(supportVirtualInitialStop, supportVirtualEntryPrice)
        supportProtectedStop = math.max(supportBreakevenStop, supportVirtualTrailStop)
        supportVirtualActiveStop := supportVirtualTp2Reached ? supportProtectedStop : supportVirtualTp1Reached ? supportBreakevenStop : supportVirtualInitialStop

// Capture reclaim events only while the original strategy would be flat.
var bool supportReclaimArmed = false
var float supportCapturedFrozenStop = na
var float supportCapitulationLow = na
var int supportBreakBarIndex = na

if barstate.isconfirmed and supportReclaimArmed and bar_index - supportBreakBarIndex > supportReclaimWindow
    supportReclaimArmed := false
    supportCapturedFrozenStop := na
    supportCapitulationLow := na
    supportBreakBarIndex := na

supportFlatForSignal = not supportVirtualLongOpen
supportPriceBreaksFrozenStop = barstate.isconfirmed and supportFlatForSignal and not na(supportRecentFrozenStop) and low < supportRecentFrozenStop

if supportPriceBreaksFrozenStop and not supportReclaimArmed
    supportReclaimArmed := true
    supportCapturedFrozenStop := supportRecentFrozenStop
    supportCapitulationLow := low
    supportBreakBarIndex := bar_index
else if barstate.isconfirmed and supportReclaimArmed
    supportCapitulationLow := math.min(supportCapitulationLow, low)

supportBarsSinceBreak = supportReclaimArmed ? bar_index - supportBreakBarIndex : na
supportReclaimSignal = barstate.isconfirmed and supportFlatForSignal and supportReclaimArmed and supportBarsSinceBreak <= supportReclaimWindow and close > supportCapturedFrozenStop and close > open and supportFiltersPass

supportDistanceFromAtrStop = not na(supportCurrentAtr) and supportCurrentAtr > 0 ? (close - supportAtrStop) / supportCurrentAtr : na
supportCoilSetup = not na(supportDistanceFromAtrStop) and close > supportAtrStop and supportDistanceFromAtrStop <= supportCoilDistanceAtr
supportCoilSignal = barstate.isconfirmed and supportFlatForSignal and supportCoilSetup and close > open and close > close[1] and supportFiltersPass

supportLongSignal = supportReclaimSignal or supportCoilSignal
supportRecentSwingLow = ta.lowest(low, supportReclaimWindow)
supportReclaimStopLow = supportReclaimSignal and not na(supportCapitulationLow) ? math.min(supportCapitulationLow, supportRecentSwingLow) : supportRecentSwingLow
supportSignalStopPrice = math.min(supportAtrStop, supportReclaimStopLow)
supportSignalRisk = close - supportSignalStopPrice
supportValidLongSignal = supportLongSignal and not na(supportSignalRisk) and supportSignalRisk > syminfo.mintick

if supportValidLongSignal
    supportVirtualLongOpen := true
    supportVirtualEntryPrice := close
    supportVirtualInitialStop := supportSignalStopPrice
    supportVirtualTp1 := supportVirtualEntryPrice + supportSignalRisk
    supportVirtualTp2 := supportVirtualEntryPrice + supportSignalRisk * 2.0
    supportVirtualTp3 := supportVirtualEntryPrice + supportSignalRisk * 3.0
    supportVirtualTrailStop := supportVirtualInitialStop
    supportVirtualActiveStop := supportVirtualInitialStop
    supportVirtualTp1Reached := false
    supportVirtualTp2Reached := false
    supportVirtualTp3Reached := false

    supportReclaimArmed := false
    supportCapturedFrozenStop := na
    supportCapitulationLow := na
    supportBreakBarIndex := na

// Purple ATR stop and SMA ATR readout from the original ATR-stop indicator.
plot(supportAtrStop, "ATR Support Stop", color=color.purple, linewidth=2, style=plot.style_stepline, force_overlay=true)
plot(supportShowLowReference ? supportCurrentLowestLow : na, "ATR Support Lowest Low", color=color.new(color.purple, 65), linewidth=1, style=plot.style_stepline, force_overlay=true)

var table supportAtrBox = table.new(position.top_right, 1, 2, frame_color=color.purple, frame_width=2, border_color=color.new(color.purple, 30), border_width=1)

if barstate.islast
    table.cell(supportAtrBox, 0, 0, "ATR (SMA " + str.tostring(supportAtrLength) + ")", text_color=color.white, bgcolor=color.purple, text_size=size.small)
    table.cell(supportAtrBox, 0, 1, str.tostring(supportCurrentAtr, format.mintick), text_color=color.purple, bgcolor=color.new(color.white, 0), text_size=size.large)

plotshape(supportValidLongSignal, title="ATR Support LONG Signal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="LONG", textcolor=color.white, force_overlay=true)

alertcondition(ta.crossunder(low, supportAtrStop), "ATR Support Stop Tagged", "Price has tagged the current-low current-ATR stop-loss line.")
alertcondition(supportValidLongSignal, "ATR Support Long Signal", "ATR Support long signal.")
````
