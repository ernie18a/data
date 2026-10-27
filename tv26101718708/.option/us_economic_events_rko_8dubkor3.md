# US Economic Events [rko]

- url: https://www.tradingview.com/script/8DUBKOR3-US-Economic-Events-rko/
- type: indicator
- pine_id: PUB;cd46df53608244ab9061efdcf8a63598
- version: 2.0

## Description

US Economic Events [rko]

Marks major US economic releases directly on the chart with vertical dashed lines and labeled callouts — no dashboard clutter, no manual calendar imports.

How it works

Events are detected two ways:

Calendar rules — NFP/Unemployment Rate (first Friday of month, 8:30 ET), Initial Jobless Claims (every Thursday, 8:30 ET), and ISM Manufacturing PMI (first business day of month, 10:00 ET) are computed from date math alone, requiring no external data
Hybrid detection — CPI, PPI, GDP, and Retail Sales use request.economic() to identify the release day, then snap the marker to the known BLS release time (8:30 ET), giving correct intraday bar placement rather than midnight
Works on any timeframe

Daily and above: marks the correct day
Intraday (30m, 15m, 5m, 1m…): marks the exact bar containing the release time
Today's Dashboard
A compact table (position configurable) shows today's scheduled events with a live countdown for upcoming releases and a ✓ confirmation once they've fired. Disappears on non-event days.

Events included

Nonfarm Payrolls (NFP)
Unemployment Rate (UR)
ISM Manufacturing PMI
Consumer Price Index (CPI)
Producer Price Index (PPI)
Gross Domestic Product (GDP)
Retail Sales
Initial Jobless Claims (optional)
Settings
Each event can be toggled individually. Label size, line transparency, and dashboard position are all adjustable

## Source Code

````pine
// © Robert Ko (TradingView: @robertko)
//
// MIT License
//
// Copyright (c) 2026 Robert Ko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//@version=6
indicator("US Economic Events [rko]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Settings ──────────────────────────────────────────────────────────────────
grp_ev = "Events"
show_nfp  = input.bool(true,  "NFP / UR – Nonfarm Payrolls (1st Fri 8:30)",  group=grp_ev)
show_ijc  = input.bool(false, "IJC – Initial Claims (every Thu 8:30)",         group=grp_ev)
show_ism  = input.bool(true,  "ISM – Mfg PMI (1st biz day 10:00)",            group=grp_ev)
show_cpi  = input.bool(true,  "CPI – Consumer Price Index (8:30)",             group=grp_ev)
show_ppi  = input.bool(true,  "PPI – Producer Price Index (8:30)",             group=grp_ev)
show_gdp  = input.bool(true,  "GDP – Gross Domestic Product (8:30)",           group=grp_ev)
show_rs   = input.bool(true,  "RS  – Retail Sales (8:30)",                     group=grp_ev)


grp_vis = "Appearance"
lbl_size     = input.string(size.normal, "Label Size", options=[size.tiny, size.small, size.normal, size.large], group=grp_vis)
line_transp  = input.int(65, "Line Transparency (0=solid)", group=grp_vis, minval=0, maxval=100)
show_dash    = input.bool(true, "Show Today's Dashboard", group=grp_vis)
dash_pos_str = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_vis)

// ── ET Time Helpers ────────────────────────────────────────────────────────────
TZ     = "America/New_York"
et_h   = hour(time, TZ)
et_m   = minute(time, TZ)
et_dow = dayofweek(time, TZ)
et_dom = dayofmonth(time, TZ)
et_mon = month(time, TZ)
et_yr  = year(time, TZ)
et_date = et_yr * 10000 + et_mon * 100 + et_dom   // compact date integer YYYYMMDD
now_mins = et_h * 60 + et_m

is_intra = not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)

// True when the current bar's window contains the given ET hh:mm release time.
at_et(h, m) =>
    if not is_intra
        true
    else
        bar_start = et_h * 60 + et_m
        bar_end   = bar_start + math.round(timeframe.in_seconds() / 60)
        release   = h * 60 + m
        bar_start <= release and release < bar_end

// Countdown string from now to release (minutes).  Returns "NOW" if past.
_countdown(release_mins) =>
    diff = release_mins - now_mins
    if diff <= 1
        "NOW"
    else if diff >= 60
        str.tostring(math.floor(diff / 60), "#0") + "h " + str.tostring(math.floor(diff % 60), "#0") + "m"
    else
        str.tostring(math.floor(diff), "#0") + "m"

// ── Release Time Constants (minutes since midnight ET) ─────────────────────────
NFP_MINS  = 8 * 60 + 30    // 510
IJC_MINS  = 8 * 60 + 30    // 510
ISM_MINS  = 10 * 60 + 0    // 600
CPI_MINS  = 8 * 60 + 30    // 510
PPI_MINS  = 8 * 60 + 30    // 510
GDP_MINS  = 8 * 60 + 30    // 510
RS_MINS   = 8 * 60 + 30    // 510

