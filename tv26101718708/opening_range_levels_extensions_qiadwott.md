# Opening Range Levels + Extensions

- url: https://www.tradingview.com/script/qIaDWotT-Opening-Range-Levels-Extensions/
- type: indicator
- pine_id: PUB;c09e14d0a9b24b5b83985552a35d72d6
- version: 1.0

## Description

Opening Range Levels marks the high, low and midpoint of a session's opening range and projects extension levels above and below it. It is a chart reference tool: it draws levels and can send alerts, and it does not place trades or tell you what to do.

HOW IT WORKS
The script watches the first minutes of the session you pick (15 minutes by default). While the range is forming, a shaded box grows with it. When the range is complete, the high, low and midpoint are drawn to the end of the session, and the extension levels appear at multiples of the range width.

SESSIONS
• New York: 09:30–16:00 ET
• London: 08:00–16:30 UK time
• Tokyo: 09:00–15:30 JST
• Custom: your own start, end and timezone. A custom session can cross midnight, and daylight saving time is handled automatically.

SETTINGS
• Opening range length: 5, 15, 30 or 60 minutes (default 15).
• History: show the last 1 to 20 sessions (default 3).
• Range lines: high, low and midpoint, each with its own color, width and line style (solid, dashed or dotted).
• Range box: shaded box with adjustable fill and border.
• Extensions: 4 levels above and 4 below, at multiples of the range width (default 0.5, 1, 1.5 and 2). Each can be turned on or off, with optional price labels.
• Breakout markers: shown on a confirmed bar close outside the range. Choose first break per side (default), every close-through, or off.
• Info table: range status (forming or complete), high, low, width in points and width as a percent of price. Pick any corner of the chart.

ALERTS (11)
• Close above the range high
• Close below the range low
• Touch of each extension level (8)
• Opening range complete
Alert messages include the ticker and the level price.

NOTES
• Use it on an intraday, time-based chart. The chart timeframe must be no longer than the range length and must divide it evenly (for example, 1, 3, 5 or 15 minutes for a 15-minute range).
• Everything is calculated on confirmed bar closes, so levels and markers do not repaint.
• No bars are invented: weekends, holidays or gaps with no data draw nothing.
• This is not a strategy and it gives no signals beyond the breakout marker. It is for study and chart reference only. Past price behavior at these levels says nothing about future results.

## Source Code

````pine
//@version=6
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shofury
indicator("Opening Range Levels + Extensions", shorttitle = "ORL+X", overlay = true, max_lines_count = 220, max_labels_count = 500, max_boxes_count = 20)

// Public opening-range arithmetic only. All prices use confirmed chart bars.
string preset = input.string("New York", "Session preset", options = ["New York", "London", "Tokyo", "Custom"], group = "Session", tooltip = "Choose the session's local opening and closing times.")
int customStartHour = input.int(9, "Custom start hour", minval = 0, maxval = 23, group = "Session", inline = "start", tooltip = "Start hour in the custom timezone, using a 24-hour clock.")
int customStartMinute = input.int(30, "Minute", minval = 0, maxval = 59, group = "Session", inline = "start", tooltip = "Start minute in the custom timezone.")
int customEndHour = input.int(16, "Custom end hour", minval = 0, maxval = 23, group = "Session", inline = "end", tooltip = "An end at or before the start means the next calendar day.")
int customEndMinute = input.int(0, "Minute", minval = 0, maxval = 59, group = "Session", inline = "end", tooltip = "End minute in the custom timezone.")
string customTimezone = input.string("America/New_York", "Custom timezone", group = "Session", tooltip = "Use a valid IANA timezone, such as America/New_York, for automatic DST handling.")
int rangeMinutes = input.int(15, "Opening range length (minutes)", options = [5, 15, 30, 60], group = "Session", tooltip = "Measure bars opening within the first N minutes.")
int keepSessions = input.int(3, "Show last N sessions", minval = 1, maxval = 20, group = "Session", tooltip = "Keep this many sessions with observed opening-range bars.")

