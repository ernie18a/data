# Primitive Charts - Session Candles

- url: https://www.tradingview.com/script/NYvqvVk1-Primitive-Charts-Session-Candles/
- type: indicator
- pine_id: PUB;6fc0e6d16bf34b2ebd9458fa5a7063b3
- version: 1.0

## Description

Primitive Charts - Session Candles brings the trading day's sessions into one view. Each selected time window becomes a single candle beside the chart, showing its open, high, low, and close on the instrument's price scale.

Read London's range and closing position at a glance. Compare the Opening Range with the Initial Balance. Follow New York as its candle develops. The right-side display summarizes observed prices from each session.

Each candle begins at its session's opening time, develops as price data arrives, and freezes when the session closes. The body connects the open and close; the wicks show the session's extremes. While a session is forming, the latest observed price acts as its close. White up candles and black down candles are the default.

Six session windows are included:

- Asian: 20:00–00:00
- London: 02:00–05:00
- Premarket: 05:00–09:30
- Opening Range: 09:30–10:00
- Initial Balance: 09:30–10:30
- New York: 09:30–16:00

All windows use New York time and follow daylight-saving changes, regardless of the chart's displayed timezone. Each session calculates independently, so overlapping windows such as Opening Range, Initial Balance, and New York can develop together.

Enable the sessions you want to see. Each slot has an editable name and time window, including overnight windows. You can also paste a pcr-1 roster code to load session definitions, then override the names or time windows separately.

The display keeps up to one candle per enabled session. By default, it follows the current trading day, with an 18:00 New York display reset that groups the prior evening's Asian session with the following London and New York sessions. Completed candles from the earlier trading day clear at that reset; a custom session crossing 18:00 stays visible through its own window.

“Show candles from the previous day” keeps each session's most recent available candle visible until its next occurrence begins. The new candle replaces it in the same slot.

“Trace Candle Open” connects each visible forming candle's open to the chart bar containing its session start, when its data and opening anchor are available. When no visible session is forming, the trace follows the most recently completed visible candle with complete data. This provides a reference between the session summary and the underlying chart.

Display settings include:

- Minimum and maximum chart timeframes, with 1 minute and 4 hours as the defaults.
- Distance from the chart, space between sessions, and candle width.
- Shared up/down colors for bodies, borders, and wicks.
- Optional session names, times, and dates, with text size, color, and label position controls.

Session names are shown by default; times and dates are off. Names follow each candle's own wick. Hover a visible label to inspect OHLC, session status, and source timestamps.

Use standard time-based charts from 1 minute through 4 hours, with the required session hours included. Session prices are measured from one-minute data across that range. Minimum and maximum timeframe settings control visibility. Leave enough space to the right of the chart for the candles.

Available history depends on the symbol, feed, and TradingView plan. Missing session minutes or boundaries produce an “Incomplete” label and withhold the candle. Custom windows spanning a market closure can also be marked incomplete. Source timestamps identify minute bars; open traces are omitted when their starting bar is more than 4,999 chart bars back.

## Source Code

````pine
//@version=6
// Primitive Charts - Session Candles
// Draft 0.3.2 / SC-05 / 2026-09-25. Candle display only; no raid engine or statistics.
// Session OHLC is measured from traded one-minute bars. End boundaries are exclusive.
indicator("Primitive Charts - Session Candles", overlay=true, max_boxes_count=10, max_lines_count=30, max_labels_count=30)

const string SC_G_GENERAL = "General"
const string SC_G_SESSIONS = "Sessions (New York time)"
const string SC_G_LAYOUT = "Layout"
const string SC_G_COLORS = "Candle Colors"
const string SC_G_LABELS = "Labels"

scMinTimeframe = input.timeframe("1", "Minimum timeframe", options=["1","2","3","5","10","15","30","45","60","120","180","240"], group=SC_G_GENERAL, tooltip="Show candles on this chart timeframe and higher, up to Maximum timeframe. Both limits are inclusive. Session prices always use one-minute data.", display=display.none)
scMaxTimeframe = input.timeframe("240", "Maximum timeframe", options=["1","2","3","5","10","15","30","45","60","120","180","240"], group=SC_G_GENERAL, tooltip="Show candles on this chart timeframe and lower, down to Minimum timeframe. Outside the selected range, candles, labels, and traces are hidden. Supported charts: standard candles, 1 minute to 4 hours.", display=display.none)

