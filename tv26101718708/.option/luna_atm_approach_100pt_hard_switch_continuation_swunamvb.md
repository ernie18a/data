# Luna ATM Approach 100pt Hard Switch Continuation

- url: https://www.tradingview.com/script/swunAMvb-Luna-ATM-Approach-100pt-Hard-Switch-Continuation/
- type: indicator
- pine_id: PUB;9a4efe66f8a740f7b683a84216d47dc1
- version: 1.0

## Description

Luna ATM Approach — 100pt Hard Switch Continuation

This indicator is built around the ATM session model and is designed to identify both ATM reversal opportunities and strong continuation conditions during the Asia, AM, and PM trading sessions.

The model automatically builds the ATM High and ATM Low using fixed New York session times and then monitors price action during the corresponding execution window.

ATM SESSION WINDOWS — NEW YORK TIME

Asia ATM Range:
6:00 PM – 7:00 PM
Execution:
7:00 PM – 8:30 PM

AM ATM Range:
7:00 AM – 9:30 AM
Execution:
9:30 AM – 11:00 AM

PM ATM Range:
11:30 AM – 1:30 PM
Execution:
1:30 PM – 3:00 PM


ATM REVERSAL MODEL

The reversal model begins after price sweeps either the ATM High or ATM Low.

ATM High Sweep:
Looks for a SHORT reversal.

ATM Low Sweep:
Looks for a LONG reversal.

Rather than waiting for a limit entry or a retest of the gap, the indicator looks for the inversion of a Significant FVG.

Once a qualifying Significant FVG becomes an IFVG, the indicator enters immediately on the confirmed candle close.

Reversal sequence:

ATM Liquidity Sweep
→ Significant FVG
→ FVG Inversion / IFVG
→ Immediate Reversal Entry

There is no limit order and no additional FVG retest required.

The indicator also displays market structure shift information for additional context.

Reversal stops can be based on the sweep swing or IFVG invalidation.

The default reversal target is the opposing ATM liquidity, with an optional fixed-RR target available.


100-POINT HARD SWITCH

The most important feature of this version is the automatic reversal-to-continuation regime switch.

If price expands 100 points above the ATM High after an ATM High sweep:

ATM High + 100 Points
→ Reversal SHORT model is immediately disabled
→ Indicator permanently switches to CONTINUATION LONG mode for that ATM session.

If price expands 100 points below the ATM Low after an ATM Low sweep:

ATM Low - 100 Points
→ Reversal LONG model is immediately disabled
→ Indicator permanently switches to CONTINUATION SHORT mode for that ATM session.

Once the 100-point threshold has been reached, the indicator will no longer attempt to fade the move.


CONTINUATION MODEL

Continuation trades require evidence that the market is maintaining directional expansion.

CONTINUATION LONG:

ATM High +100 reached
→ Reversal shorts disabled
→ Wait for retracement into a bullish 1-minute OR 5-minute FVG
→ Identify the pullback swing low
→ Wait for bullish Break of Structure
→ Enter LONG immediately on the confirmed BOS close
→ Stop below the pullback swing low
→ Target 1:1 Risk-to-Reward

CONTINUATION SHORT:

ATM Low -100 reached
→ Reversal longs disabled
→ Wait for retracement into a bearish 1-minute OR 5-minute FVG
→ Identify the pullback swing high
→ Wait for bearish Break of Structure
→ Enter SHORT immediately on the confirmed BOS close
→ Stop above the pullback swing high
→ Target 1:1 Risk-to-Reward


MULTI-TIMEFRAME FVG CONTINUATION

The continuation engine can use either:

1-Minute FVG
OR
5-Minute FVG

A tap into either qualifying FVG can arm the BOS portion of the continuation model.

The indicator identifies which timeframe was used and displays the BOS level that must be broken before entry.


CHART DISPLAY

The indicator automatically displays:

ATM High / ATM Low
ATM range windows
Execution windows
Liquidity sweeps
MSS information
Significant IFVG used for reversal
100-point continuation regime switch
1m / 5m continuation FVG tap
Continuation BOS level
Entry
Stop Loss
Take Profit
Trade outcome labels

Entry, Stop Loss, and Take Profit are displayed as clean horizontal levels with compact labels to reduce chart clutter.


IMPORTANT

The 100-point threshold refers to actual index price points, not ticks.

For example:

ATM High = 20,000
Continuation Long Mode activates at 20,100.

ATM Low = 20,000
Continuation Short Mode activates at 19,900.

The continuation model is designed primarily around 1-minute execution while also scanning confirmed 5-minute FVG structure.


MODEL SUMMARY

REVERSAL:

ATM Sweep
→ Significant IFVG
→ Immediate Entry
→ Opposing ATM / Fixed RR Target

CONTINUATION:

ATM ±100 Points
→ Reversal Model OFF
→ 1m or 5m FVG Tap
→ BOS
→ Immediate Entry
→ Swing-Based Stop
→ 1:1 Target


This indicator is intended as a structured trading and educational tool. It does not guarantee profitable trades and should be used alongside proper risk management, testing, and trader discretion.

## Source Code

````pine
//@version=6
indicator(
     "Luna ATM Approach — 100pt Hard Switch Continuation",
     shorttitle="ATM Approach",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=250
     )

//=============================================================================
// MODEL
//
// REVERSAL:
//
// ATM HIGH/LOW SWEEP
// → SIGNIFICANT IFVG
// → IMMEDIATE ENTRY AT CONFIRMED CLOSE
// → NO LIMIT
// → NO RETEST
//
// HARD REGIME SWITCH:
//
// IF PRICE REACHES ATM HIGH + 100 POINTS:
// → REVERSAL SHORT MODEL IS PERMANENTLY OFF
// → CONTINUATION LONG MODE
//
// IF PRICE REACHES ATM LOW - 100 POINTS:
// → REVERSAL LONG MODEL IS PERMANENTLY OFF
// → CONTINUATION SHORT MODE
//
// CONTINUATION:
//
// +100 / -100 HARD SWITCH
// → TAP 1M OR 5M FVG
// → BOS
// → ENTER IMMEDIATELY AT BOS CLOSE
// → SL BELOW/ABOVE PULLBACK SWING
// → TP = EXACT 1:1
//=============================================================================


//=============================================================================
// 1. ATM SESSIONS
//=============================================================================

groupSessions = "1. ATM Sessions — New York Time"

enableAsia = input.bool(
     true,
     "Asia ATM",
     group=groupSessions
     )

enableAM = input.bool(
     true,
     "AM ATM",
     group=groupSessions
     )

enablePM = input.bool(
     true,
     "PM ATM",
     group=groupSessions
     )

showRangeBg = input.bool(
     true,
     "Shade ATM range windows",
     group=groupSessions
     )

showExecBg = input.bool(
     true,
     "Shade execution windows",
     group=groupSessions
     )


//=============================================================================
// 2. REVERSAL ENGINE
//=============================================================================

groupEntry = "2. Reversal Entry Engine"

pivotLen = input.int(
     2,
     "MSS pivot strength",
     minval=1,
     maxval=10,
     group=groupEntry
     )

pivotMaxAge = input.int(
     20,
     "Max MSS pivot age",
     minval=3,
     maxval=100,
     group=groupEntry
     )

fallbackLookback = input.int(
     6,
     "MSS fallback lookback",
     minval=2,
     maxval=30,
     group=groupEntry
     )

ifvgMaxAge = input.int(
     30,
     "Max Significant IFVG age",
     minval=3,
     maxval=150,
     group=groupEntry
     )

atrLength = input.int(
     14,
     "ATR Length",
     minval=1,
     group=groupEntry
     )

minFvgAtr = input.float(
     0.10,
     "Minimum Significant FVG × ATR",
     minval=0.0,
     step=0.01,
     group=groupEntry
     )

minFvgTicks = input.int(
     4,
     "Minimum Significant FVG ticks",
     minval=1,
     group=groupEntry
     )

maxStoredFvgs = input.int(
     25,
     "Maximum stored Significant FVGs",
     minval=5,
     maxval=50,
     group=groupEntry
     )

onlyFirst30 = input.bool(
     false,
     "Only reversal first 30 minutes",
     group=groupEntry
     )


//=============================================================================
// 3. REVERSAL RISK
//=============================================================================

