# Turtle Path TP/SL Visual Alerts [Golden_WolfAI]

- url: https://www.tradingview.com/script/CzX9aWg7-turtle-path-tp-sl-visual-alerts-golden-wolfai/
- type: indicator
- pine_id: PUB;cbdca7d67b0c4bdba6ef4e8eb2c8cca5
- version: 1.0

## Description

Turtle TP/SL Visual Alerts

Turtle TP/SL Visual Alerts is a visual trading indicator based on the classic Donchian Channel breakout concept used in Turtle-style trading systems.

The indicator identifies potential breakout entries, tracks a single simulated position at a time, calculates configurable Take Profit and Stop Loss levels, supports channel-based exits, displays trade levels directly on the chart, and provides alert events for entries and exits.

The script is designed primarily as a visual decision-support and signal-tracking tool. It does not place orders automatically.

How It Works

The indicator uses two Donchian Channels:

Entry Channel — identifies breakout conditions for potential BUY or SELL entries.

Exit Channel — provides an optional Turtle-style channel exit for an active position.

The current signal candle is excluded from the Donchian calculation. This prevents the current bar from expanding the channel that it is attempting to break.

For example, with a 20-bar entry period, the current upper entry boundary is calculated from the highest price of the previous 20 completed bars.

Entry Logic

A BUY signal can occur when price breaks above the upper Entry Channel.

A SELL signal can occur when price breaks below the lower Entry Channel.

The script provides two breakout confirmation modes.

Close Confirmation

When Confirm breakout by candle close is enabled:

BUY requires the candle to close above the upper Entry Channel.

SELL requires the candle to close below the lower Entry Channel.

This mode waits for confirmation at the candle close.

High / Low Breakout

When close confirmation is disabled:

BUY can trigger when the candle high moves above the upper Entry Channel.

SELL can trigger when the candle low moves below the lower Entry Channel.

This provides more responsive breakout detection.

Signal Bar Mode

The indicator allows two signal-processing modes:

Closed candle

Signals are confirmed only after the candle closes.

Current candle

Signals may be evaluated while the current realtime candle is still forming.

Users should be aware that conditions on an unfinished candle can change before the candle closes.

Take Profit and Stop Loss

After an entry is detected, the indicator calculates fixed Take Profit and Stop Loss levels using the configured number of price points.

For a BUY position:

Take Profit is placed above the entry price.

Stop Loss is placed below the entry price.

For a SELL position:

Take Profit is placed below the entry price.

Stop Loss is placed above the entry price.

The Entry, TP and SL levels are displayed directly on the chart.

Same-Bar TP / SL Handling

On historical OHLC data, TradingView does not provide the exact intrabar sequence of price movement unless lower-timeframe data is explicitly used.

Therefore, it is possible for both the Take Profit and Stop Loss levels to fall inside the range of the same candle.

The setting:

If TP and SL hit on same candle: SL first

controls how this situation is handled.

When enabled, the indicator uses the conservative assumption that the Stop Loss was reached first.

When disabled, Take Profit is assumed to have been reached first.

This setting only resolves ambiguous candles where both levels were touched.

Turtle Channel Exit

In addition to fixed TP and SL levels, the indicator can optionally close the simulated position using the Exit Donchian Channel.

For a BUY position, an exit can occur when price breaks below the lower Exit Channel.

For a SELL position, an exit can occur when price breaks above the upper Exit Channel.

The channel exit can also be configured to require candle-close confirmation.

This allows users to combine fixed risk-management levels with traditional Turtle-style exit logic.

Visual Elements

The indicator can display:

Upper and lower Entry Donchian Channels

Upper and lower Exit Donchian Channels

BUY entry arrows

SELL entry arrows

Entry price levels

Take Profit levels

Stop Loss levels

Trade price labels

Historical trade levels

Current active-trade levels

Colors, line style, line width and label size can be customized from the indicator settings.

Information Table

An optional information panel is displayed in the upper-right corner of the chart.

The table provides a quick overview of the current indicator state, including:

Symbol and chart timeframe

Current simulated position

Entry price

Take Profit price

Stop Loss price

Current Entry Channel values

