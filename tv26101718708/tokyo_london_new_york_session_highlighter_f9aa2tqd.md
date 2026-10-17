# Tokyo London New York Session Highlighter

- url: https://www.tradingview.com/script/F9aA2tqD-Tokyo-London-New-York-Session-Highlighter/
- type: indicator
- pine_id: PUB;1aa2b3d5e71f49ea9362f1ecddf73803
- version: 2.0

## Description

Tokyo London New York Session Highlighter shades the Tokyo, London and New York trading sessions directly on the chart background so users can see time-of-day context at a glance. It is a visual aid for intraday charts.

Each session is defined by its own hours, day mask and IANA timezone, so the correct local times are used throughout the year, including daylight-saving changes in London and New York.

### Features

- Background shading for the Tokyo, London and New York sessions, each with its own color, transparency and on/off switch.
- Overlap handling: choose a dedicated color for periods when more than one session is active, or use a Priority order of New York over London over Tokyo.
- Optional session start/end markers with neutral session codes: TYO, LDN and NY.
- Optional active-session high and low plotted only while that session is open.
- Optional compact top-right table showing each session's Active/Inactive state and the number of sessions currently active.
- Optional informational session start/end alerts.

### Inputs

- Sessions: enable/disable, hours, timezone and day mask for each of the three sessions.
- Day mask: 23456 = Monday to Friday, 1234567 = every day.
- Colors: color and transparency for each session and for overlaps.
- Display: overlap handling, markers, active high/low, and the status table.
- Alerts: a single switch for session start/end alerts.

### How it works

The script checks, for every bar, whether the bar falls inside each configured session using TradingView's time engine and the session's IANA timezone.

A session start is the first bar inside the session after a bar outside it. A session end is the first bar outside the session after a bar inside it.

No higher-timeframe requests are used. The script reads only the current chart's bars and time.

### Default session references

- Tokyo: 09:00-18:00, Asia/Tokyo
- London: 08:00-17:00, Europe/London
- New York: 08:00-17:00, America/New_York

These defaults are practical regional time references for intraday analysis. They are not universal market rules and may not match every broker, exchange, product, holiday schedule, or early close. Users can adjust the session times, timezones and active days in the Inputs tab.

### Originality and usefulness

This script is not only a static three-color background tool. It adds several practical context features:

1. Timezone-aware sessions
Each major session can use its own local IANA timezone. This helps London and New York remain aligned with local time changes such as daylight saving time.

2. Explicit overlap handling
When multiple sessions are active at the same time, the script can either use a dedicated overlap color or a clear priority order. This makes overlapping trading periods easier to identify.

3. Current-session range context
Optional high/low plots show the developing range of the active session. This can help users compare current price movement with that session's own developing range.

4. Compact active-session table
The table shows which sessions are currently active and how many sessions are active at the same time. This gives a quick status view without adding another pane.

5. Clean, non-directional design
The script does not label market direction, classify trend, or suggest a trading action. It only visualizes time-based context.

### Limitations

- Designed for intraday charts. On daily or higher timeframes, the script displays an informational notice and does not shade sessions.
- Session backgrounds only appear where bars exist on the chart. If a symbol has no trading data during a period, the script cannot fill missing bars.
- Holiday schedules, broker-specific trading breaks, exchange-specific sessions, and early closes are not detected automatically.
- Default session times are user-adjustable references, not universal market rules.
- It reflects the session hours and timezones configured by the user; users should verify them against the instrument and data feed.
- It shows time-of-day context only and does not analyze price beyond plotting the optional high/low of the active session.

### What this script does not do

- It does not generate trade signals.
- It does not provide entries, exits, targets, or position sizing.
- It does not predict future price movement.
- It does not claim improved performance, accuracy, or profitability.
- It does not use future data.
- It is not a strategy or backtest system.
- It is not financial advice.

### Suggested use

Use this on intraday charts where session timing is relevant, such as FX, index CFDs, futures, or other markets where regional trading activity may matter. Keep the chart clean so the session backgrounds, overlap periods, and optional range plots remain easy to read.

### Japanese notes / 日本語補足

このインジケーターは、東京・ロンドン・ニューヨークの各セッションをチャート背景色で可視化する、日中足向けの時間帯コンテキストツールです。

目的は、セッションごとの値動きの違いや、ロンドン・ニューヨークなどの重複時間帯を見やすくすることです。売買シグナル、エントリー、エグジット、目標値、ポジションサイズの提案は行いません。

主な機能

- 東京・ロンドン・ニューヨークの背景色表示
- セッション重複時の専用カラー表示、または優先順位表示
- セッション開始・終了マーカーの任意表示
- 現在進行中のセッション高値・安値ラインの任意表示
- 現在アクティブなセッションを表示する小型テーブル
- 各セッションの時間帯・曜日・タイムゾーン・色・透明度の調整
- セッション開始・終了の情報通知アラート

このスクリプトは日中足向けです。日足以上の時間足では、背景色によるセッション表示は行わず、情報メッセージのみを表示します。

初期値は一般的な地域別時間帯の参考設定であり、特定のブローカー、取引所、銘柄、祝日、短縮取引を完全に反映するものではありません。必要に応じて各自の取引対象に合わせて調整してください。

このスクリプトは、相場の時間帯を把握するための可視化ツールです。将来の値動き、成績、勝率、精度を示唆または保証するものではありません。投資助言ではありません。

## Source Code

````pine
//@version=6
// Tokyo London New York Session Highlighter
// v3.6 Publication Polish Precision Build
// Time-of-day context only. No trade signals, no predictions, no performance claims, and no financial advice.

const string INDICATOR_NAME = "Tokyo London New York Session Highlighter"
const int MS_IN_MINUTE = 60000
const int MS_IN_DAY = 86400000

indicator(INDICATOR_NAME, shorttitle=INDICATOR_NAME, overlay=true, max_lines_count=30)

// ----------------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------------
gSes = "Sessions"

