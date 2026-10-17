# AlgoZ Pro Price Action

- url: https://www.tradingview.com/script/X0lykoWb-AlgoZ-Pro-Price-Action/
- type: indicator
- pine_id: PUB;ce20aef4aec14db68c0812771c0bad0a
- version: 1.0

## Description

AlgoZ Pro Price Action is a clean price action based forex indicator built to help traders identify potential Buy, Sell, and Exit areas using a combination of market structure, trend filtering, volatility logic, and dynamic trade management.

This indicator is designed around the idea that not every trade needs to have a high win rate to be useful. Instead of only looking for quick scalp targets, AlgoZ Pro Price Action is built to manage trades with a runner-style approach. The goal is to cut weak trades faster, protect trades that start moving in the right direction, and allow stronger moves to continue when momentum is present.

The default settings are best suited for 1-minute EUR/USD forex trading. Other forex pairs and timeframes may work differently and should be tested before use.

The indicator uses market structure breaks to identify possible directional shifts. When price breaks key internal support or resistance levels, the script checks multiple filters before plotting a signal. These filters are designed to reduce low-quality signals during chop, weak momentum, or overextended conditions.

AlgoZ Pro Price Action includes Buy, Sell, and Exit labels directly on the chart. Buy signals are shown in teal, Sell signals are shown in pink, and Exit signals are shown in a neutral color. The bars can also be colored based on the active signal direction so it is easier to visually track the current market bias.

One of the main parts of this indicator is the trend lock system. The trend lock helps prevent the indicator from flipping back and forth too quickly during noisy market conditions. It uses EMA trend structure, slope behavior, and confirmation bars to decide whether the market is currently favoring Buy-side or Sell-side continuation. Countertrend signals must be stronger before they are allowed through, which helps reduce random reversal signals during an active move.

The indicator also includes automatic forex pair adjustment. It detects whether the chart is a JPY pair or a non-JPY forex pair and automatically adjusts pip size calculations. This helps prevent issues where a stop or exit calculation is too tight or too wide because of the symbol’s price format. The script also includes auto volatility tuning, which uses ATR-based logic to scale stop size, runner triggers, trailing stop distance, dead-trade protection, and cooldown behavior based on the current pair’s movement.

Trade management is handled through a dynamic exit engine. Instead of using only fixed take profit levels, the indicator uses runner logic. Once a trade moves far enough in profit, the trade can enter runner mode. From there, the script can move the stop, protect profit, and trail the trade if the move continues. This allows stronger trades to breathe while still giving the indicator a way to exit when momentum fades.

AlgoZ Pro Price Action also includes dead-trade protection. If a trade has been open for a certain number of bars and has failed to make meaningful progress, the script can plot an Exit signal. This is designed to help remove weak trades that are not moving enough to justify staying in them.

The indicator includes several optional filters and controls, including EMA trend filtering, ADX strength filtering, chop filtering, candle body quality filtering, minimum EMA separation, price distance from the slow EMA, overextension protection, post-exit cooldown, and emergency protection logic.

Main features include:

• Buy, Sell, and Exit labels  
• Teal and pink AlgoZ Pro visual theme  
• Price action and market structure based signals  
• Internal support and resistance break logic  
• Optional BOS / CHoCH structure markings  
• EMA trend filtering  
• ADX trend strength filter  
• Chop and range filter  
• Candle quality filter  
• Trend lock system  
• Countertrend signal protection  
• Auto pip size detection  
• Auto adjustment for JPY and non-JPY forex pairs  
• ATR-based auto pair tuning  
• Dynamic stop logic  
• Runner-style trade management  
• Breakeven / profit lock logic  
• Trailing stop logic for stronger moves  
• Dead-trade exit protection  
• Optional bar coloring  
• Optional entry and stop lines  
• Optional status table  

Recommended default use:
1-minute EUR/USD forex chart.

Other forex pairs and timeframes may require adjustment depending on spread, volatility, session, and market conditions.

## Source Code

````pine
//@version=6
indicator("AlgoZ Pro Price Action", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100, max_bars_back=500)

//──────────────────────────────────────────────────────────────────────────────
// AlgoZ Pro Price Action
// Production publish version
// Pine Script v6
// No webhook inputs
// No alerts
// Theme: Teal + Pink
//──────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
groupMS      = "AlgoZ Pro Market Structure"
msSource     = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=groupMS)
internalLen  = input.int(5, "Internal Pivot Length", minval=2, maxval=50, group=groupMS)
swingLen     = input.int(50, "Swing Pivot Length", minval=5, maxval=250, group=groupMS)
useSwing     = input.bool(false, "Use Swing Levels For Signals", group=groupMS)
showLevels   = input.bool(false, "Show Current Support / Resistance", group=groupMS)
showBreaks   = input.bool(false, "Show BOS / CHoCH Marks", group=groupMS)
onlyChoCH    = input.bool(false, "Signals Only On CHoCH", group=groupMS)

