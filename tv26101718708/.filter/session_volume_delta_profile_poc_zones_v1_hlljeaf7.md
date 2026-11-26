# Session Volume + Delta Profile | POC Zones v1

- url: https://www.tradingview.com/script/HLLJEAf7-Session-Volume-Delta-Profile-POC-Zones-v1/
- type: indicator
- pine_id: PUB;3862cc4c3f0746f4bf163476686bd17c
- version: 2.0

## Description

Session Volume + Delta Profile | POC Zones

A TradingView Premium or Ultimate subscription is required because this indicator uses TradingView’s footprint data. Real-time exchange data may require separate market-data access, depending on the symbol and your account.

Session Volume + Delta Profile combines total volume and net delta at matching price levels within a selected trading session. It helps you compare where activity accumulated with the directional balance of that activity, while keeping the session’s highest-volume area visible as a POC zone or line.

The chart displays:

Volume profile: Total session volume in each price row. Longer bars represent more volume. The value area uses a separate highlight color.
Delta profile: TradingView’s buy-classified volume minus sell-classified volume in each row. Green indicates positive delta; red indicates negative delta. Both colors appear on the delta side.
POC — Point of Control: The row with the highest total volume, displayed as a shaded zone or a line through its center. The POC is determined by total volume, not by the largest delta.
VAH and VAL: Optional lines marking the upper and lower boundaries of the value area. Its default target is 70% of session volume.
Session summary: Total volume, net delta, POC price, extended POC count, and developing/completed or incomplete-data status.

The default Shared divider at right layout places delta to the left of one divider and volume to its right, away from the candles. Increase Shared divider: gap after price (bars) to move the pair farther right. Each profile scales its bar widths independently, so matching widths across the two sides do not represent equal amounts.

The alternative Session edges layout places the profiles within their original sessions and can display one to three full session profiles. Shared-divider mode displays the latest full profile; historical POC extensions remain available separately.

For the POC zone, choose:

POC row: Use the complete price range of the highest-volume row.
Custom ticks: Use a centered band with an adjustable total width.

The developing POC can move as new volume arrives. Once a session finishes, its final POC boundaries are retained for the current calculation. Developing POCs are yellow and completed POCs are orange by default; all colors are adjustable.

Enable Extend previous days’ POC zones right to retain levels from one to 30 completed trading sessions. The default is five. A completed latest session counts toward that limit; weekends and days without a session do not. Older extensions disappear as new sessions replace them. Retained POCs remain visible after price trades through them.

To get started:

Choose a standard intraday chart. A 1-minute or 5-minute chart is a practical starting point. Select a timeframe whose candles align with your chosen session’s opening and closing times.
Set the session and time zone. The default is 09:30–16:00 in America/New_York. Custom overnight sessions are supported. Exchange trading day mode uses the exchange session available on your chart. Ensure the chart includes the hours you want to analyze.
Adjust the display. Set the gap, width, target row count, colors, and optional row numbers. If the profiles are outside the visible chart, leave more space to the right of price.
Choose your POC presentation and history. Select zone or line, choose the zone width, and set how many completed sessions to extend.
Study price reactions at the reference areas. On a POC revisit, observe whether price holds, rejects, crosses, or reclaims the zone. Compare the delta at that price with nearby rows, then use your usual candle-close and market-structure confirmation.
Check the summary before interpreting a level. Incomplete sessions are excluded from extended historical POCs by default. Allowing them can show additional levels, marked with an asterisk.

The starting settings are:

Setting	Default
Session	Custom, 09:30–16:00 America/New_York
Placement	Shared divider at right
Gap after price	20 bars; adjustable from 0–250
Width per side	35 bars
Target price rows	50
Value area target	70%
POC display	Zone using the POC row
Previous sessions extended	5
Incomplete historical extensions	Excluded
Row numbers	Off

TradingView classifies footprint volume using intrabar price movement. Delta should therefore be understood as directional volume classification rather than direct exchange bid/ask aggressor data.

Changing the chart timeframe, session, or row settings can change the profiles and POC. Historical values can also recalculate when the source data changes. This custom calculation is not guaranteed to match TradingView’s built-in Session Volume Profile exactly.

Use the indicator as context alongside your trading method and risk plan. POC touches and delta colors do not, by themselves, confirm a reversal or continuation. This version provides visual analysis without automated entry signals, trade execution, or built-in alerts.

## Source Code

````pine
//@version=6
indicator("Session Volume + Delta Profile | POC Zones v1.3", shorttitle = "SVP+Delta", overlay = true, max_boxes_count = 500, max_lines_count = 150, max_labels_count = 100)