Current Exit Channel values

Most recent signal or exit event

Event time

Entry and Exit Donchian periods

Configured TP and SL distances

When no trade is currently active, the position is displayed as FLAT.

Visual History

The Visual history bars setting controls how much historical trade visualization is retained on the chart.

A value of:

0

displays all available visual history within TradingView's object limits.

A positive value limits historical trade objects to approximately the selected number of recent bars.

This can help reduce chart clutter when working with long histories.

Alerts

The indicator supports alert events for:

ENTRY

Take Profit

Stop Loss

Turtle Channel Exit

Alerts include information such as:

Event type

Symbol

Timeframe

BUY or SELL direction

Event time

Event price

Take Profit price

Stop Loss price

To use the dynamic alert messages, create a TradingView alert and select:

Turtle TP/SL Visual Alerts → Any alert() function call

Notification delivery options such as app notifications, popup, sound or other available methods are configured through TradingView's alert dialog.

Main Settings

Donchian Entry Period

Number of previous bars used to calculate the breakout channel.

Donchian Exit Period

Number of previous bars used to calculate the optional Turtle exit channel.

Take Profit, points

Distance between the entry price and Take Profit.

Stop Loss, points

Distance between the entry price and Stop Loss.

Use Turtle channel exit

Enables or disables channel-based exits.

Confirm breakout by candle close

Determines whether entry breakouts require a candle close beyond the channel.

Confirm channel exit by candle close

Determines whether Turtle exits require a candle close beyond the Exit Channel.

Signal bar mode

Controls whether the indicator operates on confirmed candles or the current realtime candle.

Same-candle TP/SL priority

Controls the assumed execution order when both TP and SL are inside the same candle range.

Important Notes

The indicator maintains one simulated position at a time.

Signals and trade levels are calculated from chart data and do not represent actual broker executions.

Fixed TP and SL values are specified in the instrument's minimum price increments. Their practical price distance therefore depends on the symbol being analyzed.

Historical results can differ from realtime behavior when conditions are evaluated on the current unfinished candle.

The script is an indicator and visualization tool. It is not a TradingView strategy and does not automatically execute trades.

Intended Use

Turtle TP/SL Visual Alerts can be used for:

Visualizing Donchian breakout structures

Monitoring Turtle-style entry conditions

Tracking predefined TP and SL levels

Testing different Donchian entry and exit periods visually

Creating breakout alerts

Reviewing historical breakout sequences

Supporting discretionary trade analysis

It can be applied to different markets and timeframes, but settings should be adjusted according to the instrument's volatility, tick size and trading characteristics.

Disclaimer

This indicator is provided for informational, analytical and educational purposes only.

It does not constitute financial, investment or trading advice. Signals generated by the indicator do not guarantee future results.

Trading and investing involve risk. Users are responsible for their own analysis, risk management and trading decisions.

© 2026 Golden_WolfAI. All rights reserved.

This Pine Script® code is proprietary and confidential.

Unauthorized copying, modification, redistribution, publication or commercial use is prohibited.

## Source Code

````pine
//@version=6
// This Pine Script® code is proprietary and confidential.
// Unauthorized copying, modification, redistribution, publication, or commercial use is prohibited.
//
// © 2026 Golden_WolfAI. All rights reserved.
indicator("Turtle TP/SL Visual Alerts", shorttitle = "Turtle TP/SL", overlay = true, max_lines_count = 100, max_labels_count = 500)

// ============================================================================
// Inputs
// ============================================================================
int entryPeriod = input.int(20, "Donchian Entry Period", minval = 2)
int exitPeriod = input.int(10, "Donchian Exit Period", minval = 2)
int takeProfitPoints = input.int(1000, "Take Profit, points", minval = 1)
int stopLossPoints = input.int(500, "Stop Loss, points", minval = 1)
bool useTurtleExit = input.bool(true, "Use Turtle channel exit")
bool confirmBreakoutByClose = input.bool(true, "Confirm breakout by candle close")
bool confirmExitByClose = input.bool(false, "Confirm channel exit by candle close")
string signalBarMode = input.string("Closed candle", "Signal bar mode", options = ["Closed candle", "Current candle"])
bool conservativeSameBar = input.bool(true, "If TP and SL hit on same candle: SL first")

