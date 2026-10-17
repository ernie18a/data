# JPM Collar Levels - SPX

- url: https://www.tradingview.com/script/IwGynP3T-JPM-Collar-Levels-SPX/
- type: indicator
- pine_id: PUB;d8fd2adee8e84770989bfbec3bcca32c
- version: 2.0

## Description

JPM Collar Levels - SPX plots manually updated quarterly JPM collar reference levels for the S&P 500 Index.

The indicator is designed for traders and analysts who want a clean way to keep the main JPM collar levels visible on the SPX chart without turning them into signals, targets, or magic lines.

The script currently plots three reference levels for each loaded quarterly collar:

- Short Call
- Long Put
- Short Put

These levels are hardcoded and updated manually after each quarterly reset.

Important convention:

The reported quarter is displayed during the following active quarter.

For example, Q2 2026 collar levels are active from July 1, 2026 to October 1, 2026.

This matters because the collar is not meant to be read as a normal calendar-quarter label. The levels are reported after a reset and then used as reference levels during the next active period.

What this indicator does:

- Plots JPM collar levels directly on SPX.
- Shows the active quarter more clearly than older quarters.
- Allows users to display only the current active quarter, the last year, or all loaded historical quarters.
- Optionally shows distance from current SPX price to each active level in points, percent, or both.
- Includes alerts for first touch per quarter or every touch.
- Shows a warning on common S&P 500 proxies such as SPY, ES, US500, or SPX500.
- Stays silent on unrelated symbols.
- Shows an update warning only after the latest loaded collar period has ended.

What this indicator does not do:

- It does not generate buy or sell signals.
- It does not predict price direction.
- It does not define support or resistance.
- It does not claim that price must react at these levels.
- It does not backtest a strategy.
- It does not estimate probabilities.

These are reference levels only.

I use them as market structure context, not as trade instructions. A level can matter because large collars and option structures may become part of how traders frame risk, hedging, and positioning. That still does not mean price has to respect the level. Markets are not polite.

Recommended use:

Use this indicator to keep quarterly JPM collar reference levels visible while analyzing SPX price action, volatility, positioning, and broader market context.

The cleanest default view is “Last year”, which shows the active quarter plus recent historical context. Users who only want the current structure can switch to “Current only”.

Distance labels are optional and turned off by default to keep the chart clean.

Symbol note:

This script is designed for SPX. It intentionally avoids plotting the levels on S&P 500 proxies such as SPY, ES, US500, SPX500, VOO, or IVV, because those instruments trade at different prices and the raw SPX collar levels do not map directly without adjustment.

Manual update note:

The levels are hardcoded. They must be updated manually after each quarterly JPM collar reset. If the latest loaded period has ended, the script will show an update warning.

Settings section
Main settings:

Visible history

- Current only: shows only the active collar period.
- Last year: shows the active period plus recent historical quarters.
- All loaded: shows all hardcoded quarters available in the script.

Distance display

- Off: clean labels only.
- Percent: shows distance from current SPX price to the active levels in percent.
- Points: shows distance in SPX points.
- Points + Percent: shows both.

Label contrast

- Soft: cleaner chart, lower visual noise.
- Normal: easier to read.
- Strong: highest label visibility.

Alerts

- First touch per quarter: each level can trigger once during the active quarter.
- Every touch: alerts can trigger again when price touches a level again.

Release notes
Initial public version.

Includes manually updated JPM quarterly collar reference levels for SPX, with configurable visible history, optional distance labels, SPX-only symbol handling, and alert modes for level touches.

The script is open-source and intended as a clean reference tool, not a trading signal.

## Source Code

````pine
//@version=6
indicator("JPM Collar Levels - SPX", shorttitle="JPM Collar SPX", overlay=true, max_lines_count=200, max_labels_count=200)

// Quarterly JPMorgan hedged-equity SPX collar references; not trading signals.
// Quarter identifier = quarter when collar was reported/rolled.
// Display interval is the FOLLOWING calendar quarter [start, end).
// SPX only: no automatic conversion for SPY, ES or CFD proxies.
// Q3 2026 levels sourced from Sep 30, 2026 public options-flow reporting;
// independently corroborated, but not confirmed here against primary fund filings.

