<!-- tradingview-pine-id: PUB;7ef6040711a04603baec490784049e0f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Decision time

Source: https://www.tradingview.com/script/l0EiaY8Y-Decision-time/

## Description

Decision Time is an intraday session overlay built around fair-value boxes and confirmation after a breakout retest. The script creates a box from a selected session's anchor candle, extends that box for the configured session duration, and then tracks whether price breaks out, retests, and confirms continuation with a second close outside the box.

The indicator supports multiple session anchors:
- Market Reopen
- Asia
- London
- New York Open
- New York PM
- Pre-news

How it works:
- When a selected session begins, the script captures the anchor candle.
- The fair-value box is built from either the anchor candle range or a fixed band around the chosen fair-price source.
- If price closes above the box, the script starts watching for a bullish retest that still holds above the box.
- If the next candle also closes above the box, the script prints a long signal.
- The bearish sequence is mirrored below the box.

Session behavior:
- Each session can be enabled or disabled independently.
- Each session box can use its own duration.
- The Asia session can optionally extend for the full day.
- The script can also color each session start candle and draw a separate rectangle around that start candle.
- A preview box shows the next upcoming session.

Main inputs:
- Session timezone and display timezone
- Session enable/disable toggles
- Per-session box lengths
- Fair-price source: Open, Midpoint, or Close
- Fair-value box mode: anchor candle range or fixed band
- Entry window after the anchor
- Maximum bars allowed between breakout and retest
- Retest touch and close conditions
- Signal limits and cooldown
- Session start candle colors and optional start-candle rectangles

Visual outputs:
- Session fair-value boxes
- Fair-price line
- Breakout and retest markers
- Long and short confirmation labels
- Session phase background shading
- Next session preview box
- Session start candle coloring

What makes this script different:
- It is session-anchored rather than using one continuous breakout model for the whole chart.
- It separates the breakout, retest, and confirmation steps instead of flagging the first close outside the range as the final signal.
- It allows different session box lengths and a full-day Asia mode, which makes it easier to adapt the same workflow across multiple market phases.

Important limitations:
- This is an indicator, not a strategy or automated execution system.
- It does not place orders, manage risk, or calculate performance.
- Signals depend on the selected session anchors, duration settings, and chart timeframe.
- The logic is designed for intraday use and may be less useful on higher timeframes or symbols with very different session behavior.
- A signal only means the configured box/retest conditions were met. It does not guarantee continuation or profitability.

This script is for chart analysis and workflow structure only. It is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Decision time", shorttitle = "Decision time", overlay = true, max_labels_count = 500, max_boxes_count = 500)

// Session-driven fair-value box with breakout -> retest -> second-close entry logic.
// Bullish default flow:
// 1) price closes above the fair-value box,
// 2) the next qualifying retest candle holds above the box,
// 3) the following candle closes above the box and becomes the long entry candle.
// Bearish logic is mirrored below the box.

groupSessions = "Sessions"
groupFairValue = "Fair Value"
groupWindows = "Windows"
groupEntry = "Box Retest Rules"
groupSignals = "Signals"
groupVisuals = "Visuals"
groupStartCandle = "Session Start Candle"

string sessionTimezone = input.string("America/New_York", "Session timezone", group = groupSessions)
string displayTimezone = input.string("Australia/Sydney", "Display timezone", group = groupSessions)

bool enableReopen = input.bool(true, "Enable market reopen", group = groupSessions)
string reopenSession = input.string("1800-1801:1234567", "Reopen anchor", group = groupSessions)
bool enableAsia = input.bool(true, "Enable Asia", group = groupSessions)
string asiaSession = input.string("2000-2001:1234567", "Asia anchor", group = groupSessions)
bool enableLondon = input.bool(true, "Enable London", group = groupSessions)
string londonSession = input.string("0300-0301:23456", "London anchor", group = groupSessions)
bool enableNewYork = input.bool(true, "Enable New York open", group = groupSessions)
string newYorkSession = input.string("0930-0931:23456", "New York anchor", group = groupSessions)
bool enableNyPm = input.bool(true, "Enable New York PM", group = groupSessions)
string nyPmSession = input.string("1400-1401:23456", "New York PM anchor", group = groupSessions)
bool enableNews = input.bool(false, "Enable 8:29 pre-news anchor", group = groupSessions)
string newsSession = input.string("0829-0830:23456", "Pre-news anchor", group = groupSessions)

