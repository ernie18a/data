<!-- tradingview-pine-id: PUB;537304b741f54069a03c3e96c248d610 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FVG Precision | Exact Labels | 2R | Webhook

Source: https://www.tradingview.com/script/O0kOwA7W-FVG-Precision-Exact-Labels-2R-Webhook/

## Description

FVG Precision | Exact Labels | 2R | Webhook is a Fair Value Gap (FVG) trading indicator designed to identify structured bullish and bearish FVG setups, wait for price to return into the imbalance, confirm rejection, and then display a complete trade setup with entry, stop loss, take profit, and trade direction.

HOW THE INDICATOR WORKS

The indicator looks for bullish and bearish Fair Value Gaps created by strong price displacement.

A bullish FVG is detected when price creates an upside imbalance between candles.

A bearish FVG is detected when price creates a downside imbalance between candles.

The script uses ATR-based filters to reduce very small or weak gaps and also checks for displacement strength before accepting an FVG.

After an FVG is identified, the indicator waits for price to return and fully fill the qualifying area.

When rejection confirmation is enabled, a trade signal is not generated simply because price touches the FVG. Price must fill the zone and then show confirmation back in the expected direction.

For bullish setups, the script looks for bullish rejection and a close back through the required portion of the FVG.

For bearish setups, the script looks for bearish rejection and a close back through the required portion of the FVG.

This helps filter out many simple touches that do not produce a confirmed reaction.

ENTRY

Once all conditions are satisfied, the indicator creates either a BUY or SELL signal.

The official entry price is based on the closing price of the candle that confirms the setup.

The indicator displays:

• BUY or SELL direction
• Exact entry price
• Signal time in Eastern Time
• Active entry FVG
• Stop Loss
• Take Profit
• Current trade status

STOP LOSS

Stops are structure-based rather than using an arbitrary fixed distance.

For BUY setups, the stop is placed below the most recently confirmed swing low, including the selected stop buffer.

For SELL setups, the stop is placed above the most recently confirmed swing high.

This allows the risk level to adapt to the current market structure.

TAKE PROFIT

The default take-profit target uses a 1:2 risk-to-reward ratio.

This means:

Risk = 1R
Target = 2R

For example:

If the distance between entry and stop loss is 5 points, the take-profit target is positioned approximately 10 points from the entry in the profitable direction.

The 2R level is automatically calculated for every qualifying setup.

ONE ACTIVE TRADE AT A TIME

The indicator is intentionally designed to manage only one active signal at a time.

While a BUY or SELL setup is active, the indicator will not issue another new trade signal.

A new setup becomes eligible after the current trade ends through:

• Take Profit
• Stop Loss
• FVG invalidation
• Weekend reset

This design helps prevent conflicting BUY and SELL signals from being active simultaneously.

ACTIVE FVG INVALIDATION

The original FVG remains part of the trade-management logic.

If price closes through the active FVG in the invalid direction before the trade completes, the indicator can classify the setup as:

FVG BROKEN

The active setup is then cancelled.

TRADING SESSION

Signals are restricted to the futures trading window used by this indicator:

Sunday 6:00 PM ET
through
Friday 4:00 PM ET

Saturday is disabled.

A weekend reset occurs Friday at 4:00 PM Eastern Time.

SUPPORTED CHART TIMEFRAMES

The indicator can visually operate on:

• 1 Minute
• 5 Minute
• 15 Minute
• 30 Minute

RECOMMENDED / PRIMARY TIMEFRAME: 15 MINUTES

The 15-minute timeframe is the primary timeframe this version is designed to be used with.

Compared with the lower timeframes, the 15-minute chart generally provides a cleaner view of market structure and reduces the amount of short-term price noise seen on very small candles.

IMPORTANT WEBHOOK RULE:

Only signals generated on the 15-minute timeframe are permitted to send trade-copier webhook events.

1 Minute:
Indicator can display setups, but website webhook transmission is OFF.

5 Minute:
Indicator can display setups, but website webhook transmission is OFF.

15 Minute:
Indicator displays setups AND webhook transmission is ON.

30 Minute:
Indicator can display setups, but website webhook transmission is OFF.

This restriction was intentionally added so an external trade copier or automation system receives only the selected 15-minute signals rather than signals from multiple chart timeframes.

WEBHOOK / AUTOMATION SUPPORT

The indicator contains machine-readable webhook functionality for integration with an external trade-management or trade-copying application.

Supported webhook lifecycle events include:

• ENTRY
• TP_HIT
• SL_HIT
• FVG_BROKEN
• WEEKEND_RESET

