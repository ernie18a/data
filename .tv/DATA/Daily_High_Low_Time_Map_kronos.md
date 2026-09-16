<!-- tradingview-pine-id: PUB;62841423a1af4479a43e80e558806094 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily High & Low Time Map (kronos)

Source: https://www.tradingview.com/script/u0etVs4Y-Daily-High-Low-Time-Map-HOD-LOD/

## Description

Daily High & Low Time Map

What it does
This indicator counts, across the completed trading days that your chart has loaded, which time window of the day produced the daily high and which produced the daily low. The result is a two-row heat strip in its own pane, lined up in time under the running day, plus a dashboard that answers the one question that actually matters intraday: at this hour, in how many of the past days was the final high still ahead? Every number carries its sample size, so you can see when a bright cell stands on three days instead of three hundred.

How it works
The script walks the chart bar by bar, never leaves the timeframe you are on and never requests data from a higher timeframe. A day is a span between two anchor points that you choose; inside that span each confirmed bar can move the running high and low. The time bucket of an extreme is taken from the opening time of the bar that produced it, so a later part of the day can never move an earlier reading.

[*] A day is closed on the first bar of the next day and written once into a ring buffer; the running day is never part of the statistics.
[*] The bucket index comes from the bar opening time in the anchor timezone, which follows daylight saving. The repeated hour of the autumn change stays inside the same day, which is capped at 100 % coverage instead of counting as an error.
[*] Days below the coverage threshold - half days, data gaps, the clipped first day of a replay - are dropped and reported as skipped instead of silently diluting the counts.
[*] Filters for weekday, day type and sample window are applied while counting; stored days are never modified. Shares carry a Wilson score interval, which stays inside 0 to 100 % even when a bucket holds no hits or every hit.

How to use it

[*] Add the script. It opens in its own pane below the chart.
[*] Pick the day definition that matches the instrument: midnight New York for index and FX charts, the 18:00 anchor for CME futures, the 09:30 anchor when only the cash session interests you, midnight UTC for symbols that trade around the clock.
[*] Read the upper row of the strip as "how often the daily high was made here" and the lower row as the same for the daily low. Brighter means more often.
[*] Read the dashboard line "High still ahead" as a conditional share over completed days, never as a statement about today.
[*] If the cells look pale and the note says the sample is small, widen the slot or load more history before you read anything into them.

What makes it original
Time-of-day statistics for highs and lows exist, and so do session boxes; what this script does differently is refuse to hand out a number without the evidence behind it. Every share is printed with the sample it came from and with a Wilson confidence interval, so a bucket built from eleven days does not read like one built from two hundred. Days are admitted only when they carry enough bars to be comparable, and the dropped ones are counted in plain sight. The map is a strip of buckets rather than a table, because the question is a shape. The conditional row extends the same idea forward: given the time of day, how much of the day's high-making is still ahead - again with the sample attached.

Inputs
Behaviour:

[*] Day definition - where a trading day starts: Midnight New York, Futures 18:00 NY, RTH 09:30 NY or Midnight UTC. Session windows use the same timezone, and an evening session is labelled by the calendar day it ends on.
[*] Slot width - 15, 30 or 60 minutes. A bucket narrower than one chart bar is raised automatically and the dashboard says so.
[*] Min day coverage % - a day counts only with at least this share of the bars of the fullest day on the chart. Range 10-100, default 60.
[*] Last N days - size of the ring buffer. Range 5-1000, default 250.
[*] Tie rule - which occurrence wins when the same price is reached twice in a day.
[*] Use start date and Start date - restrict the sample to days after a fixed date. Off by default.
[*] Mon, Tue, Wed, Thu, Fri - on by default. Sat and Sun - off by default. Auto-include weekends for 24/7 symbols - on by default; crypto includes both anyway.
[*] Day type - all days, or only those that closed above or below their open.
[*] Asia, London KZ, NY AM KZ, Lunch, NY PM KZ - session windows, one dashboard row each; a bucket counts when any part of it falls inside. NY AM KZ drives the session-start alert.
[*] Show Silver Bullet rows - three fixed one-hour rows. Off by default.
[*] Count current slot as still open - whether a day whose extreme fell into the current bucket counts as ahead. On by default.
[*] Ahead alert threshold % - level at which the ahead alert fires. Range 1-99, default 25.
[*] Ramp scaling - relative to the busiest bucket, or a fixed scale so two symbols can be compared.
[*] Strip mode - both rows, high only, low only, or one combined row counting either extreme.

Presentation: whether the strip, dashboard, live row, Wilson bounds, sparkline, session rows and the H and L markers are drawn, the dashboard corner and text size, the marker size and background, the two colour ramps and the theme.

Signals and alerts

[*] Entering high-frequency high slot - fires on bar close when price enters the bucket that held the daily high most often in the current sample.
[*] Entering high-frequency low slot - the same for the daily low.
[*] Ahead alert - fires on bar close the first time the share of days with a later high falls below the threshold.
[*] Session start - fires on the first bar inside the NY AM window.
[*] New running day extreme - fires on bar close when the running high or low of the day has moved.

The first three depend on the aggregation, which is evaluated on the most recent bar. They are meant for live use; on historical bars they stay silent.

Repainting
Every state change happens on a confirmed bar. The running day is written into the sample only on the first bar of the next day, so the current day never influences a count. The bucket of an extreme is taken from the opening time of the bar that made it and is stored once; nothing rewrites it later. There is no request for a higher timeframe and no lookahead, so a reload and a bar replay produce the same numbers.

Limitations

[*] The map is suppressed above a certain timeframe and whenever the chart bar does not divide the bucket width - on a daily chart every day is one bar, and on a 45-minute chart with 60-minute buckets some buckets get twice as many bars. The strip stays empty and the note line says why. Use a minute timeframe that divides the bucket width.
[*] The sample is the loaded chart history, nothing more: at 20 000 bars roughly 14 days on 1-minute futures, 51 on a 1-minute regular-hours stock chart, 72 on 5-minute futures, 256 on 5-minute regular hours, 217 on 15-minute futures, 430 on 30-minute and 870 on hourly. The dashboard prints the number it has.
[*] Small samples move. Below 30 days the cells are dimmed on purpose, and a share out of ten days is a number, not a finding.
[*] Buckets the chart has no bars for - the night hours of a regular-hours stock chart - stay dark. That is missing data, not a measurement.
[*] On a 1-minute chart the strip cannot be drawn more than 500 bars into the future; the dashboard reports how many buckets were left out.
[*] It describes the past of one symbol on one chart and says nothing about where today's high will be.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator("Daily High & Low Time Map (kronos)", shorttitle = "Time Map (kronos)", overlay = false, max_boxes_count = 250, max_labels_count = 20)

