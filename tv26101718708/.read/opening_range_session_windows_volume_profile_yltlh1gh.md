# Opening Range + Session Windows + Volume Profile

- url: https://www.tradingview.com/script/ylTLH1Gh-Opening-Range-Session-Windows-Volume-Profile/
- type: indicator
- pine_id: PUB;c4da5d3ef2804c829d7b9bf8c396b992
- version: 2.0

## Description

[b]Opening Range + Session Windows + Volume Profile[/b]

This is a revised repost of my previous script version that trended on the TradingView community indicators page. The script has been rewritten, renamed, and cleaned up so the publication follows TradingView House Rules more closely. 

The goal of this indicator is to make intraday session structure easier to read from one chart.

Opening range levels can be useful, but they are much more useful when viewed with nearby volume-based context. A move away from the opening range is not always the same type of move. It can be moving into an area where volume previously built, away from an area where volume was thin, or toward a level where participation has already concentrated.

[i]This script is built to help show that context visually.[/i]

[b]📊 What the script shows[/b]

• Opening range high, low, and range box  
• Configurable session windows  
• Current session volume profile  
• Previous session volume profile  
• POC, HVN, and LVN levels  
• Live and prior session node labels  
• A terminal-style HUD for session state, trend, range size, POC, HVN, LVN, and impulse counts  
• A pressure meter based on session volume standard deviation  
• Filtered buy-volume and sell-volume impulse labels  

[b]🧠 Why it was built this way[/b]

The script is designed around one main idea: the opening range should not be viewed in isolation.

A breakout, rejection, or rotation around the opening range can look completely different depending on where volume is sitting around price. If price is moving into a high-volume area, that can suggest a different type of environment than price moving through a thinner low-volume area. If a prior POC or volume node is nearby, that may also change how a trader studies the move.

This indicator does not try to replace analysis. It simply brings the important intraday structure into one clean visual layout so the user can study the session with more context.

[b]⚙️ How to use it[/b]

1. Set the main session and opening range times in the settings.  
2. Use the opening range box to mark the first part of the session.  
3. Watch how price behaves around the current and prior volume nodes.  
4. Use POC, HVN, LVN, and session levels as structure references.  
5. Use the HUD to quickly read session state, trend, range size, and active nodes.  
6. Use the volume gauge and impulse labels to study stronger participation events.  
7. Adjust the session windows to match the market and timezone you trade.  

[b]🔁 Current vs prior levels[/b]

[i]Live session levels are labeled as [b]LIVE[/b].[/i]

[i]Previous session levels are labeled as [b]PRIOR[/b].[/i]

This makes it easier to separate developing session structure from levels carried forward from the last completed session.

[b]⚡ Volume impulse labels[/b]

The volume impulse labels are intentionally filtered. They are not meant to appear on every volume increase. The script only prints them when participation is stronger than normal based on the selected settings.

This helps keep the chart cleaner and prevents the indicator from turning into a label-heavy mess.

[b]🕒 Session windows[/b]

The session windows are visual time references only. They are fully configurable from the settings and can be adjusted, enabled, or disabled depending on the market being viewed.

[b]⚠️ Important notes[/b]

This is not a trading system.

This script does not place trades, issue alerts to buy or sell, provide financial advice, or tell the user what action to take. It is a decision-support tool for studying intraday structure, volume location, session context, and participation.

FOR PINECODERS TEAM: Promotional references, branding, and unclear wording have been removed, and this description has been expanded so users can understand the purpose of the tool without needing to read the Pine code.  I cannot, within reason, direct users any further regarding specific use of this indicator as to avoid providing any form of financial advice.  It is a framework tool for various use-cases outlined above.

The user is responsible for their own analysis, risk management, and execution decisions.

[b]✅ Best used on[/b]

Intraday charts where opening range structure and volume context matter, including index futures, stocks, ETFs, and other liquid instruments with meaningful volume data.

## Source Code

````pine
//──────────────────────────────────────────────────────────────────────────────
// Opening Range + Session Windows + Volume Profile
//
// This tool combines intraday opening range structure, configurable session
// windows, and session volume profile nodes.
//
// The purpose is not to generate automatic trade instructions. The purpose is
// to make the opening range easier to read in context. A move through the
// opening range can mean very different things depending on where current and
// prior volume is concentrated. For that reason, the script maps POC, HVN, LVN,
// session pressure, trend state, and volume impulses.
//
// The session windows are visual time references. They are user-configurable
// and can be changed or disabled from the settings.
//
// Volume impulse labels are filtered so weak or average participation does not
// spam the chart. The goal is to highlight only stronger participation events
// while keeping the chart readable.
//
// This is a decision-support indicator for studying intraday structure,
// participation, and nearby volume-based levels. It does not provide financial
// advice or trade recommendations.
//──────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Opening Range + Session Windows + Volume Profile", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// inputs
groupSession = "Session"
mainSession = input.session("0930-1600", "Main Session", group = groupSession)
openingRangeSession = input.session("0930-0945", "Opening Range Session", group = groupSession)
sessionTimezone = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "America/Chicago", "UTC", "Europe/London"], group = groupSession)

groupProfile = "Volume Profile"
showCurrentProfile = input.bool(true, "Show Current Profile", group = groupProfile)
showPreviousProfile = input.bool(true, "Show Previous Profile", group = groupProfile)
profileRows = input.int(32, "Rows", minval = 12, maxval = 72, group = groupProfile)
profileWidth = input.int(22, "Profile Width", minval = 6, maxval = 70, group = groupProfile)
profileOffset = input.int(7, "Right Offset", minval = 1, maxval = 90, group = groupProfile)
maxHvns = input.int(3, "HVNs Per Session", minval = 1, maxval = 8, group = groupProfile)
maxLvns = input.int(2, "LVNs Per Session", minval = 0, maxval = 8, group = groupProfile)
nodeSeparation = input.int(4, "Node Spacing", minval = 2, maxval = 10, group = groupProfile)
hvnThreshold = input.float(0.24, "HVN Threshold", minval = 0.05, maxval = 1.0, step = 0.05, group = groupProfile)
lvnThreshold = input.float(0.30, "LVN Threshold", minval = 0.05, maxval = 0.80, step = 0.05, group = groupProfile)

groupImpulse = "Volume Impulse"
sessionZMinBars = input.int(4, "Session StdDev Minimum Bars", minval = 3, maxval = 100, group = groupImpulse)
impulseZ = input.float(1.15, "Impulse Session Z-Score", minval = 0.50, maxval = 6.00, step = 0.05, group = groupImpulse)
impulseWickMax = input.float(0.55, "Max Wick Share", minval = 0.05, maxval = 0.95, step = 0.05, group = groupImpulse)
impulseLabelSpacingBars = input.int(3, "Impulse Label Spacing Bars", minval = 3, maxval = 20, group = groupImpulse)
maxImpulseLabels = input.int(140, "Max Impulse Labels", minval = 10, maxval = 300, group = groupImpulse)
relativeVolumeLength = input.int(20, "Relative Volume Length", minval = 5, maxval = 100, group = groupImpulse)
relativeVolumeMin = input.float(1.25, "Relative Volume Trigger", minval = 1.00, maxval = 5.00, step = 0.05, group = groupImpulse)

