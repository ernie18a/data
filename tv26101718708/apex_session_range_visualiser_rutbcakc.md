# APEX Session Range Visualiser

- url: https://www.tradingview.com/script/rutBCaKc-APEX-Session-Range-Visualiser/
- type: indicator
- pine_id: PUB;2801a66ec91d4dfda46bce972250040d
- version: 1.0

## Description

APEX Session Range Visualiser draws the one-hour range of each major market open — Frankfurt, London, New York and Sydney — on any intraday chart, so you can see how price behaves around the session's opening range.

[b]What it draws[/b]
For each enabled session it shades the measured hour, draws a box from the session high to the session low once the hour has closed, extends the high and low as reference lines for the following hours, and adds a midline. An optional label on each box shows the session name and the size of the range, which is useful for judging whether an open was unusually tight or wide compared with recent days.

[b]How the sessions are defined[/b]
Each session is defined in its own market's clock rather than in the chart's or the user's timezone: the European open at 09:00 Frankfurt time, London at 09:00 London time, New York at 09:30 New York time, and Australia at a Sydney-time setting. TradingView converts these to your chart, so the ranges stay on the true market open through every daylight-saving change on either side of the Atlantic, including the weeks each spring and autumn when Europe and the US are out of step. There are no "start hour" inputs to adjust when the clocks change. Label times are shown in a display timezone of your choice.

[b]Pre-market option[/b]
"Measure Pre-Market Hour" shifts each measurement window one hour earlier, so the range is taken from the quieter hour before the open and locks as the market opens. On index CFDs this is often the more useful framing, because the pre-market hour sets the levels that the opening drive breaks. Note that some index CFDs are closed pre-market, in which case the range will not draw.

[b]Drawing budget[/b]
TradingView allows an indicator 500 boxes and 500 lines. With three sessions enabled the script creates three boxes and nine lines a day, so "Draw History (days)" limits drawing to a set number of recent days and keeps older graphics from being silently removed.

[b]Use[/b]
Intended for 1- to 15-minute charts of index CFDs and major forex pairs, with the 5-minute chart as the reference timeframe. It draws no signals, stops or targets and places no orders. The source is open: the session logic is in the f_sess and f_lbl functions and the four session blocks, and can be adapted to other opens by changing the timezone constants and default times.

## Source Code

````pine
// APEX Session Range Visualiser v1.4
// Draws the one-hour opening range of the Frankfurt, London, New York and Sydney opens.
// Session graphics only - no signals, stops or targets.
//
// v1.4: Each session is defined in its own market's clock (Frankfurt, London, New York,
//   Sydney) and TradingView converts it to your chart, so the ranges stay on the true market
//   open through every daylight-saving change. Labels show times in your chosen display
//   timezone.
// v1.2: "Draw History (days)" keeps drawing within TradingView's 500 box / 500 line limit.
//   Optional labels show the session name and the measured range size.
// v1.1: "Measure Pre-Market Hour" measures the hour before each open instead of during it.
//@version=6
indicator("APEX Session Range Visualiser", shorttitle="APEX Sessions", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=500)

var string GRP_TZ  = "Timezone and Sessions"
var string GRP_EU  = "European Open"
var string GRP_UK  = "London Open"
var string GRP_NY  = "NY Open"
var string GRP_AU  = "Asia / Australia Open"
var string GRP_VIS = "Visual Settings"

// DISPLAY TIMEZONE - used only for the times printed on labels
TZ_UK  = "Europe/London"
TZ_CET = "Europe/Paris"
TZ_NY  = "America/New_York"
TZ_SYD = "Australia/Sydney"
TZ_DXB = "Asia/Dubai"
tz_choice = input.string("UK / London", "Display Timezone", options=["UK / London", "Europe / CET", "New York / ET", "Sydney / AEDT", "Dubai / GST"], group=GRP_TZ, tooltip="Only affects the times shown on labels. Session detection uses each market's own clock, so daylight saving is handled automatically.")
TZ = tz_choice == "Europe / CET" ? TZ_CET : tz_choice == "New York / ET" ? TZ_NY : tz_choice == "Sydney / AEDT" ? TZ_SYD : tz_choice == "Dubai / GST" ? TZ_DXB : TZ_UK