string fairPriceMode = input.string("Open", "Fair price source", options = ["Open", "Midpoint", "Close"], group = groupFairValue)
string fairZoneMode = input.string("Anchor Candle Range", "Fair-value box", options = ["Anchor Candle Range", "Fixed Band"], group = groupFairValue)
float fixedBandPoints = input.float(6.0, "Fixed band half-height (points)", minval = 0.25, step = 0.25, group = groupFairValue)
int fairZoneTransparency = input.int(86, "Box transparency", minval = 0, maxval = 100, group = groupFairValue)

int entryWindowMinutes = input.int(20, "Entry window after anchor (minutes)", minval = 1, group = groupWindows)
int sessionEndMinutes = input.int(90, "Fallback session box length (minutes)", minval = 2, group = groupWindows)
int maxBarsAfterBreakout = input.int(8, "Max bars from breakout to retest", minval = 1, maxval = 50, group = groupWindows)
bool extendAsiaForFullDay = input.bool(true, "Extend Asia box for full day", group = groupWindows)
int reopenSessionMinutes = input.int(120, "Reopen box length (minutes)", minval = 2, group = groupWindows)
int asiaSessionMinutes = input.int(420, "Asia box length (minutes)", minval = 2, group = groupWindows)
int londonSessionMinutes = input.int(390, "London box length (minutes)", minval = 2, group = groupWindows)
int newYorkSessionMinutes = input.int(270, "New York box length (minutes)", minval = 2, group = groupWindows)
int nyPmSessionMinutes = input.int(120, "New York PM box length (minutes)", minval = 2, group = groupWindows)
int newsSessionMinutes = input.int(61, "Pre-news box length (minutes)", minval = 2, group = groupWindows)

bool useAnchorCandleBias = input.bool(true, "Use anchor candle for directional bias", group = groupEntry)
bool retestMustTouchBox = input.bool(false, "Retest must touch box boundary", group = groupEntry)
int retestTouchToleranceTicks = input.int(6, "Retest touch tolerance (ticks)", minval = 0, maxval = 100, group = groupEntry)
bool requireRetestCloseOutside = input.bool(true, "Retest candle must close outside box", group = groupEntry)
bool requireEntryCandleDirection = input.bool(true, "Entry candle must match direction", group = groupEntry)
float minBreakoutDistancePoints = input.float(0.0, "Min close distance beyond box on breakout", minval = 0.0, step = 0.25, group = groupEntry)

int maxLongSignalsPerSession = input.int(1, "Max long signals per session", minval = 0, maxval = 10, group = groupSignals)
int maxShortSignalsPerSession = input.int(1, "Max short signals per session", minval = 0, maxval = 10, group = groupSignals)
int signalCooldownBars = input.int(1, "Cooldown between signals (bars)", minval = 0, maxval = 20, group = groupSignals)
bool onlyConfirmedBars = input.bool(true, "Only signal on confirmed bar close", group = groupSignals)

bool showFairPriceLine = input.bool(true, "Show fair-price line", group = groupVisuals)
bool showPhaseBackground = input.bool(true, "Shade active session phases", group = groupVisuals)
bool showSetupMarkers = input.bool(true, "Show breakout and retest markers", group = groupVisuals)
bool showNextSessionPreview = input.bool(true, "Show next session preview", group = groupVisuals)
int previewRangeBars = input.int(300, "Preview range bars", minval = 50, maxval = 2000, group = groupVisuals)
float previewPaddingPercent = input.float(5.0, "Preview vertical padding %", minval = 0.0, maxval = 50.0, step = 0.5, group = groupVisuals)
int nextSessionTransparency = input.int(92, "Next session transparency", minval = 0, maxval = 100, group = groupVisuals)