groupRisk = "3. Reversal Risk / Target"

stopMode = input.string(
     "Sweep swing",
     "Reversal Stop",
     options=[
         "Sweep swing",
         "IFVG invalidation"
         ],
     group=groupRisk
     )

stopBufferTicks = input.int(
     1,
     "Stop Buffer — Ticks",
     minval=0,
     maxval=100,
     group=groupRisk
     )

targetMode = input.string(
     "Opposing ATM",
     "Reversal Target",
     options=[
         "Opposing ATM",
         "Fixed RR"
         ],
     group=groupRisk
     )

fixedRR = input.float(
     2.0,
     "Reversal Fixed RR",
     minval=0.25,
     maxval=20.0,
     step=0.25,
     group=groupRisk
     )


//=============================================================================
// 4. CONTINUATION ENGINE
//=============================================================================

groupContinuation = "4. 100pt FVG BOS Continuation"

enableContinuation = input.bool(
     true,
     "Enable Continuation",
     group=groupContinuation
     )

continuationDistance = input.float(
     100.0,
     "Hard Switch Distance Beyond ATM — Points",
     minval=10.0,
     step=5.0,
     group=groupContinuation,
     tooltip="At this distance the reversal model is immediately and permanently disabled for the session."
     )

enable1mFvg = input.bool(
     true,
     "Use 1m FVG",
     group=groupContinuation
     )

enable5mFvg = input.bool(
     true,
     "Use 5m FVG",
     group=groupContinuation
     )

continuationFvgMaxAge = input.int(
     60,
     "Maximum Continuation FVG Age — Minutes",
     minval=5,
     maxval=240,
     group=groupContinuation
     )

showBosLevel = input.bool(
     true,
     "Show Continuation BOS Level",
     group=groupContinuation
     )


//=============================================================================
// 5. VISUALS
//=============================================================================

groupVisuals = "5. Visuals / Alerts"

showSweepLabels = input.bool(
     true,
     "Show Sweep Labels",
     group=groupVisuals
     )

showMssLabels = input.bool(
     true,
     "Show MSS Labels",
     group=groupVisuals
     )

showSetupZones = input.bool(
     true,
     "Show Used FVG / IFVG",
     group=groupVisuals
     )

showLevelTags = input.bool(
     true,
     "Show ENTRY / SL / TP Tags",
     group=groupVisuals
     )

showContinuationLabels = input.bool(
     true,
     "Show Continuation Status",
     group=groupVisuals
     )

showOutcomeLabels = input.bool(
     true,
     "Show TP / SL Outcomes",
     group=groupVisuals
     )

enableDynamicAlerts = input.bool(
     true,
     "Enable alert()",
     group=groupVisuals
     )


//=============================================================================
// EXACT ATM WINDOWS
//=============================================================================

string TZ = "America/New_York"


bool inAsiaRange = enableAsia and not na(
     time(
         timeframe.period,
         "1800-1900",
         TZ
         )
     )

bool inAsiaExec = enableAsia and not na(
     time(
         timeframe.period,
         "1900-2030",
         TZ
         )
     )

bool inAMRange = enableAM and not na(
     time(
         timeframe.period,
         "0700-0930",
         TZ
         )
     )

bool inAMExec = enableAM and not na(
     time(
         timeframe.period,
         "0930-1100",
         TZ
         )
     )

bool inPMRange = enablePM and not na(
     time(
         timeframe.period,
         "1130-1330",
         TZ
         )
     )

bool inPMExec = enablePM and not na(
     time(
         timeframe.period,
         "1330-1500",
         TZ
         )
     )


bool newAsiaRange = (
     inAsiaRange and
     not inAsiaRange[1]
     )

bool newAMRange = (
     inAMRange and
     not inAMRange[1]
     )

bool newPMRange = (
     inPMRange and
     not inPMRange[1]
     )

bool newAsiaExec = (
     inAsiaExec and
     not inAsiaExec[1]
     )

bool newAMExec = (
     inAMExec and
     not inAMExec[1]
     )

bool newPMExec = (
     inPMExec and
     not inPMExec[1]
     )

bool inAnyExec = (
     inAsiaExec or
     inAMExec or
     inPMExec
     )

bool execEnded = (
     not inAnyExec and
     inAnyExec[1]
     )


//=============================================================================
// ATM RANGE BUILDERS
//=============================================================================

var float asiaHi = na
var float asiaLo = na
var int asiaRangeStartBar = na
var bool asiaRangeReady = false


if newAsiaRange

    asiaHi := high
    asiaLo := low

    asiaRangeStartBar := bar_index
    asiaRangeReady := true

else if inAsiaRange

    asiaHi := math.max(
         nz(
             asiaHi,
             high
             ),
         high
         )

    asiaLo := math.min(
         nz(
             asiaLo,
             low
             ),
         low
         )


var float amHi = na
var float amLo = na
var int amRangeStartBar = na
var bool amRangeReady = false


if newAMRange

    amHi := high
    amLo := low

    amRangeStartBar := bar_index
    amRangeReady := true

else if inAMRange

    amHi := math.max(
         nz(
             amHi,
             high
             ),
         high
         )

    amLo := math.min(
         nz(
             amLo,
             low
             ),
         low
         )


var float pmHi = na
var float pmLo = na
var int pmRangeStartBar = na
var bool pmRangeReady = false


if newPMRange

    pmHi := high
    pmLo := low

    pmRangeStartBar := bar_index
    pmRangeReady := true

else if inPMRange

    pmHi := math.max(
         nz(
             pmHi,
             high
             ),
         high
         )

    pmLo := math.min(
         nz(
             pmLo,
             low
             ),
         low
         )


//=============================================================================
// ATM PLOTS
//=============================================================================

plot(
     (inAsiaRange or inAsiaExec) ?
     asiaHi :
     na,
     "Asia ATM High",
     color=color.aqua,
     linewidth=2,
     style=plot.style_linebr
     )

plot(
     (inAsiaRange or inAsiaExec) ?
     asiaLo :
     na,
     "Asia ATM Low",
     color=color.aqua,
     linewidth=2,
     style=plot.style_linebr
     )

plot(
     (inAMRange or inAMExec) ?
     amHi :
     na,
     "AM ATM High",
     color=color.orange,
     linewidth=2,
     style=plot.style_linebr
     )

plot(
     (inAMRange or inAMExec) ?
     amLo :
     na,
     "AM ATM Low",
     color=color.orange,
     linewidth=2,
     style=plot.style_linebr
     )

plot(
     (inPMRange or inPMExec) ?
     pmHi :
     na,
     "PM ATM High",
     color=color.fuchsia,
     linewidth=2,
     style=plot.style_linebr
     )

plot(
     (inPMRange or inPMExec) ?
     pmLo :
     na,
     "PM ATM Low",
     color=color.fuchsia,
     linewidth=2,
     style=plot.style_linebr
     )


//=============================================================================
// BACKGROUND
//=============================================================================

color rangeBg = (
     inAsiaRange ?
     color.new(color.aqua, 92) :
     inAMRange ?
     color.new(color.orange, 92) :
     inPMRange ?
     color.new(color.fuchsia, 92) :
     na
     )

color execBg = (
     inAsiaExec ?
     color.new(color.aqua, 96) :
     inAMExec ?
     color.new(color.orange, 96) :
     inPMExec ?
     color.new(color.fuchsia, 96) :
     na
     )

bgcolor(
     showRangeBg ?
     rangeBg :
     na
     )

bgcolor(
     showExecBg ?
     execBg :
     na
     )


//=============================================================================
// MSS — INFORMATIONAL
//=============================================================================

float pHigh = ta.pivothigh(
     high,
     pivotLen,
     pivotLen
     )

float pLow = ta.pivotlow(
     low,
     pivotLen,
     pivotLen
     )


var float lastPivotHigh = na
var float lastPivotLow = na

var int lastPivotHighBar = na
var int lastPivotLowBar = na


if not na(pHigh)

    lastPivotHigh := pHigh

    lastPivotHighBar := (
         bar_index -
         pivotLen
         )


if not na(pLow)

    lastPivotLow := pLow

    lastPivotLowBar := (
         bar_index -
         pivotLen
         )


float fallbackHigh = ta.highest(
     high[1],
     fallbackLookback
     )

