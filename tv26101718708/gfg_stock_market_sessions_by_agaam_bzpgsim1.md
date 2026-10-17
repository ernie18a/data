# GFG Stock Market Sessions by Agaam

- url: https://www.tradingview.com/script/bzPgSIM1-GFG-Stock-Market-Sessions-by-Agaam/
- type: indicator
- pine_id: PUB;073baff712d14850a44baa20ef088acd
- version: 1.0

## Description

## GFG Stock Market Sessions by Agaam

GFG Stock Market Sessions is an intraday chart-overlay indicator designed to identify and display the major global stock-market trading sessions directly on the price chart.

The indicator tracks the high, low, opening price, start time, and end time of each enabled session. All session times displayed in the chart labels are converted to New York time for easier comparison.

### Included sessions

The indicator can display:

* Asia / Tokyo session
* London session
* U.S. pre-market
* New York regular trading session
* U.S. after-hours session

Each session can be enabled or disabled independently.

### Session boxes

A colored box is drawn while each session is active.

The box represents:

* Top boundary: highest price reached during the session
* Bottom boundary: lowest price reached during the session
* Left boundary: beginning of the session
* Right boundary: final bar of the session

The box updates as new highs or lows are created. When the session ends, the completed high-to-low range remains visible on the chart.

### Session opening lines

An optional horizontal line marks the opening price of each session.

Users can adjust:

* Line width
* Line style
* Session color
* Box transparency
* Border transparency

### Session labels

Optional labels can display:

* Session name
* Session opening and closing time
* Times converted to New York time
* Current or completed session range

Session labels can be removed entirely through the “Show Session Labels” setting. The session boxes and opening lines can remain visible without the labels.

The label time format can be displayed in either:

* 12-hour format
* 24-hour format

### Default session schedule

The default settings use:

* Asia / Tokyo: 9:00 AM–3:30 PM Tokyo local time
* London: 8:00 AM–4:30 PM London local time
* U.S. pre-market: 4:00 AM–9:30 AM New York time
* New York regular session: 9:30 AM–4:00 PM New York time
* U.S. after-hours: 4:00 PM–8:00 PM New York time

The session schedules and time zones can be changed from the indicator settings.

### Time-zone handling

The indicator uses dedicated time zones for Tokyo, London, and New York.

This allows the session detection and New York time labels to adjust when daylight-saving schedules change. During periods when different countries change their clocks on different dates, the displayed session relationships may temporarily shift.

### Alerts

Optional TradingView alerts are available when each enabled session begins:

* Asia session started
* London session started
* U.S. pre-market started
* New York regular session started
* U.S. after-hours started

### Recommended use

This indicator is intended for intraday charts.

It can help traders observe:

* Session-specific volatility
* Session highs and lows
* Changes in market participation
* Overlap between global sessions
* Breakouts from previous session ranges
* Reactions around session opening prices

The indicator does not generate automatic buy or sell signals. Session ranges and opening levels should be evaluated together with price action, volume, market structure, risk management, and the trader’s own strategy.

### Important notes

The active session box changes while the session is still developing because new highs or lows may occur.

After the session ends, its completed high, low, opening price, and time boundaries remain fixed unless the indicator settings or historical data are changed.

This indicator is designed as a chart-organization and market-session analysis tool. It does not predict future market direction.

### Disclaimer