//#region TYPES ================================================================

enum DayAnchor
    midnightNy  = "Midnight New York"
    futuresNy   = "Futures 18:00 NY"
    rthNy       = "RTH 09:30 NY"
    midnightUtc = "Midnight UTC"

enum SlotWidth
    m15 = "15 min"
    m30 = "30 min"
    m60 = "60 min"

enum TieRule
    firstTouch = "First occurrence"
    lastTouch  = "Last occurrence"

enum DayFilter
    anyDay  = "All"
    upDay   = "Up days"
    downDay = "Down days"

enum StripMode
    bothRows = "Both rows"
    highOnly = "High only"
    lowOnly  = "Low only"
    combined = "Combined"

enum RampScale
    relativeMax = "Relative to max"
    absolute25  = "Absolute 0-25 %"

enum PanelTheme
    autoTone  = "Auto"
    darkTone  = "Dark"
    lightTone = "Light"

enum PanelSpot
    topRight    = "Top right"
    topLeft     = "Top left"
    bottomRight = "Bottom right"
    bottomLeft  = "Bottom left"

//#endregion

//#region CONSTANTS ============================================================

string TZ_NEW_YORK = "America/New_York"
string TZ_UTC      = "UTC"

int    MIN_PER_DAY = 1440
int    MS_PER_MIN  = 60000
int    MS_PER_DAY  = 86400000
int    HALF_DAY    = 720
int    FUTURES_MIN = 1080
int    RTH_MIN     = 570
int    LOW_SAMPLE  = 30
int    STEADY_MIN  = 100
int    MAX_FUTURE  = 500
int    PANEL_ROWS  = 24
float  WILSON_Z    = 1.96
float  ABS_SCALE   = 25.0

color  HIGH_RAMP_LOW  = #26a69a1a
color  HIGH_RAMP_HIGH = #26a69ae6
color  LOW_RAMP_LOW   = #ef53501a
color  LOW_RAMP_HIGH  = #ef5350e6
color  NEUTRAL_COLOR  = #b2b5beff
color  DARK_TEXT      = #d1d4dcff
color  LIGHT_TEXT     = #131722ff
color  PANEL_FRAME    = #4f586380

string GRP_DAY      = "Day"
string GRP_SLOTS    = "Slots"
string GRP_SAMPLE   = "Sample"
string GRP_FILTERS  = "Filters"
string GRP_SESSIONS = "Sessions"
string GRP_LIVE     = "Live"
string GRP_DISPLAY  = "Display"
string GRP_COLORS   = "Colors"

string SPARK_GLYPHS = " .:-=+*#"

string TIP_ANCHOR = """Where a trading day starts. Midnight New York suits index
and FX charts, Futures 18:00 NY matches the CME session, RTH 09:30 NY measures
only the regular cash session, Midnight UTC suits 24/7 symbols. Session windows
below are read in the same timezone as the anchor."""

string TIP_COVERAGE = """A day is counted only when it carries at least this
share of the bars of the fullest day found on this chart. Half days, data gaps
and the clipped first day of a replay are dropped and reported as skipped."""

string TIP_SLOT = """Width of one time bucket. A bucket narrower than one chart
bar cannot measure anything, so the script raises the width automatically and
says so in the dashboard."""

string TIP_TIE = """Which occurrence wins when the same price is reached twice
on one day. Only days with an exact repeat of the extreme are affected."""

string TIP_WEEKEND = """Symbols that trade around the clock have real Saturday
and Sunday sessions. With this on, both days are included even while their
checkboxes are off."""

string TIP_CURRENT = """Counts the running bucket as still open. On means a day
whose extreme fell into the current bucket is treated as ahead, off means it is
treated as done."""

string TIP_RAMP = """Relative to max scales the brightest cell to the busiest
bucket of this chart. Absolute keeps the scale fixed so two symbols can be
compared."""

string TIP_AHEAD = """Threshold for the alert that fires once the share of days
with a later high falls under it."""

string TIP_DETAIL = """Off keeps the essential two-row panel in the indicator
pane. On moves the full diagnostic table onto the main chart."""

string TIP_TODAY_TIME = """Shows the opening time of the extreme's bucket in
the selected day-anchor timezone, not the exact tick time of the extreme."""

//#endregion

//#region INPUTS ===============================================================

DayAnchor  anchorInput        = input.enum(DayAnchor.midnightNy, "Day definition", group = GRP_DAY, tooltip = TIP_ANCHOR)
int        coverageInput      = input.int(60, "Min day coverage %", minval = 10, maxval = 100, group = GRP_DAY, tooltip = TIP_COVERAGE)

SlotWidth  slotInput          = input.enum(SlotWidth.m30, "Slot width", group = GRP_SLOTS, tooltip = TIP_SLOT)
TieRule    tieInput           = input.enum(TieRule.firstTouch, "Tie rule", group = GRP_SLOTS, tooltip = TIP_TIE)

int        lastNInput         = input.int(250, "Last N days", minval = 5, maxval = 1000, group = GRP_SAMPLE)
bool       useStartInput      = input.bool(false, "Use start date", group = GRP_SAMPLE)
int        startDateInput     = input.time(timestamp("2026-01-01T00:00:00+0000"), "Start date", group = GRP_SAMPLE, active = useStartInput)

bool       autoWeekendInput   = input.bool(true, "Auto-include weekends for 24/7 symbols", group = GRP_FILTERS, tooltip = TIP_WEEKEND)
bool       monInput           = input.bool(true, "Mon", inline = "wd1", group = GRP_FILTERS)
bool       tueInput           = input.bool(true, "Tue", inline = "wd1", group = GRP_FILTERS)
bool       wedInput           = input.bool(true, "Wed", inline = "wd1", group = GRP_FILTERS)
bool       thuInput           = input.bool(true, "Thu", inline = "wd1", group = GRP_FILTERS)
bool       friInput           = input.bool(true, "Fri", inline = "wd2", group = GRP_FILTERS)
bool       satInput           = input.bool(false, "Sat", inline = "wd2", group = GRP_FILTERS, active = not autoWeekendInput)
bool       sunInput           = input.bool(false, "Sun", inline = "wd2", group = GRP_FILTERS, active = not autoWeekendInput)
DayFilter  dayTypeInput       = input.enum(DayFilter.anyDay, "Day type", group = GRP_FILTERS)