bool colorSessionStartCandles = input.bool(true, "Color session start candles", group = groupStartCandle)
bool showSessionStartRectangles = input.bool(true, "Show session start rectangles", group = groupStartCandle)
int sessionStartRectangleTransparency = input.int(80, "Start rectangle transparency", minval = 0, maxval = 100, group = groupStartCandle)
color reopenSessionColor = input.color(color.gray, "Reopen color", group = groupStartCandle)
color asiaSessionColor = input.color(color.rgb(56, 120, 255), "Asia color", group = groupStartCandle)
color londonSessionColor = input.color(color.rgb(33, 186, 69), "London color", group = groupStartCandle)
color newYorkSessionColor = input.color(color.rgb(255, 153, 0), "New York color", group = groupStartCandle)
color nyPmSessionColor = input.color(color.rgb(173, 102, 255), "New York PM color", group = groupStartCandle)
color newsSessionColor = input.color(color.rgb(255, 90, 90), "Pre-news color", group = groupStartCandle)

f_sessionStart(string sessionText, string timezoneText) =>
    int sessionTime = time(timeframe.period, sessionText, timezoneText)
    not na(sessionTime) and na(sessionTime[1])

f_fairPrice(string mode) =>
    mode == "Open" ? open : mode == "Midpoint" ? hl2 : close

f_priceText(float value) =>
    na(value) ? "NA" : str.tostring(value, format.mintick)

f_phaseText(bool inEntryWindow, bool inMonitorWindow) =>
    inEntryWindow ? "Entry Window" : inMonitorWindow ? "Monitoring" : "Inactive"

f_biasText(bool bullBias, bool bearBias) =>
    bullBias ? "Bullish" : bearBias ? "Bearish" : "Neutral"

f_signalName(bool isLong) =>
    isLong ? "Bullish Box Retest Long" : "Bearish Box Retest Short"

f_sessionStartHour(string sessionText) =>
    int(str.tonumber(str.substring(sessionText, 0, 2)))

f_sessionStartMinute(string sessionText) =>
    int(str.tonumber(str.substring(sessionText, 2, 4)))

f_sessionDayMask(string sessionText) =>
    str.length(sessionText) > 10 ? str.substring(sessionText, 10) : "1234567"

f_dayAllowed(string dayMask, int candidateDay) =>
    str.contains(dayMask, str.tostring(candidateDay))

f_nextSessionTimestamp(string sessionText, string timezoneText) =>
    int startHour = f_sessionStartHour(sessionText)
    int startMinute = f_sessionStartMinute(sessionText)
    string dayMask = f_sessionDayMask(sessionText)
    int nextTime = na
    for dayOffset = 0 to 7
        int probeTime = time + dayOffset * 24 * 60 * 60 * 1000
        int probeYear = year(probeTime, timezoneText)
        int probeMonth = month(probeTime, timezoneText)
        int probeDay = dayofmonth(probeTime, timezoneText)
        int candidateTime = timestamp(timezoneText, probeYear, probeMonth, probeDay, startHour, startMinute, 0)
        int candidateDow = dayofweek(candidateTime, timezoneText)
        bool allowedDay = f_dayAllowed(dayMask, candidateDow)
        bool isFuture = candidateTime > time
        if allowedDay and isFuture and na(nextTime)
            nextTime := candidateTime
    nextTime

f_sessionDurationMinutes(string sessionTag) =>
    sessionTag == "RE" ? reopenSessionMinutes :
     sessionTag == "AS" ? (extendAsiaForFullDay ? 24 * 60 : asiaSessionMinutes) :
     sessionTag == "LDN" ? londonSessionMinutes :
     sessionTag == "NY" ? newYorkSessionMinutes :
     sessionTag == "PM" ? nyPmSessionMinutes :
     sessionTag == "NEWS" ? newsSessionMinutes :
     sessionEndMinutes