groupDisplay = "Display"
historyMode = input.string("Last year", "Visible history", options=["Current only", "Last year", "All loaded"], group=groupDisplay, tooltip="Current only: active quarter. Last year: latest available quarter and previous three. All loaded: all stored quarters.")
showLabels = input.bool(true, "Show labels", group=groupDisplay)
distanceDisplay = input.string("Off", "Distance display", options=["Off", "Percent", "Points", "Points + Percent"], group=groupDisplay)
showSymbolWarning = input.bool(true, "Show SPX-only warning", group=groupDisplay)

groupStyle = "Style"
baseColor = input.color(color.gray, "Line color", group=groupStyle)
currentTransparency = input.int(35, "Current quarter transparency", minval=0, maxval=95, group=groupStyle)
previousTransparency = input.int(65, "Previous quarters transparency", minval=0, maxval=95, group=groupStyle)
lineWidth = input.int(1, "Base line width", minval=1, maxval=3, group=groupStyle)
currentWidthBoost = input.bool(true, "Current quarter width boost", group=groupStyle)
lineStyleInput = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)
labelContrast = input.string("Soft", "Label contrast", options=["Soft", "Normal", "Strong"], group=groupStyle)

groupAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable alerts", group=groupAlerts)
alertMode = input.string("First touch per quarter", "Alert mode", options=["First touch per quarter", "Every touch"], group=groupAlerts)
alertShortCall = input.bool(true, "Short Call", group=groupAlerts)
alertLongPut = input.bool(true, "Long Put", group=groupAlerts)
alertShortPut = input.bool(true, "Short Put", group=groupAlerts)

string tickerUpper = str.upper(syminfo.ticker)
string tickerIdUpper = str.upper(syminfo.tickerid)
bool isSPX = tickerUpper == "SPX"
bool isSPXProxy = not isSPX and (str.contains(tickerUpper, "SPX") or str.contains(tickerUpper, "SPY") or str.contains(tickerUpper, "VOO") or str.contains(tickerUpper, "IVV") or str.contains(tickerUpper, "ES1!") or str.contains(tickerUpper, "MES1!") or str.contains(tickerUpper, "US500") or str.contains(tickerUpper, "SP500") or str.contains(tickerUpper, "SPCFD") or str.contains(tickerIdUpper, "SPX500") or str.contains(tickerIdUpper, "US500") or str.contains(tickerIdUpper, "SP500"))

lineStyle = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid
bool firstTouchOnly = alertMode == "First touch per quarter"
float warningAtr = ta.atr(14)
float warningY = high + math.max(nz(warningAtr, close * 0.015) * 2.0, close * 0.015)

// Source quarters Q2 2025 through Q3 2026 (six quarterly collars).
// Q2 2025: active Jul 1 – Oct 1, 2025.
// Q3 2025: active Oct 1, 2025 – Jan 1, 2026.
// Q4 2025: active Jan 1 – Apr 1, 2026.
// Q1 2026: active Apr 1 – Jul 1, 2026.
// Q2 2026: active Jul 1 – Oct 1, 2026.
// Q3 2026: active Oct 1, 2026 – Jan 1, 2027; options expire Dec 31, 2026.
var array<int> quarterStartTimes = array.from(timestamp("America/New_York", 2025, 7, 1, 0, 0), timestamp("America/New_York", 2025, 10, 1, 0, 0), timestamp("America/New_York", 2026, 1, 1, 0, 0), timestamp("America/New_York", 2026, 4, 1, 0, 0), timestamp("America/New_York", 2026, 7, 1, 0, 0), timestamp("America/New_York", 2026, 10, 1, 0, 0))
var array<int> quarterEndTimes = array.from(timestamp("America/New_York", 2025, 10, 1, 0, 0), timestamp("America/New_York", 2026, 1, 1, 0, 0), timestamp("America/New_York", 2026, 4, 1, 0, 0), timestamp("America/New_York", 2026, 7, 1, 0, 0), timestamp("America/New_York", 2026, 10, 1, 0, 0), timestamp("America/New_York", 2027, 1, 1, 0, 0))
var array<float> shortCallLevels = array.from(6505.0, 6955.0, 7155.0, 6865.0, 7890.0, 8105.0)
var array<float> longPutLevels = array.from(5870.0, 6290.0, 6575.0, 6180.0, 7090.0, 7290.0)
var array<float> shortPutLevels = array.from(4955.0, 5310.0, 5470.0, 5210.0, 5990.0, 6150.0)
string lastLoadedEndText = "Jan 1, 2027"