bullColor    = input.color(#00E5C7, "Buy / Teal Color", group=groupMS)
bearColor    = input.color(#FF2FA7, "Sell / Pink Color", group=groupMS)
neutralColor = input.color(#7A7A7A, "Neutral / Flat Color", group=groupMS)

autoGroup = "AlgoZ Pro Auto Pair Adjustments"
useAutoPairTuning = input.bool(true, "Use Auto Pair Tuning", group=autoGroup)
autoAtrLookback = input.int(100, "Auto ATR Lookback", minval=20, maxval=500, group=autoGroup)
autoStopATRMult = input.float(5.0, "Auto Stop ATR Multiplier", minval=1.0, maxval=15.0, step=0.25, group=autoGroup)
autoMinStopPips = input.float(7.0, "Auto Min Stop Pips", minval=1.0, step=0.5, group=autoGroup)
autoMaxStopPips = input.float(16.0, "Auto Max Stop Pips", minval=2.0, step=0.5, group=autoGroup)
autoRoundToHalfPip = input.bool(true, "Round Auto Values To 0.5 Pip", group=autoGroup)

signalGroup  = "AlgoZ Pro Signals / Filters"
showSignals  = input.bool(true, "Show Buy / Sell Labels", group=signalGroup)
paintBars    = input.bool(true, "Paint Bars By Active Signal", group=signalGroup)
confirmClose = input.bool(true, "Confirm On Bar Close", group=signalGroup)
cooldownBars = input.int(5, "Signal Cooldown Bars", minval=0, maxval=200, group=signalGroup)
oneTradeMode = input.bool(true, "No Same-Side Repeat Until Opposite Signal / Exit", group=signalGroup)
labelDistanceATR = input.float(1.00, "Buy/Sell Label Distance ATR", minval=0.0, maxval=10.0, step=0.10, group=signalGroup)

usePostExitCooldown = input.bool(true, "Use Post-Exit Cooldown", group=signalGroup)
postExitCooldownBars = input.int(60, "Manual Post-Exit Cooldown Bars", minval=0, maxval=500, group=signalGroup)

useEmaFilter = input.bool(true, "Use EMA Trend Filter", group=signalGroup)
emaFastLen   = input.int(9, "Fast EMA", minval=1, group=signalGroup)
emaSlowLen   = input.int(21, "Slow EMA", minval=2, group=signalGroup)

useAdxFilter = input.bool(true, "Use ADX Strength Filter", group=signalGroup)
adxLen       = input.int(14, "ADX Length", minval=2, group=signalGroup)
adxSmooth    = input.int(14, "ADX Smoothing", minval=2, group=signalGroup)
adxMin       = input.float(15.0, "Minimum ADX", minval=1.0, step=0.5, group=signalGroup)

useChopFilter = input.bool(true, "Avoid Tight Chop", group=signalGroup)
chopLookback  = input.int(20, "Chop Lookback", minval=5, group=signalGroup)
minRangeAtr   = input.float(1.20, "Minimum Range In ATR", minval=0.1, step=0.1, group=signalGroup)

qualityGroup = "AlgoZ Pro Scalper Quality"
useQualityFilter = input.bool(true, "Use Candle Body Filter", group=qualityGroup)
maxSignalBodyPct = input.float(0.70, "Max Signal Body %", minval=0.10, maxval=1.00, step=0.01, group=qualityGroup)

useDirectionalCloseFilter = input.bool(false, "Require Directional Signal Candle", group=qualityGroup)
minDirectionalClosePct = input.float(0.65, "Min Directional Close %", minval=0.50, maxval=0.95, step=0.01, group=qualityGroup)

useEmaSpreadFilter = input.bool(true, "Require EMA Separation", group=qualityGroup)
minEmaSpreadATR = input.float(0.35, "Min EMA Spread In ATR", minval=0.00, maxval=5.00, step=0.01, group=qualityGroup)

useMinDistanceSlowFilter = input.bool(true, "Require Price Away From Slow EMA", group=qualityGroup)
minDistanceSlowATR = input.float(1.20, "Min Distance From Slow EMA In ATR", minval=0.00, maxval=10.00, step=0.05, group=qualityGroup)

useOverExtensionFilter = input.bool(true, "Reject Overextended From Slow EMA", group=qualityGroup)
maxDistanceSlowATR = input.float(2.40, "Max Distance From Slow EMA In ATR", minval=0.25, maxval=10.00, step=0.05, group=qualityGroup)

trendGroup = "AlgoZ Pro Trend Lock"
useTrendLock = input.bool(true, "Use Trend Lock", group=trendGroup)
trendSlopeLen = input.int(10, "Trend Slope Length", minval=1, maxval=100, group=trendGroup)
trendConfirmBars = input.int(5, "Trend Confirm Bars", minval=0, maxval=50, group=trendGroup)
counterTrendBufferATR = input.float(0.35, "Countertrend Break Buffer ATR", minval=0.0, maxval=5.0, step=0.01, group=trendGroup)
counterTrendMinBars = input.int(12, "Min Bars Before Countertrend Flip", minval=0, maxval=200, group=trendGroup)
requireFastPastSlow = input.bool(true, "Require Fast EMA Past Slow EMA", group=trendGroup)
showTrendLockBg = input.bool(false, "Show Trend Lock Background", group=trendGroup)

earlyGroup = "AlgoZ Pro Early Flip Logic"
useEarlyProfitFlip = input.bool(false, "Use Early Profit Flip", group=earlyGroup)
earlyMinProfitPips = input.float(4.0, "Min Profit Before Early Flip", minval=0.1, step=0.1, group=earlyGroup)

useFailedTradeFlip = input.bool(false, "Use Failed Trade Flip", group=earlyGroup)
failedTradeLossPips = input.float(2.0, "Failed Trade Loss Pips", minval=0.1, step=0.1, group=earlyGroup)

useEarlyFlipQualityFilter = input.bool(true, "Use Early Flip Quality Filter", group=earlyGroup)
earlyFlipBufferATR = input.float(0.10, "Early Flip EMA Buffer ATR", minval=0.0, maxval=5.0, step=0.01, group=earlyGroup)
earlyFlipMinHoldBars = input.int(12, "Early Flip Min Hold Bars", minval=0, maxval=100, group=earlyGroup)
earlyRequireSlope = input.bool(true, "Require Fast EMA Slope", group=earlyGroup)

protectGroup = "AlgoZ Pro Emergency Protection"
useEmergencyBuy = input.bool(true, "Allow Emergency Buy", group=protectGroup)
useEmergencySell = input.bool(false, "Allow Emergency Sell", group=protectGroup)
maxOpenLossPipsManual = input.float(7.0, "Manual Emergency Loss Trigger Pips", minval=0.5, step=0.5, group=protectGroup)
emergencyMinHoldBars = input.int(10, "Emergency Min Hold Bars", minval=0, maxval=200, group=protectGroup)
emergencyBufferATR = input.float(0.10, "Emergency Slow EMA Break Buffer ATR", minval=0.0, maxval=5.0, step=0.01, group=protectGroup)

exitGroup = "AlgoZ Pro Runner Exits"
useScalperExits = input.bool(true, "Use Scalper Exit Engine", group=exitGroup)

useRunnerMode = input.bool(true, "Use Runner Mode Instead Of Fixed TP", group=exitGroup)
runnerTriggerPipsManual = input.float(10.0, "Manual Runner Trigger Pips", minval=0.5, step=0.5, group=exitGroup)

stopLossPipsManual = input.float(10.0, "Manual Hard Stop Loss Pips", minval=0.5, step=0.5, group=exitGroup)
minBarsBeforeExit = input.int(1, "Minimum Bars Before Exit Can Fire", minval=0, maxval=20, group=exitGroup)

useBreakEven = input.bool(true, "Move Stop After Profit", group=exitGroup)
breakEvenTriggerPipsManual = input.float(9.0, "Manual Breakeven Trigger Pips", minval=0.5, step=0.5, group=exitGroup)
lockProfitPipsManual = input.float(0.5, "Manual Locked Profit Pips", minval=0.0, step=0.5, group=exitGroup)

useRunnerTrail = input.bool(true, "Use Runner Trailing Stop", group=exitGroup)
runnerTrailStartPipsManual = input.float(22.0, "Manual Runner Trail Start Pips", minval=1.0, step=0.5, group=exitGroup)
runnerTrailDistancePipsManual = input.float(14.0, "Manual Runner Trail Distance Pips", minval=1.0, step=0.5, group=exitGroup)

maxHoldBars = input.int(300, "Max Hold Bars", minval=1, maxval=1000, group=exitGroup)
disableTimeExitAfterRunner = input.bool(true, "Disable Time Exit After Runner Activates", group=exitGroup)

useDeadTradeExit = input.bool(true, "Use Dead Trade Exit", group=exitGroup)
deadTradeBarsManual = input.int(30, "Manual Dead Trade Bars", minval=1, maxval=300, group=exitGroup)
deadTradeMinMFEPipsManual = input.float(5.0, "Manual Dead Trade Min MFE Pips", minval=0.0, step=0.5, group=exitGroup)
deadTradeLossPipsManual = input.float(2.0, "Manual Dead Trade Loss Pips", minval=0.0, step=0.5, group=exitGroup)

ignoreOppositeSignalsWhileActive = input.bool(true, "Ignore Weak Opposite Signals While Trade Is Active", group=exitGroup)
oppositeConfirmATR = input.float(0.15, "Strong Opposite Confirm ATR", minval=0.0, maxval=3.0, step=0.01, group=exitGroup)

exitTriggerMode = input.string("Wick", "Stop Trigger Mode", options=["Wick", "Close"], group=exitGroup)
showExitLabels = input.bool(true, "Show Exit Labels", group=exitGroup)
flatAfterExit = input.bool(true, "Gray Bars After Exit Until Next Signal", group=exitGroup)

riskGroup    = "AlgoZ Pro Risk / Lines"
showTradeLines = input.bool(false, "Show Entry / Stop Lines", group=riskGroup)
useAutoPipSize = input.bool(true, "Auto Pip Size", group=riskGroup)
manualPipSize = input.float(0.0001, "Manual Pip Size", minval=0.00000001, step=0.0001, group=riskGroup)

panelGroup   = "AlgoZ Pro Table"
showTable    = input.bool(false, "Show Status Table", group=panelGroup)

//──────────────────────────────────────────────────────────────────────────────
// Helper functions
//──────────────────────────────────────────────────────────────────────────────
f_price(float x) =>
    str.tostring(x, format.mintick)

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_round_half(float x) =>
    math.round(x * 2.0) / 2.0

f_auto_round(float x) =>
    autoRoundToHalfPip ? f_round_half(x) : x

f_delete_line(line id) =>
    if not na(id)
        line.delete(id)

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)

//──────────────────────────────────────────────────────────────────────────────
// Pip size
//──────────────────────────────────────────────────────────────────────────────
bool isForex = syminfo.type == "forex"
bool isJpyPair = isForex and (syminfo.currency == "JPY" or str.contains(syminfo.ticker, "JPY"))
float autoPipValue = isForex ? (isJpyPair ? 0.01 : 0.0001) : syminfo.mintick
float pipSize = useAutoPipSize ? autoPipValue : manualPipSize

//──────────────────────────────────────────────────────────────────────────────
// Pivots and structure levels
//──────────────────────────────────────────────────────────────────────────────
int pivotLen = useSwing ? swingLen : internalLen

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var float resistance = na
var float support = na
var int resistanceBar = na
var int supportBar = na

var line resistanceLine = na
var line supportLine = na

if not na(ph)
    resistance := ph
    resistanceBar := bar_index - pivotLen
    if showLevels
        f_delete_line(resistanceLine)
        resistanceLine := line.new(resistanceBar, resistance, bar_index, resistance, extend=extend.right, color=color.new(bearColor, 0), width=2)

if not na(pl)
    support := pl
    supportBar := bar_index - pivotLen
    if showLevels
        f_delete_line(supportLine)
        supportLine := line.new(supportBar, support, bar_index, support, extend=extend.right, color=color.new(bullColor, 0), width=2)

if not showLevels
    f_delete_line(resistanceLine)
    f_delete_line(supportLine)
    resistanceLine := na
    supportLine := na

float breakUpSource = msSource == "Close" ? close : high
float breakDnSource = msSource == "Close" ? close : low

bool bullishBreak = not na(resistance) and ta.crossover(breakUpSource, resistance)
bool bearishBreak = not na(support) and ta.crossunder(breakDnSource, support)

var int structureTrend = 0

bool bullChoCH = bullishBreak and structureTrend == -1
bool bearChoCH = bearishBreak and structureTrend == 1

if bullishBreak
    structureTrend := 1

if bearishBreak
    structureTrend := -1

if showBreaks and bullishBreak
    string txt = bullChoCH ? "CHoCH" : "BOS"
    label.new(bar_index, low, txt, style=label.style_label_up, color=bullChoCH ? color.new(bullColor, 0) : color.new(bullColor, 35), textcolor=color.black, size=size.tiny)
    line.new(resistanceBar, resistance, bar_index, resistance, color=bullChoCH ? bullColor : color.new(bullColor, 40), style=line.style_dashed)

if showBreaks and bearishBreak
    string txt = bearChoCH ? "CHoCH" : "BOS"
    label.new(bar_index, high, txt, style=label.style_label_down, color=bearChoCH ? color.new(bearColor, 0) : color.new(bearColor, 35), textcolor=color.white, size=size.tiny)
    line.new(supportBar, support, bar_index, support, color=bearChoCH ? bearColor : color.new(bearColor, 40), style=line.style_dashed)

//──────────────────────────────────────────────────────────────────────────────
// Filters
//──────────────────────────────────────────────────────────────────────────────
float emaFast = ta.ema(close, emaFastLen)
float emaSlow = ta.ema(close, emaSlowLen)

int emaTrend = emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0

[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxSmooth)

float atr = ta.atr(14)
float atrPips = pipSize > 0 ? atr / pipSize : 0.0
float atrPipsSmooth = nz(ta.sma(atrPips, autoAtrLookback), atrPips)

float recentRange = ta.highest(high, chopLookback) - ta.lowest(low, chopLookback)

float candleRange = high - low
float candleBody = math.abs(close - open)
float signalBodyPct = candleRange > 0 ? candleBody / candleRange : 1.0
float closePosition = candleRange > 0 ? (close - low) / candleRange : 0.50

float emaSpreadATR = atr > 0 ? math.abs(emaFast - emaSlow) / atr : 0.0
float distanceSlowATR = atr > 0 ? math.abs(close - emaSlow) / atr : 0.0
float emaFastSlope = emaFast - emaFast[1]
float emaSlowSlope = emaSlow - emaSlow[trendSlopeLen]

bool emaLongOk = not useEmaFilter or emaTrend >= 0
bool emaShortOk = not useEmaFilter or emaTrend <= 0

bool adxOk = not useAdxFilter or adxValue >= adxMin
bool chopOk = not useChopFilter or recentRange >= atr * minRangeAtr
bool confirmedOk = not confirmClose or barstate.isconfirmed

bool bodyQualityOk = not useQualityFilter or signalBodyPct <= maxSignalBodyPct
bool emaSpreadOk = not useEmaSpreadFilter or emaSpreadATR >= minEmaSpreadATR
bool minDistanceSlowOk = not useMinDistanceSlowFilter or distanceSlowATR >= minDistanceSlowATR
bool overExtensionOk = not useOverExtensionFilter or distanceSlowATR <= maxDistanceSlowATR

bool buyCandleOk = not useDirectionalCloseFilter or close > open and closePosition >= minDirectionalClosePct
bool sellCandleOk = not useDirectionalCloseFilter or close < open and closePosition <= 1.0 - minDirectionalClosePct

bool sharedCleanupOk = bodyQualityOk and emaSpreadOk and minDistanceSlowOk and overExtensionOk
bool earlySharedCleanupOk = not useEarlyFlipQualityFilter or (bodyQualityOk and emaSpreadOk and minDistanceSlowOk and overExtensionOk)

plot(useEmaFilter ? emaFast : na, "AlgoZ Fast EMA", color=color.new(bullColor, 25), linewidth=1)
plot(useEmaFilter ? emaSlow : na, "AlgoZ Slow EMA", color=color.new(bearColor, 25), linewidth=1)

//──────────────────────────────────────────────────────────────────────────────
// Auto pair tuning values
//──────────────────────────────────────────────────────────────────────────────
float autoStopRaw = atrPipsSmooth * autoStopATRMult
float autoStop = f_auto_round(f_clamp(autoStopRaw, autoMinStopPips, autoMaxStopPips))

float effectiveStopLossPips = useAutoPairTuning ? autoStop : stopLossPipsManual
float effectiveRunnerTriggerPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 1.00, 7.0, 18.0)) : runnerTriggerPipsManual
float effectiveBreakEvenTriggerPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 0.90, 5.0, 15.0)) : breakEvenTriggerPipsManual
float effectiveLockProfitPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 0.05, 0.5, 1.5)) : lockProfitPipsManual
float effectiveRunnerTrailStartPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 2.20, 16.0, 40.0)) : runnerTrailStartPipsManual
float effectiveRunnerTrailDistancePips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 1.40, 9.0, 28.0)) : runnerTrailDistancePipsManual

float effectiveDeadTradeMinMFEPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 0.70, 4.0, 12.0)) : deadTradeMinMFEPipsManual
float effectiveDeadTradeLossPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 0.25, 1.5, 4.0)) : deadTradeLossPipsManual
float effectiveEmergencyLossPips = useAutoPairTuning ? f_auto_round(f_clamp(effectiveStopLossPips * 0.70, 5.0, 12.0)) : maxOpenLossPipsManual

int effectivePostExitCooldownBars = useAutoPairTuning ? int(math.round(f_clamp(50.0 + atrPipsSmooth * 12.0, 45.0, 120.0))) : postExitCooldownBars
int effectiveDeadTradeBars = useAutoPairTuning ? int(math.round(f_clamp(20.0 + atrPipsSmooth * 6.0, 25.0, 60.0))) : deadTradeBarsManual

//──────────────────────────────────────────────────────────────────────────────
// Trend Lock
//──────────────────────────────────────────────────────────────────────────────
bool bullRegimeRaw = close > emaSlow and emaFast > emaSlow and emaSlowSlope > 0
bool bearRegimeRaw = close < emaSlow and emaFast < emaSlow and emaSlowSlope < 0

int bullBars = nz(ta.barssince(not bullRegimeRaw), 100000)
int bearBars = nz(ta.barssince(not bearRegimeRaw), 100000)