float fallbackLow = ta.lowest(
     low[1],
     fallbackLookback
     )


//=============================================================================
// SIGNIFICANT FVG DETECTION FOR REVERSAL
//=============================================================================

float atrValue = ta.atr(
     atrLength
     )


float minimumGap = math.max(
     minFvgTicks *
     syminfo.mintick,
     nz(
         atrValue,
         0.0
         ) *
     minFvgAtr
     )


bool bullFvgNow = (
     bar_index >= 2 and
     low >
     high[2]
     )

bool bearFvgNow = (
     bar_index >= 2 and
     high <
     low[2]
     )


float bullGapSize = (
     bullFvgNow ?
     low -
     high[2] :
     0.0
     )

float bearGapSize = (
     bearFvgNow ?
     low[2] -
     high :
     0.0
     )


bool significantBullFvg = (
     bullFvgNow and
     bullGapSize >=
     minimumGap
     )

bool significantBearFvg = (
     bearFvgNow and
     bearGapSize >=
     minimumGap
     )


//=============================================================================
// SIGNIFICANT FVG BANKS FOR REVERSAL IFVG
//=============================================================================

var bullFvgLo = array.new_float(0)
var bullFvgHi = array.new_float(0)
var bullFvgBar = array.new_int(0)
var bullFvgActive = array.new_bool(0)

var bearFvgLo = array.new_float(0)
var bearFvgHi = array.new_float(0)
var bearFvgBar = array.new_int(0)
var bearFvgActive = array.new_bool(0)


//=============================================================================
// CONTINUATION 1M FVG
//
// Designed for use on the 1-minute execution chart.
//=============================================================================

bool chartIs1m = (
     timeframe.isminutes and
     timeframe.multiplier == 1
     )


var float cont1mBullLo = na
var float cont1mBullHi = na
var int cont1mBullTime = na

var float cont1mBearLo = na
var float cont1mBearHi = na
var int cont1mBearTime = na


if (
     barstate.isconfirmed and
     chartIs1m and
     bullFvgNow
     )

    cont1mBullLo := high[2]
    cont1mBullHi := low
    cont1mBullTime := time


if (
     barstate.isconfirmed and
     chartIs1m and
     bearFvgNow
     )

    cont1mBearLo := high
    cont1mBearHi := low[2]
    cont1mBearTime := time


//=============================================================================
// CONFIRMED 5M FVG
//=============================================================================

[
     bull5Signal,
     bull5LoRaw,
     bull5HiRaw,
     bull5SourceTime,
     bear5Signal,
     bear5LoRaw,
     bear5HiRaw,
     bear5SourceTime
     ] = request.security(
         syminfo.tickerid,
         "5",
         [
             low[1] > high[3],
             high[3],
             low[1],
             time[1],
             high[1] < low[3],
             high[1],
             low[3],
             time[1]
             ],
         lookahead=barmerge.lookahead_on
         )


var float cont5mBullLo = na
var float cont5mBullHi = na
var int cont5mBullTime = na

var float cont5mBearLo = na
var float cont5mBearHi = na
var int cont5mBearTime = na


bool newBull5 = (
     bull5Signal and
     (
         na(cont5mBullTime) or
         bull5SourceTime !=
         cont5mBullTime
         )
     )


bool newBear5 = (
     bear5Signal and
     (
         na(cont5mBearTime) or
         bear5SourceTime !=
         cont5mBearTime
         )
     )


if newBull5

    cont5mBullLo := bull5LoRaw
    cont5mBullHi := bull5HiRaw
    cont5mBullTime := bull5SourceTime


if newBear5

    cont5mBearLo := bear5LoRaw
    cont5mBearHi := bear5HiRaw
    cont5mBearTime := bear5SourceTime


//=============================================================================
// INVALIDATE CONTINUATION FVGs
//=============================================================================

if (
     not na(cont1mBullLo) and
     close <
     cont1mBullLo
     )

    cont1mBullLo := na
    cont1mBullHi := na
    cont1mBullTime := na


if (
     not na(cont1mBearHi) and
     close >
     cont1mBearHi
     )

    cont1mBearLo := na
    cont1mBearHi := na
    cont1mBearTime := na


if (
     not na(cont5mBullLo) and
     close <
     cont5mBullLo
     )

    cont5mBullLo := na
    cont5mBullHi := na
    cont5mBullTime := na


if (
     not na(cont5mBearHi) and
     close >
     cont5mBearHi
     )

    cont5mBearLo := na
    cont5mBearHi := na
    cont5mBearTime := na


//=============================================================================
// PHASES
//
// 0 = WAIT ATM SWEEP
//
// 1 = REVERSAL SIGNIFICANT IFVG WATCH
//
// 2 = REVERSAL TRADE ACTIVE
//
// 3 = REVERSAL STOPPED, BUT 100PTS NOT YET REACHED
//
// 4 = HARD SWITCH ACTIVE → WAIT 1M/5M FVG TAP
//
// 5 = FVG TAPPED → WAIT BOS
//
// 6 = CONTINUATION TRADE ACTIVE
//
// 7 = SESSION DONE
//=============================================================================

var int phase = 7


//=============================================================================
// ATM STATE
//=============================================================================

var float atmHi = na
var float atmLo = na

var int engineRangeStartBar = na

var string sessionName = ""

var int execStartTime = na


var int sweepDir = 0
var int sweepBar = na
var int sweepTime = na

var float sweepExtreme = na


var float mssLevel = na
var bool mssConfirmed = false


//=============================================================================
// CONTINUATION STATE
//=============================================================================

var bool hardContinuationSwitch = false

var int continuationDir = 0

var int continuationSwitchBar = na
var int continuationSwitchTime = na

var float continuationImpulseHigh = na
var float continuationImpulseLow = na

var int continuationTapBar = na

var float continuationTappedFvgLo = na
var float continuationTappedFvgHi = na

var string continuationTappedTf = ""

var float continuationBosLevel = na

var float continuationSwingExtreme = na


//=============================================================================
// ACTIVE TRADE
//=============================================================================

var int tradeDir = 0
var int tradeEntryBar = na

var float entryPrice = na
var float stopPrice = na
var float targetPrice = na


var float zoneLo = na
var float zoneHi = na
var int zoneSourceBar = na


//=============================================================================
// DRAWINGS
//=============================================================================

var box activeBox = na

var line entryLine = na
var line stopLine = na
var line targetLine = na

var line mssLine = na
var line continuationBosLine = na


//=============================================================================
// ALERT FLAGS
//=============================================================================

bool reversalLongSignal = false
bool reversalShortSignal = false

bool continuationLongSignal = false
bool continuationShortSignal = false


//=============================================================================
// FIRST 30
//=============================================================================

bool withinFirst30 = (
     not na(execStartTime) and
     time -
     execStartTime <
     30 *
     60 *
     1000
     )


bool reversalTimingAllowed = (
     not onlyFirst30 or
     withinFirst30
     )


//=============================================================================
// NEW EXECUTION WINDOW
//=============================================================================