f_buildTooltip(
    string signalName,
    string sessionName,
    string sessionTag,
    string phaseName,
    string symbolTfText,
    string anchorText,
    string biasText,
    string fairPriceText,
    string fairZoneText,
    string breakoutText,
    string retestText,
    string signalPriceText,
    string signalCountsText) =>
    "Prop-Firm Fair Price Box Retest\n" +
     "Signal: " + signalName + "\n" +
     "Session: " + sessionName + " (" + sessionTag + ")\n" +
     "Symbol / TF: " + symbolTfText + "\n" +
     "Anchor: " + anchorText + "\n" +
     "Phase: " + phaseName + "\n" +
     "Bias: " + biasText + "\n" +
     "Fair price: " + fairPriceText + "\n" +
     "Fair box: " + fairZoneText + "\n" +
     "Breakout: " + breakoutText + "\n" +
     "Retest: " + retestText + "\n" +
     "Entry price: " + signalPriceText + "\n" +
     "Signal counts: " + signalCountsText

bool startReopen = enableReopen and f_sessionStart(reopenSession, sessionTimezone)
bool startAsia = enableAsia and f_sessionStart(asiaSession, sessionTimezone)
bool startLondon = enableLondon and f_sessionStart(londonSession, sessionTimezone)
bool startNewYork = enableNewYork and f_sessionStart(newYorkSession, sessionTimezone)
bool startNyPm = enableNyPm and f_sessionStart(nyPmSession, sessionTimezone)
bool startNews = enableNews and f_sessionStart(newsSession, sessionTimezone)

bool newAnchor = startReopen or startAsia or startLondon or startNewYork or startNyPm or startNews

string newSessionName = startReopen ? "Market Reopen" : startAsia ? "Asia" : startLondon ? "London" : startNewYork ? "New York Open" : startNyPm ? "New York PM" : startNews ? "Pre-News" : ""
string newSessionTag = startReopen ? "RE" : startAsia ? "AS" : startLondon ? "LDN" : startNewYork ? "NY" : startNyPm ? "PM" : startNews ? "NEWS" : ""
string newSessionText = startReopen ? reopenSession : startAsia ? asiaSession : startLondon ? londonSession : startNewYork ? newYorkSession : startNyPm ? nyPmSession : startNews ? newsSession : ""
color newSessionColor = startReopen ? reopenSessionColor : startAsia ? asiaSessionColor : startLondon ? londonSessionColor : startNewYork ? newYorkSessionColor : startNyPm ? nyPmSessionColor : newsSessionColor

var int anchorTime = na
var float anchorOpen = na
var float anchorClose = na
var float anchorHigh = na
var float anchorLow = na
var float fairPrice = na
var float fairZoneTop = na
var float fairZoneBottom = na
var int lastSignalBar = na
var int longSignalsTaken = 0
var int shortSignalsTaken = 0
var string currentSessionName = "None"
var string currentSessionTag = ""
var string currentSessionText = ""
var color currentSessionColor = color.silver
var box activeFairBox = na
var box nextSessionBox = na

var bool bullBreakoutArmed = false
var bool bearBreakoutArmed = false
var bool bullRetestActive = false
var bool bearRetestActive = false
var int bullBreakoutBar = na
var int bearBreakoutBar = na
var int bullRetestBar = na
var int bearRetestBar = na
var float bullBreakoutClose = na
var float bearBreakoutClose = na
var float bullRetestClose = na
var float bearRetestClose = na

