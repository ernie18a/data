# Midnight Revisit Study | NomadaScalper

- url: https://www.tradingview.com/script/jK0YiUpG-Midnight-Revisit-Study-NomadaScalper/
- type: indicator
- pine_id: PUB;fc7d87e538ed475da020899c81d63a62
- version: 1.0

## Description

Midnight Revisit Study | NomadaScalper

Midnight Revisit Study measures how often price touches three references from the first hour of the New York day during the following daytime session.

It builds the full 00:00 to 01:00 range, then tracks touches between 08:00 and 16:00 on the same date. All times use America/New_York, with automatic daylight saving adjustments.

The dashboard compares three measurements:

• Candle Range: price overlaps any part of the midnight hour’s high-to-low range. Starting inside that range at 08:00 also counts.
• Midpoint 50%: price touches the exact midpoint between the midnight hour’s high and low.
• Midnight Open: price touches the opening price at 00:00.

The midnight structure always represents the entire hour. On a five-minute chart, for example, the indicator builds it from the twelve candles within that hour.

HOW THE STATISTICS WORK

Each eligible date contributes one observation to each measurement. Multiple touches on the same date do not increase the count.

Touch percentage = sessions with a touch / eligible completed sessions × 100.

All three percentages use the same sample. Both the midnight hour and the observation window must have complete, continuous data. Incomplete sessions are excluded, including sessions where a touch occurred before a later data gap.

The main percentages include completed sessions only. Today’s developing status appears separately. Tooltips provide additional information, including hit counts, 95% Wilson intervals and a provisional estimate including today when sufficient data is available.

WHAT APPEARS ON THE CHART

• Midnight High, Low, Midpoint and Open.
• An optional developing range during 00:00 to 01:00.
• Shading for the 08:00 to 16:00 observation window.
• A marker and alert condition for the first confirmed midpoint touch.
• A dashboard showing touch frequencies, sample dates, completed sessions and exclusions.

Display controls include four dashboard sizes, fine scaling, corner positioning, three range styles and adjustable session shading.

SETUP

Use standard time-based charts. Supported minute intervals are 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30 and 60.

The indicator supports any symbol with sufficient data in both required windows. Enable the full trading session where available. Markets without midnight data cannot produce an eligible sample. The study currently evaluates Monday through Friday, including when applied to cryptocurrency charts.

By default, calculations use all loaded chart history. The optional date filter restricts that sample; it does not retrieve additional history.

INTERPRETING THE RESULTS

Changing symbols or timeframes recalculates the study. Results may differ because of available history, data feeds, session settings and candle resolution.

Touches are identified from each candle’s high and low. Larger candles can span intrabar price gaps, so an observed touch does not establish an exact transaction time.

These percentages describe historical touch frequency. They are not a strategy win rate or a guarantee that a level will be revisited. The indicator does not model entries, stops, costs or profitability.

## Source Code

````pine
//@version=6
// Midnight Revisit Study | NomadaScalper | 1.2.0
// All chart symbols supported; statistics use the active chart OHLC only.
// Markets without complete midnight / observation windows yield no eligible sample.
// Independent implementation of the hypothesis supplied by the user.
// Claim supplied in the post: 73.5% NQ sessions, 2015-2025. Raw study unavailable.
// This script MEASURES the chart dataset; it does not reproduce or certify that study.
// Source: full NY 00:00-01:00 range. Test: NY 08:00-16:00, same calendar date.
// One observation per complete weekday. Strict, continuous coverage in BOTH windows.
// Every included session must have full coverage, including sessions with early hits.
// Touch = a candle's actual OHLC interval contains the exact (high + low) / 2.
// No rounding of the midpoint, interpolation across missing bars, or future requests.
// Closed estimates and Wilson intervals exclude the unfinished day. LIVE +1 is explicit.
// All statistics use the loaded dataset, NOT the visible viewport or the drawing history.
// Engine uses chart bars. Compatible continuous bars/dates agree across M5/M15.
// Coarser OHLC may span price gaps inside a candle: not proof of an executed trade.
// Different history depth, session filters, feeds, roll settings and missing bars can differ.
// No trades, entries, exits, expected returns or win-rate claims are generated.
indicator("Midnight Revisit Study | NomadaScalper", shorttitle="Midnight NQ-GC-EUR-ES Revisit NomadaScalper", overlay=true, max_lines_count=20, max_labels_count=20, max_bars_back=100)