if (
     barstate.isconfirmed and
     (
         newAsiaExec or
         newAMExec or
         newPMExec
         )
     )

    //-------------------------------------------------------------------------
    // Close previous session drawings.
    //-------------------------------------------------------------------------

    if not na(activeBox)

        box.set_extend(
             activeBox,
             extend.none
             )

        box.set_right(
             activeBox,
             bar_index
             )


    if not na(entryLine)

        line.set_extend(
             entryLine,
             extend.none
             )

        line.set_x2(
             entryLine,
             bar_index
             )


    if not na(stopLine)

        line.set_extend(
             stopLine,
             extend.none
             )

        line.set_x2(
             stopLine,
             bar_index
             )


    if not na(targetLine)

        line.set_extend(
             targetLine,
             extend.none
             )

        line.set_x2(
             targetLine,
             bar_index
             )


    if not na(mssLine)

        line.set_extend(
             mssLine,
             extend.none
             )

        line.set_x2(
             mssLine,
             bar_index
             )


    if not na(continuationBosLine)

        line.set_extend(
             continuationBosLine,
             extend.none
             )

        line.set_x2(
             continuationBosLine,
             bar_index
             )


    //-------------------------------------------------------------------------
    // Load ATM.
    //-------------------------------------------------------------------------

    bool rangeWasReady = false


    if newAsiaExec

        atmHi := asiaHi
        atmLo := asiaLo

        engineRangeStartBar := (
             asiaRangeStartBar
             )

        sessionName := "ASIA"

        rangeWasReady := (
             asiaRangeReady
             )

        asiaRangeReady := false


    else if newAMExec

        atmHi := amHi
        atmLo := amLo

        engineRangeStartBar := (
             amRangeStartBar
             )

        sessionName := "AM"

        rangeWasReady := (
             amRangeReady
             )

        amRangeReady := false


    else

        atmHi := pmHi
        atmLo := pmLo

        engineRangeStartBar := (
             pmRangeStartBar
             )

        sessionName := "PM"

        rangeWasReady := (
             pmRangeReady
             )

        pmRangeReady := false


    execStartTime := time


    phase := (
         rangeWasReady and
         not na(atmHi) and
         not na(atmLo) ?
         0 :
         7
         )


    sweepDir := 0
    sweepBar := na
    sweepTime := na

    sweepExtreme := na


    mssLevel := na
    mssConfirmed := false


    hardContinuationSwitch := false

    continuationDir := 0

    continuationSwitchBar := na
    continuationSwitchTime := na

    continuationImpulseHigh := na
    continuationImpulseLow := na

    continuationTapBar := na

    continuationTappedFvgLo := na
    continuationTappedFvgHi := na
    continuationTappedTf := ""

    continuationBosLevel := na
    continuationSwingExtreme := na


    tradeDir := 0
    tradeEntryBar := na

    entryPrice := na
    stopPrice := na
    targetPrice := na

    zoneLo := na
    zoneHi := na
    zoneSourceBar := na


    activeBox := na

    entryLine := na
    stopLine := na
    targetLine := na

    mssLine := na
    continuationBosLine := na


    if phase == 0

        label.new(
             bar_index,
             atmHi,
             sessionName +
             " ATM HIGH",
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(
                 color.red,
                 20
                 ),
             size=size.tiny
             )


        label.new(
             bar_index,
             atmLo,
             sessionName +
             " ATM LOW",
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(
                 color.green,
                 20
                 ),
             size=size.tiny
             )


//=============================================================================
// ATM SWEEP
//=============================================================================

if (
     barstate.isconfirmed and
     inAnyExec and
     phase == 0 and
     not na(atmHi) and
     not na(atmLo)
     )

    bool tookHigh = (
         high >
         atmHi
         )

    bool tookLow = (
         low <
         atmLo
         )


    if (
         tookHigh and
         tookLow
         )

        phase := 7


        if showSweepLabels

            label.new(
                 bar_index,
                 close,
                 "BOTH ATM SIDES",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.gray,
                 size=size.tiny
                 )


    //=========================================================================
    // ATM LOW SWEPT → REVERSAL LONG
    //=========================================================================

    else if tookLow

        sweepDir := 1

        sweepBar := bar_index
        sweepTime := time

        sweepExtreme := low

        phase := 1


        bool pivotUsable = (
             not na(lastPivotHigh) and
             not na(lastPivotHighBar) and
             bar_index -
             lastPivotHighBar <=
             pivotMaxAge
             )


        mssLevel := (
             pivotUsable ?
             lastPivotHigh :
             fallbackHigh
             )


        if showSweepLabels

            label.new(
                 bar_index,
                 low,
                 sessionName +
                 " ATM LOW SWEPT",
                 style=label.style_label_up,
                 textcolor=color.white,
                 color=color.green,
                 size=size.tiny
                 )


        if not na(mssLevel)

            mssLine := line.new(
                 bar_index,
                 mssLevel,
                 bar_index + 1,
                 mssLevel,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=color.new(
                     color.green,
                     40
                     ),
                 style=line.style_dashed,
                 width=1
                 )


    //=========================================================================
    // ATM HIGH SWEPT → REVERSAL SHORT
    //=========================================================================

    else if tookHigh

        sweepDir := -1

        sweepBar := bar_index
        sweepTime := time

        sweepExtreme := high

        phase := 1


        bool pivotUsable = (
             not na(lastPivotLow) and
             not na(lastPivotLowBar) and
             bar_index -
             lastPivotLowBar <=
             pivotMaxAge
             )


        mssLevel := (
             pivotUsable ?
             lastPivotLow :
             fallbackLow
             )


        if showSweepLabels

            label.new(
                 bar_index,
                 high,
                 sessionName +
                 " ATM HIGH SWEPT",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.red,
                 size=size.tiny
                 )


        if not na(mssLevel)

            mssLine := line.new(
                 bar_index,
                 mssLevel,
                 bar_index + 1,
                 mssLevel,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=color.new(
                     color.red,
                     40
                     ),
                 style=line.style_dashed,
                 width=1
                 )


//=============================================================================
// TRACK REVERSAL EXTREME
//=============================================================================

if (
     phase == 1 and
     inAnyExec
     )

    if sweepDir == 1

        sweepExtreme := math.min(
             nz(
                 sweepExtreme,
                 low
                 ),
             low
             )


    else if sweepDir == -1

        sweepExtreme := math.max(
             nz(
                 sweepExtreme,
                 high
                 ),
             high
             )


//=============================================================================
// MSS DISPLAY
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 1 and
     sweepDir != 0 and
     not mssConfirmed and
     not na(mssLevel)
     )

    if (
         sweepDir == 1 and
         close >
         mssLevel
         )

        mssConfirmed := true


        if not na(mssLine)

            line.set_extend(
                 mssLine,
                 extend.none
                 )

            line.set_x2(
                 mssLine,
                 bar_index
                 )


        if showMssLabels

            label.new(
                 bar_index,
                 low,
                 "BULLISH MSS",
                 style=label.style_label_up,
                 textcolor=color.white,
                 color=color.new(
                     color.green,
                     25
                     ),
                 size=size.tiny
                 )


    else if (
         sweepDir == -1 and
         close <
         mssLevel
         )

        mssConfirmed := true


        if not na(mssLine)

            line.set_extend(
                 mssLine,
                 extend.none
                 )

            line.set_x2(
                 mssLine,
                 bar_index
                 )


        if showMssLabels

            label.new(
                 bar_index,
                 high,
                 "BEARISH MSS",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.new(
                     color.red,
                     25
                     ),
                 size=size.tiny
                 )


//=============================================================================
// OPPOSING ATM ALREADY DELIVERED
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 1 and
     not hardContinuationSwitch
     )

    bool longDelivered = (
         sweepDir == 1 and
         high >=
         atmHi
         )

    bool shortDelivered = (
         sweepDir == -1 and
         low <=
         atmLo
         )


    if (
         longDelivered or
         shortDelivered
         )

        phase := 7


//=============================================================================
// HARD 100-POINT REGIME SWITCH
//
// THIS RUNS BEFORE THE REVERSAL ENTRY ENGINE.
//
// ATM HIGH +100:
// ALL SHORT REVERSAL LOGIC DIES IMMEDIATELY.
// CONT LONG ONLY.
//
// ATM LOW -100:
// ALL LONG REVERSAL LOGIC DIES IMMEDIATELY.
// CONT SHORT ONLY.
//
// THIS DOES NOT REQUIRE THE REVERSAL TRADE TO STOP FIRST.
//=============================================================================