// Requires TradingView Premium or Ultimate for request.footprint().
// TradingView footprint buy/sell classification uses intrabar price direction;
// these values are not direct exchange bid/ask aggressor measurements.
// One footprint request supplies BOTH sides of every session profile.
// Source rows are requested at one tick, then grouped into session price rows.
// A developing session can change its row boundaries and POC as its range grows.
// Completed sessions retain their final grouped rows and final POC boundaries.
// Native data can change after a reload; an exact match to built-in SVP is not promised.
// Use a standard intraday chart. Align custom session boundaries to chart bars.
// Default: New York 09:30-16:00; shared divider at right with a 20-bar gap.
// Volume side is selectable; delta always uses the opposite side.
// Every volume / delta pair stays back to back on one common divider.
// Previous pairs sit together near the selected edge of their own session.
// Previous-session edge and volume side are independent left / right settings.
// Display rows may be merged to fit the drawing budget; POC / VA stay unchanged.
// History count means completed trading sessions, not elapsed calendar days.
// Turning history extension OFF leaves POCs inside the displayed sessions only.

const string G_SESSION = "1. Session"
const string G_PROFILE = "2. Volume and delta profiles"
const string G_POC = "3. POC line / zone"
const string G_HISTORY = "4. Previous-day POC zones"
const string G_STYLE = "5. Colors and labels"
const string G_DATA = "6. Data and display"
const int MAX_SOURCE_ROWS = 30000
const int PROFILE_BOX_BUDGET = 469 // 500 boxes minus up to 31 POC zones.

string sessionMode = input.string("Custom session", "Session basis", options = ["Custom session", "Exchange trading day"], group = G_SESSION, tooltip = "Custom session uses the hours and time zone below. Exchange trading day uses all bars available in the chart's selected exchange session, including extended hours when enabled.")
string sessionHours = input.session("0930-1600", "Custom session hours", group = G_SESSION, tooltip = "Overnight sessions are supported, for example 1800-1700 for a futures session. Use chart bars that align with the selected opening and closing times.")
string timezoneChoice = input.string("America/New_York", "Custom session time zone", options = ["America/New_York", "America/Chicago", "Europe/London", "Etc/UTC", "Exchange"], group = G_SESSION)
string sessionDays = input.string("All days", "Custom session days", options = ["All days", "Weekdays"], group = G_SESSION, tooltip = "All days allows Sunday evening futures sessions. Empty market days do not consume the POC history count.")

bool showVolume = input.bool(true, "Show volume profile", group = G_PROFILE)
bool showDelta = input.bool(true, "Show delta profile", group = G_PROFILE)
string volumeSide = input.string("Right", "Volume profile side", options = ["Left", "Right"], group = G_PROFILE, tooltip = "Volume uses the selected side of one common divider, and delta uses the opposite side. They stay back to back for every session. Previous sessions: edge separately controls where historical pairs sit within their sessions.")
int rowsRequested = input.int(50, "Target price rows per session", minval = 10, maxval = 70, group = G_PROFILE, tooltip = "Rows have a whole-tick height. The actual count can be lower than this target. With many full profiles visible, adjacent histogram rows are merged for display to fit TradingView's drawing limit. Calculated POC and value area boundaries remain unchanged.")
string placement = input.string("Shared divider at right", "Profile placement", options = ["Session edges", "Shared divider at right"], group = G_PROFILE, tooltip = "Session edges draws the latest back-to-back pair inside its session. Shared divider moves the latest pair after price. Previous pairs use the Previous sessions: edge setting in both layouts.")
string previousSessionEdge = input.string("Right", "Previous sessions: edge", options = ["Left", "Right"], group = G_PROFILE, tooltip = "For previous sessions only: Left places the entire joined pair near the beginning of each session; Right places it near the end. Applies in both layouts when previous full profiles are shown. Volume profile side independently chooses which half is volume and which half is delta.")
string profileHistory = input.string("Current session only", "Profiles to display", options = ["Current session only", "Current + previous sessions"], group = G_PROFILE, tooltip = "Current means the latest available trading session, including after its close. Previous sessions' full volume and delta profiles are independent of extended POC zones.")
int previousProfileDays = input.int(5, "Previous sessions with full profiles", minval = 1, maxval = 30, group = G_PROFILE, tooltip = "Adds this many previous trading sessions to the current session when Current + previous sessions is selected. Empty market days do not consume this count; sessions without usable footprint data cannot draw a profile. More visible profiles can reduce histogram row detail.")
int sessionWidthPercent = input.int(30, "Profile width (% of session)", minval = 5, maxval = 45, group = G_PROFILE, tooltip = "Maximum width per side for pairs drawn inside their sessions. A pair can occupy twice this percentage. Both sides share the same divider and remain inside the session.")
int dividerWidthBars = input.int(35, "Shared divider: width per side (bars)", minval = 5, maxval = 120, group = G_PROFILE)
// Maximum gap plus both maximum profile widths stays below 500 future bars.
int dividerGapBars = input.int(20, "Shared divider: gap after price (bars)", minval = 0, maxval = 250, group = G_PROFILE, tooltip = "Distance from the latest candle to the left edge of the paired profiles. Increase this value to move both profiles farther right. The divider, row values, titles, and value area lines move together.")
bool showValueArea = input.bool(true, "Show value area high / low", group = G_PROFILE)
int valueAreaPercent = input.int(70, "Value area (%)", minval = 1, maxval = 100, group = G_PROFILE)
bool showRowValues = input.bool(false, "Show volume / delta numbers in rows", group = G_PROFILE)

