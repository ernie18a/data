<!-- tradingview-pine-id: PUB;0aff1ab0e19047dcbdce919401183213 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Range Tool [vault]

Source: https://www.tradingview.com/script/8ZR4y5k8-Dynamic-Range-Tool-vault/

## Description

Dynamic Range Tool [vault] is a complete session range framework. Instead of stacking five separate tools every morning you get one: the session range with its quarters and projections, average range targets from the daily, weekly and monthly timeframes, daily and weekly opens, center mass of the previous daily and weekly candle, and automatic order blocks. One script, one chart, alerts on every level.

THE SESSION RANGE

The engine is a time window defined in EST. The default is 19:00 to 02:45, which is the asian session plus the london open lead in. The script tracks the highest high and lowest low inside that window and builds three lines from it: range high, range low, range mid. Those lines are then extended to whatever hour you set in "Extend To Hour", 19:00 the next evening by default, so the levels sit in front of you for the entire trading day.

On top of that you get the range quarters at 25% and 75%, drawn dashed in the theme accent color. Those are the levels price tends to react to on the way back into the middle.

Two vertical markers show the range gate and the moment the window closes, so you never lose track of where the measurement ends.

RANGE PROJECTIONS

Turn on "Show Range Projection" and you get the range mirrored above and below the midpoint at 1x, 1.5x, 2x and 2.5x. Classic range expansion logic. If the asian session printed 40 points you already know where 1x and 2x sit before london even starts. Upper levels use the theme top color, lower levels the bottom color.

ADR / AWR / AMR TARGETS

This is the part that does the heavy lifting. The script computes an average candle range (14 periods by default) separately on the daily, weekly, monthly and a custom intraday timeframe (60 or 240 minutes), then projects:

- Daily projected high = day low + ADR
- Daily projected low = day high - ADR
- The same for the week and the month, with progressively thicker lines
- The same for your custom timeframe
- Top hash and bottom hash, the range midpoint plus and minus half an ADR
- A second pair at the midpoint plus and minus a full ADR

Every level is labelled on the right and fires its own alert. Once the day has already delivered its average range the projected high and low cross over each other, and the script deletes both lines and their labels automatically so you are not left staring at levels that no longer mean anything.

Underneath, semi transparent zones are shaded between the range midpoint and the ADR projection. They show how much room is left before the average day is fully used up.

OPENS AND CENTER MASS

- Daily open and weekly open, colored dynamically: bottom color when price trades above the open, top color when below. One glance tells you which side of the open you are on.
- Center mass daily and weekly, the midpoint of the previous daily and weekly candle body. Thick neutral line, one of the better mean reversion magnets on intraday charts.

ORDER BLOCKS

A separate module. The script measures momentum as the percentage change of open against the open four bars back. When that change crosses the sensitivity threshold (25 by default, meaning 0.25%) it walks back 4 to 15 bars, finds the last candle opposite to the impulse, and turns it into a block. Mitigation is your choice of wick or close. Blocks are removed automatically once mitigated, and price entering an active block triggers an alert.

A minimum spacing of 5 bars between signals keeps the chart clean in chop.

STATS PANEL

Top right corner: last session range, ADR, AWR and the custom range value. Displayed in pips or in ticks depending on the toggle.

THEMES

The [vault] build ships with a full theme engine:

- Vault Red (default) - red upside, blue downside, white structure
- Vault Classic - the original orange and blue palette
- Ice - cold blues
- Neon - magenta and green
- Gold - gold and purple
- Mono - white and greys for dark charts
- Custom - unlocks every manual color picker

Switching a theme repaints the range lines, targets, zones, labels, order blocks and panel text in one move. The range center line is white now instead of black, so it is finally visible on a dark chart.

ALERTS

Weekly, monthly, daily and custom projected high and low, top hash, bottom hash, price inside bullish block, price inside bearish block. All fire once per bar.

HOW TO USE IT

1. Intraday chart. Minute based timeframes are read directly from the chart resolution.
2. Set the session window in EST for your market. For index futures leave it at 19:00 to 02:45.
3. Start the day with three questions: which side of the range am i on, which side of the daily open am i on, how much of the average range is still unused.
4. Treat the upper and lower ADR targets as places to take risk off, not places to enter.
5. The range mid and the center mass lines are return levels, not continuation levels.

TECHNICAL NOTES

Higher timeframe data (daily, weekly, monthly, custom) is requested with lookahead enabled. That keeps the levels anchored on historical bars, but it also means this script is not suitable for bar by bar backtesting or for driving an automated strategy. It is a context drawing tool, not a simulation.

All drawing is anchored to bar time rather than bar index, so levels stay locked to the clock.