if (
     barstate.isconfirmed and
     enableContinuation and
     inAnyExec and
     not hardContinuationSwitch and
     (
         phase == 1 or
         phase == 2 or
         phase == 3
         )
     )

    bool switchLong = (
         sweepDir == -1 and
         high >=
         atmHi +
         continuationDistance
         )


    bool switchShort = (
         sweepDir == 1 and
         low <=
         atmLo -
         continuationDistance
         )


    //=========================================================================
    // HARD SWITCH TO CONTINUATION LONG
    //=========================================================================

    if switchLong

        hardContinuationSwitch := true

        continuationDir := 1

        continuationSwitchBar := bar_index
        continuationSwitchTime := time

        continuationImpulseHigh := high
        continuationImpulseLow := low

        continuationTapBar := na

        continuationTappedFvgLo := na
        continuationTappedFvgHi := na
        continuationTappedTf := ""

        continuationBosLevel := na
        continuationSwingExtreme := na

        // We have ALREADY reached +100.
        // Go directly to FVG TAP WATCH.
        phase := 4


        // Stop reversal MSS guide.
        if not na(mssLine)

            line.set_extend(
                 mssLine,
                 extend.none
                 )

            line.set_x2(
                 mssLine,
                 bar_index
                 )


        // If a reversal trade was active,
        // immediately stop displaying it as the active model.
        if not na(entryLine)

            line.set_extend(
                 entryLine,
                 extend.none
                 )

            line.set_x2(
                 entryLine,
                 bar_index
                 )


        if not na(stopLine)

            line.set_extend(
                 stopLine,
                 extend.none
                 )

            line.set_x2(
                 stopLine,
                 bar_index
                 )


        if not na(targetLine)

            line.set_extend(
                 targetLine,
                 extend.none
                 )

            line.set_x2(
                 targetLine,
                 bar_index
                 )


        entryLine := na
        stopLine := na
        targetLine := na

        tradeDir := 0
        tradeEntryBar := na


        if showContinuationLabels

            label.new(
                 bar_index,
                 high,
                 "+100 ✓ REV SHORT OFF\nCONT LONG → WAIT FVG TAP",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.orange,
                 size=size.tiny
                 )


    //=========================================================================
    // HARD SWITCH TO CONTINUATION SHORT
    //=========================================================================

    else if switchShort

        hardContinuationSwitch := true

        continuationDir := -1

        continuationSwitchBar := bar_index
        continuationSwitchTime := time

        continuationImpulseHigh := high
        continuationImpulseLow := low

        continuationTapBar := na

        continuationTappedFvgLo := na
        continuationTappedFvgHi := na
        continuationTappedTf := ""

        continuationBosLevel := na
        continuationSwingExtreme := na

        // We have ALREADY reached -100.
        // Go directly to FVG TAP WATCH.
        phase := 4


        if not na(mssLine)

            line.set_extend(
                 mssLine,
                 extend.none
                 )

            line.set_x2(
                 mssLine,
                 bar_index
                 )


        if not na(entryLine)

            line.set_extend(
                 entryLine,
                 extend.none
                 )

            line.set_x2(
                 entryLine,
                 bar_index
                 )


        if not na(stopLine)

            line.set_extend(
                 stopLine,
                 extend.none
                 )

            line.set_x2(
                 stopLine,
                 bar_index
                 )


        if not na(targetLine)

            line.set_extend(
                 targetLine,
                 extend.none
                 )

            line.set_x2(
                 targetLine,
                 bar_index
                 )


        entryLine := na
        stopLine := na
        targetLine := na

        tradeDir := 0
        tradeEntryBar := na


        if showContinuationLabels

            label.new(
                 bar_index,
                 low,
                 "-100 ✓ REV LONG OFF\nCONT SHORT → WAIT FVG TAP",
                 style=label.style_label_up,
                 textcolor=color.white,
                 color=color.orange,
                 size=size.tiny
                 )


//=============================================================================
// REVERSAL SIGNIFICANT IFVG
//
// THIS CAN ONLY RUN IF THE +100/-100 HARD SWITCH HAS NOT OCCURRED.
//
// NO LIMIT.
// NO RETEST.
// ENTRY = CONFIRMED IFVG CLOSE.
//=============================================================================

if (
     barstate.isconfirmed and
     inAnyExec and
     phase == 1 and
     not hardContinuationSwitch and
     reversalTimingAllowed
     )

    int candidateIndex = -1
    int candidateBar = -1

    float candidateLo = na
    float candidateHi = na


    //=========================================================================
    // REVERSAL LONG
    //=========================================================================

    if (
         sweepDir == 1 and
         array.size(
             bearFvgLo
             ) > 0
         )

        for i = 0 to array.size(
             bearFvgLo
             ) - 1

            bool gapActive = array.get(
                 bearFvgActive,
                 i
                 )

            int sourceBar = array.get(
                 bearFvgBar,
                 i
                 )

            float zLo = array.get(
                 bearFvgLo,
                 i
                 )

            float zHi = array.get(
                 bearFvgHi,
                 i
                 )


            bool ageOk = (
                 bar_index -
                 sourceBar <=
                 ifvgMaxAge
                 )


            bool cycleOk = (
                 sourceBar >=
                 nz(
                     engineRangeStartBar,
                     sourceBar
                     )
                 )


            bool invertedNow = (
                 close >
                 zHi and
                 close[1] <=
                 zHi
                 )


            if (
                 gapActive and
                 ageOk and
                 cycleOk and
                 invertedNow and
                 sourceBar >
                 candidateBar
                 )

                candidateIndex := i
                candidateBar := sourceBar

                candidateLo := zLo
                candidateHi := zHi


    //=========================================================================
    // REVERSAL SHORT
    //=========================================================================

    else if (
         sweepDir == -1 and
         array.size(
             bullFvgLo
             ) > 0
         )

        for i = 0 to array.size(
             bullFvgLo
             ) - 1

            bool gapActive = array.get(
                 bullFvgActive,
                 i
                 )

            int sourceBar = array.get(
                 bullFvgBar,
                 i
                 )

            float zLo = array.get(
                 bullFvgLo,
                 i
                 )

            float zHi = array.get(
                 bullFvgHi,
                 i
                 )


            bool ageOk = (
                 bar_index -
                 sourceBar <=
                 ifvgMaxAge
                 )


            bool cycleOk = (
                 sourceBar >=
                 nz(
                     engineRangeStartBar,
                     sourceBar
                     )
                 )


            bool invertedNow = (
                 close <
                 zLo and
                 close[1] >=
                 zLo
                 )


            if (
                 gapActive and
                 ageOk and
                 cycleOk and
                 invertedNow and
                 sourceBar >
                 candidateBar
                 )

                candidateIndex := i
                candidateBar := sourceBar

                candidateLo := zLo
                candidateHi := zHi


    //=========================================================================
    // CREATE REVERSAL ENTRY
    //=========================================================================

    if candidateIndex >= 0

        zoneLo := candidateLo
        zoneHi := candidateHi
        zoneSourceBar := candidateBar


        entryPrice := close


        float swingStop = (
             sweepDir == 1 ?
             sweepExtreme -
             stopBufferTicks *
             syminfo.mintick :
             sweepExtreme +
             stopBufferTicks *
             syminfo.mintick
             )


        float gapStop = (
             sweepDir == 1 ?
             zoneLo -
             stopBufferTicks *
             syminfo.mintick :
             zoneHi +
             stopBufferTicks *
             syminfo.mintick
             )


        stopPrice := (
             stopMode ==
             "Sweep swing" ?
             swingStop :
             gapStop
             )


        targetPrice := (
             targetMode ==
             "Opposing ATM" ?
             (
                 sweepDir == 1 ?
                 atmHi :
                 atmLo
                 ) :
             (
                 sweepDir == 1 ?
                 entryPrice +
                 math.abs(
                     entryPrice -
                     stopPrice
                     ) *
                 fixedRR :
                 entryPrice -
                 math.abs(
                     stopPrice -
                     entryPrice
                     ) *
                 fixedRR
                 )
             )


        bool validLong = (
             sweepDir == 1 and
             stopPrice <
             entryPrice and
             targetPrice >
             entryPrice
             )


        bool validShort = (
             sweepDir == -1 and
             stopPrice >
             entryPrice and
             targetPrice <
             entryPrice
             )


        if (
             validLong or
             validShort
             )

            phase := 2

            tradeDir := sweepDir
            tradeEntryBar := bar_index


            if tradeDir == 1

                array.set(
                     bearFvgActive,
                     candidateIndex,
                     false
                     )

                reversalLongSignal := true


            else

                array.set(
                     bullFvgActive,
                     candidateIndex,
                     false
                     )

                reversalShortSignal := true


            //-----------------------------------------------------------------
            // Used IFVG
            //-----------------------------------------------------------------

            if showSetupZones

                activeBox := box.new(
                     left=zoneSourceBar,
                     top=zoneHi,
                     right=bar_index,
                     bottom=zoneLo,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     border_color=tradeDir == 1 ?
                     color.new(
                         color.green,
                         25
                         ) :
                     color.new(
                         color.red,
                         25
                         ),
                     bgcolor=tradeDir == 1 ?
                     color.new(
                         color.green,
                         88
                         ) :
                     color.new(
                         color.red,
                         88
                         )
                     )


            //-----------------------------------------------------------------
            // ENTRY / SL / TP LEVELS
            //-----------------------------------------------------------------

            entryLine := line.new(
                 bar_index,
                 entryPrice,
                 bar_index + 1,
                 entryPrice,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=color.yellow,
                 width=2
                 )


            stopLine := line.new(
                 bar_index,
                 stopPrice,
                 bar_index + 1,
                 stopPrice,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=color.red,
                 style=line.style_dotted,
                 width=1
                 )


            targetLine := line.new(
                 bar_index,
                 targetPrice,
                 bar_index + 1,
                 targetPrice,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=color.blue,
                 style=line.style_dashed,
                 width=1
                 )


            if showLevelTags

                label.new(
                     bar_index + 1,
                     entryPrice,
                     (
                         tradeDir == 1 ?
                         "REV LONG ENTRY " :
                         "REV SHORT ENTRY "
                         ) +
                     str.tostring(
                         entryPrice,
                         format.mintick
                         ),
                     xloc=xloc.bar_index,
                     style=label.style_label_left,
                     textcolor=color.black,
                     color=color.yellow,
                     size=size.tiny
                     )


                label.new(
                     bar_index + 1,
                     stopPrice,
                     "SL " +
                     str.tostring(
                         stopPrice,
                         format.mintick
                         ),
                     xloc=xloc.bar_index,
                     style=label.style_label_left,
                     textcolor=color.white,
                     color=color.red,
                     size=size.tiny
                     )


                label.new(
                     bar_index + 1,
                     targetPrice,
                     "TP " +
                     str.tostring(
                         targetPrice,
                         format.mintick
                         ),
                     xloc=xloc.bar_index,
                     style=label.style_label_left,
                     textcolor=color.white,
                     color=color.blue,
                     size=size.tiny
                     )


            if enableDynamicAlerts

                alert(
                     sessionName +
                     (
                         tradeDir == 1 ?
                         " ATM REVERSAL LONG" :
                         " ATM REVERSAL SHORT"
                         ) +
                     " | Entry " +
                     str.tostring(
                         entryPrice,
                         format.mintick
                         ) +
                     " | SL " +
                     str.tostring(
                         stopPrice,
                         format.mintick
                         ) +
                     " | TP " +
                     str.tostring(
                         targetPrice,
                         format.mintick
                         ),
                     alert.freq_once_per_bar_close
                     )


