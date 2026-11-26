# ORB STRAT 06/04/2026

- url: https://www.tradingview.com/script/cCgZQcnR-ORB-STRAT-06-04-2026/
- type: indicator
- pine_id: PUB;b52ddb98810a46f49a682658663e90b9
- version: 2.0

## Description

This strategy is built around the exact 9:30–9:45 AM Eastern opening range breakout (ORB).

The script pulls the completed 15-minute opening candle directly from the 15-minute timeframe, even when the strategy is used on a lower-timeframe chart. This helps keep the ORB levels consistent across supported chart timeframes.

The strategy is designed for intraday futures testing and includes optional filters to help reduce weaker breakouts.

HOW IT WORKS

The script identifies the high and low of the completed 9:30–9:45 AM Eastern opening-range candle.

After 9:45 AM, it watches for a confirmed breakout:

• Long setup: price closes above the ORB high by the selected tick buffer
• Short setup: price closes below the ORB low by the selected tick buffer

By default, the breakout candle must also meet the minimum candle-body-strength requirement.

STOP LOSS AND TAKE PROFIT

• Long stop loss: below the ORB low with an optional tick buffer
• Short stop loss: above the ORB high with an optional tick buffer
• Take profit: calculated using the selected reward-to-risk ratio
• Default target: 1.5R
• Open trades are closed by 4:00 PM Eastern

OPTIONAL CONFIRMATION FILTERS

The script includes several optional filters that can be enabled or disabled for testing:

• VWAP direction filter
• Higher-timeframe EMA trend filter
• Higher-timeframe EMA slope confirmation
• Stochastic momentum confirmation
• Two consecutive closes outside the ORB
• Retest confirmation after breakout
• One trade per day

HIGHER-TIMEFRAME TREND FILTER

The higher-timeframe trend filter uses completed candles to help reduce repainting.

For a long setup:

• The completed higher-timeframe close must be above the EMA
• The EMA slope can optionally be required to be rising

For a short setup:

• The completed higher-timeframe close must be below the EMA
• The EMA slope can optionally be required to be falling

The higher-timeframe chart is adjustable. Common test settings include:

• 15 minutes
• 1 hour
• 4 hours
• 1 day

ALERTS

The strategy includes early heads-up alerts and confirmed-entry alerts.

Possible long or short alerts are intended only as warnings that price is testing an ORB boundary. They are not confirmed entries.

Confirmed long or short alerts trigger only after the selected strategy rules are met.

For TradingView alerts, select:

• Order fills and alert() function calls

BACKTESTING

This script is a TradingView strategy, so results appear in the Strategy Tester.

The strategy automatically adapts its dollar calculations to the charted futures contract and selected number of contracts.

It can be tested on instruments such as:

• MES
• ES
• MNQ
• NQ

RECOMMENDED STARTING SETTINGS

• Chart timeframe: 5 minutes
• ORB: fixed at 9:30–9:45 AM Eastern
• Confirmed breakout buffer: 4 ticks
• Minimum breakout candle body: 55%
• VWAP filter: on
• Higher-timeframe trend filter: on
• Higher-timeframe EMA length: 50
• Stochastic filter: off
• Two-close confirmation: off
• Retest confirmation: off
• One trade per day: on
• Reward-to-risk target: 1.5R

IMPORTANT NOTES

Historical results do not guarantee future performance.

Backtesting results may differ from live trading because of slippage, commissions, spread, order execution, and intrabar price movement.

Possible alerts may trigger before a candle closes. Confirmed entries are intended to be evaluated using closed candles.

This strategy is for educational and testing purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Kayligh's Exact 15M ORB + Liquidity Sweep + Dollar Backtest", overlay=true, max_boxes_count=300, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================

string timezoneInput = input.string("America/New_York", "Timezone")
string orbSession = input.session("0930-0945", "15-minute ORB window")
string entrySession = input.session("0945-1530", "Allow new entries")
string manageSession = input.session("0945-1600", "Manage open trades until")
string displaySession = input.session("0930-1600", "Display ORB levels until")

int backtestStartDate = input.time(timestamp("01 Jan 2024 00:00 -0500"), "Backtest start date")

