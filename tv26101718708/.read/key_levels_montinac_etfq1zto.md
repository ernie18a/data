# KEY LEVELS - MONTINAC 

- url: https://www.tradingview.com/script/ETFq1zTO-KEY-LEVELS-MONTINAC/
- type: indicator
- pine_id: PUB;e3220af0eb774dd48dcebade92bf7463
- version: 1.0

## Description

[b]Montinac Key Levels[/b] brings period opens, previous highs and lows, and session ranges into one customizable chart overlay. Horizontal lines and right-side labels keep the references easy to identify, while proximity-based styling helps nearby levels stand out.

Designed for traders who use price levels as context, the indicator combines a familiar display with updated session handling, clearer developing-range labels, and optional level-specific alerts.

Available references include:

- 4H, daily, weekly, monthly, and quarterly opens, previous highs/lows, and previous-range midpoints.
- Monday’s trading-day high, low, and midpoint.
- Yearly open and developing current-year high, low, and midpoint.
- London, New York, and Tokyo/Asia session opens, highs, lows, and midpoints.

Each group can be enabled independently.

The display offers two layouts. Standard draws each reference from its source or availability time toward the labels. Right Anchored uses shorter lines near the right side of the chart. Choose plain text or soft label backgrounds, full names or shorthand, and optional prices or distances in ticks.

The Montinac palette uses gold, violet, periwinkle, and complementary accents. Classic and Custom palettes are also available, along with a single-color option.

When proximity emphasis is enabled, levels near the current price become brighter, thicker, and bold. Distance is measured using ATR(14); the defaults apply full emphasis within 2 ATR and maximum fading beyond 8 ATR. This highlights proximity—not the probability that a level will hold.

References sharing the same instrument tick can merge into one line and label. Nearby but distinct prices remain separate. Multiple references at one price are not treated as a calculated strength score.

Each session has its own editable hours and timezone. Named timezones follow local daylight-saving changes independently of the chart clock. Default observation windows are London 08:00–17:00, New York 08:00–17:00, and Tokyo 09:00–18:00, using each city’s local time. These are configurable observation windows, not official COMEX session definitions.

Monday’s range follows the symbol’s trading-day date, accommodating overnight futures sessions where Monday trading begins on Sunday evening.

Previous-period highs and lows use completed periods. Current session, Monday, and yearly ranges can change while forming. Developing references are marked accordingly. The lines show the current set of references; they do not reconstruct the historical path of a changing range.

Optional alerts identify a level touched or closed across. Select the desired alert mode in the inputs, then create a TradingView alert using “Any alert() function call.” Alerts evaluate at candle close and exclude developing ranges from event detection. They describe price events rather than trade recommendations.

Use standard time-based charts on intraday intervals or 1D. Session levels display on 60-minute charts and below; 4H references display on 4H charts and below. Align session boundaries with the chart interval for accurate ranges. Partially loaded ranges may be withheld, and yearly extremes require sufficient history. Data-feed revisions and continuous-futures adjustments can revise reference prices.

## Source Code

````pine
//@version=6


indicator("Montinac Key Levels", shorttitle="KEY LEVELS", overlay=true, max_lines_count=100, max_labels_count=100, max_bars_back=500)

string gDisplay = "Display"
string displayStyle = input.string("Standard", "Display style", options=["Standard", "Right Anchored"], group=gDisplay)
int distanceRight = input.int(30, "Label distance", minval=1, maxval=200, group=gDisplay)
int anchorDistance = input.int(100, "Right-anchor length", minval=5, maxval=400, group=gDisplay, tooltip="Length of the short rail ending at the label. Unlike Standard, it does not extend to the level's source period.")
bool mergeLevels = input.bool(true, "Merge identical prices", group=gDisplay, tooltip="Merges levels on the same instrument tick. Distinct prices are never moved or averaged.")
string textSize = input.string("Medium", "Text size", options=["Small", "Medium", "Large"], group=gDisplay)
string labelStyle = input.string("Text", "Label style", options=["Text", "Soft tags"], group=gDisplay)
bool showPrice = input.bool(false, "Add price to labels", group=gDisplay)
bool showDistance = input.bool(false, "Add distance in ticks", group=gDisplay)
bool showForming = input.bool(true, "Mark developing ranges", group=gDisplay)
bool globalShort = input.bool(false, "Global shorthand", group=gDisplay)
string lineStyle = input.string("Solid", "High/low line style", options=["Solid", "Dashed", "Dotted"], group=gDisplay)
int lineWidth = input.int(1, "Line width", minval=1, maxval=3, group=gDisplay)
bool lineHierarchy = input.bool(true, "Solid opens / dotted midpoints", group=gDisplay)