// ── Calendar Rules ─────────────────────────────────────────────────────────────
nfp_hit = show_nfp and et_dow == dayofweek.friday and et_dom <= 7 and at_et(8, 30)

ijc_hit = show_ijc and et_dow == dayofweek.thursday and at_et(8, 30)

is_first_biz = (et_dom == 1 and et_dow >= dayofweek.monday and et_dow <= dayofweek.friday) or
               (et_dom == 2 and et_dow == dayofweek.monday) or
               (et_dom == 3 and et_dow == dayofweek.monday)
ism_hit = show_ism and is_first_biz and at_et(10, 0)

// ── "Is today an event day" (time-agnostic, for dashboard) ────────────────────
today_nfp  = show_nfp  and et_dow == dayofweek.friday and et_dom <= 7
today_ijc  = show_ijc  and et_dow == dayofweek.thursday
today_ism  = show_ism  and is_first_biz

// ── Hybrid Events ─────────────────────────────────────────────────────────────
cpi = request.economic("US", "CPI")
ppi = request.economic("US", "PPI")
gdp = request.economic("US", "GDP")
rs  = request.economic("US", "RSYY")

day_chg(s) => not na(s) and not na(s[1]) and s != s[1]

var bool cpi_pend = false
var bool ppi_pend = false
var bool gdp_pend = false
var bool rs_pend  = false

if day_chg(cpi) and show_cpi
    cpi_pend := true
if day_chg(ppi) and show_ppi
    ppi_pend := true
if day_chg(gdp) and show_gdp
    gdp_pend := true
if day_chg(rs) and show_rs
    rs_pend := true

cpi_hit = false
ppi_hit = false
gdp_hit = false
rs_hit  = false

if is_intra
    if cpi_pend and at_et(8, 30)
        cpi_hit  := true
        cpi_pend := false
    if ppi_pend and at_et(8, 30)
        ppi_hit  := true
        ppi_pend := false
    if gdp_pend and at_et(8, 30)
        gdp_hit  := true
        gdp_pend := false
    if rs_pend and at_et(8, 30)
        rs_hit  := true
        rs_pend := false
else
    cpi_hit := day_chg(cpi) and show_cpi
    ppi_hit := day_chg(ppi) and show_ppi
    gdp_hit := day_chg(gdp) and show_gdp
    rs_hit  := day_chg(rs)  and show_rs

// ── Track Which Events Fired Today (for dashboard done-state) ─────────────────
// Store the ET date when each event fires; compare against today on last bar.
var int nfp_fired_date  = 0
var int ijc_fired_date  = 0
var int ism_fired_date  = 0
var int cpi_fired_date  = 0
var int ppi_fired_date  = 0
var int gdp_fired_date  = 0
var int rs_fired_date   = 0

if nfp_hit
    nfp_fired_date := et_date
if ijc_hit
    ijc_fired_date := et_date
if ism_hit
    ism_fired_date := et_date
if cpi_hit
    cpi_fired_date := et_date
if ppi_hit
    ppi_fired_date := et_date
if gdp_hit
    gdp_fired_date := et_date
if rs_hit
    rs_fired_date := et_date

// ── Per-Bar Event Collection ──────────────────────────────────────────────────
// One entry per event — drawn as individual stacked labels, not combined text.
ev_names  = array.new_string()
ev_colors = array.new_color()