groupRegime = "Regime"
kerLen = input.int(24, "KER Length", minval = 5, maxval = 100, group = groupRegime)
emaFastLen = input.int(9, "Fast EMA", minval = 2, maxval = 100, group = groupRegime)
emaSlowLen = input.int(21, "Slow EMA", minval = 3, maxval = 200, group = groupRegime)
structureLen = input.int(9, "Structure Lookback", minval = 3, maxval = 30, group = groupRegime)

groupVisual = "Visuals"
showHud = input.bool(true, "Show Terminal HUD", group = groupVisual)
showPressureMeter = input.bool(true, "Show Pressure Meter", group = groupVisual)
showNodeLabels = input.bool(true, "Show Node Labels", group = groupVisual)
showOpeningRangeLabels = input.bool(true, "Show Opening Range Labels", group = groupVisual)
showImpulseLabels = input.bool(true, "Show Volume Impulse Labels", group = groupVisual)
nodeExtendBars = input.int(34, "Node Extend Bars", minval = 8, maxval = 140, group = groupVisual)

groupKillzones = "Session Windows"
showKillzones = input.bool(true, "Show Session Windows", group = groupKillzones)
showKillzoneText = input.bool(true, "Show Window Text", group = groupKillzones)
maxKillzoneDays = input.int(1, "Session Window Drawing Limit", minval = 1, maxval = 12, group = groupKillzones)
useAsiaKillzone = input.bool(true, "Asia", inline = "Asia", group = groupKillzones)
asiaKillzoneSession = input.session("2000-0000", "", inline = "Asia", group = groupKillzones)
useLondonKillzone = input.bool(true, "London", inline = "London", group = groupKillzones)
londonKillzoneSession = input.session("0200-0500", "", inline = "London", group = groupKillzones)
useNyAmKillzone = input.bool(true, "NY AM", inline = "NYAM", group = groupKillzones)
nyAmKillzoneSession = input.session("0930-1100", "", inline = "NYAM", group = groupKillzones)
useNyLunchKillzone = input.bool(true, "NY Lunch", inline = "NYLunch", group = groupKillzones)
nyLunchKillzoneSession = input.session("1200-1300", "", inline = "NYLunch", group = groupKillzones)
useNyPmKillzone = input.bool(true, "NY PM", inline = "NYPM", group = groupKillzones)
nyPmKillzoneSession = input.session("1330-1600", "", inline = "NYPM", group = groupKillzones)
killzoneBoxTransparency = input.int(93, "Box Transparency", minval = 70, maxval = 98, group = groupKillzones)
killzoneBorderTransparency = input.int(70, "Border Transparency", minval = 0, maxval = 95, group = groupKillzones)
killzoneTextTransparency = input.int(50, "Text Transparency", minval = 0, maxval = 100, group = groupKillzones)

groupAlerts = "Alerts"
alertOrBreakout = input.bool(true, "Alert: Opening Range Breakout", group = groupAlerts)
alertVolumeImpulse = input.bool(true, "Alert: Volume Impulse", group = groupAlerts)
alertPocTouch = input.bool(false, "Alert: Price Tags Current POC", group = groupAlerts)

// theme
cBg = color.rgb(4, 7, 12)
cPanel = color.rgb(8, 13, 22)
cPanel2 = color.rgb(10, 18, 30)
cGrid = color.rgb(20, 38, 54)
cText = color.rgb(232, 240, 248)
cMuted = color.rgb(132, 145, 160)
cWhite = color.rgb(255, 255, 255)
cCyan = color.rgb(0, 220, 255)
cCyanDark = color.rgb(0, 92, 130)
cCurrentProfile = color.rgb(0, 188, 218)
cPreviousProfile = color.rgb(84, 96, 112)
cUp = color.rgb(0, 230, 155)
cDown = color.rgb(255, 68, 98)
cRange = color.rgb(0, 130, 170)
cViolet = color.rgb(96, 232, 255)
cBlue = color.rgb(62, 132, 255)
cGlass = color.rgb(7, 16, 28)
cAsia = color.rgb(76, 118, 255)
cLondon = color.rgb(0, 198, 230)
cNyAm = color.rgb(0, 220, 175)
cNyLunch = color.rgb(210, 225, 240)
cNyPm = color.rgb(120, 220, 255)