bool bullRegime = bullRegimeRaw and bullBars >= trendConfirmBars
bool bearRegime = bearRegimeRaw and bearBars >= trendConfirmBars

var int trendLockSide = 0

if bullRegime
    trendLockSide := 1

if bearRegime
    trendLockSide := -1

bool fastPastSlowBuyOk = not requireFastPastSlow or emaFast >= emaSlow
bool fastPastSlowSellOk = not requireFastPastSlow or emaFast <= emaSlow

bool strongBullReversal = close > emaSlow + atr * counterTrendBufferATR and emaFastSlope > 0 and fastPastSlowBuyOk
bool strongBearReversal = close < emaSlow - atr * counterTrendBufferATR and emaFastSlope < 0 and fastPastSlowSellOk

bgcolor(showTrendLockBg and trendLockSide == 1 ? color.new(bullColor, 90) : showTrendLockBg and trendLockSide == -1 ? color.new(bearColor, 90) : na)

//──────────────────────────────────────────────────────────────────────────────
// Trade state
//──────────────────────────────────────────────────────────────────────────────
var int activeSide = 0
var int lastSignalBar = na
var int lastExitBar = na
var int activeEntryBar = na

var float activeEntry = na
var float activeSL = na
var float activeMFE = 0.0
var float activeMAE = 0.0
var bool runnerActive = false