if nfp_hit
    array.push(ev_names,  "Nonfarm Payrolls")
    array.push(ev_colors, color.new(#00c176, 0))
    array.push(ev_names,  "Unemployment Rate")
    array.push(ev_colors, color.new(#00c176, 0))

if ijc_hit
    array.push(ev_names,  "Initial Jobless Claims")
    array.push(ev_colors, color.new(#f9a825, 0))

if ism_hit
    array.push(ev_names,  "ISM Manufacturing PMI")
    array.push(ev_colors, color.new(#00897b, 0))

if cpi_hit
    array.push(ev_names,  "Consumer Price Index")
    array.push(ev_colors, color.new(#e53935, 0))

if ppi_hit
    array.push(ev_names,  "Producer Price Index")
    array.push(ev_colors, color.new(#8e24aa, 0))

if gdp_hit
    array.push(ev_names,  "Gross Domestic Product")
    array.push(ev_colors, color.new(#1e88e5, 0))

if rs_hit
    array.push(ev_names,  "Retail Sales")
    array.push(ev_colors, color.new(#d81b60, 0))


// ── Draw Chart Markers ────────────────────────────────────────────────────────
n_ev = array.size(ev_names)
if n_ev > 0
    // One vertical line per bar, colored by the highest-priority event
    line.new(bar_index, high, bar_index, low, color=color.new(array.get(ev_colors, 0), line_transp), width=1, style=line.style_dashed, extend=extend.both)
    // Individual label per event, stacked upward by 1 ATR each so they don't overlap
    step = nz(ta.atr(14), high - low)
    for i = 0 to n_ev - 1
        label.new(bar_index, high + step * i, text=array.get(ev_names, i), color=color.new(#FFD600, 0), textcolor=color.black, style=label.style_label_down, size=lbl_size, yloc=yloc.price, text_formatting=text.format_bold)

// ── Today's Event Dashboard ────────────────────────────────────────────────────
// Upcoming events (orange) and already-fired events (green) for today only.
// Only drawn on the last bar.
if show_dash and barstate.islast
    dash_pos = dash_pos_str == "Top Left"     ? position.top_left     :
               dash_pos_str == "Bottom Right" ? position.bottom_right :
               dash_pos_str == "Bottom Left"  ? position.bottom_left  :
               position.top_right

    // Collect today's events as parallel arrays: name, release_mins, done?
    var names  = array.new_string()
    var rmins  = array.new_int()
    var done   = array.new_bool()
    var colors = array.new_color()

    array.clear(names)
    array.clear(rmins)
    array.clear(done)
    array.clear(colors)

    if today_nfp
        array.push(names,  "Nonfarm Payrolls")
        array.push(rmins,  NFP_MINS)
        array.push(done,   nfp_fired_date == et_date)
        array.push(colors, color.new(#00c176, 0))
        array.push(names,  "Unemployment Rate")
        array.push(rmins,  NFP_MINS)
        array.push(done,   nfp_fired_date == et_date)
        array.push(colors, color.new(#00c176, 0))

    if today_ijc
        array.push(names,  "Initial Jobless Claims")
        array.push(rmins,  IJC_MINS)
        array.push(done,   ijc_fired_date == et_date)
        array.push(colors, color.new(#f9a825, 0))

    if today_ism
        array.push(names,  "ISM Manufacturing PMI")
        array.push(rmins,  ISM_MINS)
        array.push(done,   ism_fired_date == et_date)
        array.push(colors, color.new(#00897b, 0))

    // Hybrid events: only show in dashboard if they fired today
    if cpi_fired_date == et_date
        array.push(names,  "Consumer Price Index (CPI)")
        array.push(rmins,  CPI_MINS)
        array.push(done,   true)
        array.push(colors, color.new(#e53935, 0))

    if ppi_fired_date == et_date
        array.push(names,  "Producer Price Index (PPI)")
        array.push(rmins,  PPI_MINS)
        array.push(done,   true)
        array.push(colors, color.new(#8e24aa, 0))

    if gdp_fired_date == et_date
        array.push(names,  "Gross Domestic Product (GDP)")
        array.push(rmins,  GDP_MINS)
        array.push(done,   true)
        array.push(colors, color.new(#1e88e5, 0))

    if rs_fired_date == et_date
        array.push(names,  "Retail Sales")
        array.push(rmins,  RS_MINS)
        array.push(done,   true)
        array.push(colors, color.new(#d81b60, 0))

    n = array.size(names)
    if n > 0
        t = table.new(dash_pos, 3, n + 1, border_width=1, border_color=color.new(color.gray, 60), frame_color=color.new(color.gray, 60), frame_width=1)
        hbg = color.new(#1a237e, 10)
        table.cell(t, 0, 0, "Event",   bgcolor=hbg, text_color=color.white, text_size=size.small)
        table.cell(t, 1, 0, "ET",      bgcolor=hbg, text_color=color.white, text_size=size.small)
        table.cell(t, 2, 0, "Status",  bgcolor=hbg, text_color=color.white, text_size=size.small)

        for i = 0 to n - 1
            ev_name  = array.get(names,  i)
            rel_min  = array.get(rmins,  i)
            is_done  = array.get(done,   i)
            ev_col   = array.get(colors, i)

            hh = math.floor(rel_min / 60)
            mm = math.floor(rel_min % 60)
            time_str = str.tostring(hh, "#0") + ":" + (mm < 10 ? "0" : "") + str.tostring(mm, "#0")

            status_txt = is_done ? "✓ done" : is_intra ? _countdown(rel_min) : "today"
            row_bg     = is_done ? color.new(#1b5e20, 30) : color.new(#e65100, 20)
            txt_col    = is_done ? color.new(#a5d6a7, 0)  : color.new(#ffcc80, 0)

            table.cell(t, 0, i + 1, ev_name,    bgcolor=row_bg, text_color=txt_col,           text_size=size.small)
            table.cell(t, 1, i + 1, time_str,   bgcolor=row_bg, text_color=color.white,       text_size=size.small)
            table.cell(t, 2, i + 1, status_txt, bgcolor=row_bg, text_color=txt_col,           text_size=size.small)
````
