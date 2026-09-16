<!-- tradingview-pine-id: PUB;3ee8144fc31044d4bd48690e298141d5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Opening Drive Scoreboard v4.4.2

Source: https://www.tradingview.com/script/Z1JPXTIB-Dynamic-Opening-Drive-Scoreboard-v4-4-2/

## Description

Dynamic Opening Drive Scoreboard v4.4.2

Short Description

Intraday long opening-drive dashboard using 9 EMA, VWAP, RVOL, trigger/entry logic, hybrid stop references, freshness tracking, and trade-state guidance.

Full Description

Dynamic Opening Drive Scoreboard is an intraday momentum dashboard built for traders focused on long opening-drive setups.

It is designed to help you quickly determine whether a stock is:

setting up for a long
approaching a trigger
confirming a breakout
still fresh after entry
becoming extended
showing weakness

Unlike a static trade tracker, this indicator uses a scan-first, freshness-aware framework so the board stays focused on what is relevant right now.

How the setup works

This version is built around a long opening-drive continuation setup.

Basic long criteria

price above the 9 EMA
price above VWAP
minimum setup RVOL met

When those conditions are met, the setup candle close is recorded.

Trigger

trigger is set above the setup candle close
trigger = setup close + trigger buffer

Entry confirmation

price breaks the trigger
minimum entry RVOL is met
optional increasing-volume confirmation is satisfied, if enabled

Stops The board shows two stop references:

Structure Stop = below the Low of Day
ATR Stop = a practical volatility-based reference

The structure stop represents where the setup would be invalidated. The ATR stop provides a tighter practical risk reference for planning and trade management.

How to read the board

Price / LOD
Shows current price and the Low of Day, which acts as the key structural reference for invalidation.

9 EMA
Shows whether price is above or below the 9 EMA, plus the % distance from it.

VWAP
Shows whether price is above or below VWAP, plus the % distance from it.

Setup / T-E
Shows the current setup close together with either:

Trig = breakout trigger level
Ent = confirmed entry price

Stops / Risks
Shows:

structure stop and its dollar risk
ATR stop and its dollar risk

This helps compare the true structural invalidation level with a tighter active-risk reference.

Risk Q
Rates current risk as:

Tight
Good
Acceptable
Wide

Vol Conf
Shows whether current bar volume is increasing when the volume confirmation filter is enabled.

Bar / Avg Vol
Shows current bar volume compared with average volume.

RVOL / Req
Shows:

current relative volume
minimum RVOL required for setup and entry

Range / %
Shows:

current bar range
current bar range as a percentage
whether expansion is normal, wide, or very wide

Freshness
Shows:

bars since setup
bars since entry

This helps prevent chasing stale setups or old breakouts.

State
Summarizes the current chart context in one line, including:

mode
state
suggested action
current 
𝑅
R multiple when in a trade
How to use the % distance from the 9 EMA and VWAP

The % distance from the 9 EMA and VWAP is especially useful after entry because it helps measure how stretched the move is becoming relative to its intraday support structure.

A practical way to use it:

smaller positive distances often suggest the move is still relatively orderly
expanding positive distances can show momentum building
large positive distances from both the 9 EMA and VWAP can indicate increasing extension and a need for tighter management

In practice:

if price remains above both the 9 EMA and VWAP while the move expands in a controlled way, the trend may still be healthy
if price gets far above both reference levels, the trade may be entering a more extended or emotional phase
if price starts losing one or both of those levels after being highly extended, that can be an early sign of weakening momentum

These readings are also used internally to help classify conditions such as Extended and Possible Capitulation.

Trade-state framework

Once a trade is confirmed, the board can classify it into states such as:

Fresh Entry — breakout has just triggered
Base Hit — the trade has reached the defined base-hit 
𝑅
R threshold
Runner Active — the move is still holding together after base hit
Possible Capitulation — price is very extended and may be entering a climax phase
Stalling / Weakness — structure or continuation quality is deteriorating

This allows the board to shift from finding the setup to helping manage the trade.

Optional overlay levels

The script can also plot key reference levels directly on the chart:

Trigger
Entry
Structure Stop
ATR Stop
Base-Hit Level

These overlays are intended to improve visual decision-making without changing the setup logic.