enableTokyo  = input.bool(true, "Tokyo", group=gSes, inline="tyo", display=display.none)
tokyoSession = input.session("0900-1800", "Hours", group=gSes, inline="tyo", display=display.none)
tokyoTz      = input.string("Asia/Tokyo", "Timezone", options=["Asia/Tokyo", "Etc/UTC", "Europe/London", "America/New_York", "America/Chicago", "Europe/Berlin", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], group=gSes, inline="tyo2", display=display.none)
tokyoDays    = input.string("23456", "Days", options=["23456", "1234567"], tooltip="23456 = Monday to Friday. 1234567 = every day.", group=gSes, inline="tyo2", display=display.none)

enableLondon  = input.bool(true, "London", group=gSes, inline="ldn", display=display.none)
londonSession = input.session("0800-1700", "Hours", group=gSes, inline="ldn", display=display.none)
londonTz      = input.string("Europe/London", "Timezone", options=["Europe/London", "Etc/UTC", "Asia/Tokyo", "America/New_York", "America/Chicago", "Europe/Berlin", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], group=gSes, inline="ldn2", display=display.none)
londonDays    = input.string("23456", "Days", options=["23456", "1234567"], tooltip="23456 = Monday to Friday. 1234567 = every day.", group=gSes, inline="ldn2", display=display.none)

enableNy  = input.bool(true, "New York", group=gSes, inline="ny", display=display.none)
nySession = input.session("0800-1700", "Hours", group=gSes, inline="ny", display=display.none)
nyTz      = input.string("America/New_York", "Timezone", options=["America/New_York", "Etc/UTC", "Asia/Tokyo", "Europe/London", "America/Chicago", "Europe/Berlin", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], group=gSes, inline="ny2", display=display.none)
nyDays    = input.string("23456", "Days", options=["23456", "1234567"], tooltip="23456 = Monday to Friday. 1234567 = every day.", group=gSes, inline="ny2", display=display.none)

gVis = "Visuals"
showSessionHighlight = input.bool(true, "Show session background highlight", tooltip="Switch off only the session background highlight. Current focus rails and the dashboard/list have their own controls.", group=gVis, display=display.none)
coverageMode = input.string("All history", "Historical coverage", options=["All history", "Recent only"], tooltip="All history is the default so session context remains available for historical research. Recent only is optional for very crowded charts.", group=gVis, display=display.none)
backgroundLookbackDays = input.int(30, "Recent coverage days", minval=1, maxval=365, group=gVis, display=display.none)
sessionBgTransparency = input.int(93, "Session background transparency", minval=0, maxval=100, tooltip="Lower values make the session background stronger. Higher values make it more subtle.", group=gVis, display=display.none)
overlapBgTransparency = input.int(90, "Overlap background transparency", minval=0, maxval=100, tooltip="Background transparency when two or more tracked sessions overlap.", group=gVis, display=display.none)
showCurrentRange = input.bool(true, "Current focus high/low", group=gVis, inline="lv", display=display.none)
showCurrentMid = input.bool(true, "Midpoint", group=gVis, inline="lv", display=display.none)
showOpeningRange = input.bool(true, "Opening range", group=gVis, inline="or", display=display.none)
openingRangeMinutes = input.int(60, "Minutes", minval=5, maxval=240, tooltip="Opening range is calculated from bars inside the first N minutes of each session. Lower chart timeframes give more precise opening-range boundaries.", group=gVis, inline="or", display=display.none)
showPreviousRange = input.bool(true, "Previous focus high/low", group=gVis, display=display.none)
previousReferenceMinutes = input.int(240, "Previous level visible length, minutes", minval=30, maxval=1440, group=gVis, display=display.none)
rightExtensionMinutes = input.int(60, "Right-side rail extension, minutes", minval=0, maxval=240, tooltip="Extends current reference rails slightly into the right side so the active session structure is easier to read without labels.", group=gVis, display=display.none)
liveLineWidth = input.int(2, "Live line width", minval=1, maxval=4, inline="w", group=gVis, display=display.none)
refLineWidth = input.int(1, "Reference line width", minval=1, maxval=3, inline="w", group=gVis, display=display.none)
liveLevelTransparency = input.int(0, "Live high/low transparency", minval=0, maxval=100, group=gVis, display=display.none)
midLevelTransparency = input.int(42, "Midpoint transparency", minval=0, maxval=100, group=gVis, display=display.none)
openingLevelTransparency = input.int(42, "Opening-range line transparency", minval=0, maxval=100, group=gVis, display=display.none)
previousLevelTransparency = input.int(58, "Previous level transparency", minval=0, maxval=100, group=gVis, display=display.none)