Every new trade receives a unique signal ID.

That same signal ID follows the trade throughout its lifecycle so an external application can associate subsequent events with the correct original signal.

ENTRY webhook data can include:

• Unique Signal ID
• Symbol
• TradingView Symbol
• BUY / SELL direction
• Timeframe
• Signal timestamp
• Entry price
• Stop Loss
• Take Profit
• Risk/Reward

This provides a structured foundation for webhook-based alerts and external automation.

BENEFITS

The purpose of FVG Precision is to make Fair Value Gap trading more structured and easier to interpret.

Key benefits include:

• Automatically identifies qualifying bullish and bearish FVGs
• Uses displacement and ATR filters to reduce weak setups
• Waits for FVG interaction instead of signaling immediately
• Optional rejection confirmation helps filter simple touches
• Automatically identifies BUY and SELL opportunities
• Displays exact entry prices
• Automatically calculates structure-based stop losses
• Automatically calculates a 2R profit target
• Displays the active FVG visually
• Prevents multiple active signals at the same time
• Provides FVG invalidation logic
• Restricts signals to the selected trading session
• Provides BUY, SELL, TP, SL and FVG Broken alerts
• Supports structured webhook integration
• Restricts automated webhook transmission to the preferred 15-minute timeframe

IMPORTANT

This indicator is a decision-support and automation tool. Signals are based on predefined technical conditions and do not guarantee profitable trades.

Historical or visually successful setups do not guarantee future results. Slippage, liquidity, market volatility, news events, execution quality, commissions, and other market conditions can materially affect actual results.

Users should test the indicator thoroughly and use appropriate risk management before using any signal for live trading.

---

## Source Code

````pine
//@version=6
indicator(
     "FVG Precision | Exact Labels | 2R | Webhook",
     shorttitle = "FVG Precision 2R",
     overlay = true,
     max_boxes_count = 20,
     max_lines_count = 20,
     max_labels_count = 100
)


//======================================================
// 1. FVG QUALITY
//======================================================

groupFVG = "FVG Quality"

minGapATR = input.float(
     0.10,
     "Minimum FVG Size (ATR)",
     minval = 0.0,
     step = 0.05,
     group = groupFVG
)

minBodyATR = input.float(
     0.35,
     "Minimum Displacement Body (ATR)",
     minval = 0.0,
     step = 0.05,
     group = groupFVG
)

requireRejection = input.bool(
     true,
     "Require Rejection After Full Fill",
     group = groupFVG
)

requireCloseBackMid = input.bool(
     true,
     "Require Close Back Through FVG Midpoint",
     group = groupFVG
)

maxFVGAge = input.int(
     60,
     "Maximum Waiting FVG Age",
     minval = 3,
     group = groupFVG
)


//======================================================
// 2. RISK / REWARD
//======================================================

groupRisk = "Risk / Reward"

rewardMultiple = input.float(
     2.0,
     "Take Profit R Multiple",
     minval = 0.5,
     step = 0.25,
     group = groupRisk
)

stopBufferTicks = input.int(
     1,
     "Stop Buffer Ticks",
     minval = 0,
     group = groupRisk
)


//======================================================
// 3. SWING SETTINGS
//======================================================

groupSwing = "Swing Structure"

swingLeft = input.int(
     3,
     "Swing Left",
     minval = 1,
     group = groupSwing
)

swingRight = input.int(
     3,
     "Swing Right",
     minval = 1,
     group = groupSwing
)


//======================================================
// 4. DISPLAY
//======================================================

groupDisplay = "Display"

signalBarsRight = input.int(
     2,
     "BUY / SELL Signal Bars To Right",
     minval = 0,
     maxval = 10,
     group = groupDisplay
)

signalOffsetATR = input.float(
     0.50,
     "BUY / SELL Distance From Candle (ATR)",
     minval = 0.05,
     step = 0.05,
     group = groupDisplay
)


//======================================================
// 5. NOTIFICATIONS / WEBHOOK
//======================================================

groupAlerts = "Notifications"

enableBuyNotifications = input.bool(
     true,
     "Enable BUY Signal Alerts",
     group = groupAlerts
)

enableSellNotifications = input.bool(
     true,
     "Enable SELL Signal Alerts",
     group = groupAlerts
)

enableTPNotifications = input.bool(
     true,
     "Enable Take Profit 2R Alerts",
     group = groupAlerts
)

enableSLNotifications = input.bool(
     true,
     "Enable Stop Loss Alerts",
     group = groupAlerts
)

enableFVGBrokenNotifications = input.bool(
     true,
     "Enable Active FVG Broken Alerts",
     group = groupAlerts
)