bool enablePossibleAlerts = input.bool(true, "Enable possible long and short alerts")
int possibleAlertBufferTicks = input.int(0, "Possible alert distance beyond ORB: ticks", minval=0)
bool showPossibleMarkers = input.bool(true, "Show possible long and short markers")

int breakoutBufferTicks = input.int(4, "Confirmed close beyond ORB: ticks", minval=0)
float minimumBodyPercent = input.float(55.0, "Breakout candle minimum body %", minval=0.0, maxval=100.0, step=5.0)
bool requireSecondClose = input.bool(true, "Require two consecutive closes outside ORB")
bool requireRetest = input.bool(false, "Require retest after breakout")
int maxRetestBars = input.int(6, "Maximum candles allowed for retest", minval=1)

bool useLiquiditySweepMode = input.bool(false, "Use ORB liquidity sweep reversal mode")
float minimumWickPercent = input.float(45.0, "Minimum rejection wick %", minval=10.0, maxval=90.0, step=5.0)

bool useVwapFilter = input.bool(true, "Use VWAP direction filter")
bool showVwap = input.bool(true, "Show VWAP")

bool useTopDownFilter = input.bool(true, "Use higher-timeframe trend filter")
string trendTimeframe = input.timeframe("1D", "Higher-timeframe trend chart")
int trendEmaLength = input.int(50, "Higher-timeframe EMA length", minval=1)
bool requireEmaSlope = input.bool(true, "Require higher-timeframe EMA slope")
bool showTrendEma = input.bool(false, "Show completed higher-timeframe EMA")

bool useStochasticFilter = input.bool(false, "Use stochastic momentum filter")
int stochasticLength = input.int(14, "Stochastic length", minval=1)
int stochasticKSmoothing = input.int(3, "Stochastic K smoothing", minval=1)
int stochasticDSmoothing = input.int(3, "Stochastic D smoothing", minval=1)

bool oneTradePerDay = input.bool(true, "Only take one trade per day")
float rewardRisk = input.float(1.50, "Take-profit reward-to-risk", minval=0.25, step=0.25)
int stopBufferTicks = input.int(2, "Stop-loss buffer ticks", minval=0)
int contractQuantity = input.int(1, "Number of contracts for dollar backtest", minval=1)
float roundTripFeePerContract = input.float(0.00, "Round-trip fees per contract", minval=0.00, step=0.01)

bool showOrbBox = input.bool(true, "Show exact 15-minute ORB box")
bool extendOrbBox = input.bool(true, "Extend shaded ORB box across the day")
bool showTradeLines = input.bool(true, "Show entry, stop-loss and take-profit lines")
bool showLabels = input.bool(true, "Show entry and exit labels")
bool showTable = input.bool(true, "Show backtesting table")

// ============================================================================
// SESSION DETECTION
// ============================================================================

bool inOrbBuildSession = not na(time(timeframe.period, orbSession, timezoneInput))
bool inEntrySession = not na(time(timeframe.period, entrySession, timezoneInput))
bool inManageSession = not na(time(timeframe.period, manageSession, timezoneInput))
bool inDisplaySession = not na(time(timeframe.period, displaySession, timezoneInput))

bool orbStarts = inOrbBuildSession and (bar_index == 0 or not inOrbBuildSession[1])
bool orbEnds = not inOrbBuildSession and inOrbBuildSession[1]
bool manageSessionEnds = not inManageSession and inManageSession[1]

bool inBacktestRange = time >= backtestStartDate

// ============================================================================
// HISTORY VERIFICATION COUNTERS
// ============================================================================

var int firstLoadedBarTime = na
var int firstOrbScannedTime = na
var int orbDaysScanned = 0
var int qualifiedSetups = 0
var int tradesTaken = 0

if na(firstLoadedBarTime)
    firstLoadedBarTime := time

// ============================================================================
// EXACT COMPLETED 9:30–9:45 AM 15-MINUTE ORB
// ============================================================================

float exactCompleted15High = request.security(syminfo.tickerid, "15", high[1], lookahead=barmerge.lookahead_on)
float exactCompleted15Low = request.security(syminfo.tickerid, "15", low[1], lookahead=barmerge.lookahead_on)