if newAnchor
    anchorTime := time
    anchorOpen := open
    anchorClose := close
    anchorHigh := high
    anchorLow := low
    fairPrice := f_fairPrice(fairPriceMode)
    fairZoneTop := fairZoneMode == "Anchor Candle Range" ? anchorHigh : fairPrice + fixedBandPoints
    fairZoneBottom := fairZoneMode == "Anchor Candle Range" ? anchorLow : fairPrice - fixedBandPoints
    lastSignalBar := na
    longSignalsTaken := 0
    shortSignalsTaken := 0
    currentSessionName := newSessionName
    currentSessionTag := newSessionTag
    currentSessionText := newSessionText
    currentSessionColor := newSessionColor
    bullBreakoutArmed := false
    bearBreakoutArmed := false
    bullRetestActive := false
    bearRetestActive := false
    bullBreakoutBar := na
    bearBreakoutBar := na
    bullRetestBar := na
    bearRetestBar := na
    bullBreakoutClose := na
    bearBreakoutClose := na
    bullRetestClose := na
    bearRetestClose := na
    int newSessionDurationMinutes = f_sessionDurationMinutes(newSessionTag)
    int newSessionRightTime = time + newSessionDurationMinutes * 60000
    activeFairBox := box.new(time, fairZoneTop, newSessionRightTime, fairZoneBottom, xloc = xloc.bar_time, bgcolor = color.new(newSessionColor, fairZoneTransparency), border_color = color.new(newSessionColor, 0), border_width = 1, text = newSessionTag + " BOX", text_color = color.white, text_size = size.tiny, force_overlay = true)
    if showSessionStartRectangles
        box.new(time, anchorHigh, time_close, anchorLow, xloc = xloc.bar_time, bgcolor = color.new(newSessionColor, sessionStartRectangleTransparency), border_color = color.new(newSessionColor, 0), border_width = 1, force_overlay = true)

float minutesSinceAnchor = na(anchorTime) ? na : (time - anchorTime) / 60000.0
int currentSessionDurationMinutes = f_sessionDurationMinutes(currentSessionTag)
bool sessionActive = not na(minutesSinceAnchor) and minutesSinceAnchor >= 0 and minutesSinceAnchor < currentSessionDurationMinutes
bool inEntryWindow = sessionActive and minutesSinceAnchor < entryWindowMinutes
bool inMonitorWindow = sessionActive and not inEntryWindow
int sessionEndTime = na(anchorTime) ? na : anchorTime + currentSessionDurationMinutes * 60000
int activeBoxRightTime = sessionEndTime

bool anchorBull = not na(anchorOpen) and not na(anchorClose) and anchorClose > anchorOpen
bool anchorBear = not na(anchorOpen) and not na(anchorClose) and anchorClose < anchorOpen
bool bullBias = useAnchorCandleBias ? anchorBull : not na(fairPrice) and close >= fairPrice
bool bearBias = useAnchorCandleBias ? anchorBear : not na(fairPrice) and close <= fairPrice

float retestTolerance = syminfo.mintick * retestTouchToleranceTicks
float breakoutDistanceLong = not na(fairZoneTop) ? close - fairZoneTop : na
float breakoutDistanceShort = not na(fairZoneBottom) ? fairZoneBottom - close : na

bool closeAboveBox = not na(fairZoneTop) and close > fairZoneTop
bool closeBelowBox = not na(fairZoneBottom) and close < fairZoneBottom
bool closeAtOrAboveBox = not na(fairZoneTop) and close >= fairZoneTop
bool closeAtOrBelowBox = not na(fairZoneBottom) and close <= fairZoneBottom

bool freshBullBreakout = inEntryWindow and bullBias and closeAboveBox and close[1] <= fairZoneTop and breakoutDistanceLong >= minBreakoutDistancePoints
bool freshBearBreakout = inEntryWindow and bearBias and closeBelowBox and close[1] >= fairZoneBottom and breakoutDistanceShort >= minBreakoutDistancePoints

bool bullRetestTouchesBoundary = not na(fairZoneTop) and low <= fairZoneTop + retestTolerance
bool bearRetestTouchesBoundary = not na(fairZoneBottom) and high >= fairZoneBottom - retestTolerance

bool bullRetestQualifier = bar_index > nz(bullBreakoutBar, bar_index) and closeAtOrAboveBox and (not retestMustTouchBox or bullRetestTouchesBoundary)
bool bearRetestQualifier = bar_index > nz(bearBreakoutBar, bar_index) and closeAtOrBelowBox and (not retestMustTouchBox or bearRetestTouchesBoundary)

bool barReady = onlyConfirmedBars ? barstate.isconfirmed : true
bool canSignalThisBar = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldownBars

bool longEntrySignal = false
bool shortEntrySignal = false

