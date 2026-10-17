# ICT Killzones | EonMetrics

- url: https://www.tradingview.com/script/oRPeSvXe-ICT-Killzones-EonMetrics/
- type: indicator
- pine_id: PUB;084098ff118c4ccb988d63c0926705a1
- version: 1.0

## Description

ICT Killzones by EonMetrics

[b]WHAT IT DOES[/b]

This indicator draws colored boxes on your chart during the hours when big institutional traders are historically most active — these time windows are called "killzones." Each box tracks the highest and lowest price reached while that session is open. When the session ends, the box "seals" and its high and low turn into lines that stretch forward — these are levels price is likely to react to later, so you can see them long after the session is over.

https://www.tradingview.com/x/pd7wzZgz/

It also draws simple opening-price and high/low lines for the Day, Week and Month, plus the previous day/week/month's numbers. These are shown in the same script as the killzones because they answer the same question at two different zoom levels: "where is the market's attention right now" — killzones tell you that at the hour-by-hour level, and Day/Week/Month tell you that at the bigger-picture level. Traders normally watch both together, which is why they're combined here instead of split into two separate tools.

https://www.tradingview.com/x/qER4Ura8/

[b]HOW TO ACTUALLY USE IT (STEP BY STEP)[/b]

1. Watch the Asian session box first. It's usually a quiet, narrow range — this range often becomes the "bait" that later sessions test.
2. When London or New York opens, watch for a fast move that quickly reverses (price pokes above/below the recent range and snaps back). This fake-out is common at session opens — the real move often goes the opposite way.
3. Use the high/low lines left behind by earlier sessions as your targets. If price is moving up, the next line above it (an earlier session's high, or the day/week open) is a natural place price may reach and react.
4. Check the Previous Day Close and Week Open lines for context — is today trading above or below yesterday's close? Above or below this week's open? That tells you the bigger picture bias.
5. Turn on "Show Yesterday" if you want to compare today's session ranges against yesterday's.

[b]EVERY SETTING EXPLAINED[/b]

Killzones group
- Show Asian / London Open / NY Pre-Market / NY Open / London Close / NY Lunch / NY PM — turns each individual session box on or off. All times are New York time and automatically adjust for Daylight Saving.
- Show Yesterday — also draws all the above boxes for the previous trading day.

Custom Killzone group
- Show Custom KZ — turns on an extra session box that you define yourself (for a market's own open, a prop-firm trading window, or any other hours you want tracked).
- Custom Session — the start-end time of your custom window (24-hour format). If the end time is earlier than the start time, it automatically understands the session crosses midnight.
- Session Timezone — which timezone your custom time window is read in. "Exchange" uses the timezone of whatever symbol you have open.
- Label Name — the name shown on your custom box and its high/low lines.
- Custom Color — the color of your custom box and lines.

https://www.tradingview.com/x/RV8qEQaF/

Colors group
- One color picker per killzone — sets the fill color of that session's box.

Style group
- Show Box Label — shows the session's name written inside its box while it's still active.
- Show Pivots (H/L) — after a session ends, draws its high and low as lines going forward. Turn this off if you only want the boxes, no forward lines.
- Show Midpoint (50%) — also draws a line at the exact halfway point of each finished session's range.
- Pivot Line Width — how thick the high/low lines are.
- Pivot Style — solid, dashed, or dotted line for the high/low lines.
- Midpoint Style — solid, dashed, or dotted line for the halfway line.
- Show Pivot Labels — shows small text tags (like "London H") at the end of each line.
- After Mitigation — choose what happens once price actually breaks through a level: "Stop at mitigation" freezes the line exactly where it was broken (so you keep a record of where it happened), or "Delete on mitigation" removes it completely for a cleaner chart.
- Alert Broken Pivots — sends you an alert whenever price breaks through one of these levels.

Day / Week / Month group
- Day Open / High-Low, with its own color — today's opening price, and optionally today's high/low, updating live.
- Prev Day Open / Close / High-Low, with its own color — yesterday's numbers, useful as reference points for today.
- The same three lines (Open, High/Low, and Previous versions of each) are repeated for Week and Month.
- Line Style / Line Width — applies to all of the Day/Week/Month lines at once.
- Show Labels — turns the text tags for these lines on or off.

## Source Code

````pine
//@version=6
indicator('ICT Killzones | EonMetrics', overlay = true,
  max_boxes_count  = 500,
  max_labels_count = 500,
  max_lines_count  = 500)

// ═════════════════════════════════════════════════════════════════════════════
//  SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

show_asian     = input.bool(true,  'Show Asian KZ',           group = 'Killzones', tooltip = 'Asian Killzone (20:00–00:00 NY). Liquidity built here is often swept by London or NY sessions.')
show_lon_open  = input.bool(true,  'Show London Open KZ',     group = 'Killzones', tooltip = 'London Open Killzone (02:00–05:00 NY). Watch for Judas Swing — false move before real direction.')
show_ny_pre    = input.bool(true,  'Show NY Pre-Market KZ',   group = 'Killzones', tooltip = 'NY Pre-Market Killzone (07:00–09:30 NY). ICT window — institutions position before NYSE open.')
show_ny_open   = input.bool(true,  'Show NY Open KZ',         group = 'Killzones', tooltip = 'NY Open Killzone (09:30–11:00 NY). Actual NYSE open bell — highest volume, aggressive moves.')
show_lon_close = input.bool(false, 'Show London Close KZ',    group = 'Killzones', tooltip = 'London Close Killzone (10:00–12:00 NY). London institutions close positions — common reversal window.')
show_yesterday  = input.bool(false, 'Show Yesterday',          group = 'Killzones', tooltip = 'Also display Killzones from the previous trading day.')
show_ny_lunch   = input.bool(true,  'Show NY Lunch KZ',        group = 'Killzones', tooltip = 'NY Lunch Killzone (12:00–13:00 NY). Low liquidity window — market consolidates before NY PM session.')
show_ny_pm      = input.bool(true,  'Show NY PM KZ',           group = 'Killzones', tooltip = 'NY PM Killzone (13:30–16:00 NY). Second major move of the day — often reverses the morning trend.')

asian_color     = input.color(color.new(#b2b5be, 85), 'Asian',         group = 'Colors', tooltip = 'Fill color for the Asian Killzone.')
lon_open_color  = input.color(color.new(#2196f3, 85), 'London Open',   group = 'Colors', tooltip = 'Fill color for the London Open Killzone.')
ny_pre_color    = input.color(color.new(#ff9800, 85), 'NY Pre-Market', group = 'Colors', tooltip = 'Fill color for the NY Pre-Market Killzone.')
ny_open_color   = input.color(color.new(#f44336, 85), 'NY Open',       group = 'Colors', tooltip = 'Fill color for the NY Open Killzone.')
lon_close_color = input.color(color.new(#9c27b0, 85), 'London Close',  group = 'Colors', tooltip = 'Fill color for the London Close Killzone.')
ny_lunch_color  = input.color(color.new(#607d8b, 85), 'NY Lunch',      group = 'Colors', tooltip = 'Fill color for the NY Lunch Killzone. Gray by default — low-activity window.')
ny_pm_color     = input.color(color.new(#00bcd4, 85), 'NY PM',         group = 'Colors', tooltip = 'Fill color for the NY PM Killzone.')

// ── Custom (user-defined) killzone ──────────────────────────────────────────────
grp_custom     = 'Custom Killzone'
show_custom    = input.bool(false, 'Show Custom KZ',   group = grp_custom, tooltip = 'Define your own killzone with the session window, timezone, name and color below. Use it for sessions the presets do not cover — a different market\'s open, a personal window, a prop-firm session, backtesting your own hours.')
custom_session = input.session('0300-0400', 'Custom Session', group = grp_custom, tooltip = 'Time window for the custom killzone, in the timezone selected below (24h HHMM-HHMM). Crosses midnight automatically when the end is earlier than the start (e.g. 2200-0200).')
custom_tz_inp  = input.string('America/New_York', 'Session Timezone', options = ['Exchange', 'America/New_York', 'Europe/London', 'Asia/Tokyo', 'Asia/Shanghai', 'Asia/Hong_Kong', 'Asia/Kolkata', 'Australia/Sydney', 'UTC'], group = grp_custom, tooltip = 'Timezone the custom session times are read in. "Exchange" uses the chart symbol\'s own timezone. The preset killzones above always use New York.')
custom_name    = input.string('Custom', 'Label Name',  group = grp_custom, tooltip = 'Name shown on the session box and on its High / Low pivot labels.')
custom_color   = input.color(color.new(#8bc34a, 85), 'Custom Color', group = grp_custom, tooltip = 'Fill color for the custom killzone box and its pivot lines.')

show_box_label  = input.bool(true,  'Show Box Label',       group = 'Style', tooltip = 'Show killzone name inside the box while the session is active.')
show_pivots     = input.bool(true,  'Show Pivots (H/L)',    group = 'Style', tooltip = 'After each session closes, extend High and Low lines to the right until price breaks them. These act as key support and resistance levels.')
show_midpoint   = input.bool(false, 'Show Midpoint (50%)',  group = 'Style', tooltip = 'Draw a dashed line at the 50% midpoint of each closed session range. Price often returns to this level.')
pivot_width     = input.int(1, 'Pivot Line Width', minval = 1, maxval = 4, group = 'Style', tooltip = 'Stroke width of the High, Low and Midpoint pivot lines.')
pivot_style_inp = input.string('Solid', 'Pivot Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Style', tooltip = 'Line style for High/Low pivot lines after session closes.')
mid_style_inp   = input.string('Dashed', 'Midpoint Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Style', tooltip = 'Line style for the 50% midpoint line.')
show_pivot_lbl   = input.bool(true,  'Show Pivot Labels',      group = 'Style', tooltip = 'Show H / L / Mid labels at the right end of each pivot line.')
mitigated_mode   = input.string('Stop at mitigation', 'After Mitigation', options = ['Stop at mitigation', 'Delete on mitigation'], group = 'Style', tooltip = 'Stop at mitigation: line stops exactly at the bar where price broke the level. Delete on mitigation: line and label disappear completely once the level is broken.')
alert_pivots     = input.bool(true,  'Alert Broken Pivots',    group = 'Style', tooltip = 'Fire an alert when price breaks a session High or Low pivot level.')

// ═════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═════════════════════════════════════════════════════════════════════════════

pivot_line_style() =>
    switch pivot_style_inp
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

mid_line_style() =>
    switch mid_style_inp
        'Solid'  => line.style_solid
        'Dotted' => line.style_dotted
        => line.style_dashed

// ═════════════════════════════════════════════════════════════════════════════
//  SESSION DETECTION  (America/New_York — DST auto)
// ═════════════════════════════════════════════════════════════════════════════

tz     = 'America/New_York'
MS_DAY = 86400000

in_sess(string s) => not na(time('1', s, tz))

is_asian     = in_sess('2000-2359') or in_sess('0000-0001')
is_lon_open  = in_sess('0200-0500')
is_ny_pre    = in_sess('0700-0930')
is_ny_open   = in_sess('0930-1100')
is_lon_close = in_sess('1000-1200')
is_ny_lunch  = in_sess('1200-1300')
is_ny_pm     = in_sess('1330-1600')

// Custom killzone: resolved in the user-selected timezone (may differ from NY).
custom_tz    = custom_tz_inp == 'Exchange' ? syminfo.timezone : custom_tz_inp
is_custom    = not na(time('1', custom_session, custom_tz))

// Detect whether the custom session crosses midnight (e.g. '2200-0200'), same as the
// Asian killzone does — a wrapping session needs one extra day of window lookback,
// otherwise its evening-start portion falls outside in_window_custom and never draws.
_cs_parts     = str.split(custom_session, '-')
_cs_start_num = array.size(_cs_parts) == 2 ? str.tonumber(array.get(_cs_parts, 0)) : na
_cs_end_num   = array.size(_cs_parts) == 2 ? str.tonumber(array.get(_cs_parts, 1)) : na
custom_wraps  = not na(_cs_start_num) and not na(_cs_end_num) and _cs_end_num <= _cs_start_num

// today_start in NY timezone — prevents timezone mismatch issues
_ny_year  = year(timenow, tz)
_ny_month = month(timenow, tz)
_ny_day   = dayofmonth(timenow, tz)
today_start = timestamp(tz, _ny_year, _ny_month, _ny_day, 0, 0, 0)
// Standard window: today or yesterday
in_window       = time >= (show_yesterday ? today_start - MS_DAY : today_start)
// Asian starts at 20:00 NY — yesterday's Asian begins evening before yesterday
in_window_asian = time >= (show_yesterday ? today_start - 2 * MS_DAY : today_start - MS_DAY)
// Custom KZ window is measured in ITS OWN timezone so a session that "belongs to today"
// in e.g. Tokyo is not clipped by New York's midnight boundary.
_c_year  = year(timenow, custom_tz)
_c_month = month(timenow, custom_tz)
_c_day   = dayofmonth(timenow, custom_tz)
custom_today_start = timestamp(custom_tz, _c_year, _c_month, _c_day, 0, 0, 0)
// Mirrors in_window / in_window_asian: a wrapping session always needs 1 day of lookback
// (its start sits in the prior calendar day); show_yesterday adds one more on top of that.
_custom_days_back = (custom_wraps ? 1 : 0) + (show_yesterday ? 1 : 0)
in_window_custom  = time >= custom_today_start - _custom_days_back * MS_DAY

// ═════════════════════════════════════════════════════════════════════════════
//  TYPE
// ═════════════════════════════════════════════════════════════════════════════

type KZone
    box    zone_box
    line   hi_line
    line   lo_line
    line   mid_line
    label  box_lbl
    label  hi_lbl
    label  lo_lbl
    label  mid_lbl
    float  hi
    float  lo
    int    end_bar
    bool   hi_broken
    bool   lo_broken
    string name

// ═════════════════════════════════════════════════════════════════════════════
//  STATE
// ═════════════════════════════════════════════════════════════════════════════

var KZone kz_asian     = na
var KZone kz_lon_open  = na
var KZone kz_ny_pre    = na
var KZone kz_ny_open   = na
var KZone kz_lon_close = na

var bool prev_asian     = false
var bool prev_lon_open  = false
var bool prev_ny_pre    = false
var bool prev_ny_open   = false
var bool prev_lon_close = false

var KZone kz_ny_lunch  = na
var KZone kz_ny_pm     = na

var bool prev_ny_lunch = false
var bool prev_ny_pm    = false

var KZone kz_custom    = na
var bool  prev_custom  = false

// All sealed zones are tracked here so EVERY session's pivots (not just the latest
// instance) keep getting break-checked and mitigated — even yesterday's.
var array<KZone> sealed = array.new<KZone>()

// ═════════════════════════════════════════════════════════════════════════════
//  ZONE FUNCTIONS
// ═════════════════════════════════════════════════════════════════════════════

kz_open(color c) =>
    b  = box.new(bar_index, high, bar_index, low, border_color = na, bgcolor = c)
    lb = show_box_label ? label.new(bar_index, high, '',
      color     = color.new(color.white, 100),
      textcolor = color.new(c, 0),
      style     = label.style_label_lower_right,
      size      = size.small) : na
    KZone.new(b, na, na, na, lb, na, na, na, high, low, bar_index, false, false, '')

kz_update(KZone z, string name) =>
    z.hi      := math.max(z.hi, high)
    z.lo      := math.min(z.lo, low)
    z.end_bar := bar_index
    box.set_right(z.zone_box, bar_index)
    box.set_top(z.zone_box, z.hi)
    box.set_bottom(z.zone_box, z.lo)
    if not na(z.box_lbl)
        label.set_x(z.box_lbl, bar_index)
        label.set_y(z.box_lbl, z.hi)
        label.set_text(z.box_lbl, name)

kz_seal(KZone z, color c, string name) =>
    z.name := name
    if not na(z.box_lbl)
        label.delete(z.box_lbl)
        z.box_lbl := na

    if show_pivots
        mid  = (z.hi + z.lo) / 2.0
        xfrom = z.end_bar

        z.hi_line := line.new(xfrom, z.hi, xfrom + 1, z.hi, color = color.new(c, 20), width = pivot_width, style = pivot_line_style(), extend = extend.right)
        z.lo_line := line.new(xfrom, z.lo, xfrom + 1, z.lo, color = color.new(c, 20), width = pivot_width, style = pivot_line_style(), extend = extend.right)

        if show_midpoint
            z.mid_line := line.new(xfrom, mid, xfrom + 1, mid, color = color.new(c, 40), width = pivot_width, style = mid_line_style(), extend = extend.right)

        if show_pivot_lbl
            // Labels fixed at right edge of box (xfrom = last bar of session)
            // style_label_left = tag opens to the right, anchored at xfrom
            z.hi_lbl  := label.new(xfrom, z.hi, name + ' H',   color = color.new(c, 20), textcolor = color.white, style = label.style_label_lower_left, size = size.tiny)
            z.lo_lbl  := label.new(xfrom, z.lo, name + ' L',   color = color.new(c, 20), textcolor = color.white, style = label.style_label_upper_left, size = size.tiny)
            if show_midpoint
                z.mid_lbl := label.new(xfrom, mid, name + ' Mid', color = color.new(c, 40), textcolor = color.white, style = label.style_label_lower_left, size = size.tiny)

        // Hand the sealed zone to the global tracker so its pivots stay managed.
        array.push(sealed, z)

// Check if price broke a pivot — stop extending line, update label style
kz_check_breaks(KZone z, string name) =>
    stop_at_mit = mitigated_mode == 'Stop at mitigation'

    if not na(z.hi_line) and not z.hi_broken
        if high > z.hi_line.get_y1()
            z.hi_broken := true
            if alert_pivots
                alert(name + ' High broken — price traded above ' + str.tostring(math.round(z.hi_line.get_y1(), 2)), alert.freq_once_per_bar)
            if stop_at_mit
                z.hi_line.set_extend(extend.none)
                z.hi_line.set_x2(bar_index)
                if not na(z.hi_lbl)
                    z.hi_lbl.set_style(label.style_label_down)
            if not stop_at_mit
                line.delete(z.hi_line)
                z.hi_line := na
                label.delete(z.hi_lbl)
                z.hi_lbl := na

    if not na(z.lo_line) and not z.lo_broken
        if low < z.lo_line.get_y1()
            z.lo_broken := true
            if alert_pivots
                alert(name + ' Low broken — price traded below ' + str.tostring(math.round(z.lo_line.get_y1(), 2)), alert.freq_once_per_bar)
            if stop_at_mit
                z.lo_line.set_extend(extend.none)
                z.lo_line.set_x2(bar_index)
                if not na(z.lo_lbl)
                    z.lo_lbl.set_style(label.style_label_up)
            if not stop_at_mit
                line.delete(z.lo_line)
                z.lo_line := na
                label.delete(z.lo_lbl)
                z.lo_lbl := na

    // Zone is fully resolved once both sides are taken — caller drops it then.
    z.hi_broken and z.lo_broken

// Freeze an evicted zone's lines so very old, unbroken pivots don't run across the
// whole chart forever once they fall outside the retained window.
kz_evict(KZone z) =>
    if not na(z.hi_line)
        z.hi_line.set_extend(extend.none)
        z.hi_line.set_x2(bar_index)
    if not na(z.lo_line)
        z.lo_line.set_extend(extend.none)
        z.lo_line.set_x2(bar_index)
    if not na(z.mid_line)
        z.mid_line.set_extend(extend.none)
        z.mid_line.set_x2(bar_index)

// ═════════════════════════════════════════════════════════════════════════════
//  ASIAN KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_asian
    if is_asian and not prev_asian and in_window_asian
        kz_asian := kz_open(asian_color)
    if is_asian and not na(kz_asian) and in_window_asian
        kz_update(kz_asian, 'Asian KZ')
    if not is_asian and prev_asian and not na(kz_asian)
        kz_seal(kz_asian, asian_color, 'Asian')
bool opened_asian = is_asian and not prev_asian
prev_asian := is_asian

// ═════════════════════════════════════════════════════════════════════════════
//  LONDON OPEN KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_lon_open
    if is_lon_open and not prev_lon_open and in_window
        kz_lon_open := kz_open(lon_open_color)
    if is_lon_open and not na(kz_lon_open) and in_window
        kz_update(kz_lon_open, 'London Open KZ')
    if not is_lon_open and prev_lon_open and not na(kz_lon_open)
        kz_seal(kz_lon_open, lon_open_color, 'London')
bool opened_lon_open = is_lon_open and not prev_lon_open
prev_lon_open := is_lon_open

// ═════════════════════════════════════════════════════════════════════════════
//  NY PRE-MARKET KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_ny_pre
    if is_ny_pre and not prev_ny_pre and in_window
        kz_ny_pre := kz_open(ny_pre_color)
    if is_ny_pre and not na(kz_ny_pre) and in_window
        kz_update(kz_ny_pre, 'NY Pre-Market KZ')
    if not is_ny_pre and prev_ny_pre and not na(kz_ny_pre)
        kz_seal(kz_ny_pre, ny_pre_color, 'NY Pre')
bool opened_ny_pre = is_ny_pre and not prev_ny_pre
prev_ny_pre := is_ny_pre

// ═════════════════════════════════════════════════════════════════════════════
//  NY OPEN KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_ny_open
    if is_ny_open and not prev_ny_open and in_window
        kz_ny_open := kz_open(ny_open_color)
    if is_ny_open and not na(kz_ny_open) and in_window
        kz_update(kz_ny_open, 'NY Open KZ')
    if not is_ny_open and prev_ny_open and not na(kz_ny_open)
        kz_seal(kz_ny_open, ny_open_color, 'NY Open')
bool opened_ny_open = is_ny_open and not prev_ny_open
prev_ny_open := is_ny_open

// ═════════════════════════════════════════════════════════════════════════════
//  LONDON CLOSE KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_lon_close
    if is_lon_close and not prev_lon_close and in_window
        kz_lon_close := kz_open(lon_close_color)
    if is_lon_close and not na(kz_lon_close) and in_window
        kz_update(kz_lon_close, 'London Close KZ')
    if not is_lon_close and prev_lon_close and not na(kz_lon_close)
        kz_seal(kz_lon_close, lon_close_color, 'Lon Close')
bool opened_lon_close = is_lon_close and not prev_lon_close
prev_lon_close := is_lon_close


// ═════════════════════════════════════════════════════════════════════════════
//  NY LUNCH KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_ny_lunch
    if is_ny_lunch and not prev_ny_lunch and in_window
        kz_ny_lunch := kz_open(ny_lunch_color)
    if is_ny_lunch and not na(kz_ny_lunch) and in_window
        kz_update(kz_ny_lunch, 'NY Lunch KZ')
    if not is_ny_lunch and prev_ny_lunch and not na(kz_ny_lunch)
        kz_seal(kz_ny_lunch, ny_lunch_color, 'NY Lunch')
bool opened_ny_lunch = is_ny_lunch and not prev_ny_lunch
prev_ny_lunch := is_ny_lunch

// ═════════════════════════════════════════════════════════════════════════════
//  NY PM KZ
// ═════════════════════════════════════════════════════════════════════════════

if show_ny_pm
    if is_ny_pm and not prev_ny_pm and in_window
        kz_ny_pm := kz_open(ny_pm_color)
    if is_ny_pm and not na(kz_ny_pm) and in_window
        kz_update(kz_ny_pm, 'NY PM KZ')
    if not is_ny_pm and prev_ny_pm and not na(kz_ny_pm)
        kz_seal(kz_ny_pm, ny_pm_color, 'NY PM')
bool opened_ny_pm = is_ny_pm and not prev_ny_pm
prev_ny_pm := is_ny_pm

// ═════════════════════════════════════════════════════════════════════════════
//  CUSTOM KZ  (user-defined session / timezone / name / color)
// ═════════════════════════════════════════════════════════════════════════════

if show_custom
    if is_custom and not prev_custom and in_window_custom
        kz_custom := kz_open(custom_color)
    if is_custom and not na(kz_custom) and in_window_custom
        kz_update(kz_custom, custom_name)
    if not is_custom and prev_custom and not na(kz_custom)
        kz_seal(kz_custom, custom_color, custom_name)
bool opened_custom = is_custom and not prev_custom
prev_custom := is_custom

// ═════════════════════════════════════════════════════════════════════════════
//  D/W/M OPEN, CLOSE, HIGH, LOW
// ═════════════════════════════════════════════════════════════════════════════

var g_dwm = 'Day / Week / Month'

// ─── Inputs ───────────────────────────────────────────────────────────────────
show_d_open   = input.bool(true,  'Day Open',        inline = 'D',  group = g_dwm, tooltip = 'Current day open price (00:00 NY).')
show_d_hl     = input.bool(false, 'High/Low',        inline = 'D',  group = g_dwm, tooltip = 'Current day High and Low lines — update in real time.')
d_color       = input.color(color.new(#2196f3, 20),  '',            inline = 'D',  group = g_dwm, tooltip = 'Color for current Day levels.')

show_pd_open  = input.bool(false, 'Prev Day Open',   inline = 'PD', group = g_dwm, tooltip = 'Previous day open.')
show_pd_close = input.bool(false, 'Close',           inline = 'PD', group = g_dwm, tooltip = 'Previous day close — first major S/R of the new day.')
show_pd_hl    = input.bool(false, 'High/Low',        inline = 'PD', group = g_dwm, tooltip = 'Previous day High and Low — key levels going into the new day.')
pd_color      = input.color(color.new(#2196f3, 55),  '',            inline = 'PD', group = g_dwm, tooltip = 'Color for Previous Day levels.')

show_w_open   = input.bool(true,  'Week Open',       inline = 'W',  group = g_dwm, tooltip = 'Current week open (Monday 00:00 NY).')
show_w_hl     = input.bool(false, 'High/Low',        inline = 'W',  group = g_dwm, tooltip = 'Current week High and Low lines.')
w_color       = input.color(color.new(#ff9800, 20),  '',            inline = 'W',  group = g_dwm, tooltip = 'Color for current Week levels.')

show_pw_open  = input.bool(false, 'Prev Week Open',  inline = 'PW', group = g_dwm, tooltip = 'Previous week open.')
show_pw_close = input.bool(false, 'Close',           inline = 'PW', group = g_dwm, tooltip = 'Previous week close.')
show_pw_hl    = input.bool(false, 'High/Low',        inline = 'PW', group = g_dwm, tooltip = 'Previous week High and Low — important HTF levels.')
pw_color      = input.color(color.new(#ff9800, 55),  '',            inline = 'PW', group = g_dwm, tooltip = 'Color for Previous Week levels.')

show_m_open   = input.bool(false, 'Month Open',      inline = 'M',  group = g_dwm, tooltip = 'Current month open.')
show_m_hl     = input.bool(false, 'High/Low',        inline = 'M',  group = g_dwm, tooltip = 'Current month High and Low lines.')
m_color       = input.color(color.new(#e91e63, 20),  '',            inline = 'M',  group = g_dwm, tooltip = 'Color for current Month levels.')

show_pm_open  = input.bool(false, 'Prev Month Open', inline = 'PM', group = g_dwm, tooltip = 'Previous month open.')
show_pm_close = input.bool(false, 'Close',           inline = 'PM', group = g_dwm, tooltip = 'Previous month close.')
show_pm_hl    = input.bool(false, 'High/Low',        inline = 'PM', group = g_dwm, tooltip = 'Previous month High and Low — macro S/R levels.')
pm_color      = input.color(color.new(#e91e63, 55),  '',            inline = 'PM', group = g_dwm, tooltip = 'Color for Previous Month levels.')

dwm_line_style_inp = input.string('Dashed', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_dwm, tooltip = 'Style for all D/W/M lines.')
dwm_line_width     = input.int(1, 'Line Width', minval = 1, maxval = 4, group = g_dwm, tooltip = 'Width for all D/W/M lines.')
show_dwm_labels    = input.bool(true, 'Show Labels', group = g_dwm, tooltip = 'Show label on each D/W/M line.')

// ─── Helpers ──────────────────────────────────────────────────────────────────
dwm_style() =>
    switch dwm_line_style_inp
        'Solid'  => line.style_solid
        'Dotted' => line.style_dotted
        => line.style_dashed

dwm_make(float price, color c, string txt) =>
    ln = line.new(bar_index, price, bar_index + 1, price,
      color  = c, width = dwm_line_width, style = dwm_style(), extend = extend.right)
    lb = show_dwm_labels ? label.new(bar_index, price, txt,
      color = color.new(c, 20), textcolor = color.white,
      style = label.style_label_lower_left, size = size.tiny) : na
    [ln, lb]

dwm_del(line ln, label lb) =>
    line.delete(ln)
    label.delete(lb)

dwm_ext(line ln) =>
    if not na(ln)
        ln.set_x2(bar_index)

// ─── State ────────────────────────────────────────────────────────────────────
// current
var line d_o_ln = na
var label d_o_lb = na
var float d_o = na
var line d_h_ln = na
var label d_h_lb = na
var float d_h = na
var line d_l_ln = na
var label d_l_lb = na
var float d_l = na

var line w_o_ln = na
var label w_o_lb = na
var float w_o = na
var line w_h_ln = na
var label w_h_lb = na
var float w_h = na
var line w_l_ln = na
var label w_l_lb = na
var float w_l = na

var line m_o_ln = na
var label m_o_lb = na
var float m_o = na
var line m_h_ln = na
var label m_h_lb = na
var float m_h = na
var line m_l_ln = na
var label m_l_lb = na
var float m_l = na

// previous
var line pd_o_ln = na
var label pd_o_lb = na
var float pd_o = na
var line pd_c_ln = na
var label pd_c_lb = na
var float pd_c = na
var line pd_h_ln = na
var label pd_h_lb = na
var float pd_h = na
var line pd_l_ln = na
var label pd_l_lb = na
var float pd_l = na

var line pw_o_ln = na
var label pw_o_lb = na
var float pw_o = na
var line pw_c_ln = na
var label pw_c_lb = na
var float pw_c = na
var line pw_h_ln = na
var label pw_h_lb = na
var float pw_h = na
var line pw_l_ln = na
var label pw_l_lb = na
var float pw_l = na

var line pm_o_ln = na
var label pm_o_lb = na
var float pm_o = na
var line pm_c_ln = na
var label pm_c_lb = na
var float pm_c = na
var line pm_h_ln = na
var label pm_h_lb = na
var float pm_h = na
var line pm_l_ln = na
var label pm_l_lb = na
var float pm_l = na

// ─── Logic ────────────────────────────────────────────────────────────────────
is_new_day   = na(time[1]) or dayofmonth(time, tz)  != dayofmonth(time[1], tz)  or month(time, tz) != month(time[1], tz)
// D1 forex bars open at Sunday 17:00 NY (prev day 17:00) so weekofyear() still reads the old week.
// Shifting by 17h lands us inside the actual trading day, fixing the Tuesday-instead-of-Monday bug.
_wadj        = timeframe.isdaily ? 17 * 60 * 60 * 1000 : 0
is_new_week  = na(time[1]) or weekofyear(time + _wadj, tz) != weekofyear(time[1] + _wadj, tz) or year(time + _wadj, tz) != year(time[1] + _wadj, tz)
is_new_month = na(time[1]) or month(time, tz)        != month(time[1], tz)        or year(time, tz)  != year(time[1], tz)

// ── DAY ───────────────────────────────────────────────────────────────────────
// Always track OHLC for previous-day calculations (regardless of show toggles)
if is_new_day
    // roll current → previous
    if show_pd_close
        pd_c := close[1]   // previous day's actual close (last bar of prior day), not the new day's open
        dwm_del(pd_c_ln, pd_c_lb)
        [_ln1, _lb1] = dwm_make(pd_c, pd_color, 'PDC')
        pd_c_ln := _ln1
        pd_c_lb := _lb1
    if show_pd_open and not na(d_o)
        pd_o := d_o
        dwm_del(pd_o_ln, pd_o_lb)
        [_ln2, _lb2] = dwm_make(pd_o, pd_color, 'PDO')
        pd_o_ln := _ln2
        pd_o_lb := _lb2
    if show_pd_hl and not na(d_h)
        pd_h := d_h
        pd_l := d_l
        dwm_del(pd_h_ln, pd_h_lb)
        dwm_del(pd_l_ln, pd_l_lb)
        [_ln3, _lb3] = dwm_make(pd_h, pd_color, 'PDH')
        pd_h_ln := _ln3
        pd_h_lb := _lb3
        [_ln4, _lb4] = dwm_make(pd_l, pd_color, 'PDL')
        pd_l_ln := _ln4
        pd_l_lb := _lb4
    // reset current day trackers
    d_o := open
    d_h := high
    d_l := low
    // draw current day lines
    if show_d_open
        dwm_del(d_o_ln, d_o_lb)
        [_ln5, _lb5] = dwm_make(d_o, d_color, 'D Open')
        d_o_ln := _ln5
        d_o_lb := _lb5
    if show_d_hl
        dwm_del(d_h_ln, d_h_lb)
        dwm_del(d_l_ln, d_l_lb)
        [_ln7, _lb7] = dwm_make(d_h, d_color, 'D High')
        d_h_ln := _ln7
        d_h_lb := _lb7
        [_ln8, _lb8] = dwm_make(d_l, d_color, 'D Low')
        d_l_ln := _ln8
        d_l_lb := _lb8
else
    // always update H/L for tracking (needed for previous day)
    if high > d_h
        d_h := high
        if show_d_hl and not na(d_h_ln)
            d_h_ln.set_y1(d_h)
            d_h_ln.set_y2(d_h)
        if show_d_hl and not na(d_h_lb)
            d_h_lb.set_y(d_h)
    if low < d_l
        d_l := low
        if show_d_hl and not na(d_l_ln)
            d_l_ln.set_y1(d_l)
            d_l_ln.set_y2(d_l)
        if show_d_hl and not na(d_l_lb)
            d_l_lb.set_y(d_l)
    dwm_ext(d_o_ln)
    dwm_ext(d_h_ln)
    dwm_ext(d_l_ln)
    dwm_ext(pd_o_ln)
    dwm_ext(pd_c_ln)
    dwm_ext(pd_h_ln)
    dwm_ext(pd_l_ln)

// ── WEEK ──────────────────────────────────────────────────────────────────────
if is_new_week
    if show_pw_close
        pw_c := close[1]   // previous week's actual close (last bar of prior week), not the new week's open
        dwm_del(pw_c_ln, pw_c_lb)
        [_ln9, _lb9] = dwm_make(pw_c, pw_color, 'PWC')
        pw_c_ln := _ln9
        pw_c_lb := _lb9
    if show_pw_open and not na(w_o)
        pw_o := w_o
        dwm_del(pw_o_ln, pw_o_lb)
        [_ln10, _lb10] = dwm_make(pw_o, pw_color, 'PWO')
        pw_o_ln := _ln10
        pw_o_lb := _lb10
    if show_pw_hl and not na(w_h)
        pw_h := w_h
        pw_l := w_l
        dwm_del(pw_h_ln, pw_h_lb)
        dwm_del(pw_l_ln, pw_l_lb)
        [_ln11, _lb11] = dwm_make(pw_h, pw_color, 'PWH')
        pw_h_ln := _ln11
        pw_h_lb := _lb11
        [_ln12, _lb12] = dwm_make(pw_l, pw_color, 'PWL')
        pw_l_ln := _ln12
        pw_l_lb := _lb12
    w_o := open
    w_h := high
    w_l := low
    if show_w_open
        dwm_del(w_o_ln, w_o_lb)
        [_ln13, _lb13] = dwm_make(w_o, w_color, 'W Open')
        w_o_ln := _ln13
        w_o_lb := _lb13
    if show_w_hl
        dwm_del(w_h_ln, w_h_lb)
        dwm_del(w_l_ln, w_l_lb)
        [_ln15, _lb15] = dwm_make(w_h, w_color, 'W High')
        w_h_ln := _ln15
        w_h_lb := _lb15
        [_ln16, _lb16] = dwm_make(w_l, w_color, 'W Low')
        w_l_ln := _ln16
        w_l_lb := _lb16
else
    if high > w_h
        w_h := high
        if show_w_hl and not na(w_h_ln)
            w_h_ln.set_y1(w_h)
            w_h_ln.set_y2(w_h)
        if show_w_hl and not na(w_h_lb)
            w_h_lb.set_y(w_h)
    if low < w_l
        w_l := low
        if show_w_hl and not na(w_l_ln)
            w_l_ln.set_y1(w_l)
            w_l_ln.set_y2(w_l)
        if show_w_hl and not na(w_l_lb)
            w_l_lb.set_y(w_l)
    dwm_ext(w_o_ln)
    dwm_ext(w_h_ln)
    dwm_ext(w_l_ln)
    dwm_ext(pw_o_ln)
    dwm_ext(pw_c_ln)
    dwm_ext(pw_h_ln)
    dwm_ext(pw_l_ln)

// ── MONTH ─────────────────────────────────────────────────────────────────────
if is_new_month
    if show_pm_close
        pm_c := close[1]   // previous month's actual close (last bar of prior month), not the new month's open
        dwm_del(pm_c_ln, pm_c_lb)
        [_ln17, _lb17] = dwm_make(pm_c, pm_color, 'PMC')
        pm_c_ln := _ln17
        pm_c_lb := _lb17
    if show_pm_open and not na(m_o)
        pm_o := m_o
        dwm_del(pm_o_ln, pm_o_lb)
        [_ln18, _lb18] = dwm_make(pm_o, pm_color, 'PMO')
        pm_o_ln := _ln18
        pm_o_lb := _lb18
    if show_pm_hl and not na(m_h)
        pm_h := m_h
        pm_l := m_l
        dwm_del(pm_h_ln, pm_h_lb)
        dwm_del(pm_l_ln, pm_l_lb)
        [_ln19, _lb19] = dwm_make(pm_h, pm_color, 'PMH')
        pm_h_ln := _ln19
        pm_h_lb := _lb19
        [_ln20, _lb20] = dwm_make(pm_l, pm_color, 'PML')
        pm_l_ln := _ln20
        pm_l_lb := _lb20
    m_o := open
    m_h := high
    m_l := low
    if show_m_open
        dwm_del(m_o_ln, m_o_lb)
        [_ln21, _lb21] = dwm_make(m_o, m_color, 'M Open')
        m_o_ln := _ln21
        m_o_lb := _lb21
    if show_m_hl
        dwm_del(m_h_ln, m_h_lb)
        dwm_del(m_l_ln, m_l_lb)
        [_ln23, _lb23] = dwm_make(m_h, m_color, 'M High')
        m_h_ln := _ln23
        m_h_lb := _lb23
        [_ln24, _lb24] = dwm_make(m_l, m_color, 'M Low')
        m_l_ln := _ln24
        m_l_lb := _lb24
else
    if high > m_h
        m_h := high
        if show_m_hl and not na(m_h_ln)
            m_h_ln.set_y1(m_h)
            m_h_ln.set_y2(m_h)
        if show_m_hl and not na(m_h_lb)
            m_h_lb.set_y(m_h)
    if low < m_l
        m_l := low
        if show_m_hl and not na(m_l_ln)
            m_l_ln.set_y1(m_l)
            m_l_ln.set_y2(m_l)
        if show_m_hl and not na(m_l_lb)
            m_l_lb.set_y(m_l)
    dwm_ext(m_o_ln)
    dwm_ext(m_h_ln)
    dwm_ext(m_l_ln)
    dwm_ext(pm_o_ln)
    dwm_ext(pm_c_ln)
    dwm_ext(pm_h_ln)
    dwm_ext(pm_l_ln)

// ═════════════════════════════════════════════════════════════════════════════
//  PIVOT BREAK MANAGEMENT — every sealed zone, every bar (handles all days)
// ═════════════════════════════════════════════════════════════════════════════
if array.size(sealed) > 0
    for i = array.size(sealed) - 1 to 0
        z = array.get(sealed, i)
        if kz_check_breaks(z, z.name)   // returns true once both H and L are taken
            array.remove(sealed, i)     // fully resolved -> stop tracking
// Bound the tracker: freeze and drop the oldest zones beyond the retained window
while array.size(sealed) > 30
    kz_evict(array.shift(sealed))

// Rising-edge captured BEFORE prev_* is reassigned (see opened_* above) — the
// previous inline "is_X and not prev_X" was always false here because prev_X had
// already been set equal to is_X earlier in the bar.
alertcondition(opened_asian,     'Asian KZ Opened',         'Asian Killzone opened (20:00 NY).')
alertcondition(opened_lon_open,  'London Open KZ Opened',   'London Open Killzone opened (02:00 NY).')
alertcondition(opened_ny_pre,    'NY Pre-Market KZ Opened', 'NY Pre-Market Killzone opened (07:00 NY).')
alertcondition(opened_ny_open,   'NY Open KZ Opened',       'NY Open Killzone opened (09:30 NY).')
alertcondition(opened_lon_close, 'London Close KZ Opened',  'London Close Killzone opened (10:00 NY).')
alertcondition(opened_ny_lunch,  'NY Lunch KZ Opened',      'NY Lunch Killzone opened (12:00 NY). Low liquidity — avoid new positions.')
alertcondition(opened_ny_pm,     'NY PM KZ Opened',         'NY PM Killzone opened (13:30 NY). Second major move window active.')
alertcondition(opened_custom,    'Custom KZ Opened',        'Custom Killzone opened.')
````
