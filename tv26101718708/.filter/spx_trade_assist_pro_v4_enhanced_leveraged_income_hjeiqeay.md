# SPX Trade Assist Pro v4 - Enhanced - Leveraged Income

- url: https://www.tradingview.com/script/HjeiqeaY-SPX-Trade-Assist-Pro-v4-Enhanced-Leveraged-Income/
- type: indicator
- pine_id: PUB;d903f20ed7284cde82bf421b3e7c8cc0
- version: 1.0

## Description

SPX Trade Assist Pro v4 – Enhanced is a precision-built trading system designed specifically for SPX, SPXW, ES, and 0DTE options traders who want institutional-level signal clarity without the noise.

This indicator combines trend structure, volume intelligence, volatility modeling, and multi-timeframe alignment into a single, actionable decision engine that highlights only the highest-probability setups.

🔥 Core Edge

Unlike basic indicators, this system doesn’t rely on a single signal.
It builds a confluence-based scoring model that evaluates:

Trend strength (EMA 9/21/50 structure)
VWAP positioning and reactions
MACD momentum shifts
Volume expansion and participation
Market structure (HH/HL / LH/LL)
Volatility conditions (ATR-based)
Multi-timeframe alignment
Support / resistance interaction
Volume profile (POC awareness)

Each setup is scored and graded into A+ quality trades, helping you avoid low-probability entries.

📊 What Makes v4 “Enhanced”
✅ Smart Entry Detection

Automatically identifies:

VWAP bounces
EMA pullbacks
Breakouts and reclaim setups
Trend continuation entries
Support/resistance reactions
✅ A+ Trade Scoring System

Every trade is ranked using a confluence score (0–100)
→ Only trades above your threshold trigger signals

✅ Dynamic Options Guidance
Auto-calculates ATM / 1-OTM strike suggestions
Built for 0DTE / 1DTE SPX options
Displays CALL / PUT levels with confidence %
✅ Advanced Risk Engine
ATR-based stop loss and profit targets
Dual take-profit levels (T1 / T2)
Dynamic position sizing based on account risk
Real-time P&L tracking
✅ Market Phase Awareness

Instantly identifies:

TREND
RANGE
EXTENDED
WEAK CONDITIONS

→ Prevents chasing bad environments

✅ Multi-Timeframe Confirmation

Aligns lower timeframe entries with higher timeframe trend
→ Filters out fake moves and chop

🧠 Built-In Trade Intelligence

The system continuously evaluates:

Bias: Long / Short / Neutral
Confidence % based on confluence
Entry quality (Fresh / Late / No Trade)
Volume strength
ADX trend strength (optional)

Displayed via a real-time dashboard for instant decision-making.

🎯 Visual Execution Tools
Clean Buy/Sell signals on chart
Entry + Exit labels with P&L
Dynamic stop + target plotting
Trend-based background coloring
Support & Resistance lines
Strike callouts for options traders
⚡ Trade Management Features
Momentum failure exits
VWAP breakdown exits
Time-based trade exits
One-time take-profit alerts
Cooldown logic to avoid overtrading
🧩 Designed For
SPX / SPXW options traders (especially 0DTE)
ES / MES futures traders
Intraday scalpers and momentum traders
Traders who want structure + automation-ready logic
💡 Why It Works

Most traders lose because they:

Enter without confirmation
Trade in chop
Ignore structure
Overtrade weak setups

This system solves that by enforcing:

Confluence
Discipline
Timing
Risk control
⚠️ Important

This is a decision-support tool, not financial advice.
Use it to enhance your strategy, not replace your judgment.

🧠 Summary

SPX Trade Assist Pro v4 – Enhanced = Structured edge + real-time intelligence + disciplined execution

If you trade SPX and want:

Better entries
Cleaner exits
Higher-quality setups

This tool was built for you.

## Source Code

````pine
//@version=6
indicator("SPX Trade Assist Pro v4 - Enhanced", overlay=true, max_labels_count=500, max_lines_count=200)

// ============================================
// INPUTS - ORGANIZED
// ============================================
groupTrend   = "Trend Logic"
groupFilter  = "Market Phase Filters"
groupSession = "Session Filter"
groupRisk    = "Risk Guidance"
groupQuality = "A+ Trade Filters"
groupVisual  = "Visuals"
groupTips    = "Trade Tips"
groupMTF     = "Multi-Timeframe"