if not inEntryWindow
    bullBreakoutArmed := false
    bearBreakoutArmed := false
    bullRetestActive := false
    bearRetestActive := false
    bullBreakoutBar := na
    bearBreakoutBar := na
    bullRetestBar := na
    bearRetestBar := na
    bullBreakoutClose := na
    bearBreakoutClose := na
    bullRetestClose := na
    bearRetestClose := na

if barReady and timeframe.isintraday and inEntryWindow
    if freshBullBreakout
        bullBreakoutArmed := true
        bullRetestActive := false
        bullBreakoutBar := bar_index
        bullRetestBar := na
        bullBreakoutClose := close
        bullRetestClose := na
        bearBreakoutArmed := false
        bearRetestActive := false
        bearBreakoutBar := na
        bearRetestBar := na
        bearBreakoutClose := na
        bearRetestClose := na
        if showSetupMarkers
            label.new(bar_index, high, text = currentSessionTag + " BRK", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.lime, 0), textcolor = color.black, size = size.tiny, force_overlay = true)

    if freshBearBreakout
        bearBreakoutArmed := true
        bearRetestActive := false
        bearBreakoutBar := bar_index
        bearRetestBar := na
        bearBreakoutClose := close
        bearRetestClose := na
        bullBreakoutArmed := false
        bullRetestActive := false
        bullBreakoutBar := na
        bullRetestBar := na
        bullBreakoutClose := na
        bullRetestClose := na
        if showSetupMarkers
            label.new(bar_index, low, text = currentSessionTag + " BRK", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.red, 0), textcolor = color.white, size = size.tiny, force_overlay = true)

    if bullBreakoutArmed and not bullRetestActive
        int bullBreakoutAge = bar_index - bullBreakoutBar
        bool bullRetestInvalid = requireRetestCloseOutside ? close < fairZoneTop : close < fairZoneBottom
        if bullBreakoutAge > maxBarsAfterBreakout or bullRetestInvalid
            bullBreakoutArmed := false
            bullBreakoutBar := na
            bullBreakoutClose := na
        else if bullRetestQualifier
            bullRetestActive := true
            bullRetestBar := bar_index
            bullRetestClose := close
            if showSetupMarkers
                label.new(bar_index, low, text = currentSessionTag + " RT", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.teal, 0), textcolor = color.white, size = size.tiny, force_overlay = true)

    if bearBreakoutArmed and not bearRetestActive
        int bearBreakoutAge = bar_index - bearBreakoutBar
        bool bearRetestInvalid = requireRetestCloseOutside ? close > fairZoneBottom : close > fairZoneTop
        if bearBreakoutAge > maxBarsAfterBreakout or bearRetestInvalid
            bearBreakoutArmed := false
            bearBreakoutBar := na
            bearBreakoutClose := na
        else if bearRetestQualifier
            bearRetestActive := true
            bearRetestBar := bar_index
            bearRetestClose := close
            if showSetupMarkers
                label.new(bar_index, high, text = currentSessionTag + " RT", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.tiny, force_overlay = true)

    if bullRetestActive
        if bar_index == bullRetestBar + 1
            bool bullEntryCandleValid = closeAboveBox and (not requireEntryCandleDirection or close > open)
            longEntrySignal := bullEntryCandleValid and canSignalThisBar and longSignalsTaken < maxLongSignalsPerSession
            bullBreakoutArmed := false
            bullRetestActive := false
            bullBreakoutBar := na
            bullRetestBar := na
        else if bar_index > bullRetestBar + 1
            bullBreakoutArmed := false
            bullRetestActive := false
            bullBreakoutBar := na
            bullRetestBar := na

    if bearRetestActive
        if bar_index == bearRetestBar + 1
            bool bearEntryCandleValid = closeBelowBox and (not requireEntryCandleDirection or close < open)
            shortEntrySignal := bearEntryCandleValid and canSignalThisBar and shortSignalsTaken < maxShortSignalsPerSession
            bearBreakoutArmed := false
            bearRetestActive := false
            bearBreakoutBar := na
            bearRetestBar := na
        else if bar_index > bearRetestBar + 1
            bearBreakoutArmed := false
            bearRetestActive := false
            bearBreakoutBar := na
            bearRetestBar := na