enableWebhookEvents = input.bool(
     true,
     "Enable Trade Copier Webhook Events",
     group = groupAlerts
)


//======================================================
// 6. SESSION / WEEK
//======================================================

groupSession = "Trading Session"

tradeSession = input.session(
     "1800-1600",
     "Trading Window",
     group = groupSession
)

sessionTimezone = "America/New_York"

inDailySession =
     not na(
         time(
             timeframe.period,
             tradeSession,
             sessionTimezone
         )
     )

nyDay =
     dayofweek(
         time,
         sessionTimezone
     )

nyHour =
     hour(
         time,
         sessionTimezone
     )

nyMinute =
     minute(
         time,
         sessionTimezone
     )


//======================================================
// WEEKLY TRADING WINDOW
// Sunday >= 6 PM
// Monday-Thursday allowed
// Friday until 4 PM
// Saturday disabled
//======================================================

isSunday =
     nyDay == dayofweek.sunday

isMonday =
     nyDay == dayofweek.monday

isTuesday =
     nyDay == dayofweek.tuesday

isWednesday =
     nyDay == dayofweek.wednesday

isThursday =
     nyDay == dayofweek.thursday

isFriday =
     nyDay == dayofweek.friday

isSaturday =
     nyDay == dayofweek.saturday


sundayAllowed =
     isSunday and
     nyHour >= 18

weekdayAllowed =
     isMonday or
     isTuesday or
     isWednesday or
     isThursday

fridayAllowed =
     isFriday and
     nyHour < 16


inTradingWeek =
     sundayAllowed or
     weekdayAllowed or
     fridayAllowed


allowNewSignal =
     inDailySession and
     inTradingWeek


//======================================================
// 7. FRIDAY 4 PM WEEKEND RESET
//======================================================

weekendReset =
     isFriday and
     nyHour == 16 and
     nyMinute == 0


//======================================================
// 8. TIME HELPERS
//======================================================

f_signalTime() =>
    str.format_time(
         time_close,
         "hh:mm:ss a",
         sessionTimezone
    )

f_signalDate() =>
    str.format_time(
         time_close,
         "MM/dd/yyyy",
         sessionTimezone
    )


//======================================================
// 9. TIMEFRAME CONTROL
//======================================================

validTF =
     timeframe.isminutes and
     (
         timeframe.multiplier == 1 or
         timeframe.multiplier == 5 or
         timeframe.multiplier == 15 or
         timeframe.multiplier == 30
     )

tfName =
     timeframe.multiplier == 1 ? "1M" :
     timeframe.multiplier == 5 ? "5M" :
     timeframe.multiplier == 15 ? "15M" :
     timeframe.multiplier == 30 ? "30M" :
     "INVALID"


//======================================================
// 9A. WEBSITE / WEBHOOK TIMEFRAME
// ONLY 15-MINUTE SIGNALS GO TO WEBSITE
//======================================================

websiteTF15M =
     timeframe.isminutes and
     timeframe.multiplier == 15


//======================================================
// 10. TRADE STATE
//======================================================

var int positionState = 0

// 0  = Flat
// 1  = Long
// -1 = Short

var float tradeEntry = na
var float tradeStop = na
var float tradeTarget = na
var float tradeRisk = na

var int tradeEntryBar = na

var string activeSignalId = ""
var string activeSignalSide = ""

var line entryLine = na
var line stopLine = na
var line targetLine = na

var label entryLabel = na
var label stopLabel = na
var label targetLabel = na
var label activeFVGLabel = na
var label lastExitLabel = na

var box activeTradeFVGBox = na

var float activeFVGTop = na
var float activeFVGBottom = na

bool buySignal = false
bool sellSignal = false
bool tpSignal = false
bool slSignal = false
bool fvgBrokenSignal = false


//======================================================
// 11. ATR / DISPLACEMENT
//======================================================

atr = ta.atr(14)

middleBody =
     math.abs(
         close[1] - open[1]
     )

strongDisplacement =
     middleBody >= atr[1] * minBodyATR


//======================================================
// 12. WEBHOOK FUNCTIONS
//======================================================

f_buildSignalId(string side) =>
    string result = syminfo.ticker
    result := result + "-"
    result := result + timeframe.period
    result := result + "-"
    result := result + str.tostring(time_close)
    result := result + "-"
    result := result + side
    result