// TREND SETTINGS
fastLen               = input.int(9, "Fast EMA", minval=1, group=groupTrend)
slowLen               = input.int(21, "Slow EMA", minval=1, group=groupTrend)
trendLen              = input.int(50, "Trend EMA", minval=1, group=groupTrend)
useVWAP               = input.bool(true, "Use VWAP Confirmation", group=groupTrend)
useMACD               = input.bool(true, "Use MACD Confirmation", group=groupTrend)
useADX                = input.bool(false, "Use ADX Filter", group=groupTrend)
minTrendStrengthATR   = input.float(0.10, "Min Trend Strength", minval=0.01, step=0.01, group=groupTrend)
adxThreshold          = input.float(20, "ADX Threshold", minval=0, step=1, group=groupTrend)

// MARKET PHASE FILTERS
avoidRangeMarkets     = input.bool(false, "Avoid Range Markets", group=groupFilter)
rangeAtrFactorEMA     = input.float(0.18, "Range Threshold EMA", minval=0.01, step=0.01, group=groupFilter)
rangeAtrFactorVWAP    = input.float(0.25, "Range Threshold VWAP", minval=0.01, step=0.01, group=groupFilter)
useSRLevels           = input.bool(true, "Use Support/Resistance", group=groupFilter)
useVolumeProfile      = input.bool(true, "Use Volume Profile", group=groupFilter)

// SESSION - RELAXED
useSession            = input.bool(false, "Use Session Filter", group=groupSession)
tradeSession          = input.session("0930-1130", "Trade Session", group=groupSession)
secondarySession      = input.session("1130-1230", "Secondary Session", group=groupSession)
avoidNewsTime         = input.bool(false, "Avoid News Time", group=groupSession)

// RISK
accountSize           = input.float(5000, "Account Size", minval=100, step=100, group=groupRisk)
riskPctPerTrade       = input.float(1.5, "Risk % Per Trade", minval=0.1, maxval=5.0, step=0.1, group=groupRisk)
atrLen                = input.int(14, "ATR Length", minval=1, group=groupRisk)
atrStopMult           = input.float(0.9, "ATR Stop Multiplier", minval=0.1, step=0.1, group=groupRisk)
atrTarget1Mult        = input.float(1.0, "ATR Target 1", minval=0.1, step=0.1, group=groupRisk)
atrTarget2Mult        = input.float(1.8, "ATR Target 2", minval=0.1, step=0.1, group=groupRisk)
useDynamicSizing      = input.bool(true, "Dynamic Position Sizing", group=groupRisk)

// QUALITY - LOWERED THRESHOLD
minConfluenceScore    = input.int(40, "Min Confluence Score", minval=0, maxval=100, group=groupQuality)
requireVolumeConfirm  = input.bool(false, "Require Volume Confirmation", group=groupQuality)

// VISUALS
showEMAs              = input.bool(true, "Show EMAs", group=groupVisual)
showVWAP              = input.bool(true, "Show VWAP", group=groupVisual)
showSignals           = input.bool(true, "Show Signals", group=groupVisual)
showDashboard         = input.bool(true, "Show Dashboard", group=groupVisual)
showEntryExitLabels   = input.bool(true, "Show Entry/Exit Labels", group=groupVisual)
showAScore            = input.bool(true, "Show A+ Score", group=groupVisual)
showDynamicTargets    = input.bool(true, "Show Dynamic Targets", group=groupVisual)
showTrendBackground   = input.bool(true, "Show Trend Background", group=groupVisual)
showPnLCallouts       = input.bool(true, "Show PnL Callouts", group=groupVisual)
showInfoLabel         = input.bool(true, "Show Info Label", group=groupVisual)
showSRLines           = input.bool(true, "Show S/R Lines", group=groupVisual)

// TIPS
showTips              = input.bool(true, "Show Tips", group=groupTips)
showStrikeCallouts    = input.bool(true, "Show Strike Callouts", group=groupTips)
showProfitCallouts    = input.bool(true, "Show Profit Callouts", group=groupTips)
optionMode            = input.string("ATM_1OTM", "Option Mode", options=["ATM_ONLY", "ATM_1OTM"], group=groupTips)
expiryMode            = input.string("0DTE", "Expiry", options=["0DTE", "1DTE"], group=groupTips)