float slDistance = effectiveStopLossPips * pipSize

if activeSide == 1 and not na(activeEntry)
    activeMFE := math.max(activeMFE, (high - activeEntry) / pipSize)
    activeMAE := math.min(activeMAE, (low - activeEntry) / pipSize)

if activeSide == -1 and not na(activeEntry)
    activeMFE := math.max(activeMFE, (activeEntry - low) / pipSize)
    activeMAE := math.min(activeMAE, (activeEntry - high) / pipSize)

float activePnLPips = activeSide == 1 and not na(activeEntry) ? (close - activeEntry) / pipSize : activeSide == -1 and not na(activeEntry) ? (activeEntry - close) / pipSize : 0.0
int barsInTrade = not na(activeEntryBar) ? bar_index - activeEntryBar : 0

bool runnerStartSignal = useScalperExits and useRunnerMode and activeSide != 0 and not runnerActive and activeMFE >= effectiveRunnerTriggerPips

if runnerStartSignal
    runnerActive := true

//──────────────────────────────────────────────────────────────────────────────
// Dynamic stop logic
//──────────────────────────────────────────────────────────────────────────────
float dynamicSL = activeSL

if activeSide == 1 and not na(activeEntry) and not na(activeSL)
    dynamicSL := activeSL

    if useBreakEven and activeMFE >= effectiveBreakEvenTriggerPips
        dynamicSL := math.max(dynamicSL, activeEntry + effectiveLockProfitPips * pipSize)

    if runnerActive and useRunnerTrail and activeMFE >= effectiveRunnerTrailStartPips
        float trailStopLong = activeEntry + (activeMFE - effectiveRunnerTrailDistancePips) * pipSize
        dynamicSL := math.max(dynamicSL, trailStopLong)

if activeSide == -1 and not na(activeEntry) and not na(activeSL)
    dynamicSL := activeSL

    if useBreakEven and activeMFE >= effectiveBreakEvenTriggerPips
        dynamicSL := math.min(dynamicSL, activeEntry - effectiveLockProfitPips * pipSize)

    if runnerActive and useRunnerTrail and activeMFE >= effectiveRunnerTrailStartPips
        float trailStopShort = activeEntry - (activeMFE - effectiveRunnerTrailDistancePips) * pipSize
        dynamicSL := math.min(dynamicSL, trailStopShort)

//──────────────────────────────────────────────────────────────────────────────
// Exit logic
//──────────────────────────────────────────────────────────────────────────────
bool canExitThisBar = useScalperExits and activeSide != 0 and not na(activeEntryBar) and barsInTrade >= minBarsBeforeExit

bool longSlHit = canExitThisBar and activeSide == 1 and not na(dynamicSL) and (exitTriggerMode == "Wick" ? low <= dynamicSL : close <= dynamicSL)
bool shortSlHit = canExitThisBar and activeSide == -1 and not na(dynamicSL) and (exitTriggerMode == "Wick" ? high >= dynamicSL : close >= dynamicSL)