gCol = "Colors"
tokyoColor   = input.color(#4da3ff, "Tokyo", group=gCol, inline="c1", display=display.none)
londonColor  = input.color(#2fd074, "London", group=gCol, inline="c1", display=display.none)
nyColor      = input.color(#ffb347, "New York", group=gCol, inline="c2", display=display.none)
overlapColor = input.color(#b38cff, "Overlap", group=gCol, inline="c2", display=display.none)


gDash = "Dashboard"
showSessionList = input.bool(true, "Show session list", tooltip="Shows or hides the compact top-right session list/dashboard.", group=gDash, display=display.none)
dashboardPositionInput = input.string("Top right", "Position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=gDash, display=display.none)
dashboardRightPadding = input.string("Extra large", "Right padding", options=["None", "Small", "Medium", "Large", "Extra large"], tooltip="Top-right tables cannot be pixel-offset in Pine, so a transparent spacer column moves the visible text away from price-scale labels.", group=gDash, display=display.none)
fontSizeInput = input.string("Normal", "Text size", options=["Small", "Normal", "Large"], tooltip="Pine tables do not support font weight. Use Normal or Large for stronger, more readable text.", group=gDash, display=display.none)
dashboardTextColor = input.color(#f8fafc, "Main text", group=gDash, inline="txt", display=display.none)
dashboardIdleTextColor = input.color(#cbd5e1, "Idle text", group=gDash, inline="txt", display=display.none)
dashboardSessionNameTransparency = input.int(0, "Session-name text transparency", minval=0, maxval=100, tooltip="Tokyo/London/New York labels use their own session colors. Increase this only if you want them dimmer.", group=gDash, display=display.none)
dashboardMainTextTransparency = input.int(0, "Main text transparency", minval=0, maxval=100, group=gDash, display=display.none)
dashboardMutedTextTransparency = input.int(18, "Idle text transparency", minval=0, maxval=100, group=gDash, display=display.none)
dashboardHeaderColor = input.color(#111827, "Header", group=gDash, inline="bg1", display=display.none)
dashboardPanelColor = input.color(#0f172a, "Panel", group=gDash, inline="bg1", display=display.none)
dashboardActiveRowColor = input.color(#1f2937, "Active row", group=gDash, inline="bg2", display=display.none)
dashboardHeaderTransparency = input.int(0, "Header transparency", minval=0, maxval=100, group=gDash, display=display.none)
dashboardInactiveRowTransparency = input.int(22, "Inactive row transparency", minval=0, maxval=100, group=gDash, display=display.none)
dashboardActiveRowTransparency = input.int(4, "Active row transparency", minval=0, maxval=100, tooltip="This uses a neutral background by default so session-colored text remains readable.", group=gDash, display=display.none)
dashboardFrameTransparency = input.int(56, "Frame transparency", minval=0, maxval=100, group=gDash, inline="dbf", display=display.none)
dashboardBorderTransparency = input.int(70, "Border transparency", minval=0, maxval=100, group=gDash, inline="dbf", display=display.none)


gAlert = "Alerts"
enableAlerts = input.bool(true, "Enable alert() notifications", group=gAlert, display=display.none)
alertMinutesBefore = input.int(15, "Lead minutes", minval=1, maxval=120, tooltip="On higher intraday timeframes, the script automatically widens this to at least one chart bar so the alert is not skipped.", group=gAlert, display=display.none)
alertSessionChange = input.bool(true, "Session start/end", group=gAlert, inline="a1", display=display.none)
alertPreSession = input.bool(true, "Pre-open / pre-close", group=gAlert, inline="a1", display=display.none)
alertFocusChange = input.bool(true, "Focus change", group=gAlert, inline="a2", display=display.none)
alertOverlapChange = input.bool(true, "Overlap change", group=gAlert, inline="a2", display=display.none)
alertOpeningRange = input.bool(false, "Opening range completed", group=gAlert, inline="a3", display=display.none)
alertPrevTouches = input.bool(false, "Previous high/low touched", group=gAlert, inline="a3", display=display.none)

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------
isIntraday = timeframe.isintraday
barOpenTs = time
barTs = na(time_close) ? time : time_close
recentCutoff = last_bar_time - backgroundLookbackDays * MS_IN_DAY
inRecentWindow = time >= recentCutoff

tfSeconds = nz(timeframe.in_seconds(timeframe.period), 60)
tfMinutes = math.max(1, int(math.ceil(float(tfSeconds) / 60.0)))
leadWindowMinutes = math.max(alertMinutesBefore, tfMinutes)

f_size(simple string value) =>
    switch value
        "Large" => size.large
        "Normal" => size.normal
        => size.small

f_tablePos(simple string value) =>
    switch value
        "Top left" => position.top_left
        "Bottom right" => position.bottom_right
        "Bottom left" => position.bottom_left
        => position.top_right

f_spacerText(simple string value) =>
    switch value
        "Small" => "000"
        "Medium" => "000000"
        "Large" => "000000000"
        "Extra large" => "000000000000"
        => ""

f_inSession(bool enabled, simple string sess, simple string days, simple string tz) =>
    string sessionSpec = sess + ":" + days
    isIntraday and enabled and (not na(time(timeframe.period, sessionSpec, tz)) or not na(time_close(timeframe.period, sessionSpec, tz)))

f_parseMinute(simple string sess, simple int offset) =>
    int result = na
    if str.length(sess) >= offset + 4
        float h = str.tonumber(str.substring(sess, offset, offset + 2))
        float m = str.tonumber(str.substring(sess, offset + 2, offset + 4))
        if not na(h) and not na(m)
            result := int(h) * 60 + int(m)
    result

f_minHour(int minuteValue) =>
    int(math.floor(minuteValue / 60))

f_minMinute(int minuteValue) =>
    minuteValue % 60

f_dayCode(int dow) =>
    dow == dayofweek.sunday ? "1" : dow == dayofweek.monday ? "2" : dow == dayofweek.tuesday ? "3" : dow == dayofweek.wednesday ? "4" : dow == dayofweek.thursday ? "5" : dow == dayofweek.friday ? "6" : "7"

f_dayAllowed(int dow, simple string days) =>
    str.contains(days, f_dayCode(dow))

f_sessionOpenTs(simple string sess, simple string tz) =>
    int result = na
    int startMin = f_parseMinute(sess, 0)
    int endMin = f_parseMinute(sess, 5)
    if not na(startMin) and not na(endMin)
        int openBarMin = hour(barOpenTs, tz) * 60 + minute(barOpenTs, tz)
        int closeBarMin = hour(barTs, tz) * 60 + minute(barTs, tz)
        bool overnight = endMin <= startMin
        int baseTs = barOpenTs
        if overnight
            baseTs := openBarMin < endMin ? barOpenTs - MS_IN_DAY : barOpenTs
        else
            bool crossesSessionOpenSameDay = openBarMin < startMin and closeBarMin >= startMin
            bool crossesMidnightIntoSession = closeBarMin < openBarMin and closeBarMin >= startMin and closeBarMin <= endMin
            baseTs := crossesSessionOpenSameDay or crossesMidnightIntoSession ? barTs : barOpenTs
        result := timestamp(tz, year(baseTs, tz), month(baseTs, tz), dayofmonth(baseTs, tz), f_minHour(startMin), f_minMinute(startMin))
    result

f_sessionCloseTs(simple string sess, simple string tz) =>
    int result = na
    int startMin = f_parseMinute(sess, 0)
    int endMin = f_parseMinute(sess, 5)
    int openTs = f_sessionOpenTs(sess, tz)
    if not na(startMin) and not na(endMin) and not na(openTs)
        bool overnight = endMin <= startMin
        int closeDateBase = overnight ? openTs + MS_IN_DAY : openTs
        result := timestamp(tz, year(closeDateBase, tz), month(closeDateBase, tz), dayofmonth(closeDateBase, tz), f_minHour(endMin), f_minMinute(endMin))
    result

f_sessionKey(simple string sess, simple string tz) =>
    int openTs = f_sessionOpenTs(sess, tz)
    na(openTs) ? na : year(openTs, tz) * 10000 + month(openTs, tz) * 100 + dayofmonth(openTs, tz)

f_minutesUntilOpen(simple string sess, simple string days, simple string tz) =>
    int result = na
    int startMin = f_parseMinute(sess, 0)
    if not na(startMin)
        for i = 0 to 8
            int dateProbe = barTs + i * MS_IN_DAY
            int candidate = timestamp(tz, year(dateProbe, tz), month(dateProbe, tz), dayofmonth(dateProbe, tz), f_minHour(startMin), f_minMinute(startMin))
            bool allowed = f_dayAllowed(dayofweek(candidate, tz), days)
            if na(result) and allowed and candidate > barTs
                result := int(math.ceil(float(candidate - barTs) / float(MS_IN_MINUTE)))
    result

f_minutesUntilClose(simple string sess, simple string tz) =>
    int result = na
    int closeTs = f_sessionCloseTs(sess, tz)
    if not na(closeTs)
        result := math.max(0, int(math.ceil(float(closeTs - barTs) / float(MS_IN_MINUTE))))
    result

f_progress(bool onState, simple string sess, simple string tz) =>
    float result = na
    if onState
        int openTs = f_sessionOpenTs(sess, tz)
        int closeTs = f_sessionCloseTs(sess, tz)
        int span = not na(openTs) and not na(closeTs) ? closeTs - openTs : na
        if not na(span) and span > 0
            result := math.max(0.0, math.min(1.0, float(barTs - openTs) / float(span)))
    result

f_fmtMins(int value) =>
    string result = "-"
    if not na(value)
        if value < 60
            result := str.tostring(value) + "m"
        else
            int h = int(math.floor(value / 60))
            int m = value % 60
            result := m == 0 ? str.tostring(h) + "h" : str.tostring(h) + "h" + str.tostring(m)
    result

f_fmtRangeValue(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_fmtRatio(float cur, float avg) =>
    na(cur) or na(avg) or avg == 0.0 ? "-" : str.tostring(cur / avg, "#.##") + "x"

f_stateText(bool onState, float prog) =>
    onState ? "Active " + str.tostring(math.round(nz(prog) * 100.0)) + "%" : "Idle"

f_nextText(bool onState, int toOpen, int toClose) =>
    onState ? "Closes " + f_fmtMins(toClose) : "Opens " + f_fmtMins(toOpen)

f_clock(simple string tz) =>
    str.format_time(barTs, "HH:mm", tz)

f_pushRange(array<float> arr, float value) =>
    if not na(value)
        array.push(arr, value)
        while array.size(arr) > 20
            array.shift(arr)

f_avgRange(array<float> arr) =>
    float result = na
    int n = array.size(arr)
    if n > 0
        float total = 0.0
        for i = 0 to n - 1
            total += array.get(arr, i)
        result := total / n
    result

f_levelLine(line id, bool show, int x1, float y, int x2, color lineColor, int width, string styleName) =>
    line result = id
    if show and not na(x1) and not na(x2) and not na(y)
        int safeX2 = x2 <= x1 ? x1 + MS_IN_MINUTE : x2
        if na(result)
            result := line.new(x1=x1, y1=y, x2=safeX2, y2=y, xloc=xloc.bar_time, extend=extend.none, color=lineColor, width=width)
        else
            line.set_xy1(result, x1, y)
            line.set_xy2(result, safeX2, y)
            line.set_color(result, lineColor)
            line.set_width(result, width)
        line.set_style(result, styleName == "dotted" ? line.style_dotted : styleName == "dashed" ? line.style_dashed : line.style_solid)
    else
        if not na(result)
            line.delete(result)
            result := na
    result

// ----------------------------------------------------------------------------
// Session detection with local-date rollover support
// ----------------------------------------------------------------------------
tokyoOn = f_inSession(enableTokyo, tokyoSession, tokyoDays, tokyoTz)
londonOn = f_inSession(enableLondon, londonSession, londonDays, londonTz)
nyOn = f_inSession(enableNy, nySession, nyDays, nyTz)

tokyoKey = f_sessionKey(tokyoSession, tokyoTz)
londonKey = f_sessionKey(londonSession, londonTz)
nyKey = f_sessionKey(nySession, nyTz)

var int tokyoLastKey = na
var int londonLastKey = na
var int nyLastKey = na

bool tokyoPrevOn = tokyoOn[1] == true
bool londonPrevOn = londonOn[1] == true
bool nyPrevOn = nyOn[1] == true

bool tokyoRoll = tokyoOn and not na(tokyoLastKey) and tokyoLastKey != tokyoKey
bool londonRoll = londonOn and not na(londonLastKey) and londonLastKey != londonKey
bool nyRoll = nyOn and not na(nyLastKey) and nyLastKey != nyKey

tokyoStart = tokyoOn and (not tokyoPrevOn or tokyoRoll)
londonStart = londonOn and (not londonPrevOn or londonRoll)
nyStart = nyOn and (not nyPrevOn or nyRoll)

tokyoEnd = (not tokyoOn and tokyoPrevOn) or tokyoRoll
londonEnd = (not londonOn and londonPrevOn) or londonRoll
nyEnd = (not nyOn and nyPrevOn) or nyRoll

if tokyoOn
    tokyoLastKey := tokyoKey
if londonOn
    londonLastKey := londonKey
if nyOn
    nyLastKey := nyKey

activeCount = (tokyoOn ? 1 : 0) + (londonOn ? 1 : 0) + (nyOn ? 1 : 0)
overlapOn = isIntraday and activeCount > 1
overlapStart = overlapOn and overlapOn[1] != true
overlapEnd = not overlapOn and overlapOn[1] == true

focusId = nyOn ? 3 : londonOn ? 2 : tokyoOn ? 1 : 0
focusChanged = focusId != nz(focusId[1], 0)

// ----------------------------------------------------------------------------
// Session state containers
// ----------------------------------------------------------------------------
var float tokyoHi = na
var float tokyoLo = na
var float tokyoORHi = na
var float tokyoORLo = na
var int tokyoStartTs = na
var float tokyoPrevHi = na
var float tokyoPrevLo = na
var float tokyoPrevRange = na
var bool tokyoPrevHiTouched = false
var bool tokyoPrevLoTouched = false
var array<float> tokyoRanges = array.new<float>()

var float londonHi = na
var float londonLo = na
var float londonORHi = na
var float londonORLo = na
var int londonStartTs = na
var float londonPrevHi = na
var float londonPrevLo = na
var float londonPrevRange = na
var bool londonPrevHiTouched = false
var bool londonPrevLoTouched = false
var array<float> londonRanges = array.new<float>()

var float nyHi = na
var float nyLo = na
var float nyORHi = na
var float nyORLo = na
var int nyStartTs = na
var float nyPrevHi = na
var float nyPrevLo = na
var float nyPrevRange = na
var bool nyPrevHiTouched = false
var bool nyPrevLoTouched = false
var array<float> nyRanges = array.new<float>()

// Tokyo lifecycle
if tokyoStart
    if not na(tokyoHi) and not na(tokyoLo)
        tokyoPrevHi := tokyoHi
        tokyoPrevLo := tokyoLo
        tokyoPrevRange := tokyoHi - tokyoLo
        f_pushRange(tokyoRanges, tokyoPrevRange)
    tokyoHi := high
    tokyoLo := low
    tokyoORHi := high
    tokyoORLo := low
    tokyoStartTs := nz(f_sessionOpenTs(tokyoSession, tokyoTz), time)
    tokyoPrevHiTouched := false
    tokyoPrevLoTouched := false
else if tokyoOn
    tokyoHi := math.max(nz(tokyoHi, high), high)
    tokyoLo := math.min(nz(tokyoLo, low), low)

tokyoORBuilding = tokyoOn and showOpeningRange and not na(tokyoStartTs) and barTs <= tokyoStartTs + openingRangeMinutes * MS_IN_MINUTE
if tokyoOn and tokyoORBuilding and not tokyoStart
    tokyoORHi := math.max(nz(tokyoORHi, high), high)
    tokyoORLo := math.min(nz(tokyoORLo, low), low)
if tokyoEnd and not tokyoRoll
    if not na(tokyoHi) and not na(tokyoLo)
        tokyoPrevHi := tokyoHi
        tokyoPrevLo := tokyoLo
        tokyoPrevRange := tokyoHi - tokyoLo
        f_pushRange(tokyoRanges, tokyoPrevRange)
    tokyoHi := na
    tokyoLo := na
    tokyoORHi := na
    tokyoORLo := na
    tokyoStartTs := na

// London lifecycle
if londonStart
    if not na(londonHi) and not na(londonLo)
        londonPrevHi := londonHi
        londonPrevLo := londonLo
        londonPrevRange := londonHi - londonLo
        f_pushRange(londonRanges, londonPrevRange)
    londonHi := high
    londonLo := low
    londonORHi := high
    londonORLo := low
    londonStartTs := nz(f_sessionOpenTs(londonSession, londonTz), time)
    londonPrevHiTouched := false
    londonPrevLoTouched := false
else if londonOn
    londonHi := math.max(nz(londonHi, high), high)
    londonLo := math.min(nz(londonLo, low), low)

londonORBuilding = londonOn and showOpeningRange and not na(londonStartTs) and barTs <= londonStartTs + openingRangeMinutes * MS_IN_MINUTE
if londonOn and londonORBuilding and not londonStart
    londonORHi := math.max(nz(londonORHi, high), high)
    londonORLo := math.min(nz(londonORLo, low), low)
if londonEnd and not londonRoll
    if not na(londonHi) and not na(londonLo)
        londonPrevHi := londonHi
        londonPrevLo := londonLo
        londonPrevRange := londonHi - londonLo
        f_pushRange(londonRanges, londonPrevRange)
    londonHi := na
    londonLo := na
    londonORHi := na
    londonORLo := na
    londonStartTs := na

// New York lifecycle
if nyStart
    if not na(nyHi) and not na(nyLo)
        nyPrevHi := nyHi
        nyPrevLo := nyLo
        nyPrevRange := nyHi - nyLo
        f_pushRange(nyRanges, nyPrevRange)
    nyHi := high
    nyLo := low
    nyORHi := high
    nyORLo := low
    nyStartTs := nz(f_sessionOpenTs(nySession, nyTz), time)
    nyPrevHiTouched := false
    nyPrevLoTouched := false
else if nyOn
    nyHi := math.max(nz(nyHi, high), high)
    nyLo := math.min(nz(nyLo, low), low)

nyORBuilding = nyOn and showOpeningRange and not na(nyStartTs) and barTs <= nyStartTs + openingRangeMinutes * MS_IN_MINUTE
if nyOn and nyORBuilding and not nyStart
    nyORHi := math.max(nz(nyORHi, high), high)
    nyORLo := math.min(nz(nyORLo, low), low)
if nyEnd and not nyRoll
    if not na(nyHi) and not na(nyLo)
        nyPrevHi := nyHi
        nyPrevLo := nyLo
        nyPrevRange := nyHi - nyLo
        f_pushRange(nyRanges, nyPrevRange)
    nyHi := na
    nyLo := na
    nyORHi := na
    nyORLo := na
    nyStartTs := na

// ----------------------------------------------------------------------------
// Focus values
// ----------------------------------------------------------------------------
focusColor = focusId == 3 ? nyColor : focusId == 2 ? londonColor : focusId == 1 ? tokyoColor : chart.fg_color
focusHi = focusId == 3 ? nyHi : focusId == 2 ? londonHi : focusId == 1 ? tokyoHi : na
focusLo = focusId == 3 ? nyLo : focusId == 2 ? londonLo : focusId == 1 ? tokyoLo : na
focusMid = not na(focusHi) and not na(focusLo) ? (focusHi + focusLo) / 2.0 : na
focusORHi = focusId == 3 ? nyORHi : focusId == 2 ? londonORHi : focusId == 1 ? tokyoORHi : na
focusORLo = focusId == 3 ? nyORLo : focusId == 2 ? londonORLo : focusId == 1 ? tokyoORLo : na
focusPrevHi = focusId == 3 ? nyPrevHi : focusId == 2 ? londonPrevHi : focusId == 1 ? tokyoPrevHi : na
focusPrevLo = focusId == 3 ? nyPrevLo : focusId == 2 ? londonPrevLo : focusId == 1 ? tokyoPrevLo : na
focusRange = focusId == 3 ? nyHi - nyLo : focusId == 2 ? londonHi - londonLo : focusId == 1 ? tokyoHi - tokyoLo : na
focusAvgRange = focusId == 3 ? f_avgRange(nyRanges) : focusId == 2 ? f_avgRange(londonRanges) : focusId == 1 ? f_avgRange(tokyoRanges) : na
focusStartTs = focusId == 3 ? nyStartTs : focusId == 2 ? londonStartTs : focusId == 1 ? tokyoStartTs : na
focusName = focusId == 3 ? "New York" : focusId == 2 ? "London" : focusId == 1 ? "Tokyo" : "None"

// ----------------------------------------------------------------------------
// Clean chart visual layer
// ----------------------------------------------------------------------------
bgAllowed = isIntraday and showSessionHighlight and (coverageMode == "All history" or inRecentWindow)
color bgCol = na
if bgAllowed
    bgCol := overlapOn ? color.new(overlapColor, overlapBgTransparency) : focusId > 0 ? color.new(focusColor, sessionBgTransparency) : na
bgcolor(bgCol, title="Session background")

var line liveHiLine = na
var line liveLoLine = na
var line liveMidLine = na
var line orHiLine = na
var line orLoLine = na
var line prevHiLine = na
var line prevLoLine = na

lineX1 = focusStartTs
lineX2 = barTs + rightExtensionMinutes * MS_IN_MINUTE
prevX1 = barTs - previousReferenceMinutes * MS_IN_MINUTE

liveHiLine := f_levelLine(liveHiLine, isIntraday and showCurrentRange and focusId > 0, lineX1, focusHi, lineX2, color.new(focusColor, liveLevelTransparency), liveLineWidth, "solid")
liveLoLine := f_levelLine(liveLoLine, isIntraday and showCurrentRange and focusId > 0, lineX1, focusLo, lineX2, color.new(focusColor, liveLevelTransparency), liveLineWidth, "solid")
liveMidLine := f_levelLine(liveMidLine, isIntraday and showCurrentRange and showCurrentMid and focusId > 0, lineX1, focusMid, lineX2, color.new(focusColor, midLevelTransparency), refLineWidth, "dotted")
orHiLine := f_levelLine(orHiLine, isIntraday and showOpeningRange and focusId > 0, lineX1, focusORHi, lineX2, color.new(focusColor, openingLevelTransparency), refLineWidth, "dashed")
orLoLine := f_levelLine(orLoLine, isIntraday and showOpeningRange and focusId > 0, lineX1, focusORLo, lineX2, color.new(focusColor, openingLevelTransparency), refLineWidth, "dashed")
prevHiLine := f_levelLine(prevHiLine, isIntraday and showPreviousRange and focusId > 0, prevX1, focusPrevHi, lineX2, color.new(focusColor, previousLevelTransparency), refLineWidth, "dashed")
prevLoLine := f_levelLine(prevLoLine, isIntraday and showPreviousRange and focusId > 0, prevX1, focusPrevLo, lineX2, color.new(focusColor, previousLevelTransparency), refLineWidth, "dashed")

// ----------------------------------------------------------------------------
// Compact dashboard with transparent right spacer.
// Pine tables cannot be offset by pixels. The extra invisible column creates a
// practical left shift so price-scale labels such as High/Low do not cover text.
// ----------------------------------------------------------------------------
var table dash = table.new(f_tablePos(dashboardPositionInput), 6, 4, frame_color=color.new(dashboardPanelColor, dashboardFrameTransparency), frame_width=1, border_color=color.new(dashboardTextColor, dashboardBorderTransparency), border_width=1)

dashSize = f_size(fontSizeInput)
headerBg = color.new(dashboardHeaderColor, dashboardHeaderTransparency)
inactiveRowBg = color.new(dashboardPanelColor, dashboardInactiveRowTransparency)
activeRowBg = color.new(dashboardActiveRowColor, dashboardActiveRowTransparency)
mainText = color.new(dashboardTextColor, dashboardMainTextTransparency)
mutedText = color.new(dashboardIdleTextColor, dashboardMutedTextTransparency)
spacer = f_spacerText(dashboardRightPadding)
spacerTextColor = color.new(chart.fg_color, 100)
spacerBg = color.new(chart.bg_color, 100)

tokyoProg = f_progress(tokyoOn, tokyoSession, tokyoTz)
londonProg = f_progress(londonOn, londonSession, londonTz)
nyProg = f_progress(nyOn, nySession, nyTz)

tokyoOpenMin = f_minutesUntilOpen(tokyoSession, tokyoDays, tokyoTz)
londonOpenMin = f_minutesUntilOpen(londonSession, londonDays, londonTz)
nyOpenMin = f_minutesUntilOpen(nySession, nyDays, nyTz)

tokyoCloseMin = tokyoOn ? f_minutesUntilClose(tokyoSession, tokyoTz) : na
londonCloseMin = londonOn ? f_minutesUntilClose(londonSession, londonTz) : na
nyCloseMin = nyOn ? f_minutesUntilClose(nySession, nyTz) : na

tokyoRangeNow = tokyoOn ? tokyoHi - tokyoLo : tokyoPrevRange
londonRangeNow = londonOn ? londonHi - londonLo : londonPrevRange
nyRangeNow = nyOn ? nyHi - nyLo : nyPrevRange

tokyoRowBg = tokyoOn ? activeRowBg : inactiveRowBg
londonRowBg = londonOn ? activeRowBg : inactiveRowBg
nyRowBg = nyOn ? activeRowBg : inactiveRowBg

if barstate.islast
    table.clear(dash, 0, 0, 5, 3)
    if showSessionList and not isIntraday
        table.cell(dash, 0, 0, "Intraday only", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 1, 0, "Use an intraday chart", text_color=mutedText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 5, 0, spacer, text_color=spacerTextColor, bgcolor=spacerBg, text_size=dashSize)
    else if showSessionList
        table.cell(dash, 0, 0, "Session", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 1, 0, "State", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 2, 0, "Local", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 3, 0, "Next", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 4, 0, "Range / Avg", text_color=mainText, bgcolor=headerBg, text_size=dashSize)
        table.cell(dash, 5, 0, spacer, text_color=spacerTextColor, bgcolor=spacerBg, text_size=dashSize)

        table.cell(dash, 0, 1, "Tokyo", text_color=color.new(tokyoColor, dashboardSessionNameTransparency), bgcolor=tokyoRowBg, text_size=dashSize)
        table.cell(dash, 1, 1, f_stateText(tokyoOn, tokyoProg), text_color=tokyoOn ? color.new(tokyoColor, dashboardSessionNameTransparency) : mutedText, bgcolor=tokyoRowBg, text_size=dashSize)
        table.cell(dash, 2, 1, f_clock(tokyoTz), text_color=mainText, bgcolor=tokyoRowBg, text_size=dashSize)
        table.cell(dash, 3, 1, f_nextText(tokyoOn, tokyoOpenMin, tokyoCloseMin), text_color=mainText, bgcolor=tokyoRowBg, text_size=dashSize)
        table.cell(dash, 4, 1, f_fmtRangeValue(tokyoRangeNow) + " / " + f_fmtRatio(tokyoRangeNow, f_avgRange(tokyoRanges)), text_color=mainText, bgcolor=tokyoRowBg, text_size=dashSize)
        table.cell(dash, 5, 1, spacer, text_color=spacerTextColor, bgcolor=spacerBg, text_size=dashSize)

        table.cell(dash, 0, 2, "London", text_color=color.new(londonColor, dashboardSessionNameTransparency), bgcolor=londonRowBg, text_size=dashSize)
        table.cell(dash, 1, 2, f_stateText(londonOn, londonProg), text_color=londonOn ? color.new(londonColor, dashboardSessionNameTransparency) : mutedText, bgcolor=londonRowBg, text_size=dashSize)
        table.cell(dash, 2, 2, f_clock(londonTz), text_color=mainText, bgcolor=londonRowBg, text_size=dashSize)
        table.cell(dash, 3, 2, f_nextText(londonOn, londonOpenMin, londonCloseMin), text_color=mainText, bgcolor=londonRowBg, text_size=dashSize)
        table.cell(dash, 4, 2, f_fmtRangeValue(londonRangeNow) + " / " + f_fmtRatio(londonRangeNow, f_avgRange(londonRanges)), text_color=mainText, bgcolor=londonRowBg, text_size=dashSize)
        table.cell(dash, 5, 2, spacer, text_color=spacerTextColor, bgcolor=spacerBg, text_size=dashSize)

        table.cell(dash, 0, 3, "New York", text_color=color.new(nyColor, dashboardSessionNameTransparency), bgcolor=nyRowBg, text_size=dashSize)
        table.cell(dash, 1, 3, f_stateText(nyOn, nyProg), text_color=nyOn ? color.new(nyColor, dashboardSessionNameTransparency) : mutedText, bgcolor=nyRowBg, text_size=dashSize)
        table.cell(dash, 2, 3, f_clock(nyTz), text_color=mainText, bgcolor=nyRowBg, text_size=dashSize)
        table.cell(dash, 3, 3, f_nextText(nyOn, nyOpenMin, nyCloseMin), text_color=mainText, bgcolor=nyRowBg, text_size=dashSize)
        table.cell(dash, 4, 3, f_fmtRangeValue(nyRangeNow) + " / " + f_fmtRatio(nyRangeNow, f_avgRange(nyRanges)), text_color=mainText, bgcolor=nyRowBg, text_size=dashSize)
        table.cell(dash, 5, 3, spacer, text_color=spacerTextColor, bgcolor=spacerBg, text_size=dashSize)

// ----------------------------------------------------------------------------
// Alerts: informational only. Use TradingView condition: Any alert() function call.
// ----------------------------------------------------------------------------
tokyoPreOpen = enableAlerts and alertPreSession and not tokyoOn and not na(tokyoOpenMin) and tokyoOpenMin <= leadWindowMinutes and nz(tokyoOpenMin[1], leadWindowMinutes + 1) > leadWindowMinutes
londonPreOpen = enableAlerts and alertPreSession and not londonOn and not na(londonOpenMin) and londonOpenMin <= leadWindowMinutes and nz(londonOpenMin[1], leadWindowMinutes + 1) > leadWindowMinutes
nyPreOpen = enableAlerts and alertPreSession and not nyOn and not na(nyOpenMin) and nyOpenMin <= leadWindowMinutes and nz(nyOpenMin[1], leadWindowMinutes + 1) > leadWindowMinutes

tokyoPreClose = enableAlerts and alertPreSession and tokyoOn and not na(tokyoCloseMin) and tokyoCloseMin <= leadWindowMinutes and nz(tokyoCloseMin[1], leadWindowMinutes + 1) > leadWindowMinutes
londonPreClose = enableAlerts and alertPreSession and londonOn and not na(londonCloseMin) and londonCloseMin <= leadWindowMinutes and nz(londonCloseMin[1], leadWindowMinutes + 1) > leadWindowMinutes
nyPreClose = enableAlerts and alertPreSession and nyOn and not na(nyCloseMin) and nyCloseMin <= leadWindowMinutes and nz(nyCloseMin[1], leadWindowMinutes + 1) > leadWindowMinutes

tokyoORDone = enableAlerts and alertOpeningRange and tokyoOn and not tokyoORBuilding and tokyoORBuilding[1] == true
londonORDone = enableAlerts and alertOpeningRange and londonOn and not londonORBuilding and londonORBuilding[1] == true
nyORDone = enableAlerts and alertOpeningRange and nyOn and not nyORBuilding and nyORBuilding[1] == true

tokyoPrevHitH = enableAlerts and alertPrevTouches and not tokyoPrevHiTouched and not na(tokyoPrevHi) and high >= tokyoPrevHi and low <= tokyoPrevHi
tokyoPrevHitL = enableAlerts and alertPrevTouches and not tokyoPrevLoTouched and not na(tokyoPrevLo) and high >= tokyoPrevLo and low <= tokyoPrevLo
londonPrevHitH = enableAlerts and alertPrevTouches and not londonPrevHiTouched and not na(londonPrevHi) and high >= londonPrevHi and low <= londonPrevHi
londonPrevHitL = enableAlerts and alertPrevTouches and not londonPrevLoTouched and not na(londonPrevLo) and high >= londonPrevLo and low <= londonPrevLo
nyPrevHitH = enableAlerts and alertPrevTouches and not nyPrevHiTouched and not na(nyPrevHi) and high >= nyPrevHi and low <= nyPrevHi
nyPrevHitL = enableAlerts and alertPrevTouches and not nyPrevLoTouched and not na(nyPrevLo) and high >= nyPrevLo and low <= nyPrevLo

if tokyoPrevHitH
    tokyoPrevHiTouched := true
if tokyoPrevHitL
    tokyoPrevLoTouched := true
if londonPrevHitH
    londonPrevHiTouched := true
if londonPrevHitL
    londonPrevLoTouched := true
if nyPrevHitH
    nyPrevHiTouched := true
if nyPrevHitL
    nyPrevLoTouched := true

string alertMsg = ""
if enableAlerts
    if tokyoPreOpen
        alertMsg += (alertMsg == "" ? "" : " | ") + "Tokyo opens soon: " + f_fmtMins(tokyoOpenMin)
    if londonPreOpen
        alertMsg += (alertMsg == "" ? "" : " | ") + "London opens soon: " + f_fmtMins(londonOpenMin)
    if nyPreOpen
        alertMsg += (alertMsg == "" ? "" : " | ") + "New York opens soon: " + f_fmtMins(nyOpenMin)

    if alertSessionChange and tokyoStart
        alertMsg += (alertMsg == "" ? "" : " | ") + "Tokyo session started"
    if alertSessionChange and londonStart
        alertMsg += (alertMsg == "" ? "" : " | ") + "London session started"
    if alertSessionChange and nyStart
        alertMsg += (alertMsg == "" ? "" : " | ") + "New York session started"

    if tokyoPreClose
        alertMsg += (alertMsg == "" ? "" : " | ") + "Tokyo closes soon: " + f_fmtMins(tokyoCloseMin)
    if londonPreClose
        alertMsg += (alertMsg == "" ? "" : " | ") + "London closes soon: " + f_fmtMins(londonCloseMin)
    if nyPreClose
        alertMsg += (alertMsg == "" ? "" : " | ") + "New York closes soon: " + f_fmtMins(nyCloseMin)

    if alertSessionChange and tokyoEnd
        alertMsg += (alertMsg == "" ? "" : " | ") + "Tokyo session ended"
    if alertSessionChange and londonEnd
        alertMsg += (alertMsg == "" ? "" : " | ") + "London session ended"
    if alertSessionChange and nyEnd
        alertMsg += (alertMsg == "" ? "" : " | ") + "New York session ended"

    if alertFocusChange and focusChanged and focusId > 0
        alertMsg += (alertMsg == "" ? "" : " | ") + "Focus changed to " + focusName
    if alertOverlapChange and overlapStart
        alertMsg += (alertMsg == "" ? "" : " | ") + "Session overlap started"
    if alertOverlapChange and overlapEnd
        alertMsg += (alertMsg == "" ? "" : " | ") + "Session overlap ended"

    if tokyoORDone
        alertMsg += (alertMsg == "" ? "" : " | ") + "Tokyo opening range completed"
    if londonORDone
        alertMsg += (alertMsg == "" ? "" : " | ") + "London opening range completed"
    if nyORDone
        alertMsg += (alertMsg == "" ? "" : " | ") + "New York opening range completed"

    if tokyoPrevHitH
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous Tokyo high"
    if tokyoPrevHitL
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous Tokyo low"
    if londonPrevHitH
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous London high"
    if londonPrevHitL
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous London low"
    if nyPrevHitH
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous New York high"
    if nyPrevHitL
        alertMsg += (alertMsg == "" ? "" : " | ") + "Price touched previous New York low"

if enableAlerts and str.length(alertMsg) > 0
    alert(alertMsg + " | Time context only. No signals or advice.", alert.freq_once_per_bar)
````