int activeIndex = na
for i = 0 to array.size(quarterStartTimes) - 1
    int startTime = array.get(quarterStartTimes, i)
    int endTime = array.get(quarterEndTimes, i)
    if time >= startTime and time < endTime
        activeIndex := i

float activeShortCallLevel = na
float activeLongPutLevel = na
float activeShortPutLevel = na
if not na(activeIndex)
    activeShortCallLevel := array.get(shortCallLevels, activeIndex)
    activeLongPutLevel := array.get(longPutLevels, activeIndex)
    activeShortPutLevel := array.get(shortPutLevels, activeIndex)

// Preserve one alert per level per quarter (or every touch, user-selectable).
var int previousActiveIndex = na
var bool shortCallTouched = false
var bool longPutTouched = false
var bool shortPutTouched = false
bool wasInactiveNowActive = not na(activeIndex) and na(previousActiveIndex)
bool wasActiveNowInactive = na(activeIndex) and not na(previousActiveIndex)
bool changedActiveQuarter = not na(activeIndex) and not na(previousActiveIndex) and activeIndex != previousActiveIndex
if wasInactiveNowActive or wasActiveNowInactive or changedActiveQuarter
    shortCallTouched := false
    longPutTouched := false
    shortPutTouched := false
    previousActiveIndex := activeIndex

bool canAlert = isSPX and enableAlerts
bool touchShortCall = canAlert and alertShortCall and not na(activeShortCallLevel) and high >= activeShortCallLevel and (not firstTouchOnly or not shortCallTouched)
bool touchLongPut = canAlert and alertLongPut and not na(activeLongPutLevel) and low <= activeLongPutLevel and (not firstTouchOnly or not longPutTouched)
bool touchShortPut = canAlert and alertShortPut and not na(activeShortPutLevel) and low <= activeShortPutLevel and (not firstTouchOnly or not shortPutTouched)
bool touchAnyLevel = touchShortCall or touchLongPut or touchShortPut
if touchShortCall
    shortCallTouched := true
if touchLongPut
    longPutTouched := true
if touchShortPut
    shortPutTouched := true
alertcondition(touchShortCall, "Short Call touched", "JPM collar Short Call level touched.")
alertcondition(touchLongPut, "Long Put touched", "JPM collar Long Put level touched.")
alertcondition(touchShortPut, "Short Put touched", "JPM collar Short Put level touched.")
alertcondition(touchAnyLevel, "Any JPM level touched", "A JPM collar reference level was touched.")

var array<line> collarLines = array.new_line()
var array<label> collarLabels = array.new_label()

f_clear_lines(array<line> lines) =>
    while array.size(lines) > 0
        line oldLine = array.shift(lines)
        line.delete(oldLine)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_label_transparency(bool isCurrent) =>
    int result = 45
    if labelContrast == "Soft"
        result := isCurrent ? 10 : 45
    else if labelContrast == "Normal"
        result := isCurrent ? 0 : 30
    else
        result := isCurrent ? 0 : 10
    result

f_distance_text(float level, bool includeDistance) =>
    string result = ""
    if includeDistance and close != 0
        float distancePts = level - close
        float distancePct = distancePts / close * 100.0
        string ptsSign = distancePts > 0 ? "+" : ""
        string pctSign = distancePct > 0 ? "+" : ""
        string pointsText = ptsSign + str.tostring(distancePts, "#") + " pts"
        string percentText = pctSign + str.tostring(distancePct, "#.##") + "%"
        if distanceDisplay == "Percent"
            result := " (" + percentText + ")"
        else if distanceDisplay == "Points"
            result := " (" + pointsText + ")"
        else if distanceDisplay == "Points + Percent"
            result := " (" + pointsText + " / " + percentText + ")"
    result