This indicator is provided for informational and educational purposes only. It is not financial, investment, or trading advice. No indicator can guarantee profitable results. Trading involves risk, including the possible loss of capital. Always perform your own analysis and use appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("GFG Stock Market Sessions by Agaam", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string groupDisplay = "Display"
string groupAsia = "Asia / Tokyo Session"
string groupLondon = "London Session"
string groupPreMarket = "U.S. Pre-Market"
string groupNewYork = "New York Regular Session"
string groupAfterHours = "U.S. After-Hours"
string groupHistory = "History"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showSessionBoxes = input.bool(true, "Show Session Boxes", group=groupDisplay)
bool showSessionLabels = input.bool(true, "Show Session Labels", group=groupDisplay)
bool showSessionTimes = input.bool(true, "Show Times in Labels", group=groupDisplay)
bool showSessionRange = input.bool(true, "Show Range in Labels", group=groupDisplay)
bool showOpeningLines = input.bool(true, "Show Session Open Lines", group=groupDisplay)

string timeFormatInput = input.string("12-hour", "New York Time Format", options=["12-hour", "24-hour"], group=groupDisplay)

int fillTransparency = input.int(88, "Box Fill Transparency", minval=0, maxval=100, group=groupDisplay)
int borderTransparency = input.int(20, "Box Border Transparency", minval=0, maxval=100, group=groupDisplay)
int borderWidth = input.int(1, "Box Border Width", minval=1, maxval=5, group=groupDisplay)

string labelSizeInput = input.string("Small", "Session Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)
color labelTextColor = input.color(color.white, "Session Label Text Color", group=groupDisplay)

string openLineStyleInput = input.string("Dashed", "Opening Line Style", options=["Solid", "Dashed", "Dotted"], group=groupDisplay)
int openLineWidth = input.int(1, "Opening Line Width", minval=1, maxval=5, group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA / TOKYO SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showAsia = input.bool(true, "Show Asia / Tokyo", group=groupAsia)
string asiaSession = input.session("0900-1530", "Tokyo Local Session", group=groupAsia)
string asiaTimezone = input.string("Asia/Tokyo", "Session Time Zone", group=groupAsia)
color asiaColor = input.color(color.rgb(55, 120, 205), "Session Color", group=groupAsia)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showLondon = input.bool(true, "Show London", group=groupLondon)
string londonSession = input.session("0800-1630", "London Local Session", group=groupLondon)
string londonTimezone = input.string("Europe/London", "Session Time Zone", group=groupLondon)
color londonColor = input.color(color.rgb(145, 90, 190), "Session Color", group=groupLondon)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// U.S. PRE-MARKET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showPreMarket = input.bool(false, "Show U.S. Pre-Market", group=groupPreMarket)
string preMarketSession = input.session("0400-0930", "Pre-Market New York Time", group=groupPreMarket)
string preMarketTimezone = input.string("America/New_York", "Session Time Zone", group=groupPreMarket)
color preMarketColor = input.color(color.rgb(215, 145, 45), "Session Color", group=groupPreMarket)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK REGULAR SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showNewYork = input.bool(true, "Show New York Regular Session", group=groupNewYork)
string newYorkSession = input.session("0930-1600", "Regular Session New York Time", group=groupNewYork)
string newYorkTimezone = input.string("America/New_York", "Session Time Zone", group=groupNewYork)
color newYorkColor = input.color(color.rgb(35, 165, 115), "Session Color", group=groupNewYork)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// U.S. AFTER-HOURS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showAfterHours = input.bool(false, "Show U.S. After-Hours", group=groupAfterHours)
string afterHoursSession = input.session("1600-2000", "After-Hours New York Time", group=groupAfterHours)
string afterHoursTimezone = input.string("America/New_York", "Session Time Zone", group=groupAfterHours)
color afterHoursColor = input.color(color.rgb(115, 120, 135), "Session Color", group=groupAfterHours)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int maximumSessionObjects = input.int(250, "Maximum Historical Sessions", minval=10, maxval=450, group=groupHistory)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string displayTimezone = "America/New_York"
string weekdaySuffix = ":23456"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_label_size(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny : selectedSize == "Small" ? size.small : selectedSize == "Normal" ? size.normal : size.large

f_line_style(string selectedStyle) =>
    selectedStyle == "Solid" ? line.style_solid : selectedStyle == "Dashed" ? line.style_dashed : line.style_dotted

f_session_time_new_york(string sessionValue, string sourceTimezone, int referenceTime, string selectedFormat) =>
    int startHour = int(str.tonumber(str.substring(sessionValue, 0, 2)))
    int startMinute = int(str.tonumber(str.substring(sessionValue, 2, 4)))

    int endHour = int(str.tonumber(str.substring(sessionValue, 5, 7)))
    int endMinute = int(str.tonumber(str.substring(sessionValue, 7, 9)))

    int sourceYear = year(referenceTime, sourceTimezone)
    int sourceMonth = month(referenceTime, sourceTimezone)
    int sourceDay = dayofmonth(referenceTime, sourceTimezone)

    int startTimestamp = timestamp(sourceTimezone, sourceYear, sourceMonth, sourceDay, startHour, startMinute)

    int startTotalMinutes = startHour * 60 + startMinute
    int endTotalMinutes = endHour * 60 + endMinute
    int durationMinutes = endTotalMinutes - startTotalMinutes

    if durationMinutes <= 0
        durationMinutes += 1440

    int endTimestamp = startTimestamp + durationMinutes * 60000

    string clockFormat = selectedFormat == "12-hour" ? "h:mm a" : "HH:mm"

    string startText = str.format_time(startTimestamp, clockFormat, displayTimezone)
    string endText = str.format_time(endTimestamp, clockFormat, displayTimezone)

    startText + " - " + endText + " New York"

f_session_text(string sessionName, string newYorkTimeText, float sessionHigh, float sessionLow) =>
    string result = sessionName

    if showSessionTimes
        result += "\n" + newYorkTimeText

    if showSessionRange
        result += "\nRange: " + str.tostring(sessionHigh - sessionLow, format.mintick)

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<box> sessionBoxes = array.new<box>()
var array<label> sessionLabels = array.new<label>()
var array<line> sessionOpenLines = array.new<line>()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int asiaTime = time(timeframe.period, asiaSession + weekdaySuffix, asiaTimezone)
int londonTime = time(timeframe.period, londonSession + weekdaySuffix, londonTimezone)
int preMarketTime = time(timeframe.period, preMarketSession + weekdaySuffix, preMarketTimezone)
int newYorkTime = time(timeframe.period, newYorkSession + weekdaySuffix, newYorkTimezone)
int afterHoursTime = time(timeframe.period, afterHoursSession + weekdaySuffix, afterHoursTimezone)

bool asiaActive = timeframe.isintraday and showAsia and not na(asiaTime)
bool londonActive = timeframe.isintraday and showLondon and not na(londonTime)
bool preMarketActive = timeframe.isintraday and showPreMarket and not na(preMarketTime)
bool newYorkActive = timeframe.isintraday and showNewYork and not na(newYorkTime)
bool afterHoursActive = timeframe.isintraday and showAfterHours and not na(afterHoursTime)

bool asiaStart = asiaActive and not asiaActive[1]
bool londonStart = londonActive and not londonActive[1]
bool preMarketStart = preMarketActive and not preMarketActive[1]
bool newYorkStart = newYorkActive and not newYorkActive[1]
bool afterHoursStart = afterHoursActive and not afterHoursActive[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA / TOKYO SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box asiaBox = na
var label asiaLabel = na
var line asiaOpenLine = na

var float asiaHigh = na
var float asiaLow = na
var float asiaOpen = na
var int asiaStartBar = na
var string asiaNewYorkTimeText = ""

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaOpen := open
    asiaStartBar := bar_index

    asiaNewYorkTimeText := f_session_time_new_york(asiaSession, asiaTimezone, time, timeFormatInput)

    asiaBox := na
    asiaLabel := na
    asiaOpenLine := na

    if showSessionBoxes
        asiaBox := box.new(left=bar_index, top=asiaHigh, right=bar_index, bottom=asiaLow, xloc=xloc.bar_index, border_color=color.new(asiaColor, borderTransparency), border_width=borderWidth, bgcolor=color.new(asiaColor, fillTransparency))
        array.push(sessionBoxes, asiaBox)

    if showSessionLabels
        asiaLabel := label.new(bar_index, asiaHigh, f_session_text("ASIA / TOKYO", asiaNewYorkTimeText, asiaHigh, asiaLow), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(asiaColor, 10), textcolor=labelTextColor, size=f_label_size(labelSizeInput))
        array.push(sessionLabels, asiaLabel)

    if showOpeningLines
        asiaOpenLine := line.new(bar_index, asiaOpen, bar_index, asiaOpen, xloc=xloc.bar_index, extend=extend.none, color=asiaColor, style=f_line_style(openLineStyleInput), width=openLineWidth)
        array.push(sessionOpenLines, asiaOpenLine)

if asiaActive
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)

    if not na(asiaBox)
        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_border_color(asiaBox, color.new(asiaColor, borderTransparency))
        box.set_bgcolor(asiaBox, color.new(asiaColor, fillTransparency))

    if showSessionLabels and not na(asiaLabel)
        int asiaMiddleBar = int(math.floor((asiaStartBar + bar_index) * 0.5))

        label.set_xy(asiaLabel, asiaMiddleBar, asiaHigh)
        label.set_text(asiaLabel, f_session_text("ASIA / TOKYO", asiaNewYorkTimeText, asiaHigh, asiaLow))
        label.set_color(asiaLabel, color.new(asiaColor, 10))
        label.set_textcolor(asiaLabel, labelTextColor)
        label.set_size(asiaLabel, f_label_size(labelSizeInput))

    if not na(asiaOpenLine)
        line.set_xy1(asiaOpenLine, asiaStartBar, asiaOpen)
        line.set_xy2(asiaOpenLine, bar_index, asiaOpen)
        line.set_color(asiaOpenLine, asiaColor)
        line.set_style(asiaOpenLine, f_line_style(openLineStyleInput))
        line.set_width(asiaOpenLine, openLineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box londonBox = na
var label londonLabel = na
var line londonOpenLine = na

var float londonHigh = na
var float londonLow = na
var float londonOpen = na
var int londonStartBar = na
var string londonNewYorkTimeText = ""

if londonStart
    londonHigh := high
    londonLow := low
    londonOpen := open
    londonStartBar := bar_index

    londonNewYorkTimeText := f_session_time_new_york(londonSession, londonTimezone, time, timeFormatInput)

    londonBox := na
    londonLabel := na
    londonOpenLine := na

    if showSessionBoxes
        londonBox := box.new(left=bar_index, top=londonHigh, right=bar_index, bottom=londonLow, xloc=xloc.bar_index, border_color=color.new(londonColor, borderTransparency), border_width=borderWidth, bgcolor=color.new(londonColor, fillTransparency))
        array.push(sessionBoxes, londonBox)

    if showSessionLabels
        londonLabel := label.new(bar_index, londonHigh, f_session_text("LONDON", londonNewYorkTimeText, londonHigh, londonLow), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(londonColor, 10), textcolor=labelTextColor, size=f_label_size(labelSizeInput))
        array.push(sessionLabels, londonLabel)

    if showOpeningLines
        londonOpenLine := line.new(bar_index, londonOpen, bar_index, londonOpen, xloc=xloc.bar_index, extend=extend.none, color=londonColor, style=f_line_style(openLineStyleInput), width=openLineWidth)
        array.push(sessionOpenLines, londonOpenLine)

if londonActive
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow := math.min(nz(londonLow, low), low)

    if not na(londonBox)
        box.set_right(londonBox, bar_index)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_border_color(londonBox, color.new(londonColor, borderTransparency))
        box.set_bgcolor(londonBox, color.new(londonColor, fillTransparency))

    if showSessionLabels and not na(londonLabel)
        int londonMiddleBar = int(math.floor((londonStartBar + bar_index) * 0.5))

        label.set_xy(londonLabel, londonMiddleBar, londonHigh)
        label.set_text(londonLabel, f_session_text("LONDON", londonNewYorkTimeText, londonHigh, londonLow))
        label.set_color(londonLabel, color.new(londonColor, 10))
        label.set_textcolor(londonLabel, labelTextColor)
        label.set_size(londonLabel, f_label_size(labelSizeInput))

    if not na(londonOpenLine)
        line.set_xy1(londonOpenLine, londonStartBar, londonOpen)
        line.set_xy2(londonOpenLine, bar_index, londonOpen)
        line.set_color(londonOpenLine, londonColor)
        line.set_style(londonOpenLine, f_line_style(openLineStyleInput))
        line.set_width(londonOpenLine, openLineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// U.S. PRE-MARKET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box preMarketBox = na
var label preMarketLabel = na
var line preMarketOpenLine = na

var float preMarketHigh = na
var float preMarketLow = na
var float preMarketOpen = na
var int preMarketStartBar = na
var string preMarketNewYorkTimeText = ""

if preMarketStart
    preMarketHigh := high
    preMarketLow := low
    preMarketOpen := open
    preMarketStartBar := bar_index

    preMarketNewYorkTimeText := f_session_time_new_york(preMarketSession, preMarketTimezone, time, timeFormatInput)

    preMarketBox := na
    preMarketLabel := na
    preMarketOpenLine := na

    if showSessionBoxes
        preMarketBox := box.new(left=bar_index, top=preMarketHigh, right=bar_index, bottom=preMarketLow, xloc=xloc.bar_index, border_color=color.new(preMarketColor, borderTransparency), border_width=borderWidth, bgcolor=color.new(preMarketColor, fillTransparency))
        array.push(sessionBoxes, preMarketBox)

    if showSessionLabels
        preMarketLabel := label.new(bar_index, preMarketHigh, f_session_text("U.S. PRE-MARKET", preMarketNewYorkTimeText, preMarketHigh, preMarketLow), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(preMarketColor, 10), textcolor=labelTextColor, size=f_label_size(labelSizeInput))
        array.push(sessionLabels, preMarketLabel)

    if showOpeningLines
        preMarketOpenLine := line.new(bar_index, preMarketOpen, bar_index, preMarketOpen, xloc=xloc.bar_index, extend=extend.none, color=preMarketColor, style=f_line_style(openLineStyleInput), width=openLineWidth)
        array.push(sessionOpenLines, preMarketOpenLine)

if preMarketActive
    preMarketHigh := math.max(nz(preMarketHigh, high), high)
    preMarketLow := math.min(nz(preMarketLow, low), low)

    if not na(preMarketBox)
        box.set_right(preMarketBox, bar_index)
        box.set_top(preMarketBox, preMarketHigh)
        box.set_bottom(preMarketBox, preMarketLow)
        box.set_border_color(preMarketBox, color.new(preMarketColor, borderTransparency))
        box.set_bgcolor(preMarketBox, color.new(preMarketColor, fillTransparency))

    if showSessionLabels and not na(preMarketLabel)
        int preMarketMiddleBar = int(math.floor((preMarketStartBar + bar_index) * 0.5))

        label.set_xy(preMarketLabel, preMarketMiddleBar, preMarketHigh)
        label.set_text(preMarketLabel, f_session_text("U.S. PRE-MARKET", preMarketNewYorkTimeText, preMarketHigh, preMarketLow))
        label.set_color(preMarketLabel, color.new(preMarketColor, 10))
        label.set_textcolor(preMarketLabel, labelTextColor)
        label.set_size(preMarketLabel, f_label_size(labelSizeInput))

    if not na(preMarketOpenLine)
        line.set_xy1(preMarketOpenLine, preMarketStartBar, preMarketOpen)
        line.set_xy2(preMarketOpenLine, bar_index, preMarketOpen)
        line.set_color(preMarketOpenLine, preMarketColor)
        line.set_style(preMarketOpenLine, f_line_style(openLineStyleInput))
        line.set_width(preMarketOpenLine, openLineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK REGULAR SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box newYorkBox = na
var label newYorkLabel = na
var line newYorkOpenLine = na

var float newYorkHigh = na
var float newYorkLow = na
var float newYorkOpen = na
var int newYorkStartBar = na
var string regularNewYorkTimeText = ""

if newYorkStart
    newYorkHigh := high
    newYorkLow := low
    newYorkOpen := open
    newYorkStartBar := bar_index

    regularNewYorkTimeText := f_session_time_new_york(newYorkSession, newYorkTimezone, time, timeFormatInput)

    newYorkBox := na
    newYorkLabel := na
    newYorkOpenLine := na

    if showSessionBoxes
        newYorkBox := box.new(left=bar_index, top=newYorkHigh, right=bar_index, bottom=newYorkLow, xloc=xloc.bar_index, border_color=color.new(newYorkColor, borderTransparency), border_width=borderWidth, bgcolor=color.new(newYorkColor, fillTransparency))
        array.push(sessionBoxes, newYorkBox)

    if showSessionLabels
        newYorkLabel := label.new(bar_index, newYorkHigh, f_session_text("NEW YORK", regularNewYorkTimeText, newYorkHigh, newYorkLow), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(newYorkColor, 10), textcolor=labelTextColor, size=f_label_size(labelSizeInput))
        array.push(sessionLabels, newYorkLabel)

    if showOpeningLines
        newYorkOpenLine := line.new(bar_index, newYorkOpen, bar_index, newYorkOpen, xloc=xloc.bar_index, extend=extend.none, color=newYorkColor, style=f_line_style(openLineStyleInput), width=openLineWidth)
        array.push(sessionOpenLines, newYorkOpenLine)

if newYorkActive
    newYorkHigh := math.max(nz(newYorkHigh, high), high)
    newYorkLow := math.min(nz(newYorkLow, low), low)

    if not na(newYorkBox)
        box.set_right(newYorkBox, bar_index)
        box.set_top(newYorkBox, newYorkHigh)
        box.set_bottom(newYorkBox, newYorkLow)
        box.set_border_color(newYorkBox, color.new(newYorkColor, borderTransparency))
        box.set_bgcolor(newYorkBox, color.new(newYorkColor, fillTransparency))

    if showSessionLabels and not na(newYorkLabel)
        int newYorkMiddleBar = int(math.floor((newYorkStartBar + bar_index) * 0.5))

        label.set_xy(newYorkLabel, newYorkMiddleBar, newYorkHigh)
        label.set_text(newYorkLabel, f_session_text("NEW YORK", regularNewYorkTimeText, newYorkHigh, newYorkLow))
        label.set_color(newYorkLabel, color.new(newYorkColor, 10))
        label.set_textcolor(newYorkLabel, labelTextColor)
        label.set_size(newYorkLabel, f_label_size(labelSizeInput))

    if not na(newYorkOpenLine)
        line.set_xy1(newYorkOpenLine, newYorkStartBar, newYorkOpen)
        line.set_xy2(newYorkOpenLine, bar_index, newYorkOpen)
        line.set_color(newYorkOpenLine, newYorkColor)
        line.set_style(newYorkOpenLine, f_line_style(openLineStyleInput))
        line.set_width(newYorkOpenLine, openLineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// U.S. AFTER-HOURS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box afterHoursBox = na
var label afterHoursLabel = na
var line afterHoursOpenLine = na

var float afterHoursHigh = na
var float afterHoursLow = na
var float afterHoursOpen = na
var int afterHoursStartBar = na
var string afterHoursNewYorkTimeText = ""

if afterHoursStart
    afterHoursHigh := high
    afterHoursLow := low
    afterHoursOpen := open
    afterHoursStartBar := bar_index

    afterHoursNewYorkTimeText := f_session_time_new_york(afterHoursSession, afterHoursTimezone, time, timeFormatInput)

    afterHoursBox := na
    afterHoursLabel := na
    afterHoursOpenLine := na

    if showSessionBoxes
        afterHoursBox := box.new(left=bar_index, top=afterHoursHigh, right=bar_index, bottom=afterHoursLow, xloc=xloc.bar_index, border_color=color.new(afterHoursColor, borderTransparency), border_width=borderWidth, bgcolor=color.new(afterHoursColor, fillTransparency))
        array.push(sessionBoxes, afterHoursBox)

    if showSessionLabels
        afterHoursLabel := label.new(bar_index, afterHoursHigh, f_session_text("U.S. AFTER-HOURS", afterHoursNewYorkTimeText, afterHoursHigh, afterHoursLow), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(afterHoursColor, 10), textcolor=labelTextColor, size=f_label_size(labelSizeInput))
        array.push(sessionLabels, afterHoursLabel)

    if showOpeningLines
        afterHoursOpenLine := line.new(bar_index, afterHoursOpen, bar_index, afterHoursOpen, xloc=xloc.bar_index, extend=extend.none, color=afterHoursColor, style=f_line_style(openLineStyleInput), width=openLineWidth)
        array.push(sessionOpenLines, afterHoursOpenLine)

if afterHoursActive
    afterHoursHigh := math.max(nz(afterHoursHigh, high), high)
    afterHoursLow := math.min(nz(afterHoursLow, low), low)

    if not na(afterHoursBox)
        box.set_right(afterHoursBox, bar_index)
        box.set_top(afterHoursBox, afterHoursHigh)
        box.set_bottom(afterHoursBox, afterHoursLow)
        box.set_border_color(afterHoursBox, color.new(afterHoursColor, borderTransparency))
        box.set_bgcolor(afterHoursBox, color.new(afterHoursColor, fillTransparency))

    if showSessionLabels and not na(afterHoursLabel)
        int afterHoursMiddleBar = int(math.floor((afterHoursStartBar + bar_index) * 0.5))

        label.set_xy(afterHoursLabel, afterHoursMiddleBar, afterHoursHigh)
        label.set_text(afterHoursLabel, f_session_text("U.S. AFTER-HOURS", afterHoursNewYorkTimeText, afterHoursHigh, afterHoursLow))
        label.set_color(afterHoursLabel, color.new(afterHoursColor, 10))
        label.set_textcolor(afterHoursLabel, labelTextColor)
        label.set_size(afterHoursLabel, f_label_size(labelSizeInput))

    if not na(afterHoursOpenLine)
        line.set_xy1(afterHoursOpenLine, afterHoursStartBar, afterHoursOpen)
        line.set_xy2(afterHoursOpenLine, bar_index, afterHoursOpen)
        line.set_color(afterHoursOpenLine, afterHoursColor)
        line.set_style(afterHoursOpenLine, f_line_style(openLineStyleInput))
        line.set_width(afterHoursOpenLine, openLineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REMOVE ALL LABELS WHEN LABEL DISPLAY IS OFF
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not showSessionLabels
    while array.size(sessionLabels) > 0
        label removableLabel = array.pop(sessionLabels)
        label.delete(removableLabel)

    asiaLabel := na
    londonLabel := na
    preMarketLabel := na
    newYorkLabel := na
    afterHoursLabel := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORY CONTROL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while array.size(sessionBoxes) > maximumSessionObjects
    box oldestBox = array.shift(sessionBoxes)
    box.delete(oldestBox)

while array.size(sessionLabels) > maximumSessionObjects
    label oldestLabel = array.shift(sessionLabels)
    label.delete(oldestLabel)

while array.size(sessionOpenLines) > maximumSessionObjects
    line oldestOpenLine = array.shift(sessionOpenLines)
    line.delete(oldestOpenLine)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME WARNING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label timeframeWarning = na

if barstate.islast
    if not timeframe.isintraday
        if na(timeframeWarning)
            timeframeWarning := label.new(bar_index, high, "Use this indicator on an intraday chart.", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.rgb(190, 60, 60), textcolor=color.white, size=size.normal)
        else
            label.set_xy(timeframeWarning, bar_index, high)
    else
        if not na(timeframeWarning)
            label.delete(timeframeWarning)
            timeframeWarning := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(asiaStart, title="Asia Session Started", message="Asia/Tokyo session started on {{ticker}} {{interval}}.")
alertcondition(londonStart, title="London Session Started", message="London session started on {{ticker}} {{interval}}.")
alertcondition(preMarketStart, title="U.S. Pre-Market Started", message="U.S. pre-market started on {{ticker}} {{interval}}.")
alertcondition(newYorkStart, title="New York Session Started", message="New York regular session started on {{ticker}} {{interval}}.")
alertcondition(afterHoursStart, title="U.S. After-Hours Started", message="U.S. after-hours started on {{ticker}} {{interval}}.")
````
