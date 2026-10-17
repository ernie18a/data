# Trading Sessions (Revised)

- url: https://www.tradingview.com/script/lXaETW1C-Trading-Sessions-Revised/
- type: indicator
- pine_id: PUB;431b64d6c907484d9a4460cb7ebba1d7
- version: 1.0

## Description

Trading Sessions (Revised) - It adds +1 day vertical line to see when day ends.

## Source Code

````pine
//@version=6
indicator("Trading Sessions (Revised)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

bool showSessionNames     = input.bool(true, "Show session names")
bool showSessionOC        = input.bool(true, "Draw session open and close lines")
bool showSessionTickRange = input.bool(true, "Show tick range for each session")
bool showSessionAverage   = input.bool(true, "Show average price per session")

// === NEW YORK VERTICAL LINE SETTINGS ===
bool showNYVerticalLines      = input.bool(true, "Show NY 09:30 / 16:00 vertical lines", group = "New York Vertical Lines")
bool showNextDayNYLines       = input.bool(true, "Show next-day projected NY lines", group = "New York Vertical Lines")
bool skipWeekendsForNextDay   = input.bool(true, "Skip weekends for projected lines", group = "New York Vertical Lines")

color nyOpenLineColor         = input.color(color.new(color.green, 0), "NY Open Line Color", group = "New York Vertical Lines")
color nyCloseLineColor        = input.color(color.new(color.red, 0), "NY Close Line Color", group = "New York Vertical Lines")
color nyNextDayOpenLineColor  = input.color(color.new(color.green, 35), "Next-Day NY Open Line Color", group = "New York Vertical Lines")
color nyNextDayCloseLineColor = input.color(color.new(color.red, 35), "Next-Day NY Close Line Color", group = "New York Vertical Lines")

int nyLineWidth               = input.int(2, "Line Width", minval = 1, maxval = 5, group = "New York Vertical Lines")
string nyLineStyleInput       = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "New York Vertical Lines")

line_style =
     nyLineStyleInput == "Solid"  ? line.style_solid  :
     nyLineStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed

const string TZ_TOOLTIP_TEXT = "The session's time zone, specified in either GMT notation, e.g. 'GMT-5', or as an IANA time zone database name, e.g. 'America/New_York'. We recommend the latter since it includes daylight savings changes."