bool       showSessionInput   = input.bool(true, "Show sessions", group = GRP_SESSIONS)
string     asiaInput          = input.session("2000-0000", "Asia", group = GRP_SESSIONS, active = showSessionInput)
string     londonInput        = input.session("0200-0500", "London KZ", group = GRP_SESSIONS, active = showSessionInput)
string     nyAmInput          = input.session("0830-1100", "NY AM KZ", group = GRP_SESSIONS, active = showSessionInput)
string     lunchInput         = input.session("1200-1300", "Lunch", group = GRP_SESSIONS, active = showSessionInput)
string     nyPmInput          = input.session("1330-1600", "NY PM KZ", group = GRP_SESSIONS, active = showSessionInput)
bool       silverInput        = input.bool(false, "Show Silver Bullet rows", group = GRP_SESSIONS, active = showSessionInput)

bool       showLiveInput      = input.bool(true, "Show live conditional row", group = GRP_LIVE)
bool       countCurrentInput  = input.bool(true, "Count current slot as still open", group = GRP_LIVE, active = showLiveInput, tooltip = TIP_CURRENT)
int        aheadAlertInput    = input.int(25, "Ahead alert threshold %", minval = 1, maxval = 99, group = GRP_LIVE, active = showLiveInput, tooltip = TIP_AHEAD)
bool       showTodayInput     = input.bool(true, "Show today's extreme markers", group = GRP_LIVE)

bool       showStripInput     = input.bool(true, "Show heat strip", group = GRP_DISPLAY)
StripMode  stripModeInput     = input.enum(StripMode.bothRows, "Strip mode", group = GRP_DISPLAY, active = showStripInput)
bool       showPanelInput     = input.bool(true, "Show dashboard", group = GRP_DISPLAY)
bool       detailedPanelInput = input.bool(false, "Detailed dashboard", group = GRP_DISPLAY, active = showPanelInput, tooltip = TIP_DETAIL)
bool       todayAsTimeInput   = input.bool(true, "Show today's extremes as time", group = GRP_DISPLAY, active = showPanelInput and showTodayInput, tooltip = TIP_TODAY_TIME)
PanelSpot  panelSpotInput     = input.enum(PanelSpot.topRight, "Dashboard position", group = GRP_DISPLAY, active = showPanelInput)
int        panelSizeInput     = input.int(12, "Dashboard size", minval = 10, maxval = 24, group = GRP_DISPLAY, active = showPanelInput)
bool       showWilsonInput    = input.bool(true, "Show Wilson interval", group = GRP_DISPLAY, active = showPanelInput and detailedPanelInput and showLiveInput)
bool       showSparkInput     = input.bool(true, "Show sparkline", group = GRP_DISPLAY, active = showPanelInput and detailedPanelInput)
int        markerSizeInput    = input.int(12, "Marker size", minval = 10, maxval = 30, group = GRP_DISPLAY, active = showTodayInput)
bool       markerBgInput      = input.bool(false, "Label background", group = GRP_DISPLAY, active = showTodayInput)

color      highLowColorInput  = input.color(HIGH_RAMP_LOW, "High ramp", inline = "hr", group = GRP_COLORS, active = showStripInput)
color      highTopColorInput  = input.color(HIGH_RAMP_HIGH, "", inline = "hr", group = GRP_COLORS, active = showStripInput)
color      lowLowColorInput   = input.color(LOW_RAMP_LOW, "Low ramp", inline = "lr", group = GRP_COLORS, active = showStripInput)
color      lowTopColorInput   = input.color(LOW_RAMP_HIGH, "", inline = "lr", group = GRP_COLORS, active = showStripInput)
PanelTheme themeInput         = input.enum(PanelTheme.autoTone, "Theme", group = GRP_COLORS)
RampScale  rampInput          = input.enum(RampScale.relativeMax, "Ramp scaling", group = GRP_COLORS, active = showStripInput, tooltip = TIP_RAMP)

//#endregion

//#region FUNCTIONS ============================================================

// @function          Interpolates between two colors without a named color.
// @param fromColor   (series color) Color at ratio 0.
// @param toColor     (series color) Color at ratio 1.
// @param ratio       (series float) Position in 0 .. 1, clamped.
// @returns           (series color) Interpolated color.
rampBetween(series color fromColor, series color toColor, series float ratio) =>
    float safeRatio = math.min(1.0, math.max(0.0, ratio))
    color.from_gradient(safeRatio, 0.0, 1.0, fromColor, toColor)

// @function          Wilson score interval for a share, in percent.
// @param hits        (series int) Number of successes.
// @param total       (series int) Sample size.
// @param zScore      (simple float) Normal quantile of the confidence level.
// @returns           ([series float, series float]) Lower and upper bound,
//                    clamped to 0 .. 100 so the interval never leaves the axis.
wilsonBounds(series int hits, series int total, simple float zScore) =>
    float lowBound  = 0.0
    float highBound = 0.0
    if total > 0
        float share  = 1.0 * hits / total
        float denom  = 1.0 + zScore * zScore / total
        float centre = share + zScore * zScore / (2 * total)
        float spread = share * (1 - share) / total
        float extra  = zScore * zScore / (4 * total * total)
        float margin = zScore * math.sqrt(spread + extra)
        lowBound  := math.max(0.0, (centre - margin) / denom) * 100.0
        highBound := math.min(1.0, (centre + margin) / denom) * 100.0
    [lowBound, highBound]

// @function          Reads the first half of a session string as minutes.
// @param spec        (series string) Session specification, "HHMM-HHMM".
// @returns           (series int) Minutes since local midnight.
sessionFromMinute(series string spec) =>
    int result = 0
    if str.length(spec) >= 9
        float hourPart = str.tonumber(str.substring(spec, 0, 2))
        float minPart  = str.tonumber(str.substring(spec, 2, 4))
        bool  readable = not na(hourPart) and not na(minPart)
        result := readable ? int(hourPart) * 60 + int(minPart) : 0
    result