// MULTI-TIMEFRAME
useMTF                = input.bool(true, "Use Multi-Timeframe", group=groupMTF)
mtfTimeframe          = input.string("5", "MTF Timeframe", options=["5", "15", "30"], group=groupMTF)

// ============================================
// HELPERS
// ============================================
getQualityRating(score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B+" : score >= 55 ? "B" : "C"

getQualityColor(score) =>
    score >= 85 ? color.green : score >= 75 ? color.new(color.green, 20) : score >= 65 ? color.lime : score >= 55 ? color.orange : color.red

formatPrice(val) =>
    str.tostring(val, format.mintick)

formatPnL(pnl) =>
    pnl >= 0 ? "+" + str.tostring(pnl, "#.##") : str.tostring(pnl, "#.##")

// ============================================
// SESSION & TIME FILTERS - RELAXED
// ============================================
inSession  = not na(time(timeframe.period, tradeSession))
inSecondarySession = not na(time(timeframe.period, secondarySession))

timeHour = hour(time("D"))
timeMinute = minute(time("D"))
inLunchBool = (timeHour == 12 and timeMinute >= 30) or (timeHour == 13) or (timeHour == 14 and timeMinute < 0)
inNewsTime = timeHour == 9 and timeMinute >= 30 and timeMinute < 60

// RELAXED: sessionOk is always true if useSession is false
sessionOk  = not useSession or (inSession and not inLunchBool and (not avoidNewsTime or not inNewsTime)) or (inSecondarySession and not inLunchBool and (not avoidNewsTime or not inNewsTime))
newSession = (inSession or inSecondarySession) and not (inSession[1] or inSecondarySession[1])

inPrimarySession = inSession and not inSecondarySession
inSecondarySessionOnly = inSecondarySession and not inSession
inBothSessions = inSession and inSecondarySession

// ============================================
// CORE CALCULATIONS
// ============================================
ema9    = ta.ema(close, fastLen)
ema21   = ta.ema(close, slowLen)
ema50   = ta.ema(close, trendLen)
vwapVal = ta.vwap(close)
atrVal  = ta.atr(atrLen)
basis20 = ta.sma(close, 20)

[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)

macdHistRising = macdHist > macdHist[1]
macdHistFalling = macdHist < macdHist[1]

// ADX CALCULATION
[dx, dmiMinus, dmiPlus] = ta.dmi(14, 14)
adxVal = ta.wma(dx, 14)
trendStrong = adxVal > adxThreshold

// VOLUME ANALYSIS
volumeSMA = ta.sma(volume, 20)
volumeSpike = volume > volumeSMA * 1.3
volumeRatio = volume / volumeSMA
volumeTrend = ta.ema(volume, 20)

// VOLATILITY
volatility = atrVal / close * 100

// TIME QUALITY - ADJUSTED
timeQuality = inSession and not inLunchBool and not inNewsTime ? 100 : inSecondarySession and not inLunchBool ? 85 : 75

// ============================================
// SUPPORT/RESISTANCE DETECTION
// ============================================
lookback = 50
highestHigh = ta.highest(high, lookback)
lowestLow = ta.lowest(low, lookback)

midPoint = (highestHigh + lowestLow) / 2
rangeSize = highestHigh - lowestLow

resistanceLevel = highestHigh
supportLevel = lowestLow

nearResistance = high > resistanceLevel * 0.995
nearSupport = low < supportLevel * 1.005

// ============================================
// VOLUME PROFILE
// ============================================
pocZone = ta.sma(close, 100)
volumeAtLevel = ta.sma(volume, 100)
isAtPOC = math.abs(close - pocZone) < (atrVal * 0.5)

// ============================================
// MARKET STRUCTURE
// ============================================
higherHigh = high > ta.highest(high, 20)[1]
lowerLow = low < ta.lowest(low, 20)[1]
higherLow = low > ta.lowest(low, 20)[1]
lowerHigh = high < ta.highest(high, 20)[1]

bullishStructure = higherHigh or higherLow
bearishStructure = lowerLow or lowerHigh

// ============================================
// MULTI-TIMEFRAME ANALYSIS
// ============================================
mtfEma9 = request.security(syminfo.tickerid, mtfTimeframe, ta.ema(close, 9))
mtfEma21 = request.security(syminfo.tickerid, mtfTimeframe, ta.ema(close, 21))
mtfVWAP = request.security(syminfo.tickerid, mtfTimeframe, ta.vwap(close))

mtfBullish = close > mtfEma9 and mtfEma9 > mtfEma21
mtfBearish = close < mtfEma9 and mtfEma9 < mtfEma21
mtfAligned = mtfBullish or mtfBearish

// ============================================
// TREND STATE - RELAXED
// ============================================
bullStacked    = ema9 > ema21
bearStacked    = ema9 < ema21
priceAboveVWAP = close > vwapVal
priceBelowVWAP = close < vwapVal
macdBull       = macdLine > macdSignal and macdHist >= 0
macdBear       = macdLine < macdSignal and macdHist <= 0
trendStrength  = math.abs(ema9 - ema21) / math.max(atrVal, syminfo.mintick)
strongTrendOk  = trendStrength >= minTrendStrengthATR

// TREND FILTER WITH EMA50 - RELAXED
bullishTrend = bullStacked and close > ema50
bearishTrend = bearStacked and close < ema50

// RANGE DETECTION - RELAXED
rangeCondition = avoidRangeMarkets and math.abs(ema9 - ema21) < (atrVal * rangeAtrFactorEMA) and math.abs(close - vwapVal) < (atrVal * rangeAtrFactorVWAP)
extendedMove   = math.abs(close - basis20) > (atrVal * 1.2)

// TREND FILTERS - RELAXED
longTrendFilter  = bullishTrend and (not useVWAP or priceAboveVWAP) and (not useMACD or macdBull) and strongTrendOk and (not useADX or trendStrong) and not rangeCondition and not extendedMove
shortTrendFilter = bearishTrend and (not useVWAP or priceBelowVWAP) and (not useMACD or macdBear) and strongTrendOk and (not useADX or trendStrong) and not rangeCondition and not extendedMove

// ============================================
// ENTRY DETECTION - RELAXED
// ============================================
vwapBounceLong = low <= vwapVal and close > vwapVal and close > open
vwapBounceShort = high >= vwapVal and close < vwapVal and close < open

ema9PullbackLong = low <= ema9 and close > ema9 and bullStacked
ema9PullbackShort = high >= ema9 and close < ema9 and bearStacked

longReclaim = ta.crossover(close, ema9) or ta.crossover(close, vwapVal)
longContinuation = close > ema9 and ema9 > ema21 and close > open and close > close[1]

shortReclaim = ta.crossunder(close, ema9) or ta.crossunder(close, vwapVal)
shortContinuation = close < ema9 and ema9 < ema21 and close < open and close < close[1]

// SUPPORT/RESISTANCE ENTRIES
supportBounce = low <= supportLevel * 1.005 and close > supportLevel and bullishStructure
resistanceBreak = high >= resistanceLevel and close > resistanceLevel and bullishStructure

var int lastSignalBar = na
cooldownOk = na(lastSignalBar) or (bar_index - lastSignalBar >= 3)

longEntryRaw  = sessionOk and cooldownOk and longTrendFilter and (longReclaim or longContinuation or vwapBounceLong or ema9PullbackLong or supportBounce or resistanceBreak)
shortEntryRaw = sessionOk and cooldownOk and shortTrendFilter and (shortReclaim or shortContinuation or vwapBounceShort or ema9PullbackShort)

// Entry type detection
entryTypeLong = vwapBounceLong ? "VWAP BOUNCE" : ema9PullbackLong ? "EMA9 PULLBACK" : supportBounce ? "SUPPORT BOUNCE" : resistanceBreak ? "RESISTANCE BREAK" : longReclaim ? "RECLAIM" : "CONTINUATION"
entryTypeShort = vwapBounceShort ? "VWAP BOUNCE" : ema9PullbackShort ? "EMA9 PULLBACK" : shortReclaim ? "RECLAIM" : "CONTINUATION"

// ============================================
// A+ SCORING - RELAXED
// ============================================
longConfluenceScore = 0
if longEntryRaw
    longConfluenceScore += trendStrength >= 0.25 ? 25 : trendStrength >= 0.18 ? 20 : 15
    longConfluenceScore += volumeSpike ? 20 : volumeRatio > 1.2 ? 15 : 10
    longConfluenceScore += macdHistRising and macdHist > 0 ? 20 : macdHistRising ? 15 : 10
    longConfluenceScore += volatility >= 0.20 ? 15 : volatility >= 0.15 ? 10 : 5
    longConfluenceScore += timeQuality
    longConfluenceScore += mtfAligned and mtfBullish ? 10 : 0
    longConfluenceScore += isAtPOC ? 5 : 0

shortConfluenceScore = 0
if shortEntryRaw
    shortConfluenceScore += trendStrength >= 0.25 ? 25 : trendStrength >= 0.18 ? 20 : 15
    shortConfluenceScore += volumeSpike ? 20 : volumeRatio > 1.2 ? 15 : 10
    shortConfluenceScore += macdHistFalling and macdHist < 0 ? 20 : macdHistFalling ? 15 : 10
    shortConfluenceScore += volatility >= 0.20 ? 15 : volatility >= 0.15 ? 10 : 5
    shortConfluenceScore += timeQuality
    shortConfluenceScore += mtfAligned and mtfBearish ? 10 : 0
    shortConfluenceScore += isAtPOC ? 5 : 0

longEntryFiltered = longEntryRaw and longConfluenceScore >= minConfluenceScore and (not requireVolumeConfirm or volumeRatio > 1.0)
shortEntryFiltered = shortEntryRaw and shortConfluenceScore >= minConfluenceScore and (not requireVolumeConfirm or volumeRatio > 1.0)

// ============================================
// SIGNAL STATE
// ============================================
var int signalState = 0
var float activeEntryPrice = na
var float activeStop = na
var float activeTarget1 = na
var float activeTarget2 = na
var bool longTradeActive = false
var bool shortTradeActive = false
var bool longTPShown = false
var bool shortTPShown = false
var string lastEntryType = ""
var int lastConfluenceScore = 0

newLongSignal  = longEntryFiltered and signalState <= 0
newShortSignal = shortEntryFiltered and signalState >= 0

if newLongSignal
    signalState := 1
    activeEntryPrice := close
    activeStop := close - (atrVal * atrStopMult)
    activeTarget1 := close + (atrVal * atrTarget1Mult)
    activeTarget2 := close + (atrVal * atrTarget2Mult)
    longTradeActive := true
    shortTradeActive := false
    longTPShown := false
    shortTPShown := false
    lastSignalBar := bar_index
    lastEntryType := entryTypeLong
    lastConfluenceScore := longConfluenceScore

if newShortSignal
    signalState := -1
    activeEntryPrice := close
    activeStop := close + (atrVal * atrStopMult)
    activeTarget1 := close - (atrVal * atrTarget1Mult)
    activeTarget2 := close - (atrVal * atrTarget2Mult)
    shortTradeActive := true
    longTradeActive := false
    shortTPShown := false
    longTPShown := false
    lastSignalBar := bar_index
    lastEntryType := entryTypeShort
    lastConfluenceScore := shortConfluenceScore

// ============================================
// EXIT LOGIC - ENHANCED
// ============================================
longMomentumFailure = signalState == 1 and close < ema9 and close < open
shortMomentumFailure = signalState == -1 and close > ema9 and close > open
longVWAPFailure = signalState == 1 and close < vwapVal and close < ema21
shortVWAPFailure = signalState == -1 and close > vwapVal and close > ema21
longHardStop = signalState == 1 and low <= activeStop
shortHardStop = signalState == -1 and high >= activeStop

barsInTrade = signalState != 0 ? bar_index - lastSignalBar : 0
timeExitLong = signalState == 1 and barsInTrade > 30
timeExitShort = signalState == -1 and barsInTrade > 30

longTakeProfitSignal = longTradeActive and not longTPShown and not na(activeTarget1) and high >= activeTarget1
shortTakeProfitSignal = shortTradeActive and not shortTPShown and not na(activeTarget1) and low <= activeTarget1

exitLongSignal = longTradeActive and (longVWAPFailure or longMomentumFailure or longHardStop or timeExitLong)
exitShortSignal = shortTradeActive and (shortVWAPFailure or shortMomentumFailure or shortHardStop or timeExitShort)

if longTakeProfitSignal
    longTPShown := true

if shortTakeProfitSignal
    shortTPShown := true

if exitLongSignal
    longTradeActive := false
    signalState := 0

if exitShortSignal
    shortTradeActive := false
    signalState := 0

// ============================================
// STRIKE CALCULATION - ENHANCED
// ============================================
strikeStep = close >= 1000 ? 5.0 : 1.0
atmStrike = math.round(close / strikeStep) * strikeStep

var float callStrike = atmStrike
var float putStrike = atmStrike

if newLongSignal
    callStrike := optionMode == "ATM_ONLY" ? atmStrike : atmStrike + strikeStep

if newShortSignal
    putStrike := optionMode == "ATM_ONLY" ? atmStrike : atmStrike - strikeStep

// ============================================
// MARKET STATE - ENHANCED
// ============================================
marketPhase = rangeCondition ? "RANGE" : extendedMove ? "EXTENDED" : trendStrong ? "TREND" : "WEAK"
trendBias = signalState == 1 ? "LONG BIAS" : signalState == -1 ? "SHORT BIAS" : bullishTrend ? "BULLISH LEAN" : bearishTrend ? "BEARISH LEAN" : "NEUTRAL"

currentScore = newLongSignal ? longConfluenceScore : newShortSignal ? shortConfluenceScore : lastConfluenceScore
confidence = currentScore >= 85 ? 92 : currentScore >= 75 ? 82 : currentScore >= 65 ? 72 : currentScore >= 55 ? 58 : 45

entryQuality = newLongSignal or newShortSignal ? "FRESH ENTRY" : rangeCondition ? "NO TRADE / RANGE" : extendedMove ? "LATE / EXTENDED" : "WAIT"

qualityRating = getQualityRating(currentScore)
tradeTip = newLongSignal ? "LONG " + qualityRating + ": " + entryTypeLong + ". CALL " + str.tostring(callStrike) : newShortSignal ? "SHORT " + qualityRating + ": " + entryTypeShort + ". PUT " + str.tostring(putStrike) : "No clean edge. Wait for setup."

currentPnL = signalState == 1 ? (close - activeEntryPrice) : signalState == -1 ? (activeEntryPrice - close) : 0
currentPnLDollars = currentPnL * 10.0

// ============================================
// DYNAMIC POSITION SIZING
// ============================================
estRiskDollars = accountSize * (riskPctPerTrade / 100.0)
contractSize = not useDynamicSizing ? 1 : math.max(1, math.floor(estRiskDollars / (atrVal * atrStopMult * 10)))

// ============================================
// PLOTS
// ============================================
plot(showEMAs ? ema9 : na, title="EMA 9", linewidth=2, color=color.fuchsia)
plot(showEMAs ? ema21 : na, title="EMA 21", linewidth=2, color=color.red)
plot(showEMAs ? ema50 : na, title="EMA 50", linewidth=1, color=color.blue, style=plot.style_linebr)
plot(showVWAP ? vwapVal : na, title="VWAP", linewidth=2, color=color.aqua)

plot(showDynamicTargets and signalState != 0 ? activeStop : na, title="Active Stop", linewidth=1, color=color.orange, style=plot.style_linebr)
plot(showDynamicTargets and signalState != 0 ? activeTarget1 : na, title="Target 1", linewidth=1, color=color.green, style=plot.style_linebr)
plot(showDynamicTargets and signalState != 0 ? activeTarget2 : na, title="Target 2", linewidth=1, color=color.new(color.green, 30), style=plot.style_linebr)

plot(showSRLines ? resistanceLevel : na, title="Resistance", linewidth=1, color=color.red, style=plot.style_linebr)
plot(showSRLines ? supportLevel : na, title="Support", linewidth=1, color=color.green, style=plot.style_linebr)

bgcolor(showTrendBackground ? signalState == 1 ? color.new(color.green, 90) : signalState == -1 ? color.new(color.red, 90) : rangeCondition ? color.new(color.yellow, 88) : na : na)

plotshape(showSignals and newLongSignal, title="Long Entry", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.lime, text="L")
plotshape(showSignals and newShortSignal, title="Short Entry", style=shape.triangledown, location=location.abovebar, size=size.small, color=color.red, text="S")
plotshape(showSignals and exitLongSignal, title="Exit Long", style=shape.xcross, location=location.abovebar, size=size.small, color=color.orange, text="XL")
plotshape(showSignals and exitShortSignal, title="Exit Short", style=shape.xcross, location=location.belowbar, size=size.small, color=color.orange, text="XS")

// ============================================
// LABELS
// ============================================
if showEntryExitLabels and newLongSignal
    scoreText = showAScore ? " | " + str.tostring(longConfluenceScore) + "/" + getQualityRating(longConfluenceScore) : ""
    sessionText = inSecondarySessionOnly ? " [SEC]" : ""
    label.new(bar_index, high + atrVal * 0.3, "LONG ENTRY\n" + formatPrice(close) + "\n" + entryTypeLong + "\nCALL " + str.tostring(callStrike) + scoreText + sessionText, yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=getQualityColor(longConfluenceScore), size=size.small)

if showEntryExitLabels and newShortSignal
    scoreText = showAScore ? " | " + str.tostring(shortConfluenceScore) + "/" + getQualityRating(shortConfluenceScore) : ""
    sessionText = inSecondarySessionOnly ? " [SEC]" : ""
    label.new(bar_index, low - atrVal * 0.3, "SHORT ENTRY\n" + formatPrice(close) + "\n" + entryTypeShort + "\nPUT " + str.tostring(putStrike) + scoreText + sessionText, yloc=yloc.belowbar, style=label.style_label_up, textcolor=color.white, color=getQualityColor(shortConfluenceScore), size=size.small)

if showEntryExitLabels and exitLongSignal
    pnlText = currentPnLDollars >= 0 ? formatPnL(currentPnLDollars) : formatPnL(currentPnLDollars)
    label.new(bar_index, high + atrVal * 0.2, "EXIT LONG\n" + formatPrice(close) + "\nP&L: $" + pnlText, yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=color.orange, size=size.small)

if showEntryExitLabels and exitShortSignal
    pnlText = currentPnLDollars >= 0 ? formatPnL(currentPnLDollars) : formatPnL(currentPnLDollars)
    label.new(bar_index, low - atrVal * 0.2, "EXIT SHORT\n" + formatPrice(close) + "\nP&L: $" + pnlText, yloc=yloc.belowbar, style=label.style_label_up, textcolor=color.white, color=color.orange, size=size.small)

if showStrikeCallouts and newLongSignal
    label.new(bar_index, high, "CALL " + str.tostring(callStrike) + " | " + str.tostring(confidence) + "%", yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=color.green, size=size.small)

if showStrikeCallouts and newShortSignal
    label.new(bar_index, high, "PUT " + str.tostring(putStrike) + " | " + str.tostring(confidence) + "%", yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=color.red, size=size.small)

if showProfitCallouts and longTakeProfitSignal
    label.new(bar_index, high, "TAKE PROFIT ONCE\nScale 50% near T1", yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=color.new(color.green, 0), size=size.small)

if showProfitCallouts and shortTakeProfitSignal
    label.new(bar_index, low, "TAKE PROFIT ONCE\nScale 50% near T1", yloc=yloc.belowbar, style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0), size=size.small)

