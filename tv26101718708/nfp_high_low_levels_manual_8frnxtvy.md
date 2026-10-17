# NFP High & Low Levels (Manual)

- url: https://www.tradingview.com/script/8frNXTvy-NFP-High-Low-Levels-Manual/
- type: indicator
- pine_id: PUB;7a140af86f17406fb1054ff60c721c45
- version: 1.0

## Description

[b]NFP High & Low Levels[/b]
This indicator automatically plots the High and Low of Non-Farm Payrolls (NFP) release days as horizontal levels on your chart. These levels often act as significant support and resistance in the days and weeks following the release.

[b]How it works[/b]
On NFP days, the script captures the High and Low of the defined session (default 08:30–16:00 New York time on intraday charts).
On Daily, Weekly, and Monthly charts it uses the full daily candle High/Low.
Levels are drawn as horizontal lines that start on the NFP day and extend forward.
Labels appear just to the right of the latest candle showing the month and price.

[b]Features[/b]
Works on all timeframes (intraday + higher timeframes)
Pre-loaded with 2025 and 2026 NFP dates (including known delayed releases)
Easy to add future NFP dates by editing the date list in the code
Customizable colors, label visibility, and number of levels shown
Clean visual design with light orange Highs and darker orange Lows

[b]How to update for future NFP dates[/b]
Open the script in the Pine Editor and add new dates to the nfp_dates array using this format:
[pine]pinescripttimestamp("America/New_York", YYYY, M, D, 0, 0),[/pine]

[b]Notes[/b]
NFP is usually released on the first Friday of the month, but can be delayed by holidays or government shutdowns.
The included date list already accounts for known delayed releases in 2025 and 2026.
Best used as a reference for key support/resistance zones rather than a standalone trading signal.

## Source Code