const string TZ = "America/New_York"
const string VERSION = "1.2.0"
const float POST_RATE = 73.5
bool filterDates = input.bool(false, "Use date filter", group="01 | Sample", tooltip="Default: all loaded chart bars. A date filter cannot retrieve unavailable history. It only restricts the observations already loaded.")
int startInput = input.time(timestamp("01 Jan 2015 00:00 -0500"), "From (NY calendar date)", group="01 | Sample")
int endInput = input.time(timestamp("31 Dec 2025 23:59 -0500"), "Through (NY calendar date)", group="01 | Sample", tooltip="Dates are interpreted in New York. The default filter interval matches the period claimed in the supplied post; the filter starts OFF.")
bool showSession = input.bool(true, "Highlight 08:00-16:00 ET", group="02 | Display", tooltip="Observation window in New York time, automatically adjusted for daylight saving. Display only.")
bool showMap = input.bool(true, "Show midnight structure", group="02 | Display")
bool showOpen = input.bool(true, "Show Midnight Open comparison", group="02 | Display")
bool showHistory = input.bool(true, "Show historical structures", group="02 | Display", tooltip="Presentation only. Turning this off does not reduce the statistical sample.")
bool showTouches = input.bool(true, "Mark first confirmed MID touch", group="02 | Display")
string dashboardSize = input.string("Medium", "Dashboard size", options=["Small", "Medium", "Large", "Extra large"], group="02 | Display")
int dashboardScale = input.int(100, "Dashboard fine scale (%)", minval=75, maxval=150, step=5, group="02 | Display")
string rangeStyle = input.string("Refined", "Range appearance", options=["Minimal", "Refined", "Contrast"], group="02 | Display")
bool showDeveloping = input.bool(true, "Show developing midnight range", group="02 | Display", tooltip="Dotted provisional range during 00:00-01:00. It is not used for touch statistics until the full hour is confirmed.")
int sessionTransparency = input.int(94, "Session transparency", minval=85, maxval=99, group="02 | Display")
string dock = input.string("Top right", "Dashboard position", options=["Top right", "Bottom right", "Top left", "Bottom left"], group="02 | Display")

// Do not call timeframe.in_seconds() on unsupported tick-based chart intervals.
int chartMs = timeframe.isminutes ? timeframe.multiplier * 60000 : 0
bool validTf = timeframe.isminutes and timeframe.multiplier <= 60 and 60 % timeframe.multiplier == 0

f_date_start(int t) =>
    timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 0, 0)

int sampleStart = f_date_start(startInput)
int sampleEnd = f_date_start(endInput)
bool validDates = not filterDates or sampleEnd >= sampleStart
bool enabled = chart.is_standard and validTf and validDates
int thisDate = f_date_start(time)
int lastDate = f_date_start(last_bar_time)
var int datasetStart = time

type Day
    int start = na
    int rangeEnd = na
    int testStart = na
    int testEnd = na
    bool scope = false
    int rangeNext = na
    int testNext = na
    int rangeBars = 0
    int testBars = 0
    bool rangeGood = true
    bool testGood = true
    bool ready = false
    bool settled = false
    float top = na
    float bottom = na
    float midnightOpen = na
    float midpoint = na
    bool rangeHit = false
    bool midHit = false
    bool openHit = false
    int firstMidBar = na
    int firstMidClose = na

type Sample
    int observed = 0
    int eligible = 0
    int rangeHits = 0
    int midHits = 0
    int openHits = 0
    int bothHits = 0
    int midOnly = 0
    int openOnly = 0
    int rejectedRange = 0
    int rejectedWindow = 0
    int firstDate = na
    int lastDate = na