var float orbHigh = na
var float orbLow = na
var bool orbReady = false
var box currentOrbBox = na

if orbStarts
    orbHigh := na
    orbLow := na
    orbReady := false
    currentOrbBox := na

if orbEnds and not na(exactCompleted15High) and not na(exactCompleted15Low)
    orbHigh := exactCompleted15High
    orbLow := exactCompleted15Low
    orbReady := true

    if inBacktestRange
        orbDaysScanned += 1

        if na(firstOrbScannedTime)
            firstOrbScannedTime := time

    if showOrbBox
        int exactOrbEndTime = time
        int exactOrbStartTime = exactOrbEndTime - 15 * 60 * 1000
        currentOrbBox := box.new(left=exactOrbStartTime, top=orbHigh, right=exactOrbEndTime, bottom=orbLow, xloc=xloc.bar_time, border_color=color.rgb(255, 193, 7), border_width=2, bgcolor=color.new(color.rgb(255, 193, 7), 86))

if showOrbBox and extendOrbBox and orbReady and inDisplaySession and not na(currentOrbBox)
    box.set_right(currentOrbBox, time_close)

plot(inDisplaySession and orbReady ? orbHigh : na, "Exact 15-Minute ORB High", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(inDisplaySession and orbReady ? orbLow : na, "Exact 15-Minute ORB Low", color=color.red, linewidth=2, style=plot.style_linebr)

// ============================================================================
// VWAP
// ============================================================================

float vwapValue = ta.vwap(hlc3)
plot(showVwap ? vwapValue : na, "VWAP", color=color.aqua, linewidth=2)

bool longVwapOkay = not useVwapFilter or close > vwapValue
bool shortVwapOkay = not useVwapFilter or close < vwapValue

// ============================================================================
// COMPLETED HIGHER-TIMEFRAME TREND
// ============================================================================

float trendEmaConfirmed = request.security(syminfo.tickerid, trendTimeframe, ta.ema(close, trendEmaLength)[1], lookahead=barmerge.lookahead_on)
float trendEmaPrevious = request.security(syminfo.tickerid, trendTimeframe, ta.ema(close, trendEmaLength)[2], lookahead=barmerge.lookahead_on)
float trendCloseConfirmed = request.security(syminfo.tickerid, trendTimeframe, close[1], lookahead=barmerge.lookahead_on)

bool trendEmaRising = trendEmaConfirmed > trendEmaPrevious
bool trendEmaFalling = trendEmaConfirmed < trendEmaPrevious

bool longTrendOkay = not useTopDownFilter or (trendCloseConfirmed > trendEmaConfirmed and (not requireEmaSlope or trendEmaRising))
bool shortTrendOkay = not useTopDownFilter or (trendCloseConfirmed < trendEmaConfirmed and (not requireEmaSlope or trendEmaFalling))

plot(showTrendEma ? trendEmaConfirmed : na, "Completed HTF EMA", color=color.orange, linewidth=2)

// ============================================================================
// STOCHASTIC
// ============================================================================

float rawStochasticK = ta.stoch(close, high, low, stochasticLength)
float stochasticK = ta.sma(rawStochasticK, stochasticKSmoothing)
float stochasticD = ta.sma(stochasticK, stochasticDSmoothing)

bool longStochasticOkay = not useStochasticFilter or (stochasticK > stochasticD and stochasticK > 50)
bool shortStochasticOkay = not useStochasticFilter or (stochasticK < stochasticD and stochasticK < 50)

// ============================================================================
// TRIGGER LEVELS
// ============================================================================

float possibleAlertBuffer = possibleAlertBufferTicks * syminfo.mintick
float possibleLongTrigger = orbHigh + possibleAlertBuffer
float possibleShortTrigger = orbLow - possibleAlertBuffer

float confirmedBreakoutBuffer = breakoutBufferTicks * syminfo.mintick
float confirmedLongTrigger = orbHigh + confirmedBreakoutBuffer
float confirmedShortTrigger = orbLow - confirmedBreakoutBuffer

float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyPercent = candleRange > 0 ? candleBody / candleRange * 100.0 : 0.0

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickPercent = candleRange > 0 ? upperWick / candleRange * 100.0 : 0.0
float lowerWickPercent = candleRange > 0 ? lowerWick / candleRange * 100.0 : 0.0

bool strongBullishCandle = close > open and bodyPercent >= minimumBodyPercent
bool strongBearishCandle = close < open and bodyPercent >= minimumBodyPercent

// ============================================================================
// ACTIVE TRADE STATE
// ============================================================================

var bool tradeActive = false
var int tradeDirection = 0
var int tradeEntryBar = na

var float tradeEntry = na
var float tradeStop = na
var float tradeTarget = na
var float tradeRisk = na

var line entryLine = na
var line stopLine = na
var line targetLine = na

// ============================================================================
// SETUP STATE
// ============================================================================

var bool tradedToday = false
var bool possibleLongAlertedToday = false
var bool possibleShortAlertedToday = false

var int pendingDirection = 0
var int pendingBreakoutBar = na

var bool longRetestArmed = false
var bool shortRetestArmed = false

var int longRetestArmBar = na
var int shortRetestArmBar = na

if orbStarts
    tradedToday := false
    possibleLongAlertedToday := false
    possibleShortAlertedToday := false
    pendingDirection := 0
    pendingBreakoutBar := na
    longRetestArmed := false
    shortRetestArmed := false
    longRetestArmBar := na
    shortRetestArmBar := na

// ============================================================================
// POSSIBLE ALERTS
// ============================================================================

bool canSendPossibleAlert = enablePossibleAlerts and orbReady and inEntrySession and not tradeActive and (not oneTradePerDay or not tradedToday)

bool possibleLongAlert = canSendPossibleAlert and not possibleLongAlertedToday and high >= possibleLongTrigger and longVwapOkay and longTrendOkay
bool possibleShortAlert = canSendPossibleAlert and not possibleShortAlertedToday and low <= possibleShortTrigger and shortVwapOkay and shortTrendOkay

if possibleLongAlert
    possibleLongAlertedToday := true

if possibleShortAlert
    possibleShortAlertedToday := true

plotshape(showPossibleMarkers and possibleLongAlert, title="Possible ORB Long", text="POSSIBLE\nLONG", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.tiny)
plotshape(showPossibleMarkers and possibleShortAlert, title="Possible ORB Short", text="POSSIBLE\nSHORT", style=shape.labeldown, location=location.abovebar, color=color.yellow, textcolor=color.black, size=size.tiny)

// ============================================================================
// CONFIRMED SETUP SEARCH
// ============================================================================

bool longSignal = false
bool shortSignal = false

bool canSearchForConfirmedSetup = inBacktestRange and orbReady and inEntrySession and barstate.isconfirmed and not tradeActive and (not oneTradePerDay or not tradedToday)

// ORIGINAL BREAKOUT MODE
bool freshLongBreakout = canSearchForConfirmedSetup and not useLiquiditySweepMode and close > confirmedLongTrigger and close[1] <= confirmedLongTrigger and strongBullishCandle and longVwapOkay and longTrendOkay

bool freshShortBreakout = canSearchForConfirmedSetup and not useLiquiditySweepMode and close < confirmedShortTrigger and close[1] >= confirmedShortTrigger and strongBearishCandle and shortVwapOkay and shortTrendOkay

// LIQUIDITY SWEEP MODE
bool liquiditySweepLong = canSearchForConfirmedSetup and useLiquiditySweepMode and low < orbLow and close > orbLow and lowerWickPercent >= minimumWickPercent and longVwapOkay and longTrendOkay and longStochasticOkay

bool liquiditySweepShort = canSearchForConfirmedSetup and useLiquiditySweepMode and high > orbHigh and close < orbHigh and upperWickPercent >= minimumWickPercent and shortVwapOkay and shortTrendOkay and shortStochasticOkay

if liquiditySweepLong
    longSignal := true

if liquiditySweepShort
    shortSignal := true

// ============================================================================
// LONG BREAKOUT LOGIC
// ============================================================================

if freshLongBreakout
    shortRetestArmed := false
    shortRetestArmBar := na
    pendingDirection := 0
    pendingBreakoutBar := na

    if requireSecondClose
        pendingDirection := 1
        pendingBreakoutBar := bar_index
    else if requireRetest
        longRetestArmed := true
        longRetestArmBar := bar_index
    else if longStochasticOkay
        longSignal := true

// ============================================================================
// SHORT BREAKOUT LOGIC
// ============================================================================

if freshShortBreakout
    longRetestArmed := false
    longRetestArmBar := na
    pendingDirection := 0
    pendingBreakoutBar := na

    if requireSecondClose
        pendingDirection := -1
        pendingBreakoutBar := bar_index
    else if requireRetest
        shortRetestArmed := true
        shortRetestArmBar := bar_index
    else if shortStochasticOkay
        shortSignal := true

// ============================================================================
// OPTIONAL SECOND CLOSE
// ============================================================================

if pendingDirection == 1 and not na(pendingBreakoutBar) and bar_index > pendingBreakoutBar
    bool secondLongCloseOkay = canSearchForConfirmedSetup and close > confirmedLongTrigger and longVwapOkay and longTrendOkay

    if secondLongCloseOkay
        if requireRetest
            longRetestArmed := true
            longRetestArmBar := bar_index
        else if longStochasticOkay
            longSignal := true

    pendingDirection := 0
    pendingBreakoutBar := na

if pendingDirection == -1 and not na(pendingBreakoutBar) and bar_index > pendingBreakoutBar
    bool secondShortCloseOkay = canSearchForConfirmedSetup and close < confirmedShortTrigger and shortVwapOkay and shortTrendOkay

    if secondShortCloseOkay
        if requireRetest
            shortRetestArmed := true
            shortRetestArmBar := bar_index
        else if shortStochasticOkay
            shortSignal := true

    pendingDirection := 0
    pendingBreakoutBar := na

// ============================================================================
// CANCEL FAILED OR EXPIRED RETESTS
// ============================================================================

if longRetestArmed and not na(longRetestArmBar)
    bool longRetestExpired = bar_index - longRetestArmBar > maxRetestBars
    bool longBreakoutFailed = close < orbHigh

    if longRetestExpired or longBreakoutFailed
        longRetestArmed := false
        longRetestArmBar := na

if shortRetestArmed and not na(shortRetestArmBar)
    bool shortRetestExpired = bar_index - shortRetestArmBar > maxRetestBars
    bool shortBreakoutFailed = close > orbLow

    if shortRetestExpired or shortBreakoutFailed
        shortRetestArmed := false
        shortRetestArmBar := na

// ============================================================================
// OPTIONAL RETEST ENTRY
// ============================================================================

bool longRetestSignal = canSearchForConfirmedSetup and not useLiquiditySweepMode and longRetestArmed and not na(longRetestArmBar) and bar_index > longRetestArmBar and low <= confirmedLongTrigger and close > confirmedLongTrigger and close > open and longVwapOkay and longTrendOkay and longStochasticOkay

bool shortRetestSignal = canSearchForConfirmedSetup and not useLiquiditySweepMode and shortRetestArmed and not na(shortRetestArmBar) and bar_index > shortRetestArmBar and high >= confirmedShortTrigger and close < confirmedShortTrigger and close < open and shortVwapOkay and shortTrendOkay and shortStochasticOkay

if requireRetest and longRetestSignal
    longSignal := true
    longRetestArmed := false
    longRetestArmBar := na

if requireRetest and shortRetestSignal
    shortSignal := true
    shortRetestArmed := false
    shortRetestArmBar := na

// Count setups that passed every enabled filter
if longSignal or shortSignal
    qualifiedSetups += 1

// ============================================================================
// BACKTEST TOTALS
// ============================================================================

var int totalTrades = 0
var int wins = 0
var int losses = 0
var int breakevens = 0
var int forcedExits = 0

var float netR = 0.0
var float netDollarProfit = 0.0
var float grossDollarProfit = 0.0
var float grossDollarLoss = 0.0

float stopBufferAmount = stopBufferTicks * syminfo.mintick

// ============================================================================
// CLOSE EXISTING TRADE
// ============================================================================

if tradeActive and bar_index > tradeEntryBar
    bool stopHit = tradeDirection == 1 ? low <= tradeStop : high >= tradeStop
    bool targetHit = tradeDirection == 1 ? high >= tradeTarget : low <= tradeTarget

    bool closeTrade = false
    bool forcedExit = false

    float exitPrice = na
    string exitText = ""

    if manageSessionEnds
        exitPrice := close[1]
        closeTrade := true
        forcedExit := true
        exitText := "4 PM EXIT"
    else if stopHit and targetHit
        exitPrice := tradeStop
        closeTrade := true
        exitText := "SL HIT"
    else if stopHit
        exitPrice := tradeStop
        closeTrade := true
        exitText := "SL HIT"
    else if targetHit
        exitPrice := tradeTarget
        closeTrade := true
        exitText := "TP HIT"

    if closeTrade
        float resultR = tradeDirection == 1 ? (exitPrice - tradeEntry) / tradeRisk : (tradeEntry - exitPrice) / tradeRisk
        float grossTradeDollars = tradeDirection == 1 ? (exitPrice - tradeEntry) * syminfo.pointvalue * contractQuantity : (tradeEntry - exitPrice) * syminfo.pointvalue * contractQuantity
        float tradeFees = roundTripFeePerContract * contractQuantity
        float tradeDollarResult = grossTradeDollars - tradeFees

        totalTrades += 1
        netR += resultR
        netDollarProfit += tradeDollarResult

        if forcedExit
            forcedExits += 1

        if tradeDollarResult > 0
            wins += 1
            grossDollarProfit += tradeDollarResult
        else if tradeDollarResult < 0
            losses += 1
            grossDollarLoss += math.abs(tradeDollarResult)
        else
            breakevens += 1

        if showLabels
            label.new(bar_index, close, exitText + "\n" + str.tostring(resultR, "#.##") + "R\n$" + str.tostring(tradeDollarResult, "#.##"), style=tradeDollarResult >= 0 ? label.style_label_down : label.style_label_up, color=tradeDollarResult >= 0 ? color.green : color.red, textcolor=color.white, size=size.small)

        if not na(entryLine)
            line.delete(entryLine)

        if not na(stopLine)
            line.delete(stopLine)

        if not na(targetLine)
            line.delete(targetLine)

        entryLine := na
        stopLine := na
        targetLine := na

        tradeActive := false
        tradeDirection := 0
        tradeEntryBar := na
        tradeEntry := na
        tradeStop := na
        tradeTarget := na
        tradeRisk := na

// ============================================================================
// OPEN LONG TRADE
// ============================================================================

if not tradeActive and longSignal
    float proposedEntry = close
    float proposedStop = useLiquiditySweepMode ? low - stopBufferAmount : orbLow - stopBufferAmount
    float proposedRisk = proposedEntry - proposedStop

    if proposedRisk >= syminfo.mintick
        tradeActive := true
        tradeDirection := 1
        tradeEntryBar := bar_index

        tradeEntry := proposedEntry
        tradeStop := proposedStop
        tradeRisk := proposedRisk
        tradeTarget := tradeEntry + tradeRisk * rewardRisk

        tradedToday := true
        tradesTaken += 1

        if showTradeLines
            entryLine := line.new(bar_index, tradeEntry, bar_index + 1, tradeEntry, extend=extend.right, color=color.white, width=2)
            stopLine := line.new(bar_index, tradeStop, bar_index + 1, tradeStop, extend=extend.right, color=color.red, width=2)
            targetLine := line.new(bar_index, tradeTarget, bar_index + 1, tradeTarget, extend=extend.right, color=color.lime, width=2)

        if showLabels
            label.new(bar_index, low, useLiquiditySweepMode ? "SWEEP LONG\nENTRY: " + str.tostring(tradeEntry, format.mintick) + "\nSL: " + str.tostring(tradeStop, format.mintick) + "\nTP: " + str.tostring(tradeTarget, format.mintick) : "ORB LONG CONFIRMED\nENTRY: " + str.tostring(tradeEntry, format.mintick) + "\nSL: " + str.tostring(tradeStop, format.mintick) + "\nTP: " + str.tostring(tradeTarget, format.mintick), style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

// ============================================================================
// OPEN SHORT TRADE
// ============================================================================

if not tradeActive and shortSignal
    float proposedEntry = close
    float proposedStop = useLiquiditySweepMode ? high + stopBufferAmount : orbHigh + stopBufferAmount
    float proposedRisk = proposedStop - proposedEntry

    if proposedRisk >= syminfo.mintick
        tradeActive := true
        tradeDirection := -1
        tradeEntryBar := bar_index

        tradeEntry := proposedEntry
        tradeStop := proposedStop
        tradeRisk := proposedRisk
        tradeTarget := tradeEntry - tradeRisk * rewardRisk

        tradedToday := true
        tradesTaken += 1

        if showTradeLines
            entryLine := line.new(bar_index, tradeEntry, bar_index + 1, tradeEntry, extend=extend.right, color=color.white, width=2)
            stopLine := line.new(bar_index, tradeStop, bar_index + 1, tradeStop, extend=extend.right, color=color.red, width=2)
            targetLine := line.new(bar_index, tradeTarget, bar_index + 1, tradeTarget, extend=extend.right, color=color.lime, width=2)

        if showLabels
            label.new(bar_index, high, useLiquiditySweepMode ? "SWEEP SHORT\nENTRY: " + str.tostring(tradeEntry, format.mintick) + "\nSL: " + str.tostring(tradeStop, format.mintick) + "\nTP: " + str.tostring(tradeTarget, format.mintick) : "ORB SHORT CONFIRMED\nENTRY: " + str.tostring(tradeEntry, format.mintick) + "\nSL: " + str.tostring(tradeStop, format.mintick) + "\nTP: " + str.tostring(tradeTarget, format.mintick), style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// ============================================================================
// MARKERS AND ALERTS
// ============================================================================

plotshape(longSignal and not useLiquiditySweepMode, title="Confirmed ORB Long", text="ORB\nLONG", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(shortSignal and not useLiquiditySweepMode, title="Confirmed ORB Short", text="ORB\nSHORT", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(longSignal and useLiquiditySweepMode, title="Confirmed Sweep Long", text="SWEEP\nLONG", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(shortSignal and useLiquiditySweepMode, title="Confirmed Sweep Short", text="SWEEP\nSHORT", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

alertcondition(possibleLongAlert, "Possible ORB Long", "Possible ORB long: price is testing the exact 9:30–9:45 ORB high. Watch for confirmation before entering.")
alertcondition(possibleShortAlert, "Possible ORB Short", "Possible ORB short: price is testing the exact 9:30–9:45 ORB low. Watch for confirmation before entering.")
alertcondition(longSignal, "Confirmed ORB Long / Sweep Long", "Confirmed ORB long or liquidity sweep long setup.")
alertcondition(shortSignal, "Confirmed ORB Short / Sweep Short", "Confirmed ORB short or liquidity sweep short setup.")

// ============================================================================
// SMALL BACKTEST TABLE WITH HISTORY VERIFICATION
// ============================================================================

float winRate = totalTrades > 0 ? wins * 100.0 / totalTrades : na
float profitFactor = grossDollarLoss > 0 ? grossDollarProfit / grossDollarLoss : na

string winRateText = totalTrades > 0 ? str.tostring(winRate, "#.##") + "%" : "N/A"
string profitFactorText = grossDollarLoss > 0 ? str.tostring(profitFactor, "#.##") : grossDollarProfit > 0 ? "No losses" : "N/A"
string dollarProfitText = netDollarProfit >= 0 ? "+$" + str.tostring(netDollarProfit, "#.##") : "-$" + str.tostring(math.abs(netDollarProfit), "#.##")

string requestedStartText = str.format_time(backtestStartDate, "MMM dd, yyyy", timezoneInput)
string oldestLoadedText = not na(firstLoadedBarTime) ? str.format_time(firstLoadedBarTime, "MMM dd, yyyy", timezoneInput) : "N/A"
string firstOrbScannedText = not na(firstOrbScannedTime) ? str.format_time(firstOrbScannedTime, "MMM dd, yyyy", timezoneInput) : "N/A"

bool requestedHistoryLoaded = not na(firstLoadedBarTime) and firstLoadedBarTime <= backtestStartDate
string requestedHistoryLoadedText = requestedHistoryLoaded ? "YES" : "NO"

var table stats = table.new(position.top_right, 2, 15, border_width=1)

if barstate.islast and showTable
    table.cell(stats, 0, 0, "ORB TEST", bgcolor=color.rgb(63, 81, 181), text_color=color.white)
    table.cell(stats, 1, 0, useLiquiditySweepMode ? "SWEEP" : "BREAKOUT", bgcolor=color.rgb(63, 81, 181), text_color=color.white)

    table.cell(stats, 0, 1, "History loaded?", bgcolor=requestedHistoryLoaded ? color.new(color.green, 68) : color.new(color.red, 60), text_color=color.white)
    table.cell(stats, 1, 1, requestedHistoryLoadedText, bgcolor=requestedHistoryLoaded ? color.new(color.green, 68) : color.new(color.red, 60), text_color=color.white)

    table.cell(stats, 0, 2, "Requested start", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(stats, 1, 2, requestedStartText, bgcolor=color.new(color.blue, 80), text_color=color.white)

    table.cell(stats, 0, 3, "Oldest candle", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(stats, 1, 3, oldestLoadedText, bgcolor=color.new(color.blue, 80), text_color=color.white)

    table.cell(stats, 0, 4, "First ORB checked", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(stats, 1, 4, firstOrbScannedText, bgcolor=color.new(color.blue, 80), text_color=color.white)

    table.cell(stats, 0, 5, "ORB days scanned", bgcolor=color.new(color.orange, 70), text_color=color.white)
    table.cell(stats, 1, 5, str.tostring(orbDaysScanned), bgcolor=color.new(color.orange, 70), text_color=color.white)

    table.cell(stats, 0, 6, "Qualified setups", bgcolor=color.new(color.orange, 70), text_color=color.white)
    table.cell(stats, 1, 6, str.tostring(qualifiedSetups), bgcolor=color.new(color.orange, 70), text_color=color.white)

    table.cell(stats, 0, 7, "Trades taken", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(stats, 1, 7, str.tostring(tradesTaken), bgcolor=color.new(color.blue, 80), text_color=color.white)

    table.cell(stats, 0, 8, "Closed trades", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(stats, 1, 8, str.tostring(totalTrades), bgcolor=color.new(color.blue, 80), text_color=color.white)

    table.cell(stats, 0, 9, "Wins / losses / BE", bgcolor=color.new(color.purple, 72), text_color=color.white)
    table.cell(stats, 1, 9, str.tostring(wins) + " / " + str.tostring(losses) + " / " + str.tostring(breakevens), bgcolor=color.new(color.purple, 72), text_color=color.white)

    table.cell(stats, 0, 10, "4 PM exits", bgcolor=color.new(color.orange, 70), text_color=color.white)
    table.cell(stats, 1, 10, str.tostring(forcedExits), bgcolor=color.new(color.orange, 70), text_color=color.white)

    table.cell(stats, 0, 11, "Win rate", bgcolor=color.new(color.purple, 72), text_color=color.white)
    table.cell(stats, 1, 11, winRateText, bgcolor=color.new(color.purple, 72), text_color=color.white)

    table.cell(stats, 0, 12, "Profit factor", bgcolor=color.new(color.teal, 70), text_color=color.white)
    table.cell(stats, 1, 12, profitFactorText, bgcolor=color.new(color.teal, 70), text_color=color.white)

    table.cell(stats, 0, 13, "Net R", bgcolor=netR >= 0 ? color.new(color.green, 68) : color.new(color.red, 68), text_color=color.white)
    table.cell(stats, 1, 13, str.tostring(netR, "#.##") + "R", bgcolor=netR >= 0 ? color.new(color.green, 68) : color.new(color.red, 68), text_color=color.white)

    table.cell(stats, 0, 14, "Net P/L", bgcolor=netDollarProfit >= 0 ? color.new(color.green, 68) : color.new(color.red, 68), text_color=color.white)
    table.cell(stats, 1, 14, dollarProfitText, bgcolor=netDollarProfit >= 0 ? color.new(color.green, 68) : color.new(color.red, 68), text_color=color.white)

    for row = 0 to 14
        table.cell_set_text_size(stats, 0, row, size.tiny)
        table.cell_set_text_size(stats, 1, row, size.tiny)
````