Best suited for
intraday momentum traders
opening-drive breakout traders
EMA + VWAP traders
volume-confirmation workflows
scanner follow-up
replay study and execution review
Notes
long-side version only
designed for intraday use
uses bar-based proxies such as volume, RVOL, and range
does not use Level 2, bid/ask, or spread data
intended as a decision-support tool, not financial advice

Enjoy!
Wayne

---

## Source Code

````pine
//@version=6
indicator("Dynamic Opening Drive Scoreboard v4.4.2", overlay=true, max_lines_count=500, max_labels_count=500)

// ======================================================
// INPUTS
// ======================================================
showBoard           = input.bool(true, "Show Scoreboard")
emaLength           = input.int(9, "EMA Length", minval=1)
stopBuffer          = input.float(0.03, "Structure Stop Buffer Below LOD", minval=0.0, step=0.01)
triggerBuffer       = input.float(0.01, "Trigger Buffer Above Setup Close", minval=0.0, step=0.01)
rvolLength          = input.int(20, "RVOL Length", minval=1)
highRvolThreshold   = input.float(2.0, "High RVOL Threshold", minval=0.1)

// Volume confirmation
minRvolForSetup      = input.float(1.0, "Min RVOL For Setup", minval=0.1, step=0.05)
minRvolForEntry      = input.float(1.25, "Min RVOL For Entry", minval=0.1, step=0.05)
requireIncreasingVol = input.bool(true, "Require Increasing Volume For Entry")

// Freshness / cleanup
maxBarsSetupAlive    = input.int(5, "Max Bars Setup Stays Active", minval=1)
maxBarsEntryFresh    = input.int(5, "Max Bars Entry Stays Fresh", minval=1)
clearOnStructureFail = input.bool(true, "Clear Setup/Entry On EMA+VWAP Failure")

// Extension
emaExtendedPct       = input.float(5.0, "EMA Extended %", minval=0.1)
emaExhaustionPct     = input.float(8.0, "EMA Exhaustion %", minval=0.1)
vwapExtendedPct      = input.float(5.0, "VWAP Extended %", minval=0.1)
vwapExhaustionPct    = input.float(10.0, "VWAP Exhaustion %", minval=0.1)

// Trade management
baseHitR             = input.float(2.0, "Base Hit R Threshold", minval=0.25, step=0.25)
runnerBarsMin        = input.int(1, "Runner Active Minimum Bars Since Entry", minval=1)

// Weakness tuning
weakCloseThreshold   = input.float(0.40, "Weak Close Threshold (0-1)", minval=0.0, maxval=1.0, step=0.05)
reversalGivebackPct  = input.float(50.0, "Reversal Giveback % Threshold", minval=1.0, maxval=100.0, step=1.0)

// ATR settings
atrLength            = input.int(14, "ATR Length", minval=1)
atrMult1m            = input.float(0.75, "ATR Multiplier - 1m", minval=0.1, step=0.05)
atrMult5m            = input.float(0.75, "ATR Multiplier - 5m", minval=0.1, step=0.05)
atrMultOther         = input.float(0.75, "ATR Multiplier - Other TF", minval=0.1, step=0.05)
showAtrRow           = input.bool(false, "Show ATR Row")

// Range thresholds
rangeWideThreshold        = input.float(0.25, "Range Wide Threshold", minval=0.0, step=0.01)
rangeVeryWideThreshold    = input.float(0.50, "Range Very Wide Threshold", minval=0.0, step=0.01)
rangePctWideThreshold     = input.float(2.0, "Range % Wide Threshold", minval=0.0, step=0.1)
rangePctVeryWideThreshold = input.float(5.0, "Range % Very Wide Threshold", minval=0.0, step=0.1)

boardPositionInput = input.string(
    "Top Right",
    "Scoreboard Position",
    options = [
        "Top Left", "Top Center", "Top Right",
        "Middle Left", "Middle Center", "Middle Right",
        "Bottom Left", "Bottom Center", "Bottom Right"
    ]
)

// ======================================================
// OVERLAY INPUTS
// ======================================================
overlayGroup = "Overlay Visuals"
showTriggerLine    = input.bool(true, "Show Trigger Line", group=overlayGroup)
showEntryLine      = input.bool(true, "Show Entry Line", group=overlayGroup)
showStructureLine  = input.bool(true, "Show Structure Stop Line", group=overlayGroup)
showAtrLine        = input.bool(true, "Show ATR Stop Line", group=overlayGroup)
showBaseHitLine    = input.bool(true, "Show Base-Hit Line", group=overlayGroup)
showLevelLabels    = input.bool(true, "Show Overlay Labels", group=overlayGroup)
lineExtendBars     = input.int(20, "Line Length (Bars)", minval=1, group=overlayGroup)