f_new_day(int t) =>
    Day s = Day.new()
    s.start := f_date_start(t)
    int yy = year(t, TZ)
    int mm = month(t, TZ)
    int dd = dayofmonth(t, TZ)
    s.rangeEnd := timestamp(TZ, yy, mm, dd, 1, 0)
    s.testStart := timestamp(TZ, yy, mm, dd, 8, 0)
    s.testEnd := timestamp(TZ, yy, mm, dd, 16, 0)
    int weekday = dayofweek(s.start, TZ)
    s.scope := weekday >= dayofweek.monday and weekday <= dayofweek.friday and (not filterDates or (s.start >= sampleStart and s.start <= sampleEnd))
    s.rangeNext := s.start
    s.testNext := s.testStart
    s

// BEGIN EXECUTABLE CORE: tested by extracting these bodies into a Python harness.
// No statistical counter is written by this function. A preview uses a scalar copy.
f_feed(Day s, int t, int tc, float o, float h, float l, float c, bool confirmed, int stepMs) =>
    bool priceGood = not na(o) and not na(h) and not na(l) and not na(c)
    priceGood := priceGood and h >= l and o >= l and o <= h and c >= l and c <= h
    bool spanGood = not na(tc) and tc - t == stepMs
    bool overlapsRange = not na(tc) and t < s.rangeEnd and tc > s.start
    bool inRange = overlapsRange and t >= s.start and tc <= s.rangeEnd
    if overlapsRange and not inRange
        s.rangeGood := false
    if inRange and not s.settled
        s.rangeGood := s.rangeGood and spanGood and priceGood and t == s.rangeNext
        s.rangeBars += 1
        s.rangeNext := tc
        if t == s.start and priceGood
            s.midnightOpen := o
        if priceGood
            if na(s.top)
                s.top := h
                s.bottom := l
            else
                s.top := math.max(s.top, h)
                s.bottom := math.min(s.bottom, l)
        bool entireRange = s.rangeBars * stepMs == s.rangeEnd - s.start and s.rangeNext == s.rangeEnd
        if confirmed and entireRange and s.rangeGood and not na(s.midnightOpen)
            s.ready := true
            s.midpoint := (s.top + s.bottom) * 0.5
    bool overlapsTest = not na(tc) and t < s.testEnd and tc > s.testStart
    bool inTest = overlapsTest and t >= s.testStart and tc <= s.testEnd
    if overlapsTest and not inTest
        s.testGood := false
    if inTest and not s.settled
        s.testGood := s.testGood and spanGood and priceGood and t == s.testNext
        s.testBars += 1
        s.testNext := tc
        if s.ready and priceGood
            if h >= s.bottom and l <= s.top
                s.rangeHit := true
            bool touchesMid = l <= s.midpoint and h >= s.midpoint
            bool touchesOpen = l <= s.midnightOpen and h >= s.midnightOpen
            if touchesMid and not s.midHit
                s.midHit := true
                s.firstMidBar := t
                s.firstMidClose := tc
            if touchesOpen
                s.openHit := true
    s

f_complete(Day s, int stepMs) =>
    s.ready and s.rangeGood and s.testGood and s.testNext == s.testEnd and s.testBars * stepMs == s.testEnd - s.testStart

f_settle(Day s, Sample a, int stepMs) =>
    if not s.settled
        s.settled := true
        if s.scope
            a.observed += 1
            if f_complete(s, stepMs)
                a.eligible += 1
                if s.rangeHit
                    a.rangeHits += 1
                if s.midHit
                    a.midHits += 1
                if s.openHit
                    a.openHits += 1
                if s.midHit and s.openHit
                    a.bothHits += 1
                if s.midHit and not s.openHit
                    a.midOnly += 1
                if s.openHit and not s.midHit
                    a.openOnly += 1
                if na(a.firstDate)
                    a.firstDate := s.start
                a.lastDate := s.start
            else if not s.ready or not s.rangeGood
                a.rejectedRange += 1
            else
                a.rejectedWindow += 1
    a