// helpers
f_clear_boxes(array<box> arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            box.delete(array.get(arr, i))
    array.clear(arr)

f_clear_lines(array<line> arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            line.delete(array.get(arr, i))
    array.clear(arr)

f_clear_labels(array<label> arr) =>
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            label.delete(array.get(arr, i))
    array.clear(arr)

f_fmt2(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##")

f_fmt1(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.#")

f_fmt0(float x) =>
    string out = "n/a"
    if not na(x)
        int v = int(math.round(x))
        int av = int(math.abs(v))
        string s = str.tostring(av)
        int n = str.length(s)
        string sign = v < 0 ? "-" : ""
        out := n <= 3 ? sign + s : n <= 6 ? sign + str.substring(s, 0, n - 3) + "," + str.substring(s, n - 3, n) : sign + str.substring(s, 0, n - 6) + "," + str.substring(s, n - 6, n - 3) + "," + str.substring(s, n - 3, n)
    out

f_node_list(array<int> rowsArr, float sessionLow, float stepVal, int pocIdx, bool skipPoc) =>
    string out = "n/a"
    if array.size(rowsArr) > 0 and not na(sessionLow) and not na(stepVal)
        string txt = ""
        int count = 0
        for i = 0 to array.size(rowsArr) - 1
            int rowIdx = array.get(rowsArr, i)
            bool includeRow = not skipPoc or na(pocIdx) or rowIdx != pocIdx
            if includeRow
                float nodePrice = sessionLow + stepVal * (rowIdx + 0.5)
                txt := count == 0 ? f_fmt0(nodePrice) : txt + "  |  " + f_fmt0(nodePrice)
                count += 1
        out := count > 0 ? txt : "n/a"
    out

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_month_text(int m) =>
    m == 1 ? "JAN" : m == 2 ? "FEB" : m == 3 ? "MAR" : m == 4 ? "APR" : m == 5 ? "MAY" : m == 6 ? "JUN" : m == 7 ? "JUL" : m == 8 ? "AUG" : m == 9 ? "SEP" : m == 10 ? "OCT" : m == 11 ? "NOV" : m == 12 ? "DEC" : ""

f_session_date_text(int m, int d) =>
    f_month_text(m) + " " + str.tostring(d)

f_type_text(int typ) =>
    typ == 1 ? "POC" : typ == 2 ? "HVN" : typ == 3 ? "LVN" : "Node"

f_type_color(int typ) =>
    typ == 1 ? cWhite : typ == 2 ? cBlue : cViolet

f_zero_float_array(array<float> arr, int targetSize) =>
    if array.size(arr) != targetSize
        while array.size(arr) > 0
            array.pop(arr)
        for i = 0 to targetSize - 1
            array.push(arr, 0.0)
    else
        for i = 0 to targetSize - 1
            array.set(arr, i, 0.0)

f_day_class(float dayKer, float netMove, float dayRange) =>
    string res = "Building"
    float netAbs = math.abs(netMove)
    float netRangeShare = dayRange > syminfo.mintick ? netAbs / dayRange : 0.0
    bool upDay = netMove >= 0
    bool strongTrendDay = (dayKer >= 0.38 and netRangeShare >= 0.55) or netRangeShare >= 0.70
    bool trendDay = (dayKer >= 0.24 and netRangeShare >= 0.40) or netRangeShare >= 0.55
    if na(dayKer) or na(netMove) or na(dayRange) or dayRange <= syminfo.mintick
        res := "Building"
    else if strongTrendDay
        res := upDay ? "Strong Uptrend" : "Strong Downtrend"
    else if trendDay
        res := upDay ? "Uptrend" : "Downtrend"
    else
        res := "Chop / Mean Reverting"
    res

f_select_high_nodes(array<float> rowsArr, array<int> outRows, int pocIdx, float maxVol, int rowsCount, int maxPick, int minSep, float thresholdPct) =>
    if not na(pocIdx)
        array.push(outRows, pocIdx)
        float threshold = maxVol * thresholdPct
        array<int> selectedRows = array.new_int()
        array.push(selectedRows, pocIdx)
        for pick = 0 to maxPick - 1
            int bestRow = na
            float bestVol = na
            for r = 0 to rowsCount - 1
                float rv = array.get(rowsArr, r)
                bool notPoc = r != pocIdx
                bool aboveThreshold = rv >= threshold
                bool spaced = true
                if array.size(selectedRows) > 0
                    for j = 0 to array.size(selectedRows) - 1
                        if math.abs(r - array.get(selectedRows, j)) <= minSep
                            spaced := false
                if notPoc and aboveThreshold and spaced and (na(bestVol) or rv > bestVol)
                    bestVol := rv
                    bestRow := r
            if not na(bestRow)
                array.push(selectedRows, bestRow)
                array.push(outRows, bestRow)

f_select_low_nodes(array<float> rowsArr, array<int> outRows, int pocIdx, float maxVol, int rowsCount, int maxPick, int minSep, float thresholdPct) =>
    if maxPick > 0 and rowsCount > 2 and maxVol > 0
        array<int> selectedRows = array.new_int()
        if not na(pocIdx)
            array.push(selectedRows, pocIdx)
        float threshold = maxVol * thresholdPct
        for pick = 0 to maxPick - 1
            int bestRow = na
            float bestScore = na
            for r = 1 to rowsCount - 2
                float rv = array.get(rowsArr, r)
                float leftVol = array.get(rowsArr, r - 1)
                float rightVol = array.get(rowsArr, r + 1)
                bool notPoc = r != pocIdx
                bool localLow = rv < leftVol and rv < rightVol
                bool weakEnough = rv <= threshold
                bool realNeighbors = leftVol + rightVol > maxVol * 0.12
                bool spaced = true
                if array.size(selectedRows) > 0
                    for j = 0 to array.size(selectedRows) - 1
                        if math.abs(r - array.get(selectedRows, j)) <= minSep
                            spaced := false
                if notPoc and localLow and weakEnough and realNeighbors and spaced
                    float score = leftVol + rightVol - rv
                    if na(bestScore) or score > bestScore
                        bestScore := score
                        bestRow := r
            if not na(bestRow)
                array.push(selectedRows, bestRow)
                array.push(outRows, bestRow)

f_kz_text_color(string zoneName, color zoneColor) =>
    zoneName == "Midday Window" ? color.rgb(12, 16, 22) : zoneColor

f_kz_active(bool enabled, string sessionText) =>
    enabled and showKillzones and not na(time(timeframe.period, sessionText, sessionTimezone))

f_trim_box_array(array<box> arr, int maxKeep) =>
    while array.size(arr) > maxKeep
        box.delete(array.pop(arr))

f_manage_killzone(bool enabled, string sessionText, string zoneName, color zoneColor, array<box> boxes) =>
    bool active = f_kz_active(enabled, sessionText)
    bool started = active and not (active[1] == true)
    color labelTextColor = f_kz_text_color(zoneName, zoneColor)
    if started
        color boxBg = color.new(zoneColor, killzoneBoxTransparency)
        color boxBorder = color.new(zoneColor, killzoneBorderTransparency)
        color boxTextColor = color.new(labelTextColor, killzoneTextTransparency)
        box zoneBox = box.new(left = time, top = high, right = time, bottom = low, xloc = xloc.bar_time, bgcolor = boxBg, border_color = boxBorder, border_width = 1, text = showKillzoneText ? zoneName : "", text_color = boxTextColor)
        array.unshift(boxes, zoneBox)
        f_trim_box_array(boxes, maxKillzoneDays)
    if active and array.size(boxes) > 0
        box zoneBox = array.get(boxes, 0)
        float newTop = math.max(box.get_top(zoneBox), high)
        float newBottom = math.min(box.get_bottom(zoneBox), low)
        box.set_right(zoneBox, time)
        box.set_top(zoneBox, newTop)
        box.set_bottom(zoneBox, newBottom)
        box.set_bgcolor(zoneBox, color.new(zoneColor, killzoneBoxTransparency))
        box.set_border_color(zoneBox, color.new(zoneColor, killzoneBorderTransparency))

// session
inSession = not na(time(timeframe.period, mainSession, sessionTimezone))
inOpeningRange = not na(time(timeframe.period, openingRangeSession, sessionTimezone))
wasInSession = inSession[1] == true
newSession = inSession and not wasInSession
sessionEnded = not inSession and wasInSession
newOpeningRange = inOpeningRange and not (inOpeningRange[1] == true)

// storage
var array<float> currentHighs = array.new_float()
var array<float> currentLows = array.new_float()
var array<float> currentVolumes = array.new_float()
var array<float> previousHighs = array.new_float()
var array<float> previousLows = array.new_float()
var array<float> previousVolumes = array.new_float()

var array<float> currentRows = array.new_float()
var array<float> previousRows = array.new_float()
var array<int> currentHvnRows = array.new_int()
var array<int> previousHvnRows = array.new_int()
var array<int> currentLvnRows = array.new_int()
var array<int> previousLvnRows = array.new_int()

// drawings
var array<box> profileBoxes = array.new_box()
var array<box> nodeBoxes = array.new_box()
var array<label> nodeLabels = array.new_label()
var array<label> impulseLabels = array.new_label()

var array<box> asiaBoxes = array.new_box()
var array<box> londonBoxes = array.new_box()
var array<box> nyAmBoxes = array.new_box()
var array<box> nyLunchBoxes = array.new_box()
var array<box> nyPmBoxes = array.new_box()

var line openingRangeHighLine = na
var line openingRangeLowLine = na
var label openingRangeHighLabel = na
var label openingRangeLowLabel = na
var label openingRangeTextLabel = na

// range state
var float currentSessionHigh = na
var float currentSessionLow = na
var float previousSessionHigh = na
var float previousSessionLow = na
var int currentSessionStartBar = na
var int previousSessionStartBar = na
var string currentSessionDateText = ""
var string previousSessionDateText = ""
var float openingRangeHigh = na
var float openingRangeLow = na
var int openingRangeStartBar = na
var int openingRangeRightBar = na
var box openingRangeBox = na

// day state
var bool haveSession = false
var bool sessionClassified = false
var float currentDayOpen = na
var float currentDayClose = na
var float currentDayPath = na
var string previousDayType = "Building"
var int completedDays = 0
var int sessionImpulseCount = 0
var int sessionPositiveImpulses = 0
var int sessionNegativeImpulses = 0

// session volume standard deviation
var float sessionVolSum = 0.0
var float sessionVolSqSum = 0.0
var int sessionVolCount = 0
var int lastImpulseLabelBar = na

// classify finished session
if sessionEnded and haveSession and not sessionClassified and not na(currentSessionHigh) and not na(currentSessionLow) and not na(currentDayOpen) and not na(currentDayClose)
    float dayRange = currentSessionHigh - currentSessionLow
    float netMove = currentDayClose - currentDayOpen
    float dayKer = currentDayPath > syminfo.mintick ? math.abs(netMove) / currentDayPath : 0.0
    previousDayType := f_day_class(dayKer, netMove, dayRange)
    completedDays += 1
    sessionClassified := true

// rollover
if newSession
    if haveSession and not sessionClassified and not na(currentSessionHigh) and not na(currentSessionLow) and not na(currentDayOpen) and not na(currentDayClose)
        float dayRange = currentSessionHigh - currentSessionLow
        float netMove = currentDayClose - currentDayOpen
        float dayKer = currentDayPath > syminfo.mintick ? math.abs(netMove) / currentDayPath : 0.0
        previousDayType := f_day_class(dayKer, netMove, dayRange)
        completedDays += 1

    previousSessionHigh := currentSessionHigh
    previousSessionLow := currentSessionLow
    previousSessionStartBar := currentSessionStartBar
    previousSessionDateText := currentSessionDateText

    array.clear(previousHighs)
    array.clear(previousLows)
    array.clear(previousVolumes)
    if array.size(currentHighs) > 0
        for i = 0 to array.size(currentHighs) - 1
            array.push(previousHighs, array.get(currentHighs, i))
            array.push(previousLows, array.get(currentLows, i))
            array.push(previousVolumes, array.get(currentVolumes, i))

    array.clear(currentHighs)
    array.clear(currentLows)
    array.clear(currentVolumes)

    currentSessionHigh := high
    currentSessionLow := low
    currentSessionStartBar := bar_index
    currentSessionDateText := f_session_date_text(month(time, sessionTimezone), dayofmonth(time, sessionTimezone))
    currentDayOpen := open
    currentDayClose := close
    currentDayPath := math.abs(close - open)
    haveSession := true
    sessionClassified := false
    sessionImpulseCount := 0
    sessionPositiveImpulses := 0
    sessionNegativeImpulses := 0
    openingRangeHigh := na
    openingRangeLow := na
    openingRangeStartBar := na
    openingRangeRightBar := na
    sessionVolSum := 0.0
    sessionVolSqSum := 0.0
    sessionVolCount := 0
    lastImpulseLabelBar := na

    if not na(openingRangeBox)
        box.delete(openingRangeBox)
    openingRangeBox := na
    if not na(openingRangeHighLine)
        line.delete(openingRangeHighLine)
        openingRangeHighLine := na
    if not na(openingRangeLowLine)
        line.delete(openingRangeLowLine)
        openingRangeLowLine := na
    if not na(openingRangeHighLabel)
        label.delete(openingRangeHighLabel)
        openingRangeHighLabel := na
    if not na(openingRangeLowLabel)
        label.delete(openingRangeLowLabel)
        openingRangeLowLabel := na
    if not na(openingRangeTextLabel)
        label.delete(openingRangeTextLabel)
        openingRangeTextLabel := na

// live session tracking
if inSession and not newSession
    currentSessionHigh := na(currentSessionHigh) ? high : math.max(currentSessionHigh, high)
    currentSessionLow := na(currentSessionLow) ? low : math.min(currentSessionLow, low)
    currentDayClose := close
    if inSession[1] == true
        currentDayPath := na(currentDayPath) ? math.abs(close - open) : currentDayPath + math.abs(close - close[1])

if inSession and barstate.isconfirmed
    if currentSessionDateText == ""
        currentSessionDateText := f_session_date_text(month(time, sessionTimezone), dayofmonth(time, sessionTimezone))
    array.push(currentHighs, high)
    array.push(currentLows, low)
    array.push(currentVolumes, na(volume) ? 0.0 : volume)

// opening range
if newOpeningRange
    openingRangeHigh := high
    openingRangeLow := low
    openingRangeStartBar := bar_index
    openingRangeRightBar := bar_index
    if not na(openingRangeBox)
        box.delete(openingRangeBox)
    openingRangeBox := box.new(left = bar_index, top = high, right = bar_index, bottom = low, xloc = xloc.bar_index, bgcolor = color.new(cRange, 88), border_color = color.new(cCyan, 44), border_width = 1, text = "", text_color = color.new(cCyan, 0))

if inOpeningRange
    openingRangeHigh := na(openingRangeHigh) ? high : math.max(openingRangeHigh, high)
    openingRangeLow := na(openingRangeLow) ? low : math.min(openingRangeLow, low)

if not na(openingRangeBox) and inSession and not na(openingRangeHigh) and not na(openingRangeLow)
    openingRangeRightBar := bar_index
    box.set_right(openingRangeBox, openingRangeRightBar)
    box.set_top(openingRangeBox, openingRangeHigh)
    box.set_bottom(openingRangeBox, openingRangeLow)
    box.set_bgcolor(openingRangeBox, color.new(cRange, 89))
    box.set_border_color(openingRangeBox, color.new(cCyan, 48))

openingRangeReady = not inOpeningRange and not na(openingRangeHigh) and not na(openingRangeLow) and not na(openingRangeStartBar)
openingRangeSize = not na(openingRangeHigh) and not na(openingRangeLow) ? openingRangeHigh - openingRangeLow : na

if not na(openingRangeBox)
    box.set_text(openingRangeBox, "")
    box.set_text_color(openingRangeBox, color.new(cCyan, 0))
    box.set_text_size(openingRangeBox, size.huge)
    box.set_text_halign(openingRangeBox, text.align_center)
    box.set_text_valign(openingRangeBox, text.align_center)

// session windows
f_manage_killzone(useAsiaKillzone, asiaKillzoneSession, "Asia Window", cAsia, asiaBoxes)
f_manage_killzone(useLondonKillzone, londonKillzoneSession, "London Window", cLondon, londonBoxes)
f_manage_killzone(useNyAmKillzone, nyAmKillzoneSession, "NY Open Window", cNyAm, nyAmBoxes)
f_manage_killzone(useNyLunchKillzone, nyLunchKillzoneSession, "Midday Window", cNyLunch, nyLunchBoxes)
f_manage_killzone(useNyPmKillzone, nyPmKillzoneSession, "NY PM Window", cNyPm, nyPmBoxes)

// profiles
f_zero_float_array(currentRows, profileRows)
f_zero_float_array(previousRows, profileRows)
array.clear(currentHvnRows)
array.clear(previousHvnRows)
array.clear(currentLvnRows)
array.clear(previousLvnRows)

currentReady = array.size(currentHighs) > 0 and not na(currentSessionHigh) and not na(currentSessionLow) and currentSessionHigh > currentSessionLow
previousReady = array.size(previousHighs) > 0 and not na(previousSessionHigh) and not na(previousSessionLow) and previousSessionHigh > previousSessionLow

currentStep = currentReady ? math.max(syminfo.mintick, (currentSessionHigh - currentSessionLow) / profileRows) : na
previousStep = previousReady ? math.max(syminfo.mintick, (previousSessionHigh - previousSessionLow) / profileRows) : na

if currentReady
    for b = 0 to array.size(currentHighs) - 1
        float bh = array.get(currentHighs, b)
        float bl = array.get(currentLows, b)
        float bv = array.get(currentVolumes, b)
        float br = math.max(syminfo.mintick, bh - bl)
        for r = 0 to profileRows - 1
            float rowLow = currentSessionLow + currentStep * r
            float rowHigh = rowLow + currentStep
            float overlap = math.max(0.0, math.min(bh, rowHigh) - math.max(bl, rowLow))
            if overlap > 0
                array.set(currentRows, r, array.get(currentRows, r) + bv * overlap / br)

if previousReady
    for b = 0 to array.size(previousHighs) - 1
        float bh = array.get(previousHighs, b)
        float bl = array.get(previousLows, b)
        float bv = array.get(previousVolumes, b)
        float br = math.max(syminfo.mintick, bh - bl)
        for r = 0 to profileRows - 1
            float rowLow = previousSessionLow + previousStep * r
            float rowHigh = rowLow + previousStep
            float overlap = math.max(0.0, math.min(bh, rowHigh) - math.max(bl, rowLow))
            if overlap > 0
                array.set(previousRows, r, array.get(previousRows, r) + bv * overlap / br)

// poc
int currentPocIndex = na
int previousPocIndex = na
float currentMaxVol = na
float previousMaxVol = na

if currentReady
    currentPocIndex := 0
    currentMaxVol := array.get(currentRows, 0)
    for r = 1 to profileRows - 1
        float rv = array.get(currentRows, r)
        if rv > currentMaxVol
            currentMaxVol := rv
            currentPocIndex := r

if previousReady
    previousPocIndex := 0
    previousMaxVol := array.get(previousRows, 0)
    for r = 1 to profileRows - 1
        float rv = array.get(previousRows, r)
        if rv > previousMaxVol
            previousMaxVol := rv
            previousPocIndex := r

// nodes
if currentReady and not na(currentPocIndex)
    f_select_high_nodes(currentRows, currentHvnRows, currentPocIndex, currentMaxVol, profileRows, maxHvns, nodeSeparation, hvnThreshold)
    f_select_low_nodes(currentRows, currentLvnRows, currentPocIndex, currentMaxVol, profileRows, maxLvns, nodeSeparation, lvnThreshold)

if previousReady and not na(previousPocIndex)
    f_select_high_nodes(previousRows, previousHvnRows, previousPocIndex, previousMaxVol, profileRows, maxHvns, nodeSeparation, hvnThreshold)
    f_select_low_nodes(previousRows, previousLvnRows, previousPocIndex, previousMaxVol, profileRows, maxLvns, nodeSeparation, lvnThreshold)

// nearest maps
float priorUpDist = na
float priorDnDist = na
float liveUpDist = na
float liveDnDist = na

if previousReady and not na(previousStep)
    if array.size(previousHvnRows) > 0
        for i = 0 to array.size(previousHvnRows) - 1
            int rowIdx = array.get(previousHvnRows, i)
            float p = previousSessionLow + previousStep * (rowIdx + 0.5)
            if p > close
                float d = p - close
                if na(priorUpDist) or d < priorUpDist
                    priorUpDist := d
            if p < close
                float d = close - p
                if na(priorDnDist) or d < priorDnDist
                    priorDnDist := d
    if array.size(previousLvnRows) > 0
        for i = 0 to array.size(previousLvnRows) - 1
            int rowIdx = array.get(previousLvnRows, i)
            float p = previousSessionLow + previousStep * (rowIdx + 0.5)
            if p > close
                float d = p - close
                if na(priorUpDist) or d < priorUpDist
                    priorUpDist := d
            if p < close
                float d = close - p
                if na(priorDnDist) or d < priorDnDist
                    priorDnDist := d

if currentReady and not na(currentStep)
    if array.size(currentHvnRows) > 0
        for i = 0 to array.size(currentHvnRows) - 1
            int rowIdx = array.get(currentHvnRows, i)
            float p = currentSessionLow + currentStep * (rowIdx + 0.5)
            if p > close
                float d = p - close
                if na(liveUpDist) or d < liveUpDist
                    liveUpDist := d
            if p < close
                float d = close - p
                if na(liveDnDist) or d < liveDnDist
                    liveDnDist := d
    if array.size(currentLvnRows) > 0
        for i = 0 to array.size(currentLvnRows) - 1
            int rowIdx = array.get(currentLvnRows, i)
            float p = currentSessionLow + currentStep * (rowIdx + 0.5)
            if p > close
                float d = p - close
                if na(liveUpDist) or d < liveUpDist
                    liveUpDist := d
            if p < close
                float d = close - p
                if na(liveDnDist) or d < liveDnDist
                    liveDnDist := d

// session standard deviation pressure
sessionVolMean = sessionVolCount >= sessionZMinBars ? sessionVolSum / sessionVolCount : na
sessionVolVariance = sessionVolCount >= sessionZMinBars ? math.max((sessionVolSqSum / sessionVolCount) - math.pow(sessionVolMean, 2.0), 0.0) : na
sessionVolStd = not na(sessionVolVariance) ? math.sqrt(sessionVolVariance) : na
sessionVolZ = inSession and not na(sessionVolStd) and sessionVolStd > 0 ? (volume - sessionVolMean) / sessionVolStd : 0.0

barRange = high - low
barBody = math.abs(close - open)
wickShare = barRange > 0 ? (barRange - barBody) / barRange : 1.0
signedPressure = sessionVolZ * (close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0)
pressureClamped = f_clamp(signedPressure, -3.0, 3.0)
relativeVolumeBase = ta.sma(volume, relativeVolumeLength)
relativeVolumeRatio = not na(relativeVolumeBase) and relativeVolumeBase > 0 ? volume / relativeVolumeBase : 0.0
impulseBySessionZ = inSession and sessionVolCount >= sessionZMinBars and sessionVolZ >= impulseZ
impulseByRelativeVolume = inSession and relativeVolumeRatio >= relativeVolumeMin
impulseRaw = barstate.isconfirmed and ((impulseBySessionZ and sessionVolZ >= 3.0) or (impulseByRelativeVolume and relativeVolumeRatio >= 3.0))
impulseDirection = close > open ? 1 : close < open ? -1 : close >= close[1] ? 1 : -1
impulseUp = impulseRaw and impulseDirection == 1
impulseDown = impulseRaw and impulseDirection == -1

if impulseUp or impulseDown
    int impulseCooldownBars = math.max(3, impulseLabelSpacingBars)
    bool canPrintImpulse = showImpulseLabels and (na(lastImpulseLabelBar) or bar_index - lastImpulseLabelBar >= impulseCooldownBars)
    if canPrintImpulse
        lastImpulseLabelBar := bar_index
        sessionImpulseCount += 1
        sessionPositiveImpulses += impulseUp ? 1 : 0
        sessionNegativeImpulses += impulseDown ? 1 : 0
        color impulseColor = impulseUp ? cUp : cDown
        string impulseMetric = sessionVolZ >= 3.0 ? f_fmt1(sessionVolZ) + "σ" : f_fmt1(relativeVolumeRatio) + "x"
        string impulseText = impulseUp ? "Buy Vol +" + impulseMetric : "Sell Vol +" + impulseMetric
        label il = label.new(bar_index, na, " " + impulseText + " ", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(impulseColor, 12), textcolor = cWhite, size = size.small)
        array.push(impulseLabels, il)
        if array.size(impulseLabels) > maxImpulseLabels
            label.delete(array.shift(impulseLabels))

if inSession and barstate.isconfirmed and not na(volume)
    sessionVolSum += volume
    sessionVolSqSum += volume * volume
    sessionVolCount += 1

// trend
float kerPath = 0.0
for i = 0 to kerLen - 1
    kerPath += not na(close[i + 1]) ? math.abs(close[i] - close[i + 1]) : 0.0

trendEr = kerPath > syminfo.mintick and not na(close[kerLen]) ? math.abs(close - close[kerLen]) / kerPath : 0.0
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atrNow = ta.atr(14)

int upStruct = 0
int downStruct = 0
if structureLen > 2
    for i = 0 to structureLen - 2
        bool stepUp = not na(high[i + 1]) and high[i] > high[i + 1] and low[i] >= low[i + 1]
        bool stepDown = not na(high[i + 1]) and high[i] < high[i + 1] and low[i] <= low[i + 1]
        if stepUp
            upStruct += 1
        if stepDown
            downStruct += 1

structureBias = (upStruct - downStruct) / math.max(1.0, structureLen - 1.0)
emaSepNorm = atrNow > syminfo.mintick ? f_clamp(math.abs(emaFast - emaSlow) / atrNow * 2.0, 0.0, 1.0) : 0.0
trendScoreFloat = trendEr * 60.0 + math.abs(structureBias) * 25.0 + emaSepNorm * 15.0
trendScore = int(math.round(f_clamp(trendScoreFloat, 0.0, 100.0)))
directionScore = (emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0) + (structureBias > 0.10 ? 1 : structureBias < -0.10 ? -1 : 0) + (close > emaSlow ? 1 : close < emaSlow ? -1 : 0)
trendState = trendScore < 35 or trendEr < 0.22 ? "Chop" : directionScore > 0 ? "Bullish" : directionScore < 0 ? "Bearish" : "Chop"
trendCol = trendState == "Bullish" ? cUp : trendState == "Bearish" ? cDown : cCyan

// alerts
orBreakUp = openingRangeReady and ta.crossover(close, openingRangeHigh)
orBreakDn = openingRangeReady and ta.crossunder(close, openingRangeLow)
currentPocPriceLive = currentReady and not na(currentPocIndex) ? currentSessionLow + currentStep * (currentPocIndex + 0.5) : na
pocTouch = not na(currentPocPriceLive) and high >= currentPocPriceLive and low <= currentPocPriceLive

if alertOrBreakout and orBreakUp
    alert("Opening Range breakout UP on " + syminfo.ticker + " (" + f_fmt0(close) + ")", alert.freq_once_per_bar_close)
if alertOrBreakout and orBreakDn
    alert("Opening Range breakout DOWN on " + syminfo.ticker + " (" + f_fmt0(close) + ")", alert.freq_once_per_bar_close)
if alertVolumeImpulse and impulseUp
    alert("Buy volume impulse on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertVolumeImpulse and impulseDown
    alert("Sell volume impulse on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertPocTouch and pocTouch
    alert("Price tagged current POC on " + syminfo.ticker + " (" + f_fmt0(currentPocPriceLive) + ")", alert.freq_once_per_bar)

// visuals
if barstate.islast
    f_clear_boxes(profileBoxes)
    f_clear_boxes(nodeBoxes)
    f_clear_labels(nodeLabels)

    int anchor = bar_index + profileOffset

    if previousReady and showPreviousProfile and previousMaxVol > 0
        for r = 0 to profileRows - 1
            float rowLow = previousSessionLow + previousStep * r
            float rowHigh = rowLow + previousStep
            float rv = array.get(previousRows, r)
            int rowWidth = int(math.max(1, math.round(profileWidth * rv / previousMaxVol)))
            color rowColor = color.new(cPreviousProfile, 88)
            box b = box.new(left = anchor, top = rowHigh, right = anchor + rowWidth, bottom = rowLow, xloc = xloc.bar_index, bgcolor = rowColor, border_color = color.new(cPreviousProfile, 100))
            array.push(profileBoxes, b)

    if currentReady and showCurrentProfile and currentMaxVol > 0
        for r = 0 to profileRows - 1
            float rowLow = currentSessionLow + currentStep * r
            float rowHigh = rowLow + currentStep
            float rv = array.get(currentRows, r)
            int rowWidth = int(math.max(1, math.round(profileWidth * rv / currentMaxVol)))
            color rowColor = color.new(cCurrentProfile, 82)
            box b = box.new(left = anchor, top = rowHigh, right = anchor + rowWidth, bottom = rowLow, xloc = xloc.bar_index, bgcolor = rowColor, border_color = color.new(cCurrentProfile, 100))
            array.push(profileBoxes, b)

    if currentReady
        int liveZoneLeft = currentSessionStartBar
        int liveZoneRight = bar_index + nodeExtendBars
        int liveLabelX = liveZoneRight + 2

        if array.size(currentHvnRows) > 0
            for i = 0 to array.size(currentHvnRows) - 1
                int rowIdx = array.get(currentHvnRows, i)
                float zLow = currentSessionLow + currentStep * rowIdx
                float zHigh = zLow + currentStep
                float zMid = currentSessionLow + currentStep * (rowIdx + 0.5)
                int typ = rowIdx == currentPocIndex ? 1 : 2
                color zoneColor = f_type_color(typ)
                box outer = box.new(left = liveZoneLeft, top = zHigh, right = liveZoneRight, bottom = zLow, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, typ == 1 ? 90 : 94), border_color = color.new(zoneColor, typ == 1 ? 45 : 68), border_width = typ == 1 ? 2 : 1)
                array.push(nodeBoxes, outer)
                if showNodeLabels
                    color nodeTextColor = typ == 1 ? color.rgb(12, 16, 22) : cWhite
                    label lb = label.new(liveLabelX, zMid, " LIVE " + f_type_text(typ) + " " + currentSessionDateText + " " + f_fmt0(zMid) + " ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(zoneColor, typ == 1 ? 10 : 22), textcolor = nodeTextColor, size = size.tiny)
                    array.push(nodeLabels, lb)

        if array.size(currentLvnRows) > 0
            for i = 0 to array.size(currentLvnRows) - 1
                int rowIdx = array.get(currentLvnRows, i)
                float zLow = currentSessionLow + currentStep * rowIdx
                float zHigh = zLow + currentStep
                float zMid = currentSessionLow + currentStep * (rowIdx + 0.5)
                int typ = 3
                color zoneColor = f_type_color(typ)
                box outer = box.new(left = liveZoneLeft, top = zHigh, right = liveZoneRight, bottom = zLow, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, 95), border_color = color.new(zoneColor, 72), border_width = 1)
                array.push(nodeBoxes, outer)
                if showNodeLabels
                    label lb = label.new(liveLabelX, zMid, " LIVE LVN " + currentSessionDateText + " " + f_fmt0(zMid) + " ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(zoneColor, 24), textcolor = cWhite, size = size.tiny)
                    array.push(nodeLabels, lb)

    if previousReady
        int priorZoneLeft = previousSessionStartBar
        int priorZoneRight = bar_index + nodeExtendBars
        int priorLabelX = priorZoneRight + 2

        if array.size(previousHvnRows) > 0
            for i = 0 to array.size(previousHvnRows) - 1
                int rowIdx = array.get(previousHvnRows, i)
                float zLow = previousSessionLow + previousStep * rowIdx
                float zHigh = zLow + previousStep
                float zMid = previousSessionLow + previousStep * (rowIdx + 0.5)
                int typ = rowIdx == previousPocIndex ? 1 : 2
                color zoneColor = f_type_color(typ)
                box outer = box.new(left = priorZoneLeft, top = zHigh, right = priorZoneRight, bottom = zLow, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, typ == 1 ? 95 : 97), border_color = color.new(zoneColor, typ == 1 ? 72 : 84), border_width = typ == 1 ? 2 : 1)
                array.push(nodeBoxes, outer)
                if showNodeLabels
                    color nodeTextColor = typ == 1 ? color.rgb(12, 16, 22) : cWhite
                    label lb = label.new(priorLabelX, zMid, " PRIOR " + f_type_text(typ) + " " + previousSessionDateText + " " + f_fmt0(zMid) + " ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(zoneColor, typ == 1 ? 28 : 36), textcolor = nodeTextColor, size = size.tiny)
                    array.push(nodeLabels, lb)

        if array.size(previousLvnRows) > 0
            for i = 0 to array.size(previousLvnRows) - 1
                int rowIdx = array.get(previousLvnRows, i)
                float zLow = previousSessionLow + previousStep * rowIdx
                float zHigh = zLow + previousStep
                float zMid = previousSessionLow + previousStep * (rowIdx + 0.5)
                int typ = 3
                color zoneColor = f_type_color(typ)
                box outer = box.new(left = priorZoneLeft, top = zHigh, right = priorZoneRight, bottom = zLow, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, 98), border_color = color.new(zoneColor, 88), border_width = 1)
                array.push(nodeBoxes, outer)
                if showNodeLabels
                    label lb = label.new(priorLabelX, zMid, " PRIOR LVN " + previousSessionDateText + " " + f_fmt0(zMid) + " ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(zoneColor, 42), textcolor = cWhite, size = size.tiny)
                    array.push(nodeLabels, lb)

// hud
var table hud = table.new(position.top_right, 2, 11, bgcolor = color.new(cPanel, 4), frame_color = color.new(cCyan, 42), frame_width = 1, border_color = color.new(cGrid, 58), border_width = 1)
var bool hudMerged = false

if barstate.islast and showHud
    if not hudMerged
        table.merge_cells(hud, 0, 0, 1, 0)
        hudMerged := true

    string sessionState = inOpeningRange ? "Building Opening Range" : openingRangeReady ? close > openingRangeHigh ? "Above Opening Range" : close < openingRangeLow ? "Below Opening Range" : "Inside Opening Range" : "Pre-Range"
    color stateColor = sessionState == "Above Opening Range" ? cUp : sessionState == "Below Opening Range" ? cDown : sessionState == "Inside Opening Range" ? cCyan : cMuted
    string biasText = na(priorUpDist) and na(priorDnDist) ? "No Prior Magnet" : na(priorDnDist) ? "Upside Magnet" : na(priorUpDist) ? "Downside Magnet" : priorUpDist < priorDnDist ? "Upside Closer" : priorDnDist < priorUpDist ? "Downside Closer" : "Balanced"
    color biasColor = biasText == "Upside Magnet" or biasText == "Upside Closer" ? cUp : biasText == "Downside Magnet" or biasText == "Downside Closer" ? cDown : cCyan
    float currentPocPrice = currentReady and not na(currentPocIndex) ? currentSessionLow + currentStep * (currentPocIndex + 0.5) : na
    string currentHvnText = currentReady ? f_node_list(currentHvnRows, currentSessionLow, currentStep, currentPocIndex, true) : "n/a"
    string currentLvnText = currentReady ? f_node_list(currentLvnRows, currentSessionLow, currentStep, currentPocIndex, false) : "n/a"
    color topAccentBg = color.new(cWhite, 90)
    color rowBg = color.new(cPanel, 0)
    color altRowBg = color.new(cPanel2, 6)

    table.cell(hud, 0, 0, "Opening Range Profile Terminal", height = 2.3, text_color = cCyan, text_halign = text.align_center, text_size = size.normal, bgcolor = color.new(cBg, 0))

    table.cell(hud, 0, 1, "State", height = 2.45, text_color = cCyan, text_halign = text.align_left, text_size = size.large, bgcolor = topAccentBg)
    table.cell(hud, 1, 1, sessionState, height = 2.45, text_color = stateColor, text_halign = text.align_right, text_size = size.large, bgcolor = topAccentBg)

    table.cell(hud, 0, 2, "Trend", height = 2.45, text_color = cCyan, text_halign = text.align_left, text_size = size.large, bgcolor = topAccentBg)
    table.cell(hud, 1, 2, trendState + " • " + str.tostring(trendScore) + "/100", height = 2.45, text_color = trendCol, text_halign = text.align_right, text_size = size.large, bgcolor = topAccentBg)

    table.cell(hud, 0, 3, "Previous Day", height = 2.45, text_color = cCyan, text_halign = text.align_left, text_size = size.large, bgcolor = topAccentBg)
    table.cell(hud, 1, 3, previousDayType, height = 2.45, text_color = previousDayType == "Strong Uptrend" or previousDayType == "Uptrend" ? cUp : previousDayType == "Strong Downtrend" or previousDayType == "Downtrend" ? cDown : cCyan, text_halign = text.align_right, text_size = size.large, bgcolor = topAccentBg)

    table.cell(hud, 0, 4, "Magnet Bias", height = 2.05, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = rowBg)
    table.cell(hud, 1, 4, biasText, height = 2.05, text_color = biasColor, text_halign = text.align_right, text_size = size.normal, bgcolor = rowBg)

    table.cell(hud, 0, 5, "Range Size", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = altRowBg)
    table.cell(hud, 1, 5, f_fmt2(openingRangeSize), height = 1.95, text_color = cWhite, text_halign = text.align_right, text_size = size.normal, bgcolor = altRowBg)

    table.cell(hud, 0, 6, "POC", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = rowBg)
    table.cell(hud, 1, 6, f_fmt0(currentPocPrice), height = 1.95, text_color = cCyan, text_halign = text.align_right, text_size = size.normal, bgcolor = rowBg)

    table.cell(hud, 0, 7, "HVN", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = altRowBg)
    table.cell(hud, 1, 7, currentHvnText, height = 1.95, text_color = cBlue, text_halign = text.align_right, text_size = size.normal, bgcolor = altRowBg)

    table.cell(hud, 0, 8, "LVN", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = rowBg)
    table.cell(hud, 1, 8, currentLvnText, height = 1.95, text_color = cViolet, text_halign = text.align_right, text_size = size.normal, bgcolor = rowBg)

    table.cell(hud, 0, 9, "Buy Impulses", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = altRowBg)
    table.cell(hud, 1, 9, str.tostring(sessionPositiveImpulses), height = 1.95, text_color = cUp, text_halign = text.align_right, text_size = size.normal, bgcolor = altRowBg)

    table.cell(hud, 0, 10, "Sell Impulses", height = 1.95, text_color = cMuted, text_halign = text.align_left, text_size = size.normal, bgcolor = rowBg)
    table.cell(hud, 1, 10, str.tostring(sessionNegativeImpulses), height = 1.95, text_color = cDown, text_halign = text.align_right, text_size = size.normal, bgcolor = rowBg)

// pressure meter
var table meter = table.new(position.bottom_right, 12, 4, bgcolor = color.new(cPanel, 4), frame_color = color.new(cCyan, 28), frame_width = 1, border_color = color.new(cGrid, 42), border_width = 1)
var bool meterMerged = false

if barstate.islast and showPressureMeter
    if not meterMerged
        table.merge_cells(meter, 0, 0, 11, 0)
        table.merge_cells(meter, 0, 2, 11, 2)
        table.merge_cells(meter, 0, 3, 11, 3)
        meterMerged := true

    float ratio = (pressureClamped + 3.0) / 6.0
    int needlePos = int(math.round(f_clamp(ratio, 0.0, 1.0) * 11.0))

    table.cell(meter, 0, 0, "Pressure Meter | " + f_fmt2(pressureClamped) + "σ | Session Vol Z " + f_fmt2(sessionVolZ), text_color = cCyan, text_size = size.normal, bgcolor = color.new(cBg, 0))

    for seg = 0 to 11
        float segRatio = seg / 11.0
        color segColor = color.from_gradient(segRatio, 0.0, 1.0, cDown, cUp)
        bool isFilled = pressureClamped >= 0 ? seg <= needlePos and seg >= 6 : seg >= needlePos and seg <= 5
        bool isNeedle = seg == needlePos
        color cellBg = isFilled ? color.new(segColor, 8) : color.new(segColor, 76)
        string symbol = isNeedle ? "◆" : "▰"
        if seg == 0
            symbol := isNeedle ? "◆ -3σ" : "-3σ"
        if seg == 6
            symbol := isNeedle ? "◆ 0" : "0"
        if seg == 11
            symbol := isNeedle ? "◆ +3σ" : "+3σ"
        table.cell(meter, seg, 1, symbol, text_color = isNeedle ? cWhite : segColor, text_size = size.normal, bgcolor = cellBg)

    string pressureFooter = pressureClamped > 1.5 ? "Strong Positive Pressure" : pressureClamped > 0.35 ? "Positive Pressure" : pressureClamped < -1.5 ? "Strong Negative Pressure" : pressureClamped < -0.35 ? "Negative Pressure" : "Balanced Pressure"
    table.cell(meter, 0, 2, pressureFooter, text_color = pressureClamped > 0 ? cUp : pressureClamped < 0 ? cDown : cCyan, text_size = size.normal, bgcolor = color.new(cGlass, 0))
    table.cell(meter, 0, 3, "Session stdv based impulse model", text_color = cMuted, text_size = size.normal, bgcolor = color.new(cBg, 0))

// Opening Range labels are redrawn last so they stay above the NY Open Window box and profile drawings.
if barstate.islast
    if not na(openingRangeHighLine)
        line.delete(openingRangeHighLine)
        openingRangeHighLine := na
    if not na(openingRangeLowLine)
        line.delete(openingRangeLowLine)
        openingRangeLowLine := na
    if not na(openingRangeHighLabel)
        label.delete(openingRangeHighLabel)
        openingRangeHighLabel := na
    if not na(openingRangeLowLabel)
        label.delete(openingRangeLowLabel)
        openingRangeLowLabel := na
    if not na(openingRangeTextLabel)
        label.delete(openingRangeTextLabel)
        openingRangeTextLabel := na
    if showOpeningRangeLabels and openingRangeReady
        int orLevelStartValue = openingRangeStartBar
        int orLevelRightValue = na(openingRangeRightBar) ? bar_index : openingRangeRightBar
        int orLevelMidValue = int(math.round((orLevelStartValue + orLevelRightValue) / 2.0))
        float orMidPriceValue = math.avg(openingRangeHigh, openingRangeLow)
        color orHighLineColorValue = color.rgb(226, 92, 92)
        color orLowLineColorValue = color.rgb(62, 191, 122)
        color orTextColorValue = color.rgb(0, 240, 255)
        openingRangeHighLine := line.new(orLevelStartValue, openingRangeHigh, orLevelRightValue, openingRangeHigh, xloc = xloc.bar_index, extend = extend.none, color = color.new(orHighLineColorValue, 0), width = 2, style = line.style_solid)
        openingRangeLowLine := line.new(orLevelStartValue, openingRangeLow, orLevelRightValue, openingRangeLow, xloc = xloc.bar_index, extend = extend.none, color = color.new(orLowLineColorValue, 0), width = 2, style = line.style_solid)
        openingRangeHighLabel := label.new(orLevelMidValue, openingRangeHigh, " OR High (" + f_fmt0(openingRangeHigh) + ") ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(orHighLineColorValue, 0), textcolor = color.rgb(255, 255, 255), size = size.tiny)
        openingRangeLowLabel := label.new(orLevelMidValue, openingRangeLow, " OR Low (" + f_fmt0(openingRangeLow) + ") ", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(orLowLineColorValue, 0), textcolor = color.rgb(255, 255, 255), size = size.tiny)
        openingRangeTextLabel := label.new(orLevelMidValue, orMidPriceValue, "OPENING RANGE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, color = color.new(color.white, 100), textcolor = color.new(orTextColorValue, 0), size = size.huge, text_formatting = text.format_bold)
````