// SESSION HOME TIMEZONES - fixed. Each open is defined in the clock of its own market.
TZ_EU_HOME = "Europe/Berlin"
TZ_UK_HOME = "Europe/London"
TZ_NY_HOME = "America/New_York"
TZ_AU_HOME = "Australia/Sydney"

eu_open_h = input.int(9,  "EU open hour (Frankfurt time)",   group=GRP_TZ, minval=0, maxval=23, tooltip="Xetra opens 09:00 Frankfurt time. Leave at 9 unless you trade a different European open.")
eu_open_m = input.int(0,  "EU open minute",                  group=GRP_TZ, minval=0, maxval=59)
uk_open_h = input.int(9,  "UK open hour (London time)",      group=GRP_TZ, minval=0, maxval=23, tooltip="Measures 09:00-10:00 London time by default.")
uk_open_m = input.int(0,  "UK open minute",                  group=GRP_TZ, minval=0, maxval=59)
ny_open_h = input.int(9,  "NY open hour (New York time)",    group=GRP_TZ, minval=0, maxval=23, tooltip="NYSE opens 09:30 New York time. Leave at 9 / 30.")
ny_open_m = input.int(30, "NY open minute",                  group=GRP_TZ, minval=0, maxval=59)
au_open_h = input.int(8,  "AU open hour (Sydney time)",      group=GRP_TZ, minval=0, maxval=23, tooltip="Default 08:50 Sydney time. Set 10 / 0 for the ASX cash open.")
au_open_m = input.int(50, "AU open minute",                  group=GRP_TZ, minval=0, maxval=59)
premarket = input.bool(false, "Measure Pre-Market Hour", group=GRP_TZ, tooltip="ON: measure the hour BEFORE each open, so the range is set on the quieter pre-market hour. OFF (default): measure during the opening hour. May not draw on index CFDs, often closed pre-market.")
pm_off    = premarket ? 60 : 0

f_hhmm(h, m) =>
    hh = h < 10 ? "0" + str.tostring(h) : str.tostring(h)
    mm = m < 10 ? "0" + str.tostring(m) : str.tostring(m)
    hh + mm

// Build a one-hour session string in the market's own clock, shifted back an hour for pre-market.
f_sess(h, m) =>
    s = (h * 60 + m - pm_off + 1440) % 1440
    e = (s + 60) % 1440
    f_hhmm(int(s / 60), s % 60) + "-" + f_hhmm(int(e / 60), e % 60)

EU_SESS = f_sess(eu_open_h, eu_open_m)
UK_SESS = f_sess(uk_open_h, uk_open_m)
NY_SESS = f_sess(ny_open_h, ny_open_m)
AU_SESS = f_sess(au_open_h, au_open_m)

// Label text in the DISPLAY timezone, built from the actual session start bar.
f_lbl(t) => f_hhmm(hour(t, TZ), minute(t, TZ)) + "-" + f_hhmm(hour(t + 3600000, TZ), minute(t + 3600000, TZ))

use_eu = input.bool(true,  "Enable European Open",         group=GRP_EU)
use_uk = input.bool(true,  "Enable London Open",           group=GRP_UK)
use_ny = input.bool(true,  "Enable NY Open",               group=GRP_NY)
use_au = input.bool(false, "Enable Asia / Australia Open", group=GRP_AU)

show_box   = input.bool(true, "Show Opening Range Box",      group=GRP_VIS)
show_mid   = input.bool(true, "Show Midline",                group=GRP_VIS)
show_ext   = input.bool(true, "Show H/L Extension Lines",    group=GRP_VIS)
show_shade = input.bool(true, "Shade Active Session Window", group=GRP_VIS)
show_lbl   = input.bool(true, "Label Boxes With Range Size", group=GRP_VIS, tooltip="Marks each box with the session name and how tall the range was. Useful for judging at a glance whether an opening hour was unusually tight or wide compared with recent days.")
ext_bars   = input.int(80,   "Extension Line Length (bars)", group=GRP_VIS, minval=10, maxval=300)
draw_days  = input.int(20,   "Draw History (days)",          group=GRP_VIS, minval=1, maxval=250, tooltip="How many days of session graphics to draw. TradingView caps an indicator at 500 boxes and 500 lines, so drawing months of history exhausts the pool and older drawings disappear. Each enabled session uses one box and three lines per day. Lower this if graphics go missing.")