bool deadTradeHit = canExitThisBar and useDeadTradeExit and activeSide != 0 and not runnerActive and barsInTrade >= effectiveDeadTradeBars and activeMFE < effectiveDeadTradeMinMFEPips and activePnLPips <= -effectiveDeadTradeLossPips

bool timeExitAllowed = not runnerActive or not disableTimeExitAfterRunner
bool timeExitHit = canExitThisBar and activeSide != 0 and barsInTrade >= maxHoldBars and timeExitAllowed

bool slHit = confirmedOk and (longSlHit or shortSlHit)
bool deadHit = confirmedOk and deadTradeHit and not slHit
bool timeHit = confirmedOk and timeExitHit and not slHit and not deadHit

bool exitHit = slHit or deadHit or timeHit

bool exitWasLong = exitHit and activeSide == 1
bool exitWasShort = exitHit and activeSide == -1

int sideForSignalChecks = exitHit ? 0 : activeSide

bool flatEntryContext = activeSide == 0 or exitHit
int barsSinceExit = exitHit ? 0 : na(lastExitBar) ? 100000 : bar_index - lastExitBar
bool postExitCooldownOk = not usePostExitCooldown or not flatEntryContext or barsSinceExit >= effectivePostExitCooldownBars

//──────────────────────────────────────────────────────────────────────────────
// Structure signal logic
//──────────────────────────────────────────────────────────────────────────────
bool rawBuy = onlyChoCH ? bullChoCH : bullishBreak
bool rawSell = onlyChoCH ? bearChoCH : bearishBreak

bool cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
bool counterFlipBarsOk = na(lastSignalBar) or bar_index - lastSignalBar >= counterTrendMinBars

bool buyRepeatOk = not oneTradeMode or sideForSignalChecks <= 0
bool sellRepeatOk = not oneTradeMode or sideForSignalChecks >= 0

bool buyAllowedByTrend = not useTrendLock or trendLockSide != -1 or strongBullReversal and counterFlipBarsOk
bool sellAllowedByTrend = not useTrendLock or trendLockSide != 1 or strongBearReversal and counterFlipBarsOk

bool strongOppositeBuyConfirm = close > emaSlow + atr * oppositeConfirmATR and emaFastSlope > 0 and emaFast >= emaSlow
bool strongOppositeSellConfirm = close < emaSlow - atr * oppositeConfirmATR and emaFastSlope < 0 and emaFast <= emaSlow

bool blockBuyBecauseActiveSell = ignoreOppositeSignalsWhileActive and activeSide == -1 and not exitHit and not strongOppositeBuyConfirm
bool blockSellBecauseActiveBuy = ignoreOppositeSignalsWhileActive and activeSide == 1 and not exitHit and not strongOppositeSellConfirm

bool baseBuySignal = showSignals and rawBuy and postExitCooldownOk and not blockBuyBecauseActiveSell and buyAllowedByTrend and emaLongOk and adxOk and chopOk and sharedCleanupOk and buyCandleOk and confirmedOk and cooldownOk and buyRepeatOk
bool baseSellSignal = showSignals and rawSell and postExitCooldownOk and not blockSellBecauseActiveBuy and sellAllowedByTrend and emaShortOk and adxOk and chopOk and sharedCleanupOk and sellCandleOk and confirmedOk and cooldownOk and sellRepeatOk

//──────────────────────────────────────────────────────────────────────────────
// Early flip logic
//──────────────────────────────────────────────────────────────────────────────
bool earlyHoldOk = na(lastSignalBar) or bar_index - lastSignalBar >= earlyFlipMinHoldBars

bool earlyProfitOk = useEarlyProfitFlip and activeMFE >= earlyMinProfitPips
bool failedTradeOk = useFailedTradeFlip and activePnLPips <= -failedTradeLossPips

bool earlyReasonOk = earlyProfitOk or failedTradeOk

bool earlySlopeBuyOk = not earlyRequireSlope or emaFastSlope > 0
bool earlySlopeSellOk = not earlyRequireSlope or emaFastSlope < 0

bool earlyBuyTrigger = activeSide == -1 and close > emaFast + atr * earlyFlipBufferATR
bool earlySellTrigger = activeSide == 1 and close < emaFast - atr * earlyFlipBufferATR

bool earlyBuySignal = showSignals and activeSide == -1 and not exitHit and not blockBuyBecauseActiveSell and buyAllowedByTrend and earlyHoldOk and earlyReasonOk and earlySharedCleanupOk and buyCandleOk and confirmedOk and earlyBuyTrigger and earlySlopeBuyOk
bool earlySellSignal = showSignals and activeSide == 1 and not exitHit and not blockSellBecauseActiveBuy and sellAllowedByTrend and earlyHoldOk and earlyReasonOk and earlySharedCleanupOk and sellCandleOk and confirmedOk and earlySellTrigger and earlySlopeSellOk

//──────────────────────────────────────────────────────────────────────────────
// Emergency signal logic
//──────────────────────────────────────────────────────────────────────────────
bool emergencyHoldOk = na(lastSignalBar) or bar_index - lastSignalBar >= emergencyMinHoldBars
bool emergencyLossOk = activePnLPips <= -effectiveEmergencyLossPips

bool emergencyBuyBreak = close > emaSlow + atr * emergencyBufferATR and emaFast >= emaSlow and emaFastSlope > 0
bool emergencySellBreak = close < emaSlow - atr * emergencyBufferATR and emaFast <= emaSlow and emaFastSlope < 0