//=============================================================================
// MANAGE REVERSAL
//
// IF IT STOPS BEFORE +/-100:
//
// DON'T AUTOMATICALLY ENTER CONTINUATION.
//
// JUST WAIT TO SEE WHETHER PRICE ACTUALLY REACHES +/-100.
//
// THE HARD SWITCH ABOVE IS STILL THE ONLY THING THAT ALLOWS CONTINUATION.
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 2 and
     not hardContinuationSwitch and
     bar_index >
     tradeEntryBar
     )

    bool hitStop = (
         tradeDir == 1 ?
         low <=
         stopPrice :
         high >=
         stopPrice
         )


    bool hitTarget = (
         tradeDir == 1 ?
         high >=
         targetPrice :
         low <=
         targetPrice
         )


    if (
         hitStop and
         hitTarget
         )

        phase := 7


        if showOutcomeLabels

            label.new(
                 bar_index,
                 close,
                 "REV SL + TP SAME BAR",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.gray,
                 size=size.tiny
                 )


    else if hitTarget

        phase := 7


        if showOutcomeLabels

            label.new(
                 bar_index,
                 targetPrice,
                 "REV TP HIT",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.blue,
                 size=size.tiny
                 )


    else if hitStop

        //=============================================================
        // REVERSAL STOPPED.
        //
        // STILL NO CONT ENTRY.
        //
        // WAIT FOR HARD +/-100 THRESHOLD.
        //=============================================================

        if (
             enableContinuation and
             inAnyExec
             )

            phase := 3


            if showContinuationLabels

                label.new(
                     bar_index,
                     stopPrice,
                     sweepDir == -1 ?
                     "REV STOPPED • WAIT +100" :
                     "REV STOPPED • WAIT -100",
                     style=label.style_label_left,
                     textcolor=color.white,
                     color=color.orange,
                     size=size.tiny
                     )


        else

            phase := 7


    if (
         hitStop or
         hitTarget
         )

        if not na(entryLine)

            line.set_extend(
                 entryLine,
                 extend.none
                 )

            line.set_x2(
                 entryLine,
                 bar_index
                 )


        if not na(stopLine)

            line.set_extend(
                 stopLine,
                 extend.none
                 )

            line.set_x2(
                 stopLine,
                 bar_index
                 )


        if not na(targetLine)

            line.set_extend(
                 targetLine,
                 extend.none
                 )

            line.set_x2(
                 targetLine,
                 bar_index
                 )


        entryLine := na
        stopLine := na
        targetLine := na


//=============================================================================
// PHASE 3
//
// REVERSAL STOPPED BEFORE +/-100.
//
// JUST WAIT.
//
// NO CONTINUATION SETUP EXISTS YET.
//
// THE HARD SWITCH BLOCK ABOVE WILL MOVE PHASE 3 → PHASE 4
// WHEN +/-100 IS ACTUALLY REACHED.
//=============================================================================

if (
     phase == 3 and
     inAnyExec
     )

    // Intentional.
    // Hard-switch block controls transition.
    na