The "ADR Days" input is a leftover from the original and does not affect any calculation. The averaging length lives in "ADR period".

Nothing here is financial advice. The tool draws context, the decisions are yours.

Based on Dynamic Range Tool V1 by Black Box Trading.

---

## Source Code

````pine
//@version=6
// ============================================================
// Dynamic Range Tool [vault]
// payoutvault.one
// based on "Dynamic Range Tool V1" (Black Box Trading)
// v6 port + theme engine + white center line + fixes
// ============================================================
indicator('Dynamic Range Tool [vault]', shorttitle='DRT [vault]', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ------------------------------------------------------------
// THEME ENGINE
// ------------------------------------------------------------
g_theme = 'Theme'
input_theme = input.string('Vault Red', title = 'Color Theme', options = ['Vault Red', 'Vault Classic', 'Ice', 'Neon', 'Gold', 'Mono', 'Custom'], group = g_theme, tooltip = 'Vault Red is the default palette (upper side red, lower side blue). Pick Custom to unlock the manual color pickers below.')

theme_up = switch input_theme
    'Vault Red' => #ff2e4c
    'Vault Classic' => #ff9800
    'Ice' => #00e5ff
    'Neon' => #ff00e5
    'Gold' => #ffd700
    'Mono' => #ffffff
    => color.orange

theme_dn = switch input_theme
    'Vault Red' => #2962ff
    'Vault Classic' => #2962ff
    'Ice' => #1e88e5
    'Neon' => #00ff9d
    'Gold' => #8e24aa
    'Mono' => #9e9e9e
    => color.blue

theme_neutral = switch input_theme
    'Ice' => #e0f7fa
    'Gold' => #f5f5f5
    => #ffffff

theme_accent = switch input_theme
    'Vault Red' => #ffb300
    'Vault Classic' => #ffeb3b
    'Ice' => #80deea
    'Neon' => #ccff00
    'Gold' => #ffab00
    'Mono' => #bdbdbd
    => color.yellow

theme_mass = input_theme == 'Mono' ? #757575 : color.gray

useTheme = input_theme != 'Custom'

// ------------------------------------------------------------
// DISPLAY TOGGLES
// ------------------------------------------------------------
g_disp = 'Display'
show_blocks = input.bool(true, title = 'Show Blocks', group = g_disp)
showDailyCenter = input.bool(true, title = 'Show Previous Daily Center Mass', group = g_disp)
showWeeklyCenter = input.bool(true, title = 'Show Previous Weekly Center Mass', group = g_disp)
showDailyOpen = input.bool(true, title = 'Show Daily Open', group = g_disp)
showWeeklyOpen = input.bool(true, title = 'Show Weekly Open', group = g_disp)
showADRTargets = input.bool(true, title = 'Show ADR Targets', group = g_disp)
showRangeProjection = input.bool(false, title = 'Show Range Projection', group = g_disp)
showADR = input.bool(true, title = 'Show Average Daily Range', group = g_disp)
is_forex_pips = input.bool(true, title = 'Display range in pips', group = g_disp)

g_adr = 'Range Settings'
daily_adr = input.int(1, title = 'ADR Days (legacy)', minval = 0, group = g_adr, tooltip = 'Kept for settings compatibility with V1. Not used in any calculation - the averaging length is set below.')
daily_adr_length = input.int(14, title = 'ADR period (bars, default 14)', minval = 1, group = g_adr)
input_tf = input.string('240', title = 'Custom Range', options = ['60', '240'], group = g_adr)

g_ses = 'Session Window (EST)'
input_ssth = input.string('19', title = 'Start Hour', options = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'], group = g_ses)
input_sstm = input.string('00', title = 'Start Minute', options = ['00', '15', '30', '45'], group = g_ses)
input_esth = input.string('02', title = 'End Hour', options = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'], group = g_ses)
input_estm = input.string('45', title = 'End Minute', options = ['00', '15', '30', '45'], group = g_ses)
input_elth = input.string('19', title = 'Extend To Hour', options = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'], group = g_ses)
input_eltm = input.string('00', title = 'Extend To Minute', options = ['00', '15', '30', '45'], group = g_ses)

// ------------------------------------------------------------
// CUSTOM COLORS (only used when Theme = Custom)
// ------------------------------------------------------------
g_custom = 'Custom Colors (Theme = Custom)'
input_box_line_top_color = input.string('orange', title = 'Top Color', options = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'], group = g_custom)
input_box_line_bottom_color = input.string('blue', title = 'Bottom Color', options = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'], group = g_custom)
input_box_line_color = input.string('white', title = 'Range Outline Color', options = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'], group = g_custom)
input_midline_color = input.string('white', title = 'Center Range Line Color', options = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'], group = g_custom)
input_text_color = input.string('white', title = 'Text Color', options = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'], group = g_custom)

// ------------------------------------------------------------
// STYLE
// ------------------------------------------------------------
g_style = 'Style'
boxLineWidth = input.int(1, title = 'Range Outline Width', minval = 1, maxval = 10, group = g_style)
input_box_line_style = input.string('solid', title = 'Range Outline Style', options = ['solid', 'dashed', 'dotted'], group = g_style)
sessionLineWidth = input.int(2, title = 'Session Line Width', minval = 1, maxval = 20, group = g_style)
input_upperlower_line_style = input.string('solid', title = 'Session Line Style', options = ['solid', 'dashed', 'dotted'], group = g_style)
input_middle_line_style = input.string('solid', title = 'Center Range Line Style', options = ['solid', 'dashed', 'dotted'], group = g_style)
input_label_size = input.string('AUTO', title = 'Text Size', options = ['AUTO', 'tiny', 'small', 'normal', 'large'], group = g_style)

// ------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------
f_color(name) =>
    switch name
        'aqua' => color.aqua
        'black' => color.black
        'blue' => color.blue
        'fuchsia' => color.fuchsia
        'gray' => color.gray
        'green' => color.green
        'lime' => color.lime
        'maroon' => color.maroon
        'navy' => color.navy
        'olive' => color.olive
        'orange' => color.orange
        'purple' => color.purple
        'red' => color.red
        'silver' => color.silver
        'teal' => color.teal
        'white' => color.white
        'yellow' => color.yellow
        => color.black

f_lineStyle(name) =>
    switch name
        'solid' => line.style_solid
        'dashed' => line.style_dashed
        'dotted' => line.style_dotted
        => line.style_solid

// FIX: force integer output, otherwise str.tostring() leaks decimals
// into the session string and time() throws "incorrect entry syntax"
f_pad(v) =>
    vi = int(math.round(v))
    (vi < 10 ? '0' : '') + str.tostring(vi)

// resolved colors
line_color_top = useTheme ? theme_up : f_color(input_box_line_top_color)
line_color_bottom = useTheme ? theme_dn : f_color(input_box_line_bottom_color)
line_color = useTheme ? theme_neutral : f_color(input_box_line_color)
midline_color = useTheme ? theme_neutral : f_color(input_midline_color)
text_color = useTheme ? theme_neutral : f_color(input_text_color)
col_up = line_color_top
col_dn = line_color_bottom
col_accent = useTheme ? theme_accent : color.yellow
col_mass = useTheme ? theme_mass : color.gray

box_line_style = f_lineStyle(input_box_line_style)
upperlower_line_style = f_lineStyle(input_upperlower_line_style)
middle_line_style = f_lineStyle(input_middle_line_style)

labelsize = switch input_label_size
    'AUTO' => size.auto
    'tiny' => size.tiny
    'small' => size.small
    'normal' => size.normal
    'large' => size.large
    => size.normal

// ------------------------------------------------------------
// TIME MATH
// ------------------------------------------------------------
// chart resolution in minutes (V1 only mapped 1/3/5/15/30/45 and fell back to 15)
chart_time_period_int = timeframe.isminutes ? timeframe.multiplier : timeframe.isseconds ? 1 : 15

start_range_hour_int = int(str.tonumber(input_ssth))
start_range_minute_int = int(str.tonumber(input_sstm))
end_range_hour_int = int(str.tonumber(input_esth))
end_range_minute_int = int(str.tonumber(input_estm))
end_line_minute_int = int(str.tonumber(input_eltm))

int end_line_hour_int = int(str.tonumber(input_elth))
if end_line_hour_int == 0
    end_line_hour_int := -24 + 8

// session string, built with proper wrap-around
// V1 did hour + str.tostring(minute + chartMinutes) which produced junk like "0260" on 15m charts
// FIX: math.floor + int cast, and 00:00 is written as 2400 so the session is never empty
ses_end_total = (end_range_hour_int * 60 + end_range_minute_int + chart_time_period_int) % 1440
ses_end_h = int(math.floor(ses_end_total / 60))
ses_end_m = int(ses_end_total % 60)
ses_end_h_str = ses_end_h == 0 and ses_end_m == 0 ? 24 : ses_end_h
range_ses = f_pad(start_range_hour_int) + f_pad(start_range_minute_int) + '-' + f_pad(ses_end_h_str) + f_pad(ses_end_m) + ':1234567'

f_security(_symbol, _res, _src) =>
    request.security(_symbol, _res, _src[0], lookahead = barmerge.lookahead_on)

open_bar(ses) =>
    t = time('D', ses)
    na(t[1]) and not na(t) or t[1] < t

is_open(ses) =>
    not na(time(timeframe.period, ses))

adr(length) =>
    rng = high - low
    ta.sma(rng[1], length)

to_pips(val) =>
    is_forex_pips ? math.round(val / syminfo.mintick / 10) : math.round(val / syminfo.mintick)

day_adr = f_security(syminfo.tickerid, 'D', adr(daily_adr_length))
week_adr = f_security(syminfo.tickerid, 'W', adr(daily_adr_length))
month_adr = f_security(syminfo.tickerid, 'M', adr(daily_adr_length))
current_adr = f_security(syminfo.tickerid, input_tf, adr(daily_adr_length))

startTimeDelta = 24 - start_range_hour_int + 1
endTimeDelta = 24 - start_range_hour_int + 1
isStartTimeAlignment = hour + startTimeDelta > 24 ? 0 : 1
isEndTimeAlignment = hour + endTimeDelta > 24 ? 1 : 0

FromDate = timestamp(year, month, dayofmonth - isStartTimeAlignment, start_range_hour_int, start_range_minute_int)
ToDate = timestamp(year, month, dayofmonth + isEndTimeAlignment, end_range_hour_int, end_range_minute_int) - chart_time_period_int
LineFromDate = timestamp(year, month, dayofmonth + isEndTimeAlignment, end_range_hour_int, end_range_minute_int) - chart_time_period_int
LineToDate = timestamp(year, month, dayofmonth + isEndTimeAlignment, end_line_hour_int, end_line_minute_int)
LabelDate = timestamp(year, month, dayofmonth + isEndTimeAlignment, end_line_hour_int + 4, end_line_minute_int)

// ------------------------------------------------------------
// RANGE
// ------------------------------------------------------------
inSession = not na(time(timeframe.period, range_ses))
range_open_bar = open_bar(range_ses)
range_is_open = is_open(range_ses)

float range_low = na
range_low := range_is_open ? range_open_bar ? low : math.min(range_low[1], low) : range_low[1]
float range_high = na
range_high := range_is_open ? range_open_bar ? high : math.max(range_high[1], high) : range_high[1]
range_mid = math.avg(range_low, range_high)
range_size = range_high - range_low

// quarters
qLow = line.new(LineFromDate, range_mid - (range_mid - range_low) / 2, LineToDate, range_mid - (range_mid - range_low) / 2, xloc = xloc.bar_time, color = col_accent, style = line.style_dashed, width = boxLineWidth)
line.delete(qLow[1])

qHigh = line.new(LineFromDate, range_mid + (range_high - range_mid) / 2, LineToDate, range_mid + (range_high - range_mid) / 2, xloc = xloc.bar_time, color = col_accent, style = line.style_dashed, width = boxLineWidth)
line.delete(qHigh[1])

// range boundaries + mid
tl = line.new(LineFromDate, range_low, LineToDate, range_low, xloc = xloc.bar_time, color = line_color, style = upperlower_line_style, width = sessionLineWidth)
line.delete(tl[1])

th = line.new(LineFromDate, range_high, LineToDate, range_high, xloc = xloc.bar_time, color = line_color, style = upperlower_line_style, width = sessionLineWidth)
line.delete(th[1])

tm = line.new(LineFromDate, range_mid, LineToDate, range_mid, xloc = xloc.bar_time, color = midline_color, style = middle_line_style, width = sessionLineWidth)
line.delete(tm[1])

// 1x mirror of the range, drawn even without full projections
ttrlex = line.new(LineFromDate, range_low + range_size, LineToDate, range_low + range_size, xloc = xloc.bar_time, color = line_color, style = box_line_style, width = boxLineWidth)
line.delete(ttrlex[1])

btrhex = line.new(LineFromDate, range_high - range_size, LineToDate, range_high - range_size, xloc = xloc.bar_time, color = line_color, style = box_line_style, width = boxLineWidth)
line.delete(btrhex[1])

if showRangeProjection
    p15u = line.new(LineFromDate, range_mid + 1.5 * range_size, LineToDate, range_mid + 1.5 * range_size, xloc = xloc.bar_time, color = line_color_top, style = box_line_style, width = sessionLineWidth)
    line.delete(p15u[1])

    p20u = line.new(LineFromDate, range_mid + 2 * range_size, LineToDate, range_mid + 2 * range_size, xloc = xloc.bar_time, color = line_color_top, style = middle_line_style, width = sessionLineWidth)
    line.delete(p20u[1])

    p25u = line.new(LineFromDate, range_mid + 2.5 * range_size, LineToDate, range_mid + 2.5 * range_size, xloc = xloc.bar_time, color = line_color_top, style = box_line_style, width = sessionLineWidth)
    line.delete(p25u[1])

    p10u = line.new(LineFromDate, range_mid + range_size, LineToDate, range_mid + range_size, xloc = xloc.bar_time, color = line_color_top, style = middle_line_style, width = sessionLineWidth)
    line.delete(p10u[1])

    p15d = line.new(LineFromDate, range_mid - 1.5 * range_size, LineToDate, range_mid - 1.5 * range_size, xloc = xloc.bar_time, color = line_color_bottom, style = box_line_style, width = sessionLineWidth)
    line.delete(p15d[1])

    p20d = line.new(LineFromDate, range_mid - 2 * range_size, LineToDate, range_mid - 2 * range_size, xloc = xloc.bar_time, color = line_color_bottom, style = middle_line_style, width = sessionLineWidth)
    line.delete(p20d[1])

    p25d = line.new(LineFromDate, range_mid - 2.5 * range_size, LineToDate, range_mid - 2.5 * range_size, xloc = xloc.bar_time, color = line_color_bottom, style = box_line_style, width = sessionLineWidth)
    line.delete(p25d[1])

    p10d = line.new(LineFromDate, range_mid - range_size, LineToDate, range_mid - range_size, xloc = xloc.bar_time, color = line_color_bottom, style = box_line_style, width = sessionLineWidth)
    line.delete(p10d[1])

// ------------------------------------------------------------
// HTF DATA
// ------------------------------------------------------------
highDaily = f_security(syminfo.tickerid, 'D', high)
lowDaily = f_security(syminfo.tickerid, 'D', low)
highWeekly = f_security(syminfo.tickerid, 'W', high)
lowWeekly = f_security(syminfo.tickerid, 'W', low)
highMonthly = f_security(syminfo.tickerid, 'M', high)
lowMonthly = f_security(syminfo.tickerid, 'M', low)
highCurrent = f_security(syminfo.tickerid, input_tf, high)
lowCurrent = f_security(syminfo.tickerid, input_tf, low)
openDaily = f_security(syminfo.tickerid, 'D', open)
openWeekly = f_security(syminfo.tickerid, 'W', open)

if showDailyOpen
    mColor = openDaily < close ? col_dn : col_up
    dailyOpen = line.new(LineFromDate, openDaily, LineToDate, openDaily, xloc = xloc.bar_time, color = mColor, style = line.style_solid, width = sessionLineWidth * 2)
    line.delete(dailyOpen[1])
    lbl = label.new(LabelDate, openDaily, 'Daily Open', style = label.style_none, xloc = xloc.bar_time, textcolor = mColor)
    label.delete(lbl[1])

if showWeeklyOpen
    mColor = openWeekly < close ? col_dn : col_up
    weeklyOpen = line.new(LineFromDate, openWeekly, LineToDate, openWeekly, xloc = xloc.bar_time, color = mColor, style = line.style_solid, width = sessionLineWidth * 4)
    line.delete(weeklyOpen[1])
    lbl = label.new(LabelDate, openWeekly, 'Weekly Open', style = label.style_none, xloc = xloc.bar_time, textcolor = mColor)
    label.delete(lbl[1])

// ------------------------------------------------------------
// ADR / AWR / AMR TARGETS
// ------------------------------------------------------------
if showADRTargets
    // weekly
    atrLowWeek = line.new(LineFromDate, highWeekly - week_adr, LineToDate, highWeekly - week_adr, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dotted, width = sessionLineWidth * 4)
    line.delete(atrLowWeek[1])
    lblLowW = label.new(LabelDate, highWeekly - week_adr, 'Weekly Projected Low', style = label.style_none, xloc = xloc.bar_time, textcolor = col_dn)
    label.delete(lblLowW[1])
    if low < highWeekly - week_adr and high > highWeekly - week_adr
        alert('Weekly Projected Low', alert.freq_once_per_bar)

    atrHighWeek = line.new(LineFromDate, lowWeekly + week_adr, LineToDate, lowWeekly + week_adr, xloc = xloc.bar_time, color = line_color_top, style = line.style_dotted, width = sessionLineWidth * 4)
    line.delete(atrHighWeek[1])
    lblHighW = label.new(LabelDate, lowWeekly + week_adr, 'Weekly Projected High', style = label.style_none, xloc = xloc.bar_time, textcolor = col_up)
    label.delete(lblHighW[1])
    if high > lowWeekly + week_adr and low < lowWeekly + week_adr
        alert('Weekly Projected High', alert.freq_once_per_bar)

    // monthly
    atrLowMonth = line.new(LineFromDate, highMonthly - month_adr, LineToDate, highMonthly - month_adr, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dotted, width = sessionLineWidth * 6)
    line.delete(atrLowMonth[1])
    lblLowM = label.new(LabelDate, highMonthly - month_adr, 'Monthly Projected Low', style = label.style_none, xloc = xloc.bar_time, textcolor = col_dn)
    label.delete(lblLowM[1])
    if low < highMonthly - month_adr and high > highMonthly - month_adr
        alert('Monthly Projected Low', alert.freq_once_per_bar)

    atrHighMonth = line.new(LineFromDate, lowMonthly + month_adr, LineToDate, lowMonthly + month_adr, xloc = xloc.bar_time, color = line_color_top, style = line.style_dotted, width = sessionLineWidth * 6)
    line.delete(atrHighMonth[1])
    lblHighM = label.new(LabelDate, lowMonthly + month_adr, 'Monthly Projected High', style = label.style_none, xloc = xloc.bar_time, textcolor = col_up)
    label.delete(lblHighM[1])
    if high > lowMonthly + month_adr and low < lowMonthly + month_adr
        alert('Monthly Projected High', alert.freq_once_per_bar)

    // daily
    atrLow = line.new(LineFromDate, highDaily - day_adr, LineToDate, highDaily - day_adr, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dotted, width = sessionLineWidth)
    line.delete(atrLow[1])
    lblLowD = label.new(LabelDate, highDaily - day_adr, 'Daily Projected Low', style = label.style_none, xloc = xloc.bar_time, textcolor = col_dn)
    label.delete(lblLowD[1])
    if low < highDaily - day_adr and high > lowDaily + day_adr
        alert('Daily Projected Low', alert.freq_once_per_bar)

    atrHigh = line.new(LineFromDate, lowDaily + day_adr, LineToDate, lowDaily + day_adr, xloc = xloc.bar_time, color = line_color_top, style = line.style_dotted, width = sessionLineWidth)
    line.delete(atrHigh[1])
    lblHighD = label.new(LabelDate, lowDaily + day_adr, 'Daily Projected High', style = label.style_none, xloc = xloc.bar_time, textcolor = col_up)
    label.delete(lblHighD[1])
    if high > lowDaily + day_adr and low < lowDaily + day_adr
        alert('Daily Projected High', alert.freq_once_per_bar)

    // daily range already extended -> drop the crossed lines and their labels
    if line.get_y1(atrLow) > line.get_y1(atrHigh)
        line.delete(atrLow)
        line.delete(atrHigh)
        label.delete(lblLowD)
        label.delete(lblHighD)

    // custom timeframe
    atrLowCurrent = line.new(time, highCurrent - current_adr, LineToDate, highCurrent - current_adr, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dotted, width = 1)
    line.delete(atrLowCurrent[1])
    lblLowC = label.new(LabelDate, highCurrent - current_adr, input_tf + ' Projected Low', style = label.style_none, xloc = xloc.bar_time, textcolor = col_dn)
    label.delete(lblLowC[1])
    if low < highCurrent - current_adr and high > lowCurrent + current_adr
        alert('Custom Projected Low', alert.freq_once_per_bar)

    atrHighCurrent = line.new(time, lowCurrent + current_adr, LineToDate, lowCurrent + current_adr, xloc = xloc.bar_time, color = line_color_top, style = line.style_dotted, width = 1)
    line.delete(atrHighCurrent[1])
    lblHighC = label.new(LabelDate, lowCurrent + current_adr, input_tf + ' Projected High', style = label.style_none, xloc = xloc.bar_time, textcolor = col_up)
    label.delete(lblHighC[1])
    if high > lowCurrent + current_adr and low < lowCurrent + current_adr
        alert('Custom Projected High', alert.freq_once_per_bar)

    if line.get_y1(atrLowCurrent) > line.get_y1(atrHighCurrent)
        line.delete(atrLowCurrent)
        line.delete(atrHighCurrent)
        label.delete(lblLowC)
        label.delete(lblHighC)

    // hashes around the range midpoint
    atrLowAvg = line.new(LineFromDate, range_mid - day_adr / 2, LineToDate, range_mid - day_adr / 2, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dashed, width = math.max(1, sessionLineWidth / 2))
    line.delete(atrLowAvg[1])
    lblBottomHash = label.new(LabelDate, range_mid - day_adr / 2, 'Bottom Hash', style = label.style_none, xloc = xloc.bar_time, textcolor = col_dn)
    label.delete(lblBottomHash[1])
    if low < range_mid - day_adr / 2 and high > range_mid - day_adr / 2
        alert('Bottom Hash', alert.freq_once_per_bar)

    atrHighAvg = line.new(LineFromDate, range_mid + day_adr / 2, LineToDate, range_mid + day_adr / 2, xloc = xloc.bar_time, color = line_color_top, style = line.style_dashed, width = math.max(1, sessionLineWidth / 2))
    line.delete(atrHighAvg[1])
    lblTopHash = label.new(LabelDate, range_mid + day_adr / 2, 'Top Hash', style = label.style_none, xloc = xloc.bar_time, textcolor = col_up)
    label.delete(lblTopHash[1])
    if high > range_mid + day_adr / 2 and low < range_mid + day_adr / 2
        alert('Top Hash', alert.freq_once_per_bar)

    atrLowAvgl = line.new(LineFromDate, range_mid - day_adr, LineToDate, range_mid - day_adr, xloc = xloc.bar_time, color = line_color_bottom, style = line.style_dashed, width = sessionLineWidth)
    line.delete(atrLowAvgl[1])

    atrHighAvgh = line.new(LineFromDate, range_mid + day_adr, LineToDate, range_mid + day_adr, xloc = xloc.bar_time, color = line_color_top, style = line.style_dashed, width = sessionLineWidth)
    line.delete(atrHighAvgh[1])

    // shaded zones between the mid and the ADR projection
    lowboxX = box.new(LineFromDate, range_mid - day_adr, LineToDate, highDaily - day_adr, border_color = color.new(col_dn, 95), bgcolor = color.new(col_dn, 90), xloc = xloc.bar_time)
    box.delete(lowboxX[1])

    hiboxX = box.new(LineFromDate, range_mid + day_adr, LineToDate, lowDaily + day_adr, border_color = color.new(col_up, 95), bgcolor = color.new(col_up, 90), xloc = xloc.bar_time)
    box.delete(hiboxX[1])

    lowboxMid = box.new(LineFromDate, range_low, LineToDate, highDaily - day_adr, border_color = color.new(line_color, 95), bgcolor = color.new(line_color, 100), xloc = xloc.bar_time, border_width = 1)
    box.delete(lowboxMid[1])

    hiboxMid = box.new(LineFromDate, range_high, LineToDate, lowDaily + day_adr, border_color = color.new(line_color, 95), bgcolor = color.new(line_color, 100), xloc = xloc.bar_time, border_width = 1)
    box.delete(hiboxMid[1])

// ------------------------------------------------------------
// CENTER LINE - was black in V1, now white / theme neutral
// ------------------------------------------------------------
plot(range_mid, title = 'Range Center Line', color = color.new(midline_color, 50), linewidth = 3)

// ------------------------------------------------------------
// CENTER MASS
// ------------------------------------------------------------
previousWeeklyOpen = f_security(syminfo.tickerid, 'W', open[1])
previousWeeklyClose = f_security(syminfo.tickerid, 'W', close[1])
midWeek = previousWeeklyOpen < previousWeeklyClose ? previousWeeklyClose - (previousWeeklyClose - previousWeeklyOpen) / 2 : previousWeeklyOpen - (previousWeeklyOpen - previousWeeklyClose) / 2

if showWeeklyCenter
    lw = line.new(LineFromDate - 1, midWeek, LineToDate, midWeek, xloc = xloc.bar_time, color = col_mass, style = line.style_solid, width = sessionLineWidth + 3)
    line.delete(lw[1])
    lbl = label.new(LabelDate, midWeek, 'Center Mass Weekly', style = label.style_none, xloc = xloc.bar_time, textcolor = col_mass)
    label.delete(lbl[1])

previousDailyOpen = f_security(syminfo.tickerid, 'D', open[1])
previousDailyClose = f_security(syminfo.tickerid, 'D', close[1])
midDay = previousDailyOpen < previousDailyClose ? previousDailyClose - (previousDailyClose - previousDailyOpen) / 2 : previousDailyOpen - (previousDailyOpen - previousDailyClose) / 2

if showDailyCenter
    ld = line.new(LineFromDate, midDay, LineToDate, midDay, xloc = xloc.bar_time, color = col_mass, style = line.style_solid, width = sessionLineWidth + 2)
    line.delete(ld[1])
    lbl = label.new(LabelDate, midDay, 'Center Mass Daily', style = label.style_none, xloc = xloc.bar_time, textcolor = col_mass)
    label.delete(lbl[1])

// ------------------------------------------------------------
// STATS PANEL
// ------------------------------------------------------------
var table statsTable = table.new(position = position.top_right, columns = 1, rows = 1, border_width = 1)
if showADR and barstate.islast
    openingRange = to_pips(range_high[1] - range_low[1])
    table.cell(table_id = statsTable, text_size = labelsize, text_color = text_color, column = 0, row = 0, text = 'Opening Range: ' + str.tostring(openingRange) + '\nAverage Daily Range: ' + str.tostring(to_pips(day_adr)) + '\nAverage Weekly Range: ' + str.tostring(to_pips(week_adr)) + '\nCustom Range: ' + str.tostring(to_pips(current_adr)))

// ------------------------------------------------------------
// SESSION MARKERS
// ------------------------------------------------------------
LineGate = timestamp(year, month, dayofmonth - isStartTimeAlignment, start_range_hour_int + 7, start_range_minute_int + 45)

vertGate = line.new(LineGate, range_mid - range_size / 2, LineGate, range_mid + range_size / 2, color = color.new(line_color, 50), width = 2, xloc = xloc.bar_time, style = line.style_solid)
line.delete(vertGate[1])

vertGateEnd = line.new(LineToDate, range_mid - range_size / 2, LineToDate, range_mid + range_size / 2, color = color.new(line_color, 50), width = 2, xloc = xloc.bar_time, style = line.style_solid)
line.delete(vertGateEnd[1])

// ------------------------------------------------------------
// ORDER BLOCKS
// ------------------------------------------------------------
g_ob = 'Order Block'
sensInput = input.int(25, minval = 1, title = 'Sensitivity', group = g_ob, tooltip = 'Momentum threshold in hundredths of a percent. 25 = 0.25% change of open over 4 bars. Higher value = fewer, stronger blocks.')
sens = sensInput / 100.0

OBMitigationType = input.string('Wick', title = 'OB Mitigation Type', options = ['Close', 'Wick'], group = g_ob)
OBBullMitigation = OBMitigationType == 'Wick' ? close[1] : low
OBBearMitigation = OBMitigationType == 'Wick' ? close[1] : high

col_bullish = input.color(color.new(color.blue, 70), title = 'Bullish', inline = 'a', group = g_ob)
col_bullish_ob = input.color(color.new(color.blue, 90), title = 'Background', inline = 'a', group = g_ob)
col_bearish = input.color(color.new(color.orange, 70), title = 'Bearish', inline = 'b', group = g_ob)
col_bearish_ob = input.color(color.new(color.orange, 90), title = 'Background', inline = 'b', group = g_ob)

ob_bull_border = useTheme ? color.new(col_dn, 70) : col_bullish
ob_bull_bg = useTheme ? color.new(col_dn, 90) : col_bullish_ob
ob_bear_border = useTheme ? color.new(col_up, 70) : col_bearish
ob_bear_bg = useTheme ? color.new(col_up, 90) : col_bearish_ob

var array<box> longBoxes = array.new<box>()
var array<box> shortBoxes = array.new<box>()
var int cross_index = na

bool ob_created = false
bool ob_created_bull = false

pc = (open - open[4]) / open[4] * 100

if ta.crossunder(pc, -sens)
    ob_created := true
    cross_index := bar_index

if ta.crossover(pc, sens)
    ob_created_bull := true
    cross_index := bar_index

if ob_created and cross_index - cross_index[1] > 5 and show_blocks
    int last_green = 0
    for i = 4 to 15
        if close[i] > open[i]
            last_green := i
            break
    b = box.new(left = bar_index[last_green], top = high[last_green], bottom = low[last_green], right = bar_index[last_green], bgcolor = ob_bear_bg, border_color = ob_bear_border, extend = extend.right)
    array.push(shortBoxes, b)

if ob_created_bull and cross_index - cross_index[1] > 5 and show_blocks
    int last_red = 0
    for i = 4 to 15
        if close[i] < open[i]
            last_red := i
            break
    b = box.new(left = bar_index[last_red], top = high[last_red], bottom = low[last_red], right = bar_index[last_red], bgcolor = ob_bull_bg, border_color = ob_bull_border, extend = extend.right)
    array.push(longBoxes, b)

if array.size(shortBoxes) > 0
    for i = array.size(shortBoxes) - 1 to 0
        sbox = array.get(shortBoxes, i)
        topB = box.get_top(sbox)
        botB = box.get_bottom(sbox)
        if OBBearMitigation > topB
            array.remove(shortBoxes, i)
            box.delete(sbox)
        else if high > botB and show_blocks
            alert('Price inside Bearish Block', alert.freq_once_per_bar)

if array.size(longBoxes) > 0
    for i = array.size(longBoxes) - 1 to 0
        lbox = array.get(longBoxes, i)
        topB = box.get_top(lbox)
        botB = box.get_bottom(lbox)
        if OBBullMitigation < botB
            array.remove(longBoxes, i)
            box.delete(lbox)
        else if low < topB and show_blocks
            alert('Price inside Bullish Block', alert.freq_once_per_bar)
````