f_entryWebhook(
     string signalId,
     string side,
     float entryPrice,
     float stopPrice,
     float targetPrice
     ) =>

    string msg = "{\"schema_version\":1"
    msg := msg + ",\"event_type\":\"ENTRY\""
    msg := msg + ",\"signal_id\":\"" + signalId + "\""
    msg := msg + ",\"source\":\"FVG_INDICATOR\""
    msg := msg + ",\"symbol\":\"" + syminfo.root + "\""
    msg := msg + ",\"tradingview_symbol\":\"" + syminfo.ticker + "\""
    msg := msg + ",\"side\":\"" + side + "\""
    msg := msg + ",\"timeframe\":\"" + timeframe.period + "\""
    msg := msg + ",\"signal_time\":" + str.tostring(time_close)
    msg := msg + ",\"entry\":" + str.tostring(entryPrice, format.mintick)
    msg := msg + ",\"stop_loss\":" + str.tostring(stopPrice, format.mintick)
    msg := msg + ",\"take_profit\":" + str.tostring(targetPrice, format.mintick)
    msg := msg + ",\"risk_reward\":2"
    msg := msg + "}"
    msg


f_exitWebhook(
     string eventType,
     string signalId,
     string side,
     float entryPrice,
     float stopPrice,
     float targetPrice,
     float exitPrice
     ) =>

    string msg = "{\"schema_version\":1"
    msg := msg + ",\"event_type\":\"" + eventType + "\""
    msg := msg + ",\"signal_id\":\"" + signalId + "\""
    msg := msg + ",\"source\":\"FVG_INDICATOR\""
    msg := msg + ",\"symbol\":\"" + syminfo.root + "\""
    msg := msg + ",\"tradingview_symbol\":\"" + syminfo.ticker + "\""
    msg := msg + ",\"side\":\"" + side + "\""
    msg := msg + ",\"timeframe\":\"" + timeframe.period + "\""
    msg := msg + ",\"signal_time\":" + str.tostring(time_close)
    msg := msg + ",\"entry\":" + str.tostring(entryPrice, format.mintick)
    msg := msg + ",\"stop_loss\":" + str.tostring(stopPrice, format.mintick)
    msg := msg + ",\"take_profit\":" + str.tostring(targetPrice, format.mintick)
    msg := msg + ",\"exit_price\":" + str.tostring(exitPrice, format.mintick)
    msg := msg + ",\"risk_reward\":2"
    msg := msg + "}"
    msg


//======================================================
// 13. FVG DETECTION
//======================================================

rawBullFVG =
     validTF and
     allowNewSignal and
     positionState == 0 and
     low > high[2]

bullGap =
     low - high[2]

newBullFVG =
     rawBullFVG and
     bullGap >= atr * minGapATR and
     strongDisplacement


rawBearFVG =
     validTF and
     allowNewSignal and
     positionState == 0 and
     high < low[2]

bearGap =
     low[2] - high

newBearFVG =
     rawBearFVG and
     bearGap >= atr * minGapATR and
     strongDisplacement


//======================================================
// 14. WAITING FVG STATE
//======================================================

var float bullTop = na
var float bullBottom = na
var float bullMid = na
var int bullBorn = na
var bool bullActive = false
var bool bullFilled = false
var box bullBox = na

var float bearTop = na
var float bearBottom = na
var float bearMid = na
var int bearBorn = na
var bool bearActive = false
var bool bearFilled = false
var box bearBox = na


//======================================================
// 15. CREATE BULLISH FVG
//======================================================

if newBullFVG

    if not na(bullBox)
        box.delete(bullBox)

    bullBox := na

    bullTop := low
    bullBottom := high[2]
    bullMid := (bullTop + bullBottom) / 2.0

    bullBorn := bar_index

    bullActive := true
    bullFilled := false

    bullBox :=
         box.new(
             left = bar_index - 2,
             top = bullTop,
             right = bar_index,
             bottom = bullBottom,
             extend = extend.right,
             border_color = color.aqua,
             bgcolor = color.new(color.aqua, 86)
         )


//======================================================
// 16. CREATE BEARISH FVG
//======================================================

if newBearFVG

    if not na(bearBox)
        box.delete(bearBox)

    bearBox := na

    bearTop := low[2]
    bearBottom := high
    bearMid := (bearTop + bearBottom) / 2.0

    bearBorn := bar_index

    bearActive := true
    bearFilled := false

    bearBox :=
         box.new(
             left = bar_index - 2,
             top = bearTop,
             right = bar_index,
             bottom = bearBottom,
             extend = extend.right,
             border_color = color.red,
             bgcolor = color.new(color.red, 86)
         )


//======================================================
// 17. WAITING FVG EXPIRATION
//======================================================