f_rate(int hits, int total) =>
    float result = na
    if total > 0
        result := 100.0 * hits / total
    result

f_wilson(int hits, int total) =>
    float lower = na
    float upper = na
    if total > 0
        float z = 1.959963984540054
        float z2 = z * z
        float p = float(hits) / total
        float denominator = 1.0 + z2 / total
        float center = (p + z2 / (2.0 * total)) / denominator
        float margin = z * math.sqrt(p * (1.0 - p) / total + z2 / (4.0 * total * total)) / denominator
        lower := math.max(0.0, center - margin) * 100.0
        upper := math.min(1.0, center + margin) * 100.0
    [lower, upper]
// END EXECUTABLE CORE

var Day current = na
var Sample sample = Sample.new()
bool firstMidEvent = false
if enabled and barstate.isconfirmed
    if na(current)
        current := f_new_day(time)
    else if current.start != thisDate
        // A skipped last bar / early close is rejected here, never counted as a miss.
        f_settle(current, sample, chartMs)
        current := f_new_day(time)
    bool previousHit = current.midHit
    f_feed(current, time, time_close, open, high, low, close, true, chartMs)
    firstMidEvent := current.scope and current.ready and current.testGood and current.midHit and not previousHit
    if not na(time_close) and time_close >= current.testEnd
        f_settle(current, sample, chartMs)

// Scalar-only UDT: copy is independent; no arrays/objects are shared by preview.
Day live = f_new_day(time)
if enabled and not na(current)
    if current.start == thisDate
        live := current.copy()
if enabled and not barstate.isconfirmed
    f_feed(live, time, time_close, open, high, low, close, false, chartMs)
int observedClock = barstate.isconfirmed ? time_close : time
bool activeWindow = not na(observedClock) and observedClock >= live.testStart and observedClock < live.testEnd
bool liveIncluded = enabled and live.scope and live.ready and live.rangeGood and live.testGood and live.testBars > 0 and not live.settled and activeWindow
float rangeRate = f_rate(sample.rangeHits, sample.eligible)
float closedRate = f_rate(sample.midHits, sample.eligible)
float openRate = f_rate(sample.openHits, sample.eligible)
float liveRate = liveIncluded ? f_rate(sample.midHits + (live.midHit ? 1 : 0), sample.eligible + 1) : na
[ciLow, ciHigh] = f_wilson(sample.midHits, sample.eligible)

const color PANEL = #101923
const color ALT = #15212E
const color HEADER = #1C2B3B
const color FRAME = #34485B
const color INK = #EEEAE2
const color MUTED = #A9B6C4
const color GOLD = #D6B46D
const color JADE = #67C5A3
const color ROSE = #D68791
const color BLUE = #86B9DC
bool darkChart = color.r(chart.bg_color) * 0.2126 + color.g(chart.bg_color) * 0.7152 + color.b(chart.bg_color) * 0.0722 < 128
color lineGold = darkChart ? GOLD : #947022
color lineSteel = darkChart ? #8EAFCA : #52758E
color lineJade = darkChart ? JADE : #28785D
color lineBlue = darkChart ? BLUE : #3E759C

// Session tint is display-only. No future shading or change to eligibility.
bool sessionVisible = showSession and enabled and live.scope and time >= live.testStart and time < live.testEnd and (showHistory or thisDate == lastDate)
bgcolor(sessionVisible ? color.new(lineBlue, sessionTransparency) : na, title="NY observation session | 08:00-16:00 ET")