bool showEntryChannel = input.bool(true, "Show entry channel")
bool showExitChannel = input.bool(true, "Show exit channel")
bool showSignalArrows = input.bool(true, "Show entry arrows")
bool showTradeLevels = input.bool(true, "Show Entry/TP/SL trade lines")
bool showTradeLabels = input.bool(true, "Show trade labels")
string labelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"])
bool showInfoTable = input.bool(true, "Show information table")
int visualHistoryBars = input.int(800, "Visual history bars; 0 = all", minval = 0)
int arrowOffsetPoints = input.int(20, "Arrow offset, points", minval = 0)

color entryChannelColor = input.color(#1E90FF, "Entry channel color")
color exitChannelColor = input.color(#FFA500, "Exit channel color")
color buyColor = input.color(#00FF00, "BUY color")
color sellColor = input.color(#FF0000, "SELL color")
color tpColor = input.color(#32CD32, "TP color")
color slColor = input.color(#FF6347, "SL color")
color entryLineColor = input.color(#FFFFFF, "Entry color")
string tradeLineStyleInput = input.string("Dotted", "TP/SL line style", options = ["Solid", "Dotted", "Dashed"])
int tradeLineWidth = input.int(1, "Trade line width", minval = 1, maxval = 4)

bool alertOnIndicatorStart = input.bool(false, "Send alert immediately when indicator starts")
bool alertOnEntry = input.bool(true, "Entry alerts")
bool alertOnTakeProfit = input.bool(true, "Take Profit alerts")
bool alertOnStopLoss = input.bool(true, "Stop Loss alerts")
bool alertOnTurtleExit = input.bool(true, "Turtle exit alerts")

// ============================================================================
// Helpers
// ============================================================================
float point = 1.0 / syminfo.pricescale

f_sideText(int side) =>
    side > 0 ? "BUY" : side < 0 ? "SELL" : "FLAT"

f_priceText(float price) =>
    str.tostring(price, "#.##########")

f_roundToPoint(float price) =>
    math.round(price / point) * point

f_alertMessage(string eventType, int side, int signalTime, float price, float tpPrice, float slPrice, string extra) =>
    string timeText = str.format_time(signalTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
    string msg = "Turtle " + eventType + " " + syminfo.tickerid + " " + timeframe.period +
      " | " + f_sideText(side) +
      " | " + timeText +
      " | price=" + f_priceText(price) +
      " | TP=" + f_priceText(tpPrice) +
      " | SL=" + f_priceText(slPrice)
    extra == "" ? msg : msg + " | " + extra

tradePlotLineStyle = switch tradeLineStyleInput
    "Solid" => plot.linestyle_solid
    "Dashed" => plot.linestyle_dashed
    => plot.linestyle_dotted

string tradeDrawingLineStyle = switch tradeLineStyleInput
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

tradeLabelSize = switch labelSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

var table infoTable = table.new(position.top_right, 2, 9, border_width = 1)

// ============================================================================
// Donchian/Turtle channels. The current signal bar is excluded from channel calculations.
// ============================================================================
float entryUpper = ta.highest(high[1], entryPeriod)
float entryLower = ta.lowest(low[1], entryPeriod)
float exitUpper = ta.highest(high[1], exitPeriod)
float exitLower = ta.lowest(low[1], exitPeriod)

plot(showEntryChannel ? entryUpper : na, "Turtle Entry Upper", color = entryChannelColor, linewidth = 1, style = plot.style_line, linestyle = plot.linestyle_solid)
plot(showEntryChannel ? entryLower : na, "Turtle Entry Lower", color = entryChannelColor, linewidth = 1, style = plot.style_line, linestyle = plot.linestyle_solid)
plot(showExitChannel ? exitUpper : na, "Turtle Exit Upper", color = exitChannelColor, linewidth = 1, style = plot.style_line, linestyle = plot.linestyle_dotted)
plot(showExitChannel ? exitLower : na, "Turtle Exit Lower", color = exitChannelColor, linewidth = 1, style = plot.style_line, linestyle = plot.linestyle_dotted)

// ============================================================================
// Trade state
// ============================================================================
var int position = 0
var int entryBar = na
var int entryTime = na
var float entryPrice = na
var float tpPrice = na
var float slPrice = na

// Labels kept for closed trades. TradingView hard-limits labels to 500.
var array<label> historyLabels = array.new<label>()
var array<int> historyLabelExitBars = array.new<int>()
int HISTORY_LABEL_CAP = 495

// Recent closed-trade records are only needed to restore the full segment of a
// trade that starts before VisualHistoryBars but exits inside it.
var array<int> recordEntryBars = array.new<int>()
var array<int> recordExitBars = array.new<int>()
var array<int> recordEntryTimes = array.new<int>()
var array<int> recordExitTimes = array.new<int>()
var array<float> recordEntryPrices = array.new<float>()
var array<float> recordTPPrices = array.new<float>()
var array<float> recordSLPrices = array.new<float>()

// Live trade objects draw ray-right levels for an open trade.
var line liveEntryLine = na
var line liveTPLine = na
var line liveSLLine = na
var label liveEntryLabel = na
var label liveTPLabel = na
var label liveSLLabel = na

// At most one closed trade can straddle the left boundary of the visual range.
var line boundaryEntryLine = na
var line boundaryTPLine = na
var line boundarySLLine = na
var int boundaryExitBar = na

// Persistent alert key used to prevent duplicate realtime alerts.
varip string lastAlertKey = ""
varip bool realtimeInitialized = false

var string lastEventType = "—"
var string lastEventSummary = "—"
var int lastEventTimePersist = na

// ============================================================================
// Per-bar outputs/events
// ============================================================================
float buyArrowY = na
float sellArrowY = na
float tradeEntryLevel = na
float tradeTPLevel = na
float tradeSLLevel = na

string eventType = ""
int eventSide = 0
int eventTime = na
float eventPrice = na
float eventTP = na
float eventSL = na
string eventExtra = ""

bool signalAllowedOnThisBar = signalBarMode == "Current candle" or barstate.isconfirmed

// ============================================================================
// Simulation: one position at a time, with deterministic exit-priority checks.
// ============================================================================
if position == 0
    if signalAllowedOnThisBar and not na(entryUpper) and not na(entryLower)
        bool buySignal = confirmBreakoutByClose ? close > entryUpper : high > entryUpper
        bool sellSignal = confirmBreakoutByClose ? close < entryLower : low < entryLower

        if buySignal != sellSignal
            if buySignal
                position := 1
                entryBar := bar_index
                entryTime := time
                entryPrice := f_roundToPoint(confirmBreakoutByClose ? close : entryUpper)
                tpPrice := f_roundToPoint(entryPrice + takeProfitPoints * point)
                slPrice := f_roundToPoint(entryPrice - stopLossPoints * point)

                buyArrowY := low - arrowOffsetPoints * point
                tradeEntryLevel := entryPrice
                tradeTPLevel := tpPrice
                tradeSLLevel := slPrice

                eventType := "ENTRY"
                eventSide := position
                eventTime := time
                eventPrice := entryPrice
                eventTP := tpPrice
                eventSL := slPrice
            else
                position := -1
                entryBar := bar_index
                entryTime := time
                entryPrice := f_roundToPoint(confirmBreakoutByClose ? close : entryLower)
                tpPrice := f_roundToPoint(entryPrice - takeProfitPoints * point)
                slPrice := f_roundToPoint(entryPrice + stopLossPoints * point)

                sellArrowY := high + arrowOffsetPoints * point
                tradeEntryLevel := entryPrice
                tradeTPLevel := tpPrice
                tradeSLLevel := slPrice

                eventType := "ENTRY"
                eventSide := position
                eventTime := time
                eventPrice := entryPrice
                eventTP := tpPrice
                eventSL := slPrice
else
    // Existing trade levels are visible on every bar up to and including exit.
    tradeEntryLevel := entryPrice
    tradeTPLevel := tpPrice
    tradeSLLevel := slPrice

    // A trade never exits on the same bar where it was entered.
    if bar_index > entryBar
        bool exitNow = false
        string exitReason = ""
        float exitPrice = na

        if position > 0
            bool slHit = low <= slPrice
            bool tpHit = high >= tpPrice
            bool channelHit = useTurtleExit and not na(exitLower) and (confirmExitByClose ? close < exitLower : low < exitLower)

            if slHit and tpHit
                exitNow := true
                exitReason := conservativeSameBar ? "SL" : "TP"
                exitPrice := conservativeSameBar ? slPrice : tpPrice
            else if slHit
                exitNow := true
                exitReason := "SL"
                exitPrice := slPrice
            else if tpHit
                exitNow := true
                exitReason := "TP"
                exitPrice := tpPrice
            else if channelHit
                exitNow := true
                exitReason := "TURTLE_EXIT"
                exitPrice := confirmExitByClose ? close : exitLower
        else
            bool slHit = high >= slPrice
            bool tpHit = low <= tpPrice
            bool channelHit = useTurtleExit and not na(exitUpper) and (confirmExitByClose ? close > exitUpper : high > exitUpper)

            if slHit and tpHit
                exitNow := true
                exitReason := conservativeSameBar ? "SL" : "TP"
                exitPrice := conservativeSameBar ? slPrice : tpPrice
            else if slHit
                exitNow := true
                exitReason := "SL"
                exitPrice := slPrice
            else if tpHit
                exitNow := true
                exitReason := "TP"
                exitPrice := tpPrice
            else if channelHit
                exitNow := true
                exitReason := "TURTLE_EXIT"
                exitPrice := confirmExitByClose ? close : exitUpper

        if exitNow
            int closedSide = position
            int closedEntryBar = entryBar
            int closedEntryTime = entryTime
            float closedEntryPrice = entryPrice
            float closedTP = tpPrice
            float closedSL = slPrice
            bool exitInsideVisualRange = visualHistoryBars <= 0 or bar_index >= last_bar_index - visualHistoryBars

            eventType := exitReason
            eventSide := closedSide
            eventTime := time
            eventPrice := f_roundToPoint(exitPrice)
            eventTP := closedTP
            eventSL := closedSL
            eventExtra := "entry=" + f_priceText(closedEntryPrice)

            // Keep enough trade metadata to reconstruct a boundary-crossing
            // horizontal segment inside the selected visual history.
            if showTradeLevels and visualHistoryBars > 0 and exitInsideVisualRange
                array.push(recordEntryBars, closedEntryBar)
                array.push(recordExitBars, bar_index)
                array.push(recordEntryTimes, closedEntryTime)
                array.push(recordExitTimes, time)
                array.push(recordEntryPrices, closedEntryPrice)
                array.push(recordTPPrices, closedTP)
                array.push(recordSLPrices, closedSL)

            // Closed-trade labels. If the trade had live labels, preserve them;
            // otherwise create them retroactively at the original entry time.
            if showTradeLevels and showTradeLabels and exitInsideVisualRange
                if not na(liveEntryLabel)
                    array.push(historyLabels, liveEntryLabel)
                    array.push(historyLabelExitBars, bar_index)
                    array.push(historyLabels, liveTPLabel)
                    array.push(historyLabelExitBars, bar_index)
                    array.push(historyLabels, liveSLLabel)
                    array.push(historyLabelExitBars, bar_index)
                    liveEntryLabel := na
                    liveTPLabel := na
                    liveSLLabel := na
                else
                    while array.size(historyLabels) > HISTORY_LABEL_CAP - 3
                        label.delete(array.shift(historyLabels))
                        array.shift(historyLabelExitBars)

                    string sideText = f_sideText(closedSide)
                    string entryText = sideText + " Entry " + f_priceText(closedEntryPrice)
                    string tpText = "TP " + f_priceText(closedTP)
                    string slText = "SL " + f_priceText(closedSL)

                    label lEntry = label.new(x = closedEntryTime, y = closedEntryPrice, xloc = xloc.bar_time, yloc = yloc.price,
                      text = entryText, style = label.style_none, textcolor = entryLineColor, size = tradeLabelSize, tooltip = entryText)
                    label lTP = label.new(x = closedEntryTime, y = closedTP, xloc = xloc.bar_time, yloc = yloc.price,
                      text = tpText, style = label.style_none, textcolor = tpColor, size = tradeLabelSize, tooltip = tpText)
                    label lSL = label.new(x = closedEntryTime, y = closedSL, xloc = xloc.bar_time, yloc = yloc.price,
                      text = slText, style = label.style_none, textcolor = slColor, size = tradeLabelSize, tooltip = slText)

                    array.push(historyLabels, lEntry)
                    array.push(historyLabelExitBars, bar_index)
                    array.push(historyLabels, lTP)
                    array.push(historyLabelExitBars, bar_index)
                    array.push(historyLabels, lSL)
                    array.push(historyLabelExitBars, bar_index)
            else
                if not na(liveEntryLabel)
                    label.delete(liveEntryLabel)
                    label.delete(liveTPLabel)
                    label.delete(liveSLLabel)
                    liveEntryLabel := na
                    liveTPLabel := na
                    liveSLLabel := na

            // Open-trade rays are no longer needed after exit. Historical
            // closed levels are rendered by plots below.
            if not na(liveEntryLine)
                line.delete(liveEntryLine)
                line.delete(liveTPLine)
                line.delete(liveSLLine)
                liveEntryLine := na
                liveTPLine := na
                liveSLLine := na

            position := 0
            entryBar := na
            entryTime := na
            entryPrice := na
            tpPrice := na
            slPrice := na

// ============================================================================
// Main visual plots
// ============================================================================
int tradeLevelsShowLast = visualHistoryBars > 0 ? visualHistoryBars + 1 : 1000000

plot(showTradeLevels ? tradeEntryLevel : na, "Trade Entry", color = entryLineColor,
  linewidth = tradeLineWidth, style = plot.style_linebr, linestyle = plot.linestyle_solid, show_last = tradeLevelsShowLast)
plot(showTradeLevels ? tradeTPLevel : na, "Trade TP", color = tpColor,
  linewidth = tradeLineWidth, style = plot.style_linebr, linestyle = tradePlotLineStyle, show_last = tradeLevelsShowLast)
plot(showTradeLevels ? tradeSLLevel : na, "Trade SL", color = slColor,
  linewidth = tradeLineWidth, style = plot.style_linebr, linestyle = tradePlotLineStyle, show_last = tradeLevelsShowLast)

plotshape(showSignalArrows ? buyArrowY : na, title = "Turtle Buy", style = shape.arrowup,
  location = location.absolute, color = buyColor, size = size.small)
plotshape(showSignalArrows ? sellArrowY : na, title = "Turtle Sell", style = shape.arrowdown,
  location = location.absolute, color = sellColor, size = size.small)

// ============================================================================
// Last-bar object maintenance: open rays, labels, visual-history boundary.
// ============================================================================
if barstate.islast
    int cutoffBar = visualHistoryBars > 0 ? last_bar_index - visualHistoryBars : na

    // Prune labels no longer inside the selected visual history.
    if visualHistoryBars > 0
        while array.size(historyLabelExitBars) > 0 and array.get(historyLabelExitBars, 0) < cutoffBar
            label.delete(array.shift(historyLabels))
            array.shift(historyLabelExitBars)

        while array.size(recordExitBars) > 0 and array.get(recordExitBars, 0) < cutoffBar
            array.shift(recordEntryBars)
            array.shift(recordExitBars)
            array.shift(recordEntryTimes)
            array.shift(recordExitTimes)
            array.shift(recordEntryPrices)
            array.shift(recordTPPrices)
            array.shift(recordSLPrices)

    while array.size(historyLabels) > HISTORY_LABEL_CAP
        label.delete(array.shift(historyLabels))
        array.shift(historyLabelExitBars)

    // Draw ray-right levels for the currently open position.
    if showTradeLevels and position != 0
        if na(liveEntryLine)
            liveEntryLine := line.new(x1 = entryTime, y1 = entryPrice, x2 = time, y2 = entryPrice,
              xloc = xloc.bar_time, extend = extend.right, color = entryLineColor, style = line.style_solid, width = tradeLineWidth)
            liveTPLine := line.new(x1 = entryTime, y1 = tpPrice, x2 = time, y2 = tpPrice,
              xloc = xloc.bar_time, extend = extend.right, color = tpColor, style = tradeDrawingLineStyle, width = tradeLineWidth)
            liveSLLine := line.new(x1 = entryTime, y1 = slPrice, x2 = time, y2 = slPrice,
              xloc = xloc.bar_time, extend = extend.right, color = slColor, style = tradeDrawingLineStyle, width = tradeLineWidth)
        else
            line.set_x2(liveEntryLine, time)
            line.set_x2(liveTPLine, time)
            line.set_x2(liveSLLine, time)

        if showTradeLabels and na(liveEntryLabel)
            string sideText = f_sideText(position)
            string entryText = sideText + " Entry " + f_priceText(entryPrice)
            string tpText = "TP " + f_priceText(tpPrice)
            string slText = "SL " + f_priceText(slPrice)

            liveEntryLabel := label.new(x = entryTime, y = entryPrice, xloc = xloc.bar_time, yloc = yloc.price,
              text = entryText, style = label.style_none, textcolor = entryLineColor, size = tradeLabelSize, tooltip = entryText)
            liveTPLabel := label.new(x = entryTime, y = tpPrice, xloc = xloc.bar_time, yloc = yloc.price,
              text = tpText, style = label.style_none, textcolor = tpColor, size = tradeLabelSize, tooltip = tpText)
            liveSLLabel := label.new(x = entryTime, y = slPrice, xloc = xloc.bar_time, yloc = yloc.price,
              text = slText, style = label.style_none, textcolor = slColor, size = tradeLabelSize, tooltip = slText)
    else
        if not na(liveEntryLine)
            line.delete(liveEntryLine)
            line.delete(liveTPLine)
            line.delete(liveSLLine)
            liveEntryLine := na
            liveTPLine := na
            liveSLLine := na

        if not na(liveEntryLabel)
            label.delete(liveEntryLabel)
            label.delete(liveTPLabel)
            label.delete(liveSLLabel)
            liveEntryLabel := na
            liveTPLabel := na
            liveSLLabel := na

    if showInfoTable
        string posText = f_sideText(position)
        color posColor = position > 0 ? buyColor : position < 0 ? sellColor : color.silver
        string entryTextTable = position != 0 and not na(entryPrice) ? f_priceText(entryPrice) : "—"
        string tpTextTable = position != 0 and not na(tpPrice) ? f_priceText(tpPrice) : "—"
        string slTextTable = position != 0 and not na(slPrice) ? f_priceText(slPrice) : "—"
        string entryChannelText = not na(entryUpper) and not na(entryLower) ? f_priceText(entryUpper) + " / " + f_priceText(entryLower) : "—"
        string exitChannelText = not na(exitUpper) and not na(exitLower) ? f_priceText(exitUpper) + " / " + f_priceText(exitLower) : "—"
        string lastEventTimeText = not na(lastEventTimePersist) ? str.format_time(lastEventTimePersist, "yyyy-MM-dd HH:mm", syminfo.timezone) : "—"

        table.clear(infoTable, 0, 0, 1, 8)
        table.cell(infoTable, 0, 0, "Turtle TP/SL", text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 70))
        table.cell(infoTable, 1, 0, syminfo.ticker + " | " + timeframe.period, text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 70))

        table.cell(infoTable, 0, 1, "Position", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 1, posText, text_color = posColor, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 2, "Entry / TP / SL", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 2, entryTextTable + " / " + tpTextTable + " / " + slTextTable, text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 3, "Entry channel", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 3, entryChannelText, text_color = entryChannelColor, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 4, "Exit channel", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 4, exitChannelText, text_color = exitChannelColor, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 5, "Last event", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 5, lastEventSummary, text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 6, "Event time", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 6, lastEventTimeText, text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 7, "Parameters", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 7, "Entry " + str.tostring(entryPeriod) + " | Exit " + str.tostring(exitPeriod), text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))

        table.cell(infoTable, 0, 8, "TP / SL", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
        table.cell(infoTable, 1, 8, str.tostring(takeProfitPoints) + " / " + str.tostring(stopLossPoints) + " pts", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 15))
    else
        table.clear(infoTable, 0, 0, 1, 8)

    // The plot mask starts at cutoffBar. If one closed trade began before that
    // boundary but exited after it, draw its complete segment with 3 lines.
    int candidateIndex = na
    if showTradeLevels and visualHistoryBars > 0 and array.size(recordExitBars) > 0
        for i = 0 to array.size(recordExitBars) - 1
            int recEntryBar = array.get(recordEntryBars, i)
            int recExitBar = array.get(recordExitBars, i)
            if recEntryBar < cutoffBar and recExitBar >= cutoffBar
                candidateIndex := i
                break

    int candidateExitBar = not na(candidateIndex) ? array.get(recordExitBars, candidateIndex) : na

    bool boundaryChanged = (na(candidateExitBar) and not na(boundaryExitBar)) or (not na(candidateExitBar) and (na(boundaryExitBar) or candidateExitBar != boundaryExitBar))

    if boundaryChanged
        if not na(boundaryEntryLine)
            line.delete(boundaryEntryLine)
            line.delete(boundaryTPLine)
            line.delete(boundarySLLine)
            boundaryEntryLine := na
            boundaryTPLine := na
            boundarySLLine := na

        boundaryExitBar := candidateExitBar

        if not na(candidateIndex)
            int recEntryTime = array.get(recordEntryTimes, candidateIndex)
            int recExitTime = array.get(recordExitTimes, candidateIndex)
            float recEntryPrice = array.get(recordEntryPrices, candidateIndex)
            float recTP = array.get(recordTPPrices, candidateIndex)
            float recSL = array.get(recordSLPrices, candidateIndex)

            boundaryEntryLine := line.new(x1 = recEntryTime, y1 = recEntryPrice, x2 = recExitTime, y2 = recEntryPrice,
              xloc = xloc.bar_time, extend = extend.none, color = entryLineColor, style = line.style_solid, width = tradeLineWidth)
            boundaryTPLine := line.new(x1 = recEntryTime, y1 = recTP, x2 = recExitTime, y2 = recTP,
              xloc = xloc.bar_time, extend = extend.none, color = tpColor, style = tradeDrawingLineStyle, width = tradeLineWidth)
            boundarySLLine := line.new(x1 = recEntryTime, y1 = recSL, x2 = recExitTime, y2 = recSL,
              xloc = xloc.bar_time, extend = extend.none, color = slColor, style = tradeDrawingLineStyle, width = tradeLineWidth)

// ============================================================================
// Last event memory for the info table
// ============================================================================
if eventType != ""
    lastEventType := eventType
    lastEventTimePersist := eventTime
    string lastEventTimeText = str.format_time(eventTime, "MM-dd HH:mm", syminfo.timezone)
    lastEventSummary := eventType + " | " + f_sideText(eventSide) + " | " + f_priceText(eventPrice) + " | " + lastEventTimeText

// ============================================================================
// Alerts
// TradingView controls popup/sound/push/email in the Create Alert dialog.
// Select this indicator -> "Any alert() function call".
// ============================================================================
bool alertTypeEnabled = switch eventType
    "ENTRY" => alertOnEntry
    "TP" => alertOnTakeProfit
    "SL" => alertOnStopLoss
    "TURTLE_EXIT" => alertOnTurtleExit
    => false

bool eventIsOnWatchedBar = signalBarMode == "Current candle" or barstate.isconfirmed
bool startupGate = alertOnIndicatorStart or realtimeInitialized

if barstate.isrealtime
    if eventType != "" and eventIsOnWatchedBar and startupGate and alertTypeEnabled
        string alertKey = eventType + "_" + f_sideText(eventSide) + "_" + str.tostring(eventTime)
        if alertKey != lastAlertKey
            alert(f_alertMessage(eventType, eventSide, eventTime, eventPrice, eventTP, eventSL, eventExtra), alert.freq_all)
            lastAlertKey := alertKey

    realtimeInitialized := true
````