// @function          Reads the second half of a session string as minutes.
// @param spec        (series string) Session specification, "HHMM-HHMM".
// @returns           (series int) Minutes since local midnight. A trailing
//                    "0000" means midnight and is returned as 1440.
sessionToMinute(series string spec) =>
    int result = 1440
    if str.length(spec) >= 9
        float hourPart = str.tonumber(str.substring(spec, 5, 7))
        float minPart  = str.tonumber(str.substring(spec, 7, 9))
        bool  readable = not na(hourPart) and not na(minPart)
        int   raw      = readable ? int(hourPart) * 60 + int(minPart) : 0
        result := raw == 0 ? 1440 : raw
    result

// @function          Membership of a wall-clock minute in a session window.
// @param minuteOfDay (series int) Minute since local midnight.
// @param fromMinute  (series int) Window start.
// @param toMinute    (series int) Window end; may wrap past midnight.
// @returns           (series bool) True when the minute lies inside.
inWindow(series int minuteOfDay, series int fromMinute, series int toMinute) =>
    int reach  = toMinute > fromMinute ? toMinute - fromMinute : toMinute + 1440 - fromMinute
    int offset = (minuteOfDay - fromMinute + 1440) % 1440
    offset < reach

// @function          Overlap of a whole slot with a session window.
// @param startMinute (series int) Wall-clock minute the slot starts at.
// @param width       (series int) Slot width in minutes.
// @param fromMinute  (series int) Window start.
// @param toMinute    (series int) Window end; may wrap past midnight.
// @returns           (series bool) True when any minute of the slot is inside.
slotTouchesWindow(series int startMinute, series int width,
  series int fromMinute, series int toMinute) =>
    bool hit = false
    for step = 0 to width - 1
        if not hit and inWindow((startMinute + step) % MIN_PER_DAY, fromMinute, toMinute)
            hit := true
    hit

// @function          One ASCII glyph for a share in 0 .. 100.
// @param share       (series float) Share in percent.
// @param glyphs      (simple string) Ramp of glyphs, densest last.
// @returns           (series string) Single character of `glyphs`.
sparkGlyph(series float share, simple string glyphs) =>
    int steps = str.length(glyphs)
    int idx   = math.min(steps - 1, math.max(0, int(share * steps / 100.0)))
    str.substring(glyphs, idx, idx + 1)

// @function          Formats a share together with its sample size.
// @param hits        (series int) Successes.
// @param total       (series int) Sample size.
// @returns           (series string) Percentage and n, or an empty-sample hint.
shareText(series int hits, series int total) =>
    string body = str.tostring(hits * 100.0 / math.max(1, total), "#.#")
    total <= 0 ? "no days in sample" : body + " % (n=" + str.tostring(total) + ")"

// @function          Formats a minute of day as HH:MM.
// @param minuteOfDay (series int) Minute since local midnight, wrapping allowed.
// @returns           (series string) Zero-padded 24-hour wall-clock time.
clockText(series int minuteOfDay) =>
    int cleanMinute = (minuteOfDay % MIN_PER_DAY + MIN_PER_DAY) % MIN_PER_DAY
    // Pine's `/` produces a float even for integer operands. Cast the floored
    // hour explicitly so 115 minutes renders as 01:55, never 01.916666667:55.
    int hourPart    = int(math.floor(cleanMinute / 60.0))
    int minutePart  = cleanMinute % 60
    string hourText = (hourPart < 10 ? "0" : "") + str.tostring(hourPart)
    string minText  = (minutePart < 10 ? "0" : "") + str.tostring(minutePart)
    hourText + ":" + minText

// @function          Formats one stored slot without recalculating its identity.
// @param slot        (series int) Stored slot index of the extreme.
// @param anchorStart (series int) Selected trading-day anchor in wall-clock minutes.
// @param width       (series int) Effective slot width in minutes.
// @param asTime      (series bool) True for bucket start time, false for slot number.
// @returns           (series string) Time, slot notation, or no-bar hint.
slotDisplay(series int slot, series int anchorStart, series int width,
  series bool asTime) =>
    string result = "no confirmed bar yet"
    if slot >= 0
        result := asTime ? clockText(anchorStart + slot * width)
          : "slot " + str.tostring(slot)
    result

// @function          Writes one two-column dashboard row.
// @param board       (series table) Target table.
// @param row         (series int) Row index to write.
// @param headText    (series string) Left column.
// @param valueText   (series string) Right column.
// @param tone        (series color) Text color.
// @param glyphSize   (series int) Text size in points.
// @returns           (series int) Index of the next free row.
panelRow(series table board, series int row, series string headText,
  series string valueText, series color tone, series int glyphSize) =>
    table.cell(board, 0, row, headText, text_color = tone, text_size = glyphSize)
    table.cell(board, 1, row, valueText, text_color = tone, text_size = glyphSize)
    row + 1

//#endregion

//#region CALCULATIONS =========================================================

int  nyMinuteOfDay  = hour(time, TZ_NEW_YORK) * 60 + minute(time, TZ_NEW_YORK)
int  utcMinuteOfDay = hour(time, TZ_UTC) * 60 + minute(time, TZ_UTC)
int  rawOffset      = (nyMinuteOfDay - utcMinuteOfDay + MIN_PER_DAY) % MIN_PER_DAY
int  nyOffsetMin    = rawOffset > HALF_DAY ? rawOffset - MIN_PER_DAY : rawOffset
bool utcAnchor      = anchorInput == DayAnchor.midnightUtc
int  anchorOffset   = utcAnchor ? 0 : nyOffsetMin
int  anchorMinute   = utcAnchor ? utcMinuteOfDay : nyMinuteOfDay

int anchorStart = switch anchorInput
    DayAnchor.futuresNy => FUTURES_MIN
    DayAnchor.rthNy     => RTH_MIN
    =>                     0

int wallMs = time + anchorOffset * MS_PER_MIN
int dayKey = int(math.floor((wallMs - anchorStart * MS_PER_MIN) / MS_PER_DAY))
int relMin = (anchorMinute - anchorStart + MIN_PER_DAY) % MIN_PER_DAY

int chartTfMin  = math.max(1, int(timeframe.in_seconds(timeframe.period) / 60))
int wantedWidth = switch slotInput
    SlotWidth.m15 => 15
    SlotWidth.m30 => 30
    =>               60

int slotMinutes = 60
if wantedWidth <= 15 and chartTfMin <= 15 and 15 % chartTfMin == 0
    slotMinutes := 15