col_eu_box = input.color(color.new(#A78BFA, 0), "EU Box Colour", group=GRP_EU)
col_uk_box = input.color(color.new(#38BDF8, 0), "UK Box Colour", group=GRP_UK)
col_ny_box = input.color(color.new(#FB923C, 0), "NY Box Colour", group=GRP_NY)
col_au_box = input.color(color.new(#34D399, 0), "AU Box Colour", group=GRP_AU)

// Bars per day varies with timeframe, so budget in days rather than bars.
bars_per_day = timeframe.in_seconds(timeframe.period) > 0 ? math.max(1, math.round(86400 / timeframe.in_seconds(timeframe.period))) : 288
in_draw_range = (last_bar_index - bar_index) <= draw_days * bars_per_day

f_range_txt(sz) => str.tostring(sz, format.mintick)

// SESSION FLAGS - each evaluated in its own market's timezone
eu_in    = use_eu and not na(time("5", EU_SESS, TZ_EU_HOME))
eu_start = eu_in and not eu_in[1]
eu_end   = not eu_in and eu_in[1]

uk_in    = use_uk and not na(time("5", UK_SESS, TZ_UK_HOME))
uk_start = uk_in and not uk_in[1]
uk_end   = not uk_in and uk_in[1]

ny_in    = use_ny and not na(time("5", NY_SESS, TZ_NY_HOME))
ny_start = ny_in and not ny_in[1]
ny_end   = not ny_in and ny_in[1]

au_in    = use_au and not na(time("5", AU_SESS, TZ_AU_HOME))
au_start = au_in and not au_in[1]
au_end   = not au_in and au_in[1]

var float eu_high = na, var float eu_low = na, var int eu_si = na, var int eu_ei = na, var string eu_lbl = ""
var float uk_high = na, var float uk_low = na, var int uk_si = na, var int uk_ei = na, var string uk_lbl = ""
var float ny_high = na, var float ny_low = na, var int ny_si = na, var int ny_ei = na, var string ny_lbl = ""
var float au_high = na, var float au_low = na, var int au_si = na, var int au_ei = na, var string au_lbl = ""

if eu_start
    eu_high := high, eu_low := low, eu_si := bar_index, eu_lbl := f_lbl(time)
if eu_in
    eu_high := math.max(eu_high, high), eu_low := math.min(eu_low, low)
if eu_end
    eu_ei := bar_index
    if show_box and in_draw_range
        box.new(eu_si, eu_high, eu_ei, eu_low, bgcolor=color.new(col_eu_box, 78), border_color=col_eu_box, border_width=1)
    if show_mid and in_draw_range
        line.new(eu_si, (eu_high + eu_low) / 2, eu_ei + ext_bars, (eu_high + eu_low) / 2, color=color.new(col_eu_box, 55), style=line.style_dashed, width=1)
    if show_ext and in_draw_range
        line.new(eu_ei, eu_high, eu_ei + ext_bars, eu_high, color=color.new(col_eu_box, 20), style=line.style_dotted, width=2)
        line.new(eu_ei, eu_low,  eu_ei + ext_bars, eu_low,  color=color.new(col_eu_box, 20), style=line.style_dotted, width=2)
    if show_lbl and in_draw_range
        label.new(eu_si, eu_high, "EU " + eu_lbl + "  ·  " + f_range_txt(eu_high - eu_low), style=label.style_label_down, color=color.new(col_eu_box, 15), textcolor=color.white, size=size.tiny)

if uk_start
    uk_high := high, uk_low := low, uk_si := bar_index, uk_lbl := f_lbl(time)
if uk_in
    uk_high := math.max(uk_high, high), uk_low := math.min(uk_low, low)
if uk_end
    uk_ei := bar_index
    if show_box and in_draw_range
        box.new(uk_si, uk_high, uk_ei, uk_low, bgcolor=color.new(col_uk_box, 78), border_color=col_uk_box, border_width=1)
    if show_mid and in_draw_range
        line.new(uk_si, (uk_high + uk_low) / 2, uk_ei + ext_bars, (uk_high + uk_low) / 2, color=color.new(col_uk_box, 55), style=line.style_dashed, width=1)
    if show_ext and in_draw_range
        line.new(uk_ei, uk_high, uk_ei + ext_bars, uk_high, color=color.new(col_uk_box, 20), style=line.style_dotted, width=2)
        line.new(uk_ei, uk_low,  uk_ei + ext_bars, uk_low,  color=color.new(col_uk_box, 20), style=line.style_dotted, width=2)
    if show_lbl and in_draw_range
        label.new(uk_si, uk_high, "UK " + uk_lbl + "  ·  " + f_range_txt(uk_high - uk_low), style=label.style_label_down, color=color.new(col_uk_box, 15), textcolor=color.white, size=size.tiny)

if ny_start
    ny_high := high, ny_low := low, ny_si := bar_index, ny_lbl := f_lbl(time)
if ny_in
    ny_high := math.max(ny_high, high), ny_low := math.min(ny_low, low)
if ny_end
    ny_ei := bar_index
    if show_box and in_draw_range
        box.new(ny_si, ny_high, ny_ei, ny_low, bgcolor=color.new(col_ny_box, 78), border_color=col_ny_box, border_width=1)
    if show_mid and in_draw_range
        line.new(ny_si, (ny_high + ny_low) / 2, ny_ei + ext_bars, (ny_high + ny_low) / 2, color=color.new(col_ny_box, 55), style=line.style_dashed, width=1)
    if show_ext and in_draw_range
        line.new(ny_ei, ny_high, ny_ei + ext_bars, ny_high, color=color.new(col_ny_box, 20), style=line.style_dotted, width=2)
        line.new(ny_ei, ny_low,  ny_ei + ext_bars, ny_low,  color=color.new(col_ny_box, 20), style=line.style_dotted, width=2)
    if show_lbl and in_draw_range
        label.new(ny_si, ny_high, "NY " + ny_lbl + "  ·  " + f_range_txt(ny_high - ny_low), style=label.style_label_down, color=color.new(col_ny_box, 15), textcolor=color.white, size=size.tiny)

if au_start
    au_high := high, au_low := low, au_si := bar_index, au_lbl := f_lbl(time)
if au_in
    au_high := math.max(au_high, high), au_low := math.min(au_low, low)
if au_end
    au_ei := bar_index
    if show_box and in_draw_range
        box.new(au_si, au_high, au_ei, au_low, bgcolor=color.new(col_au_box, 78), border_color=col_au_box, border_width=1)
    if show_mid and in_draw_range
        line.new(au_si, (au_high + au_low) / 2, au_ei + ext_bars, (au_high + au_low) / 2, color=color.new(col_au_box, 55), style=line.style_dashed, width=1)
    if show_ext and in_draw_range
        line.new(au_ei, au_high, au_ei + ext_bars, au_high, color=color.new(col_au_box, 20), style=line.style_dotted, width=2)
        line.new(au_ei, au_low,  au_ei + ext_bars, au_low,  color=color.new(col_au_box, 20), style=line.style_dotted, width=2)
    if show_lbl and in_draw_range
        label.new(au_si, au_high, "AU " + au_lbl + "  ·  " + f_range_txt(au_high - au_low), style=label.style_label_down, color=color.new(col_au_box, 15), textcolor=color.white, size=size.tiny)

bgcolor(show_shade and eu_in ? color.new(col_eu_box, 92) : na, title="EU Session Shade")
bgcolor(show_shade and uk_in ? color.new(col_uk_box, 92) : na, title="UK Session Shade")
bgcolor(show_shade and ny_in ? color.new(col_ny_box, 92) : na, title="NY Session Shade")
bgcolor(show_shade and au_in ? color.new(col_au_box, 92) : na, title="AU Session Shade")
````