if longEntrySignal
    longSignalsTaken += 1
    lastSignalBar := bar_index

if shortEntrySignal
    shortSignalsTaken += 1
    lastSignalBar := bar_index

if not na(activeFairBox)
    box.set_right(activeFairBox, activeBoxRightTime)
    box.set_top(activeFairBox, fairZoneTop)
    box.set_bottom(activeFairBox, fairZoneBottom)

barcolor(colorSessionStartCandles and newAnchor ? newSessionColor : na)

color entryWindowBg = color.new(currentSessionColor, 90)
color monitorWindowBg = color.new(currentSessionColor, 95)
color activePhaseBg = showPhaseBackground ? (inEntryWindow ? entryWindowBg : inMonitorWindow ? monitorWindowBg : na) : na
bgcolor(activePhaseBg)

plot(showFairPriceLine and sessionActive ? fairPrice : na, "Fair price", color = color.new(currentSessionColor, 0), linewidth = 2, style = plot.style_linebr)

int nextReopenTime = enableReopen ? f_nextSessionTimestamp(reopenSession, sessionTimezone) : na
int nextAsiaTime = enableAsia ? f_nextSessionTimestamp(asiaSession, sessionTimezone) : na
int nextLondonTime = enableLondon ? f_nextSessionTimestamp(londonSession, sessionTimezone) : na
int nextNewYorkTime = enableNewYork ? f_nextSessionTimestamp(newYorkSession, sessionTimezone) : na
int nextNyPmTime = enableNyPm ? f_nextSessionTimestamp(nyPmSession, sessionTimezone) : na
int nextNewsTime = enableNews ? f_nextSessionTimestamp(newsSession, sessionTimezone) : na

int nextSessionTime = na
string nextSessionName = ""
string nextSessionTag = ""
color nextSessionColor = color.silver

if not na(nextReopenTime)
    nextSessionTime := nextReopenTime
    nextSessionName := "Market Reopen"
    nextSessionTag := "RE"
    nextSessionColor := reopenSessionColor

if not na(nextAsiaTime) and (na(nextSessionTime) or nextAsiaTime < nextSessionTime)
    nextSessionTime := nextAsiaTime
    nextSessionName := "Asia"
    nextSessionTag := "AS"
    nextSessionColor := asiaSessionColor

if not na(nextLondonTime) and (na(nextSessionTime) or nextLondonTime < nextSessionTime)
    nextSessionTime := nextLondonTime
    nextSessionName := "London"
    nextSessionTag := "LDN"
    nextSessionColor := londonSessionColor

if not na(nextNewYorkTime) and (na(nextSessionTime) or nextNewYorkTime < nextSessionTime)
    nextSessionTime := nextNewYorkTime
    nextSessionName := "New York Open"
    nextSessionTag := "NY"
    nextSessionColor := newYorkSessionColor

if not na(nextNyPmTime) and (na(nextSessionTime) or nextNyPmTime < nextSessionTime)
    nextSessionTime := nextNyPmTime
    nextSessionName := "New York PM"
    nextSessionTag := "PM"
    nextSessionColor := nyPmSessionColor

if not na(nextNewsTime) and (na(nextSessionTime) or nextNewsTime < nextSessionTime)
    nextSessionTime := nextNewsTime
    nextSessionName := "Pre-News"
    nextSessionTag := "NEWS"
    nextSessionColor := newsSessionColor

float previewHigh = ta.highest(high, previewRangeBars)
float previewLow = ta.lowest(low, previewRangeBars)
float previewSpan = math.max(previewHigh - previewLow, syminfo.mintick * 50)
float previewPad = previewSpan * previewPaddingPercent / 100.0
float previewTop = previewHigh + previewPad
float previewBottom = previewLow - previewPad
int nextSessionDurationMinutes = f_sessionDurationMinutes(nextSessionTag)
int nextSessionEndTime = na(nextSessionTime) ? na : nextSessionTime + nextSessionDurationMinutes * 60000
string nextSessionLocalTimeText = na(nextSessionTime) ? "NA" : str.format_time(nextSessionTime, "EEE hh:mm a", displayTimezone)
string nextSessionSessionTimeText = na(nextSessionTime) ? "NA" : str.format_time(nextSessionTime, "EEE HH:mm", sessionTimezone)
string nextSessionBoxText = "Next Session\n" + nextSessionName + " (" + nextSessionTag + ")\n" + "Local " + nextSessionLocalTimeText + "\n" + "Session " + nextSessionSessionTimeText