bool showPoc = input.bool(true, "Show POC", group = G_POC)
string pocStyle = input.string("Zone", "POC display", options = ["Zone", "Line"], group = G_POC)
string pocWidthMode = input.string("POC row", "Zone width basis", options = ["POC row", "Custom ticks"], group = G_POC, tooltip = "POC row uses the full highest-volume price row. Custom ticks creates a centered band with the total width selected below.")
int customPocTicks = input.int(8, "Custom zone total width (ticks)", minval = 1, maxval = 10000, group = G_POC)
bool extendDevelopingPoc = input.bool(true, "Extend developing session POC right", group = G_POC)
int pocTransparency = input.int(85, "Zone transparency", minval = 0, maxval = 100, group = G_POC)
int pocBorderWidth = input.int(1, "Zone border width", minval = 0, maxval = 4, group = G_POC)
int pocLineWidth = input.int(2, "POC line width", minval = 1, maxval = 5, group = G_POC)

bool extendPreviousPoc = input.bool(true, "Extend previous days' POC zones right", group = G_HISTORY)
int previousDays = input.int(5, "Previous days to extend", minval = 1, maxval = 30, group = G_HISTORY, tooltip = "Keeps this many most recent completed trading sessions extended right. A completed latest session counts toward this limit. Weekends and days without a session do not consume it. Older extensions disappear automatically.")
bool allowPartialHistory = input.bool(false, "Allow incomplete sessions in POC history", group = G_HISTORY, tooltip = "OFF skips extended historical POCs from sessions with missing footprint data, a partial starting session, or bars that cross custom session boundaries. ON includes them, with a * in their labels.")
bool showPocLabels = input.bool(true, "Show dated POC labels", group = G_HISTORY)

color volumeColor = input.color(color.rgb(64, 132, 224), "Volume", group = G_STYLE)
color valueAreaColor = input.color(color.rgb(90, 175, 250), "Volume inside value area", group = G_STYLE)
color positiveDeltaColor = input.color(color.rgb(30, 185, 130), "Positive delta", group = G_STYLE)
color negativeDeltaColor = input.color(color.rgb(228, 75, 95), "Negative delta", group = G_STYLE)
color developingPocColor = input.color(color.rgb(255, 207, 70), "Developing POC", group = G_STYLE)
color historicalPocColor = input.color(color.rgb(245, 154, 65), "Completed POC", group = G_STYLE)
color valueAreaLineColor = input.color(color.rgb(150, 155, 170), "Value area lines", group = G_STYLE)
int profileTransparency = input.int(25, "Profile transparency", minval = 0, maxval = 100, group = G_STYLE)
bool showProfileTitles = input.bool(true, "Show profile titles", group = G_STYLE)
bool showSummary = input.bool(true, "Show session summary", group = G_DATA)

// Finished profile arrays are independent snapshots; no raw footprint objects
// are retained in history, and no live session can mutate a saved profile.
type SessionProfile
    int key
    int startTime
    int endTime
    float lowerPrice
    float rowHeight
    array<float> buys
    array<float> sells
    int pocIndex
    int valIndex
    int vahIndex
    float totalBuy
    float totalSell
    bool completeData
    bool ended
    string dateText