if bullActive and
   bar_index - bullBorn > maxFVGAge

    bullActive := false
    bullFilled := false

    if not na(bullBox)
        box.delete(bullBox)

    bullBox := na


if bearActive and
   bar_index - bearBorn > maxFVGAge

    bearActive := false
    bearFilled := false

    if not na(bearBox)
        box.delete(bearBox)

    bearBox := na


//======================================================
// 18. FULL FILL
//======================================================

if bullActive and
   bar_index > bullBorn and
   low <= bullBottom

    bullFilled := true


if bearActive and
   bar_index > bearBorn and
   high >= bearTop

    bearFilled := true


//======================================================
// 19. REJECTION
//======================================================

bullRejection =
     bullFilled and
     close > open and
     close > bullBottom

if requireCloseBackMid

    bullRejection :=
         bullRejection and
         close > bullMid


bearRejection =
     bearFilled and
     close < open and
     close < bearTop

if requireCloseBackMid

    bearRejection :=
         bearRejection and
         close < bearMid


bullTrigger =
     requireRejection ?
     bullRejection :
     bullFilled


bearTrigger =
     requireRejection ?
     bearRejection :
     bearFilled


//======================================================
// 20. SWING DETECTION
//======================================================

pivotHigh =
     ta.pivothigh(
         high,
         swingLeft,
         swingRight
     )

pivotLow =
     ta.pivotlow(
         low,
         swingLeft,
         swingRight
     )

var float[] swingHighs =
     array.new_float()

var float[] swingLows =
     array.new_float()


if not na(pivotHigh)

    array.push(
         swingHighs,
         pivotHigh
     )

    if array.size(swingHighs) > 200
        array.shift(swingHighs)


if not na(pivotLow)

    array.push(
         swingLows,
         pivotLow
     )

    if array.size(swingLows) > 200
        array.shift(swingLows)


//======================================================
// 21. LAST SWING FUNCTIONS
//======================================================

f_lastSwingLow() =>

    float result = na

    count =
         array.size(
             swingLows
         )

    if count > 0
        result :=
             array.get(
                 swingLows,
                 count - 1
             )

    result


f_lastSwingHigh() =>

    float result = na

    count =
         array.size(
             swingHighs
         )

    if count > 0
        result :=
             array.get(
                 swingHighs,
                 count - 1
             )

    result


//======================================================
// 22. CLEAR ACTIVE TRADE DISPLAY
//======================================================

f_clearTradeDisplay() =>

    if not na(entryLine)
        line.delete(entryLine)

    if not na(stopLine)
        line.delete(stopLine)

    if not na(targetLine)
        line.delete(targetLine)

    if not na(entryLabel)
        label.delete(entryLabel)

    if not na(stopLabel)
        label.delete(stopLabel)

    if not na(targetLabel)
        label.delete(targetLabel)

    if not na(activeFVGLabel)
        label.delete(activeFVGLabel)

    if not na(activeTradeFVGBox)
        box.delete(activeTradeFVGBox)


//======================================================
// 23. LONG ENTRY
//======================================================