const string FIRST_SESSION_GROUP = "First Session"
showFirst         = input.bool(false, "Show session", group = FIRST_SESSION_GROUP, display = display.none)
firstSessionName  = input.string("Tokyo", "Displayed name", group = FIRST_SESSION_GROUP, display = display.none, active = showFirst)
firstSessionTime  = input.session("0900-1500", "Session time", group = FIRST_SESSION_GROUP, display = display.none, active = showFirst)
firstSessionTZ    = input.string("Asia/Tokyo", "Session timezone", group = FIRST_SESSION_GROUP, display = display.none, tooltip = TZ_TOOLTIP_TEXT, active = showFirst)
firstSessionColor = input.color(color.new(#2962FF, 85), "Session color", group = FIRST_SESSION_GROUP, active = showFirst)

const string SECOND_SESSION_GROUP = "Second session"
showSecond         = input.bool(false, "Show session", group = SECOND_SESSION_GROUP, display = display.none)
secondSessionName  = input.string("London", "Displayed name", group = SECOND_SESSION_GROUP, display = display.none, active = showSecond)
secondSessionTime  = input.session("0830-1630", "Session time", group = SECOND_SESSION_GROUP, display = display.none, active = showSecond)
secondSessionTZ    = input.string("Europe/London", "Session timezone", group = SECOND_SESSION_GROUP, display = display.none, tooltip = TZ_TOOLTIP_TEXT, active = showSecond)
secondSessionColor = input.color(color.new(#FF9800, 85), "Session color", group = SECOND_SESSION_GROUP, active = showSecond)

const string THIRD_SESSION_GROUP = "Third session"
showThird         = input.bool(false, "Show session", group = THIRD_SESSION_GROUP, display = display.none)
thirdSessionName  = input.string("New York", "Displayed name", group = THIRD_SESSION_GROUP, display = display.none, active = showThird)
thirdSessionTime  = input.session("0930-1600", "Session time", group = THIRD_SESSION_GROUP, display = display.none, active = showThird)
thirdSessionTZ    = input.string("America/New_York", "Session timezone", group = THIRD_SESSION_GROUP, display = display.none, tooltip = TZ_TOOLTIP_TEXT, active = showThird)
thirdSessionColor = input.color(color.new(#089981, 85), "Session color", group = THIRD_SESSION_GROUP, active = showThird)

type SessionDisplay
    box   sessionBox
    label sessionLabel
    line  openLine
    line  avgLine
    line  closeLine
    float sumClose
    int   numOfBars

type SessionInfo
    color  color
    string name
    string session
    string timezone
    SessionDisplay active = na

method setName(SessionDisplay this, string name) =>
    sessionLabel = this.sessionLabel
    sessionBox = this.sessionBox
    boxText = array.new<string>()

    if showSessionTickRange
        boxText.push("Range: " + str.tostring((sessionBox.get_top() - sessionBox.get_bottom()) / syminfo.mintick, format.mintick))

    if showSessionAverage
        boxText.push("Avg: " + str.tostring(this.sumClose / this.numOfBars, format.mintick))

    if showSessionNames
        boxText.push(name)

    sessionLabel.set_y(sessionBox.get_bottom())
    sessionLabel.set_text(array.join(boxText, "\n"))

method createSessionDisplay(SessionInfo this) =>
    boxColor = this.color
    opaqueColor = color.new(boxColor, 0)

    dis = SessionDisplay.new(
         sessionBox = box.new(bar_index, high, bar_index, low, bgcolor = boxColor, border_color = na),
         sessionLabel = label.new(bar_index, low, "", style = label.style_label_upper_left, textalign = text.align_left, textcolor = opaqueColor, color = color(na)),
         openLine = showSessionOC ? line.new(bar_index, open, bar_index, open, color = opaqueColor, style = line.style_dashed, width = 1) : na,
         closeLine = showSessionOC ? line.new(bar_index, close, bar_index, close, color = opaqueColor, style = line.style_dashed, width = 1) : na,
         avgLine = showSessionAverage ? line.new(bar_index, close, bar_index, close, style = line.style_dotted, width = 2, color = opaqueColor) : na,
         sumClose = close,
         numOfBars = 1
     )

    if showSessionOC
        linefill.new(dis.openLine, dis.closeLine, boxColor)

    dis.setName(this.name)
    this.active := dis

method updateSessionDisplay(SessionInfo this) =>
    sessionDisp = this.active
    sessionBox = sessionDisp.sessionBox
    openLine = sessionDisp.openLine
    closeLine = sessionDisp.closeLine
    avgLine = sessionDisp.avgLine

    sessionDisp.sumClose += close
    sessionDisp.numOfBars += 1

    sessionBox.set_top(math.max(sessionBox.get_top(), high))
    sessionBox.set_bottom(math.min(sessionBox.get_bottom(), low))
    sessionBox.set_right(bar_index)

    sessionDisp.setName(this.name)

    if showSessionOC
        openLine.set_x2(bar_index)
        closeLine.set_x2(bar_index)
        closeLine.set_y1(close)
        closeLine.set_y2(close)

    if showSessionAverage
        avgLine.set_x2(bar_index)
        avg = sessionDisp.sumClose / sessionDisp.numOfBars
        avgLine.set_y1(avg)
        avgLine.set_y2(avg)

    sessionDisp

method update(SessionInfo this) =>
    bool isChange = timeframe.change("1D")

    if not na(time("", this.session, this.timezone))
        if na(this.active) or isChange
            this.createSessionDisplay()
        else
            this.updateSessionDisplay()
    else if not na(this.active)
        this.active := na

getSessionInfos() =>
    array<SessionInfo> sessionInfos = array.new<SessionInfo>()

    if showFirst
        sessionInfos.push(SessionInfo.new(firstSessionColor, firstSessionName, firstSessionTime, firstSessionTZ))

    if showSecond
        sessionInfos.push(SessionInfo.new(secondSessionColor, secondSessionName, secondSessionTime, secondSessionTZ))

    if showThird
        sessionInfos.push(SessionInfo.new(thirdSessionColor, thirdSessionName, thirdSessionTime, thirdSessionTZ))

    sessionInfos

var array<SessionInfo> sessionInfos = getSessionInfos()

if timeframe.isdwm
    runtime.error("This indicator can only be used on intraday timeframes.")

// === UPDATE SESSION BOXES ===
for info in sessionInfos
    info.update()

// === EXACT NEW YORK 09:30 AND 16:00 VERTICAL LINES ===
int nyYear  = year(time, "America/New_York")
int nyMonth = month(time, "America/New_York")
int nyDay   = dayofmonth(time, "America/New_York")

bool newNYDay = ta.change(nyDay) != 0

int nyOpenTime  = timestamp("America/New_York", nyYear, nyMonth, nyDay, 9, 30)
int nyCloseTime = timestamp("America/New_York", nyYear, nyMonth, nyDay, 16, 0)

if showNYVerticalLines and newNYDay
    line.new(
         x1 = nyOpenTime,
         y1 = low,
         x2 = nyOpenTime,
         y2 = high,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = nyOpenLineColor,
         style = line_style,
         width = nyLineWidth
     )

    line.new(
         x1 = nyCloseTime,
         y1 = low,
         x2 = nyCloseTime,
         y2 = high,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = nyCloseLineColor,
         style = line_style,
         width = nyLineWidth
     )

// === PROJECT NEXT-DAY NY 09:30 AND 16:00 LINES ===
var line nextDayOpenLine  = na
var line nextDayCloseLine = na

int nyDOW = dayofweek(time, "America/New_York")

int daysToAdd =
     skipWeekendsForNextDay and nyDOW == dayofweek.friday   ? 3 :
     skipWeekendsForNextDay and nyDOW == dayofweek.saturday ? 2 :
     1

int nextNYOpenTime  = timestamp("America/New_York", nyYear, nyMonth, nyDay + daysToAdd, 9, 30)
int nextNYCloseTime = timestamp("America/New_York", nyYear, nyMonth, nyDay + daysToAdd, 16, 0)

if barstate.islast
    if not na(nextDayOpenLine)
        line.delete(nextDayOpenLine)

    if not na(nextDayCloseLine)
        line.delete(nextDayCloseLine)

    if showNYVerticalLines and showNextDayNYLines
        nextDayOpenLine := line.new(
             x1 = nextNYOpenTime,
             y1 = low,
             x2 = nextNYOpenTime,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = nyNextDayOpenLineColor,
             style = line_style,
             width = nyLineWidth
         )

        nextDayCloseLine := line.new(
             x1 = nextNYCloseTime,
             y1 = low,
             x2 = nextNYCloseTime,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = nyNextDayCloseLineColor,
             style = line_style,
             width = nyLineWidth
         )
````