//=============================================================================
// CONTINUATION STEP 1
//
// +/-100 HAS ALREADY BEEN REACHED.
//
// WAIT FOR TAP OF BULLISH/BEARISH 1M OR 5M FVG.
//
// IMPORTANT:
//
// FVG MAY HAVE FORMED DURING THE IMPULSE FROM THE ATM SWEEP TO +100/-100.
//
// SO WE ALLOW FVGs FORMED AFTER THE ORIGINAL ATM SWEEP,
// NOT ONLY AFTER THE +100/-100 SWITCH CANDLE.
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 4 and
     hardContinuationSwitch and
     inAnyExec and
     bar_index >
     continuationSwitchBar
     )

    //=========================================================================
    // CONT LONG
    //=========================================================================

    if continuationDir == 1

        bool valid1m = (
             enable1mFvg and
             not na(cont1mBullLo) and
             not na(cont1mBullHi) and
             not na(cont1mBullTime) and
             not na(sweepTime) and
             cont1mBullTime >=
             sweepTime and
             time -
             cont1mBullTime <=
             continuationFvgMaxAge *
             60 *
             1000
             )


        bool valid5m = (
             enable5mFvg and
             not na(cont5mBullLo) and
             not na(cont5mBullHi) and
             not na(cont5mBullTime) and
             not na(sweepTime) and
             cont5mBullTime >=
             sweepTime and
             time -
             cont5mBullTime <=
             continuationFvgMaxAge *
             60 *
             1000
             )


        bool tap1m = (
             valid1m and
             low <=
             cont1mBullHi and
             high >=
             cont1mBullLo
             )


        bool tap5m = (
             valid5m and
             low <=
             cont5mBullHi and
             high >=
             cont5mBullLo
             )


        if (
             tap1m or
             tap5m
             )

            //=============================================================
            // The highest point made BEFORE the FVG pullback
            // becomes the bullish BOS level.
            //=============================================================

            continuationBosLevel := (
                 continuationImpulseHigh
                 )


            continuationTapBar := bar_index

            continuationSwingExtreme := low


            bool use5m = (
                 tap5m and
                 (
                     not tap1m or
                     nz(
                         cont5mBullTime,
                         0
                         ) >=
                     nz(
                         cont1mBullTime,
                         0
                         )
                     )
                 )


            if use5m

                continuationTappedFvgLo := (
                     cont5mBullLo
                     )

                continuationTappedFvgHi := (
                     cont5mBullHi
                     )

                continuationTappedTf := "5M"


            else

                continuationTappedFvgLo := (
                     cont1mBullLo
                     )

                continuationTappedFvgHi := (
                     cont1mBullHi
                     )

                continuationTappedTf := "1M"


            phase := 5


            if showSetupZones

                activeBox := box.new(
                     left=bar_index,
                     top=continuationTappedFvgHi,
                     right=bar_index + 1,
                     bottom=continuationTappedFvgLo,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     border_color=color.new(
                         color.lime,
                         25
                         ),
                     bgcolor=color.new(
                         color.lime,
                         88
                         )
                     )


            if (
                 showBosLevel and
                 not na(continuationBosLevel)
                 )

                continuationBosLine := line.new(
                     bar_index,
                     continuationBosLevel,
                     bar_index + 1,
                     continuationBosLevel,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.lime,
                     style=line.style_dashed,
                     width=2
                     )


            if showContinuationLabels

                label.new(
                     bar_index,
                     low,
                     continuationTappedTf +
                     " BULL FVG TAP ✓ • WAIT BOS",
                     style=label.style_label_up,
                     textcolor=color.white,
                     color=color.new(
                         color.lime,
                         15
                         ),
                     size=size.tiny
                     )


    //=========================================================================
    // CONT SHORT
    //=========================================================================

    else if continuationDir == -1

        bool valid1m = (
             enable1mFvg and
             not na(cont1mBearLo) and
             not na(cont1mBearHi) and
             not na(cont1mBearTime) and
             not na(sweepTime) and
             cont1mBearTime >=
             sweepTime and
             time -
             cont1mBearTime <=
             continuationFvgMaxAge *
             60 *
             1000
             )


        bool valid5m = (
             enable5mFvg and
             not na(cont5mBearLo) and
             not na(cont5mBearHi) and
             not na(cont5mBearTime) and
             not na(sweepTime) and
             cont5mBearTime >=
             sweepTime and
             time -
             cont5mBearTime <=
             continuationFvgMaxAge *
             60 *
             1000
             )


        bool tap1m = (
             valid1m and
             high >=
             cont1mBearLo and
             low <=
             cont1mBearHi
             )


        bool tap5m = (
             valid5m and
             high >=
             cont5mBearLo and
             low <=
             cont5mBearHi
             )


        if (
             tap1m or
             tap5m
             )

            //=============================================================
            // Lowest point before retracement becomes bearish BOS level.
            //=============================================================

            continuationBosLevel := (
                 continuationImpulseLow
                 )


            continuationTapBar := bar_index

            continuationSwingExtreme := high


            bool use5m = (
                 tap5m and
                 (
                     not tap1m or
                     nz(
                         cont5mBearTime,
                         0
                         ) >=
                     nz(
                         cont1mBearTime,
                         0
                         )
                     )
                 )


            if use5m

                continuationTappedFvgLo := (
                     cont5mBearLo
                     )

                continuationTappedFvgHi := (
                     cont5mBearHi
                     )

                continuationTappedTf := "5M"


            else

                continuationTappedFvgLo := (
                     cont1mBearLo
                     )

                continuationTappedFvgHi := (
                     cont1mBearHi
                     )

                continuationTappedTf := "1M"


            phase := 5


            if showSetupZones

                activeBox := box.new(
                     left=bar_index,
                     top=continuationTappedFvgHi,
                     right=bar_index + 1,
                     bottom=continuationTappedFvgLo,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     border_color=color.new(
                         color.red,
                         25
                         ),
                     bgcolor=color.new(
                         color.red,
                         88
                         )
                     )


            if (
                 showBosLevel and
                 not na(continuationBosLevel)
                 )

                continuationBosLine := line.new(
                     bar_index,
                     continuationBosLevel,
                     bar_index + 1,
                     continuationBosLevel,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.red,
                     style=line.style_dashed,
                     width=2
                     )


            if showContinuationLabels

                label.new(
                     bar_index,
                     high,
                     continuationTappedTf +
                     " BEAR FVG TAP ✓ • WAIT BOS",
                     style=label.style_label_down,
                     textcolor=color.white,
                     color=color.new(
                         color.red,
                         15
                         ),
                     size=size.tiny
                     )


    //-------------------------------------------------------------------------
    // Until FVG is tapped, keep tracking continuation impulse extreme.
    //-------------------------------------------------------------------------

    if phase == 4

        continuationImpulseHigh := math.max(
             nz(
                 continuationImpulseHigh,
                 high
                 ),
             high
             )


        continuationImpulseLow := math.min(
             nz(
                 continuationImpulseLow,
                 low
                 ),
             low
             )


