<!-- tradingview-pine-id: PUB;f8d6f3df9d554f3b91a82d2de060a14f -->
<!-- tradingviewscripts-format: 1 -->
# 3 Session ORB [TickDaddy] — Any-Side Arm + Sequential 2 Trades

Source: https://www.tradingview.com/script/XoWVndPv-3-Session-ORB-BudgeDaddy/

## Description

im the daddy. systems the daddy, im your daddy. im not telling you how to do it im just putting it here for you to find it. now leave me alone

---

## Source Code

````pine
//@version=6
strategy(
     "3 Session ORB [TickDaddy] — Any-Side Arm + Sequential 2 Trades",
     overlay = true,
     pyramiding = 2,
     process_orders_on_close = false,
     calc_on_order_fills = true,
     calc_on_every_tick = false,
     max_boxes_count = 500,
     max_labels_count = 500,
     max_lines_count = 500)


// ==================== STRATEGY SETTINGS ====================
emaLength = input.int(20, "EMA Length", minval = 1, group = "Strategy", display = display.none)

biasControlSource = input.string(
     "Automatic Scoring",
     "Bias Control",
     options = ["Automatic Scoring", "Manual Modes"],
     group = "Bias Control",
     tooltip = "Automatic Scoring uses the locked automatic direction. Manual Modes restores the original Daily Bias / Session Bias control modes.",
     display = display.none)

dailyBias = input.string(
     "Off",
     "Daily Bias",
     options = ["Off", "Bullish", "Bearish"],
     group = "Manual Bias Settings",
     active = biasControlSource == "Manual Modes",
     tooltip = "Used by the manual bias modes. Off does not force a daily direction.",
     display = display.none)

biasControlMode = input.string(
     "Daily Bias Only",
     "Bias Control Mode",
     options = [
         "Daily Bias Only",
         "Session Bias Only",
         "Daily Preferred"
     ],
     group = "Manual Bias Settings",
     active = biasControlSource == "Manual Modes",
     tooltip = "Daily Bias Only follows Daily Bias. Session Bias Only follows the locked 1H session bias. Daily Preferred favors Daily Bias unless a strong opposing session bias takes control.",
     display = display.none)

neutralSessionMode = input.string(
     "Off",
     "Neutral Session Mode",
     options = ["Off", "ORB Rejection"],
     group = "Manual Bias Settings",
     active = biasControlSource == "Manual Modes",
     tooltip = "When Manual Modes is selected, Daily Bias is Off, and the locked 1H session bias is Neutral, ORB Rejection looks for a failed push through an ORB edge that closes back inside the range, then waits for the matching EMA confirmation.",
     display = display.none)


// Automatic bias Supertrend restored to the original fixed settings.
autoBiasStAtrLength = 10
autoBiasStFactor = 3.0

targetTicks = input.int(
     70,
     "Take Profit (ticks)",
     minval = 1,
     group = "Risk / Reward",
     tooltip = "Default is 70 ticks.",
     display = display.none)

stopTicks = input.int(
     210,
     "Stop Loss (ticks)",
     minval = 1,
     group = "Risk / Reward",
     tooltip = "Default is 210 ticks.",
     display = display.none)

riskRewardRatio = targetTicks / stopTicks

showEntryRiskLevels = input.bool(
     true,
     "Show Entry, Stop and Target",
     group = "Risk / Reward",
     tooltip = "Draws labelled Entry, SL and TP levels from the strategy's actual average fill price.",
     display = display.none)

enableOrbFormedAlert = input.bool(
     true,
     "Alert: ORB Formed",
     group = "Webhook Alerts",
     tooltip = "Fires once when the session's 30-minute ORB has finished forming.",
     display = display.none)

enableFirstBreakoutAlert = input.bool(
     true,
     "Alert: First Confirmed Breakout",
     group = "Webhook Alerts",
     tooltip = "Fires once only when a completed 2-minute candle CLOSES outside the ORB. Wicks outside that close back inside do not count.",
     display = display.none)

enableEntryStartedAlert = input.bool(
     true,
     "Alert: Entry Started",
     group = "Webhook Alerts",
     tooltip = "Fires only when the strategy submits an actual long or short entry order.",
     display = display.none)

useEntryQualityFilter = input.bool(true, "Use EMA Entry Quality Filter", group = "Entry Quality", tooltip = "Scores the completed EMA-cross candle using session bias, EMA slope, candle strength and recent EMA choppiness.", display = display.none)
minimumEntryQualityScore = input.int(3, "Minimum Entry Quality Score", minval = 0, maxval = 7, group = "Entry Quality", tooltip = "Recommended starting value: 4. Higher values produce fewer, stricter entries.", display = display.none)
minimumBodyFraction = input.float(0.50, "Minimum Body / Candle Range", minval = 0.0, maxval = 1.0, step = 0.05, group = "Entry Quality", display = display.none)
minimumCloseLocation = input.float(0.65, "Minimum Directional Close Location", minval = 0.50, maxval = 1.0, step = 0.05, group = "Entry Quality", display = display.none)
maximumRecentEmaFlips = input.int(1, "Maximum EMA Side Flips (Previous 3 Bars)", minval = 0, maxval = 2, group = "Entry Quality", display = display.none)

showDiagnostics = input.bool(
     false,
     "Show Diagnostic Labels",
     group = "Diagnostics",
     tooltip = "Adds a compact label to every completed 2-minute candle showing session, ORB state, bias mode, armed direction, EMA cross state, quality scores and the most likely reason an entry did not occur.",
     display = display.none)

maxTradesPerSession = input.int(
     1,
     "Max Trades Per Session",
     minval = 1,
     maxval = 2,
     group = "Strategy",
     tooltip = "Allows either 1 or 2 completed trade entries per Asia, London, or New York session. A second trade must form a fresh EMA confirmation after the first trade has closed.",
     display = display.none)


breakoutToleranceTicks = input.int(
     35,
     "Breakout Tolerance (ticks)",
     minval = 0,
     group = "Strategy",
     tooltip = "A completed 2-minute candle must close at least this many ticks beyond the ORB high or low. Set to 0 to accept every breakout.",
     display = display.none)

breakoutTolerancePrice = breakoutToleranceTicks * syminfo.mintick

// ==================== GLOBAL SETTINGS ====================
timezone = input.string(
     "Europe/London",
     "Timezone",
     options = [
         "Europe/London",
         "America/Denver",
         "America/New_York",
         "America/Chicago",
         "America/Los_Angeles",
         "UTC"
     ],
     group = "Global",
     display = display.none)

rangeMinutes = input.int(
     30,
     "Range Duration (minutes)",
     minval = 1,
     maxval = 120,
     group = "Global",
     display = display.none)

displayDurationHours = input.int(
     5,
     "Display Duration (hours)",
     minval = 0,
     maxval = 12,
     group = "Global",
     tooltip = "How many hours to display lines after session opens",
     display = display.none)