if positionState == 0 and
   allowNewSignal and
   bullActive and
   bullTrigger

    candidateEntry =
         close

    lastSwing =
         f_lastSwingLow()

    candidateStop =
         not na(lastSwing) ?
         lastSwing -
         syminfo.mintick *
         stopBufferTicks :
         na

    candidateRisk =
         not na(candidateStop) ?
         candidateEntry -
         candidateStop :
         na

    candidateTarget =
         not na(candidateRisk) ?
         candidateEntry +
         candidateRisk *
         rewardMultiple :
         na

    validLong =
         not na(candidateStop) and
         candidateStop < candidateEntry and
         candidateRisk > 0


    if validLong

        if not na(lastExitLabel)
            label.delete(lastExitLabel)

        f_clearTradeDisplay()

        positionState := 1

        tradeEntry := candidateEntry
        tradeStop := candidateStop
        tradeRisk := candidateRisk
        tradeTarget := candidateTarget
        tradeEntryBar := bar_index

        activeFVGTop := bullTop
        activeFVGBottom := bullBottom

        buySignal := true

        activeSignalSide := "BUY"
        activeSignalId := f_buildSignalId(activeSignalSide)

        buySignalTime =
             f_signalTime()

        buySignalDate =
             f_signalDate()


        activeTradeFVGBox :=
             box.new(
                 left = bullBorn - 2,
                 top = bullTop,
                 right = bar_index + 1,
                 bottom = bullBottom,
                 extend = extend.right,
                 border_color = color.aqua,
                 bgcolor = color.new(color.aqua, 78)
             )


        activeFVGLabel :=
             label.new(
                 bar_index,
                 bullMid,
                 "BULLISH ENTRY FVG - " + tfName,
                 style = label.style_label_left,
                 color = color.aqua,
                 textcolor = color.black
             )


        if not na(bullBox)
            box.delete(bullBox)

        if not na(bearBox)
            box.delete(bearBox)

        bullBox := na
        bearBox := na

        bullActive := false
        bearActive := false

        bullFilled := false
        bearFilled := false


        entryLine :=
             line.new(
                 bar_index,
                 tradeEntry,
                 bar_index + 1,
                 tradeEntry,
                 extend = extend.right,
                 color = color.aqua,
                 width = 2
             )


        buyLabelY =
             low -
             atr *
             signalOffsetATR


        entryLabel :=
             label.new(
                 bar_index + signalBarsRight,
                 buyLabelY,
                 "BUY\n" +
                 str.tostring(
                     tradeEntry,
                     format.mintick
                 ) +
                 "\n" +
                 buySignalTime +
                 " ET",
                 style = label.style_label_up,
                 color = color.lime,
                 textcolor = color.white,
                 size = size.small
             )


        stopLine :=
             line.new(
                 bar_index,
                 tradeStop,
                 bar_index + 1,
                 tradeStop,
                 extend = extend.right,
                 color = color.red,
                 width = 2,
                 style = line.style_dashed
             )


        stopLabel :=
             label.new(
                 bar_index,
                 tradeStop,
                 "STOP LOSS\n" +
                 str.tostring(
                     tradeStop,
                     format.mintick
                 ) +
                 "\nRISK = 1R",
                 style = label.style_label_up,
                 color = color.red,
                 textcolor = color.white
             )


        targetLine :=
             line.new(
                 bar_index,
                 tradeTarget,
                 bar_index + 1,
                 tradeTarget,
                 extend = extend.right,
                 color = color.lime,
                 width = 2,
                 style = line.style_dashed
             )


        targetLabel :=
             label.new(
                 bar_index,
                 tradeTarget,
                 "TAKE PROFIT 2R\n" +
                 str.tostring(
                     tradeTarget,
                     format.mintick
                 ) +
                 "\nREWARD = 2R",
                 style = label.style_label_down,
                 color = color.lime,
                 textcolor = color.white
             )


        // ONLY 15-MINUTE SIGNALS ARE SENT TO WEBSITE
        if enableWebhookEvents and websiteTF15M

            alert(
                 f_entryWebhook(
                     activeSignalId,
                     activeSignalSide,
                     tradeEntry,
                     tradeStop,
                     tradeTarget
                 ),
                 alert.freq_once_per_bar_close
             )


//======================================================
// 24. SHORT ENTRY
//======================================================