else if wantedWidth <= 30 and chartTfMin <= 30 and 30 % chartTfMin == 0
    slotMinutes := 30

bool slotRaised = slotMinutes != wantedWidth
int  slotCount  = MIN_PER_DAY / slotMinutes
int  slotIdx    = relMin / slotMinutes
var bool gridOffset = false
if barstate.isconfirmed and relMin % slotMinutes + chartTfMin > slotMinutes
    gridOffset := true
bool tooCoarse  = chartTfMin > slotMinutes
  or slotMinutes % chartTfMin != 0 or gridOffset

var float dayHigh        = na
var float dayLow         = na
var float dayOpenPrice   = na
var float dayClosePrice  = na
var int   dayHighSlot    = -1
var int   dayLowSlot     = -1
var int   dayBarCount    = 0
var int   dayStartMs     = 0
var int   dayAnchorMs    = 0
var int   dayFirstSlot   = -1
var bool  dayHighOnOpen  = false
var bool  dayLowOnOpen   = false
var int   dayKeyOfState  = na

var array<int>  recHighSlot = array.new<int>()
var array<int>  recLowSlot  = array.new<int>()
var array<int>  recBarCount = array.new<int>()
var array<int>  recDow      = array.new<int>()
var array<bool> recUpDay    = array.new<bool>()
var array<int>  recStartMs  = array.new<int>()
var array<bool> slotSeen    = array.new<bool>(slotCount, false)

bool confirmedBar = barstate.isconfirmed
bool newDayBar    = na(dayKey[1]) or dayKey != dayKey[1]
bool tieLast      = tieInput == TieRule.lastTouch
int  labelMs      = anchorStart >= HALF_DAY ? dayAnchorMs + MS_PER_DAY : dayAnchorMs
int  startDow     = utcAnchor ? dayofweek(labelMs, TZ_UTC) : dayofweek(labelMs, TZ_NEW_YORK)

if confirmedBar
    if newDayBar and dayBarCount > 0
        array.push(recHighSlot, dayHighSlot)
        array.push(recLowSlot, dayLowSlot)
        array.push(recBarCount, dayBarCount)
        array.push(recDow, startDow)
        array.push(recUpDay, dayClosePrice > dayOpenPrice)
        array.push(recStartMs, dayStartMs)
        while array.size(recHighSlot) > lastNInput
            array.shift(recHighSlot)
            array.shift(recLowSlot)
            array.shift(recBarCount)
            array.shift(recDow)
            array.shift(recUpDay)
            array.shift(recStartMs)
    if newDayBar
        dayKeyOfState   := dayKey
        dayHigh        := na
        dayLow         := na
        dayOpenPrice   := open
        dayHighSlot    := -1
        dayLowSlot     := -1
        dayBarCount    := 0
        dayStartMs     := time
        dayAnchorMs    := time - relMin * MS_PER_MIN
        dayFirstSlot   := -1
        dayHighOnOpen  := false
        dayLowOnOpen   := false
    if slotIdx >= 0 and slotIdx < slotCount
        array.set(slotSeen, slotIdx, true)
    if dayFirstSlot < 0
        dayFirstSlot := slotIdx
    bool madeHigh = na(dayHigh) or high > dayHigh or (tieLast and high >= dayHigh)
    bool madeLow  = na(dayLow) or low < dayLow or (tieLast and low <= dayLow)
    if madeHigh
        dayHigh       := na(dayHigh) ? high : math.max(dayHigh, high)
        dayHighSlot   := slotIdx
        dayHighOnOpen := slotIdx == dayFirstSlot
    if madeLow
        dayLow       := na(dayLow) ? low : math.min(dayLow, low)
        dayLowSlot   := slotIdx
        dayLowOnOpen := slotIdx == dayFirstSlot
    dayBarCount   += 1
    dayClosePrice := close

var array<int> highCount = array.new<int>(slotCount, 0)
var array<int> lowCount  = array.new<int>(slotCount, 0)
var int sampleSize  = 0
var int skippedDays = 0
var int filteredDays = 0
var int maxDayBars  = 0
var int aheadHigh   = 0
var int aheadLow    = 0
var int topHighSlot = -1
var int topLowSlot  = -1
var int peakHigh    = 0
var int peakLow     = 0
var int peakBoth    = 0

bool weekendAuto = autoWeekendInput and syminfo.type == "crypto"
bool satActive   = satInput or weekendAuto
bool sunActive   = sunInput or weekendAuto

float aheadShare = na
bool  enteredHigh  = false
bool  enteredLow   = false
bool  aheadDropped = false

if barstate.islast
    for i = 0 to slotCount - 1
        array.set(highCount, i, 0)
        array.set(lowCount, i, 0)
    sampleSize  := 0
    skippedDays := 0
    filteredDays := 0
    maxDayBars  := 0
    aheadHigh   := 0
    aheadLow    := 0
    if array.size(recBarCount) > 0
        for i = 0 to array.size(recBarCount) - 1
            maxDayBars := math.max(maxDayBars, array.get(recBarCount, i))
    if array.size(recHighSlot) > 0 and not tooCoarse
        for i = 0 to array.size(recHighSlot) - 1
            int   barsOfDay = array.get(recBarCount, i)
            float coverRaw  = maxDayBars > 0 ? barsOfDay * 100.0 / maxDayBars : 0.0
            int   coverPct  = math.min(100, int(math.round(coverRaw)))
            int   dowOfDay  = array.get(recDow, i)
            bool  upOfDay   = array.get(recUpDay, i)
            bool dowActive = switch dowOfDay
                1 => sunActive
                2 => monInput
                3 => tueInput
                4 => wedInput
                5 => thuInput
                6 => friInput
                =>   satActive
            bool wantsUp    = dayTypeInput == DayFilter.upDay
            bool typeActive = dayTypeInput == DayFilter.anyDay or wantsUp == upOfDay
            bool afterStart = not useStartInput or array.get(recStartMs, i) >= startDateInput
            if coverPct < coverageInput
                skippedDays += 1
            else if dowActive and typeActive and afterStart
                int highOfDay = array.get(recHighSlot, i)
                int lowOfDay  = array.get(recLowSlot, i)
                if highOfDay >= 0 and highOfDay < slotCount
                    array.set(highCount, highOfDay, array.get(highCount, highOfDay) + 1)
                if lowOfDay >= 0 and lowOfDay < slotCount
                    array.set(lowCount, lowOfDay, array.get(lowCount, lowOfDay) + 1)
                bool highAhead = countCurrentInput ? highOfDay >= slotIdx : highOfDay > slotIdx
                bool lowAhead  = countCurrentInput ? lowOfDay >= slotIdx : lowOfDay > slotIdx
                aheadHigh  += highAhead ? 1 : 0
                aheadLow   += lowAhead ? 1 : 0
                sampleSize += 1
            else
                filteredDays += 1
    peakHigh    := 0
    peakLow     := 0
    peakBoth    := 0
    topHighSlot := -1
    topLowSlot  := -1
    for i = 0 to slotCount - 1
        int highHits = array.get(highCount, i)
        int lowHits  = array.get(lowCount, i)
        if highHits > peakHigh
            peakHigh    := highHits
            topHighSlot := i
        if lowHits > peakLow
            peakLow    := lowHits
            topLowSlot := i
        if highHits + lowHits > peakBoth
            peakBoth := highHits + lowHits
    aheadShare := sampleSize > 0 ? aheadHigh * 100.0 / sampleSize : na
    bool slotChanged = slotIdx != slotIdx[1]
    enteredHigh := confirmedBar and slotChanged and topHighSlot == slotIdx
    enteredLow  := confirmedBar and slotChanged and topLowSlot == slotIdx
    bool wasAbove = not na(aheadShare[1]) and aheadShare[1] >= aheadAlertInput
    bool nowBelow = not na(aheadShare) and aheadShare < aheadAlertInput
    aheadDropped := confirmedBar and nowBelow and wasAbove and showLiveInput