if showNextSessionPreview and timeframe.isintraday and not na(nextSessionTime)
    if na(nextSessionBox)
        nextSessionBox := box.new(nextSessionTime, previewTop, nextSessionEndTime, previewBottom, xloc = xloc.bar_time, bgcolor = color.new(nextSessionColor, nextSessionTransparency), border_color = color.new(nextSessionColor, 0), border_width = 1, text = nextSessionBoxText, text_color = color.white, text_size = size.small, force_overlay = true)
    else
        box.set_left(nextSessionBox, nextSessionTime)
        box.set_right(nextSessionBox, nextSessionEndTime)
        box.set_top(nextSessionBox, previewTop)
        box.set_bottom(nextSessionBox, previewBottom)
        box.set_bgcolor(nextSessionBox, color.new(nextSessionColor, nextSessionTransparency))
        box.set_border_color(nextSessionBox, color.new(nextSessionColor, 0))
        box.set_text(nextSessionBox, nextSessionBoxText)
        box.set_text_color(nextSessionBox, color.white)
else
    if not na(nextSessionBox)
        box.delete(nextSessionBox)
        nextSessionBox := na

string symbolTfText = syminfo.ticker + " / " + timeframe.period
string anchorText = currentSessionText + " " + sessionTimezone
string biasText = f_biasText(bullBias, bearBias)
string phaseText = f_phaseText(inEntryWindow, inMonitorWindow)
string fairPriceText = f_priceText(fairPrice)
string fairZoneText = f_priceText(fairZoneBottom) + " to " + f_priceText(fairZoneTop)
string breakoutTextLong = "Close " + f_priceText(bullBreakoutClose) + " above " + f_priceText(fairZoneTop)
string breakoutTextShort = "Close " + f_priceText(bearBreakoutClose) + " below " + f_priceText(fairZoneBottom)
string retestTextLong = "Retest close " + f_priceText(bullRetestClose) + " held above box"
string retestTextShort = "Retest close " + f_priceText(bearRetestClose) + " held below box"
string signalCountsText = "Long " + str.tostring(longSignalsTaken) + "/" + str.tostring(maxLongSignalsPerSession) + " | Short " + str.tostring(shortSignalsTaken) + "/" + str.tostring(maxShortSignalsPerSession)

if longEntrySignal
    label.new(bar_index, low, text = currentSessionTag + " LONG", yloc = yloc.belowbar, style = label.style_label_up, color = color.lime, textcolor = color.black, size = size.small, tooltip = f_buildTooltip(f_signalName(true), currentSessionName, currentSessionTag, phaseText, symbolTfText, anchorText, biasText, fairPriceText, fairZoneText, breakoutTextLong, retestTextLong, f_priceText(close), signalCountsText), force_overlay = true)

if shortEntrySignal
    label.new(bar_index, high, text = currentSessionTag + " SHORT", yloc = yloc.abovebar, style = label.style_label_down, color = color.red, textcolor = color.white, size = size.small, tooltip = f_buildTooltip(f_signalName(false), currentSessionName, currentSessionTag, phaseText, symbolTfText, anchorText, biasText, fairPriceText, fairZoneText, breakoutTextShort, retestTextShort, f_priceText(close), signalCountsText), force_overlay = true)

alertcondition(longEntrySignal, "Bullish Box Retest Long", "Bullish box retest long on {{ticker}} {{interval}}")
alertcondition(shortEntrySignal, "Bearish Box Retest Short", "Bearish box retest short on {{ticker}} {{interval}}")
alertcondition(longEntrySignal or shortEntrySignal, "Any Box Retest Entry", "Any fair-price box retest entry on {{ticker}} {{interval}}")
````