//=============================================================================
// CONTINUATION STEP 2
//
// FVG TAPPED.
//
// TRACK RETRACEMENT SWING.
//
// LONG:
// BOS ABOVE PRE-PULLBACK HIGH.
//
// SHORT:
// BOS BELOW PRE-PULLBACK LOW.
//
// ENTER AT BOS CLOSE.
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 5 and
     hardContinuationSwitch and
     inAnyExec
     )

    //=========================================================================
    // CONT LONG
    //=========================================================================

    if continuationDir == 1

        continuationSwingExtreme := math.min(
             nz(
                 continuationSwingExtreme,
                 low
                 ),
             low
             )


        bool bullishBos = (
             bar_index >
             continuationTapBar and
             close >
             continuationBosLevel
             )


        if bullishBos

            entryPrice := close


            stopPrice := (
                 continuationSwingExtreme -
                 stopBufferTicks *
                 syminfo.mintick
                 )


            float risk = (
                 entryPrice -
                 stopPrice
                 )


            targetPrice := (
                 entryPrice +
                 risk
                 )


            if (
                 risk > 0 and
                 targetPrice >
                 entryPrice
                 )

                phase := 6

                tradeDir := 1
                tradeEntryBar := bar_index

                continuationLongSignal := true


                if not na(continuationBosLine)

                    line.set_extend(
                         continuationBosLine,
                         extend.none
                         )

                    line.set_x2(
                         continuationBosLine,
                         bar_index
                         )


                if not na(activeBox)

                    box.set_extend(
                         activeBox,
                         extend.none
                         )

                    box.set_right(
                         activeBox,
                         bar_index
                         )


                entryLine := line.new(
                     bar_index,
                     entryPrice,
                     bar_index + 1,
                     entryPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.yellow,
                     width=2
                     )


                stopLine := line.new(
                     bar_index,
                     stopPrice,
                     bar_index + 1,
                     stopPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.red,
                     style=line.style_dotted,
                     width=1
                     )


                targetLine := line.new(
                     bar_index,
                     targetPrice,
                     bar_index + 1,
                     targetPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.blue,
                     style=line.style_dashed,
                     width=1
                     )


                if showLevelTags

                    label.new(
                         bar_index + 1,
                         entryPrice,
                         "CONT LONG ENTRY " +
                         str.tostring(
                             entryPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.black,
                         color=color.yellow,
                         size=size.tiny
                         )


                    label.new(
                         bar_index + 1,
                         stopPrice,
                         "SL " +
                         str.tostring(
                             stopPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.white,
                         color=color.red,
                         size=size.tiny
                         )


                    label.new(
                         bar_index + 1,
                         targetPrice,
                         "TP 1R " +
                         str.tostring(
                             targetPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.white,
                         color=color.blue,
                         size=size.tiny
                         )


                if enableDynamicAlerts

                    alert(
                         sessionName +
                         " ATM CONT LONG" +
                         " | +100 HARD SWITCH" +
                         " | " +
                         continuationTappedTf +
                         " FVG TAP" +
                         " | BOS" +
                         " | Entry " +
                         str.tostring(
                             entryPrice,
                             format.mintick
                             ) +
                         " | SL " +
                         str.tostring(
                             stopPrice,
                             format.mintick
                             ) +
                         " | TP " +
                         str.tostring(
                             targetPrice,
                             format.mintick
                             ),
                         alert.freq_once_per_bar_close
                         )


    //=========================================================================
    // CONT SHORT
    //=========================================================================

    else if continuationDir == -1

        continuationSwingExtreme := math.max(
             nz(
                 continuationSwingExtreme,
                 high
                 ),
             high
             )


        bool bearishBos = (
             bar_index >
             continuationTapBar and
             close <
             continuationBosLevel
             )


        if bearishBos

            entryPrice := close


            stopPrice := (
                 continuationSwingExtreme +
                 stopBufferTicks *
                 syminfo.mintick
                 )


            float risk = (
                 stopPrice -
                 entryPrice
                 )


            targetPrice := (
                 entryPrice -
                 risk
                 )


            if (
                 risk > 0 and
                 targetPrice <
                 entryPrice
                 )

                phase := 6

                tradeDir := -1
                tradeEntryBar := bar_index

                continuationShortSignal := true


                if not na(continuationBosLine)

                    line.set_extend(
                         continuationBosLine,
                         extend.none
                         )

                    line.set_x2(
                         continuationBosLine,
                         bar_index
                         )


                if not na(activeBox)

                    box.set_extend(
                         activeBox,
                         extend.none
                         )

                    box.set_right(
                         activeBox,
                         bar_index
                         )


                entryLine := line.new(
                     bar_index,
                     entryPrice,
                     bar_index + 1,
                     entryPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.yellow,
                     width=2
                     )


                stopLine := line.new(
                     bar_index,
                     stopPrice,
                     bar_index + 1,
                     stopPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.red,
                     style=line.style_dotted,
                     width=1
                     )


                targetLine := line.new(
                     bar_index,
                     targetPrice,
                     bar_index + 1,
                     targetPrice,
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=color.blue,
                     style=line.style_dashed,
                     width=1
                     )


                if showLevelTags

                    label.new(
                         bar_index + 1,
                         entryPrice,
                         "CONT SHORT ENTRY " +
                         str.tostring(
                             entryPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.black,
                         color=color.yellow,
                         size=size.tiny
                         )


                    label.new(
                         bar_index + 1,
                         stopPrice,
                         "SL " +
                         str.tostring(
                             stopPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.white,
                         color=color.red,
                         size=size.tiny
                         )


                    label.new(
                         bar_index + 1,
                         targetPrice,
                         "TP 1R " +
                         str.tostring(
                             targetPrice,
                             format.mintick
                             ),
                         xloc=xloc.bar_index,
                         style=label.style_label_left,
                         textcolor=color.white,
                         color=color.blue,
                         size=size.tiny
                         )


                if enableDynamicAlerts

                    alert(
                         sessionName +
                         " ATM CONT SHORT" +
                         " | -100 HARD SWITCH" +
                         " | " +
                         continuationTappedTf +
                         " FVG TAP" +
                         " | BOS" +
                         " | Entry " +
                         str.tostring(
                             entryPrice,
                             format.mintick
                             ) +
                         " | SL " +
                         str.tostring(
                             stopPrice,
                             format.mintick
                             ) +
                         " | TP " +
                         str.tostring(
                             targetPrice,
                             format.mintick
                             ),
                         alert.freq_once_per_bar_close
                         )


//=============================================================================
// MANAGE CONTINUATION
//=============================================================================

if (
     barstate.isconfirmed and
     phase == 6 and
     bar_index >
     tradeEntryBar
     )

    bool hitStop = (
         tradeDir == 1 ?
         low <=
         stopPrice :
         high >=
         stopPrice
         )


    bool hitTarget = (
         tradeDir == 1 ?
         high >=
         targetPrice :
         low <=
         targetPrice
         )


    if (
         hitStop and
         hitTarget
         )

        phase := 7


        if showOutcomeLabels

            label.new(
                 bar_index,
                 close,
                 "CONT SL + TP SAME BAR",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.gray,
                 size=size.tiny
                 )


    else if hitTarget

        phase := 7


        if showOutcomeLabels

            label.new(
                 bar_index,
                 targetPrice,
                 "✓ CONT 1R",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.blue,
                 size=size.tiny
                 )


    else if hitStop

        phase := 7


        if showOutcomeLabels

            label.new(
                 bar_index,
                 stopPrice,
                 "CONT SL",
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=color.red,
                 size=size.tiny
                 )


    if (
         hitStop or
         hitTarget
         )

        if not na(entryLine)

            line.set_extend(
                 entryLine,
                 extend.none
                 )

            line.set_x2(
                 entryLine,
                 bar_index
                 )


        if not na(stopLine)

            line.set_extend(
                 stopLine,
                 extend.none
                 )

            line.set_x2(
                 stopLine,
                 bar_index
                 )


        if not na(targetLine)

            line.set_extend(
                 targetLine,
                 extend.none
                 )

            line.set_x2(
                 targetLine,
                 bar_index
                 )


//=============================================================================
// EXECUTION WINDOW END
//=============================================================================

if (
     barstate.isconfirmed and
     execEnded
     )

    if (
         phase == 0 or
         phase == 1 or
         phase == 3 or
         phase == 4 or
         phase == 5
         )

        phase := 7


    if not na(mssLine)

        line.set_extend(
             mssLine,
             extend.none
             )

        line.set_x2(
             mssLine,
             bar_index
             )


    if not na(continuationBosLine)

        line.set_extend(
             continuationBosLine,
             extend.none
             )

        line.set_x2(
             continuationBosLine,
             bar_index
             )


//=============================================================================
// RETIRE SIGNIFICANT FVGs
//
// RUNS AFTER REVERSAL IFVG DETECTION.
//=============================================================================

if barstate.isconfirmed

    if array.size(
         bullFvgLo
         ) > 0

        for i = 0 to array.size(
             bullFvgLo
             ) - 1

            if array.get(
                 bullFvgActive,
                 i
                 )

                float zLo = array.get(
                     bullFvgLo,
                     i
                     )

                int sourceBar = array.get(
                     bullFvgBar,
                     i
                     )


                bool expired = (
                     bar_index -
                     sourceBar >
                     ifvgMaxAge
                     )


                bool inverted = (
                     close <
                     zLo
                     )


                if (
                     expired or
                     inverted
                     )

                    array.set(
                         bullFvgActive,
                         i,
                         false
                         )


    if array.size(
         bearFvgLo
         ) > 0

        for i = 0 to array.size(
             bearFvgLo
             ) - 1

            if array.get(
                 bearFvgActive,
                 i
                 )

                float zHi = array.get(
                     bearFvgHi,
                     i
                     )

                int sourceBar = array.get(
                     bearFvgBar,
                     i
                     )


                bool expired = (
                     bar_index -
                     sourceBar >
                     ifvgMaxAge
                     )


                bool inverted = (
                     close >
                     zHi
                     )


                if (
                     expired or
                     inverted
                     )

                    array.set(
                         bearFvgActive,
                         i,
                         false
                         )


//=============================================================================
// STORE SIGNIFICANT BULL FVG
//=============================================================================

if (
     barstate.isconfirmed and
     significantBullFvg
     )

    array.push(
         bullFvgLo,
         high[2]
         )

    array.push(
         bullFvgHi,
         low
         )

    array.push(
         bullFvgBar,
         bar_index
         )

    array.push(
         bullFvgActive,
         true
         )


    if (
         array.size(
             bullFvgLo
             ) >
         maxStoredFvgs
         )

        array.shift(
             bullFvgLo
             )

        array.shift(
             bullFvgHi
             )

        array.shift(
             bullFvgBar
             )

        array.shift(
             bullFvgActive
             )


//=============================================================================
// STORE SIGNIFICANT BEAR FVG
//=============================================================================

if (
     barstate.isconfirmed and
     significantBearFvg
     )

    array.push(
         bearFvgLo,
         high
         )

    array.push(
         bearFvgHi,
         low[2]
         )

    array.push(
         bearFvgBar,
         bar_index
         )

    array.push(
         bearFvgActive,
         true
         )


    if (
         array.size(
             bearFvgLo
             ) >
         maxStoredFvgs
         )

        array.shift(
             bearFvgLo
             )

        array.shift(
             bearFvgHi
             )

        array.shift(
             bearFvgBar
             )

        array.shift(
             bearFvgActive
             )


//=============================================================================
// ALERT CONDITIONS
//=============================================================================

alertcondition(
     reversalLongSignal,
     "ATM Reversal Long",
     "ATM Reversal LONG — Significant IFVG confirmed."
     )

alertcondition(
     reversalShortSignal,
     "ATM Reversal Short",
     "ATM Reversal SHORT — Significant IFVG confirmed."
     )

alertcondition(
     continuationLongSignal,
     "ATM Continuation Long",
     "ATM Continuation LONG — ATM High +100 hard switch + 1m/5m bullish FVG tap + bullish BOS."
     )

alertcondition(
     continuationShortSignal,
     "ATM Continuation Short",
     "ATM Continuation SHORT — ATM Low -100 hard switch + 1m/5m bearish FVG tap + bearish BOS."
     )
````