f_buildProfile(map<int, float> buyMap, map<int, float> sellMap, int firstTick, int lastTick, int key, int leftTime, int rightTime, bool completeData, bool ended, string dateText) =>
    // An empty record still consumes its actual trading-day position in history.
    // Missing-data days must not make an older POC look like yesterday's POC.
    SessionProfile result = SessionProfile.new(key, leftTime, rightTime, na, na, array.new<float>(), array.new<float>(), na, na, na, 0.0, 0.0, false, ended, dateText)
    if not na(firstTick) and not na(lastTick) and map.size(buyMap) > 0
        int span = lastTick - firstTick + 1
        int ticksPerRow = math.max(1, int(math.ceil(float(span) / rowsRequested)))
        int rowCount = math.max(1, int(math.ceil(float(span) / ticksPerRow)))
        array<float> buys = array.new<float>(rowCount, 0.0)
        array<float> sells = array.new<float>(rowCount, 0.0)
        array<int> keys = map.keys(buyMap)
        float totalBuy = 0.0
        float totalSell = 0.0
        for tickKey in keys
            int index = math.min(rowCount - 1, int(math.floor(float(tickKey - firstTick) / ticksPerRow)))
            float buyAmount = nz(map.get(buyMap, tickKey), 0.0)
            float sellAmount = nz(map.get(sellMap, tickKey), 0.0)
            array.set(buys, index, array.get(buys, index) + buyAmount)
            array.set(sells, index, array.get(sells, index) + sellAmount)
            totalBuy += buyAmount
            totalSell += sellAmount
        int pocIndex = 0
        float highestVolume = -1.0
        for index = 0 to rowCount - 1
            float rowVolume = array.get(buys, index) + array.get(sells, index)
            // Deterministic tie: choose the lower price row.
            if rowVolume > highestVolume
                highestVolume := rowVolume
                pocIndex := index
        int valIndex = pocIndex
        int vahIndex = pocIndex
        float areaVolume = highestVolume
        float targetVolume = (totalBuy + totalSell) * valueAreaPercent / 100.0
        while areaVolume < targetVolume and (valIndex > 0 or vahIndex < rowCount - 1)
            float aboveVolume = vahIndex < rowCount - 1 ? array.get(buys, vahIndex + 1) + array.get(sells, vahIndex + 1) : -1.0
            float belowVolume = valIndex > 0 ? array.get(buys, valIndex - 1) + array.get(sells, valIndex - 1) : -1.0
            if aboveVolume > belowVolume
                vahIndex += 1
                areaVolume += aboveVolume
            else
                valIndex -= 1
                areaVolume += belowVolume
        result := SessionProfile.new(key, leftTime, rightTime, firstTick * syminfo.mintick, ticksPerRow * syminfo.mintick, buys, sells, pocIndex, valIndex, vahIndex, totalBuy, totalSell, completeData, ended, dateText)
    result

f_pocBounds(SessionProfile profile) =>
    float rowBottom = profile.lowerPrice + profile.pocIndex * profile.rowHeight
    float rowTop = rowBottom + profile.rowHeight
    float center = math.avg(rowBottom, rowTop)
    float halfWidth = customPocTicks * syminfo.mintick / 2.0
    float bottom = pocWidthMode == "Custom ticks" ? center - halfWidth : rowBottom
    float top = pocWidthMode == "Custom ticks" ? center + halfWidth : rowTop
    [bottom, top, center]

f_clearDrawings(array<box> boxes, array<line> lines, array<label> labels) =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))
    true

f_drawPoc(SessionProfile profile, bool extendRight, color pocColor, array<box> boxes, array<line> lines, array<label> labels) =>
    [bottom, top, center] = f_pocBounds(profile)
    string extension = extendRight ? extend.right : extend.none
    if pocStyle == "Zone"
        box zone = box.new(left = profile.startTime, top = top, right = profile.endTime, bottom = bottom, xloc = xloc.bar_time, extend = extension, border_color = color.new(pocColor, 20), border_width = pocBorderWidth, bgcolor = color.new(pocColor, pocTransparency))
        array.push(boxes, zone)
    else
        line pocLine = line.new(x1 = profile.startTime, y1 = center, x2 = profile.endTime, y2 = center, xloc = xloc.bar_time, extend = extension, color = pocColor, width = pocLineWidth)
        array.push(lines, pocLine)
    if showPocLabels
        string labelText = profile.dateText + " POC" + (profile.completeData ? "" : " *")
        string tooltipText = "POC: " + str.tostring(center, format.mintick) + "\nZone: " + str.tostring(bottom, format.mintick) + " - " + str.tostring(top, format.mintick) + "\n" + (profile.ended ? "Completed session" : "Developing session") + (profile.completeData ? "" : "\nIncomplete source data or session coverage")
        if extendRight
            label pocLabel = label.new(x = bar_index + 2, y = center, text = labelText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocColor, 85), textcolor = pocColor, size = size.tiny, tooltip = tooltipText)
            array.push(labels, pocLabel)
        else
            label pocLabel = label.new(x = profile.endTime, y = center, text = labelText, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(pocColor, 85), textcolor = pocColor, size = size.tiny, tooltip = tooltipText)
            array.push(labels, pocLabel)
    true