// Midnight levels become drawable only AFTER the entire source hour is confirmed.
// No final midnight range is drawn backward into its building hour.
bool mapSession = enabled and live.scope and live.ready and time >= live.rangeEnd and time < live.testEnd
bool mapVisible = showMap and mapSession and (showHistory or thisDate == lastDate)
float mapHigh = mapVisible ? live.top : na
float mapLow = mapVisible ? live.bottom : na
float mapMid = mapVisible ? live.midpoint : na
color midInk = live.midHit ? lineJade : lineGold
float edgeDepth = mapVisible ? (live.top - live.bottom) * 0.035 : na
bool styledRange = rangeStyle != "Minimal"
int zoneAlpha = rangeStyle == "Contrast" ? 86 : 93
pUpperInset = plot(styledRange ? mapHigh - edgeDepth : na, "Range upper edge inset", color=na, display=display.none)
pLowerInset = plot(styledRange ? mapLow + edgeDepth : na, "Range lower edge inset", color=na, display=display.none)
pHigh = plot(mapHigh, "Midnight High", color=color.new(lineSteel, 25), linewidth=1, style=plot.style_linebr)
pLow = plot(mapLow, "Midnight Low", color=color.new(lineSteel, 25), linewidth=1, style=plot.style_linebr)
pMid = plot(mapMid, "Midnight Midpoint (exact)", color=midInk, linewidth=2, style=plot.style_linebr)
plot(mapVisible and showOpen ? live.midnightOpen : na, "Midnight Open", color=color.new(lineBlue, 35), linewidth=1, style=plot.style_circles)
fill(pHigh, pLow, color=color.new(lineSteel, rangeStyle == "Minimal" ? 97 : zoneAlpha), title="Confirmed midnight envelope", fillgaps=false)
fill(pHigh, pUpperInset, color=styledRange ? color.new(lineSteel, 72) : na, title="Upper boundary detail", fillgaps=false)
fill(pLow, pLowerInset, color=styledRange ? color.new(lineSteel, 72) : na, title="Lower boundary detail", fillgaps=false)
fill(pHigh, pMid, color=styledRange ? color.new(lineSteel, 96) : na, title="Upper range depth", fillgaps=false)
fill(pMid, pLow, color=styledRange ? color.new(midInk, 96) : na, title="Lower range depth", fillgaps=false)
bool buildingVisible = showMap and showDeveloping and enabled and live.scope and time >= live.start and time < live.rangeEnd and not live.ready and (showHistory or thisDate == lastDate)
bHigh = plot(buildingVisible ? live.top : na, "Developing high (provisional)", color=color.new(lineSteel, 40), style=plot.style_circles, linewidth=1)
bLow = plot(buildingVisible ? live.bottom : na, "Developing low (provisional)", color=color.new(lineSteel, 40), style=plot.style_circles, linewidth=1)
fill(bHigh, bLow, color=color.new(lineSteel, 96), title="Developing hour only", fillgaps=false)
plotshape(enabled and showTouches and firstMidEvent and (showHistory or thisDate == lastDate) ? live.midpoint : na, title="First MID touch: confirmation bar", style=shape.circle, location=location.absolute, color=lineJade, size=size.tiny)
alertcondition(firstMidEvent, title="Midnight MID touched", message="Midnight midpoint touched in the NY 08:00-16:00 window | {{ticker}} | {{interval}}. Observed OHLC touch, not a trade signal; final session coverage is not yet known.")

f_price(float p) =>
    na(p) ? "--" : str.tostring(p, "#,##0.000")

f_pct(float p) =>
    na(p) ? "--" : p > 0 and p < 0.1 ? "<0.1%" : p < 100 and p > 99.9 ? ">99.9%" : str.tostring(p, "0.0") + "%"

f_pp(float p) =>
    na(p) ? "--" : (p > 0 ? "+" : "") + str.tostring(p, "0.0") + " pp"

f_date(int stamp) =>
    na(stamp) ? "--" : str.format_time(stamp, "yyyy-MM-dd", TZ)

f_clock(int stamp) =>
    na(stamp) ? "--" : str.format_time(stamp, "HH:mm", TZ)

// Compact native plates: faint relief behind one text face; no price relocation.
// Only card Y can move. Leaders connect each card to its exact source level.
var array<label> shadows = array.new<label>(4)
var array<label> plates = array.new<label>(4)
var array<line> leaders = array.new<line>(4)
var array<line> elbows = array.new<line>(4)