int  nyAmFrom      = sessionFromMinute(nyAmInput)
int  nyAmTo        = sessionToMinute(nyAmInput)
bool insideNyAm    = inWindow(anchorMinute, nyAmFrom, nyAmTo)
bool wasInsideNyAm = inWindow(anchorMinute[1], nyAmFrom, nyAmTo)
bool sessionOpened = confirmedBar and showSessionInput and insideNyAm and not wasInsideNyAm
bool extremeMoved  = dayHigh != dayHigh[1] or dayLow != dayLow[1]
bool newDayExtreme = confirmedBar and dayBarCount > 1 and extremeMoved

//#endregion

//#region VISUALS ==============================================================

plot(0.0, "Scale floor", color.new(NEUTRAL_COLOR, 100), 1)
plot(2.0, "Scale ceiling", color.new(NEUTRAL_COLOR, 100), 1)

color panelText = switch themeInput
    PanelTheme.darkTone  => DARK_TEXT
    PanelTheme.lightTone => LIGHT_TEXT
    =>                      chart.fg_color

int panelPos = switch panelSpotInput
    PanelSpot.topLeft     => 1
    PanelSpot.bottomRight => 2
    PanelSpot.bottomLeft  => 3
    =>                       0

var array<box> highBoxes = array.new<box>()
var array<box> lowBoxes  = array.new<box>()
var label todayHighMark  = na
var label todayLowMark   = na
var table compactBoard   = table.new(position.top_right, 2, 2, border_width = 1)
var table detailBoard    = table.new(position.top_right, 2, PANEL_ROWS,
  border_width = 1, force_overlay = true)