f_drawProfile(SessionProfile profile, bool useDivider, bool pairOnLeftEdge, int maxDisplayRows, array<box> boxes, array<line> lines, array<label> labels) =>
    int sourceRowCount = array.size(profile.buys)
    // Merge only the displayed histograms. Saved price rows, POC bounds,
    // value area bounds, and session totals are never changed by visibility.
    int rowsPerGroup = math.max(1, int(math.ceil(float(sourceRowCount) / maxDisplayRows)))
    int rowCount = int(math.ceil(float(sourceRowCount) / rowsPerGroup))
    array<float> displayBuys = array.new<float>(rowCount, 0.0)
    array<float> displaySells = array.new<float>(rowCount, 0.0)
    for index = 0 to sourceRowCount - 1
        int groupIndex = int(math.floor(float(index) / rowsPerGroup))
        array.set(displayBuys, groupIndex, array.get(displayBuys, groupIndex) + array.get(profile.buys, index))
        array.set(displaySells, groupIndex, array.get(displaySells, groupIndex) + array.get(profile.sells, index))
    float maxVolume = 0.0
    float maxAbsDelta = 0.0
    for index = 0 to rowCount - 1
        float rowBuy = array.get(displayBuys, index)
        float rowSell = array.get(displaySells, index)
        maxVolume := math.max(maxVolume, rowBuy + rowSell)
        maxAbsDelta := math.max(maxAbsDelta, math.abs(rowBuy - rowSell))
    string coordinateMode = useDivider ? xloc.bar_index : xloc.bar_time
    int fullWidth = useDivider ? dividerWidthBars : math.max(1, int((profile.endTime - profile.startTime) * sessionWidthPercent / 100.0))
    bool volumeOnLeft = volumeSide == "Left"
    // One origin for BOTH sides in both layouts. In-session pairs are inset
    // by one full width so neither side spills into a neighboring session.
    int divider = useDivider ? bar_index + dividerGapBars + dividerWidthBars : pairOnLeftEdge ? profile.startTime + fullWidth : profile.endTime - fullWidth
    bool volumeGrowsRight = not volumeOnLeft
    bool deltaGrowsRight = not volumeGrowsRight
    int volumeAnchor = divider
    int deltaAnchor = divider
    for index = 0 to rowCount - 1
        float rowBuy = array.get(displayBuys, index)
        float rowSell = array.get(displaySells, index)
        float rowVolume = rowBuy + rowSell
        float rowDelta = rowBuy - rowSell
        int firstSourceRow = index * rowsPerGroup
        int endSourceRow = math.min(sourceRowCount, firstSourceRow + rowsPerGroup)
        float bottom = profile.lowerPrice + firstSourceRow * profile.rowHeight
        float top = profile.lowerPrice + endSourceRow * profile.rowHeight
        // Small vertical gaps keep neighboring rows legible.
        float inset = (top - bottom) * 0.04
        if showVolume and rowVolume > 0 and maxVolume > 0
            int width = math.max(1, int(math.round(fullWidth * rowVolume / maxVolume)))
            int left = volumeGrowsRight ? volumeAnchor : volumeAnchor - width
            int right = volumeGrowsRight ? volumeAnchor + width : volumeAnchor
            bool insideValueArea = firstSourceRow <= profile.vahIndex and endSourceRow > profile.valIndex
            bool containsPoc = firstSourceRow <= profile.pocIndex and endSourceRow > profile.pocIndex
            color rowColor = insideValueArea ? valueAreaColor : volumeColor
            color borderColor = containsPoc ? (profile.ended ? historicalPocColor : developingPocColor) : color.new(rowColor, 100)
            string rowText = showRowValues ? str.tostring(rowVolume, format.volume) : ""
            box volumeBox = box.new(left = left, top = top - inset, right = right, bottom = bottom + inset, xloc = coordinateMode, border_color = borderColor, border_width = 1, bgcolor = color.new(rowColor, profileTransparency), text = rowText, text_size = size.tiny, text_color = chart.fg_color)
            array.push(boxes, volumeBox)
        if showDelta and math.abs(rowDelta) > 0 and maxAbsDelta > 0
            int width = math.max(1, int(math.round(fullWidth * math.abs(rowDelta) / maxAbsDelta)))
            int left = deltaGrowsRight ? deltaAnchor : deltaAnchor - width
            int right = deltaGrowsRight ? deltaAnchor + width : deltaAnchor
            color rowColor = rowDelta > 0 ? positiveDeltaColor : negativeDeltaColor
            string rowText = showRowValues ? (rowDelta > 0 ? "+" : "") + str.tostring(rowDelta, format.volume) : ""
            box deltaBox = box.new(left = left, top = top - inset, right = right, bottom = bottom + inset, xloc = coordinateMode, border_color = color.new(rowColor, 100), border_width = 0, bgcolor = color.new(rowColor, profileTransparency), text = rowText, text_size = size.tiny, text_color = chart.fg_color)
            array.push(boxes, deltaBox)
    float profileTop = profile.lowerPrice + sourceRowCount * profile.rowHeight
    if showVolume or showDelta
        line spine = line.new(x1 = divider, y1 = profile.lowerPrice, x2 = divider, y2 = profileTop, xloc = coordinateMode, color = color.new(chart.fg_color, 65))
        array.push(lines, spine)
    if showValueArea
        float val = profile.lowerPrice + profile.valIndex * profile.rowHeight
        float vah = profile.lowerPrice + (profile.vahIndex + 1) * profile.rowHeight
        int left = useDivider ? divider - dividerWidthBars : profile.startTime
        int right = useDivider ? divider + dividerWidthBars : profile.endTime
        line valLine = line.new(x1 = left, y1 = val, x2 = right, y2 = val, xloc = coordinateMode, color = valueAreaLineColor, style = line.style_dotted)
        line vahLine = line.new(x1 = left, y1 = vah, x2 = right, y2 = vah, xloc = coordinateMode, color = valueAreaLineColor, style = line.style_dotted)
        array.push(lines, valLine)
        array.push(lines, vahLine)
    if showProfileTitles
        float titlePrice = profileTop + profile.rowHeight * 0.4
        if showDelta
            int titleX = deltaAnchor + (deltaGrowsRight ? 1 : -1) * int(fullWidth / 2)
            label title = label.new(x = titleX, y = titlePrice, text = "DELTA " + profile.dateText, xloc = coordinateMode, style = label.style_none, textcolor = chart.fg_color, size = size.tiny)
            array.push(labels, title)
        if showVolume
            int titleX = volumeAnchor + (volumeGrowsRight ? 1 : -1) * int(fullWidth / 2)
            label title = label.new(x = titleX, y = titlePrice, text = "VOLUME " + profile.dateText, xloc = coordinateMode, style = label.style_none, textcolor = chart.fg_color, size = size.tiny)
            array.push(labels, title)
    true

