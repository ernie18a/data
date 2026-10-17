# Killzones

- url: https://www.tradingview.com/script/ZTSFlBbA/
- type: indicator
- pine_id: PUB;afafdab4abf04177a600e4bc74bb5299
- version: 1.0

## Description

Plots the major intraday killzones used in orderflow/ICT analysis as session
boxes. Up to five fully configurable sessions (Asian, London, NY AM, London
Close, NY PM by default) are drawn on the chart, so you instantly see the
windows where intraday liquidity is typically built and swept.

Each box automatically tracks the high and low of its session, giving you the
session range and its liquidity edges at a glance. All sessions are calculated
in a selectable timezone (default New York, with automatic DST handling so the
windows match ICT killzone times year-round). Optional vertical lines mark each
session's open and close, and labels name each zone.

Because the sessions are purely time-based, completed killzones are fixed and do
not repaint; only the active session updates in real time as price extends.

Use the killzones to frame WHEN you look for setups (e.g. sweeps and reversals
into London/NY after the Asian range), not as standalone signals.

Settings: enable/disable each session, custom times and timezone, weekdays-only
filter, per-session colors, optional open/close lines and labels, extend-after-
session, and a historical zone limit.

This tool is for visualization only. It issues no buy/sell signals and makes no
claim about future performance.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════════
//  MTF Killzones 
// ════════════════════════════════════════════════════════════════════════════════