string gFocus = "Price proximity"
bool focusLevels = input.bool(true, "Emphasize nearby levels", group=gFocus, tooltip="Visual emphasis only: near levels become brighter and thicker; distant levels fade. It does not rank trading probability.")
float nearATR = input.float(2.0, "Bright within ATR", minval=0.1, step=0.1, group=gFocus)
float farATR = input.float(8.0, "Fully faded beyond ATR", minval=0.5, step=0.5, group=gFocus)
int farFade = input.int(75, "Distant-line transparency", minval=0, maxval=95, group=gFocus)

string gColors = "Palette"
string palette = input.string("Montinac", "Palette", options=["Montinac", "Classic", "Custom"], group=gColors)
bool oneColor = input.bool(false, "Use one color for every group", inline="global", group=gColors)
color allColor = input.color(#D8DCE5, "", inline="global", group=gColors)

string g4 = "4H"
bool h4Open = input.bool(false, "Open", inline="4", group=g4)
bool h4Range = input.bool(true, "Previous H/L", inline="4", group=g4)
bool h4Mid = input.bool(false, "Previous mid", inline="4", group=g4)
bool h4Short = input.bool(false, "Shorthand", inline="4c", group=g4)
color h4Custom = input.color(#838FE8, "Custom color", inline="4c", group=g4)
string gD = "Daily"
bool dOpen = input.bool(true, "Open", inline="d", group=gD)
bool dRange = input.bool(true, "Previous H/L", inline="d", group=gD)
bool dMid = input.bool(true, "Previous mid", inline="d", group=gD)
bool dShort = input.bool(false, "Shorthand", inline="dc", group=gD)
color dCustom = input.color(#F4CD6A, "Custom color", inline="dc", group=gD)
string gMon = "Monday range"
bool monRange = input.bool(true, "Range", inline="mon", group=gMon)
bool monMid = input.bool(false, "Midpoint", inline="mon", group=gMon)
bool monShort = input.bool(false, "Shorthand", inline="monc", group=gMon)
color monCustom = input.color(#A9B6CA, "Custom color", inline="monc", group=gMon)
string gW = "Weekly"
bool wOpen = input.bool(false, "Open", inline="w", group=gW)
bool wRange = input.bool(true, "Previous H/L", inline="w", group=gW)
bool wMid = input.bool(false, "Previous mid", inline="w", group=gW)
bool wShort = input.bool(false, "Shorthand", inline="wc", group=gW)
color wCustom = input.color(#EAA869, "Custom color", inline="wc", group=gW)
string gM = "Monthly"
bool mOpen = input.bool(false, "Open", inline="m", group=gM)
bool mRange = input.bool(false, "Previous H/L", inline="m", group=gM)
bool mMid = input.bool(false, "Previous mid", inline="m", group=gM)
bool mShort = input.bool(false, "Shorthand", inline="mc", group=gM)
color mCustom = input.color(#B8A0F0, "Custom color", inline="mc", group=gM)
string gQ = "Quarterly"
bool qOpen = input.bool(false, "Open", inline="q", group=gQ)
bool qRange = input.bool(false, "Previous H/L", inline="q", group=gQ)
bool qMid = input.bool(false, "Previous mid", inline="q", group=gQ)
bool qShort = input.bool(false, "Shorthand", inline="qc", group=gQ)
color qCustom = input.color(#D59FE8, "Custom color", inline="qc", group=gQ)
string gY = "Yearly"
bool yOpen = input.bool(false, "Open", inline="y", group=gY)
bool yRange = input.bool(false, "Current H/L", inline="y", group=gY)
bool yMid = input.bool(false, "Current mid", inline="y", group=gY)
bool yShort = input.bool(false, "Shorthand", inline="yc", group=gY)
color yCustom = input.color(#E7D9A8, "Custom color", inline="yc", group=gY)

string gLon = "London session"
bool lonRange = input.bool(true, "Range", inline="lon", group=gLon)
bool lonOpen = input.bool(true, "Open", inline="lon", group=gLon)
bool lonMid = input.bool(false, "Midpoint", inline="lon", group=gLon)
string lonHours = input.session("0800-1700", "Local hours", group=gLon)
string lonZone = input.string("Europe/London", "Timezone", group=gLon, tooltip="IANA timezone names follow daylight saving. The chart clock does not change this setting.")
color lonCustom = input.color(#A47AE2, "Custom color", group=gLon)
string gNY = "New York session"
bool nyRange = input.bool(true, "Range", inline="ny", group=gNY)
bool nyOpen = input.bool(true, "Open", inline="ny", group=gNY)
bool nyMid = input.bool(false, "Midpoint", inline="ny", group=gNY)
string nyHours = input.session("0800-1700", "Local hours", group=gNY)
string nyZone = input.string("America/New_York", "Timezone", group=gNY)
color nyCustom = input.color(#F4CD6A, "Custom color", group=gNY)
string gAsia = "Tokyo / Asia session"
bool asiaRange = input.bool(true, "Range", inline="asia", group=gAsia)
bool asiaOpen = input.bool(true, "Open", inline="asia", group=gAsia)
bool asiaMid = input.bool(false, "Midpoint", inline="asia", group=gAsia)
string asiaHours = input.session("0900-1800", "Local hours", group=gAsia)
string asiaZone = input.string("Asia/Tokyo", "Timezone", group=gAsia)
color asiaCustom = input.color(#718CD9, "Custom color", group=gAsia)
string gSessions = "Session display"
string sessionDays = input.string("23456", "Local session days", group=gSessions, tooltip="1=Sunday, 2=Monday ... 7=Saturday. Default is Monday-Friday in EACH session's own timezone. Session ranges are shown on 60-minute and lower charts; use bar intervals aligned with session boundaries.")
bool sessionShort = input.bool(false, "Session shorthand", group=gSessions)

string gAlerts = "Optional alerts"
string alertMode = input.string("Off", "Named level alerts", options=["Off", "Touch", "Close across", "Touch and close across"], group=gAlerts)
int alertTicks = input.int(0, "Touch tolerance (ticks)", minval=0, maxval=100, group=gAlerts)

if barstate.isfirst and timeframe.in_seconds() > 86400
    runtime.error("Montinac Key Levels is designed for time-based intraday charts and 1D. Use a 1D or lower interval.")

f_color(color custom, color montinac, color classic) =>
    oneColor ? allColor : palette == "Classic" ? classic : palette == "Custom" ? custom : montinac

// Opens/time are known at the period's first tick. Previous H/L are offset
// BEFORE lookahead_on. No developing HTF high/low is requested with lookahead.
f_period(string tf) =>
    request.security(syminfo.tickerid, tf, [time, open, high[1], low[1]], lookahead=barmerge.lookahead_on)
[t4, o4, ph4, pl4] = f_period("240")
[td, od, phd, pld] = f_period("D")
[tw, ow, phw, plw] = f_period("W")
[tm, om, phm, plm] = f_period("M")
[tq, oq, phq, plq] = f_period("3M")
[ty, oy, phy, ply] = f_period("12M")

// A daily context provides completed Monday and year-to-date history even
// when an intraday chart has loaded only a few days. All returned extremes
// are offset one DAILY bar, then combined with today's observed bars below.
f_dailyHistory() =>
    int wk = time("W")
    int yr = time("12M")
    bool newWeek = ta.change(wk) != 0
    bool newYear = ta.change(yr) != 0
    var float mh = na
    var float ml = na
    var int mt = na
    if newWeek
        mh := na
        ml := na
        mt := na
    if dayofweek(time_tradingday, "UTC") == dayofweek.monday
        mh := high
        ml := low
        mt := time
    var float yh = na
    var float yl = na
    var bool yearComplete = false
    if barstate.isfirst or newYear
        yh := high
        yl := low
        yearComplete := newYear or time == yr
    else
        yh := math.max(yh, high)
        yl := math.min(yl, low)
    [mt[1], mh[1], ml[1], wk[1], yr[1], yh[1], yl[1], yearComplete[1]]
[histMonTime, histMonHigh, histMonLow, histWeek, histYear, histYearHigh, histYearLow, yearHistoryComplete] = request.security(syminfo.tickerid, "D", f_dailyHistory(), lookahead=barmerge.lookahead_on, calc_bars_count=1500)

var float dayHigh = na
var float dayLow = na
var bool fullDayObserved = false
if barstate.isfirst or ta.change(td) != 0
    dayHigh := high
    dayLow := low
    fullDayObserved := time == td
else
    dayHigh := math.max(dayHigh, high)
    dayLow := math.min(dayLow, low)
bool isMonday = dayofweek(time_tradingday, "UTC") == dayofweek.monday
float mondayHigh = isMonday ? (fullDayObserved ? dayHigh : na) : histWeek == tw ? histMonHigh : na
float mondayLow = isMonday ? (fullDayObserved ? dayLow : na) : histWeek == tw ? histMonLow : na
int mondayTime = isMonday ? td : histWeek == tw ? histMonTime : na
bool newYearDay = td == ty
bool yearReady = fullDayObserved and ((histYear == ty and yearHistoryComplete) or newYearDay)
float yearHigh = yearReady ? (histYear == ty ? math.max(histYearHigh, dayHigh) : dayHigh) : na
float yearLow = yearReady ? (histYear == ty ? math.min(histYearLow, dayLow) : dayLow) : na

type SessionRange
    float hi = na
    float lo = na
    float op = na
    int started = na
    int key = na
    bool active = false
    bool ready = false
    bool forming = false

method update(SessionRange this, string hours, string zone) =>
    string sessionSpec = hours + ":" + sessionDays
    bool inside = timeframe.isintraday and not na(time(timeframe.period, sessionSpec, zone))
    int currentKey = time("1D", sessionSpec, zone)
    if inside
        bool firstBar = not this.active or currentKey != this.key
        if firstBar
            this.hi := high
            this.lo := low
            this.op := open
            this.started := time
            this.key := currentKey
            // Do not present a partial first loaded session as a complete range.
            this.ready := not barstate.isfirst or time == currentKey
        else
            this.hi := math.max(this.hi, high)
            this.lo := math.min(this.lo, low)
    this.active := inside
    // The last candle of a session can remain the chart's last bar over a
    // weekend. Its closed range is final even before an outside bar arrives.
    this.forming := inside and (not barstate.isconfirmed or time_close < time_close("1D", sessionSpec, zone))

var SessionRange london = SessionRange.new()
var SessionRange newYork = SessionRange.new()
var SessionRange asia = SessionRange.new()
london.update(lonHours, lonZone)
newYork.update(nyHours, nyZone)
asia.update(asiaHours, asiaZone)

type Level
    int slot
    float price
    int started
    string title
    color tint
    int kind
    bool forming

array<Level> levels = array.new<Level>()
f_add(int slot, bool enabled, float price, int started, string full, string shortName, bool shorthand, color tint, int kind, bool forming) =>
    if enabled and not na(price) and not na(started)
        array.push(levels, Level.new(slot, math.round_to_mintick(price), started, globalShort or shorthand ? shortName : full, tint, kind, forming))

f_group(int slot, string name, string abbr, bool showOpen, bool showRange, bool showMid, bool shorthand, color tint, int started, float op, float hi, float lo, bool allowed) =>
    string openName = name == "Day" ? "Daily" : name == "Week" ? "Weekly" : name == "Month" ? "Monthly" : name == "Quarter" ? "Quarterly" : name
    // Previous-period extremes become available at the CURRENT period start.
    f_add(slot, allowed and showOpen, op, started, openName + " Open", abbr + "O", shorthand, tint, 0, false)
    f_add(slot + 1, allowed and showRange, hi, started, "Prev " + name + " High", "P" + abbr + "H", shorthand, tint, 1, false)
    f_add(slot + 2, allowed and showRange, lo, started, "Prev " + name + " Low", "P" + abbr + "L", shorthand, tint, 1, false)
    f_add(slot + 3, allowed and showMid, (hi + lo) / 2, started, "Prev " + name + " Mid", "P" + abbr + "M", shorthand, tint, 2, false)

f_group(0, "4H", "4H-", h4Open, h4Range, h4Mid, h4Short, f_color(h4Custom, #838FE8, color.orange), t4, o4, ph4, pl4, timeframe.in_seconds() <= 14400)
f_group(4, "Day", "D", dOpen, dRange, dMid, dShort, f_color(dCustom, #F4CD6A, #08BCD4), td, od, phd, pld, true)
f_group(8, "Week", "W", wOpen, wRange, wMid, wShort, f_color(wCustom, #EAA869, #FFFCBC), tw, ow, phw, plw, true)
f_group(12, "Month", "M", mOpen, mRange, mMid, mShort, f_color(mCustom, #B8A0F0, #08D48C), tm, om, phm, plm, true)
f_group(16, "Quarter", "Q", qOpen, qRange, qMid, qShort, f_color(qCustom, #D59FE8, color.red), tq, oq, phq, plq, true)
color yearColor = f_color(yCustom, #E7D9A8, color.red)
f_add(20, yOpen, oy, ty, "Yearly Open", "YO", yShort, yearColor, 0, false)
f_add(21, yRange, yearHigh, ty, "Current Year High", "CYH", yShort, yearColor, 1, true)
f_add(22, yRange, yearLow, ty, "Current Year Low", "CYL", yShort, yearColor, 1, true)
f_add(23, yMid, (yearHigh + yearLow) / 2, ty, "Current Year Mid", "CYM", yShort, yearColor, 2, true)
color mondayColor = f_color(monCustom, #A9B6CA, color.white)
f_add(24, monRange, mondayHigh, mondayTime, "Monday High", "MON-H", monShort, mondayColor, 1, isMonday)
f_add(25, monRange, mondayLow, mondayTime, "Monday Low", "MON-L", monShort, mondayColor, 1, isMonday)
f_add(26, monMid, (mondayHigh + mondayLow) / 2, mondayTime, "Monday Mid", "MON-M", monShort, mondayColor, 2, isMonday)

f_session(int slot, string name, string abbr, SessionRange sess, bool showOpen, bool showRange, bool showMid, color tint) =>
    bool allowed = timeframe.isintraday and timeframe.in_seconds() <= 3600 and sess.ready
    f_add(slot, allowed and showOpen, sess.op, sess.started, name + " Open", abbr + "-O", sessionShort, tint, 0, false)
    f_add(slot + 1, allowed and showRange, sess.hi, sess.started, name + " High", abbr + "-H", sessionShort, tint, 1, sess.forming)
    f_add(slot + 2, allowed and showRange, sess.lo, sess.started, name + " Low", abbr + "-L", sessionShort, tint, 1, sess.forming)
    f_add(slot + 3, allowed and showMid, (sess.hi + sess.lo) / 2, sess.started, name + " Mid", abbr + "-M", sessionShort, tint, 2, sess.forming)
f_session(27, "London", "LON", london, lonOpen, lonRange, lonMid, f_color(lonCustom, #A47AE2, color.white))
f_session(31, "New York", "NY", newYork, nyOpen, nyRange, nyMid, f_color(nyCustom, #F4CD6A, color.white))
f_session(35, "Asia", "AS", asia, asiaOpen, asiaRange, asiaMid, f_color(asiaCustom, #718CD9, color.white))

// Named, close-confirmed alerts for stable levels only. A newly introduced
// level or moving range cannot manufacture a crossing of its own old price.
var array<float> lastPrices = array.new_float(39, na)
var array<int> lastStarts = array.new_int(39, na)
var array<bool> lastTouches = array.new_bool(39, false)
var array<bool> lastForming = array.new_bool(39, true)
if barstate.isconfirmed
    string events = ""
    for level in levels
        int id = level.slot
        float oldPrice = array.get(lastPrices, id)
        int oldStart = array.get(lastStarts, id)
        bool stable = not level.forming and not array.get(lastForming, id) and oldPrice == level.price and oldStart == level.started
        float pad = alertTicks * syminfo.mintick
        bool touched = low <= level.price + pad and high >= level.price - pad
        bool crossedUp = stable and close > level.price and close[1] <= level.price
        bool crossedDown = stable and close < level.price and close[1] >= level.price
        bool touchEvent = stable and touched and not array.get(lastTouches, id)
        bool useCross = alertMode == "Close across" or alertMode == "Touch and close across"
        bool useTouch = alertMode == "Touch" or alertMode == "Touch and close across"
        string action = useCross and crossedUp ? "closed above" : useCross and crossedDown ? "closed below" : useTouch and touchEvent ? "touched" : ""
        if action != ""
            events += (events == "" ? "" : " | ") + level.title + " " + action + " " + str.tostring(level.price, format.mintick)
        array.set(lastPrices, id, level.price)
        array.set(lastStarts, id, level.started)
        array.set(lastTouches, id, touched)
        array.set(lastForming, id, level.forming)
    if events != "" and alertMode != "Off"
        alert(syminfo.ticker + " " + timeframe.period + ": " + events, alert.freq_once_per_bar_close)

float atr = ta.atr(14)
string fontSize = textSize == "Small" ? size.small : textSize == "Large" ? size.large : size.normal
string selectedStyle = lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Dotted" ? line.style_dotted : line.style_solid
var array<line> rails = array.new_line()
var array<label> tags = array.new_label()

// Persistent drawing pool: update existing objects rather than creating
// new historical lines on every candle. Timed endpoints use chart time,
// never wall-clock time, so weekends and Replay do not push labels away.
if barstate.islast
    array<float> drawnPrices = array.new_float()
    array<Level> visible = array.new<Level>()
    array<int> counts = array.new_int()
    array<bool> mixed = array.new_bool()
    for level in levels
        int match = mergeLevels ? array.indexof(drawnPrices, level.price) : -1
        if match >= 0
            Level existing = array.get(visible, match)
            bool differs = existing.forming != level.forming
            existing.title += " / " + level.title
            existing.started := math.min(existing.started, level.started)
            existing.kind := math.min(existing.kind, level.kind)
            existing.forming := existing.forming or level.forming
            array.set(mixed, match, array.get(mixed, match) or differs)
            array.set(counts, match, array.get(counts, match) + 1)
        else
            array.push(drawnPrices, level.price)
            array.push(visible, Level.new(level.slot, level.price, level.started, level.title, level.tint, level.kind, level.forming))
            array.push(counts, 1)
            array.push(mixed, false)
    int used = array.size(visible)
    while array.size(rails) < used
        array.push(rails, line.new(time, close, time, close, xloc=xloc.bar_time))
        array.push(tags, label.new(time, close, "", xloc=xloc.bar_time))
    int stepMs = int(timeframe.in_seconds() * 1000)
    int rightEdge = time + distanceRight * stepMs
    if array.size(rails) > 0
        for i = 0 to array.size(rails) - 1
            line rail = array.get(rails, i)
            label tag = array.get(tags, i)
            if i >= used
                line.set_color(rail, na)
                label.set_text(tag, "")
                label.set_color(tag, na)
            else
                Level level = array.get(visible, i)
                float distance = math.abs(level.price - close)
                float normalized = not na(atr) and atr > 0 ? distance / atr : 0
                bool near = focusLevels and not na(atr) and normalized <= nearATR
                float fadeRange = math.max(farATR - nearATR, 0.1)
                int fade = focusLevels ? int(math.round(math.max(0.0, math.min(1.0, (normalized - nearATR) / fadeRange)) * farFade)) : 0
                int count = array.get(counts, i)
                string suffix = showForming and level.forming ? (array.get(mixed, i) ? " [part forming]" : " [forming]") : ""
                string labelText = level.title + suffix
                labelText += showPrice ? "  " + str.tostring(level.price, format.mintick) : ""
                labelText += showDistance ? "  [" + str.tostring(math.round(distance / syminfo.mintick), "0") + "t]" : ""
                int leftEdge = displayStyle == "Right Anchored" ? rightEdge - anchorDistance * stepMs : level.started
                string style = lineHierarchy and level.kind == 2 ? line.style_dotted : level.forming ? line.style_dashed : lineHierarchy and level.kind == 0 ? line.style_solid : selectedStyle
                line.set_xy1(rail, leftEdge, level.price)
                line.set_xy2(rail, rightEdge, level.price)
                line.set_color(rail, color.new(level.tint, fade))
                line.set_width(rail, math.min(4, lineWidth + (near ? 1 : 0)))
                line.set_style(rail, style)
                label.set_xy(tag, rightEdge, level.price)
                label.set_text(tag, labelText)
                label.set_style(tag, labelStyle == "Soft tags" ? label.style_label_left : label.style_none)
                label.set_color(tag, labelStyle == "Soft tags" ? color.new(level.tint, 88) : na)
                label.set_textcolor(tag, color.new(level.tint, int(math.min(fade, 40))))
                label.set_size(tag, fontSize)
                label.set_textalign(tag, text.align_left)
                label.set_text_formatting(tag, near ? text.format_bold : text.format_none)
                string detail = level.title + "\nPrice: " + str.tostring(level.price, format.mintick) + "\nDistance: " + str.tostring(distance, format.mintick) + " points / " + str.tostring(math.round(distance / syminfo.mintick), "0") + " ticks"
                detail += count > 1 ? "\n" + str.tostring(count) + " references share this exact tick. This is not a strength score." : ""
                detail += level.forming ? "\nContains a developing range: the high, low or midpoint can change." : "\nFixed reference for its current period/session."
                label.set_tooltip(tag, detail)

plot(na, "Validation", display=display.none)
````