if positionState == 0 and
   allowNewSignal and
   bearActive and
   bearTrigger

    candidateEntry =
         close

    lastSwing =
         f_lastSwingHigh()

    candidateStop =
         not na(lastSwing) ?
         lastSwing +
         syminfo.mintick *
         stopBufferTicks :
         na

    candidateRisk =
         not na(candidateStop) ?
         candidateStop -
         candidateEntry :
         na

    candidateTarget =
         not na(candidateRisk) ?
         candidateEntry -
         candidateRisk *
         rewardMultiple :
         na

    validShort =
         not na(candidateStop) and
         candidateStop > candidateEntry and
         candidateRisk > 0


    if validShort

        if not na(lastExitLabel)
            label.delete(lastExitLabel)

        f_clearTradeDisplay()

        positionState := -1

        tradeEntry := candidateEntry
        tradeStop := candidateStop
        tradeRisk := candidateRisk
        tradeTarget := candidateTarget
        tradeEntryBar := bar_index

        activeFVGTop := bearTop
        activeFVGBottom := bearBottom

        sellSignal := true

        activeSignalSide := "SELL"
        activeSignalId := f_buildSignalId(activeSignalSide)

        sellSignalTime =
             f_signalTime()

        sellSignalDate =
             f_signalDate()


        activeTradeFVGBox :=
             box.new(
                 left = bearBorn - 2,
                 top = bearTop,
                 right = bar_index + 1,
                 bottom = bearBottom,
                 extend = extend.right,
                 border_color = color.red,
                 bgcolor = color.new(color.red, 78)
             )


        activeFVGLabel :=
             label.new(
                 bar_index,
                 bearMid,
                 "BEARISH ENTRY FVG - " + tfName,
                 style = label.style_label_left,
                 color = color.red,
                 textcolor = color.white
             )


        if not na(bullBox)
            box.delete(bullBox)

        if not na(bearBox)
            box.delete(bearBox)

        bullBox := na
        bearBox := na

        bullActive := false
        bearActive := false

        bullFilled := false
        bearFilled := false


        entryLine :=
             line.new(
                 bar_index,
                 tradeEntry,
                 bar_index + 1,
                 tradeEntry,
                 extend = extend.right,
                 color = color.aqua,
                 width = 2
             )


        sellLabelY =
             high +
             atr *
             signalOffsetATR


        entryLabel :=
             label.new(
                 bar_index + signalBarsRight,
                 sellLabelY,
                 "SELL\n" +
                 str.tostring(
                     tradeEntry,
                     format.mintick
                 ) +
                 "\n" +
                 sellSignalTime +
                 " ET",
                 style = label.style_label_down,
                 color = color.red,
                 textcolor = color.white,
                 size = size.small
             )


        stopLine :=
             line.new(
                 bar_index,
                 tradeStop,
                 bar_index + 1,
                 tradeStop,
                 extend = extend.right,
                 color = color.red,
                 width = 2,
                 style = line.style_dashed
             )


        stopLabel :=
             label.new(
                 bar_index,
                 tradeStop,
                 "STOP LOSS\n" +
                 str.tostring(
                     tradeStop,
                     format.mintick
                 ) +
                 "\nRISK = 1R",
                 style = label.style_label_down,
                 color = color.red,
                 textcolor = color.white
             )


        targetLine :=
             line.new(
                 bar_index,
                 tradeTarget,
                 bar_index + 1,
                 tradeTarget,
                 extend = extend.right,
                 color = color.lime,
                 width = 2,
                 style = line.style_dashed
             )


        targetLabel :=
             label.new(
                 bar_index,
                 tradeTarget,
                 "TAKE PROFIT 2R\n" +
                 str.tostring(
                     tradeTarget,
                     format.mintick
                 ) +
                 "\nREWARD = 2R",
                 style = label.style_label_up,
                 color = color.lime,
                 textcolor = color.white
             )


        // ONLY 15-MINUTE SIGNALS ARE SENT TO WEBSITE
        if enableWebhookEvents and websiteTF15M

            alert(
                 f_entryWebhook(
                     activeSignalId,
                     activeSignalSide,
                     tradeEntry,
                     tradeStop,
                     tradeTarget
                 ),
                 alert.freq_once_per_bar_close
             )


//======================================================
// 25. ACTIVE FVG INVALIDATION
//======================================================

bullFVGBroken =
     positionState == 1 and
     bar_index > tradeEntryBar and
     not na(activeFVGBottom) and
     close < activeFVGBottom


bearFVGBroken =
     positionState == -1 and
     bar_index > tradeEntryBar and
     not na(activeFVGTop) and
     close > activeFVGTop


if bullFVGBroken or
   bearFVGBroken

    fvgBrokenSignal := true
    positionState := 0


//======================================================
// 26. TP / SL MANAGEMENT
//======================================================

if positionState == 1 and
   bar_index > tradeEntryBar

    stopHit =
         low <= tradeStop

    targetHit =
         high >= tradeTarget


    if stopHit

        slSignal := true
        positionState := 0

    else if targetHit

        tpSignal := true
        positionState := 0


if positionState == -1 and
   bar_index > tradeEntryBar

    stopHit =
         high >= tradeStop

    targetHit =
         low <= tradeTarget


    if stopHit

        slSignal := true
        positionState := 0

    else if targetHit

        tpSignal := true
        positionState := 0


//======================================================
// 27. HANDLE TRADE EXIT / INVALIDATION
//======================================================