if barstate.isfirst
    if not timeframe.isintraday or not chart.is_standard
        runtime.error("Use a standard time-based intraday chart for the session profiles.")

string sessionTimezone = timezoneChoice == "Exchange" ? syminfo.timezone : timezoneChoice
string sessionString = sessionHours + (sessionDays == "Weekdays" ? ":23456" : ":1234567")
int startHour = int(str.tonumber(str.substring(sessionHours, 0, 2)))
int startMinute = int(str.tonumber(str.substring(sessionHours, 2, 4)))
int endHour = int(str.tonumber(str.substring(sessionHours, 5, 7)))
int endMinute = int(str.tonumber(str.substring(sessionHours, 7, 9)))
int todayStart = timestamp(sessionTimezone, year(time, sessionTimezone), month(time, sessionTimezone), dayofmonth(time, sessionTimezone), startHour, startMinute)
int customKey = time >= todayStart ? todayStart : timestamp(sessionTimezone, year(time, sessionTimezone), month(time, sessionTimezone), dayofmonth(time, sessionTimezone) - 1, startHour, startMinute)
int endDayOffset = endHour * 60 + endMinute <= startHour * 60 + startMinute ? 1 : 0
int customEnd = timestamp(sessionTimezone, year(customKey, sessionTimezone), month(customKey, sessionTimezone), dayofmonth(customKey, sessionTimezone) + endDayOffset, endHour, endMinute)
bool customMode = sessionMode == "Custom session"
bool inSession = customMode ? not na(time(timeframe.period, sessionString, sessionTimezone)) : true
int incomingKey = customMode ? customKey : time_tradingday

// Only ONE unique request. Both profiles use its identical price-row data.
footprint currentFootprint = request.footprint(1)

// Plain var state intentionally participates in realtime rollback. Each live
// calculation adds the current bar's footprint snapshot to the last confirmed
// session state; it does not repeatedly add that snapshot on every price tick.
var map<int, float> sessionBuys = map.new<int, float>()
var map<int, float> sessionSells = map.new<int, float>()
var array<SessionProfile> history = array.new<SessionProfile>()
var int activeKey = na
var int activeStart = na
var int activeEnd = na
var int expectedEnd = na
var int firstTick = na
var int lastTick = na
var bool partialStart = false
var bool crossedBoundary = false
var bool sourceLimitReached = false
var bool activeEnded = false
var int missingBars = 0
var int dataBars = 0
var string activeDateText = ""
var SessionProfile finalizedLatest = na
var array<box> drawnBoxes = array.new<box>()
var array<line> drawnLines = array.new<line>()
var array<label> drawnLabels = array.new<label>()
var table summary = table.new(position.bottom_right, 2, 7, bgcolor = color.new(chart.bg_color, 10), frame_color = color.new(chart.fg_color, 75), frame_width = 1)