f_clear_card(int i) =>
    label.delete(array.get(shadows, i))
    label.delete(array.get(plates, i))
    line.delete(array.get(leaders, i))
    line.delete(array.get(elbows, i))
    array.set(shadows, i, na)
    array.set(plates, i, na)
    array.set(leaders, i, na)
    array.set(elbows, i, na)
    0

f_card(int i, int x, float price, float y, string captionText, color accent, float depth, string tip) =>
    label shadow = array.get(shadows, i)
    label face = array.get(plates, i)
    line leader = array.get(leaders, i)
    line elbow = array.get(elbows, i)
    string caption = " " + captionText + " "
    if na(face)
        shadow := label.new(x, y - depth, caption, style=label.style_label_left, color=color.new(#03070C, 65), textcolor=color.new(INK, 100), size=9, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        face := label.new(x, y, caption, style=label.style_label_left, color=PANEL, textcolor=accent, size=9, text_font_family=font.family_monospace, text_formatting=text.format_bold, tooltip=tip)
        leader := line.new(bar_index, price, x - 1, price, color=color.new(accent, 25), width=1)
        elbow := line.new(x - 1, price, x - 1, y, color=color.new(accent, 35), width=1)
        array.set(shadows, i, shadow)
        array.set(plates, i, face)
        array.set(leaders, i, leader)
        array.set(elbows, i, elbow)
    label.set_xy(shadow, x, y - depth)
    label.set_text(shadow, caption)
    label.set_xy(face, x, y)
    label.set_text(face, caption)
    label.set_textcolor(face, accent)
    label.set_tooltip(face, tip)
    line.set_xy1(leader, bar_index, price)
    line.set_xy2(leader, x - 1, price)
    line.set_color(leader, color.new(accent, 25))
    line.set_xy1(elbow, x - 1, price)
    line.set_xy2(elbow, x - 1, y)
    line.set_color(elbow, color.new(accent, 35))
    0

float uiScale = (dashboardSize == "Small" ? 0.82 : dashboardSize == "Large" ? 1.20 : dashboardSize == "Extra large" ? 1.42 : 1.0) * dashboardScale / 100.0
f_font(int base) =>
    math.max(7, int(math.round(base * uiScale)))

f_meter(float rate) =>
    int filled = na(rate) ? 0 : int(math.round(rate / 10.0))
    string result = ""
    for j = 1 to 10
        result += j <= filled ? "━" : "·"
    result

f_cell(table t, int col, int row, string content, color ink, color bg, int fontSize, string tip = "") =>
    table.cell(t, col, row, " " + content + " ", text_color=ink, bgcolor=bg, text_size=f_font(fontSize), text_font_family=font.family_monospace, text_halign=col == 0 ? text.align_left : col == 1 ? text.align_right : text.align_center, tooltip=tip)
    0

string tablePosition = dock == "Top left" ? position.top_left : dock == "Bottom left" ? position.bottom_left : dock == "Bottom right" ? position.bottom_right : position.top_right
// Three comparable measures share ONE closed-session denominator.
f_today(Day d, bool hit, int clock) =>
    string state = "WAIT 08:00"
    if not enabled or not d.scope
        state := "--"
    else if clock < d.rangeEnd
        state := "BUILDING"
    else if not d.ready or not d.rangeGood
        state := "NO SOURCE"
    else if not d.testGood
        state := "GAP"
    else if d.settled
        state := f_complete(d, chartMs) ? (hit ? "TOUCHED" : "MISSED") : "EXCLUDED"
    else if clock >= d.testEnd
        state := "EXCLUDED"
    else if clock >= d.testStart
        state := hit ? "TOUCHED" : "PENDING"
    state

f_metric(table t, int row, string name, int hits, bool hit, color accent, string definition, Day d, int clock) =>
    string state = f_today(d, hit, clock)
    [lower, upper] = f_wilson(hits, sample.eligible)
    string tip = definition + "\nCompleted sessions: " + str.tostring(hits) + " / " + str.tostring(sample.eligible) + "\n95% Wilson interval: " + f_pct(lower) + " to " + f_pct(upper)
    string nowTip = "Today's status is separate from the historical percentage. A forming bar is provisional."
    if liveIncluded
        nowTip += "\nIncluding today provisionally: " + f_pct(f_rate(hits + (hit ? 1 : 0), sample.eligible + 1)) + " | N " + str.tostring(sample.eligible + 1)
    color bg = row == 4 ? #1C2834 : PANEL
    float rate = f_rate(hits, sample.eligible)
    color stateInk = state == "TOUCHED" ? JADE : state == "MISSED" or state == "GAP" or state == "EXCLUDED" ? ROSE : MUTED
    color stateBg = state == "TOUCHED" ? #19382F : state == "MISSED" or state == "GAP" or state == "EXCLUDED" ? #34232D : bg
    f_cell(t, 0, row, name + "\n" + (enabled and sample.eligible > 0 ? f_meter(rate) : "NO CLOSED SAMPLE"), accent, bg, 10, definition)
    f_cell(t, 1, row, enabled ? f_pct(f_rate(hits, sample.eligible)) : "--", accent, bg, 25, tip)
    table.cell_set_text_formatting(t, 1, row, text.format_bold)
    f_cell(t, 2, row, enabled ? str.tostring(hits) + "/" + str.tostring(sample.eligible) : "--", MUTED, bg, 10, tip)
    f_cell(t, 3, row, state, stateInk, stateBg, 9, nowTip)
    0

var table desk = table.new(tablePosition, 4, 10, bgcolor=PANEL, frame_color=#526273, frame_width=1, border_width=0)
if barstate.isfirst
    table.merge_cells(desk, 0, 0, 3, 0)
    table.merge_cells(desk, 0, 1, 3, 1)
    table.merge_cells(desk, 0, 6, 3, 6)
    table.merge_cells(desk, 0, 7, 3, 7)
    table.merge_cells(desk, 0, 8, 3, 8)
    table.merge_cells(desk, 0, 9, 3, 9)

float layoutAtr = ta.atr(14)
if barstate.islast
    string sourceTip = "Midnight candle = FULL 00:00-01:00 New York high/low, even on M5/M15. Midpoint = (high + low)/2 without rounding. Midnight Open = open at 00:00. Touches are measured only in 08:00-16:00 on that same NY weekday. DST adjusts automatically.\nChart OHLC overlap is not proof of an executed trade; coarser candles may bridge intrabar gaps."
    string cohortTip = "Same completed sessions for all three percentages. Both windows require complete, contiguous chart bars. Early hits followed by missing data are excluded too. Uses loaded history, not the visible viewport.\nRejected source hours: " + str.tostring(sample.rejectedRange) + " | Rejected test windows: " + str.tostring(sample.rejectedWindow) + "\nLoaded bars: " + str.tostring(bar_index + 1) + " | Dataset starts: " + f_date(datasetStart) + "\nEnable the full electronic session to include midnight."
    string reason = not chart.is_standard ? "Use standard candles" : not validTf ? "Use M5, M15 or minutes dividing 60" : not validDates ? "Check date filter order" : ""
    string phase = observedClock < live.rangeEnd ? "MIDNIGHT FORMING" : observedClock < live.testStart ? "WAITING" : observedClock < live.testEnd ? "LIVE" : "CLOSED"
    if not live.scope
        phase := "DATE OUTSIDE SAMPLE"
    else if observedClock >= live.rangeEnd and not live.ready
        phase := "MIDNIGHT DATA INCOMPLETE"
    else if not live.testGood
        phase := "OBSERVATION COVERAGE GAP"
    f_cell(desk, 0, 0, "OHLClabs   /   NomadaScalper", GOLD, HEADER, 13)
    table.cell_set_text_formatting(desk, 0, 0, text.format_bold)
    f_cell(desk, 0, 1, "MIDNIGHT  /  REVISIT STUDY     " + syminfo.ticker + "  " + timeframe.period + "m", MUTED, PANEL, 10, sourceTip)
    f_cell(desk, 0, 2, "00:00-01:00 ET", MUTED, HEADER, 9, sourceTip)
    f_cell(desk, 1, 2, "TOUCH %", GOLD, HEADER, 9, "Observed frequency over completed eligible sessions.")
    f_cell(desk, 2, 2, "HITS / N", MUTED, HEADER, 9, cohortTip)
    f_cell(desk, 3, 2, "TODAY", MUTED, HEADER, 9, "Current NY date: " + f_date(live.start))
    f_metric(desk, 3, "CANDLE RANGE", sample.rangeHits, live.rangeHit, BLUE, "Any overlap with the midnight hour's full high-low range: test high >= midnight low AND test low <= midnight high. Starting inside the range at 08:00 counts. Neither boundary has to be crossed.", live, observedClock)
    f_metric(desk, 4, "MIDPOINT 50%", sample.midHits, live.midHit, GOLD, "The exact midpoint of the full midnight hour is contained in a test bar's low-high interval.", live, observedClock)
    f_metric(desk, 5, "MIDNIGHT OPEN", sample.openHits, live.openHit, JADE, "The 00:00 opening price is contained in a test bar's low-high interval.", live, observedClock)
    f_cell(desk, 0, 6, "SAMPLE  " + f_date(sample.firstDate) + "  /  " + f_date(sample.lastDate), INK, HEADER, 10, cohortTip)
    f_cell(desk, 0, 7, str.tostring(sample.eligible) + " complete sessions  |  " + str.tostring(sample.rejectedRange + sample.rejectedWindow) + " excluded" + (sample.eligible < 30 ? "  |  SMALL SAMPLE" : ""), MUTED, PANEL, 9, cohortTip)
    f_cell(desk, 0, 8, enabled ? "NY 08:00–16:00  /  " + phase : reason, enabled ? BLUE : ROSE, ALT, 9, sourceTip)
    f_cell(desk, 0, 9, "CLOSED HISTORY  /  LIVE DAY SEPARATE", MUTED, PANEL, 8, "Not a win rate or guaranteed future probability. Today's unfinished observation is excluded from the primary percentages. Hover TODAY for a provisional estimate. Changing timeframe can change available history and OHLC resolution.")

    bool cardsVisible = showMap and enabled and live.scope and live.ready and observedClock >= live.rangeEnd
    if cardsVisible
        array<float> prices = array.from(live.top, live.midpoint, live.bottom, showOpen ? live.midnightOpen : float(na))
        array<float> packed = array.copy(prices)
        array<int> order = array.sort_indices(prices, order.ascending)
        float gap = math.max(syminfo.mintick * 4, math.max(nz(layoutAtr, 0) * 0.28, (live.top - live.bottom) * 0.08))
        float previousY = na
        float shift = 0.0
        int slots = 0
        for i in order
            float p = array.get(prices, i)
            if not na(p)
                float y = na(previousY) ? p : math.max(p, previousY + gap)
                array.set(packed, i, y)
                shift += y - p
                slots += 1
                previousY := y
        float centerShift = slots > 0 ? shift / slots : 0.0
        array<string> names = array.from("HIGH", "MID", "LOW", "OPEN")
        array<color> colors = array.from(BLUE, live.midHit ? JADE : GOLD, BLUE, MUTED)
        for i = 0 to 3
            float p = array.get(prices, i)
            if not na(p)
                string cardText = array.get(names, i) + "  " + f_price(p)
                string cardTip = sourceTip + "\nNY date: " + f_date(live.start) + "\n" + array.get(names, i) + ": " + f_price(p) + "\nExact level at connector; displaced label is presentation only."
                f_card(i, bar_index + 7, p, array.get(packed, i) - centerShift, cardText, array.get(colors, i), gap * 0.07, cardTip)
            else
                f_clear_card(i)
    else
        for i = 0 to 3
            f_clear_card(i)
````