if tpSignal or
   slSignal or
   fvgBrokenSignal

    float exitPrice = na

    if tpSignal
        exitPrice := tradeTarget

    else if slSignal
        exitPrice := tradeStop

    else
        exitPrice := close


    // ONLY 15-MINUTE EXIT EVENTS ARE SENT TO WEBSITE
    if enableWebhookEvents and
       websiteTF15M and
       activeSignalId != ""

        exitEventType =
             tpSignal ?
             "TP_HIT" :
             slSignal ?
             "SL_HIT" :
             "FVG_BROKEN"

        alert(
             f_exitWebhook(
                 exitEventType,
                 activeSignalId,
                 activeSignalSide,
                 tradeEntry,
                 tradeStop,
                 tradeTarget,
                 exitPrice
             ),
             alert.freq_once_per_bar_close
        )


    f_clearTradeDisplay()


    entryLine := na
    stopLine := na
    targetLine := na

    entryLabel := na
    stopLabel := na
    targetLabel := na

    activeFVGLabel := na
    activeTradeFVGBox := na


    if not na(lastExitLabel)
        label.delete(lastExitLabel)


    lastExitLabel :=
         label.new(
             bar_index,
             exitPrice,
             tpSignal ?
             "TAKE PROFIT HIT\n+2R" :
             slSignal ?
             "STOP LOSS HIT\n-1R" :
             "FVG BROKEN\nSIGNAL CANCELLED",
             style =
                 tpSignal ?
                 label.style_label_down :
                 label.style_label_up,
             color =
                 tpSignal ?
                 color.lime :
                 color.red,
             textcolor = color.white,
             size = size.small
         )


    tradeEntry := na
    tradeStop := na
    tradeTarget := na
    tradeRisk := na
    tradeEntryBar := na

    activeFVGTop := na
    activeFVGBottom := na

    activeSignalId := ""
    activeSignalSide := ""


//======================================================
// 28. WEEKEND RESET
//======================================================

if weekendReset

    // ONLY 15-MINUTE WEEKEND RESET IS SENT TO WEBSITE
    if enableWebhookEvents and
       websiteTF15M and
       positionState != 0 and
       activeSignalId != ""

        alert(
             f_exitWebhook(
                 "WEEKEND_RESET",
                 activeSignalId,
                 activeSignalSide,
                 tradeEntry,
                 tradeStop,
                 tradeTarget,
                 close
             ),
             alert.freq_once_per_bar_close
        )


    positionState := 0

    bullActive := false
    bearActive := false

    bullFilled := false
    bearFilled := false


    if not na(bullBox)
        box.delete(bullBox)

    if not na(bearBox)
        box.delete(bearBox)


    bullBox := na
    bearBox := na


    f_clearTradeDisplay()


    entryLine := na
    stopLine := na
    targetLine := na

    entryLabel := na
    stopLabel := na
    targetLabel := na

    activeFVGLabel := na
    activeTradeFVGBox := na


    if not na(lastExitLabel)
        label.delete(lastExitLabel)

    lastExitLabel := na


    tradeEntry := na
    tradeStop := na
    tradeTarget := na
    tradeRisk := na
    tradeEntryBar := na

    activeFVGTop := na
    activeFVGBottom := na

    activeSignalId := ""
    activeSignalSide := ""


//======================================================
// 29. STATUS TABLE
//======================================================

var table status =
     table.new(
         position.top_right,
         1,
         1
     )


if barstate.islast

    if validTF

        statusText =
             positionState == 1 ?
             "LONG ACTIVE\nTP = 2R\n" + tfName :
             positionState == -1 ?
             "SHORT ACTIVE\nTP = 2R\n" + tfName :
             "WAITING FOR FVG\n" + tfName


        websiteStatus =
             websiteTF15M ?
             "\nWEBHOOK: ON (15M)" :
             "\nWEBHOOK: OFF"


        table.cell(
             status,
             0,
             0,
             statusText +
             websiteStatus +
             "\nSUN 6PM - FRI 4PM ET",
             bgcolor =
                 positionState == 1 ?
                 color.new(
                     color.green,
                     55
                 ) :
                 positionState == -1 ?
                 color.new(
                     color.red,
                     55
                 ) :
                 color.new(
                     color.black,
                     45
                 ),
             text_color = color.white
         )


    else

        table.cell(
             status,
             0,
             0,
             "USE 1M / 5M / 15M / 30M",
             bgcolor = color.red,
             text_color = color.white
         )


//======================================================
// 30. ALERT CONDITIONS
//======================================================

alertcondition(
     buySignal and
     enableBuyNotifications,
     title = "NEW FVG BUY",
     message = "New bullish FVG BUY signal. Webhook event generated only on 15M."
)

alertcondition(
     sellSignal and
     enableSellNotifications,
     title = "NEW FVG SELL",
     message = "New bearish FVG SELL signal. Webhook event generated only on 15M."
)

alertcondition(
     tpSignal and
     enableTPNotifications,
     title = "TAKE PROFIT 2R HIT",
     message = "FVG trade reached its 2R take-profit target."
)

alertcondition(
     slSignal and
     enableSLNotifications,
     title = "STOP LOSS HIT",
     message = "FVG trade reached its swing-based stop loss."
)

alertcondition(
     fvgBrokenSignal and
     enableFVGBrokenNotifications,
     title = "ACTIVE FVG BROKEN",
     message = "The active entry FVG was invalidated."
)
````