if showPnLCallouts and (signalState == 1 or signalState == -1)
    pnlColor = currentPnLDollars >= 0 ? color.green : color.red
    label.new(bar_index, signalState == 1 ? low - atrVal * 0.5 : high + atrVal * 0.5, "P&L: $" + formatPnL(currentPnLDollars), yloc=signalState == 1 ? yloc.belowbar : yloc.abovebar, style=signalState == 1 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=pnlColor, size=size.tiny)

// ============================================
// DASHBOARD - ENHANCED
// ============================================
var table dash = table.new(position.top_right, 2, 19, border_width=2)

phaseColor = marketPhase == "TREND" ? color.new(color.green, 75) : marketPhase == "RANGE" ? color.new(color.yellow, 60) : marketPhase == "EXTENDED" ? color.new(color.orange, 65) : color.new(color.gray, 70)
biasColor = signalState == 1 ? color.new(color.green, 70) : signalState == -1 ? color.new(color.red, 70) : color.new(color.blue, 78)
scoreColor = getQualityColor(currentScore)
adxColor = trendStrong ? color.green : color.orange

if barstate.islast and showDashboard
    bg = color.black

    table.cell(dash, 0, 0, "Metric", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "Value", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 0, 1, "Bias", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 1, trendBias, bgcolor=biasColor, text_color=color.white)
    table.cell(dash, 0, 2, "Phase", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 2, marketPhase, bgcolor=phaseColor, text_color=color.white)
    table.cell(dash, 0, 3, "A+ Score", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(currentScore) + "/" + getQualityRating(currentScore), bgcolor=scoreColor, text_color=color.white)
    table.cell(dash, 0, 4, "Confidence", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(confidence) + "%", bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 5, "ADX", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(adxVal, "#.##"), bgcolor=adxColor, text_color=color.white)
    table.cell(dash, 0, 6, "Entry", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 6, entryQuality, bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 7, "Session", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 7, inSecondarySessionOnly ? "SECONDARY" : inPrimarySession ? "PRIMARY" : "OFF SESSION", bgcolor=inSecondarySessionOnly ? color.orange : inPrimarySession ? color.green : color.gray, text_color=color.white)
    table.cell(dash, 0, 8, "Call", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 8, str.tostring(callStrike), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 9, "Put", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 9, str.tostring(putStrike), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 10, "Expiry", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 10, expiryMode, bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 11, "Risk", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 11, "$" + str.tostring(estRiskDollars), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 12, "Contracts", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 12, str.tostring(contractSize), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 13, "T1/T2", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 13, str.tostring(activeTarget1, format.mintick) + " / " + str.tostring(activeTarget2, format.mintick), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 14, "Stop", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 14, str.tostring(activeStop, format.mintick), bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 15, "Entry Price", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 15, not na(activeEntryPrice) ? formatPrice(activeEntryPrice) : "N/A", bgcolor=bg, text_color=color.white)
    table.cell(dash, 0, 16, "P&L", bgcolor=bg, text_color=color.white)
    pnlColor = currentPnLDollars >= 0 ? color.green : color.red
    table.cell(dash, 1, 16, signalState != 0 ? "$" + formatPnL(currentPnLDollars) : "-", bgcolor=bg, text_color=pnlColor)
    table.cell(dash, 0, 17, "MTF", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 17, mtfAligned ? (mtfBullish ? "BULL" : "BEAR") : "NEUTRAL", bgcolor=mtfBullish ? color.green : mtfBearish ? color.red : color.gray, text_color=color.white)
    table.cell(dash, 0, 18, "Vol Ratio", bgcolor=bg, text_color=color.white)
    table.cell(dash, 1, 18, str.tostring(volumeRatio, "#.##"), bgcolor=volumeRatio > 1.3 ? color.green : color.gray, text_color=color.white)