bool emergencyBuySignal = showSignals and useEmergencyBuy and activeSide == -1 and not exitHit and not blockBuyBecauseActiveSell and emergencyHoldOk and emergencyLossOk and confirmedOk and emergencyBuyBreak
bool emergencySellSignal = showSignals and useEmergencySell and activeSide == 1 and not exitHit and not blockSellBecauseActiveBuy and emergencyHoldOk and emergencyLossOk and confirmedOk and emergencySellBreak

bool buySignal = baseBuySignal or earlyBuySignal or emergencyBuySignal
bool sellSignal = baseSellSignal or earlySellSignal or emergencySellSignal

bool exitAction = exitHit and not buySignal and not sellSignal

//──────────────────────────────────────────────────────────────────────────────
// Entry / Exit updates
//──────────────────────────────────────────────────────────────────────────────
var line entryLine = na
var line stopLine = na

var label entryLabel = na
var label stopLabel = na

if exitHit
    lastExitBar := bar_index

    activeSide := 0
    activeEntry := na
    activeEntryBar := na
    activeSL := na
    activeMFE := 0.0
    activeMAE := 0.0
    runnerActive := false

    f_delete_line(entryLine)
    f_delete_line(stopLine)
    f_delete_label(entryLabel)
    f_delete_label(stopLabel)

    entryLine := na
    stopLine := na
    entryLabel := na
    stopLabel := na

if buySignal or sellSignal
    activeSide := buySignal ? 1 : -1
    lastSignalBar := bar_index
    activeEntryBar := bar_index

    activeEntry := close
    activeSL := buySignal ? close - slDistance : close + slDistance
    activeMFE := 0.0
    activeMAE := 0.0
    runnerActive := false

    f_delete_line(entryLine)
    f_delete_line(stopLine)
    f_delete_label(entryLabel)
    f_delete_label(stopLabel)

    if showTradeLines
        entryLine := line.new(bar_index, activeEntry, bar_index + 1, activeEntry, extend=extend.right, color=color.new(color.white, 0), style=line.style_dotted, width=1)
        stopLine := line.new(bar_index, activeSL, bar_index + 1, activeSL, extend=extend.right, color=color.new(neutralColor, 0), style=line.style_dashed, width=2)

        entryLabel := label.new(bar_index, activeEntry, "Entry " + f_price(activeEntry), style=label.style_label_left, color=color.new(color.black, 75), textcolor=color.white)
        stopLabel := label.new(bar_index, activeSL, "Stop " + f_price(activeSL), style=label.style_label_left, color=color.new(neutralColor, 75), textcolor=color.white)

if showTradeLines and not na(entryLabel)
    label.set_x(entryLabel, bar_index)
    label.set_x(stopLabel, bar_index)

    if not na(dynamicSL) and not na(stopLine)
        line.set_y1(stopLine, dynamicSL)
        line.set_y2(stopLine, dynamicSL)
        label.set_y(stopLabel, dynamicSL)
        label.set_text(stopLabel, "Stop " + f_price(dynamicSL))

if not showTradeLines
    f_delete_line(entryLine)
    f_delete_line(stopLine)
    f_delete_label(entryLabel)
    f_delete_label(stopLabel)

    entryLine := na
    stopLine := na
    entryLabel := na
    stopLabel := na

//──────────────────────────────────────────────────────────────────────────────
// Visuals
//──────────────────────────────────────────────────────────────────────────────
float buyLabelY = buySignal ? low - atr * labelDistanceATR : na
float sellLabelY = sellSignal ? high + atr * labelDistanceATR : na

float exitLabelY = exitWasLong ? high + atr * labelDistanceATR : exitWasShort ? low - atr * labelDistanceATR : na

plotshape(buySignal ? buyLabelY : na, title="Buy", text="Buy", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=color.black, size=size.small)
plotshape(sellSignal ? sellLabelY : na, title="Sell", text="Sell", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=color.white, size=size.small)

plotshape(showExitLabels and exitAction ? exitLabelY : na, title="Exit", text="Exit", style=shape.labeldown, location=location.absolute, color=color.new(neutralColor, 0), textcolor=color.white, size=size.tiny)

int visualSide = flatAfterExit and activeSide == 0 ? 0 : activeSide
color barPaint = visualSide == 1 ? color.new(bullColor, 0) : visualSide == -1 ? color.new(bearColor, 0) : color.new(neutralColor, 65)
barcolor(paintBars ? barPaint : na)

// Data-window plots only. These are not alerts.
plot(buySignal ? 1 : na, "Buy", display=display.data_window)
plot(sellSignal ? 1 : na, "Sell", display=display.data_window)
plot(exitAction ? 1 : na, "Exit", display=display.data_window)

// Hidden debug plots
plot(signalBodyPct, "Signal Body %", display=display.none)
plot(closePosition, "Close Position", display=display.none)
plot(emaSpreadATR, "EMA Spread ATR", display=display.none)
plot(distanceSlowATR, "Distance From Slow EMA ATR", display=display.none)
plot(activeMFE, "Active MFE Pips", display=display.none)
plot(activeMAE, "Active MAE Pips", display=display.none)
plot(activePnLPips, "Active PnL Pips", display=display.none)
plot(dynamicSL, "Dynamic Stop", display=display.none)
plot(trendLockSide, "Trend Lock Side", display=display.none)
plot(barsInTrade, "Bars In Trade", display=display.none)
plot(runnerActive ? 1 : 0, "Runner Active", display=display.none)
plot(barsSinceExit, "Bars Since Exit", display=display.none)
plot(deadHit ? 1 : na, "Dead Trade Exit", display=display.none)
plot(pipSize, "Auto / Active Pip Size", display=display.none)
plot(atrPipsSmooth, "ATR Pips Smooth", display=display.none)
plot(effectiveStopLossPips, "Auto Stop Pips", display=display.none)
plot(effectiveRunnerTriggerPips, "Auto Runner Trigger Pips", display=display.none)
plot(effectiveRunnerTrailDistancePips, "Auto Trail Distance Pips", display=display.none)
plot(effectivePostExitCooldownBars, "Auto Post Exit Cooldown", display=display.none)