overlayColorGroup = "Overlay Colors"
triggerLineColor   = input.color(color.lime, "Trigger Line Color", group=overlayColorGroup)
entryLineColor     = input.color(color.green, "Entry Line Color", group=overlayColorGroup)
structureLineColor = input.color(color.red, "Structure Stop Color", group=overlayColorGroup)
atrLineColor       = input.color(color.orange, "ATR Stop Color", group=overlayColorGroup)
baseHitLineColor   = input.color(color.aqua, "Base-Hit Color", group=overlayColorGroup)

// ======================================================
// POSITION MAPPING
// ======================================================
boardPosition =
     boardPositionInput == "Top Left" ? position.top_left :
     boardPositionInput == "Top Center" ? position.top_center :
     boardPositionInput == "Top Right" ? position.top_right :
     boardPositionInput == "Middle Left" ? position.middle_left :
     boardPositionInput == "Middle Center" ? position.middle_center :
     boardPositionInput == "Middle Right" ? position.middle_right :
     boardPositionInput == "Bottom Left" ? position.bottom_left :
     boardPositionInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

// ======================================================
// HELPER FUNCTIONS
// ======================================================
formatPrice(v) =>
    na(v) ? "n/a" :
     v < 1 ? str.tostring(v, "#.####") : str.tostring(v, "#.##")