// ============================================
// TIPS LABEL - ENHANCED
// ============================================
var label infoLabel = na

if barstate.islast and showInfoLabel and showTips
    label.delete(infoLabel)
    mtfText = useMTF ? "\nMTF: " + (mtfBullish ? "BULLISH" : mtfBearish ? "BEARISH" : "NEUTRAL") : ""
    adxText = useADX ? "\nADX: " + str.tostring(adxVal, "#.##") + (trendStrong ? " (STRONG)" : " (WEAK)") : ""
    sessionInfo = inSecondarySessionOnly ? " (SEC)" : ""
    infoLabel := label.new(bar_index, high + atrVal * 0.6, "SPX Trade Assist Pro v4" + sessionInfo + "\nPhase: " + marketPhase + "\nBias: " + trendBias + "\nA+ Score: " + str.tostring(currentScore) + "/" + qualityRating + "\nTip: " + tradeTip + mtfText + adxText, style=label.style_label_left, textcolor=color.white, color=color.new(color.black, 10), size=size.small)

// ============================================
// ALERTS
// ============================================
alertcondition(newLongSignal, title="Long Entry Alert", message="LONG_ENTRY")
alertcondition(newShortSignal, title="Short Entry Alert", message="SHORT_ENTRY")
alertcondition(exitLongSignal, title="Exit Long Alert", message="EXIT_LONG")
alertcondition(exitShortSignal, title="Exit Short Alert", message="EXIT_SHORT")
alertcondition(longTakeProfitSignal, title="Long TP Hit", message="LONG_TP")
alertcondition(shortTakeProfitSignal, title="Short TP Hit", message="SHORT_TP")

if newLongSignal
    sessionAlert = inSecondarySessionOnly ? "[SECONDARY SESSION] " : ""
    alert(sessionAlert + "LONG_SIGNAL: " + entryTypeLong + " (" + getQualityRating(longConfluenceScore) + ")", alert.freq_once_per_bar_close)

if newShortSignal
    sessionAlert = inSecondarySessionOnly ? "[SECONDARY SESSION] " : ""
    alert(sessionAlert + "SHORT_SIGNAL: " + entryTypeShort + " (" + getQualityRating(shortConfluenceScore) + ")", alert.freq_once_per_bar_close)

if exitLongSignal
    alert("EXIT_LONG: P&L $" + str.tostring(currentPnLDollars), alert.freq_once_per_bar_close)

if exitShortSignal
    alert("EXIT_SHORT: P&L $" + str.tostring(currentPnLDollars), alert.freq_once_per_bar_close)
````