````pine
//@version=6
indicator("NFP High & Low Levels (Manual)", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── Inputs ────────────────────────────────────────────────────────────────
lookback     = input.int(12, "Number of recent NFP levels to show", minval=1, maxval=24)
session_str  = input.session("0830-1600", "NFP Session (New York time) - Intraday only")
high_color   = input.color(#FFB347, "High Color")   // Light orange
low_color    = input.color(#D35400, "Low Color")    // Darker orange
show_labels  = input.bool(true, "Show Labels")
show_price   = input.bool(true, "Show Price in Labels")

// ─── Full list of NFP dates (including delayed releases) ───────────────────
// To add future NFP dates, simply insert a new line in the format below:
// timestamp("America/New_York", YYYY, M, D, 0, 0),
// Example: timestamp("America/New_York", 2027, 1, 8, 0, 0),
nfp_dates = array.from(
    // 2026
    timestamp("America/New_York", 2026, 12, 4, 0, 0),
    timestamp("America/New_York", 2026, 11, 6, 0, 0),
    timestamp("America/New_York", 2026, 10, 2, 0, 0),
    timestamp("America/New_York", 2026, 9, 4, 0, 0),
    timestamp("America/New_York", 2026, 8, 7, 0, 0),
    timestamp("America/New_York", 2026, 7, 2, 0, 0),
    timestamp("America/New_York", 2026, 6, 5, 0, 0),
    timestamp("America/New_York", 2026, 5, 8, 0, 0),
    timestamp("America/New_York", 2026, 4, 3, 0, 0),
    timestamp("America/New_York", 2026, 3, 6, 0, 0),
    timestamp("America/New_York", 2026, 2, 11, 0, 0),
    timestamp("America/New_York", 2026, 1, 9, 0, 0),

    // 2025
    timestamp("America/New_York", 2025, 12, 16, 0, 0),
    timestamp("America/New_York", 2025, 11, 20, 0, 0),
    timestamp("America/New_York", 2025, 9, 5, 0, 0),
    timestamp("America/New_York", 2025, 8, 1, 0, 0),
    timestamp("America/New_York", 2025, 7, 3, 0, 0),
    timestamp("America/New_York", 2025, 6, 6, 0, 0),
    timestamp("America/New_York", 2025, 5, 2, 0, 0),
    timestamp("America/New_York", 2025, 4, 4, 0, 0),
    timestamp("America/New_York", 2025, 3, 7, 0, 0),
    timestamp("America/New_York", 2025, 2, 7, 0, 0),
    timestamp("America/New_York", 2025, 1, 10, 0, 0)
)

// ─── Detect NFP day ────────────────────────────────────────────────────────
is_nfp_day = false

for i = 0 to array.size(nfp_dates) - 1
    nfp_ts = array.get(nfp_dates, i)
    if year == year(nfp_ts, "America/New_York") and 
       month == month(nfp_ts, "America/New_York") and 
       dayofmonth == dayofmonth(nfp_ts, "America/New_York")
        is_nfp_day := true
        break

// ─── Capture High / Low ────────────────────────────────────────────────────
is_intraday = timeframe.isintraday

var float sess_high = na
var float sess_low  = na
var int   sess_time = na

if is_nfp_day
    if is_intraday
        in_session = not na(time(timeframe.period, session_str, "America/New_York"))
        if in_session
            if na(sess_high)
                sess_high := high
                sess_low  := low
                sess_time := time
            else
                sess_high := math.max(sess_high, high)
                sess_low  := math.min(sess_low, low)
    else
        sess_high := high
        sess_low  := low
        sess_time := time

// Store finished levels
var array<float>  highs  = array.new<float>()
var array<float>  lows   = array.new<float>()
var array<int>    times  = array.new<int>()
var array<string> labels = array.new<string>()

store_level = false

if is_intraday
    in_session = not na(time(timeframe.period, session_str, "America/New_York"))
    store_level := is_nfp_day and in_session[1] and not in_session and not na(sess_high[1])
else
    store_level := is_nfp_day and barstate.isconfirmed and not na(sess_high)

if store_level
    array.unshift(highs, is_intraday ? sess_high[1] : sess_high)
    array.unshift(lows,  is_intraday ? sess_low[1]  : sess_low)
    array.unshift(times, is_intraday ? sess_time[1] : sess_time)
    array.unshift(labels, str.format("{0}/{1}", month, year))

    if array.size(highs) > lookback
        array.pop(highs)
        array.pop(lows)
        array.pop(times)
        array.pop(labels)

    sess_high := na
    sess_low  := na
    sess_time := na

// ─── Draw lines + labels ───────────────────────────────────────────────────
var array<line>  h_lines  = array.new<line>()
var array<line>  l_lines  = array.new<line>()
var array<label> h_labels = array.new<label>()
var array<label> l_labels = array.new<label>()

if barstate.islast
    for l in h_lines
        line.delete(l)
    for l in l_lines
        line.delete(l)
    for lb in h_labels
        label.delete(lb)
    for lb in l_labels
        label.delete(lb)
    array.clear(h_lines)
    array.clear(l_lines)
    array.clear(h_labels)
    array.clear(l_labels)

    size = array.size(highs)
    if size > 0
        end_time = time + 2 * timeframe.in_seconds() * 1000

        for i = 0 to size - 1
            h_val   = array.get(highs, i)
            l_val   = array.get(lows, i)
            start_t = array.get(times, i)
            lab     = array.get(labels, i)

            ln_h = line.new(start_t, h_val, end_time, h_val, 
                 xloc=xloc.bar_time, 
                 color=high_color, width=1, 
                 style=line.style_solid, extend=extend.none)
            array.push(h_lines, ln_h)

            ln_l = line.new(start_t, l_val, end_time, l_val, 
                 xloc=xloc.bar_time, 
                 color=low_color, width=1, 
                 style=line.style_solid, extend=extend.none)
            array.push(l_lines, ln_l)

            if show_labels
                txt_h = show_price ? "NFP H " + lab + "  " + str.tostring(h_val, format.mintick) : "NFP H " + lab
                txt_l = show_price ? "NFP L " + lab + "  " + str.tostring(l_val, format.mintick) : "NFP L " + lab

                lb_h = label.new(bar_index + 3, h_val, txt_h, 
                     style=label.style_label_left, 
                     color=color.new(high_color, 70), 
                     textcolor=high_color, size=size.small)
                lb_l = label.new(bar_index + 3, l_val, txt_l, 
                     style=label.style_label_left, 
                     color=color.new(low_color, 70), 
                     textcolor=low_color, size=size.small)
                array.push(h_labels, lb_h)
                array.push(l_labels, lb_l)

bgcolor(is_nfp_day ? color.new(color.orange, 92) : na)
````