if barstate.islast
    int  chartMs     = chartTfMin * MS_PER_MIN
    int  maxRightMs  = time + MAX_FUTURE * chartMs
    int  hiddenSlots = 0
    bool bothRows    = stripModeInput == StripMode.bothRows
    bool combinedRow = stripModeInput == StripMode.combined
    bool stripOn     = showStripInput and not tooCoarse
    bool showHighRow = stripOn and (bothRows or combinedRow
      or stripModeInput == StripMode.highOnly)
    bool showLowRow  = stripOn and (bothRows or stripModeInput == StripMode.lowOnly)
    bool oneRowOnly  = not bothRows
    float highFloor  = oneRowOnly and not showLowRow ? 0.0 : 1.0
    float lowTop     = oneRowOnly and not showHighRow ? 2.0 : 1.0
    color blankTone  = color.new(NEUTRAL_COLOR, 100)
    for i = 0 to slotCount - 1
        int  leftMs   = dayAnchorMs + i * slotMinutes * MS_PER_MIN
        int  rightMs  = leftMs + slotMinutes * MS_PER_MIN
        bool beyond   = leftMs > maxRightMs
        hiddenSlots  += beyond ? 1 : 0
        int  leftUsed  = math.min(leftMs, maxRightMs)
        int  rightUsed = math.min(rightMs, maxRightMs)
        int  rawHigh   = array.get(highCount, i)
        int  rawLow    = array.get(lowCount, i)
        int  highHits  = combinedRow ? rawHigh + rawLow : rawHigh
        int  lowHits   = rawLow
        float highSpan = sampleSize > 0 ? highHits * 100.0 / sampleSize : 0.0
        float lowSpan  = sampleSize > 0 ? lowHits * 100.0 / sampleSize : 0.0
        int   highPeak = combinedRow ? peakBoth : peakHigh
        float highRel  = highPeak > 0 ? 1.0 * highHits / highPeak : 0.0
        float lowRel   = peakLow > 0 ? 1.0 * lowHits / peakLow : 0.0
        bool  absolute = rampInput == RampScale.absolute25
        float highGrade = absolute ? highSpan / ABS_SCALE : highRel
        float lowGrade  = absolute ? lowSpan / ABS_SCALE : lowRel
        bool  thinCell  = sampleSize < LOW_SAMPLE or not array.get(slotSeen, i)
        color highTone  = rampBetween(highLowColorInput, highTopColorInput, highGrade)
        color lowTone   = rampBetween(lowLowColorInput, lowTopColorInput, lowGrade)
        color highDrawn = thinCell ? color.new(highTone, 80) : highTone
        color lowDrawn  = thinCell ? color.new(lowTone, 80) : lowTone
        color highFill  = beyond or not showHighRow ? blankTone : highDrawn
        color lowFill   = beyond or not showLowRow ? blankTone : lowDrawn
        if array.size(highBoxes) <= i
            array.push(highBoxes, box.new(leftUsed, 2.0, rightUsed, highFloor,
              xloc = xloc.bar_time, border_color = blankTone, bgcolor = highFill))
        else
            box.set_lefttop(array.get(highBoxes, i), leftUsed, 2.0)
            box.set_rightbottom(array.get(highBoxes, i), rightUsed, highFloor)
            box.set_bgcolor(array.get(highBoxes, i), highFill)
        if array.size(lowBoxes) <= i
            array.push(lowBoxes, box.new(leftUsed, lowTop, rightUsed, 0.0,
              xloc = xloc.bar_time, border_color = blankTone, bgcolor = lowFill))
        else
            box.set_lefttop(array.get(lowBoxes, i), leftUsed, lowTop)
            box.set_rightbottom(array.get(lowBoxes, i), rightUsed, 0.0)
            box.set_bgcolor(array.get(lowBoxes, i), lowFill)

    label.delete(todayHighMark)
    label.delete(todayLowMark)
    int halfSlotMs = slotMinutes * MS_PER_MIN / 2
    color markBack = color.new(chart.bg_color, 100)
    if showTodayInput and dayHighSlot >= 0
        int markMs = dayAnchorMs + dayHighSlot * slotMinutes * MS_PER_MIN + halfSlotMs
        color markFace = markerBgInput ? color.new(highTopColorInput, 40) : markBack
        todayHighMark := label.new(markMs, 1.5, "H", xloc = xloc.bar_time,
          style = label.style_label_down, color = markFace,
          textcolor = panelText, size = markerSizeInput)
    if showTodayInput and dayLowSlot >= 0
        int markMs = dayAnchorMs + dayLowSlot * slotMinutes * MS_PER_MIN + halfSlotMs
        color markFace = markerBgInput ? color.new(lowTopColorInput, 40) : markBack
        todayLowMark := label.new(markMs, 0.5, "L", xloc = xloc.bar_time,
          style = label.style_label_up, color = markFace,
          textcolor = panelText, size = markerSizeInput)

    // Compact table stays in the indicator pane. The detail table is created
    // with force_overlay so only that table, never the heat strip, enters the
    // main price pane.
    table.clear(compactBoard, 0, 0, 1, 1)
    table.clear(detailBoard, 0, 0, 1, PANEL_ROWS - 1)

    string compactWarning = ""
    if tooCoarse
        compactWarning := "Timeframe too high"
    else if slotRaised
        compactWarning := "Using " + str.tostring(slotMinutes) + " min slots"
    else if sampleSize < STEADY_MIN
        compactWarning := "Limited history"
    else if hiddenSlots > 0
        compactWarning := "Some slots hidden"

    if showPanelInput and not detailedPanelInput
        string stillCell = str.tostring(sampleSize) + " days"
        if tooCoarse
            stillCell := "Timeframe too high | " + str.tostring(sampleSize) + " days"
        else if showLiveInput and sampleSize > 0
            string highAheadText = str.tostring(aheadHigh * 100.0 / sampleSize, "#") + "%"
            string lowAheadText  = str.tostring(aheadLow * 100.0 / sampleSize, "#") + "%"
            stillCell := "High " + highAheadText + " | Low " + lowAheadText
              + " | Based on " + str.tostring(sampleSize) + " days"
        else if showLiveInput
            stillCell := "No completed days"
        if str.length(compactWarning) > 0 and not tooCoarse
            stillCell := stillCell + " | " + compactWarning
        int compactRow = panelRow(compactBoard, 0, "Final extreme later?", stillCell,
          panelText, panelSizeInput)
        bool todayCurrent = dayKeyOfState == dayKey
        if showTodayInput and not tooCoarse
            string highToday = slotDisplay(dayHighSlot, anchorStart,
              slotMinutes, todayAsTimeInput)
            string lowToday = slotDisplay(dayLowSlot, anchorStart,
              slotMinutes, todayAsTimeInput)
            compactRow := panelRow(compactBoard, compactRow, "Current extreme times",
              todayCurrent ? "High " + highToday + " | Low " + lowToday : "High - | Low -",
              panelText, panelSizeInput)
        if panelPos == 1
            table.set_position(compactBoard, position.top_left)
        else if panelPos == 2
            table.set_position(compactBoard, position.bottom_right)
        else if panelPos == 3
            table.set_position(compactBoard, position.bottom_left)
        else
            table.set_position(compactBoard, position.top_right)
        table.set_frame_color(compactBoard, PANEL_FRAME)
        table.set_border_color(compactBoard, PANEL_FRAME)

    if showPanelInput and detailedPanelInput
        string tzLabel = utcAnchor ? "UTC" : "New York"
        string headRight = syminfo.ticker + " " + timeframe.period
        int rowAt = panelRow(detailBoard, 0, "HOD / LOD Time Map", headRight,
          panelText, panelSizeInput)
        string dayCell = str.tostring(anchorInput) + ", "
          + str.tostring(slotMinutes) + " min (" + tzLabel + ")"
        rowAt := panelRow(detailBoard, rowAt, "Day / slot", dayCell,
          panelText, panelSizeInput)
        string sampleCell = str.tostring(sampleSize) + " of "
          + str.tostring(array.size(recHighSlot)) + ", "
          + str.tostring(skippedDays) + " skipped, "
          + str.tostring(filteredDays) + " filtered"
        rowAt := panelRow(detailBoard, rowAt, "Days in sample", sampleCell,
          panelText, panelSizeInput)
        if showLiveInput
            [aheadFrom, aheadTo] = wilsonBounds(aheadHigh, sampleSize, WILSON_Z)
            string band = " [" + str.tostring(aheadFrom, "#.#") + " - "
              + str.tostring(aheadTo, "#.#") + "]"
            bool bandOn = showWilsonInput and sampleSize > 0
            string aheadCell = shareText(aheadHigh, sampleSize) + (bandOn ? band : "")
            rowAt := panelRow(detailBoard, rowAt, "High still ahead", aheadCell,
              panelText, panelSizeInput)
            rowAt := panelRow(detailBoard, rowAt, "Low still ahead",
              shareText(aheadLow, sampleSize), panelText, panelSizeInput)
        if showTodayInput and dayKeyOfState == dayKey
            string highSlotShare = dayHighSlot < 0 ? "" :
              shareText(array.get(highCount, dayHighSlot), sampleSize)
            string highToday = slotDisplay(dayHighSlot, anchorStart,
              slotMinutes, todayAsTimeInput)
            string highOpenNote = dayHighOnOpen ? ", set in the opening bucket" : ""
            string highDetail = dayHighSlot < 0 ? highToday
              : highToday + " (" + highSlotShare + ")" + highOpenNote
            string highLabel = todayAsTimeInput ? "Today's high time" : "Today's high slot"
            rowAt := panelRow(detailBoard, rowAt, highLabel, highDetail,
              panelText, panelSizeInput)

            string lowSlotShare = dayLowSlot < 0 ? "" :
              shareText(array.get(lowCount, dayLowSlot), sampleSize)
            string lowToday = slotDisplay(dayLowSlot, anchorStart,
              slotMinutes, todayAsTimeInput)
            string lowOpenNote = dayLowOnOpen ? ", set in the opening bucket" : ""
            string lowDetail = dayLowSlot < 0 ? lowToday
              : lowToday + " (" + lowSlotShare + ")" + lowOpenNote
            string lowLabel = todayAsTimeInput ? "Today's low time" : "Today's low slot"
            rowAt := panelRow(detailBoard, rowAt, lowLabel, lowDetail,
              panelText, panelSizeInput)
        if showSparkInput
            string sparkLine = ""
            int running = 0
            for i = 0 to slotCount - 1
                running += array.get(highCount, i)
                float done = sampleSize > 0 ? running * 100.0 / sampleSize : 0.0
                sparkLine := sparkLine + sparkGlyph(done, SPARK_GLYPHS)
            rowAt := panelRow(detailBoard, rowAt, "High already set", sparkLine,
              panelText, panelSizeInput)
        if showSessionInput
            for s = 0 to 4
                string windowName = switch s
                    0 => "Asia"
                    1 => "London KZ"
                    2 => "NY AM KZ"
                    3 => "Lunch"
                    =>   "NY PM KZ"
                string windowSpec = switch s
                    0 => asiaInput
                    1 => londonInput
                    2 => nyAmInput
                    3 => lunchInput
                    =>   nyPmInput
                int fromMinute = sessionFromMinute(windowSpec)
                int toMinute   = sessionToMinute(windowSpec)
                int windowHigh = 0
                int windowLow  = 0
                for i = 0 to slotCount - 1
                    int wallMinute = (i * slotMinutes + anchorStart) % MIN_PER_DAY
                    if slotTouchesWindow(wallMinute, slotMinutes, fromMinute, toMinute)
                        windowHigh += array.get(highCount, i)
                        windowLow  += array.get(lowCount, i)
                string windowCell = "H " + shareText(windowHigh, sampleSize)
                  + " / L " + shareText(windowLow, sampleSize)
                rowAt := panelRow(detailBoard, rowAt, windowName, windowCell,
                  panelText, panelSizeInput)
            if silverInput
                for s = 0 to 2
                    int fromMinute = s == 0 ? 180 : s == 1 ? 600 : 840
                    int toMinute   = fromMinute + 60
                    int windowHigh = 0
                    int windowLow  = 0
                    for i = 0 to slotCount - 1
                        int wallMinute = (i * slotMinutes + anchorStart) % MIN_PER_DAY
                        if slotTouchesWindow(wallMinute, slotMinutes, fromMinute, toMinute)
                            windowHigh += array.get(highCount, i)
                            windowLow  += array.get(lowCount, i)
                    string silverName = "Silver Bullet "
                      + str.tostring(fromMinute / 60) + ":00"
                    string silverCell = "H " + shareText(windowHigh, sampleSize)
                      + " / L " + shareText(windowLow, sampleSize)
                    rowAt := panelRow(detailBoard, rowAt, silverName, silverCell,
                      panelText, panelSizeInput)
        string noteText = ""
        if tooCoarse
            noteText := "chart bar does not fit the bucket grid - no time resolution"
        else if slotRaised
            noteText := "slot width raised to " + str.tostring(slotMinutes) + " min"
        else if sampleSize < STEADY_MIN
            noteText := "small sample - a wider slot is steadier"
        if hiddenSlots > 0
            string gap = str.length(noteText) > 0 ? "; " : ""
            noteText := noteText + gap + str.tostring(hiddenSlots)
              + " slots past the 500-bar draw limit"
        if sampleSize < LOW_SAMPLE
            string gap = str.length(noteText) > 0 ? "; " : ""
            noteText := noteText + gap + "cells dimmed below "
              + str.tostring(LOW_SAMPLE) + " days"
        rowAt := panelRow(detailBoard, rowAt, "Notes",
          str.length(noteText) > 0 ? noteText : "-", panelText, panelSizeInput)
        string filterCell = str.tostring(dayTypeInput) + ", coverage >= "
          + str.tostring(coverageInput) + " %, last "
          + str.tostring(lastNInput) + " days; weekdays "
          + (monInput ? "M" : "") + (tueInput ? "T" : "")
          + (wedInput ? "W" : "") + (thuInput ? "R" : "")
          + (friInput ? "F" : "") + (satActive ? "S" : "")
          + (sunActive ? "U" : "")
          + (useStartInput ? "; start "
            + str.format_time(startDateInput, "yyyy-MM-dd", TZ_UTC) : "")
        rowAt := panelRow(detailBoard, rowAt, "Filters", filterCell,
          panelText, panelSizeInput)
        if panelPos == 1
            table.set_position(detailBoard, position.top_left)
        else if panelPos == 2
            table.set_position(detailBoard, position.bottom_right)
        else if panelPos == 3
            table.set_position(detailBoard, position.bottom_left)
        else
            table.set_position(detailBoard, position.top_right)
        table.set_frame_color(detailBoard, PANEL_FRAME)
        table.set_border_color(detailBoard, PANEL_FRAME)

//#endregion

//#region ALERTS ===============================================================

alertcondition(enteredHigh, "Entering high-frequency high slot",
  "Entered the time window that held the daily high most often on this chart")
alertcondition(enteredLow, "Entering high-frequency low slot",
  "Entered the time window that held the daily low most often on this chart")

if enteredHigh
    alert("Entered the most frequent high-of-day window on " + syminfo.ticker,
      alert.freq_once_per_bar_close)

if enteredLow
    alert("Entered the most frequent low-of-day window on " + syminfo.ticker,
      alert.freq_once_per_bar_close)

if aheadDropped
    alert("Share of days with a later high fell below "
      + str.tostring(aheadAlertInput) + " %", alert.freq_once_per_bar_close)

if sessionOpened
    alert("NY AM window started on " + syminfo.ticker,
      alert.freq_once_per_bar_close)

if newDayExtreme
    alert("New running extreme of the day on " + syminfo.ticker,
      alert.freq_once_per_bar_close)

//#endregion
````