indicator("MTF Killzones", "Killzones", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ════════════════════════════════════════════════════════════════════════════════

string GRP_KZ1 = "── Killzone 1 ──"
string GRP_KZ2 = "── Killzone 2 ──"
string GRP_KZ3 = "── Killzone 3 ──"
string GRP_KZ4 = "── Killzone 4 ──"
string GRP_KZ5 = "── Killzone 5 ──"
string GRP_GEN = "═══════ General Settings ═══════"

string TT_SESSION = "Session time in HHMM-HHMM format. Sessions are based on the timezone setting below."
string TT_TZ      = "Timezone for all session calculations. Default: America/New_York (handles DST automatically — matches ICT killzone times year-round)."
string TT_DAYS    = "Only show killzones on weekdays (Monday-Friday)."
string TT_EXTEND  = "Extend box range to current bar even after session ends (until new session starts)."

// ════════════════════════════════════════════════════════════════════════════════
// INPUTS: KILLZONES
// ════════════════════════════════════════════════════════════════════════════════

kz1_enable = input.bool(true, "Enable", group=GRP_KZ1, inline="e1")
kz1_name   = input.string("Asian Killzone", "Name", group=GRP_KZ1, inline="e1")
kz1_time   = input.session("2000-0000", "Session", group=GRP_KZ1, tooltip=TT_SESSION)
kz1_color  = input.color(color.new(color.purple, 85), "Color", group=GRP_KZ1)

kz2_enable = input.bool(true, "Enable", group=GRP_KZ2, inline="e2")
kz2_name   = input.string("London Killzone", "Name", group=GRP_KZ2, inline="e2")
kz2_time   = input.session("0200-0500", "Session", group=GRP_KZ2, tooltip=TT_SESSION)
kz2_color  = input.color(color.new(color.blue, 85), "Color", group=GRP_KZ2)

kz3_enable = input.bool(true, "Enable", group=GRP_KZ3, inline="e3")
kz3_name   = input.string("NY AM Killzone", "Name", group=GRP_KZ3, inline="e3")
kz3_time   = input.session("0830-1100", "Session", group=GRP_KZ3, tooltip=TT_SESSION)
kz3_color  = input.color(color.new(color.green, 85), "Color", group=GRP_KZ3)

kz4_enable = input.bool(false, "Enable", group=GRP_KZ4, inline="e4")
kz4_name   = input.string("London Close", "Name", group=GRP_KZ4, inline="e4")
kz4_time   = input.session("1000-1200", "Session", group=GRP_KZ4, tooltip=TT_SESSION)
kz4_color  = input.color(color.new(color.orange, 85), "Color", group=GRP_KZ4)

kz5_enable = input.bool(false, "Enable", group=GRP_KZ5, inline="e5")
kz5_name   = input.string("NY PM Killzone", "Name", group=GRP_KZ5, inline="e5")
kz5_time   = input.session("1330-1600", "Session", group=GRP_KZ5, tooltip=TT_SESSION)
kz5_color  = input.color(color.new(color.red, 85), "Color", group=GRP_KZ5)

// General Settings
kz_timezone   = input.string("America/New_York", "Timezone", options=["America/New_York", "UTC", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney"], group=GRP_GEN, tooltip=TT_TZ)
kz_weekdays   = input.bool(true, "Weekdays Only (Mon-Fri)", group=GRP_GEN, tooltip=TT_DAYS)
kz_show_label = input.bool(true, "Show Session Names", group=GRP_GEN)
kz_show_lines = input.bool(true, "Show Vertical Lines", group=GRP_GEN)
kz_extend     = input.bool(false, "Extend Box After Session", group=GRP_GEN, tooltip=TT_EXTEND)
kz_max_history = input.int(20, "Max Historical Killzones per Session", minval=1, maxval=50, group=GRP_GEN)

// ════════════════════════════════════════════════════════════════════════════════
// TYPES
// ════════════════════════════════════════════════════════════════════════════════

type Killzone
    box   bx
    line  lnStart
    line  lnEnd
    label lbl
    float kzHigh
    float kzLow
    int   startBar
    bool  active

// ════════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ════════════════════════════════════════════════════════════════════════════════

inSession(string sessionStr, string tz) =>
    not na(time(timeframe.period, sessionStr, tz))

isWeekday(string tz) =>
    dow = dayofweek(time, tz)
    dow >= dayofweek.monday and dow <= dayofweek.friday

deleteKillzone(Killzone kz) =>
    if not na(kz.bx)
        box.delete(kz.bx)
    if not na(kz.lnStart)
        line.delete(kz.lnStart)
    if not na(kz.lnEnd)
        line.delete(kz.lnEnd)
    if not na(kz.lbl)
        label.delete(kz.lbl)
    int(na)

trimKillzones(array<Killzone> list, int maxCount) =>
    while list.size() > maxCount
        oldest = list.shift()
        deleteKillzone(oldest)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// MAIN KILLZONE LOGIC
// ════════════════════════════════════════════════════════════════════════════════

processKillzone(array<Killzone> list, bool enable, string sessionStr, string kzName, color kzColor, string tz, bool weekdaysOnly, bool showLabel, bool showLines, bool extend, int maxHistory) =>
    if enable
        nowInSession = inSession(sessionStr, tz)
        weekdayOk    = not weekdaysOnly or isWeekday(tz)
        isActiveBar  = nowInSession and weekdayOk

        Killzone activeKZ = na
        if list.size() > 0
            last = list.get(list.size() - 1)
            if last.active
                activeKZ := last

        // SESSION STARTS — create new killzone
        if isActiveBar and na(activeKZ)
            newBox = box.new(bar_index, high, bar_index, low, bgcolor=kzColor, border_color=color.new(kzColor, 50), border_width=0)
            line  startLn = na
            line  endLn   = na
            label lbl     = na

            if showLines
                startLn := line.new(bar_index, high, bar_index, low, extend=extend.both, color=color.new(kzColor, 50), style=line.style_solid, width=1)

            if showLabel
                lbl := label.new(bar_index, high, kzName, style=label.style_label_lower_right, color=color.new(kzColor, 70), textcolor=color.white, size=size.small)

            newKZ = Killzone.new(newBox, startLn, endLn, lbl, high, low, bar_index, true)
            list.push(newKZ)

        // SESSION ACTIVE — update high/low and box
        else if isActiveBar and not na(activeKZ)
            if high > activeKZ.kzHigh
                activeKZ.kzHigh := high
            if low < activeKZ.kzLow
                activeKZ.kzLow := low
            activeKZ.bx.set_top(activeKZ.kzHigh)
            activeKZ.bx.set_bottom(activeKZ.kzLow)
            activeKZ.bx.set_right(bar_index)

        // SESSION ENDS — close out the killzone
        else if not isActiveBar and not na(activeKZ)
            activeKZ.active := false
            activeKZ.bx.set_right(bar_index)

            if showLines
                endLn = line.new(bar_index, high, bar_index, low, extend=extend.both, color=color.new(kzColor, 50), style=line.style_solid, width=1)
                activeKZ.lnEnd := endLn

        // EXTEND mode — keep updating box right edge after session ends
        if extend and not na(activeKZ) and not activeKZ.active
            activeKZ.bx.set_right(bar_index)

        trimKillzones(list, maxHistory)

    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════════════════════════════

var array<Killzone> kz1List = array.new<Killzone>()
var array<Killzone> kz2List = array.new<Killzone>()
var array<Killzone> kz3List = array.new<Killzone>()
var array<Killzone> kz4List = array.new<Killzone>()
var array<Killzone> kz5List = array.new<Killzone>()

// ════════════════════════════════════════════════════════════════════════════════
// EXECUTE
// ════════════════════════════════════════════════════════════════════════════════

processKillzone(kz1List, kz1_enable, kz1_time, kz1_name, kz1_color, kz_timezone, kz_weekdays, kz_show_label, kz_show_lines, kz_extend, kz_max_history)
processKillzone(kz2List, kz2_enable, kz2_time, kz2_name, kz2_color, kz_timezone, kz_weekdays, kz_show_label, kz_show_lines, kz_extend, kz_max_history)
processKillzone(kz3List, kz3_enable, kz3_time, kz3_name, kz3_color, kz_timezone, kz_weekdays, kz_show_label, kz_show_lines, kz_extend, kz_max_history)
processKillzone(kz4List, kz4_enable, kz4_time, kz4_name, kz4_color, kz_timezone, kz_weekdays, kz_show_label, kz_show_lines, kz_extend, kz_max_history)
processKillzone(kz5List, kz5_enable, kz5_time, kz5_name, kz5_color, kz_timezone, kz_weekdays, kz_show_label, kz_show_lines, kz_extend, kz_max_history)
````