// ==================== ASIA SESSION ====================
enableAsia = input.bool(true, "Enable Asia Session", group = "Asia Session", display = display.none)
asiaStartHour = input.int(1, "Start Hour", minval = 0, maxval = 23, group = "Asia Session", display = display.none)
asiaStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, group = "Asia Session", display = display.none)
asiaHighColor = input.color(color.new(#00BCD4, 0), "High Line Color", group = "Asia Session", display = display.none)
asiaLowColor = input.color(color.new(#00838F, 0), "Low Line Color", group = "Asia Session", display = display.none)
asiaLineThickness = input.int(2, "Line Thickness", minval = 1, maxval = 10, group = "Asia Session", display = display.none)
asiaShowLabel = input.bool(true, "Show Label", group = "Asia Session", display = display.none)
asiaShow50 = input.bool(false, "Show 50% Line", group = "Asia Session", display = display.none)
asia50Color = input.color(color.new(#00BCD4, 50), "50% Line Color", group = "Asia Session", display = display.none)
asia50Style = input.string("Dashed", "50% Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Asia Session", display = display.none)
asia50Thickness = input.int(1, "50% Line Thickness", minval = 1, maxval = 10, group = "Asia Session", display = display.none)

// ==================== LONDON SESSION ====================
enableLondon = input.bool(true, "Enable London Session", group = "London Session", display = display.none)
londonStartHour = input.int(9, "Start Hour", minval = 0, maxval = 23, group = "London Session", display = display.none)
londonStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, group = "London Session", display = display.none)
londonHighColor = input.color(color.new(#FF6B6B, 0), "High Line Color", group = "London Session", display = display.none)
londonLowColor = input.color(color.new(#C92A2A, 0), "Low Line Color", group = "London Session", display = display.none)
londonLineThickness = input.int(2, "Line Thickness", minval = 1, maxval = 10, group = "London Session", display = display.none)
londonShowLabel = input.bool(true, "Show Label", group = "London Session", display = display.none)
londonShow50 = input.bool(false, "Show 50% Line", group = "London Session", display = display.none)
london50Color = input.color(color.new(#FF6B6B, 50), "50% Line Color", group = "London Session", display = display.none)
london50Style = input.string("Dashed", "50% Line Style", options = ["Solid", "Dashed", "Dotted"], group = "London Session", display = display.none)
london50Thickness = input.int(1, "50% Line Thickness", minval = 1, maxval = 10, group = "London Session", display = display.none)

// ==================== NEW YORK SESSION ====================
enableNewYork = input.bool(true, "Enable New York Session", group = "New York Session", display = display.none)
newYorkStartHour = input.int(14, "Start Hour", minval = 0, maxval = 23, group = "New York Session", display = display.none)
newYorkStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, group = "New York Session", display = display.none)
newYorkHighColor = input.color(color.new(#4CAF50, 0), "High Line Color", group = "New York Session", display = display.none)
newYorkLowColor = input.color(color.new(#2E7D32, 0), "Low Line Color", group = "New York Session", display = display.none)
newYorkLineThickness = input.int(2, "Line Thickness", minval = 1, maxval = 10, group = "New York Session", display = display.none)
newYorkShowLabel = input.bool(true, "Show Label", group = "New York Session", display = display.none)
newYorkShow50 = input.bool(false, "Show 50% Line", group = "New York Session", display = display.none)
newYork50Color = input.color(color.new(#4CAF50, 50), "50% Line Color", group = "New York Session", display = display.none)
newYork50Style = input.string("Dashed", "50% Line Style", options = ["Solid", "Dashed", "Dotted"], group = "New York Session", display = display.none)
newYork50Thickness = input.int(1, "50% Line Thickness", minval = 1, maxval = 10, group = "New York Session", display = display.none)

// ==================== TRADE VISUALS ====================
showHistoricalTradeHighlights = input.bool(
     true,
     "Show Completed Trade Boxes",
     group = "Trade Visuals",
     tooltip = "Draws a green box around each winning trade and a red box around each losing trade, from entry through exit.",
     display = display.none)

showLiveTradeCandles = input.bool(
     true,
     "Colour Open-Trade Candles",
     group = "Trade Visuals",
     tooltip = "While a trade is open, colours each candle green when the position is in profit and red when it is in loss.",
     display = display.none)

winningTradeColor = input.color(
     color.new(color.lime, 60),
     "Winning Trade Box Fill",
     group = "Trade Visuals",
     tooltip = "Green fill for winning trades. Default is 80% opacity.",
     display = display.none)

losingTradeColor = input.color(
     color.new(color.red, 60),
     "Losing Trade Box Fill",
     group = "Trade Visuals",
     tooltip = "Red fill for losing trades. Default is 80% opacity.",
     display = display.none)

// ==================== AUTOMATIC DAILY BIAS ====================
// The 10-minute values come from the last fully completed 10-minute candle.
// At each session start, the strategy also reads the previous completed
// 2-minute candle and locks the result for the whole session.
autoBiasConfirmed10mValues() =>
    [stLine, stDirection] = ta.supertrend(autoBiasStFactor, autoBiasStAtrLength)
    [close[1], stLine[1]]

[autoBias10mClose, autoBias10mStLine] = request.security(
     syminfo.tickerid,
     "10",
     autoBiasConfirmed10mValues(),
     barmerge.gaps_off,
     barmerge.lookahead_on)

[autoBias2mStLineLive, autoBias2mStDirection] = ta.supertrend(
     autoBiasStFactor,
     autoBiasStAtrLength)

autoBias2mCloseForLock = close[1]
autoBias2mStLineForLock = autoBias2mStLineLive[1]

autoBias10mBullish = not na(autoBias10mClose) and not na(autoBias10mStLine) and autoBias10mClose > autoBias10mStLine
autoBias10mBearish = not na(autoBias10mClose) and not na(autoBias10mStLine) and autoBias10mClose < autoBias10mStLine
autoBias2mBullishForLock = not na(autoBias2mCloseForLock) and not na(autoBias2mStLineForLock) and autoBias2mCloseForLock > autoBias2mStLineForLock
autoBias2mBearishForLock = not na(autoBias2mCloseForLock) and not na(autoBias2mStLineForLock) and autoBias2mCloseForLock < autoBias2mStLineForLock

autoBiasCandidate =
     autoBias10mBullish and autoBias2mBullishForLock ? "Bullish" :
     autoBias10mBearish and autoBias2mBearishForLock ? "Bearish" :
     "Off"

var string lockedAutoDailyBias = "Off"
var string lockedAuto10mState = "Neutral"
var string lockedAuto2mState = "Neutral"
var string lockedAutoBiasSession = "Pending"

var int lockedAutomaticDailyScore = 0
var int lockedAutomaticSessionScore = 0
var int lockedAutomaticCombinedScore = 0
var string lockedAutomaticDecision = "NO TRADE"
var string lockedDecisionSession = "Waiting"
var int lockedDecisionTime = na

activeDailyBias =
     biasControlSource == "Manual Modes" ?
         dailyBias :
         lockedAutoDailyBias

// ==================== WEBHOOK ALERT HELPER ====================
webhookMessage(eventType, sessionName, direction) =>
    requestedEntry = close
    stopPrice =
         direction == "long" ? requestedEntry - stopTicks * syminfo.mintick :
         direction == "short" ? requestedEntry + stopTicks * syminfo.mintick :
         na
    targetPrice =
         direction == "long" ? requestedEntry + targetTicks * syminfo.mintick :
         direction == "short" ? requestedEntry - targetTicks * syminfo.mintick :
         na
    signalId =
         syminfo.tickerid + "-" +
         sessionName + "-" +
         direction + "-" +
         str.tostring(time)
    message =
         "{\"event\":\"" + eventType +
         "\",\"signal_id\":\"" + signalId +
         "\",\"ticker\":\"" + syminfo.tickerid +
         "\",\"timeframe\":\"" + timeframe.period +
         "\",\"timezone\":\"" + timezone +
         "\",\"session\":\"" + sessionName +
         "\",\"system_state\":\"" + eventType +
         "\",\"locked_direction\":\"" + lockedAutomaticDecision +
         "\",\"direction\":\"" + direction +
         "\",\"combined_score\":" + str.tostring(lockedAutomaticCombinedScore) +
         ",\"daily_score\":" + str.tostring(lockedAutomaticDailyScore) +
         ",\"session_score\":" + str.tostring(lockedAutomaticSessionScore) +
         ",\"requested_entry_price\":" + str.tostring(requestedEntry, format.mintick) +
         ",\"stop_price\":" + (na(stopPrice) ? "null" : str.tostring(stopPrice, format.mintick)) +
         ",\"target_price\":" + (na(targetPrice) ? "null" : str.tostring(targetPrice, format.mintick)) +
         ",\"stop_ticks\":" + str.tostring(stopTicks) +
         ",\"target_ticks\":" + str.tostring(targetTicks) +
         ",\"reward_risk\":" + str.tostring(riskRewardRatio) +
         ",\"breakout_tolerance_ticks\":" + str.tostring(breakoutToleranceTicks) +
         ",\"breakout_confirmation\":\"Close Outside ORB\"" +
         ",\"bias_lock_timing\":\"ORB Completion\"" +
         "\",\"time\":\"" + str.format_time(time, "yyyy-MM-dd HH:mm:ss", timezone) +
         "\"}"
    message

// ==================== HELPER FUNCTIONS ====================
calculateRangeEnd(startH, startM, durationM) =>
    endH = startH
    endM = startM + durationM
    if endM >= 60
        endH := endH + math.floor(endM / 60)
        endM := endM % 60
    if endH >= 24
        endH := endH % 24
    [endH, endM]

getLineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted

isTimeInWindow(nowH, nowM, startH, startM, endH, endM) =>
    nowTotal = nowH * 60 + nowM
    startTotal = startH * 60 + startM
    endTotal = endH * 60 + endM
    startTotal < endTotal ?
         nowTotal >= startTotal and nowTotal < endTotal :
         nowTotal >= startTotal or nowTotal < endTotal

// ==================== SESSION PROCESSOR ====================
var float asiaHigh = na
var float asiaLow = na
var int asiaStartBar = na
var box asiaHighBox = na
var box asiaLowBox = na
var bool asiaBoxesCreated = false
var label asiaLabel = na
var line asia50Line = na
var int asiaTradeCount = 0

var float londonHigh = na
var float londonLow = na
var int londonStartBar = na
var box londonHighBox = na
var box londonLowBox = na
var bool londonBoxesCreated = false
var label londonLabel = na
var line london50Line = na
var int londonTradeCount = 0

var float newYorkHigh = na
var float newYorkLow = na
var int newYorkStartBar = na
var box newYorkHighBox = na
var box newYorkLowBox = na
var bool newYorkBoxesCreated = false
var label newYorkLabel = na
var line newYork50Line = na
var int newYorkTradeCount = 0

currentTime = time(timeframe.period, "0000-0000:1234567", timezone)
currentHour = hour(currentTime, timezone)
currentMinute = minute(currentTime, timezone)
currentDay = dayofmonth(currentTime, timezone)

newDay = ta.change(currentDay) != 0

if newDay
    asiaHigh := na
    asiaLow := na
    asiaStartBar := na
    asiaHighBox := na
    asiaLowBox := na
    asiaBoxesCreated := false
    asiaLabel := na
    asia50Line := na
    asiaTradeCount := 0

    londonHigh := na
    londonLow := na
    londonStartBar := na
    londonHighBox := na
    londonLowBox := na
    londonBoxesCreated := false
    londonLabel := na
    london50Line := na
    londonTradeCount := 0

    newYorkHigh := na
    newYorkLow := na
    newYorkStartBar := na
    newYorkHighBox := na
    newYorkLowBox := na
    newYorkBoxesCreated := false
    newYorkLabel := na
    newYork50Line := na
    newYorkTradeCount := 0

// ==================== PROCESS ASIA SESSION ====================
[asiaEndH, asiaEndM] = calculateRangeEnd(asiaStartHour, asiaStartMinute, rangeMinutes)
asiaDisplayEndH = (asiaStartHour + displayDurationHours) % 24
asiaDisplayEndM = asiaStartMinute

isInAsiaRange = enableAsia and isTimeInWindow(
     currentHour, currentMinute,
     asiaStartHour, asiaStartMinute,
     asiaEndH, asiaEndM)

inAsiaDisplayWindow = enableAsia and isTimeInWindow(
     currentHour, currentMinute,
     asiaStartHour, asiaStartMinute,
     asiaDisplayEndH, asiaDisplayEndM)

isAsiaComplete = enableAsia and not isInAsiaRange and not na(asiaHigh) and not na(asiaLow) and inAsiaDisplayWindow

if isInAsiaRange
    if na(asiaStartBar)
        asiaStartBar := bar_index
        if "ORB Completion" == "Session Start"
            lockedAutoDailyBias := autoBiasCandidate
            lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
            lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
            lockedAutoBiasSession := "Asia • Start"
    if na(asiaHigh) or na(asiaLow)
        asiaHigh := high
        asiaLow := low
    else
        asiaHigh := math.max(asiaHigh, high)
        asiaLow := math.min(asiaLow, low)

if isAsiaComplete and not asiaBoxesCreated
    if "ORB Completion" == "ORB Completion"
        lockedAutoDailyBias := autoBiasCandidate
        lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
        lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
        lockedAutoBiasSession := "Asia • ORB"
    displayMinutes = displayDurationHours * 60
    barInterval = timeframe.in_seconds(timeframe.period) / 60
    barsToEnd = math.floor(displayMinutes / barInterval)

    asiaHighBox := box.new(asiaStartBar, asiaHigh, bar_index + barsToEnd, asiaHigh, border_color = asiaHighColor, border_width = asiaLineThickness, bgcolor = color.new(asiaHighColor, 95))
    asiaLowBox := box.new(asiaStartBar, asiaLow, bar_index + barsToEnd, asiaLow, border_color = asiaLowColor, border_width = asiaLineThickness, bgcolor = color.new(asiaLowColor, 95))

    if asiaShowLabel
        asiaLabel := label.new(asiaStartBar, asiaHigh, "ASIA", style = label.style_label_down, color = asiaHighColor, textcolor = color.white, size = size.small)

    if asiaShow50
        asia50Price = (asiaHigh + asiaLow) / 2
        asia50Line := line.new(asiaStartBar, asia50Price, bar_index + barsToEnd, asia50Price, color = asia50Color, width = asia50Thickness, style = getLineStyle(asia50Style))

    if enableOrbFormedAlert
        alert(webhookMessage("orb_formed", "asia", "none"), alert.freq_once_per_bar_close)

    asiaBoxesCreated := true

if not na(asiaHighBox) and not na(asiaLowBox) and asiaBoxesCreated and inAsiaDisplayWindow
    box.set_right(asiaHighBox, bar_index)
    box.set_right(asiaLowBox, bar_index)
    if asiaShow50 and not na(asia50Line)
        line.set_x2(asia50Line, bar_index)

// ==================== PROCESS LONDON SESSION ====================
[londonEndH, londonEndM] = calculateRangeEnd(londonStartHour, londonStartMinute, rangeMinutes)
londonDisplayEndH = (londonStartHour + displayDurationHours) % 24
londonDisplayEndM = londonStartMinute

isInLondonRange = enableLondon and isTimeInWindow(
     currentHour, currentMinute,
     londonStartHour, londonStartMinute,
     londonEndH, londonEndM)

inLondonDisplayWindow = enableLondon and isTimeInWindow(
     currentHour, currentMinute,
     londonStartHour, londonStartMinute,
     londonDisplayEndH, londonDisplayEndM)

isLondonComplete = enableLondon and not isInLondonRange and not na(londonHigh) and not na(londonLow) and inLondonDisplayWindow

if isInLondonRange
    if na(londonStartBar)
        londonStartBar := bar_index
        if "ORB Completion" == "Session Start"
            lockedAutoDailyBias := autoBiasCandidate
            lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
            lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
            lockedAutoBiasSession := "London • Start"
    if na(londonHigh) or na(londonLow)
        londonHigh := high
        londonLow := low
    else
        londonHigh := math.max(londonHigh, high)
        londonLow := math.min(londonLow, low)

if isLondonComplete and not londonBoxesCreated
    if "ORB Completion" == "ORB Completion"
        lockedAutoDailyBias := autoBiasCandidate
        lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
        lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
        lockedAutoBiasSession := "London • ORB"
    displayMinutes = displayDurationHours * 60
    barInterval = timeframe.in_seconds(timeframe.period) / 60
    barsToEnd = math.floor(displayMinutes / barInterval)

    londonHighBox := box.new(londonStartBar, londonHigh, bar_index + barsToEnd, londonHigh, border_color = londonHighColor, border_width = londonLineThickness, bgcolor = color.new(londonHighColor, 95))
    londonLowBox := box.new(londonStartBar, londonLow, bar_index + barsToEnd, londonLow, border_color = londonLowColor, border_width = londonLineThickness, bgcolor = color.new(londonLowColor, 95))

    if londonShowLabel
        londonLabel := label.new(londonStartBar, londonHigh, "LONDON", style = label.style_label_down, color = londonHighColor, textcolor = color.white, size = size.small)

    if londonShow50
        london50Price = (londonHigh + londonLow) / 2
        london50Line := line.new(londonStartBar, london50Price, bar_index + barsToEnd, london50Price, color = london50Color, width = london50Thickness, style = getLineStyle(london50Style))

    if enableOrbFormedAlert
        alert(webhookMessage("orb_formed", "london", "none"), alert.freq_once_per_bar_close)

    londonBoxesCreated := true

if not na(londonHighBox) and not na(londonLowBox) and londonBoxesCreated and inLondonDisplayWindow
    box.set_right(londonHighBox, bar_index)
    box.set_right(londonLowBox, bar_index)
    if londonShow50 and not na(london50Line)
        line.set_x2(london50Line, bar_index)

// ==================== PROCESS NEW YORK SESSION ====================
[newYorkEndH, newYorkEndM] = calculateRangeEnd(newYorkStartHour, newYorkStartMinute, rangeMinutes)
newYorkDisplayEndH = (newYorkStartHour + displayDurationHours) % 24
newYorkDisplayEndM = newYorkStartMinute

isInNewYorkRange = enableNewYork and isTimeInWindow(
     currentHour, currentMinute,
     newYorkStartHour, newYorkStartMinute,
     newYorkEndH, newYorkEndM)

inNewYorkDisplayWindow = enableNewYork and isTimeInWindow(
     currentHour, currentMinute,
     newYorkStartHour, newYorkStartMinute,
     newYorkDisplayEndH, newYorkDisplayEndM)

isNewYorkComplete = enableNewYork and not isInNewYorkRange and not na(newYorkHigh) and not na(newYorkLow) and inNewYorkDisplayWindow

if isInNewYorkRange
    if na(newYorkStartBar)
        newYorkStartBar := bar_index
        if "ORB Completion" == "Session Start"
            lockedAutoDailyBias := autoBiasCandidate
            lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
            lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
            lockedAutoBiasSession := "New York • Start"
    if na(newYorkHigh) or na(newYorkLow)
        newYorkHigh := high
        newYorkLow := low
    else
        newYorkHigh := math.max(newYorkHigh, high)
        newYorkLow := math.min(newYorkLow, low)

if isNewYorkComplete and not newYorkBoxesCreated
    if "ORB Completion" == "ORB Completion"
        lockedAutoDailyBias := autoBiasCandidate
        lockedAuto10mState := autoBias10mBullish ? "Green" : autoBias10mBearish ? "Red" : "Neutral"
        lockedAuto2mState := autoBias2mBullishForLock ? "Green" : autoBias2mBearishForLock ? "Red" : "Neutral"
        lockedAutoBiasSession := "New York • ORB"
    displayMinutes = displayDurationHours * 60
    barInterval = timeframe.in_seconds(timeframe.period) / 60
    barsToEnd = math.floor(displayMinutes / barInterval)

    newYorkHighBox := box.new(newYorkStartBar, newYorkHigh, bar_index + barsToEnd, newYorkHigh, border_color = newYorkHighColor, border_width = newYorkLineThickness, bgcolor = color.new(newYorkHighColor, 95))
    newYorkLowBox := box.new(newYorkStartBar, newYorkLow, bar_index + barsToEnd, newYorkLow, border_color = newYorkLowColor, border_width = newYorkLineThickness, bgcolor = color.new(newYorkLowColor, 95))

    if newYorkShowLabel
        newYorkLabel := label.new(newYorkStartBar, newYorkHigh, "NEW YORK", style = label.style_label_down, color = newYorkHighColor, textcolor = color.white, size = size.small)

    if newYorkShow50
        newYork50Price = (newYorkHigh + newYorkLow) / 2
        newYork50Line := line.new(newYorkStartBar, newYork50Price, bar_index + barsToEnd, newYork50Price, color = newYork50Color, width = newYork50Thickness, style = getLineStyle(newYork50Style))

    if enableOrbFormedAlert
        alert(webhookMessage("orb_formed", "new_york", "none"), alert.freq_once_per_bar_close)

    newYorkBoxesCreated := true

if not na(newYorkHighBox) and not na(newYorkLowBox) and newYorkBoxesCreated and inNewYorkDisplayWindow
    box.set_right(newYorkHighBox, bar_index)
    box.set_right(newYorkLowBox, bar_index)
    if newYorkShow50 and not na(newYork50Line)
        line.set_x2(newYork50Line, bar_index)

// ==================== TRADE WINDOWS ====================
// Trading remains active after each ORB until the next session begins.
// This is deliberately separate from the visual display duration.
asiaTradeWindow =
     enableAsia and
     not isInAsiaRange and
     isTimeInWindow(
          currentHour, currentMinute,
          asiaEndH, asiaEndM,
          londonStartHour, londonStartMinute)

londonTradeWindow =
     enableLondon and
     not isInLondonRange and
     isTimeInWindow(
          currentHour, currentMinute,
          londonEndH, londonEndM,
          newYorkStartHour, newYorkStartMinute)

newYorkTradeWindow =
     enableNewYork and
     not isInNewYorkRange and
     isTimeInWindow(
          currentHour, currentMinute,
          newYorkEndH, newYorkEndM,
          asiaStartHour, asiaStartMinute)

// ==================== 2-MINUTE ORB ARMING ====================
// A completed 2-minute chart candle closing outside the finished 30-minute ORB
// arms the session immediately. A wick outside the ORB does not count.
// The breakout side does not force trade direction; the later completed EMA
// body-cross candle and bias/quality rules still determine long or short.
breaksAbove(orbHigh) =>
    close > orbHigh

breaksBelow(orbLow) =>
    close < orbLow

var int armedSession = 0
var int armedBreakoutDirection = 0  // +1 long, -1 short
var bool armedNeutralRange = false

if asiaStartBar == bar_index or londonStartBar == bar_index or newYorkStartBar == bar_index
    armedSession := 0
    armedBreakoutDirection := 0
    armedNeutralRange := false

// These are evaluated only on a completed 2-minute candle.
// The exact same booleans arm the strategy and fire the webhook, so the
// strategy and alert can never disagree.
asiaConfirmedCloseAbove =
     barstate.isconfirmed and
     asiaTradeWindow and
     asiaTradeCount < maxTradesPerSession and
     not na(asiaHigh) and
     close > asiaHigh

asiaConfirmedCloseBelow =
     barstate.isconfirmed and
     asiaTradeWindow and
     asiaTradeCount < maxTradesPerSession and
     not na(asiaLow) and
     close < asiaLow

londonConfirmedCloseAbove =
     barstate.isconfirmed and
     londonTradeWindow and
     londonTradeCount < maxTradesPerSession and
     not na(londonHigh) and
     close > londonHigh

londonConfirmedCloseBelow =
     barstate.isconfirmed and
     londonTradeWindow and
     londonTradeCount < maxTradesPerSession and
     not na(londonLow) and
     close < londonLow

newYorkConfirmedCloseAbove =
     barstate.isconfirmed and
     newYorkTradeWindow and
     newYorkTradeCount < maxTradesPerSession and
     not na(newYorkHigh) and
     close > newYorkHigh

newYorkConfirmedCloseBelow =
     barstate.isconfirmed and
     newYorkTradeWindow and
     newYorkTradeCount < maxTradesPerSession and
     not na(newYorkLow) and
     close < newYorkLow

// Any completed 2-minute close outside either ORB boundary arms the session.
// The breakout side does not determine the trade direction.
// Daily / session bias and the later EMA confirmation determine long or short.
// Neutral / sideways mode is deliberately separate from normal breakout continuation.
// It is available only when:
//   1) Manual Modes is selected,
//   2) Daily Bias is Off,
//   3) locked 1H session bias score is Neutral (session score = 0),
//   4) Neutral Session Mode = ORB Rejection.
neutralRangeActive =
     biasControlSource == "Manual Modes" and
     dailyBias == "Off" and
     lockedAutomaticSessionScore == 0 and
     neutralSessionMode == "ORB Rejection"

asiaBullishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     asiaTradeWindow and
     asiaTradeCount < maxTradesPerSession and
     not na(asiaHigh) and
     not na(asiaLow) and
     low < asiaLow and
     close > asiaLow and
     close < asiaHigh

asiaBearishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     asiaTradeWindow and
     asiaTradeCount < maxTradesPerSession and
     not na(asiaHigh) and
     not na(asiaLow) and
     high > asiaHigh and
     close < asiaHigh and
     close > asiaLow

londonBullishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     londonTradeWindow and
     londonTradeCount < maxTradesPerSession and
     not na(londonHigh) and
     not na(londonLow) and
     low < londonLow and
     close > londonLow and
     close < londonHigh

londonBearishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     londonTradeWindow and
     londonTradeCount < maxTradesPerSession and
     not na(londonHigh) and
     not na(londonLow) and
     high > londonHigh and
     close < londonHigh and
     close > londonLow

newYorkBullishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     newYorkTradeWindow and
     newYorkTradeCount < maxTradesPerSession and
     not na(newYorkHigh) and
     not na(newYorkLow) and
     low < newYorkLow and
     close > newYorkLow and
     close < newYorkHigh

newYorkBearishRejection =
     barstate.isconfirmed and
     neutralRangeActive and
     newYorkTradeWindow and
     newYorkTradeCount < maxTradesPerSession and
     not na(newYorkHigh) and
     not na(newYorkLow) and
     high > newYorkHigh and
     close < newYorkHigh and
     close > newYorkLow

// Normal continuation arming is suppressed while Neutral ORB Rejection mode is active.
// Otherwise, any confirmed close outside either ORB side arms the session.
asiaMatchingBreakout =
     not neutralRangeActive and
     (asiaConfirmedCloseAbove or asiaConfirmedCloseBelow)

londonMatchingBreakout =
     not neutralRangeActive and
     (londonConfirmedCloseAbove or londonConfirmedCloseBelow)

newYorkMatchingBreakout =
     not neutralRangeActive and
     (newYorkConfirmedCloseAbove or newYorkConfirmedCloseBelow)

if armedSession == 0
    if asiaBullishRejection or asiaBearishRejection
        armedSession := 1
        armedBreakoutDirection := asiaBullishRejection ? 1 : -1
        armedNeutralRange := true

    else if londonBullishRejection or londonBearishRejection
        armedSession := 2
        armedBreakoutDirection := londonBullishRejection ? 1 : -1
        armedNeutralRange := true

    else if newYorkBullishRejection or newYorkBearishRejection
        armedSession := 3
        armedBreakoutDirection := newYorkBullishRejection ? 1 : -1
        armedNeutralRange := true

    else if asiaMatchingBreakout
        armedSession := 1
        armedBreakoutDirection := asiaConfirmedCloseAbove ? 1 : -1
        armedNeutralRange := false
        if enableFirstBreakoutAlert
            alert(
                 webhookMessage(
                      "first_breakout",
                      "asia",
                      armedBreakoutDirection == 1 ? "above" : "below"),
                 alert.freq_once_per_bar_close)

    else if londonMatchingBreakout
        armedSession := 2
        armedBreakoutDirection := londonConfirmedCloseAbove ? 1 : -1
        armedNeutralRange := false
        if enableFirstBreakoutAlert
            alert(
                 webhookMessage(
                      "first_breakout",
                      "london",
                      armedBreakoutDirection == 1 ? "above" : "below"),
                 alert.freq_once_per_bar_close)

    else if newYorkMatchingBreakout
        armedSession := 3
        armedBreakoutDirection := newYorkConfirmedCloseAbove ? 1 : -1
        armedNeutralRange := false
        if enableFirstBreakoutAlert
            alert(
                 webhookMessage(
                      "first_breakout",
                      "new_york",
                      armedBreakoutDirection == 1 ? "above" : "below"),
                 alert.freq_once_per_bar_close)

armedTradeWindow =
     armedSession == 1 ? asiaTradeWindow :
     armedSession == 2 ? londonTradeWindow :
     armedSession == 3 ? newYorkTradeWindow :
     false

if armedSession != 0 and not armedTradeWindow
    armedSession := 0
    armedBreakoutDirection := 0
    armedNeutralRange := false

// ==================== TRADE COLOURING ====================
// Live colours while a trade is open.
liveTradeCandleColor =
     strategy.position_size > 0 ?
         (close >= strategy.position_avg_price ? color.lime : color.red) :
     strategy.position_size < 0 ?
         (close <= strategy.position_avg_price ? color.lime : color.red) :
     na

barcolor(showLiveTradeCandles ? liveTradeCandleColor : na)

// Persistent trade-result boxes.
// A box is created when a trade opens, expanded while the trade is active,
// and recoloured green/red when the trade closes. Historical completed trades
// remain visible after script recalculation.
var box activeTradeBox = na
var float activeTradeHigh = na
var float activeTradeLow = na
var int processedClosedTrades = 0

tradeIsOpen = strategy.position_size != 0
tradeJustOpened = tradeIsOpen and strategy.position_size[1] == 0
tradeJustClosed = not tradeIsOpen and strategy.position_size[1] != 0
newClosedTrade = tradeJustClosed and strategy.closedtrades > processedClosedTrades

if tradeJustOpened
    activeTradeHigh := high
    activeTradeLow := low

    if showHistoricalTradeHighlights
        activeTradeBox := box.new(
             left = bar_index,
             top = activeTradeHigh,
             right = bar_index + 1,
             bottom = activeTradeLow,
             xloc = xloc.bar_index,
             border_color = color.new(color.gray, 0),
             border_width = 2,
             bgcolor = color.new(color.gray, 70))

if tradeIsOpen
    activeTradeHigh := na(activeTradeHigh) ? high : math.max(activeTradeHigh, high)
    activeTradeLow := na(activeTradeLow) ? low : math.min(activeTradeLow, low)

    if showHistoricalTradeHighlights and not na(activeTradeBox)
        box.set_right(activeTradeBox, bar_index + 1)
        box.set_top(activeTradeBox, activeTradeHigh)
        box.set_bottom(activeTradeBox, activeTradeLow)

// Actual-fill Entry / Stop / Target levels.
var line activeEntryLine = na
var line activeStopLine = na
var line activeTargetLine = na
var label activeEntryLabel = na
var label activeStopLabel = na
var label activeTargetLabel = na
var float displayedEntryPrice = na
var float displayedStopPrice = na
var float displayedTargetPrice = na

if tradeJustOpened
    displayedEntryPrice := strategy.position_avg_price
    displayedStopPrice :=
         strategy.position_size > 0 ?
             displayedEntryPrice - stopTicks * syminfo.mintick :
             displayedEntryPrice + stopTicks * syminfo.mintick
    displayedTargetPrice :=
         strategy.position_size > 0 ?
             displayedEntryPrice + targetTicks * syminfo.mintick :
             displayedEntryPrice - targetTicks * syminfo.mintick

    if showEntryRiskLevels
        activeEntryLine := line.new(bar_index, displayedEntryPrice, bar_index + 1, displayedEntryPrice, xloc = xloc.bar_index, extend = extend.right, color = color.blue, width = 2)
        activeStopLine := line.new(bar_index, displayedStopPrice, bar_index + 1, displayedStopPrice, xloc = xloc.bar_index, extend = extend.right, color = color.red, width = 2, style = line.style_dashed)
        activeTargetLine := line.new(bar_index, displayedTargetPrice, bar_index + 1, displayedTargetPrice, xloc = xloc.bar_index, extend = extend.right, color = color.lime, width = 2, style = line.style_dashed)

        activeEntryLabel := label.new(bar_index, displayedEntryPrice, "ENTRY  " + str.tostring(displayedEntryPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = color.blue, size = size.small)
        activeStopLabel := label.new(bar_index, displayedStopPrice, "SL  " + str.tostring(displayedStopPrice, format.mintick) + "  •  " + str.tostring(stopTicks) + " ticks", xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = color.red, size = size.small)
        activeTargetLabel := label.new(bar_index, displayedTargetPrice, "TP  " + str.tostring(displayedTargetPrice, format.mintick) + "  •  " + str.tostring(targetTicks) + " ticks  •  " + str.tostring(riskRewardRatio, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = color.green, size = size.small)

if tradeIsOpen and showEntryRiskLevels
    if not na(activeEntryLabel)
        label.set_x(activeEntryLabel, bar_index)
    if not na(activeStopLabel)
        label.set_x(activeStopLabel, bar_index)
    if not na(activeTargetLabel)
        label.set_x(activeTargetLabel, bar_index)

if newClosedTrade and showEntryRiskLevels
    if not na(activeEntryLine)
        line.set_extend(activeEntryLine, extend.none)
        line.set_x2(activeEntryLine, bar_index)
    if not na(activeStopLine)
        line.set_extend(activeStopLine, extend.none)
        line.set_x2(activeStopLine, bar_index)
    if not na(activeTargetLine)
        line.set_extend(activeTargetLine, extend.none)
        line.set_x2(activeTargetLine, bar_index)

if newClosedTrade
    lastTradeIndex = strategy.closedtrades - 1
    firstTradeBar = strategy.closedtrades.entry_bar_index(lastTradeIndex)
    lastTradeBar = strategy.closedtrades.exit_bar_index(lastTradeIndex)
    entryPrice = strategy.closedtrades.entry_price(lastTradeIndex)
    exitPrice = strategy.closedtrades.exit_price(lastTradeIndex)
    lastTradeProfit = strategy.closedtrades.profit(lastTradeIndex)

    isWinningTrade = lastTradeProfit >= 0
    completedBorderColor = isWinningTrade ? color.lime : color.red
    completedBackgroundColor = isWinningTrade ? winningTradeColor : losingTradeColor

    finalTradeHigh = math.max(
         na(activeTradeHigh) ? high : activeTradeHigh,
         math.max(high, math.max(entryPrice, exitPrice)))

    finalTradeLow = math.min(
         na(activeTradeLow) ? low : activeTradeLow,
         math.min(low, math.min(entryPrice, exitPrice)))

    if showHistoricalTradeHighlights
        if na(activeTradeBox)
            activeTradeBox := box.new(
                 left = firstTradeBar,
                 top = finalTradeHigh,
                 right = lastTradeBar + 1,
                 bottom = finalTradeLow,
                 xloc = xloc.bar_index,
                 border_color = completedBorderColor,
                 border_width = 3,
                 bgcolor = completedBackgroundColor)
        else
            box.set_left(activeTradeBox, firstTradeBar)
            box.set_right(activeTradeBox, lastTradeBar + 1)
            box.set_top(activeTradeBox, finalTradeHigh)
            box.set_bottom(activeTradeBox, finalTradeLow)
            box.set_border_color(activeTradeBox, completedBorderColor)
            box.set_border_width(activeTradeBox, 3)
            box.set_bgcolor(activeTradeBox, completedBackgroundColor)

    processedClosedTrades := strategy.closedtrades
    activeTradeBox := na
    activeTradeHigh := na
    activeTradeLow := na
    activeEntryLine := na
    activeStopLine := na
    activeTargetLine := na
    activeEntryLabel := na
    activeStopLabel := na
    activeTargetLabel := na
    displayedEntryPrice := na
    displayedStopPrice := na
    displayedTargetPrice := na



//=============================================================================
// 1-HOUR BIAS DASHBOARD
// Informational only: this block does not modify entries, exits, or backtests.
// All factor calculations use confirmed 1-hour data while the chart remains 2m.
//=============================================================================
bhGroupGeneral = "1H Bias — General"
bhShowDashboard = input.bool(true, "Show 1H bias dashboard", group = bhGroupGeneral, display = display.none)
bhHistoricalReview = input.bool(false, "Historical review mode", group = bhGroupGeneral, display = display.none)
bhReviewTime = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Review date and time", group = bhGroupGeneral, display = display.none, confirm = true)
// The 1H bias engine uses the exact same timezone and session-start events
// as the ORB engine. This prevents UTC/BST/DST drift.
bhSessionTZ = timezone

bhGroupTrend = "1H Bias — Trend"
bhEmaLength = input.int(200, "EMA length", minval = 1, group = bhGroupTrend, display = display.none)
bhEmaWeight = input.int(3, "EMA importance (0-3)", minval = 0, maxval = 3, group = bhGroupTrend, display = display.none)
bhStAtrLength = input.int(10, "Supertrend ATR length", minval = 1, group = bhGroupTrend, display = display.none)
bhStFactor = input.float(3.0, "Supertrend factor", minval = 0.01, step = 0.01, group = bhGroupTrend, display = display.none)
bhStWeight = input.int(3, "Supertrend importance (0-3)", minval = 0, maxval = 3, group = bhGroupTrend, display = display.none)

bhGroupVWAP = "1H Bias — VWAP"
bhSessionVwapWeight = input.int(2, "Session VWAP importance (0-3)", minval = 0, maxval = 3, group = bhGroupVWAP, display = display.none)
bhWeeklyVwapWeight = input.int(3, "Weekly VWAP importance (0-3)", minval = 0, maxval = 3, group = bhGroupVWAP, display = display.none)

bhGroupLevels = "1H Bias — Previous-Day Levels"
bhMidWeight = input.int(2, "Previous-day midpoint importance (0-3)", minval = 0, maxval = 3, group = bhGroupLevels, display = display.none)
bhRangeWeight = input.int(1, "Previous-day high/low importance (0-3)", minval = 0, maxval = 3, group = bhGroupLevels, display = display.none)

bhGroupADX = "1H Bias — ADX / DMI"
bhDiLength = input.int(3, "DI length", minval = 1, group = bhGroupADX, display = display.none)
bhAdxSmoothing = input.int(3, "ADX smoothing", minval = 1, group = bhGroupADX, display = display.none)
bhAdxThreshold = input.float(20.0, "ADX strength threshold", minval = 0.0, step = 0.5, group = bhGroupADX, display = display.none)
bhAdxWeight = input.int(2, "ADX / DI importance (0-3)", minval = 0, maxval = 3, group = bhGroupADX, display = display.none)

// Helper functions execute inside their 1-hour request.security() contexts.
bhStValue() =>
    [bhSt_, bhDir_] = ta.supertrend(bhStFactor, bhStAtrLength)
    bhSt_

bhStDir() =>
    [bhSt_, bhDir_] = ta.supertrend(bhStFactor, bhStAtrLength)
    bhDir_

bhDiPlusValue() =>
    [bhPlus_, bhMinus_, bhAdx_] = ta.dmi(bhDiLength, bhAdxSmoothing)
    bhPlus_

bhDiMinusValue() =>
    [bhPlus_, bhMinus_, bhAdx_] = ta.dmi(bhDiLength, bhAdxSmoothing)
    bhMinus_

bhAdxValue() =>
    [bhPlus_, bhMinus_, bhAdx_] = ta.dmi(bhDiLength, bhAdxSmoothing)
    bhAdx_

// Each series is requested separately to avoid multiline tuple parsing issues.
// lookahead_off means the 2-minute chart receives only confirmed 1-hour values.
bhHourCloseTime = request.security(syminfo.tickerid, "60", time_close, barmerge.gaps_off, barmerge.lookahead_off)
bhClose = request.security(syminfo.tickerid, "60", close, barmerge.gaps_off, barmerge.lookahead_off)
bhEma = request.security(syminfo.tickerid, "60", ta.ema(close, bhEmaLength), barmerge.gaps_off, barmerge.lookahead_off)
bhSupertrend = request.security(syminfo.tickerid, "60", bhStValue(), barmerge.gaps_off, barmerge.lookahead_off)
bhStDirection = request.security(syminfo.tickerid, "60", bhStDir(), barmerge.gaps_off, barmerge.lookahead_off)
bhSessionVWAP = request.security(syminfo.tickerid, "60", ta.vwap(hlc3), barmerge.gaps_off, barmerge.lookahead_off)
bhWeeklyVWAP = request.security(syminfo.tickerid, "60", ta.vwap(hlc3, timeframe.change("1W")), barmerge.gaps_off, barmerge.lookahead_off)
bhDiPlus = request.security(syminfo.tickerid, "60", bhDiPlusValue(), barmerge.gaps_off, barmerge.lookahead_off)
bhDiMinus = request.security(syminfo.tickerid, "60", bhDiMinusValue(), barmerge.gaps_off, barmerge.lookahead_off)
bhAdx = request.security(syminfo.tickerid, "60", bhAdxValue(), barmerge.gaps_off, barmerge.lookahead_off)

// Previous-day levels are fixed daily values and are safe to map to the 2m chart.
bhPrevHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
bhPrevLow = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)
bhPrevMid = (bhPrevHigh + bhPrevLow) / 2.0

bhEmaState = bhClose > bhEma ? 1 : bhClose < bhEma ? -1 : 0
bhStState = bhStDirection < 0 ? 1 : bhStDirection > 0 ? -1 : 0
bhSessionVwapState = bhClose > bhSessionVWAP ? 1 : bhClose < bhSessionVWAP ? -1 : 0
bhWeeklyVwapState = bhClose > bhWeeklyVWAP ? 1 : bhClose < bhWeeklyVWAP ? -1 : 0
bhMidState = bhClose > bhPrevMid ? 1 : bhClose < bhPrevMid ? -1 : 0
bhRangeState = bhClose > bhPrevHigh ? 1 : bhClose < bhPrevLow ? -1 : 0
bhAdxState = bhAdx >= bhAdxThreshold ? (bhDiPlus > bhDiMinus ? 1 : bhDiMinus > bhDiPlus ? -1 : 0) : 0

bhEmaScore = bhEmaState * bhEmaWeight
bhStScore = bhStState * bhStWeight
bhSessionVwapScore = bhSessionVwapState * bhSessionVwapWeight
bhWeeklyVwapScore = bhWeeklyVwapState * bhWeeklyVwapWeight
bhMidScore = bhMidState * bhMidWeight
bhRangeScore = bhRangeState * bhRangeWeight
bhAdxScore = bhAdxState * bhAdxWeight

bhTotalScore = bhEmaScore + bhStScore + bhSessionVwapScore + bhWeeklyVwapScore + bhMidScore + bhRangeScore + bhAdxScore
bhMaxScore = bhEmaWeight + bhStWeight + bhSessionVwapWeight + bhWeeklyVwapWeight + bhMidWeight + bhRangeWeight + bhAdxWeight
bhBullScore = math.max(bhEmaScore, 0) + math.max(bhStScore, 0) + math.max(bhSessionVwapScore, 0) + math.max(bhWeeklyVwapScore, 0) + math.max(bhMidScore, 0) + math.max(bhRangeScore, 0) + math.max(bhAdxScore, 0)
bhBearScore = math.abs(math.min(bhEmaScore, 0)) + math.abs(math.min(bhStScore, 0)) + math.abs(math.min(bhSessionVwapScore, 0)) + math.abs(math.min(bhWeeklyVwapScore, 0)) + math.abs(math.min(bhMidScore, 0)) + math.abs(math.min(bhRangeScore, 0)) + math.abs(math.min(bhAdxScore, 0))
bhScorePct = bhMaxScore > 0 ? 100.0 * bhTotalScore / bhMaxScore : 0.0

// Session starts are detected on the visible chart, but the values being frozen
// are the latest confirmed 1-hour values from the engine above.
bhAsiaStart = enableAsia and asiaStartBar == bar_index
bhLondonStart = enableLondon and londonStartBar == bar_index
bhNewYorkStart = enableNewYork and newYorkStartBar == bar_index

// Current session comes from the same ORB trade-window engine.
bhInAsia = isInAsiaRange or asiaTradeWindow
bhInLondon = isInLondonRange or londonTradeWindow
bhInNewYork = isInNewYorkRange or newYorkTradeWindow

var string bhLockedSession = "Waiting for Asia"
var int bhLockedTime = na
var int bhLockedBarIndex = na
var int bhLockedEmaState = 0
var int bhLockedStState = 0
var int bhLockedSessionVwapState = 0
var int bhLockedWeeklyVwapState = 0
var int bhLockedMidState = 0
var int bhLockedRangeState = 0
var int bhLockedAdxState = 0
var float bhLockedEma = na
var float bhLockedSupertrend = na
var float bhLockedSessionVWAP = na
var float bhLockedWeeklyVWAP = na
var float bhLockedPrevMid = na
var float bhLockedPrevHigh = na
var float bhLockedPrevLow = na
var float bhLockedAdx = na
var float bhLockedDiPlus = na
var float bhLockedDiMinus = na
var int bhLockedTotalScore = 0
var int bhLockedBullScore = 0
var int bhLockedBearScore = 0
var float bhLockedScorePct = 0.0

var string bhAsiaHistory = "Pending"
var string bhLondonHistory = "Pending"
var string bhNewYorkHistory = "Pending"
var float bhAsiaLockedPct = na
var float bhLondonLockedPct = na
var float bhNewYorkLockedPct = na
var int bhAsiaLockedScore = na
var int bhLondonLockedScore = na
var int bhNewYorkLockedScore = na

bhBiasText(float pct) =>
    pct >= 60 ? "STRONG BULLISH" : pct >= 25 ? "BULLISH" : pct <= -60 ? "STRONG BEARISH" : pct <= -25 ? "BEARISH" : "NEUTRAL"

bhActionText(float pct) =>
    pct >= 60 ? "LONGS ONLY" : pct >= 25 ? "LONGS PREFERRED" : pct <= -60 ? "SHORTS ONLY" : pct <= -25 ? "SHORTS PREFERRED" : "NO CLEAR EDGE"

bhShortAction(float pct) =>
    pct >= 60 ? "Longs only" : pct >= 25 ? "Longs preferred" : pct <= -60 ? "Shorts only" : pct <= -25 ? "Shorts preferred" : "Neutral"

if bhAsiaStart
    bhAsiaLockedPct := bhScorePct
    bhAsiaLockedScore := bhTotalScore
    bhAsiaHistory := bhShortAction(bhAsiaLockedPct)
    bhLondonHistory := "Pending"
    bhNewYorkHistory := "Pending"

if bhLondonStart
    bhLondonLockedPct := bhScorePct
    bhLondonLockedScore := bhTotalScore
    bhLondonHistory := bhShortAction(bhLondonLockedPct)

if bhNewYorkStart
    bhNewYorkLockedPct := bhScorePct
    bhNewYorkLockedScore := bhTotalScore
    bhNewYorkHistory := bhShortAction(bhNewYorkLockedPct)

if bhAsiaStart or bhLondonStart or bhNewYorkStart
    bhLockedSession := bhAsiaStart ? "Asia" : bhLondonStart ? "London" : "NY"
    bhLockedTime := time
    bhLockedBarIndex := bar_index
    bhLockedEmaState := bhEmaState
    bhLockedStState := bhStState
    bhLockedSessionVwapState := bhSessionVwapState
    bhLockedWeeklyVwapState := bhWeeklyVwapState
    bhLockedMidState := bhMidState
    bhLockedRangeState := bhRangeState
    bhLockedAdxState := bhAdxState
    bhLockedEma := bhEma
    bhLockedSupertrend := bhSupertrend
    bhLockedSessionVWAP := bhSessionVWAP
    bhLockedWeeklyVWAP := bhWeeklyVWAP
    bhLockedPrevMid := bhPrevMid
    bhLockedPrevHigh := bhPrevHigh
    bhLockedPrevLow := bhPrevLow
    bhLockedAdx := bhAdx
    bhLockedDiPlus := bhDiPlus
    bhLockedDiMinus := bhDiMinus
    bhLockedTotalScore := bhTotalScore
    bhLockedBullScore := bhBullScore
    bhLockedBearScore := bhBearScore
    bhLockedScorePct := bhScorePct

// ==================== 2-MINUTE EMA ENTRY ====================
ema = ta.ema(close, emaLength)
plot(ema, "20 EMA", color = color.orange, linewidth = 2, display = display.pane)
isTwoMinuteChart = timeframe.isminutes and timeframe.multiplier == 2

// True EMA body-cross events.
// A bullish cross opens at/below the EMA and closes above it.
// A bearish cross opens at/above the EMA and closes below it.
rawBullishBodyCross = open <= ema and close > ema
rawBearishBodyCross = open >= ema and close < ema

// ==================== ENTRY QUALITY SCORE ====================
// The EMA cross remains the trigger. These conditions score the completed
// crossing candle using bias, EMA slope, candle strength and recent chop.
emaRising = ema > ema[1] and ema[1] >= ema[2]
emaFalling = ema < ema[1] and ema[1] <= ema[2]

crossCandleRange = high - low
crossCandleBody = math.abs(close - open)
crossBodyFraction = crossCandleRange > 0 ? crossCandleBody / crossCandleRange : 0.0

longCloseStrong =
     crossCandleRange > 0 and
     close >= low + crossCandleRange * minimumCloseLocation

shortCloseStrong =
     crossCandleRange > 0 and
     close <= high - crossCandleRange * minimumCloseLocation

emaSide1 = close[1] > ema[1] ? 1 : close[1] < ema[1] ? -1 : 0
emaSide2 = close[2] > ema[2] ? 1 : close[2] < ema[2] ? -1 : 0
emaSide3 = close[3] > ema[3] ? 1 : close[3] < ema[3] ? -1 : 0

recentEmaFlips =
     (emaSide1 != emaSide2 ? 1 : 0) +
     (emaSide2 != emaSide3 ? 1 : 0)

notRecentlyChoppy = recentEmaFlips <= maximumRecentEmaFlips

longBiasPoints =
     (bhLockedScorePct >= 25 ? 2 : 0) +
     (bhLockedScorePct >= 60 ? 1 : 0)

shortBiasPoints =
     (bhLockedScorePct <= -25 ? 2 : 0) +
     (bhLockedScorePct <= -60 ? 1 : 0)

longEntryQualityScore =
     longBiasPoints +
     (emaRising ? 1 : 0) +
     (crossBodyFraction >= minimumBodyFraction ? 1 : 0) +
     (longCloseStrong ? 1 : 0) +
     (notRecentlyChoppy ? 1 : 0)

shortEntryQualityScore =
     shortBiasPoints +
     (emaFalling ? 1 : 0) +
     (crossBodyFraction >= minimumBodyFraction ? 1 : 0) +
     (shortCloseStrong ? 1 : 0) +
     (notRecentlyChoppy ? 1 : 0)

longQualityPassed =
     not useEntryQualityFilter or
     longEntryQualityScore >= minimumEntryQualityScore

shortQualityPassed =
     not useEntryQualityFilter or
     shortEntryQualityScore >= minimumEntryQualityScore

// ==================== 7-CANDLE EMA RECROSS CONFIRMATION ====================
// The first body cross creates a provisional direction.
// Every opposite body recross flips that provisional direction.
// This may continue for up to seven crossing candles.
// The last cross is confirmed only when the following completed candle does
// not body-cross back and remains closed on the provisional side of the EMA.
var bool emaCrossSequenceActive = false
var int emaProvisionalDirection = 0       // +1 long, -1 short
var int emaCrossCount = 0
var bool emaProvisionalQualityPassed = false
var int emaProvisionalQualityScore = na
var int emaLastCrossBar = na

bool bullishEmaCrossConfirmed = false
bool bearishEmaCrossConfirmed = false
int confirmedEmaQualityScore = na

bullishEmaCrossConfirmed := false
bearishEmaCrossConfirmed := false
confirmedEmaQualityScore := na

emaSequenceEligible =
     barstate.isconfirmed and
     isTwoMinuteChart and
     armedSession != 0

if not emaSequenceEligible
    emaCrossSequenceActive := false
    emaProvisionalDirection := 0
    emaCrossCount := 0
    emaProvisionalQualityPassed := false
    emaProvisionalQualityScore := na
    emaLastCrossBar := na
else
    currentCrossDirection =
         rawBullishBodyCross ? 1 :
         rawBearishBodyCross ? -1 :
         0

    if currentCrossDirection != 0
        if not emaCrossSequenceActive
            emaCrossSequenceActive := true
            emaCrossCount := 1
        else if currentCrossDirection != emaProvisionalDirection
            // Opposite recross: flip the provisional side.
            // After seven crossing candles, begin a fresh sequence from this cross.
            emaCrossCount := emaCrossCount >= 7 ? 1 : emaCrossCount + 1

        emaProvisionalDirection := currentCrossDirection
        emaProvisionalQualityPassed :=
             currentCrossDirection == 1 ?
                 longQualityPassed :
                 shortQualityPassed
        emaProvisionalQualityScore :=
             currentCrossDirection == 1 ?
                 longEntryQualityScore :
                 shortEntryQualityScore
        emaLastCrossBar := bar_index

    else if emaCrossSequenceActive and bar_index == emaLastCrossBar + 1
        // The immediate next completed candle confirms the last cross only
        // when it stays on that same side and does not body-cross back.
        longStayedAbove =
             emaProvisionalDirection == 1 and
             close > ema

        shortStayedBelow =
             emaProvisionalDirection == -1 and
             close < ema

        bullishEmaCrossConfirmed :=
             longStayedAbove and
             emaProvisionalQualityPassed

        bearishEmaCrossConfirmed :=
             shortStayedBelow and
             emaProvisionalQualityPassed

        confirmedEmaQualityScore := emaProvisionalQualityScore

        // Whether confirmed or invalidated, that sequence is now complete.
        emaCrossSequenceActive := false
        emaProvisionalDirection := 0
        emaCrossCount := 0
        emaProvisionalQualityPassed := false
        emaProvisionalQualityScore := na
        emaLastCrossBar := na

sessionBullish = bhLockedScorePct >= 25
sessionBearish = bhLockedScorePct <= -25
strongSessionBullish = bhLockedScorePct >= 60
strongSessionBearish = bhLockedScorePct <= -60

automaticDailyScoreLive =
     activeDailyBias == "Bullish" ? 2 :
     activeDailyBias == "Bearish" ? -2 :
     0

automaticSessionScoreLive =
     strongSessionBullish ? 2 :
     sessionBullish ? 1 :
     strongSessionBearish ? -2 :
     sessionBearish ? -1 :
     0

automaticCombinedScoreLive = automaticDailyScoreLive + automaticSessionScoreLive

asiaDirectionLockEvent =
     asiaBoxesCreated and not asiaBoxesCreated[1]

londonDirectionLockEvent =
     londonBoxesCreated and not londonBoxesCreated[1]

newYorkDirectionLockEvent =
     newYorkBoxesCreated and not newYorkBoxesCreated[1]

directionLockEvent =
     asiaDirectionLockEvent or
     londonDirectionLockEvent or
     newYorkDirectionLockEvent

if directionLockEvent
    lockedAutomaticDailyScore := automaticDailyScoreLive
    lockedAutomaticSessionScore := automaticSessionScoreLive
    lockedAutomaticCombinedScore := automaticCombinedScoreLive
    // Direction hierarchy:
    // 1. Matching 10m + 2m Supertrends set the automatic trend direction.
    // 2. If they are mixed, the fresher completed 2m Supertrend decides.
    // 3. The locked 1H bias is used only when trend data is unavailable.
    lockedAutomaticDecision :=
         automaticDailyScoreLive > 0 ? "LONG ONLY" :
         automaticDailyScoreLive < 0 ? "SHORT ONLY" :
         autoBias2mBullishForLock ? "LONG ONLY" :
         autoBias2mBearishForLock ? "SHORT ONLY" :
         automaticSessionScoreLive > 0 ? "LONG ONLY" :
         automaticSessionScoreLive < 0 ? "SHORT ONLY" :
         "NO TRADE"
    lockedDecisionSession :=
         asiaDirectionLockEvent ? "Asia" :
         londonDirectionLockEvent ? "London" :
         "New York"
    lockedDecisionTime := time

automaticLongAllowed = lockedAutomaticDecision == "LONG ONLY"
automaticShortAllowed = lockedAutomaticDecision == "SHORT ONLY"

sessionNeutral = not sessionBullish and not sessionBearish

manualLongAllowed =
     dailyBias == "Off" or
     dailyBias == "Bullish"

manualShortAllowed =
     dailyBias == "Off" or
     dailyBias == "Bearish"

dailyPreferredLong =
     dailyBias == "Off" ?
         not sessionBearish :
     dailyBias == "Bullish" ?
         not strongSessionBearish :
         strongSessionBullish

dailyPreferredShort =
     dailyBias == "Off" ?
         not sessionBullish :
     dailyBias == "Bearish" ?
         not strongSessionBullish :
         strongSessionBearish

manualModeLongAllowed =
     biasControlMode == "Daily Bias Only" ?
         manualLongAllowed :
     biasControlMode == "Session Bias Only" ?
         (sessionBullish or sessionNeutral) :
         dailyPreferredLong

manualModeShortAllowed =
     biasControlMode == "Daily Bias Only" ?
         manualShortAllowed :
     biasControlMode == "Session Bias Only" ?
         (sessionBearish or sessionNeutral) :
         dailyPreferredShort

longAllowed =
     armedNeutralRange ?
         true :
     biasControlSource == "Automatic Scoring" ?
         automaticLongAllowed :
         manualModeLongAllowed

shortAllowed =
     armedNeutralRange ?
         true :
     biasControlSource == "Automatic Scoring" ?
         automaticShortAllowed :
         manualModeShortAllowed

activeBiasDecision =
     biasControlSource == "Automatic Scoring" ?
         lockedAutomaticDecision :
         biasControlMode

automaticDailyScore = lockedAutomaticDailyScore
automaticSessionScore = lockedAutomaticSessionScore
automaticCombinedScore = lockedAutomaticCombinedScore
automaticBiasDecision = lockedAutomaticDecision

// Submit the order on the EMA-interaction candle's close.
// With process_orders_on_close=false, the fill occurs at the open of the next
// 2-minute candle. Example: interaction at 13:52, entry at 13:54.
// A later session may add one more trade while an earlier session remains open.
// Opposite-direction entries are blocked because TradingView nets positions.
// Trades within a session are sequential, never pyramided.
// A second session trade may only be taken after the first trade has fully closed.
canOpenAnotherTrade = strategy.opentrades == 0 and strategy.position_size == 0
canAddLong = strategy.position_size == 0
canAddShort = strategy.position_size == 0

// ==================== DIAGNOSTICS ====================
diagSession =
     asiaTradeWindow or isInAsiaRange ? "ASIA" :
     londonTradeWindow or isInLondonRange ? "LONDON" :
     newYorkTradeWindow or isInNewYorkRange ? "NY" :
     "NONE"

diagOrbState =
     (asiaTradeWindow and not na(asiaHigh) and not na(asiaLow)) or
     (londonTradeWindow and not na(londonHigh) and not na(londonLow)) or
     (newYorkTradeWindow and not na(newYorkHigh) and not na(newYorkLow)) ?
         "COMPLETE" :
     (isInAsiaRange or isInLondonRange or isInNewYorkRange) ?
         "BUILDING" :
         "WAITING"

diagArmed =
     armedSession == 0 ? "NONE" :
     armedBreakoutDirection == 1 ? "LONG" :
     armedBreakoutDirection == -1 ? "SHORT" :
     "UNKNOWN"

diagEma =
     rawBullishBodyCross ? "RAW LONG CROSS" :
     rawBearishBodyCross ? "RAW SHORT CROSS" :
     bullishEmaCrossConfirmed ? "LONG CONFIRMED" :
     bearishEmaCrossConfirmed ? "SHORT CONFIRMED" :
     emaCrossSequenceActive ?
         (emaProvisionalDirection == 1 ? "PROV LONG " + str.tostring(emaCrossCount) :
          emaProvisionalDirection == -1 ? "PROV SHORT " + str.tostring(emaCrossCount) :
          "PROVISIONAL") :
         "NONE"

diagCurrentSessionLimitReached =
     (asiaTradeWindow and asiaTradeCount >= maxTradesPerSession) or
     (londonTradeWindow and londonTradeCount >= maxTradesPerSession) or
     (newYorkTradeWindow and newYorkTradeCount >= maxTradesPerSession)

diagReason =
     not isTwoMinuteChart ? "NOT 2M" :
     lockedDecisionSession == "Waiting" ? "WAITING FOR ORB LOCK" :
     diagCurrentSessionLimitReached ? "SESSION TRADE LIMIT REACHED" :
     armedSession == 0 ? "WAITING FOR VALID ORB EVENT" :
     not canOpenAnotherTrade ? "WAITING FOR CURRENT TRADE TO CLOSE" :
     longAllowed and not canAddLong ? "OPPOSITE POSITION OPEN" :
     shortAllowed and not canAddShort ? "OPPOSITE POSITION OPEN" :
     not longAllowed and not shortAllowed ? "BLOCKED BY BIAS MODE" :
     longAllowed and not bullishEmaCrossConfirmed ? "WAITING FOR LONG EMA CONFIRM" :
     shortAllowed and not bearishEmaCrossConfirmed ? "WAITING FOR SHORT EMA CONFIRM" :
     longAllowed and useEntryQualityFilter and not longQualityPassed ? "LONG QUALITY FAIL" :
     shortAllowed and useEntryQualityFilter and not shortQualityPassed ? "SHORT QUALITY FAIL" :
     "ENTRY CONDITIONS READY"

if showDiagnostics and isTwoMinuteChart and barstate.isconfirmed
    diagText =
         "DBG " + diagSession +
         "\nORB: " + diagOrbState +
         " | Armed: " + diagArmed +
         "\nBias: " + (biasControlSource == "Automatic Scoring" ? "AUTO" : biasControlMode) +
         " | Auto: " + lockedAutomaticDecision +
         "\nEMA: " + diagEma +
         "\nQ L/S: " + str.tostring(longEntryQualityScore) + "/" + str.tostring(shortEntryQualityScore) +
         "\nTrades A/L/NY: " + str.tostring(asiaTradeCount) + "/" + str.tostring(londonTradeCount) + "/" + str.tostring(newYorkTradeCount) +
         "\n" + diagReason

    label.new(
         bar_index,
         high,
         diagText,
         xloc = xloc.bar_index,
         style = label.style_label_down,
         textcolor = color.white,
         color = color.new(color.black, 70),
         size = size.tiny)

longSignal =
     isTwoMinuteChart and
     lockedDecisionSession != "Waiting" and
     armedSession != 0 and
     longAllowed and
     canOpenAnotherTrade and
     canAddLong and
     bullishEmaCrossConfirmed

shortSignal =
     isTwoMinuteChart and
     lockedDecisionSession != "Waiting" and
     armedSession != 0 and
     shortAllowed and
     canOpenAnotherTrade and
     canAddShort and
     bearishEmaCrossConfirmed

if longSignal
    if armedSession == 1
        strategy.entry("Asia Long", strategy.long)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "asia", "long"), alert.freq_once_per_bar_close)
        asiaTradeCount += 1
    else if armedSession == 2
        strategy.entry("London Long", strategy.long)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "london", "long"), alert.freq_once_per_bar_close)
        londonTradeCount += 1
    else if armedSession == 3
        strategy.entry("NY Long", strategy.long)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "new_york", "long"), alert.freq_once_per_bar_close)
        newYorkTradeCount += 1

    armedSession := 0
    armedBreakoutDirection := 0
    armedNeutralRange := false

else if shortSignal
    if armedSession == 1
        strategy.entry("Asia Short", strategy.short)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "asia", "short"), alert.freq_once_per_bar_close)
        asiaTradeCount += 1
    else if armedSession == 2
        strategy.entry("London Short", strategy.short)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "london", "short"), alert.freq_once_per_bar_close)
        londonTradeCount += 1
    else if armedSession == 3
        strategy.entry("NY Short", strategy.short)
        if enableEntryStartedAlert
            alert(webhookMessage("entry_started", "new_york", "short"), alert.freq_once_per_bar_close)
        newYorkTradeCount += 1

    armedSession := 0
    armedBreakoutDirection := 0
    armedNeutralRange := false

// ==================== EXITS ====================
// Each session order keeps its own stop and target from its own entry price.
strategy.exit("Asia Long Exit", "Asia Long", loss = stopTicks, profit = targetTicks)
strategy.exit("London Long Exit", "London Long", loss = stopTicks, profit = targetTicks)
strategy.exit("NY Long Exit", "NY Long", loss = stopTicks, profit = targetTicks)

strategy.exit("Asia Short Exit", "Asia Short", loss = stopTicks, profit = targetTicks)
strategy.exit("London Short Exit", "London Short", loss = stopTicks, profit = targetTicks)
strategy.exit("NY Short Exit", "NY Short", loss = stopTicks, profit = targetTicks)


string bhNextSession = bhInAsia ? "London" : bhInLondon ? "NY" : "Asia"

//=============================================================================
// HISTORICAL REVIEW SNAPSHOT
//=============================================================================
// TradingView tables always render on the chart's last bar. Scrolling alone does
// not move a table into the past. Review mode solves that by freezing the first
// chart bar at or immediately after the selected date/time.
//
// The stored values come from confirmed 1-hour request.security() series, so the
// snapshot does not use future 1-hour information.
bhReviewCrossed = time >= bhReviewTime and (na(time[1]) or time[1] < bhReviewTime)

var bool bhReviewCaptured = false
var int bhReviewCapturedTime = na
var string bhReviewSession = "Outside session"
var int bhReviewEmaState = 0
var int bhReviewStState = 0
var int bhReviewSessionVwapState = 0
var int bhReviewWeeklyVwapState = 0
var int bhReviewMidState = 0
var int bhReviewRangeState = 0
var int bhReviewAdxState = 0
var float bhReviewEma = na
var float bhReviewSupertrend = na
var float bhReviewSessionVWAP = na
var float bhReviewWeeklyVWAP = na
var float bhReviewPrevMid = na
var float bhReviewPrevHigh = na
var float bhReviewPrevLow = na
var float bhReviewAdx = na
var float bhReviewDiPlus = na
var float bhReviewDiMinus = na
var int bhReviewTotalScore = 0
var int bhReviewBullScore = 0
var int bhReviewBearScore = 0
var float bhReviewScorePct = 0.0

if bhReviewCrossed
    bhReviewCaptured := true
    bhReviewCapturedTime := time
    bhReviewSession := bhInAsia ? "Asia" : bhInLondon ? "London" : bhInNewYork ? "NY" : "Outside session"
    bhReviewEmaState := bhEmaState
    bhReviewStState := bhStState
    bhReviewSessionVwapState := bhSessionVwapState
    bhReviewWeeklyVwapState := bhWeeklyVwapState
    bhReviewMidState := bhMidState
    bhReviewRangeState := bhRangeState
    bhReviewAdxState := bhAdxState
    bhReviewEma := bhEma
    bhReviewSupertrend := bhSupertrend
    bhReviewSessionVWAP := bhSessionVWAP
    bhReviewWeeklyVWAP := bhWeeklyVWAP
    bhReviewPrevMid := bhPrevMid
    bhReviewPrevHigh := bhPrevHigh
    bhReviewPrevLow := bhPrevLow
    bhReviewAdx := bhAdx
    bhReviewDiPlus := bhDiPlus
    bhReviewDiMinus := bhDiMinus
    bhReviewTotalScore := bhTotalScore
    bhReviewBullScore := bhBullScore
    bhReviewBearScore := bhBearScore
    bhReviewScorePct := bhScorePct

// Values used by the table. Live mode shows the latest session lock. Historical
// mode shows the frozen snapshot selected in the indicator settings.
bhViewReady = not bhHistoricalReview or bhReviewCaptured
bhViewSession = bhHistoricalReview ? (bhReviewCaptured ? bhReviewSession + " (REVIEW)" : "DATE NOT LOADED") : bhLockedSession + (na(bhLockedTime) ? "" : " (LOCKED)")
bhViewTime = bhHistoricalReview ? bhReviewCapturedTime : bhLockedTime
bhViewEmaState = bhHistoricalReview ? bhReviewEmaState : bhLockedEmaState
bhViewStState = bhHistoricalReview ? bhReviewStState : bhLockedStState
bhViewSessionVwapState = bhHistoricalReview ? bhReviewSessionVwapState : bhLockedSessionVwapState
bhViewWeeklyVwapState = bhHistoricalReview ? bhReviewWeeklyVwapState : bhLockedWeeklyVwapState
bhViewMidState = bhHistoricalReview ? bhReviewMidState : bhLockedMidState
bhViewRangeState = bhHistoricalReview ? bhReviewRangeState : bhLockedRangeState
bhViewAdxState = bhHistoricalReview ? bhReviewAdxState : bhLockedAdxState
bhViewEma = bhHistoricalReview ? bhReviewEma : bhLockedEma
bhViewSupertrend = bhHistoricalReview ? bhReviewSupertrend : bhLockedSupertrend
bhViewSessionVWAP = bhHistoricalReview ? bhReviewSessionVWAP : bhLockedSessionVWAP
bhViewWeeklyVWAP = bhHistoricalReview ? bhReviewWeeklyVWAP : bhLockedWeeklyVWAP
bhViewPrevMid = bhHistoricalReview ? bhReviewPrevMid : bhLockedPrevMid
bhViewPrevHigh = bhHistoricalReview ? bhReviewPrevHigh : bhLockedPrevHigh
bhViewPrevLow = bhHistoricalReview ? bhReviewPrevLow : bhLockedPrevLow
bhViewAdx = bhHistoricalReview ? bhReviewAdx : bhLockedAdx
bhViewDiPlus = bhHistoricalReview ? bhReviewDiPlus : bhLockedDiPlus
bhViewDiMinus = bhHistoricalReview ? bhReviewDiMinus : bhLockedDiMinus
bhViewTotalScore = bhHistoricalReview ? bhReviewTotalScore : bhLockedTotalScore
bhViewBullScore = bhHistoricalReview ? bhReviewBullScore : bhLockedBullScore
bhViewBearScore = bhHistoricalReview ? bhReviewBearScore : bhLockedBearScore
bhViewScorePct = bhHistoricalReview ? bhReviewScorePct : bhLockedScorePct

bhStateText(int state) =>
    state > 0 ? "Bullish" : state < 0 ? "Bearish" : "Neutral"

bhStateColor(int state) =>
    state > 0 ? color.new(color.green, 0) : state < 0 ? color.new(color.red, 0) : color.new(color.gray, 35)

bhBiasColor(float pct) =>
    pct >= 60 ? color.new(color.green, 0) : pct >= 25 ? color.new(color.green, 35) : pct <= -60 ? color.new(color.red, 0) : pct <= -25 ? color.new(color.red, 35) : color.new(color.gray, 30)

bhRow(table t, int row, string name, int state, int weight, string detail) =>
    table.cell(t, 0, row, name, text_color = color.white, bgcolor = color.new(color.black, 0), text_halign = text.align_left, text_size = size.tiny)
    table.cell(t, 1, row, bhStateText(state), text_color = color.white, bgcolor = bhStateColor(state), text_size = size.tiny)
    table.cell(t, 2, row, str.tostring(weight), text_color = color.white, bgcolor = color.new(color.blue, 55), text_size = size.tiny)
    table.cell(t, 3, row, detail, text_color = color.white, bgcolor = color.new(color.black, 0), text_halign = text.align_right, text_size = size.tiny)

var table bhDash = table.new(position.top_right, 4, 34, border_width = 1)

if barstate.islast and bhShowDashboard
    table.clear(bhDash, 0, 0, 3, 33)

    table.cell(bhDash, 0, 0, bhHistoricalReview ? "ORB 1H BIAS • REVIEW" : "ORB 1H BIAS", text_color = color.white, bgcolor = color.new(color.blue, 15), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 0, 3, 0)

    table.cell(bhDash, 0, 1, bhHistoricalReview ? "HISTORICAL SNAPSHOT" : "LOCKED", text_color = color.white, bgcolor = color.new(color.navy, 15), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 1, 3, 1)

    bhSessionText = bhViewSession
    table.cell(bhDash, 0, 2, "Session", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 2, bhSessionText, text_color = color.white, bgcolor = color.new(color.blue, 35), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 2, 3, 2)

    table.cell(bhDash, 0, 3, "Bias", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 3, bhBiasText(bhViewScorePct), text_color = color.white, bgcolor = bhBiasColor(bhViewScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 3, 3, 3)

    table.cell(bhDash, 0, 4, "Action", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 4, bhActionText(bhViewScorePct), text_color = color.white, bgcolor = bhBiasColor(bhViewScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 4, 3, 4)

    table.cell(bhDash, 0, 5, "Conf", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 5, str.tostring(math.abs(bhViewScorePct), "#.0") + "%", text_color = color.white, bgcolor = bhBiasColor(bhViewScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 5, 3, 5)

    table.cell(bhDash, 0, 6, "Bull/Bear", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 6, str.tostring(bhViewBullScore) + " / " + str.tostring(bhViewBearScore), text_color = color.white, bgcolor = bhBiasColor(bhViewScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 6, 3, 6)

    table.cell(bhDash, 0, 7, "Net", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 7, str.tostring(bhViewTotalScore) + " / " + str.tostring(bhMaxScore), text_color = color.white, bgcolor = bhBiasColor(bhViewScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 7, 3, 7)

    bhLockHour = na(bhViewTime) ? na : hour(bhViewTime, bhSessionTZ)
    bhLockMinute = na(bhViewTime) ? na : minute(bhViewTime, bhSessionTZ)
    bhLockTimeText = na(bhViewTime) ? "Waiting" : str.tostring(bhLockHour, "00") + ":" + str.tostring(bhLockMinute, "00") + " " + bhSessionTZ
    table.cell(bhDash, 0, 8, "Lock time", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.cell(bhDash, 1, 8, bhLockTimeText, text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 8, 3, 8)

    table.cell(bhDash, 0, 9, bhHistoricalReview ? "SELECTED-TIME SCORE" : "NEXT PREVIEW", text_color = color.white, bgcolor = color.new(color.navy, 15), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 9, 3, 9)

    table.cell(bhDash, 0, 10, "Next", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 10, bhHistoricalReview ? (bhReviewCaptured ? "Snapshot at selected time" : "Load more chart history") : bhNextSession + " (1H PREVIEW)", text_color = color.white, bgcolor = color.new(color.blue, 35), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 10, 3, 10)

    table.cell(bhDash, 0, 11, "Bias", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 11, bhBiasText(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_color = color.white, bgcolor = bhBiasColor(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 11, 3, 11)

    table.cell(bhDash, 0, 12, "Action", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 12, bhActionText(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_color = color.white, bgcolor = bhBiasColor(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 12, 3, 12)

    table.cell(bhDash, 0, 13, "Conf", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 13, str.tostring(math.abs(bhHistoricalReview ? bhViewScorePct : bhScorePct), "#.0") + "%", text_color = color.white, bgcolor = bhBiasColor(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 13, 3, 13)

    table.cell(bhDash, 0, 14, "Live B/B", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 14, str.tostring(bhHistoricalReview ? bhViewBullScore : bhBullScore) + " / " + str.tostring(bhHistoricalReview ? bhViewBearScore : bhBearScore), text_color = color.white, bgcolor = bhBiasColor(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 14, 3, 14)

    table.cell(bhDash, 0, 15, "Live net", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 15, str.tostring(bhHistoricalReview ? bhViewTotalScore : bhTotalScore) + " / " + str.tostring(bhMaxScore), text_color = color.white, bgcolor = bhBiasColor(bhHistoricalReview ? bhViewScorePct : bhScorePct), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 15, 3, 15)

    table.cell(bhDash, 0, 16, "FACTORS", text_color = color.white, bgcolor = color.new(color.navy, 15), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 16, 3, 16)

    table.cell(bhDash, 0, 17, "Component", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 17, "State", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 2, 17, "Wt", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 3, 17, "Value", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)

    bhRow(bhDash, 18, "200 EMA", bhViewEmaState, bhEmaWeight, str.tostring(bhViewEma, format.mintick))
    bhRow(bhDash, 19, "Supertrend", bhViewStState, bhStWeight, str.tostring(bhViewSupertrend, format.mintick))
    bhRow(bhDash, 20, "Session VWAP", bhViewSessionVwapState, bhSessionVwapWeight, str.tostring(bhViewSessionVWAP, format.mintick))
    bhRow(bhDash, 21, "Weekly VWAP", bhViewWeeklyVwapState, bhWeeklyVwapWeight, str.tostring(bhViewWeeklyVWAP, format.mintick))
    bhRow(bhDash, 22, "PD mid", bhViewMidState, bhMidWeight, str.tostring(bhViewPrevMid, format.mintick))
    bhRow(bhDash, 23, "PD H/L", bhViewRangeState, bhRangeWeight, str.tostring(bhViewPrevHigh, format.mintick) + " / " + str.tostring(bhViewPrevLow, format.mintick))
    bhAdxDetail = str.tostring(bhViewAdx, "#.0") + " | +DI " + str.tostring(bhViewDiPlus, "#.0") + " | -DI " + str.tostring(bhViewDiMinus, "#.0")
    bhRow(bhDash, 24, "ADX / DI", bhViewAdxState, bhAdxWeight, bhAdxDetail)

    dailyBiasBg =
         activeDailyBias == "Bullish" ? color.new(color.green, 35) :
         activeDailyBias == "Bearish" ? color.new(color.red, 35) :
         color.new(color.gray, 45)

    table.cell(bhDash, 0, 25, "DAILY BIAS", text_color = color.white, bgcolor = color.new(color.navy, 15), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 25, 3, 25)

    table.cell(bhDash, 0, 26, "Active", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 26, activeDailyBias, text_color = color.white, bgcolor = dailyBiasBg, text_size = size.tiny)
    table.merge_cells(bhDash, 1, 26, 3, 26)

    table.cell(bhDash, 0, 27, "Source", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 27, "Automatic Supertrend Agreement", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 27, 3, 27)

    table.cell(bhDash, 0, 28, "10m / 2m ST", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 28, lockedAuto10mState + " / " + lockedAuto2mState, text_color = color.white, bgcolor = dailyBiasBg, text_size = size.tiny)
    table.merge_cells(bhDash, 1, 28, 3, 28)

    table.cell(bhDash, 0, 29, "Locked", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 29, lockedAutoBiasSession + " • " + lockedAutoDailyBias, text_color = color.white, bgcolor = dailyBiasBg, text_size = size.tiny)
    table.merge_cells(bhDash, 1, 29, 3, 29)

    scoreDecisionBg =
         automaticCombinedScore >= 2 ? color.new(color.green, 35) :
         automaticCombinedScore <= -2 ? color.new(color.red, 35) :
         color.new(color.gray, 45)

    table.cell(bhDash, 0, 30, "AUTOMATIC DECISION", text_color = color.white, bgcolor = color.new(color.purple, 20), text_size = size.tiny)
    table.merge_cells(bhDash, 0, 30, 3, 30)

    table.cell(bhDash, 0, 31, "Daily / Session", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 31, "Daily " + str.tostring(automaticDailyScore) + " • Session " + str.tostring(automaticSessionScore), text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.merge_cells(bhDash, 1, 31, 3, 31)

    table.cell(bhDash, 0, 32, "Combined", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 32, str.tostring(automaticCombinedScore), text_color = color.white, bgcolor = scoreDecisionBg, text_size = size.tiny)
    table.merge_cells(bhDash, 1, 32, 3, 32)

    table.cell(bhDash, 0, 33, "Decision", text_color = color.white, bgcolor = color.new(color.gray, 45), text_size = size.tiny)
    table.cell(bhDash, 1, 33, biasControlSource == "Automatic Scoring" ? automaticBiasDecision : "MANUAL • " + biasControlMode, text_color = color.white, bgcolor = scoreDecisionBg, text_size = size.tiny)
    table.merge_cells(bhDash, 1, 33, 3, 33)

if barstate.islast and not bhShowDashboard
    table.clear(bhDash, 0, 0, 3, 33)


bhNewLock = bhAsiaStart or bhLondonStart or bhNewYorkStart
alertcondition(bhNewLock and bhLockedScorePct >= 25, "1H session bias locked bullish", "ORB 1H Bias locked bullish for the new session")
alertcondition(bhNewLock and bhLockedScorePct <= -25, "1H session bias locked bearish", "ORB 1H Bias locked bearish for the new session")
alertcondition(bhNewLock and math.abs(bhLockedScorePct) < 25, "1H session bias locked neutral", "ORB 1H Bias locked neutral for the new session")
````
