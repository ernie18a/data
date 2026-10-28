# ZenFlow Scanner v2.3

- url: https://www.tradingview.com/script/L3OZmZ3M-ZenFlow-Scanner-v2-3/
- type: indicator
- pine_id: PUB;43a225c346bc414593e151600868e4a6
- version: 1.0

## Description

ZenFlow Scanner v2.0 is a streamlined institutional-style market scanner designed to identify high-probability trading opportunities using a powerful combination of Volume Weighted Average Price, Exponential Moving Average alignment, market structure, and momentum analysis. Built for futures, stocks, and options traders, ZenFlow helps detect A+ setups by combining trend confirmation, mean reversion, and price-action context into a clean, easy-to-read dashboard. Developed by Calm Hustle Company, this tool is intended to help traders stay disciplined, reduce noise, and focus only on the highest-quality opportunities.

## Source Code

````pine
//@version=5
indicator("ZenFlow Scanner v2.3 — Minimal Adaptive Execution", overlay=true, max_labels_count=300, max_lines_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMode     = "Instrument Mode"
groupCore     = "Core Setup"
groupEngine   = "Signal Engines"
groupOF       = "Order Flow Proxy"
groupSetup    = "Setup / Trigger / Invalidation"
groupSession  = "Sessions"
groupRisk     = "Risk / Targets"
groupVisual   = "Visuals"
groupDash     = "Dashboard"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
instrumentMode = input.string("NQ", "Instrument Mode", options=["NQ", "ES/MES", "Stocks", "Manual"], group=groupMode)

emaFastLen = input.int(9, "Fast EMA", group=groupCore)
emaSlowLen = input.int(21, "Slow EMA", group=groupCore)
volLen     = input.int(20, "Volume MA Length", group=groupCore)
useVWAP    = input.bool(true, "Use VWAP Filter", group=groupCore)
useVolume  = input.bool(true, "Use Volume Filter", group=groupCore)
manualVolMult  = input.float(1.2, "Manual Volume Multiplier", step=0.1, group=groupCore)
manualATRMult  = input.float(1.2, "Manual ATR Stop Multiplier", step=0.1, group=groupCore)
manualBreakLen = input.int(1, "Manual Break Lookback", minval=1, maxval=10, group=groupCore)

useContinuationEngine = input.bool(true, "Use A+ Continuation Engine", group=groupEngine)
usePullbackEngine     = input.bool(true, "Use PB Pullback Engine", group=groupEngine)
useReversalEngine     = input.bool(true, "Use REV Reversal Engine", group=groupEngine)
useMomentumState      = input.bool(true, "Use Momentum Continuation State", group=groupEngine)
pullbackNeedsVolume   = input.bool(false, "PB Requires Volume Expansion", group=groupEngine)
pullbackBreakLen      = input.int(2, "PB Structure Break Lookback", minval=1, maxval=10, group=groupEngine)
reversalNeedsVolume   = input.bool(false, "REV Requires Volume Expansion", group=groupEngine)
reversalBreakLen      = input.int(2, "REV Structure Break Lookback", minval=1, maxval=10, group=groupEngine)

useOrderFlow       = input.bool(true, "Use Order Flow Scoring", group=groupOF)
useOrderFlowFilter = input.bool(false, "Require Order Flow Confirmation", group=groupOF)
ofLen              = input.int(20, "Delta / Pressure Length", minval=2, group=groupOF)
ofSmooth           = input.int(8, "Cumulative Delta EMA", minval=1, group=groupOF)
ofDeltaMult        = input.float(0.55, "Delta Strength Threshold", step=0.05, group=groupOF)
trapLookback       = input.int(5, "Trap Lookback", minval=2, maxval=20, group=groupOF)
trapBoost          = input.int(10, "Trap Confidence Boost", minval=0, maxval=25, group=groupOF)
impulseBoost       = input.int(8, "Impulse Confidence Boost", minval=0, maxval=25, group=groupOF)

vwapProxATR = input.float(0.35, "VWAP Decision Zone ATR", step=0.05, group=groupSetup)
emaProxATR  = input.float(0.35, "EMA Pullback Zone ATR", step=0.05, group=groupSetup)
requireTriggerForEntries = input.bool(false, "Require Trigger Confirmation for Entries", group=groupSetup)
useLTFExecutionMode = input.bool(true, "Use Lower-Timeframe Execution Mode", group=groupSetup)
ltfEntryMinScore = input.int(60, "LTF / Momentum Minimum Entry %", minval=40, maxval=90, group=groupSetup)
triggerLookback   = input.int(2, "Trigger Structure Lookback", minval=1, maxval=10, group=groupSetup)
wickRatioTrigger  = input.float(1.2, "Rejection Wick Ratio", minval=0.5, step=0.1, group=groupSetup)
useInvalidation       = input.bool(true, "Use Dynamic Invalidation", group=groupSetup)
invalidateOnVWAPFlip  = input.bool(true, "Invalidate on VWAP + EMA Flip", group=groupSetup)
invalidateOnOFImpulse = input.bool(true, "Invalidate on Opposite Order Flow", group=groupSetup)

useSessionFilter = input.bool(false, "Use Session Filter", group=groupSession)
asiaSession      = input.session("1800-0000", "Asia Session", group=groupSession)
nySession        = input.session("0830-1100", "NY Session", group=groupSession)
sessionMode      = input.string("Any", "Allowed Session", options=["Any", "Asia", "NY"], group=groupSession)
shadeSessions    = input.bool(true, "Shade Active Sessions", group=groupSession)

atrLen  = input.int(14, "ATR Length", group=groupRisk)
rr1     = input.float(1.0, "Target 1 R", step=0.25, group=groupRisk)
rr2     = input.float(2.0, "Target 2 R", step=0.25, group=groupRisk)
rr3     = input.float(3.0, "Target 3 R", step=0.25, group=groupRisk)
showTP3 = input.bool(true, "Show TP3", group=groupRisk)

visualMode = input.string("Clean", "Visual Mode", options=["Clean", "Full"], group=groupVisual)
showSignals = input.bool(true, "Show Entry Signal Tags", group=groupVisual)
showTriggerMarks = input.bool(false, "Show Trigger Tags", group=groupVisual)
showOFMarks = input.bool(false, "Show Order Flow Tags", group=groupVisual)
showLevels = input.bool(true, "Show Entry / Stop / Targets", group=groupVisual)
showDecisionBg = input.bool(true, "Highlight VWAP Decision Zone", group=groupVisual)
showPBHighlight = input.bool(true, "Highlight PB Trigger Candle", group=groupVisual)

showMainDash = input.bool(true, "Show Main Dashboard", group=groupDash)
showOrderFlowMini = input.bool(true, "Show Order Flow Mini", group=groupDash)
showActiveTradeMini = input.bool(true, "Show Active Trade Mini", group=groupDash)
showCenterPanel = input.bool(false, "Show Targets / Stats Panel", group=groupDash)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTO SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volMult = instrumentMode == "NQ" ? 1.20 : instrumentMode == "ES/MES" ? 1.10 : instrumentMode == "Stocks" ? 1.50 : manualVolMult
autoATRMult = instrumentMode == "NQ" ? 1.20 : instrumentMode == "ES/MES" ? 1.05 : instrumentMode == "Stocks" ? 1.20 : manualATRMult
breakLookback = instrumentMode == "ES/MES" ? 3 : instrumentMode == "Stocks" ? 1 : instrumentMode == "NQ" ? 1 : manualBreakLen

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapVal = ta.vwap(close)
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
highVol = volume > volAvg * volMult
volPass = useVolume ? highVol : true

bullTrend = close > emaSlow and emaFast > emaSlow
bearTrend = close < emaSlow and emaFast < emaSlow
aboveVWAP = close > vwapVal
belowVWAP = close < vwapVal
vwapReclaim = close > vwapVal and close[1] <= vwapVal[1]
vwapReject = close < vwapVal and close[1] >= vwapVal[1]
emaBullFlip = ta.crossover(emaFast, emaSlow)
emaBearFlip = ta.crossunder(emaFast, emaSlow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inAsia = not na(time(timeframe.period, asiaSession))
inNY = not na(time(timeframe.period, nySession))
sessionOK = sessionMode == "Any" ? true : sessionMode == "Asia" ? inAsia : sessionMode == "NY" ? inNY : true
sessionPass = useSessionFilter ? sessionOK : true
sessionName = inAsia ? "Asia" : inNY ? "NY" : "Other"
bgcolor(shadeSessions and inAsia ? color.new(color.blue, 93) : na)
bgcolor(shadeSessions and inNY ? color.new(color.green, 93) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER FLOW PROXY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closeLocation = (close - low) / barRange
buyPressureVol = volume * closeLocation
sellPressureVol = volume * (1.0 - closeLocation)
deltaProxy = buyPressureVol - sellPressureVol
absDeltaAvg = ta.ema(math.abs(deltaProxy), ofLen)
deltaStrength = absDeltaAvg > 0 ? deltaProxy / absDeltaAvg : 0.0
cumDeltaProxy = ta.cum(deltaProxy)
cumDeltaSignal = ta.ema(cumDeltaProxy, ofSmooth)

bullOFImpulse = deltaStrength >= ofDeltaMult and cumDeltaProxy >= cumDeltaSignal and closeLocation >= 0.60
bearOFImpulse = deltaStrength <= -ofDeltaMult and cumDeltaProxy <= cumDeltaSignal and closeLocation <= 0.40
bullAbsorption = highVol and lowerWick > bodySize and closeLocation >= 0.55
bearAbsorption = highVol and upperWick > bodySize and closeLocation <= 0.45
bullExhaustion = highVol and upperWick > bodySize * 1.5 and closeLocation < 0.60 and close > open
bearExhaustion = highVol and lowerWick > bodySize * 1.5 and closeLocation > 0.40 and close < open

recentHigh = ta.highest(high, trapLookback)[1]
recentLow = ta.lowest(low, trapLookback)[1]
failedBreakHigh = high > recentHigh and close < recentHigh
failedBreakLow = low < recentLow and close > recentLow
longTrap = failedBreakLow and deltaStrength < 0 and closeLocation >= 0.55
shortTrap = failedBreakHigh and deltaStrength > 0 and closeLocation <= 0.45
impulseBody = bodySize >= ta.ema(bodySize, ofLen) * 1.4
bullImpulseTag = impulseBody and bullOFImpulse and close > high[1]
bearImpulseTag = impulseBody and bearOFImpulse and close < low[1]

bullOFPass = useOrderFlow ? (bullOFImpulse or bullAbsorption or longTrap) : true
bearOFPass = useOrderFlow ? (bearOFImpulse or bearAbsorption or shortTrap) : true
ofLongGate = useOrderFlowFilter ? bullOFPass : true
ofShortGate = useOrderFlowFilter ? bearOFPass : true
ofText = bullOFImpulse ? "Bull Impulse" : bearOFImpulse ? "Bear Impulse" : bullAbsorption ? "Buy Absorb" : bearAbsorption ? "Sell Absorb" : "Neutral"
impulseWatchLong = bullOFImpulse and aboveVWAP and not bearTrend
impulseWatchShort = bearOFImpulse and belowVWAP and not bullTrend
ofBg = bullOFImpulse or bullAbsorption ? color.new(color.green, 25) : bearOFImpulse or bearAbsorption ? color.new(color.red, 25) : color.new(color.gray, 55)
modifierText = longTrap ? "Long Trap" : shortTrap ? "Short Trap" : bullImpulseTag ? "Bull Impulse" : bearImpulseTag ? "Bear Impulse" : "None"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE / WATCH STATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
breakHigh = breakLookback <= 1 ? close > high[1] : close > ta.highest(high, breakLookback)[1]
breakLow = breakLookback <= 1 ? close < low[1] : close < ta.lowest(low, breakLookback)[1]
pbBreakHigh = pullbackBreakLen <= 1 ? close > high[1] : close > ta.highest(high, pullbackBreakLen)[1]
pbBreakLow = pullbackBreakLen <= 1 ? close < low[1] : close < ta.lowest(low, pullbackBreakLen)[1]
revBreakHigh = reversalBreakLen <= 1 ? close > high[1] : close > ta.highest(high, reversalBreakLen)[1]
revBreakLow = reversalBreakLen <= 1 ? close < low[1] : close < ta.lowest(low, reversalBreakLen)[1]

nearVWAP = math.abs(close - vwapVal) <= atr * vwapProxATR
nearEMA = math.abs(close - emaSlow) <= atr * emaProxATR or math.abs(close - emaFast) <= atr * emaProxATR
decisionZone = sessionPass and nearVWAP
longWatch = bullTrend and sessionPass and (nearEMA or decisionZone)
shortWatch = bearTrend and sessionPass and (nearEMA or decisionZone)
pbLongWatch = bullTrend and aboveVWAP and nearEMA and sessionPass
pbShortWatch = bearTrend and belowVWAP and nearEMA and sessionPass
revLongWatch = belowVWAP and emaBullFlip and sessionPass
revShortWatch = aboveVWAP and emaBearFlip and sessionPass

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRIGGER CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
triggerBreakHigh = triggerLookback <= 1 ? close > high[1] : close > ta.highest(high, triggerLookback)[1]
triggerBreakLow = triggerLookback <= 1 ? close < low[1] : close < ta.lowest(low, triggerLookback)[1]
bullRejectCandle = lowerWick >= bodySize * wickRatioTrigger and closeLocation >= 0.60 and close > open
bearRejectCandle = upperWick >= bodySize * wickRatioTrigger and closeLocation <= 0.40 and close < open
longTriggerConfirm = sessionPass and (longWatch or pbLongWatch or revLongWatch) and (bullRejectCandle or triggerBreakHigh or longTrap or bullImpulseTag)
shortTriggerConfirm = sessionPass and (shortWatch or pbShortWatch or revShortWatch) and (bearRejectCandle or triggerBreakLow or shortTrap or bearImpulseTag)
triggerConfirmed = longTriggerConfirm or shortTriggerConfirm

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INVALIDATION + RESET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullRegimeFlip = close > vwapVal and emaFast > emaSlow and close > emaFast
bearRegimeFlip = close < vwapVal and emaFast < emaSlow and close < emaFast
shortInvalidVWAP = invalidateOnVWAPFlip and bullRegimeFlip
longInvalidVWAP = invalidateOnVWAPFlip and bearRegimeFlip
shortInvalidOF = invalidateOnOFImpulse and (bullOFImpulse or bullAbsorption or longTrap)
longInvalidOF = invalidateOnOFImpulse and (bearOFImpulse or bearAbsorption or shortTrap)
bullThesisReset = bullTrend and aboveVWAP and (bullOFImpulse or triggerBreakHigh or breakHigh)
bearThesisReset = bearTrend and belowVWAP and (bearOFImpulse or triggerBreakLow or breakLow)
shortThesisInvalid = useInvalidation and (shortInvalidVWAP or shortInvalidOF) and not bearThesisReset
longThesisInvalid = useInvalidation and (longInvalidVWAP or longInvalidOF) and not bullThesisReset

// Momentum watch must come after invalidation exists.
momentumLongWatch = useMomentumState and bullTrend and aboveVWAP and sessionPass and (bullOFImpulse or breakHigh or triggerBreakHigh) and not longThesisInvalid
momentumShortWatch = useMomentumState and bearTrend and belowVWAP and sessionPass and (bearOFImpulse or breakLow or triggerBreakLow) and not shortThesisInvalid

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIRST PASS SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longVWAPPass = useVWAP ? vwapReclaim : true
shortVWAPPass = useVWAP ? vwapReject : true
pbVolPass = pullbackNeedsVolume ? highVol : true
revVolPass = reversalNeedsVolume ? highVol : true
triggerLongPass = requireTriggerForEntries ? longTriggerConfirm : true
triggerShortPass = requireTriggerForEntries ? shortTriggerConfirm : true
ltfLongExecutionBase = useLTFExecutionMode and pbLongWatch and bullTrend and aboveVWAP and nearEMA and triggerBreakHigh and not longThesisInvalid
ltfShortExecutionBase = useLTFExecutionMode and pbShortWatch and bearTrend and belowVWAP and nearEMA and triggerBreakLow and not shortThesisInvalid
rawContLong = useContinuationEngine and bullTrend and longVWAPPass and volPass and breakHigh and ofLongGate and sessionPass and triggerLongPass and not longThesisInvalid
rawContShort = useContinuationEngine and bearTrend and shortVWAPPass and volPass and breakLow and ofShortGate and sessionPass and triggerShortPass and not shortThesisInvalid
rawPBLongBase = usePullbackEngine and ((bullTrend and aboveVWAP and nearEMA and pbBreakHigh and pbVolPass and ofLongGate and sessionPass and triggerLongPass and not longThesisInvalid) or ltfLongExecutionBase)
rawPBShortBase = usePullbackEngine and ((bearTrend and belowVWAP and nearEMA and pbBreakLow and pbVolPass and ofShortGate and sessionPass and triggerShortPass and not shortThesisInvalid) or ltfShortExecutionBase)
rawRevLong = useReversalEngine and belowVWAP and vwapReclaim and emaBullFlip and revBreakHigh and revVolPass and ofLongGate and sessionPass and triggerLongPass and not longThesisInvalid
rawRevShort = useReversalEngine and aboveVWAP and vwapReject and emaBearFlip and revBreakLow and revVolPass and ofShortGate and sessionPass and triggerShortPass and not shortThesisInvalid
preLong = rawContLong or rawPBLongBase or rawRevLong or longTriggerConfirm or longWatch or pbLongWatch or revLongWatch or momentumLongWatch
preShort = rawContShort or rawPBShortBase or rawRevShort or shortTriggerConfirm or shortWatch or pbShortWatch or revShortWatch or momentumShortWatch

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullModifierScore = (longTrap ? trapBoost : 0) + (bullImpulseTag ? impulseBoost : 0)
bearModifierScore = (shortTrap ? trapBoost : 0) + (bearImpulseTag ? impulseBoost : 0)
ofBullScore = useOrderFlow ? (bullOFImpulse ? 15 : bullAbsorption ? 12 : bullExhaustion ? -8 : 0) + bullModifierScore : 0
ofBearScore = useOrderFlow ? (bearOFImpulse ? 15 : bearAbsorption ? 12 : bearExhaustion ? -8 : 0) + bearModifierScore : 0

bullScore = 0
bullScore += bullTrend ? 25 : 0
bullScore += aboveVWAP ? 20 : 0
bullScore += highVol ? 15 : 0
bullScore += breakHigh ? 15 : 0
bullScore += nearEMA ? 10 : 0
bullScore += sessionPass ? 10 : 0
bullScore += ofBullScore
bearScore = 0
bearScore += bearTrend ? 25 : 0
bearScore += belowVWAP ? 20 : 0
bearScore += highVol ? 15 : 0
bearScore += breakLow ? 15 : 0
bearScore += nearEMA ? 10 : 0
bearScore += sessionPass ? 10 : 0
bearScore += ofBearScore
pbBullScore = 0
pbBullScore += bullTrend ? 25 : 0
pbBullScore += aboveVWAP ? 20 : 0
pbBullScore += nearEMA ? 20 : 0
pbBullScore += pbBreakHigh ? 20 : 0
pbBullScore += pbVolPass ? 10 : 0
pbBullScore += ofBullScore
pbBearScore = 0
pbBearScore += bearTrend ? 25 : 0
pbBearScore += belowVWAP ? 20 : 0
pbBearScore += nearEMA ? 20 : 0
pbBearScore += pbBreakLow ? 20 : 0
pbBearScore += pbVolPass ? 10 : 0
pbBearScore += ofBearScore
revBullScore = 0
revBullScore += belowVWAP ? 20 : 0
revBullScore += vwapReclaim ? 25 : 0
revBullScore += emaBullFlip ? 20 : 0
revBullScore += revBreakHigh ? 20 : 0
revBullScore += revVolPass ? 10 : 0
revBullScore += ofBullScore
revBearScore = 0
revBearScore += aboveVWAP ? 20 : 0
revBearScore += vwapReject ? 25 : 0
revBearScore += emaBearFlip ? 20 : 0
revBearScore += revBreakLow ? 20 : 0
revBearScore += revVolPass ? 10 : 0
revBearScore += ofBearScore

rawConfidence = math.max(math.max(bullScore, bearScore), math.max(math.max(pbBullScore, pbBearScore), math.max(revBullScore, revBearScore)))
longContextActive = preLong or bullScore > bearScore
shortContextActive = preShort or bearScore > bullScore
trendConflictLong = longContextActive and bearTrend
trendConflictShort = shortContextActive and bullTrend
locationConflictLong = longContextActive and belowVWAP
locationConflictShort = shortContextActive and aboveVWAP
orderFlowConflictLong = longContextActive and (bearOFImpulse or bearAbsorption or shortTrap or bearImpulseTag)
orderFlowConflictShort = shortContextActive and (bullOFImpulse or bullAbsorption or longTrap or bullImpulseTag)
noModifierPenalty = modifierText == "None" ? 5 : 0
noTriggerPenalty = requireTriggerForEntries and not triggerConfirmed ? 8 : 0
conflictPenalty = 0
conflictPenalty += trendConflictLong or trendConflictShort ? 15 : 0
conflictPenalty += locationConflictLong or locationConflictShort ? 10 : 0
conflictPenalty += orderFlowConflictLong or orderFlowConflictShort ? 15 : 0
conflictPenalty += noModifierPenalty
conflictPenalty += noTriggerPenalty
biasConfidence = math.max(0, math.min(100, rawConfidence))
entryConfidence = math.max(0, math.min(100, rawConfidence - conflictPenalty))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ltfLongExecution = ltfLongExecutionBase and entryConfidence >= ltfEntryMinScore
ltfShortExecution = ltfShortExecutionBase and entryConfidence >= ltfEntryMinScore
pbLong = rawPBLongBase and (not ltfLongExecutionBase or entryConfidence >= ltfEntryMinScore)
pbShort = rawPBShortBase and (not ltfShortExecutionBase or entryConfidence >= ltfEntryMinScore)
contLong = rawContLong
contShort = rawContShort
revLong = rawRevLong
revShort = rawRevShort
momLong = useMomentumState and momentumLongWatch and entryConfidence >= ltfEntryMinScore
momShort = useMomentumState and momentumShortWatch and entryConfidence >= ltfEntryMinScore
zenLong = contLong or pbLong or revLong or momLong
zenShort = contShort or pbShort or revShort or momShort
newSignal = zenLong or zenShort
signalType = contLong ? "A+ Long" : contShort ? "A+ Short" : pbLong and ltfLongExecution ? "LTF PB Long" : pbShort and ltfShortExecution ? "LTF PB Short" : pbLong ? "PB Long" : pbShort ? "PB Short" : revLong ? "REV Long" : revShort ? "REV Short" : momLong ? "Momentum Long" : momShort ? "Momentum Short" : "None"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GRADING + DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
strongModifier = modifierText != "None"
orderFlowAlignedLong = bullOFImpulse or bullAbsorption or longTrap or bullImpulseTag
orderFlowAlignedShort = bearOFImpulse or bearAbsorption or shortTrap or bearImpulseTag
orderFlowAligned = zenLong ? orderFlowAlignedLong : zenShort ? orderFlowAlignedShort : bullScore > bearScore ? orderFlowAlignedLong : orderFlowAlignedShort
longContextAligned = (longWatch or pbLongWatch or revLongWatch or zenLong or momentumLongWatch) and bullTrend and aboveVWAP and not longThesisInvalid
shortContextAligned = (shortWatch or pbShortWatch or revShortWatch or zenShort or momentumShortWatch) and bearTrend and belowVWAP and not shortThesisInvalid
contextAligned = longContextAligned or shortContextAligned
baseTradeGrade = entryConfidence >= 85 and strongModifier and triggerConfirmed and orderFlowAligned ? "A+" : entryConfidence >= 75 and triggerConfirmed and (strongModifier or orderFlowAligned) ? "A" : entryConfidence >= 60 and triggerConfirmed ? "B" : entryConfidence >= 45 ? "C" : "D"
tradeGrade = baseTradeGrade == "C" and biasConfidence >= 70 and entryConfidence >= 60 and contextAligned ? "B" : baseTradeGrade == "D" and biasConfidence >= 65 and entryConfidence >= 55 and contextAligned ? "C" : baseTradeGrade
tradeGradeBg = tradeGrade == "A+" ? color.new(color.green, 0) : tradeGrade == "A" ? color.new(color.green, 25) : tradeGrade == "B" ? color.new(color.orange, 20) : tradeGrade == "C" ? color.new(color.yellow, 35) : color.new(color.red, 20)
sizeSuggestion = tradeGrade == "A+" ? "Full" : tradeGrade == "A" ? "Normal" : tradeGrade == "B" and triggerConfirmed ? "Light" : tradeGrade == "B" ? "Watch" : tradeGrade == "C" ? "Tiny/Skip" : "Skip"
trendText = bullTrend ? "Bullish" : bearTrend ? "Bearish" : "Neutral"
trendBg = bullTrend ? color.new(color.green, 25) : bearTrend ? color.new(color.red, 25) : color.new(color.gray, 50)
setupText = contLong ? "A+ Long" : contShort ? "A+ Short" : pbLong and ltfLongExecution ? "LTF PB Long" : pbShort and ltfShortExecution ? "LTF PB Short" : pbLong ? "PB Long" : pbShort ? "PB Short" : revLong ? "REV Long" : revShort ? "REV Short" : momLong ? "Momentum Long" : momShort ? "Momentum Short" : pbLongWatch ? "PB Long Watch" : pbShortWatch ? "PB Short Watch" : momentumLongWatch ? "Momentum Long Watch" : momentumShortWatch ? "Momentum Short Watch" : impulseWatchLong ? "Impulse Long Watch" : impulseWatchShort ? "Impulse Short Watch" : longWatch ? "Long Watch" : shortWatch ? "Short Watch" : revLongWatch ? "REV Long Watch" : revShortWatch ? "REV Short Watch" : decisionZone ? "Decision" : "No Setup"
actionText = zenLong ? "Enter Long" : zenShort ? "Enter Short" : pbLongWatch ? "Watch PB Long" : pbShortWatch ? "Watch PB Short" : momentumLongWatch ? "Watch Momentum Long" : momentumShortWatch ? "Watch Momentum Short" : impulseWatchLong ? "Watch Impulse Long" : impulseWatchShort ? "Watch Impulse Short" : longWatch ? "Watch Long" : shortWatch ? "Watch Short" : decisionZone ? "Wait Break" : "Wait"
setupBg = zenLong ? color.new(color.green, 0) : zenShort ? color.new(color.red, 0) : pbLongWatch or longWatch or revLongWatch or momentumLongWatch or impulseWatchLong ? color.new(color.green, 45) : pbShortWatch or shortWatch or revShortWatch or momentumShortWatch or impulseWatchShort ? color.new(color.red, 45) : decisionZone ? color.new(color.yellow, 35) : color.new(color.gray, 55)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RISK + TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longEntry = close
longStop = math.min(low, close - atr * autoATRMult)
longRisk = longEntry - longStop
longTP1 = longEntry + longRisk * rr1
longTP2 = longEntry + longRisk * rr2
longTP3 = longEntry + longRisk * rr3
shortEntry = close
shortStop = math.max(high, close + atr * autoATRMult)
shortRisk = shortStop - shortEntry
shortTP1 = shortEntry - shortRisk * rr1
shortTP2 = shortEntry - shortRisk * rr2
shortTP3 = shortEntry - shortRisk * rr3

var bool inTrade = false
var int tradeDir = 0
var float activeEntry = na
var float activeStop = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var string tradeStatus = "No Active Trade"
var int totalTrades = 0
var int wins = 0
var int losses = 0
var float totalR = 0.0

if newSignal and not inTrade
    inTrade := true
    tradeDir := zenLong ? 1 : -1
    activeEntry := zenLong ? longEntry : shortEntry
    activeStop := zenLong ? longStop : shortStop
    activeTP1 := zenLong ? longTP1 : shortTP1
    activeTP2 := zenLong ? longTP2 : shortTP2
    activeTP3 := zenLong ? longTP3 : shortTP3
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tradeStatus := signalType
    totalTrades += 1

if inTrade and tradeDir == 1
    if not tp1Hit and high >= activeTP1
        tp1Hit := true
        tradeStatus := "TP1 Hit"
    if not tp2Hit and high >= activeTP2
        tp2Hit := true
        tradeStatus := "TP2 Hit"
    if showTP3 and not tp3Hit and high >= activeTP3
        tp3Hit := true
        tradeStatus := "TP3 Hit"
    if low <= activeStop
        wins += tp1Hit ? 1 : 0
        losses += tp1Hit ? 0 : 1
        totalR += tp3Hit ? rr3 : tp2Hit ? rr2 : tp1Hit ? rr1 : -1
        tradeStatus := tp3Hit ? "Closed TP3" : tp2Hit ? "Closed TP2" : tp1Hit ? "Closed TP1" : "Stopped"
        inTrade := false

if inTrade and tradeDir == -1
    if not tp1Hit and low <= activeTP1
        tp1Hit := true
        tradeStatus := "TP1 Hit"
    if not tp2Hit and low <= activeTP2
        tp2Hit := true
        tradeStatus := "TP2 Hit"
    if showTP3 and not tp3Hit and low <= activeTP3
        tp3Hit := true
        tradeStatus := "TP3 Hit"
    if high >= activeStop
        wins += tp1Hit ? 1 : 0
        losses += tp1Hit ? 0 : 1
        totalR += tp3Hit ? rr3 : tp2Hit ? rr2 : tp1Hit ? rr1 : -1
        tradeStatus := tp3Hit ? "Closed TP3" : tp2Hit ? "Closed TP2" : tp1Hit ? "Closed TP1" : "Stopped"
        inTrade := false

if inTrade and useInvalidation
    if tradeDir == 1 and longThesisInvalid
        tradeStatus := "Long Invalidated"
        inTrade := false
        tradeDir := 0
        activeEntry := na
        activeStop := na
        activeTP1 := na
        activeTP2 := na
        activeTP3 := na
    if tradeDir == -1 and shortThesisInvalid
        tradeStatus := "Short Invalidated"
        inTrade := false
        tradeDir := 0
        activeEntry := na
        activeStop := na
        activeTP1 := na
        activeTP2 := na
        activeTP3 := na

if not inTrade and (bullThesisReset or bearThesisReset) and (tradeStatus == "Long Invalidated" or tradeStatus == "Short Invalidated")
    tradeStatus := "No Active Trade"
    tradeDir := 0
    activeEntry := na
    activeStop := na
    activeTP1 := na
    activeTP2 := na
    activeTP3 := na

winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : na
avgR = totalTrades > 0 ? totalR / totalTrades : na
riskPts = inTrade ? math.abs(activeEntry - activeStop) : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(emaFast, "EMA Fast", color=color.new(color.yellow, 0), linewidth=2, display=display.all - display.price_scale)
plot(emaSlow, "EMA Slow", color=color.new(color.orange, 0), linewidth=2, display=display.all - display.price_scale)
plot(vwapVal, "VWAP", color=color.new(color.white, 0), linewidth=2, display=display.all - display.price_scale)
bgcolor(showDecisionBg and decisionZone ? color.new(color.yellow, 93) : na)
bgcolor(showPBHighlight and (pbLong or pbShort) ? color.new(pbLong ? color.lime : color.red, 88) : na)

plotshape(visualMode == "Full" and showSignals and contLong, title="A+ Long", style=shape.labelup, text="A+ LONG", location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showSignals and contShort, title="A+ Short", style=shape.labeldown, text="A+ SHORT", location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showSignals and pbLong, title="PB Long", style=shape.labelup, text="PB LONG", location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
plotshape(visualMode == "Full" and showSignals and pbShort, title="PB Short", style=shape.labeldown, text="PB SHORT", location=location.abovebar, color=color.new(color.maroon, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showSignals and revLong, title="REV Long", style=shape.labelup, text="REV LONG", location=location.belowbar, color=color.new(color.teal, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showSignals and revShort, title="REV Short", style=shape.labeldown, text="REV SHORT", location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showTriggerMarks and longTriggerConfirm, title="Long Trigger", style=shape.labelup, text="TRIG+", location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showTriggerMarks and shortTriggerConfirm, title="Short Trigger", style=shape.labeldown, text="TRIG-", location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
plotshape(visualMode == "Full" and showOFMarks and bullAbsorption, title="Bull Absorption", style=shape.triangleup, text="ABS", location=location.belowbar, color=color.new(color.teal, 0), textcolor=color.white, size=size.tiny)
plotshape(visualMode == "Full" and showOFMarks and bearAbsorption, title="Bear Absorption", style=shape.triangledown, text="ABS", location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLbl = na
var label stopLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na

// Clear old execution drawings once a trade is no longer active.
if showLevels and not inTrade and (tradeStatus == "Stopped" or tradeStatus == "Closed TP1" or tradeStatus == "Closed TP2" or tradeStatus == "Closed TP3" or tradeStatus == "Long Invalidated" or tradeStatus == "Short Invalidated")
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(entryLbl)
    label.delete(stopLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    entryLine := na
    stopLine := na
    tp1Line := na
    tp2Line := na
    tp3Line := na
    entryLbl := na
    stopLbl := na
    tp1Lbl := na
    tp2Lbl := na
    tp3Lbl := na

if showLevels and newSignal
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(entryLbl)
    label.delete(stopLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    entryPrice = zenLong ? longEntry : shortEntry
    stopPrice = zenLong ? longStop : shortStop
    tp1Price = zenLong ? longTP1 : shortTP1
    tp2Price = zenLong ? longTP2 : shortTP2
    tp3Price = zenLong ? longTP3 : shortTP3
    lineEnd = bar_index + 8
    labelX = lineEnd + 1
    entryLine := line.new(bar_index, entryPrice, lineEnd, entryPrice, color=color.white, width=2)
    stopLine := line.new(bar_index, stopPrice, lineEnd, stopPrice, color=color.red, width=2)
    tp1Line := line.new(bar_index, tp1Price, lineEnd, tp1Price, color=color.green, width=1)
    tp2Line := line.new(bar_index, tp2Price, lineEnd, tp2Price, color=color.green, width=1)
    if showTP3
        tp3Line := line.new(bar_index, tp3Price, lineEnd, tp3Price, color=color.new(color.green, 40), width=1)
    entryLbl := label.new(labelX, entryPrice, "E", style=label.style_label_left, size=size.tiny, color=color.white, textcolor=color.black)
    stopLbl := label.new(labelX, stopPrice, "SL", style=label.style_label_left, size=size.tiny, color=color.red, textcolor=color.white)
    tp1Lbl := label.new(labelX, tp1Price, "T1", style=label.style_label_left, size=size.tiny, color=color.green, textcolor=color.white)
    tp2Lbl := label.new(labelX, tp2Price, "T2", style=label.style_label_left, size=size.tiny, color=color.green, textcolor=color.white)
    if showTP3
        tp3Lbl := label.new(labelX, tp3Price, "T3", style=label.style_label_left, size=size.tiny, color=color.new(color.green, 35), textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table mainDash = table.new(position.top_right, 2, 6, border_width=1)
var table ofDash = table.new(position.bottom_left, 2, 4, border_width=1)
var table tradeDash = table.new(position.bottom_right, 2, 5, border_width=1)
var table centerDash = table.new(position.bottom_center, 3, 8, border_width=1)

if barstate.islast
    if showMainDash
        table.cell(mainDash, 0, 0, "ZenFlow", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
        table.cell(mainDash, 1, 0, syminfo.ticker, text_color=color.aqua, bgcolor=color.new(color.black, 0), text_size=size.small)
        table.cell(mainDash, 0, 1, "Trend", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
        table.cell(mainDash, 1, 1, trendText, text_color=color.white, bgcolor=trendBg, text_size=size.small)
        table.cell(mainDash, 0, 2, "Setup", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
        table.cell(mainDash, 1, 2, setupText, text_color=color.white, bgcolor=setupBg, text_size=size.small)
        table.cell(mainDash, 0, 3, "Action", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
        table.cell(mainDash, 1, 3, actionText, text_color=color.white, bgcolor=setupBg, text_size=size.small)
        table.cell(mainDash, 0, 4, "Entry %", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
        table.cell(mainDash, 1, 4, str.tostring(entryConfidence) + "%", text_color=color.white, bgcolor=entryConfidence >= 70 ? color.new(color.green, 25) : entryConfidence >= 50 ? color.new(color.orange, 25) : color.new(color.red, 25), text_size=size.small)
        table.cell(mainDash, 0, 5, "Grade", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
        table.cell(mainDash, 1, 5, tradeGrade + " / " + sizeSuggestion, text_color=color.white, bgcolor=tradeGradeBg, text_size=size.small)

    if showOrderFlowMini
        table.cell(ofDash, 0, 0, "OF", text_color=color.aqua, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(ofDash, 1, 0, ofText, text_color=color.white, bgcolor=ofBg, text_size=size.tiny)
        table.cell(ofDash, 0, 1, "Δ", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(ofDash, 1, 1, str.tostring(deltaStrength, "#.##"), text_color=color.white, bgcolor=deltaStrength >= 0 ? color.new(color.green, 45) : color.new(color.red, 45), text_size=size.tiny)
        table.cell(ofDash, 0, 2, "CL", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(ofDash, 1, 2, str.tostring(closeLocation * 100, "#.0") + "%", text_color=color.white, bgcolor=closeLocation >= 0.60 ? color.new(color.green, 45) : closeLocation <= 0.40 ? color.new(color.red, 45) : color.new(color.gray, 55), text_size=size.tiny)
        table.cell(ofDash, 0, 3, "CVD", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(ofDash, 1, 3, cumDeltaProxy >= cumDeltaSignal ? "Rising" : "Falling", text_color=color.white, bgcolor=cumDeltaProxy >= cumDeltaSignal ? color.new(color.green, 45) : color.new(color.red, 45), text_size=size.tiny)

    if showActiveTradeMini and inTrade
        table.cell(tradeDash, 0, 0, "Trade", text_color=color.red, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(tradeDash, 1, 0, tradeStatus, text_color=color.white, bgcolor=inTrade ? color.new(color.blue, 35) : color.new(color.gray, 55), text_size=size.tiny)
        table.cell(tradeDash, 0, 1, "Entry", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(tradeDash, 1, 1, na(activeEntry) ? "-" : str.tostring(activeEntry, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(tradeDash, 0, 2, "Stop", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(tradeDash, 1, 2, na(activeStop) ? "-" : str.tostring(activeStop, format.mintick), text_color=color.white, bgcolor=color.new(color.red, 45), text_size=size.tiny)
        table.cell(tradeDash, 0, 3, "Dir", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(tradeDash, 1, 3, tradeDir == 1 ? "Long" : tradeDir == -1 ? "Short" : "None", text_color=color.white, bgcolor=tradeDir == 1 ? color.new(color.green, 45) : tradeDir == -1 ? color.new(color.red, 45) : color.new(color.gray, 55), text_size=size.tiny)
        table.cell(tradeDash, 0, 4, "R", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(tradeDash, 1, 4, na(riskPts) ? "-" : str.tostring(riskPts, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)

    if showCenterPanel
        table.cell(centerDash, 0, 0, "Targets", text_color=color.aqua, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 1, 0, "Px", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 2, 0, "St", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 0, 1, "T1", text_color=color.green, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(centerDash, 1, 1, na(activeTP1) ? "-" : str.tostring(activeTP1, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 2, 1, tp1Hit ? "✓" : "…", text_color=color.white, bgcolor=tp1Hit ? color.new(color.green, 35) : color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 0, 2, "T2", text_color=color.green, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(centerDash, 1, 2, na(activeTP2) ? "-" : str.tostring(activeTP2, format.mintick), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 2, 2, tp2Hit ? "✓" : "…", text_color=color.white, bgcolor=tp2Hit ? color.new(color.green, 35) : color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 0, 3, "Conf", text_color=color.orange, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(centerDash, 1, 3, str.tostring(entryConfidence) + "%", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 2, 3, tradeGrade, text_color=color.white, bgcolor=tradeGradeBg, text_size=size.tiny)
        table.cell(centerDash, 0, 4, "Stats", text_color=color.aqua, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 1, 4, sessionName, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 2, 4, "", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(centerDash, 0, 5, "Trades", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(centerDash, 1, 5, str.tostring(totalTrades), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 2, 5, "", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 0, 6, "Win%", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.tiny)
        table.cell(centerDash, 1, 6, na(winRate) ? "n/a" : str.tostring(winRate, "#.0") + "%", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
        table.cell(centerDash, 2, 6, str.tostring(totalR, "#.1") + "R", text_color=color.white, bgcolor=totalR >= 0 ? color.new(color.green, 45) : color.new(color.red, 45), text_size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(contLong, title="ZenFlow A+ Long", message="ZenFlow v2.3 A+ LONG continuation setup detected.")
alertcondition(contShort, title="ZenFlow A+ Short", message="ZenFlow v2.3 A+ SHORT continuation setup detected.")
alertcondition(pbLong, title="ZenFlow PB Long", message="ZenFlow v2.3 PB LONG pullback continuation setup detected.")
alertcondition(pbShort, title="ZenFlow PB Short", message="ZenFlow v2.3 PB SHORT pullback continuation setup detected.")
alertcondition(revLong, title="ZenFlow REV Long", message="ZenFlow v2.3 REV LONG reversal setup detected.")
alertcondition(revShort, title="ZenFlow REV Short", message="ZenFlow v2.3 REV SHORT reversal setup detected.")
alertcondition(momLong, title="ZenFlow Momentum Long", message="ZenFlow v2.3 MOMENTUM LONG setup detected.")
alertcondition(momShort, title="ZenFlow Momentum Short", message="ZenFlow v2.3 MOMENTUM SHORT setup detected.")
alertcondition(longTriggerConfirm, title="ZenFlow Long Trigger", message="ZenFlow v2.3 LONG trigger confirmation detected.")
alertcondition(shortTriggerConfirm, title="ZenFlow Short Trigger", message="ZenFlow v2.3 SHORT trigger confirmation detected.")
````