bool showHigh = input.bool(true, "Show high", group = "Range high", tooltip = "Draw the opening-range high through session end.")
color highColor = input.color(color.teal, "Color", group = "Range high", tooltip = "High line color.")
int highWidth = input.int(2, "Width", minval = 1, maxval = 4, group = "Range high", tooltip = "High line width in pixels.")
string highStyle = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Range high", tooltip = "High line style.")
bool showLow = input.bool(true, "Show low", group = "Range low", tooltip = "Draw the opening-range low through session end.")
color lowColor = input.color(color.orange, "Color", group = "Range low", tooltip = "Low line color.")
int lowWidth = input.int(2, "Width", minval = 1, maxval = 4, group = "Range low", tooltip = "Low line width in pixels.")
string lowStyle = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Range low", tooltip = "Low line style.")
bool showMid = input.bool(true, "Show midpoint", group = "Midpoint", tooltip = "Draw halfway between the opening-range high and low.")
color midColor = input.color(color.gray, "Color", group = "Midpoint", tooltip = "Midpoint line color.")
int midWidth = input.int(1, "Width", minval = 1, maxval = 4, group = "Midpoint", tooltip = "Midpoint line width in pixels.")
string midStyle = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Midpoint", tooltip = "Midpoint line style.")
bool showBox = input.bool(true, "Show shaded range box", group = "Range box", tooltip = "Grow a box as range bars close; keep the completed box.")
color boxFill = input.color(color.new(color.teal, 90), "Fill", group = "Range box", tooltip = "Range box shading and transparency.")
color boxBorder = input.color(color.new(color.teal, 40), "Border", group = "Range box", tooltip = "Range box border color.")
int boxWidth = input.int(1, "Border width", minval = 1, maxval = 4, group = "Range box", tooltip = "Range box border width in pixels.")
string boxStyle = input.string("Solid", "Border style", options = ["Solid", "Dashed", "Dotted"], group = "Range box", tooltip = "Range box border style.")

bool extension1 = input.bool(true, "Enabled", group = "Extension 1", tooltip = "Project this multiple above the high and below the low.")
float multiple1 = input.float(0.5, "Range multiple", minval = 0.0, step = 0.1, group = "Extension 1", tooltip = "Distance from the range edge, in range widths.")
color extensionColor1 = input.color(color.blue, "Color", group = "Extension 1", tooltip = "Color of both extension lines.")
int extensionWidth1 = input.int(1, "Width", minval = 1, maxval = 4, group = "Extension 1", tooltip = "Extension line width in pixels.")
string extensionStyle1 = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Extension 1", tooltip = "Extension line style.")
bool extension2 = input.bool(true, "Enabled", group = "Extension 2", tooltip = "Project this multiple above the high and below the low.")
float multiple2 = input.float(1.0, "Range multiple", minval = 0.0, step = 0.1, group = "Extension 2", tooltip = "Distance from the range edge, in range widths.")
color extensionColor2 = input.color(color.purple, "Color", group = "Extension 2", tooltip = "Color of both extension lines.")
int extensionWidth2 = input.int(1, "Width", minval = 1, maxval = 4, group = "Extension 2", tooltip = "Extension line width in pixels.")
string extensionStyle2 = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Extension 2", tooltip = "Extension line style.")
bool extension3 = input.bool(true, "Enabled", group = "Extension 3", tooltip = "Project this multiple above the high and below the low.")
float multiple3 = input.float(1.5, "Range multiple", minval = 0.0, step = 0.1, group = "Extension 3", tooltip = "Distance from the range edge, in range widths.")
color extensionColor3 = input.color(color.fuchsia, "Color", group = "Extension 3", tooltip = "Color of both extension lines.")
int extensionWidth3 = input.int(1, "Width", minval = 1, maxval = 4, group = "Extension 3", tooltip = "Extension line width in pixels.")
string extensionStyle3 = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Extension 3", tooltip = "Extension line style.")
bool extension4 = input.bool(true, "Enabled", group = "Extension 4", tooltip = "Project this multiple above the high and below the low.")
float multiple4 = input.float(2.0, "Range multiple", minval = 0.0, step = 0.1, group = "Extension 4", tooltip = "Distance from the range edge, in range widths.")
color extensionColor4 = input.color(color.red, "Color", group = "Extension 4", tooltip = "Color of both extension lines.")
int extensionWidth4 = input.int(1, "Width", minval = 1, maxval = 4, group = "Extension 4", tooltip = "Extension line width in pixels.")
string extensionStyle4 = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = "Extension 4", tooltip = "Extension line style.")
bool showPrices = input.bool(true, "Price labels at extension ends", group = "Extension labels", tooltip = "Show extension prices at the session-end timestamps.")
color priceTextColor = input.color(color.white, "Text color", group = "Extension labels", tooltip = "Extension price text color; label backgrounds match their lines.")