int fullProfileHistory = profileHistory == "Current + previous sessions" ? previousProfileDays : 0
int historyToKeep = math.max(previousDays, fullProfileHistory)
// A generous calendar window covers the requested trading-session history.
// It also avoids aggregating raw tick rows throughout an unnecessarily long chart.
int historyCutoff = last_bar_time - (historyToKeep * 3 + 14) * 86400000
bool inCalculationWindow = time >= historyCutoff
if inCalculationWindow and inSession
    bool newSession = na(activeKey) or incomingKey != activeKey
    if newSession
        if not na(activeKey)
            SessionProfile previous = finalizedLatest
            if na(previous)
                bool complete = not partialStart and not crossedBoundary and not sourceLimitReached and missingBars == 0
                previous := f_buildProfile(sessionBuys, sessionSells, firstTick, lastTick, activeKey, activeStart, activeEnd, complete, true, activeDateText)
            if not na(previous)
                previous.ended := true
                array.unshift(history, previous)
                while array.size(history) > historyToKeep
                    array.pop(history)
        map.clear(sessionBuys)
        map.clear(sessionSells)
        activeKey := incomingKey
        activeStart := customMode ? customKey : time
        activeEnd := time_close
        expectedEnd := customMode ? customEnd : na
        firstTick := na
        lastTick := na
        partialStart := customMode ? time > customKey : not session.isfirstbar or barstate.isfirst
        crossedBoundary := false
        sourceLimitReached := false
        activeEnded := false
        missingBars := 0
        dataBars := 0
        activeDateText := customMode ? str.format_time(customEnd, "MMM d", sessionTimezone) : str.format_time(time_tradingday, "MMM d", "Etc/UTC")
        finalizedLatest := na
    activeEnd := customMode ? math.min(time_close, expectedEnd) : time_close
    bool alignedBar = not customMode or (time >= activeStart and time_close <= expectedEnd)
    if not alignedBar
        // Never mix outside-session volume into a selected custom session.
        crossedBoundary := true
    else if not na(currentFootprint)
        array<volume_row> sourceRows = currentFootprint.rows()
        bool positiveSourceVolume = false
        for sourceRow in sourceRows
            float buyAmount = nz(sourceRow.buy_volume(), 0.0)
            float sellAmount = nz(sourceRow.sell_volume(), 0.0)
            if buyAmount + sellAmount > 0
                positiveSourceVolume := true
                int tickKey = int(math.round(sourceRow.down_price() / syminfo.mintick))
                if map.contains(sessionBuys, tickKey) or map.size(sessionBuys) < MAX_SOURCE_ROWS
                    map.put(sessionBuys, tickKey, nz(map.get(sessionBuys, tickKey), 0.0) + buyAmount)
                    map.put(sessionSells, tickKey, nz(map.get(sessionSells, tickKey), 0.0) + sellAmount)
                    firstTick := na(firstTick) ? tickKey : math.min(firstTick, tickKey)
                    lastTick := na(lastTick) ? tickKey : math.max(lastTick, tickKey)
                else
                    sourceLimitReached := true
        if positiveSourceVolume or nz(volume, 0.0) == 0
            dataBars += 1
        else
            missingBars += 1
    else if nz(volume, 0.0) > 0
        missingBars += 1
    bool finalBar = customMode ? time_close >= expectedEnd : session.islastbar
    if barstate.isconfirmed and finalBar
        activeEnded := true

// Custom sessions can finish without a bar outside their hours being loaded.
// Their last aligned closing bar already finalized them above. This branch
// also handles a later out-of-session bar following an incomplete last bar.
if customMode and not na(activeKey) and time >= expectedEnd
    activeEnded := true

if activeEnded and na(finalizedLatest) and not na(activeKey)
    bool complete = not partialStart and not crossedBoundary and not sourceLimitReached and missingBars == 0
    finalizedLatest := f_buildProfile(sessionBuys, sessionSells, firstTick, lastTick, activeKey, activeStart, activeEnd, complete, true, activeDateText)