formatPct(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##") + "%"

formatVol(v) =>
    na(v) ? "n/a" :
     v >= 1000000000 ? str.tostring(v / 1000000000.0, "#.##") + "B" :
     v >= 1000000 ? str.tostring(v / 1000000.0, "#.##") + "M" :
     v >= 1000 ? str.tostring(v / 1000.0, "#.##") + "K" :
     str.tostring(v, "#")

formatDollarRisk(v) =>
    na(v) ? "n/a" :
     "$" + (v < 1 ? str.tostring(v, "#.####") : str.tostring(v, "#.##"))

// ======================================================
// CORE SERIES
// ======================================================
ema9       = ta.ema(close, emaLength)
vwapValue  = ta.vwap
avgVolume  = ta.sma(volume, rvolLength)
rvol       = not na(avgVolume) and avgVolume != 0 ? volume / avgVolume : na
atrValue   = ta.atr(atrLength)

aboveEMA   = close > ema9
aboveVWAP  = close > vwapValue
aboveBoth  = aboveEMA and aboveVWAP
belowBoth  = not aboveEMA and not aboveVWAP

emaDistPct  = ema9 != 0 ? ((close - ema9) / ema9) * 100 : na
vwapDistPct = vwapValue != 0 ? ((close - vwapValue) / vwapValue) * 100 : na
changePct   = close[1] != 0 ? ((close - close[1]) / close[1]) * 100 : na

barVolume     = volume
rangeValue    = high - low
rangePct      = close != 0 ? (rangeValue / close) * 100 : na
increasingVol = volume > volume[1]
redCloseBar   = close < open
greenBar      = close > open

// Bar close quality within range: 0 = closed at low, 1 = closed at high
closeLocation = rangeValue > 0 ? (close - low) / rangeValue : na
weakClose     = not na(closeLocation) and closeLocation <= weakCloseThreshold
strongClose   = not na(closeLocation) and closeLocation >= 0.60

// Giveback from high relative to bar range
givebackPct = rangeValue > 0 ? ((high - close) / rangeValue) * 100 : na
heavyGiveback = not na(givebackPct) and givebackPct >= reversalGivebackPct

// ======================================================
// ATR MULTIPLIER BY TIMEFRAME
// ======================================================
is1m = timeframe.period == "1"
is5m = timeframe.period == "5"

activeAtrMult =
     is1m ? atrMult1m :
     is5m ? atrMult5m :
     atrMultOther

// ======================================================
// SESSION RESET
// ======================================================
isNewDay = ta.change(time("D")) != 0

var float sessionLOD = na
var bool  setupArmed = false
var bool  entryDone = false
var float setupClose = na
var float triggerPrice = na
var float entryPrice = na
var int   setupBarIndex = na
var int   entryBarIndex = na

if isNewDay
    sessionLOD := low
    setupArmed := false
    entryDone := false
    setupClose := na
    triggerPrice := na
    entryPrice := na
    setupBarIndex := na
    entryBarIndex := na
else
    sessionLOD := na(sessionLOD) ? low : math.min(sessionLOD, low)

// ======================================================
// CONDITIONS
// ======================================================
setupVolumeOK = not na(rvol) and rvol >= minRvolForSetup
entryRvolOK   = not na(rvol) and rvol >= minRvolForEntry
entryVolOK    = requireIncreasingVol ? increasingVol : true

setupCondition = not setupArmed and not entryDone and aboveBoth and setupVolumeOK
entryCondition = setupArmed and not entryDone and high >= triggerPrice and aboveBoth and entryRvolOK and entryVolOK

structureFailed = clearOnStructureFail and belowBoth

// ======================================================
// ARM SETUP
// ======================================================
if setupCondition
    setupArmed := true
    setupClose := close
    triggerPrice := setupClose + triggerBuffer
    setupBarIndex := bar_index
    entryDone := false
    entryPrice := na
    entryBarIndex := na

// ======================================================
// CONFIRM ENTRY
// ======================================================
if entryCondition and not na(setupBarIndex) and bar_index > setupBarIndex
    entryDone := true
    entryPrice := triggerPrice
    entryBarIndex := bar_index

// ======================================================
// FRESHNESS CALCULATION
// ======================================================
barsSinceSetup = not na(setupBarIndex) ? bar_index - setupBarIndex : na
barsSinceEntry = not na(entryBarIndex) ? bar_index - entryBarIndex : na

setupExpired = setupArmed and not entryDone and not na(barsSinceSetup) and barsSinceSetup > maxBarsSetupAlive
entryNoLongerFresh = entryDone and not na(barsSinceEntry) and barsSinceEntry > maxBarsEntryFresh

// ======================================================
// CLEAR STALE / FAILED STATE
// ======================================================
if setupExpired
    setupArmed := false
    setupClose := na
    triggerPrice := na
    setupBarIndex := na

if structureFailed
    setupArmed := false
    entryDone := false
    setupClose := na
    triggerPrice := na
    entryPrice := na
    setupBarIndex := na
    entryBarIndex := na

lateMove = entryDone and entryNoLongerFresh
if lateMove
    entryDone := false
    setupArmed := false
    setupClose := na
    triggerPrice := na
    entryPrice := na
    setupBarIndex := na
    entryBarIndex := na

// ======================================================
// HYBRID STOPS
// ======================================================
structureStop = sessionLOD - stopBuffer
tradeRefPrice = entryDone ? entryPrice : triggerPrice
atrStop = not na(tradeRefPrice) ? tradeRefPrice - (atrValue * activeAtrMult) : na

structureRisk = not na(tradeRefPrice) ? tradeRefPrice - structureStop : na
atrRisk       = not na(tradeRefPrice) and not na(atrStop) ? tradeRefPrice - atrStop : na

riskQuality =
     na(structureRisk) or na(atrRisk) ? "n/a" :
     structureRisk <= 0.20 and atrRisk <= 0.20 ? "Tight" :
     structureRisk <= 0.40 and atrRisk <= 0.40 ? "Good" :
     structureRisk <= 0.60 or atrRisk <= 0.40 ? "Acceptable" :
     "Wide"

// ======================================================
// R MULTIPLE
// ======================================================
activeRisk = not na(atrRisk) ? atrRisk : structureRisk
openProfitPerShare = entryDone ? close - entryPrice : na
currentR = entryDone and not na(activeRisk) and activeRisk > 0 ? openProfitPerShare / activeRisk : na

baseHitReached = entryDone and not na(currentR) and currentR >= baseHitR
runnerActive   = entryDone and baseHitReached and aboveBoth and not na(barsSinceEntry) and barsSinceEntry >= runnerBarsMin
baseHitLevel   = entryDone and not na(activeRisk) ? entryPrice + (baseHitR * activeRisk) : na

// ======================================================
// MOMENTUM SCORE
// ======================================================
momentumScore = 0
highRvol      = not na(rvol) and rvol >= highRvolThreshold
strongBar     = not na(changePct) and changePct > 1.0

if aboveEMA
    momentumScore += 1
if aboveVWAP
    momentumScore += 1
if highRvol
    momentumScore += 1
if greenBar
    momentumScore += 1
if strongBar
    momentumScore += 1

momentumLabel =
     momentumScore >= 4 ? "Strong" :
     momentumScore == 3 ? "Good" :
     momentumScore == 2 ? "Building" :
     momentumScore == 1 ? "Weak" :
     "Flat"

// ======================================================
// EXTENSION / CAPITULATION CONTEXT
// ======================================================
emaExtended   = not na(emaDistPct) and emaDistPct >= emaExtendedPct
emaExhausted  = not na(emaDistPct) and emaDistPct >= emaExhaustionPct
vwapExtended  = not na(vwapDistPct) and vwapDistPct >= vwapExtendedPct
vwapExhausted = not na(vwapDistPct) and vwapDistPct >= vwapExhaustionPct

extensionState =
     emaExhausted and vwapExhausted ? "Capitulation Risk" :
     emaExtended or vwapExtended ? "Extended" :
     "Normal"

isExtendedNow = extensionState == "Extended" or extensionState == "Capitulation Risk"

// ======================================================
// RANGE STATES
// ======================================================
rangeState =
     rangeValue >= rangeVeryWideThreshold ? "Very Wide" :
     rangeValue >= rangeWideThreshold ? "Wide" :
     "Normal"

rangePctState =
     not na(rangePct) and rangePct >= rangePctVeryWideThreshold ? "Very Wide" :
     not na(rangePct) and rangePct >= rangePctWideThreshold ? "Wide" :
     "Normal"

// ======================================================
// SCAN-FIRST STATE ENGINE
// ======================================================
scanState =
     belowBoth and not setupArmed and not entryDone ? "No Setup" :
     aboveBoth and not setupArmed and not entryDone and setupVolumeOK ? "Setup Forming" :
     setupArmed and not entryDone ? "Trigger Armed" :
     aboveBoth and not setupArmed and not entryDone and isExtendedNow ? "Late / Extended" :
     "Monitor"

scanAction =
     belowBoth and not setupArmed and not entryDone ? "NO LONG" :
     aboveBoth and not setupArmed and not entryDone and setupVolumeOK ? "WATCH" :
     setupArmed and not entryDone ? "WATCH BREAK" :
     aboveBoth and not setupArmed and not entryDone and isExtendedNow ? "WAIT RESET" :
     "SCAN"

// ======================================================
// TRADE STATE ENGINE
// ======================================================
lostOneMajorLevel = (aboveEMA and not aboveVWAP) or (aboveVWAP and not aboveEMA)

failedContinuation =
     entryDone and not na(barsSinceEntry) and barsSinceEntry >= 1 and (
     (redCloseBar and weakClose and lostOneMajorLevel) or
     (redCloseBar and heavyGiveback and rangeState == "Very Wide") or
     (baseHitReached and redCloseBar and not aboveBoth) or
     (not na(currentR) and currentR < 1.0 and redCloseBar and not aboveBoth)
     )

stallingWeakness =
     entryDone and (
     belowBoth or
     failedContinuation or
     (redCloseBar and weakClose and not aboveVWAP) or
     (redCloseBar and weakClose and not aboveEMA) or
     (barsSinceEntry > 0 and not na(rvol) and rvol < 1.0 and not aboveBoth)
     )

possibleCapitulation =
     entryDone and not stallingWeakness and not na(barsSinceEntry) and barsSinceEntry >= 1 and (
     extensionState == "Capitulation Risk" or
     (rangeState == "Very Wide" and rangePctState == "Very Wide" and not na(currentR) and currentR >= baseHitR and aboveBoth) or
     (baseHitReached and strongClose and isExtendedNow and aboveBoth)
     )

freshEntryState =
     entryDone and not stallingWeakness and not possibleCapitulation and not baseHitReached and aboveBoth and barsSinceEntry == 0

baseHitState =
     entryDone and not stallingWeakness and baseHitReached and aboveBoth and barsSinceEntry == 0

runnerState =
     entryDone and not stallingWeakness and not possibleCapitulation and runnerActive

fallbackTradeState =
     entryDone and not stallingWeakness and not possibleCapitulation and not runnerState and not baseHitState and not freshEntryState

tradeState =
     stallingWeakness ? "Stalling / Weakness" :
     baseHitState ? "Base Hit" :
     possibleCapitulation ? "Possible Capitulation" :
     runnerState ? "Runner Active" :
     freshEntryState ? "Fresh Entry" :
     fallbackTradeState ? "Runner Active" :
     "n/a"

tradeAction =
     stallingWeakness ? "EXIT POSITION" :
     baseHitState ? "SH / BE / HOLD" :
     possibleCapitulation ? "SELL MORE / WATCH 1M" :
     runnerState ? "HOLD RUNNER" :
     freshEntryState ? "HOLD" :
     fallbackTradeState ? "HOLD RUNNER" :
     "n/a"

modeLabel = entryDone ? "Trade" : "Scan"

finalState  = entryDone ? tradeState : scanState
finalAction = entryDone ? tradeAction : scanAction

// ======================================================
// LABELS
// ======================================================
emaBiasLabel  = (aboveEMA ? "Above 9 EMA" : "Below 9 EMA") + " | " + formatPct(emaDistPct)
vwapBiasLabel = (aboveVWAP ? "Above VWAP" : "Below VWAP") + " | " + formatPct(vwapDistPct)

teLabel =
     not setupArmed and not entryDone ? "n/a" :
     setupArmed and not entryDone ? "Trig " + formatPrice(triggerPrice) :
     "Ent " + formatPrice(entryPrice)

stopsLabel =
     not na(tradeRefPrice) ? "S " + formatPrice(structureStop) + " | A " + formatPrice(atrStop) : "n/a"

risksLabel =
     not na(tradeRefPrice) ? "S " + formatPrice(structureRisk) + " | A " + formatPrice(atrRisk) : "n/a"

atrLabel =
     formatPrice(atrValue) + " x " + str.tostring(activeAtrMult, "#.##")

rangeLabel =
     formatPrice(rangeValue) + " | " + rangeState

rangePctLabel =
     formatPct(rangePct) + " | " + rangePctState

stateLine =
     modeLabel + " | " + finalState + " | " + finalAction + " | " + (entryDone ? str.tostring(currentR, "#.##") + "R" : "n/a")

volConfirmLabel =
     requireIncreasingVol ? (increasingVol ? "Up Vol" : "Flat/Down Vol") : "Vol Filter Off"

setupFilterLabel =
     "S:" + str.tostring(minRvolForSetup, "#.##") + " E:" + str.tostring(minRvolForEntry, "#.##")

freshnessLabel =
     "SU " + (na(barsSinceSetup) ? "n/a" : str.tostring(barsSinceSetup)) + " | EN " + (na(barsSinceEntry) ? "n/a" : str.tostring(barsSinceEntry))

stopsRisksDisplay =
     not na(tradeRefPrice) ?
     "S " + formatPrice(structureStop) + " / " + formatDollarRisk(structureRisk) + "   A " + formatPrice(atrStop) + " / " + formatDollarRisk(atrRisk) :
     "n/a"

rangeCompactState =
     rangeState == rangePctState ? rangeState : rangeState + " / " + rangePctState

rangeCompactDisplay =
     formatPrice(rangeValue) + " | " + formatPct(rangePct) + " | " + rangeCompactState

setupTeDisplay =
     (setupArmed or entryDone ? formatPrice(setupClose) : "n/a") + " | " + teLabel

rvolReqDisplay =
     (na(rvol) ? "n/a" : str.tostring(rvol, "#.##") + "x") + " | " + setupFilterLabel

// ======================================================
// COLORS
// ======================================================
headerBg = color.new(color.blue, 65)
normalBg = color.new(color.gray, 85)
greenBg  = color.new(color.green, 78)
redBg    = color.new(color.red, 78)
orangeBg = color.new(color.orange, 72)
yellowBg = color.new(color.yellow, 72)
tealBg   = color.new(color.teal, 72)

emaBg    = aboveEMA ? greenBg : redBg
vwapBg   = aboveVWAP ? greenBg : redBg
rvolBg   = highRvol ? orangeBg : normalBg

rangeBg =
     rangeState == "Very Wide" ? redBg :
     rangeState == "Wide" ? orangeBg :
     normalBg

rangePctBg =
     rangePctState == "Very Wide" ? redBg :
     rangePctState == "Wide" ? orangeBg :
     normalBg

riskQualityBg =
     riskQuality == "Tight" ? color.new(color.green, 72) :
     riskQuality == "Good" ? color.new(color.green, 78) :
     riskQuality == "Acceptable" ? color.new(color.orange, 72) :
     riskQuality == "Wide" ? color.new(color.red, 72) :
     normalBg

volFilterBg =
     requireIncreasingVol ? (increasingVol ? greenBg : orangeBg) : normalBg

stateBg =
     entryDone and finalState == "Fresh Entry" ? greenBg :
     entryDone and finalState == "Base Hit" ? color.new(color.lime, 68) :
     entryDone and finalState == "Runner Active" ? tealBg :
     entryDone and finalState == "Possible Capitulation" ? orangeBg :
     entryDone and finalState == "Stalling / Weakness" ? redBg :
     finalState == "Trigger Armed" ? tealBg :
     finalState == "Setup Forming" ? greenBg :
     finalState == "Late / Extended" ? orangeBg :
     finalState == "No Setup" ? yellowBg :
     normalBg

setupTeBg = entryDone ? greenBg : setupArmed ? tealBg : normalBg
rangeComboBg =
     rangeState == "Very Wide" or rangePctState == "Very Wide" ? redBg :
     rangeState == "Wide" or rangePctState == "Wide" ? orangeBg :
     normalBg

// ======================================================
// TABLE
// ======================================================
var table board = table.new(boardPosition, 2, 14, border_width=1)

if barstate.islast
    if showBoard
        int row = 0

        table.cell(board, 0, row, "Metric", text_color=color.white, bgcolor=headerBg)
        table.cell(board, 1, row, "Live", text_color=color.white, bgcolor=headerBg)
        row += 1

        table.cell(board, 0, row, "Price / LOD", text_color=color.white, bgcolor=normalBg)
        table.cell(board, 1, row, formatPrice(close) + " | LOD " + formatPrice(sessionLOD), text_color=color.white, bgcolor=normalBg)
        row += 1

        table.cell(board, 0, row, "9 EMA", text_color=color.white, bgcolor=emaBg)
        table.cell(board, 1, row, emaBiasLabel, text_color=color.white, bgcolor=emaBg)
        row += 1

        table.cell(board, 0, row, "VWAP", text_color=color.white, bgcolor=vwapBg)
        table.cell(board, 1, row, vwapBiasLabel, text_color=color.white, bgcolor=vwapBg)
        row += 1

        table.cell(board, 0, row, "Setup / T-E", text_color=color.white, bgcolor=setupTeBg)
        table.cell(board, 1, row, setupTeDisplay, text_color=color.white, bgcolor=setupTeBg)
        row += 1

        if showAtrRow
            table.cell(board, 0, row, "ATR", text_color=color.white, bgcolor=normalBg)
            table.cell(board, 1, row, atrLabel, text_color=color.white, bgcolor=normalBg)
            row += 1

        table.cell(board, 0, row, "Stops / Risks", text_color=color.white, bgcolor=normalBg)
        table.cell(board, 1, row, stopsRisksDisplay, text_color=color.white, bgcolor=normalBg)
        row += 1

        table.cell(board, 0, row, "Risk Q", text_color=color.white, bgcolor=riskQualityBg)
        table.cell(board, 1, row, riskQuality, text_color=color.white, bgcolor=riskQualityBg)
        row += 1

        table.cell(board, 0, row, "Vol Conf", text_color=color.white, bgcolor=volFilterBg)
        table.cell(board, 1, row, volConfirmLabel, text_color=color.white, bgcolor=volFilterBg)
        row += 1

        table.cell(board, 0, row, "Bar / Avg Vol", text_color=color.white, bgcolor=normalBg)
        table.cell(board, 1, row, formatVol(barVolume) + " / " + formatVol(avgVolume), text_color=color.white, bgcolor=normalBg)
        row += 1

        table.cell(board, 0, row, "RVOL / Req", text_color=color.white, bgcolor=rvolBg)
        table.cell(board, 1, row, rvolReqDisplay, text_color=color.white, bgcolor=rvolBg)
        row += 1

        table.cell(board, 0, row, "Range / %", text_color=color.white, bgcolor=rangeComboBg)
        table.cell(board, 1, row, rangeCompactDisplay, text_color=color.white, bgcolor=rangeComboBg)
        row += 1

        table.cell(board, 0, row, "Freshness", text_color=color.white, bgcolor=normalBg)
        table.cell(board, 1, row, freshnessLabel, text_color=color.white, bgcolor=normalBg)
        row += 1

        table.cell(board, 0, row, "State", text_color=color.white, bgcolor=stateBg)
        table.cell(board, 1, row, stateLine, text_color=color.white, bgcolor=stateBg)
    else
        table.clear(board, 0, 0, 1, 13)

// ======================================================
// OVERLAYS
// ======================================================
var line triggerLineObj = na
var line entryLineObj = na
var line structureLineObj = na
var line atrLineObj = na
var line baseHitLineObj = na

var label triggerLabelObj = na
var label entryLabelObj = na
var label structureLabelObj = na
var label atrLabelObj = na
var label baseHitLabelObj = na

deleteLine(lineObj) =>
    if not na(lineObj)
        line.delete(lineObj)

deleteLabel(labelObj) =>
    if not na(labelObj)
        label.delete(labelObj)

if barstate.islast
    deleteLine(triggerLineObj)
    deleteLine(entryLineObj)
    deleteLine(structureLineObj)
    deleteLine(atrLineObj)
    deleteLine(baseHitLineObj)

    deleteLabel(triggerLabelObj)
    deleteLabel(entryLabelObj)
    deleteLabel(structureLabelObj)
    deleteLabel(atrLabelObj)
    deleteLabel(baseHitLabelObj)

    if showTriggerLine and setupArmed and not entryDone and not na(triggerPrice)
        triggerLineObj := line.new(bar_index, triggerPrice, bar_index + lineExtendBars, triggerPrice, color=triggerLineColor, style=line.style_dotted, width=2)
        if showLevelLabels
            triggerLabelObj := label.new(bar_index + lineExtendBars, triggerPrice, "Trig " + formatPrice(triggerPrice), style=label.style_label_left, textcolor=color.white, color=triggerLineColor)

    if showEntryLine and entryDone and not na(entryPrice)
        entryLineObj := line.new(bar_index, entryPrice, bar_index + lineExtendBars, entryPrice, color=entryLineColor, style=line.style_dotted, width=2)
        if showLevelLabels
            entryLabelObj := label.new(bar_index + lineExtendBars, entryPrice, "Ent " + formatPrice(entryPrice), style=label.style_label_left, textcolor=color.white, color=entryLineColor)

    if showStructureLine and entryDone and not na(structureStop)
        structureLineObj := line.new(bar_index, structureStop, bar_index + lineExtendBars, structureStop, color=structureLineColor, style=line.style_dotted, width=2)
        if showLevelLabels
            structureLabelObj := label.new(bar_index + lineExtendBars, structureStop, "SStop " + formatPrice(structureStop), style=label.style_label_left, textcolor=color.white, color=structureLineColor)

    if showAtrLine and entryDone and not na(atrStop)
        atrLineObj := line.new(bar_index, atrStop, bar_index + lineExtendBars, atrStop, color=atrLineColor, style=line.style_dotted, width=2)
        if showLevelLabels
            atrLabelObj := label.new(bar_index + lineExtendBars, atrStop, "AStop " + formatPrice(atrStop), style=label.style_label_left, textcolor=color.white, color=atrLineColor)

    if showBaseHitLine and entryDone and not na(baseHitLevel)
        baseHitLineObj := line.new(bar_index, baseHitLevel, bar_index + lineExtendBars, baseHitLevel, color=baseHitLineColor, style=line.style_dotted, width=2)
        if showLevelLabels
            baseHitLabelObj := label.new(bar_index + lineExtendBars, baseHitLevel, "Base " + formatPrice(baseHitLevel), style=label.style_label_left, textcolor=color.black, color=baseHitLineColor)

// ======================================================
// ALERTS
// ======================================================
alertcondition(setupCondition, "Setup Armed", "Setup candle closed above 9 EMA and VWAP with minimum RVOL.")
alertcondition(entryCondition, "Entry Confirmed", "Price broke trigger with volume confirmation.")
alertcondition(entryDone and tradeState == "Base Hit", "Base Hit", "Trade has reached the base hit threshold.")
alertcondition(entryDone and tradeState == "Runner Active", "Runner Active", "Trade runner remains active above structure.")
alertcondition(entryDone and tradeState == "Possible Capitulation", "Possible Capitulation", "Trade may be entering a capitulation / squeeze phase.")
alertcondition(entryDone and tradeState == "Stalling / Weakness", "Stalling / Weakness", "Trade is stalling or weakening.")
````