scImportRoster = input.bool(true, "Import roster code", group=SC_G_SESSIONS, tooltip="Paste a Primitive Charts pcr-1 roster code below to set session names and windows in New York time, with daylight-saving changes. Enable switches stay yours. An empty or invalid code uses the stored manual values; a nonempty invalid code shows a warning. Turn import off to ignore the code. Sessions also run on weekends when the symbol trades.", display=display.none)
scRosterCode = input.text_area("", "", group=SC_G_SESSIONS, active=scImportRoster, display=display.none)
scOverrideNames = input.bool(false, "❯ Override session names?", inline="scRosterModes", group=SC_G_SESSIONS, active=scImportRoster, tooltip="Use the six manual names while retaining the imported time windows. With an empty code, names are already editable.", display=display.none)
scManualWindows = input.bool(false, "❯ Manual time windows?", inline="scRosterModes", group=SC_G_SESSIONS, active=scImportRoster, tooltip="Use the six manual time windows while retaining imported names. With an empty code, windows are already editable. End times are exclusive; equal start and end times define a 24-hour window.", display=display.none)

scAsia = input.bool(true, "", inline="scSession1", group=SC_G_SESSIONS, tooltip="Each row has an enable switch, name, and session window. All windows use New York local time and share the Candle Colors settings. Each session shows one candle, frozen at its window end.", display=display.none)
scR1Name = input.string("Asian", "", inline="scSession1", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR1Session = input.session("2000-0000", "", inline="scSession1", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)

scLondon = input.bool(true, "", inline="scSession2", group=SC_G_SESSIONS, display=display.none)
scR2Name = input.string("London", "", inline="scSession2", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR2Session = input.session("0200-0500", "", inline="scSession2", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)

scPremarket = input.bool(true, "", inline="scSession3", group=SC_G_SESSIONS, display=display.none)
scR3Name = input.string("Premarket", "", inline="scSession3", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR3Session = input.session("0500-0930", "", inline="scSession3", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)

scOR = input.bool(true, "", inline="scSession4", group=SC_G_SESSIONS, display=display.none)
scR4Name = input.string("Opening Range", "", inline="scSession4", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR4Session = input.session("0930-1000", "", inline="scSession4", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)

scIB = input.bool(true, "", inline="scSession5", group=SC_G_SESSIONS, display=display.none)
scR5Name = input.string("Initial Balance", "", inline="scSession5", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR5Session = input.session("0930-1030", "", inline="scSession5", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)

scNY = input.bool(true, "", inline="scSession6", group=SC_G_SESSIONS, display=display.none)
scR6Name = input.string("New York", "", inline="scSession6", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scOverrideNames, display=display.none)
scR6Session = input.session("0930-1600", "", inline="scSession6", group=SC_G_SESSIONS, active=not scImportRoster or str.trim(scRosterCode) == "" or scManualWindows, display=display.none)
scShowPreviousDay = input.bool(false, "Show candles from the previous day", group=SC_G_SESSIONS, tooltip="Keep the most recent prior trading day's candle visible until a new occurrence begins. Still shows only one candle per session. Off: completed candles expire at the 18:00 New York reset; a session crossing that reset remains visible. Follows the latest chart data, including Bar Replay.", display=display.none)

scOffset = input.int(10, "Distance from chart (bars)", minval=2, maxval=60, group=SC_G_LAYOUT, tooltip="Distance from the latest chart bar to the first session candle. Increase your chart's right margin if candles are outside the visible area.", display=display.none)
scSessionGap = input.int(3, "Space between sessions (bars)", minval=2, maxval=20, group=SC_G_LAYOUT, tooltip="Empty horizontal space between candle bodies. Hidden sessions leave no gap. Horizontal measurements use chart bars, not pixels.", display=display.none)
scWidth = input.int(4, "Candle width (bars)", options=[2,4,6,8], group=SC_G_LAYOUT, tooltip="Body width shared by every session. Wicks stay centered; prices and candle heights are never rescaled.", display=display.none)
scTraceOpen = input.bool(false, "Trace Candle Open", group=SC_G_LAYOUT, tooltip="Trace the Open of forming candles. When none is forming, trace the latest completed candle. Lines begin at the chart bar containing the session open. Sources more than 4,999 chart bars back are omitted.", display=display.none)

// Unicode EN spaces keep the repeated Up/Down swatches approximately aligned in Pine's native panel.
scBodyUp = input.color(#ffffff, "Body: Up  ", inline="scBody", group=SC_G_COLORS, display=display.none)
scBodyDown = input.color(#000000, "Down", inline="scBody", group=SC_G_COLORS, tooltip="Up: Close > Open. Down: Close < Open. Shared across every session; picker transparency is respected.", display=display.none)
scBorderUp = input.color(#000000, "Border: Up", inline="scBorder", group=SC_G_COLORS, display=display.none)
scBorderDown = input.color(#000000, "Down", inline="scBorder", group=SC_G_COLORS, tooltip="Candle borders are one pixel wide. Flat candles use the Up border color.", display=display.none)
scWickUp = input.color(#000000, "Wick: Up  ", inline="scWick", group=SC_G_COLORS, display=display.none)
scWickDown = input.color(#000000, "Down", inline="scWick", group=SC_G_COLORS, tooltip="Candle wicks are one pixel wide. Flat candles use the Up wick color.", display=display.none)

scShowNames = input.bool(true, "Session name", group=SC_G_LABELS, display=display.none)
scShowTimes = input.bool(false, "Session time", group=SC_G_LABELS, tooltip="Show each session's effective New York time window, from its manual settings or imported roster. Can be displayed with or without the name.", display=display.none)
scShowDates = input.bool(false, "Session date", group=SC_G_LABELS, tooltip="Show the New York calendar date when the configured session began. Overnight windows use their opening date.", display=display.none)
scLabelPosition = input.string("Above", "Label position", options=["Above","Below"], group=SC_G_LABELS, active=scShowNames or scShowTimes or scShowDates, tooltip="Names and times sit just above each candle's top wick, or below its bottom wick. Dates appear beside the opposite wick. Labels follow the candle as it forms.", display=display.none)
scTextSize = input.string("Small", "Text size", options=["Tiny","Small","Normal","Large"], group=SC_G_LABELS, display=display.none)
scTextColor = input.color(#7e828a, "Text color", group=SC_G_LABELS, display=display.none)

// Session Candles roster resolver. Assemble after inputs and before the measurement core.
// Exports: scEffectiveNames, scEffectiveSessions, scEffectiveEnabled (six entries each),
// scCodeInvalid, and f_scClockMinutes(clock) -> [startMinute, endMinute].
// pcr-1 grammar follows the current OHLC Table parser; imported codes never change enable switches.

f_scValidHHMM(string value) =>
    bool ok = str.length(value) == 4
    if ok
        for i = 0 to 3
            ok := ok and not na(str.tonumber(str.substring(value, i, i + 1)))
    if ok
        int hh = int(str.tonumber(str.substring(value, 0, 2)))
        int mm = int(str.tonumber(str.substring(value, 2, 4)))
        ok := hh < 24 and mm < 60
    ok

// Validate the whole payload before applying any row. Extra fields remain portable;
// short codes leave later rows manual, and valid rows beyond six are safely unused.
f_scParsePCR(string code) =>
    var array<string> nameA = array.new<string>()
    var array<string> sessA = array.new<string>()
    var bool parsed = false
    var bool ok = false
    if not parsed
        nameA.clear()
        sessA.clear()
        string c = str.trim(code)
        if str.startswith(c, "pcr-1-")
            array<string> segs = str.split(str.substring(c, 6, str.length(c)), "|")
            bool good = segs.size() > 0
            for seg in segs
                array<string> fld = str.split(seg, "~")
                if fld.size() >= 3
                    string st = str.trim(fld.get(1))
                    string en = str.trim(fld.get(2))
                    if f_scValidHHMM(st) and f_scValidHHMM(en)
                        string nm = str.trim(str.replace_all(fld.get(0), "\n", " "))
                        nameA.push(str.length(nm) > 40 ? str.substring(nm, 0, 40) : nm)
                        sessA.push(st + "-" + en)
                    else
                        good := false
                else
                    good := false
            ok := good and nameA.size() > 0
        parsed := true
    [ok, nameA, sessA]

[scCodeOK, scImportedNames, scImportedSessions] = f_scParsePCR(scRosterCode)
bool scUseCode = scImportRoster and scCodeOK
bool scCodeInvalid = scImportRoster and str.trim(scRosterCode) != "" and not scCodeOK

f_scEffectiveName(int index, string manualName) =>
    scUseCode and not scOverrideNames and index < scImportedNames.size() ? scImportedNames.get(index) : manualName

f_scEffectiveSession(int index, string manualSession) =>
    scUseCode and not scManualWindows and index < scImportedSessions.size() ? scImportedSessions.get(index) : manualSession

// Stable input-derived arrays: any setting edit restarts Pine and rebuilds every resolved row.
var array<string> scEffectiveNames = array.from(f_scEffectiveName(0, scR1Name), f_scEffectiveName(1, scR2Name), f_scEffectiveName(2, scR3Name), f_scEffectiveName(3, scR4Name), f_scEffectiveName(4, scR5Name), f_scEffectiveName(5, scR6Name))
var array<string> scEffectiveSessions = array.from(f_scEffectiveSession(0, scR1Session), f_scEffectiveSession(1, scR2Session), f_scEffectiveSession(2, scR3Session), f_scEffectiveSession(3, scR4Session), f_scEffectiveSession(4, scR5Session), f_scEffectiveSession(5, scR6Session))
var array<bool> scEffectiveEnabled = array.from(scAsia, scLondon, scPremarket, scOR, scIB, scNY)

f_scClockMinutes(string clock) =>
    int startMinute = na
    int endMinute = na
    if str.length(clock) == 9 and str.substring(clock, 4, 5) == "-"
        string st = str.substring(clock, 0, 4)
        string en = str.substring(clock, 5, 9)
        if f_scValidHHMM(st) and f_scValidHHMM(en)
            startMinute := int(str.tonumber(str.substring(st, 0, 2))) * 60 + int(str.tonumber(str.substring(st, 2, 4)))
            endMinute := int(str.tonumber(str.substring(en, 0, 2))) * 60 + int(str.tonumber(str.substring(en, 2, 4)))
    [startMinute, endMinute]

// Session Candles measurement core. Assemble after the indicator declaration and inputs.
// Effective names, windows, and enable flags come from roster.pinepart.
// Measurement uses ordinary var rollback: replay all returned minutes on every execution.
const string SC_TIMEZONE = "America/New_York"
const int SC_MINUTE_MS = 60000

type SCCandle
    int sessionStart
    int sessionEnd
    float O = na
    float H = na
    float L = na
    float C = na
    int tH = na
    int tL = na
    int bO = na
    int bH = na
    int bL = na
    int bC = na
    int observedStart = na
    int observedEnd = na
    int lastSampleTime = na
    int lastSampleClose = na
    bool closed = false
    bool partial = false

type SCSession
    string name
    string clock
    int startMin
    int endMin
    bool enabled
    array<SCCandle> candles

f_scNewSession(string sessionName, string sessionClock, int startMinute, int endMinute, bool enabled) =>
    SCSession.new(sessionName, sessionClock, startMinute, endMinute, enabled, array.new<SCCandle>())

// Six independent ET windows. An input edit restarts the script and rebuilds every slot.
var array<SCSession> scSessions = array.new<SCSession>()
if barstate.isfirst
    for i = 0 to 5
        string sessionClock = scEffectiveSessions.get(i)
        [startMinute, endMinute] = f_scClockMinutes(sessionClock)
        scSessions.push(f_scNewSession(scEffectiveNames.get(i), sessionClock, startMinute, endMinute, scEffectiveEnabled.get(i)))

f_scContains(SCSession slot, int sampleTime) =>
    int minuteOfDay = hour(sampleTime, SC_TIMEZONE) * 60 + minute(sampleTime, SC_TIMEZONE)
    slot.endMin > slot.startMin ? minuteOfDay >= slot.startMin and minuteOfDay < slot.endMin : minuteOfDay >= slot.startMin or minuteOfDay < slot.endMin

// Construct both boundaries in local calendar time, rather than adding a fixed 24 hours.
f_scBounds(SCSession slot, int sampleTime) =>
    int minuteOfDay = hour(sampleTime, SC_TIMEZONE) * 60 + minute(sampleTime, SC_TIMEZONE)
    bool wraps = slot.endMin <= slot.startMin
    int dayShift = wraps and minuteOfDay < slot.startMin ? -1 : 0
    int yyyy = year(sampleTime, SC_TIMEZONE)
    int mm = month(sampleTime, SC_TIMEZONE)
    int dd = dayofmonth(sampleTime, SC_TIMEZONE) + dayShift
    int startTime = timestamp(SC_TIMEZONE, yyyy, mm, dd, int(math.floor(slot.startMin / 60)), slot.startMin % 60)
    int endTime = timestamp(SC_TIMEZONE, yyyy, mm, dd + (wraps ? 1 : 0), int(math.floor(slot.endMin / 60)), slot.endMin % 60)
    [startTime, endTime]

method scFinalize(SCCandle candle) =>
    if not candle.closed
        candle.partial := candle.partial or na(candle.O) or na(candle.observedStart) or candle.observedStart != candle.sessionStart or na(candle.observedEnd) or candle.observedEnd != candle.sessionEnd
        candle.closed := true
    true

// Invalid price samples may advance the target clock, but never invent prices or coverage.
// A later target timestamp closes the previous occurrence before any new occurrence is born.
method scObserve(SCSession slot, int sampleTime, int sampleClose, float sampleO, float sampleH, float sampleL, float sampleC, bool sampleConfirmed, int sourceBar, int keepCount) =>
    bool validTime = not na(sampleTime) and not na(sampleClose) and sampleClose > sampleTime
    bool validPrice = validTime and sampleClose - sampleTime == SC_MINUTE_MS and not na(sampleO) and not na(sampleH) and not na(sampleL) and not na(sampleC)
    if slot.enabled and validTime
        SCCandle previous = slot.candles.size() > 0 ? slot.candles.get(0) : na
        if not na(previous) and not previous.closed and sampleTime >= previous.sessionEnd
            previous.scFinalize()
        // Keep an occurrence continuous in absolute time when the local clock repeats.
        // For example, a fall-back hour may return to a wall time before its opening.
        bool continuesOccurrence = not na(previous) and sampleTime >= previous.sessionStart and sampleTime < previous.sessionEnd
        if continuesOccurrence or f_scContains(slot, sampleTime)
            int startTime = na
            int endTime = na
            if continuesOccurrence
                startTime := previous.sessionStart
                endTime := previous.sessionEnd
            else
                [calendarStart, calendarEnd] = f_scBounds(slot, sampleTime)
                startTime := calendarStart
                endTime := calendarEnd
            // DST can make a local time ambiguous or nonexistent. A wall-clock match
            // alone must not create an occurrence outside its resolved timestamps.
            bool insideBounds = sampleTime >= startTime and sampleTime < endTime
            if insideBounds
                bool newOccurrence = na(previous) or previous.sessionStart != startTime
                if newOccurrence
                    if not na(previous) and not previous.closed
                        previous.scFinalize()
                    SCCandle born = SCCandle.new(sessionStart=startTime, sessionEnd=endTime, partial=sampleTime != startTime or not validPrice)
                    slot.candles.unshift(born)
                    if slot.candles.size() > keepCount
                        slot.candles.pop()
                SCCandle current = slot.candles.get(0)
                if not current.closed
                    bool fits = sampleTime >= current.sessionStart and sampleClose <= current.sessionEnd
                    if not validPrice or not fits
                        current.partial := true
                    else if na(current.lastSampleTime) or sampleTime > current.lastSampleTime
                        if not na(current.lastSampleClose) and sampleTime != current.lastSampleClose
                            current.partial := true
                        if na(current.observedStart)
                            current.observedStart := sampleTime
                            if sampleTime == current.sessionStart
                                current.O := sampleO
                                current.bO := sourceBar
                            else
                                current.partial := true
                        if na(current.H) or sampleH > current.H
                            current.H := sampleH
                            current.tH := sampleTime
                            current.bH := sourceBar
                        if na(current.L) or sampleL < current.L
                            current.L := sampleL
                            current.tL := sampleTime
                            current.bL := sourceBar
                        current.C := sampleC
                        current.bC := sourceBar
                        current.lastSampleTime := sampleTime
                        current.lastSampleClose := sampleClose
                        current.observedEnd := sampleClose
                    // time_close is the planned minute boundary, not proof that a live minute finished.
                    if sampleConfirmed and sampleClose >= current.sessionEnd
                        current.scFinalize()
    validPrice

float scChartSeconds = timeframe.in_seconds()
float scMinSeconds = timeframe.in_seconds(scMinTimeframe)
float scMaxSeconds = timeframe.in_seconds(scMaxTimeframe)
bool scTimeframeRangeValid = scMinSeconds <= scMaxSeconds
bool scTimeframeVisible = scTimeframeRangeValid and scChartSeconds >= scMinSeconds and scChartSeconds <= scMaxSeconds
bool scSupported = chart.is_standard and timeframe.isintraday and scChartSeconds >= 60 and scChartSeconds <= 14400
bool scDirectMinute = scSupported and scChartSeconds == 60
const int scKeepCount = 1
string scFeedSymbol = ticker.modify(syminfo.tickerid, settlement_as_close=settlement_as_close.off)

// One request and one target clock. No substitute host OHLC on coarser charts with empty arrays.
[scMinuteTimes, scMinuteCloses, scMinuteOpen, scMinuteHigh, scMinuteLow, scMinuteClose] = request.security_lower_tf(scFeedSymbol, "1", [time, time_close, open, high, low, close], ignore_invalid_timeframe=true)

// scDataAvailable refers to this execution; the last-observed stamps survive empty buckets.
bool scDataAvailable = false
var int scLastSampleTime = na
var int scLastSampleClose = na
if scSupported
    if scDirectMinute
        bool validSample = not na(time) and not na(time_close) and time_close - time == SC_MINUTE_MS and not na(open) and not na(high) and not na(low) and not na(close)
        for slot in scSessions
            slot.scObserve(time, time_close, open, high, low, close, barstate.isconfirmed, bar_index, scKeepCount)
        if validSample
            scDataAvailable := true
            scLastSampleTime := time
            scLastSampleClose := time_close
    else
        int minuteCount = na(scMinuteTimes) ? 0 : scMinuteTimes.size()
        if minuteCount > 0
            for j = 0 to minuteCount - 1
                int sampleTime = scMinuteTimes.get(j)
                int sampleClose = scMinuteCloses.get(j)
                float sampleO = scMinuteOpen.get(j)
                float sampleH = scMinuteHigh.get(j)
                float sampleL = scMinuteLow.get(j)
                float sampleC = scMinuteClose.get(j)
                // Later returned minutes prove the previous minute ended. Host confirmation
                // proves all its minutes ended; realtime wall time never confirms a future close.
                bool followedByLaterMinute = j + 1 < minuteCount and not na(sampleClose) and scMinuteTimes.get(j + 1) >= sampleClose
                bool sampleConfirmed = barstate.isconfirmed or followedByLaterMinute or (barstate.isrealtime and not na(sampleClose) and timenow >= sampleClose)
                bool validSample = not na(sampleTime) and not na(sampleClose) and sampleClose - sampleTime == SC_MINUTE_MS and not na(sampleO) and not na(sampleH) and not na(sampleL) and not na(sampleC)
                for slot in scSessions
                    slot.scObserve(sampleTime, sampleClose, sampleO, sampleH, sampleL, sampleC, sampleConfirmed, bar_index, scKeepCount)
                if validSample
                    scDataAvailable := true
                    scLastSampleTime := sampleTime
                    scLastSampleClose := sampleClose

// Bounded drawing layer. At most six candles and six open traces.
// Even at every layout maximum, the last candle is fewer than 500 bars ahead.
var array<box> scBodies = array.new<box>()
var array<line> scLines = array.new<line>()
var array<label> scLabels = array.new<label>()
var table scNotice = table.new(position.bottom_left, 1, 1)

// Price drawings with old bar_index anchors implicitly read time history.
max_bars_back(time, 5000)

f_scResetTime(int stamp) =>
    int dateShift = hour(stamp, SC_TIMEZONE) < 18 ? -1 : 0
    timestamp(SC_TIMEZONE, year(stamp, SC_TIMEZONE), month(stamp, SC_TIMEZONE), dayofmonth(stamp, SC_TIMEZONE) + dateShift, 18, 0)

f_scDisplaySession(SCSession slot, int resetTime) =>
    // Windows crossing 18:00 remain visible through their own end, including after close.
    slot.enabled and slot.candles.size() > 0 and (scShowPreviousDay or slot.candles.get(0).sessionEnd > resetTime)

f_scDrawable(SCCandle candle) =>
    not candle.partial and not na(candle.O) and not na(candle.H) and not na(candle.L) and not na(candle.C)

f_scFont() =>
    switch scTextSize
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_scPrice(float value) =>
    na(value) ? "Unavailable" : str.tostring(value, format.mintick)

f_scTime(int stamp) =>
    na(stamp) ? "Unavailable" : str.format_time(stamp, "MMM d, HH:mm", SC_TIMEZONE)

f_scWindow(SCSession slot) =>
    string clock = slot.clock
    str.substring(clock, 0, 2) + ":" + str.substring(clock, 2, 4) + "-" + str.substring(clock, 5, 7) + ":" + str.substring(clock, 7, 9)

f_scPhase(SCCandle candle) =>
    int observedClock = barstate.isrealtime ? timenow : na(scLastSampleClose) ? time : math.max(time, scLastSampleClose)
    candle.closed ? "Closed" : observedClock >= candle.sessionEnd ? "Awaiting data" : "Forming"

f_scStatus(SCCandle candle) =>
    f_scPhase(candle) + (candle.partial ? " / Incomplete" : "")

f_scTooltip(SCSession slot, SCCandle candle) =>
    slot.name + " | " + f_scWindow(slot) + " New York\n" + f_scTime(candle.sessionStart) + " to " + f_scTime(candle.sessionEnd) + " (end exclusive)\n" + f_scStatus(candle) + "\nOpen  " + f_scPrice(candle.O) + "\nHigh  " + f_scPrice(candle.H) + "  @ " + f_scTime(candle.tH) + "\nLow   " + f_scPrice(candle.L) + "  @ " + f_scTime(candle.tL) + "\nClose " + f_scPrice(candle.C) + "\nLast source minute: " + f_scTime(candle.lastSampleTime) + (candle.partial ? "\nCoverage is incomplete. Observed prices are not a complete session candle." : "")

f_scClearDrawings() =>
    while scBodies.size() > 0
        box.delete(scBodies.pop())
    while scLines.size() > 0
        line.delete(scLines.pop())
    while scLabels.size() > 0
        label.delete(scLabels.pop())
    true

f_scDrawLine(int x1, float y1, int x2, float y2, color paint, string style, int width) =>
    line object = line.new(x1, y1, x2, y2, xloc=xloc.bar_index, extend=extend.none, color=paint, style=style, width=width, force_overlay=true)
    scLines.push(object)
    object

f_scDrawLabel(int x, float y, string words, string style, string tip) =>
    label object = label.new(x=x, y=y, text=words, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), style=style, textcolor=scTextColor, size=f_scFont(), textalign=text.align_center, tooltip=tip, force_overlay=true)
    scLabels.push(object)
    object

f_scTraceOpen(int sourceBar, int targetBar, float price) =>
    bool visible = scTraceOpen and not na(sourceBar) and not na(price) and sourceBar >= math.max(0, bar_index - 4999) and sourceBar <= bar_index
    if visible
        f_scDrawLine(sourceBar, price, targetBar, price, color.new(chart.fg_color, 55), line.style_dotted, 1)
    visible

f_scDrawCandle(SCCandle candle, int left, int right) =>
    bool up = candle.C > candle.O
    bool flat = candle.C == candle.O
    int center = int((left + right) / 2)
    float bodyTop = math.max(candle.O, candle.C)
    float bodyBottom = math.min(candle.O, candle.C)
    color bodyColor = up ? scBodyUp : scBodyDown
    color borderColor = up or flat ? scBorderUp : scBorderDown
    color wickColor = up or flat ? scWickUp : scWickDown
    if candle.H > bodyTop
        f_scDrawLine(center, candle.H, center, bodyTop, wickColor, line.style_solid, 1)
    if candle.L < bodyBottom
        f_scDrawLine(center, bodyBottom, center, candle.L, wickColor, line.style_solid, 1)
    if flat
        f_scDrawLine(left, candle.O, right, candle.O, borderColor, line.style_solid, 1)
    else
        box body = box.new(left=left, top=bodyTop, right=right, bottom=bodyBottom, xloc=xloc.bar_index, border_color=borderColor, border_width=1, bgcolor=bodyColor, force_overlay=true)
        scBodies.push(body)
    true

// No fake fallback to coarser OHLC. The notice explains unsupported or missing data.
if barstate.islast
    f_scClearDrawings()
    table.clear(scNotice, 0, 0)
    int enabledCount = 0
    // Use loaded chart/source time, not wall time, so replay and closed markets stay consistent.
    int resetTime = f_scResetTime(na(scLastSampleTime) ? time : math.max(time, scLastSampleTime))
    bool anyForming = false
    int lastClosedSlot = -1
    int lastClosedEnd = na
    int lastClosedStart = na
    float upper = na
    float lower = na
    for [slotIndex, slot] in scSessions
        if slot.enabled
            enabledCount += 1
        if f_scDisplaySession(slot, resetTime)
            for candle in slot.candles
                anyForming := anyForming or f_scPhase(candle) == "Forming"
                // Newest close wins; later open breaks a tie, then the first slot wins.
                if candle.closed and f_scDrawable(candle)
                    bool later = na(lastClosedEnd) or candle.sessionEnd > lastClosedEnd or (candle.sessionEnd == lastClosedEnd and candle.sessionStart > lastClosedStart)
                    if later
                        lastClosedSlot := slotIndex
                        lastClosedEnd := candle.sessionEnd
                        lastClosedStart := candle.sessionStart
                if not na(candle.H) and not na(candle.L)
                    upper := na(upper) ? candle.H : math.max(upper, candle.H)
                    lower := na(lower) ? candle.L : math.min(lower, candle.L)
    string notice = ""
    if enabledCount > 0
        if not scTimeframeRangeValid
            notice := "Session Candles: Minimum timeframe must not exceed Maximum timeframe."
        else if scTimeframeVisible and not scSupported
            notice := "Session Candles: use standard time-based candles, 1 minute to 4 hours."
        else if scTimeframeVisible
            if na(upper) or na(lower)
                upper := high
                lower := low
            bool namesAbove = scLabelPosition == "Above"
            string headingStyle = namesAbove ? label.style_label_down : label.style_label_up
            string dateStyle = namesAbove ? label.style_label_up : label.style_label_down
            int left = bar_index + scOffset
            int incompleteCount = 0
            for [slotIndex, slot] in scSessions
                if f_scDisplaySession(slot, resetTime)
                    int count = slot.candles.size()
                    SCCandle latest = slot.candles.get(0)
                    float labelHigh = nz(latest.H, upper)
                    float labelLow = nz(latest.L, lower)
                    float padding = math.max(syminfo.mintick * 2, (labelHigh - labelLow) * 0.015)
                    // Each label follows its own candle's wick, including while forming.
                    float headingY = namesAbove ? labelHigh + padding : labelLow - padding
                    float dateY = namesAbove ? labelLow - padding : labelHigh + padding
                    int baseWidth = scWidth
                    int headingX = left + int(baseWidth / 2)
                    string name = slot.name == "Opening Range" ? "Opening\nRange" : slot.name == "Initial Balance" ? "Initial\nBalance" : slot.name
                    string heading = (scShowNames ? name : "") + (scShowTimes ? (scShowNames ? "\n" : "") + f_scWindow(slot) : "")
                    string headingTip = count > 0 ? f_scTooltip(slot, slot.candles.get(0)) : slot.name + " | " + f_scWindow(slot) + " New York\nNo occurrence is available in the loaded minute data."
                    if heading != ""
                        f_scDrawLabel(headingX, headingY, heading, headingStyle, headingTip)
                    if count == 0
                        f_scDrawLabel(headingX, (upper + lower) / 2, "No data", label.style_label_center, headingTip)
                    else
                        for displayed = 0 to count - 1
                            // Retention is fixed to one occurrence per session.
                            int index = count - 1 - displayed
                            SCCandle candle = slot.candles.get(index)
                            int candleLeft = left
                            int candleRight = candleLeft + scWidth
                            int center = candleLeft + int(scWidth / 2)
                            bool drawable = f_scDrawable(candle)
                            string tip = f_scTooltip(slot, candle)
                            string stamp = str.format_time(candle.sessionStart, "MMM d", SC_TIMEZONE)
                            if not drawable
                                incompleteCount += 1
                                f_scDrawLabel(center, na(candle.C) ? (upper + lower) / 2 : candle.C, "Incomplete", label.style_label_center, tip)
                            else
                                bool traceSelected = anyForming ? f_scPhase(candle) == "Forming" : slotIndex == lastClosedSlot
                                if traceSelected
                                    f_scTraceOpen(candle.bO, candleLeft, candle.O)
                                f_scDrawCandle(candle, candleLeft, candleRight)
                            if scShowDates
                                f_scDrawLabel(center, dateY, stamp, dateStyle, tip)
                    left += baseWidth + scSessionGap
            if na(scLastSampleTime)
                notice := "Session Candles: no one-minute data available. Load intraday history and include the session hours."
            else if not scDataAvailable
                notice := "Waiting for one-minute data. Last source minute: " + f_scTime(scLastSampleTime) + " ET."
            else if incompleteCount > 0
                notice := "Incomplete source coverage: labelled occurrences are withheld. Hover their labels for details."
    if scCodeInvalid and scSupported and scTimeframeVisible
        notice := "Invalid roster code: using the stored session names and windows." + (notice != "" ? "\n" + notice : "")
    if notice != ""
        table.cell(scNotice, 0, 0, notice, text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 10), text_size=size.small)
````