if barstate.islast
    f_clearDrawings(drawnBoxes, drawnLines, drawnLabels)
    SessionProfile latest = finalizedLatest
    if na(latest) and not na(firstTick)
        bool complete = not partialStart and not crossedBoundary and not sourceLimitReached and missingBars == 0
        latest := f_buildProfile(sessionBuys, sessionSells, firstTick, lastTick, activeKey, activeStart, activeEnd, complete, activeEnded, activeDateText)
    bool latestHasData = not na(latest) and array.size(latest.buys) > 0
    int visibleHistory = math.min(fullProfileHistory, array.size(history))
    int visibleProfileCount = latestHasData ? 1 : 0
    if visibleHistory > 0
        for index = 0 to visibleHistory - 1
            SessionProfile saved = array.get(history, index)
            if array.size(saved.buys) > 0
                visibleProfileCount += 1
    int visibleSides = (showVolume ? 1 : 0) + (showDelta ? 1 : 0)
    int maxDisplayRows = math.max(1, int(math.floor(float(PROFILE_BOX_BUDGET) / math.max(1, visibleProfileCount * visibleSides))))
    bool currentEnded = not na(activeKey) and activeEnded
    // A completed latest session is the newest historical day, even after hours.
    int olderExtensions = math.max(0, previousDays - (currentEnded ? 1 : 0))
    int extendedCount = 0

    // POC bands are drawn first so histograms remain clear in the foreground.
    if showPoc
        if latestHasData
            bool eligible = latest.completeData or allowPartialHistory
            bool extendLatest = latest.ended ? extendPreviousPoc and eligible : extendDevelopingPoc
            f_drawPoc(latest, extendLatest, latest.ended ? historicalPocColor : developingPocColor, drawnBoxes, drawnLines, drawnLabels)
            if latest.ended and extendLatest
                extendedCount += 1
        if array.size(history) > 0
            for index = 0 to array.size(history) - 1
                SessionProfile saved = array.get(history, index)
                bool savedHasData = array.size(saved.buys) > 0
                bool fullProfileVisible = index < fullProfileHistory
                bool eligible = saved.completeData or allowPartialHistory
                bool extendSaved = extendPreviousPoc and index < olderExtensions and eligible and savedHasData
                if savedHasData and (fullProfileVisible or extendSaved)
                    f_drawPoc(saved, extendSaved, historicalPocColor, drawnBoxes, drawnLines, drawnLabels)
                    if extendSaved
                        extendedCount += 1

    if latestHasData
        f_drawProfile(latest, placement == "Shared divider at right", volumeSide == "Left", maxDisplayRows, drawnBoxes, drawnLines, drawnLabels)
    if visibleHistory > 0
        for index = 0 to visibleHistory - 1
            SessionProfile saved = array.get(history, index)
            if array.size(saved.buys) > 0
                f_drawProfile(saved, false, previousSessionEdge == "Left", maxDisplayRows, drawnBoxes, drawnLines, drawnLabels)

    table.clear(summary, 0, 0, 1, 6)
    if showSummary
        string sessionText = customMode ? sessionHours + " " + (timezoneChoice == "Exchange" ? syminfo.timezone : timezoneChoice) : "Exchange trading day"
        table.cell(summary, 0, 0, "SESSION VP + DELTA", text_color = chart.fg_color, text_size = size.small)
        table.cell(summary, 1, 0, not na(latest) ? latest.dateText : "Waiting", text_color = chart.fg_color, text_size = size.small)
        table.cell(summary, 0, 1, "Session", text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 1, 1, sessionText, text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 0, 2, "Volume", text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 0, 3, "Net delta", text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 0, 4, "POC", text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 0, 5, "Extended POCs", text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 1, 5, str.tostring(extendedCount) + " / " + str.tostring(previousDays), text_color = chart.fg_color, text_size = size.tiny)
        table.cell(summary, 0, 6, "Status", text_color = chart.fg_color, text_size = size.tiny)
        if latestHasData
            float totalVolume = latest.totalBuy + latest.totalSell
            float netDelta = latest.totalBuy - latest.totalSell
            [pocBottom, pocTop, pocCenter] = f_pocBounds(latest)
            table.cell(summary, 1, 2, str.tostring(totalVolume, format.volume), text_color = chart.fg_color, text_size = size.tiny)
            table.cell(summary, 1, 3, (netDelta > 0 ? "+" : "") + str.tostring(netDelta, format.volume), text_color = netDelta >= 0 ? positiveDeltaColor : negativeDeltaColor, text_size = size.tiny)
            table.cell(summary, 1, 4, str.tostring(pocCenter, format.mintick), text_color = latest.ended ? historicalPocColor : developingPocColor, text_size = size.tiny)
            string statusText = latest.ended ? "Completed" : "Developing"
            if not latest.completeData
                statusText += sourceLimitReached ? " | Source row limit" : crossedBoundary or partialStart ? " | Partial session" : " | Missing footprint data"
            table.cell(summary, 1, 6, statusText, text_color = latest.completeData ? chart.fg_color : historicalPocColor, text_size = size.tiny)
        else
            table.cell(summary, 1, 2, "-", text_color = chart.fg_color, text_size = size.tiny)
            table.cell(summary, 1, 3, "-", text_color = chart.fg_color, text_size = size.tiny)
            table.cell(summary, 1, 4, "-", text_color = chart.fg_color, text_size = size.tiny)
            string statusText = crossedBoundary or partialStart ? "Align chart bars with session hours" : dataBars == 0 and missingBars > 0 ? "No footprint data for this session" : "Waiting for session volume"
            table.cell(summary, 1, 6, statusText, text_color = historicalPocColor, text_size = size.tiny)
````