string markerMode = input.string("First break per side", "Breakout markers", options = ["First break per side", "Every close-through", "Off"], group = "Breakouts", tooltip = "First close outside per side, every crossing close, or no markers. Alerts remain available.")
color upColor = input.color(color.lime, "Up marker color", group = "Breakouts", tooltip = "Small upward marker below a confirmed breakout bar.")
color downColor = input.color(color.red, "Down marker color", group = "Breakouts", tooltip = "Small downward marker above a confirmed breakout bar.")
bool showInfo = input.bool(true, "Show info table", group = "Info table", tooltip = "Show the current day's range, or the active overnight session's range.")
string tableCorner = input.string("Top right", "Corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = "Info table", tooltip = "Place the info table and any configuration message.")
color tableText = input.color(color.white, "Text color", group = "Info table", tooltip = "Info table text color.")
color tableBackground = input.color(color.new(color.black, 15), "Background", group = "Info table", tooltip = "Info table background color.")
color tableBorder = input.color(color.gray, "Border color", group = "Info table", tooltip = "Info table border and cell frame color.")
int tableWidth = input.int(1, "Border width", minval = 0, maxval = 4, group = "Info table", tooltip = "Info table border width in pixels.")

f_style(string selection) =>
    switch selection
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

string sessionTimezone = switch preset
    "New York" => "America/New_York"
    "London" => "Europe/London"
    "Tokyo" => "Asia/Tokyo"
    => customTimezone
int startHour = preset == "New York" ? 9 : preset == "London" ? 8 : preset == "Tokyo" ? 9 : customStartHour
int startMinute = preset == "New York" ? 30 : preset == "Custom" ? customStartMinute : 0
int endHour = preset == "New York" or preset == "London" ? 16 : preset == "Tokyo" ? 15 : customEndHour
int endMinute = preset == "London" or preset == "Tokyo" ? 30 : preset == "Custom" ? customEndMinute : 0
int startMinuteOfDay = startHour * 60 + startMinute
int endMinuteOfDay = endHour * 60 + endMinute
bool overnight = endMinuteOfDay <= startMinuteOfDay
string sessionString = str.tostring(startHour, "00") + str.tostring(startMinute, "00") + "-" + str.tostring(endHour, "00") + str.tostring(endMinute, "00") + ":1234567"

// Calendar arithmetic in the selected timezone handles overnight sessions and DST.
int localYear = year(time, sessionTimezone)
int localMonth = month(time, sessionTimezone)
int localDay = dayofmonth(time, sessionTimezone)
int localMinuteOfDay = hour(time, sessionTimezone) * 60 + minute(time, sessionTimezone)
int anchorDay = localDay - (localMinuteOfDay < startMinuteOfDay ? 1 : 0)
int sessionStart = timestamp(sessionTimezone, localYear, localMonth, anchorDay, startHour, startMinute)
int sessionEnd = timestamp(sessionTimezone, localYear, localMonth, anchorDay + (overnight ? 1 : 0), endHour, endMinute)
int rangeEnd = sessionStart + rangeMinutes * 60 * 1000
float chartSeconds = timeframe.in_seconds()
bool timeframeOK = timeframe.isintraday and chartSeconds > 0 and chartSeconds <= rangeMinutes * 60 and (rangeMinutes * 60) % chartSeconds == 0
bool sessionOK = rangeEnd <= sessionEnd
bool usable = timeframeOK and sessionOK
bool inSession = usable and not na(time(timeframe.period, sessionString, sessionTimezone)) and time >= sessionStart and time < sessionEnd
bool inRange = inSession and time < rangeEnd

// Slots: high, low, midpoint, then upper/lower pairs for each extension.
var array<bool> enabled = array.from(showHigh, showLow, showMid, extension1, extension1, extension2, extension2, extension3, extension3, extension4, extension4)
var array<color> levelColors = array.from(highColor, lowColor, midColor, extensionColor1, extensionColor1, extensionColor2, extensionColor2, extensionColor3, extensionColor3, extensionColor4, extensionColor4)
var array<int> levelWidths = array.from(highWidth, lowWidth, midWidth, extensionWidth1, extensionWidth1, extensionWidth2, extensionWidth2, extensionWidth3, extensionWidth3, extensionWidth4, extensionWidth4)
var array<string> levelStyles = array.from(highStyle, lowStyle, midStyle, extensionStyle1, extensionStyle1, extensionStyle2, extensionStyle2, extensionStyle3, extensionStyle3, extensionStyle4, extensionStyle4)
var array<float> multiples = array.from(multiple1, multiple2, multiple3, multiple4)

type SessionDrawing
    int startTime
    int endTime
    array<line> levels
    array<label> prices
    box rangeBox

f_deleteSession(SessionDrawing drawing) =>
    for level in drawing.levels
        if not na(level)
            line.delete(level)
    for priceLabel in drawing.prices
        if not na(priceLabel)
            label.delete(priceLabel)
    if not na(drawing.rangeBox)
        box.delete(drawing.rangeBox)
    0

f_updateSession(SessionDrawing drawing, float rangeHigh, float rangeLow, int boxRight, int extensionStart, bool complete) =>
    float width = rangeHigh - rangeLow
    for slot = 0 to 10
        if array.get(enabled, slot) and (slot < 3 or complete)
            float levelPrice = slot == 0 ? rangeHigh : slot == 1 ? rangeLow : (rangeHigh + rangeLow) / 2
            if slot >= 3
                int multipleIndex = int((slot - 3) / 2)
                float distance = array.get(multiples, multipleIndex) * width
                levelPrice := (slot - 3) % 2 == 0 ? rangeHigh + distance : rangeLow - distance
            line level = array.get(drawing.levels, slot)
            if na(level)
                int leftTime = slot < 3 ? drawing.startTime : extensionStart
                level := line.new(leftTime, levelPrice, drawing.endTime, levelPrice, xloc = xloc.bar_time, extend = extend.none, color = array.get(levelColors, slot), style = f_style(array.get(levelStyles, slot)), width = array.get(levelWidths, slot))
                array.set(drawing.levels, slot, level)
            else
                line.set_y1(level, levelPrice)
                line.set_y2(level, levelPrice)
            if slot >= 3 and showPrices
                label priceLabel = array.get(drawing.prices, slot)
                if na(priceLabel)
                    priceLabel := label.new(drawing.endTime, levelPrice, str.tostring(levelPrice, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = array.get(levelColors, slot), textcolor = priceTextColor, size = size.tiny)
                    array.set(drawing.prices, slot, priceLabel)
    if not na(drawing.rangeBox)
        box.set_top(drawing.rangeBox, rangeHigh)
        box.set_bottom(drawing.rangeBox, rangeLow)
        box.set_right(drawing.rangeBox, boxRight)
    drawing

var array<SessionDrawing> sessions = array.new<SessionDrawing>()
var array<label> markerLabels = array.new<label>()
var array<int> markerSessions = array.new<int>()

f_removeOldMarkers(int expiredStart) =>
    while array.size(markerSessions) > 0 and array.get(markerSessions, 0) <= expiredStart
        label.delete(array.shift(markerLabels))
        array.shift(markerSessions)
    0

f_addMarker(bool upward, int activeStart) =>
    // Reserve 160 labels for 8 extension prices across 20 sessions.
    // Delete before creating so TradingView's automatic label collector never runs.
    if array.size(markerLabels) >= 340
        label.delete(array.shift(markerLabels))
        array.shift(markerSessions)
    label marker = label.new(time, upward ? low : high, "", xloc = xloc.bar_time, yloc = upward ? yloc.belowbar : yloc.abovebar, style = upward ? label.style_triangleup : label.style_triangledown, color = upward ? upColor : downColor, size = size.tiny)
    array.push(markerLabels, marker)
    array.push(markerSessions, activeStart)
    0

var int activeStart = na
var int activeEnd = na
var int activeRangeEnd = na
var int boxRight = na
var float rangeHigh = na
var float rangeLow = na
var bool complete = false
var bool brokeHigh = false
var bool brokeLow = false
var float confirmedPrice = na
var SessionDrawing currentDrawing = na
bool rangeCompleteEvent = false
float completedHigh = na
float completedLow = na

if barstate.isconfirmed
    confirmedPrice := close

if usable
    // Finalize before changing sessions, even if the next chart bar follows a gap.
    // Snapshot alert prices before a new session can reset the active range.
    if not na(activeStart) and not complete and not na(rangeHigh) and time >= activeRangeEnd
        complete := true
        f_updateSession(currentDrawing, rangeHigh, rangeLow, boxRight, activeRangeEnd, true)
        rangeCompleteEvent := barstate.isconfirmed
        completedHigh := rangeHigh
        completedLow := rangeLow

    if inSession and (na(activeStart) or sessionStart != activeStart)
        activeStart := sessionStart
        activeEnd := sessionEnd
        activeRangeEnd := rangeEnd
        boxRight := na
        rangeHigh := na
        rangeLow := na
        complete := false
        brokeHigh := false
        brokeLow := false
        currentDrawing := na

    // No unconfirmed high/low is accumulated. No varip state is needed.
    if inRange and barstate.isconfirmed
        rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
        rangeLow := na(rangeLow) ? low : math.min(rangeLow, low)
        boxRight := math.min(time_close, activeRangeEnd)
        if na(currentDrawing)
            // Free the expired session before allocating the next one's objects.
            while array.size(sessions) >= keepSessions
                SessionDrawing expired = array.shift(sessions)
                f_deleteSession(expired)
                f_removeOldMarkers(expired.startTime)
            box formingBox = na
            if showBox
                formingBox := box.new(activeStart, rangeHigh, boxRight, rangeLow, xloc = xloc.bar_time, border_color = boxBorder, border_width = boxWidth, border_style = f_style(boxStyle), bgcolor = boxFill)
            currentDrawing := SessionDrawing.new(activeStart, activeEnd, array.new<line>(11, na), array.new<label>(11, na), formingBox)
            array.push(sessions, currentDrawing)
        f_updateSession(currentDrawing, rangeHigh, rangeLow, boxRight, activeRangeEnd, false)

// The first post-range close may already be outside (including a gap).
// Later close-throughs require the previous close to be on the other side.
bool signalBar = usable and inSession and activeStart == sessionStart and complete and barstate.isconfirmed and time_close <= activeEnd
bool closeAbove = signalBar and close > rangeHigh and (not complete[1] or activeStart != activeStart[1] or close[1] <= rangeHigh)
bool closeBelow = signalBar and close < rangeLow and (not complete[1] or activeStart != activeStart[1] or close[1] >= rangeLow)
bool firstAbove = signalBar and close > rangeHigh and not brokeHigh
bool firstBelow = signalBar and close < rangeLow and not brokeLow
bool markAbove = markerMode == "First break per side" ? firstAbove : markerMode == "Every close-through" and closeAbove
bool markBelow = markerMode == "First break per side" ? firstBelow : markerMode == "Every close-through" and closeBelow
if markAbove
    f_addMarker(true, activeStart)
if markBelow
    f_addMarker(false, activeStart)
if signalBar
    brokeHigh := brokeHigh or close > rangeHigh
    brokeLow := brokeLow or close < rangeLow

float rangeWidth = rangeHigh - rangeLow
float upper1 = rangeHigh + rangeWidth * multiple1
float lower1 = rangeLow - rangeWidth * multiple1
float upper2 = rangeHigh + rangeWidth * multiple2
float lower2 = rangeLow - rangeWidth * multiple2
float upper3 = rangeHigh + rangeWidth * multiple3
float lower3 = rangeLow - rangeWidth * multiple3
float upper4 = rangeHigh + rangeWidth * multiple4
float lower4 = rangeLow - rangeWidth * multiple4

// Hidden plots supply exact dynamic prices to constant alertcondition messages.
plot(rangeCompleteEvent ? completedHigh : signalBar ? rangeHigh : na, title = "Range high price", display = display.none)
plot(rangeCompleteEvent ? completedLow : signalBar ? rangeLow : na, title = "Range low price", display = display.none)
plot(signalBar ? upper1 : na, title = "Extension 1 high price", display = display.none)
plot(signalBar ? lower1 : na, title = "Extension 1 low price", display = display.none)
plot(signalBar ? upper2 : na, title = "Extension 2 high price", display = display.none)
plot(signalBar ? lower2 : na, title = "Extension 2 low price", display = display.none)
plot(signalBar ? upper3 : na, title = "Extension 3 high price", display = display.none)
plot(signalBar ? lower3 : na, title = "Extension 3 low price", display = display.none)
plot(signalBar ? upper4 : na, title = "Extension 4 high price", display = display.none)
plot(signalBar ? lower4 : na, title = "Extension 4 low price", display = display.none)

alertcondition(closeAbove, "Close above range high", '{{ticker}} closed above range high {{plot("Range high price")}}.')
alertcondition(closeBelow, "Close below range low", '{{ticker}} closed below range low {{plot("Range low price")}}.')
alertcondition(signalBar and extension1 and low <= upper1 and high >= upper1, "Touch extension 1 high", '{{ticker}} touched upper extension 1 at {{plot("Extension 1 high price")}}.')
alertcondition(signalBar and extension1 and low <= lower1 and high >= lower1, "Touch extension 1 low", '{{ticker}} touched lower extension 1 at {{plot("Extension 1 low price")}}.')
alertcondition(signalBar and extension2 and low <= upper2 and high >= upper2, "Touch extension 2 high", '{{ticker}} touched upper extension 2 at {{plot("Extension 2 high price")}}.')
alertcondition(signalBar and extension2 and low <= lower2 and high >= lower2, "Touch extension 2 low", '{{ticker}} touched lower extension 2 at {{plot("Extension 2 low price")}}.')
alertcondition(signalBar and extension3 and low <= upper3 and high >= upper3, "Touch extension 3 high", '{{ticker}} touched upper extension 3 at {{plot("Extension 3 high price")}}.')
alertcondition(signalBar and extension3 and low <= lower3 and high >= lower3, "Touch extension 3 low", '{{ticker}} touched lower extension 3 at {{plot("Extension 3 low price")}}.')
alertcondition(signalBar and extension4 and low <= upper4 and high >= upper4, "Touch extension 4 high", '{{ticker}} touched upper extension 4 at {{plot("Extension 4 high price")}}.')
alertcondition(signalBar and extension4 and low <= lower4 and high >= lower4, "Touch extension 4 low", '{{ticker}} touched lower extension 4 at {{plot("Extension 4 low price")}}.')
alertcondition(rangeCompleteEvent, "Range complete", '{{ticker}} opening range complete: high {{plot("Range high price")}}, low {{plot("Range low price")}}.')

string tablePosition = switch tableCorner
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
var table info = table.new(tablePosition, 2, 5, bgcolor = tableBackground, frame_color = tableBorder, frame_width = tableWidth, border_color = tableBorder, border_width = tableWidth)
if barstate.islast
    table.clear(info, 0, 0, 1, 4)
    if not timeframeOK
        table.cell(info, 0, 0, "Use an intraday timeframe ≤ the range length", text_color = tableText, bgcolor = tableBackground)
    else if not sessionOK
        table.cell(info, 0, 0, "Session must be at least as long as the range", text_color = tableText, bgcolor = tableBackground)
    else if showInfo
        bool sameCalendarDay = not na(activeStart) and year(activeStart, sessionTimezone) == localYear and month(activeStart, sessionTimezone) == localMonth and dayofmonth(activeStart, sessionTimezone) == localDay
        bool currentRange = not na(rangeHigh) and (sameCalendarDay or (inSession and activeStart == sessionStart))
        string status = not currentRange ? "Waiting" : complete ? "Complete" : "Forming"
        float percent = currentRange and not na(confirmedPrice) and confirmedPrice != 0 ? rangeWidth / math.abs(confirmedPrice) * 100 : na
        table.cell(info, 0, 0, "Opening range", text_color = tableText)
        table.cell(info, 1, 0, status, text_color = tableText)
        table.cell(info, 0, 1, "High", text_color = tableText)
        table.cell(info, 1, 1, currentRange ? str.tostring(rangeHigh, format.mintick) : "—", text_color = tableText)
        table.cell(info, 0, 2, "Low", text_color = tableText)
        table.cell(info, 1, 2, currentRange ? str.tostring(rangeLow, format.mintick) : "—", text_color = tableText)
        table.cell(info, 0, 3, "Width (points)", text_color = tableText)
        table.cell(info, 1, 3, currentRange ? str.tostring(rangeWidth, format.mintick) : "—", text_color = tableText)
        table.cell(info, 0, 4, "Width / price", text_color = tableText)
        table.cell(info, 1, 4, not na(percent) ? str.tostring(percent, "0.00") + "%" : "—", text_color = tableText)
````