//──────────────────────────────────────────────────────────────────────────────
// Status table
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 24, border_width=1)

if showTable and barstate.islast
    string sideTxt = activeSide == 1 ? "Buy" : activeSide == -1 ? "Sell" : "Flat"
    string structTxt = structureTrend == 1 ? "Bullish" : structureTrend == -1 ? "Bearish" : "Neutral"
    string emaTxt = emaTrend == 1 ? "Bullish" : emaTrend == -1 ? "Bearish" : "Flat"
    string lockTxt = trendLockSide == 1 ? "Buy Lock" : trendLockSide == -1 ? "Sell Lock" : "None"
    string pairTxt = isJpyPair ? "JPY Pair" : isForex ? "Forex Pair" : "Other"

    table.cell(dash, 0, 0, "AlgoZ Pro", text_color=color.white, bgcolor=color.new(bearColor, 0))
    table.cell(dash, 1, 0, sideTxt, text_color=color.black, bgcolor=activeSide == 1 ? color.new(bullColor, 0) : activeSide == -1 ? color.new(bearColor, 0) : color.new(neutralColor, 40))

    table.cell(dash, 0, 1, "Pair Type", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 1, pairTxt, text_color=color.white, bgcolor=isJpyPair ? color.new(bullColor, 65) : color.new(bearColor, 75))

    table.cell(dash, 0, 2, "Pip Size", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 2, str.tostring(pipSize), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 3, "Auto Tuning", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 3, useAutoPairTuning ? "ON" : "OFF", text_color=color.black, bgcolor=useAutoPairTuning ? color.new(bullColor, 0) : color.new(bearColor, 0))

    table.cell(dash, 0, 4, "ATR Pips", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 4, str.tostring(atrPipsSmooth, "#.1"), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 5, "Auto Stop", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 5, str.tostring(effectiveStopLossPips, "#.1") + " pips", text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 6, "Runner Trigger", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 6, str.tostring(effectiveRunnerTriggerPips, "#.1") + " pips", text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 7, "Trail Start / Dist", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 7, str.tostring(effectiveRunnerTrailStartPips, "#.1") + " / " + str.tostring(effectiveRunnerTrailDistancePips, "#.1"), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 8, "Trend Lock", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 8, lockTxt, text_color=color.white, bgcolor=trendLockSide == 1 ? color.new(bullColor, 65) : trendLockSide == -1 ? color.new(bearColor, 65) : color.new(neutralColor, 70))

    table.cell(dash, 0, 9, "Structure", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 9, structTxt, text_color=color.white, bgcolor=structureTrend == 1 ? color.new(bullColor, 65) : structureTrend == -1 ? color.new(bearColor, 65) : color.new(neutralColor, 70))

    table.cell(dash, 0, 10, "EMA Trend", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 10, emaTxt, text_color=color.white, bgcolor=emaTrend == 1 ? color.new(bullColor, 65) : emaTrend == -1 ? color.new(bearColor, 65) : color.new(neutralColor, 70))

    table.cell(dash, 0, 11, "ADX", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 11, str.tostring(adxValue, "#.##"), text_color=color.white, bgcolor=adxOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 12, "Chop", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 12, chopOk ? "OK" : "Chop", text_color=color.white, bgcolor=chopOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 13, "Body %", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 13, str.tostring(signalBodyPct * 100, "#.0") + "%", text_color=color.white, bgcolor=bodyQualityOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 14, "EMA Spread", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 14, str.tostring(emaSpreadATR, "#.00") + " ATR", text_color=color.white, bgcolor=emaSpreadOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 15, "Slow EMA Dist", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 15, str.tostring(distanceSlowATR, "#.00") + " ATR", text_color=color.white, bgcolor=minDistanceSlowOk and overExtensionOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 16, "Post-Exit Cooldown", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 16, postExitCooldownOk ? "Ready" : str.tostring(effectivePostExitCooldownBars - barsSinceExit) + " bars", text_color=color.white, bgcolor=postExitCooldownOk ? color.new(bullColor, 75) : color.new(bearColor, 75))

    table.cell(dash, 0, 17, "PnL Pips", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 17, str.tostring(activePnLPips, "#.1"), text_color=color.white, bgcolor=activePnLPips >= 0 ? color.new(bullColor, 65) : color.new(bearColor, 65))

    table.cell(dash, 0, 18, "MFE Pips", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 18, str.tostring(activeMFE, "#.1"), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 19, "MAE Pips", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 19, str.tostring(activeMAE, "#.1"), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 20, "Bars In Trade", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 20, str.tostring(barsInTrade), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 21, "Runner", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 21, runnerActive ? "Active" : "Off", text_color=color.white, bgcolor=runnerActive ? color.new(bullColor, 65) : color.new(color.black, 70))

    table.cell(dash, 0, 22, "Dynamic Stop", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 22, na(dynamicSL) ? "—" : f_price(dynamicSL), text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(dash, 0, 23, "Last Entry", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, 23, na(activeEntry) ? "—" : f_price(activeEntry), text_color=color.white, bgcolor=color.new(color.black, 70))

if not showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 23)
````