f_draw_level(int x1, int x2, float y, string labelText, color levelColor, color textColor, bool includeDistance, int levelLineWidth) =>
    line newLine = line.new(x1=x1, y1=y, x2=x2, y2=y, xloc=xloc.bar_time, extend=extend.none, color=levelColor, width=levelLineWidth, style=lineStyle)
    array.push(collarLines, newLine)
    if showLabels
        int labelX = x1 + int(math.round((x2 - x1) / 2.0))
        string fullLabel = labelText + " " + str.tostring(y, "#") + f_distance_text(y, includeDistance)
        label newLabel = label.new(x=labelX, y=y, text=fullLabel, xloc=xloc.bar_time, style=label.style_none, textcolor=textColor, color=color.new(color.white, 100), size=size.tiny)
        array.push(collarLabels, newLabel)

f_draw_quarter(int quarterIndex, int startTime, int endTime, float shortCall, float longPut, float shortPut) =>
    bool isCurrent = quarterIndex == activeIndex
    bool includeDistance = distanceDisplay != "Off" and isCurrent
    int transparency = isCurrent ? currentTransparency : previousTransparency
    int textTransparency = f_label_transparency(isCurrent)
    int levelLineWidth = currentWidthBoost and isCurrent ? math.min(lineWidth + 1, 4) : lineWidth
    color levelColor = color.new(baseColor, transparency)
    color textColor = color.new(baseColor, textTransparency)
    f_draw_level(startTime, endTime, shortCall, "Short Call", levelColor, textColor, includeDistance, levelLineWidth)
    f_draw_level(startTime, endTime, longPut, "Long Put", levelColor, textColor, includeDistance, levelLineWidth)
    f_draw_level(startTime, endTime, shortPut, "Short Put", levelColor, textColor, includeDistance, levelLineWidth)

if barstate.islast
    f_clear_lines(collarLines)
    f_clear_labels(collarLabels)
    int lastKnownIndex = na
    for i = 0 to array.size(quarterStartTimes) - 1
        int startTime = array.get(quarterStartTimes, i)
        if time >= startTime
            lastKnownIndex := i
    int lastLoadedIndex = array.size(quarterEndTimes) - 1
    int lastLoadedEnd = array.get(quarterEndTimes, lastLoadedIndex)
    bool dataEnded = time >= lastLoadedEnd
    if isSPX
        int firstVisibleIndex = na
        int lastVisibleIndex = na
        if historyMode == "Current only"
            if not na(activeIndex)
                firstVisibleIndex := activeIndex
                lastVisibleIndex := activeIndex
        else if historyMode == "Last year"
            if not na(lastKnownIndex)
                firstVisibleIndex := math.max(0, lastKnownIndex - 3)
                lastVisibleIndex := lastKnownIndex
        else
            if not na(lastKnownIndex)
                firstVisibleIndex := 0
                lastVisibleIndex := lastKnownIndex
        if not na(firstVisibleIndex) and not na(lastVisibleIndex) and firstVisibleIndex <= lastVisibleIndex
            for i = firstVisibleIndex to lastVisibleIndex
                f_draw_quarter(i, array.get(quarterStartTimes, i), array.get(quarterEndTimes, i), array.get(shortCallLevels, i), array.get(longPutLevels, i), array.get(shortPutLevels, i))
        if dataEnded
            label updateLabel = label.new(x=time, y=warningY, text="JPM collar data ended\n" + lastLoadedEndText + ". Update needed.", xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=color.new(color.orange, 0), size=size.small)
            array.push(collarLabels, updateLabel)
    else if showSymbolWarning and isSPXProxy
        label proxyWarningLabel = label.new(x=time, y=warningY, text="JPM levels:\nDesigned for SPX only.\nSwitch to SPX.", xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, color=color.new(color.orange, 0), size=size.small)
        array.push(collarLabels, proxyWarningLabel)
````
